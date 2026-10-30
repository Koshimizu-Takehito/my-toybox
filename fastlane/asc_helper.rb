require "json"
require "net/http"

# App Store Connect API calls for submission prerequisites that `deliver`
# doesn't handle. Uses the token set by `app_store_connect_api_key`.
module ASCHelper
  UI = FastlaneCore::UI

  # Age rating questions that may stay unanswered. `socialMediaAgeRestricted`
  # becomes required once `socialMedia` is true.
  OPTIONAL_AGE_RATING_ATTRIBUTES = %w[
    developerAgeRatingInfoUrl
    gracRatingClassificationNumber
    kidsAgeBand
    socialMediaAgeRestricted
  ].freeze

  # App info states whose age rating can still change, most likely first.
  EDITABLE_APP_INFO_STATES = %w[PREPARE_FOR_SUBMISSION DEVELOPER_REJECTED REJECTED].freeze
  SUPERSEDED_APP_INFO_STATES = %w[READY_FOR_DISTRIBUTION REPLACED_WITH_NEW_INFO].freeze

  module_function

  # Returns [Net::HTTPResponse, parsed JSON or {}] without raising on HTTP errors.
  def raw_request(method, path, body = nil)
    token = Spaceship::ConnectAPI.token || UI.user_error!("No App Store Connect token. Run through a lane that calls app_store_connect_api_key.")
    token.refresh! if token.expired?

    uri = URI("https://api.appstoreconnect.apple.com/v1/#{path}")
    req = Net::HTTP.const_get(method.to_s.capitalize).new(uri)
    req["Authorization"] = "Bearer #{token.text}"
    req["Content-Type"] = "application/json"
    req.body = JSON.generate(body) if body

    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req) }
    json = begin
      res.body.to_s.empty? ? {} : JSON.parse(res.body)
    rescue JSON::ParserError
      {} # e.g. an HTML 502/503 page
    end
    [res, json]
  end

  def request(method, path, body = nil)
    res, json = raw_request(method, path, body)
    return json if res.is_a?(Net::HTTPSuccess)

    details = json["errors"]&.to_json || res.body.to_s[0, 200]
    UI.user_error!("ASC API #{method.upcase} #{path} failed (#{res.code}): #{details}")
  end

  def app_id
    bundle_id = CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)
    Spaceship::ConnectAPI::App.find(bundle_id)&.id || UI.user_error!("App #{bundle_id} not found on App Store Connect.")
  end

  def app_store_version(app_id:, version_string:)
    request(:get, "apps/#{app_id}/appStoreVersions?filter[platform]=IOS&filter[versionString]=#{version_string}&include=appClipDefaultExperience")["data"].first ||
      UI.user_error!("App Store version #{version_string} not found. Run `make metadata-push VERSION=#{version_string}` first.")
  end

  # Warns about age rating questions that look unanswered. Apple adds required
  # questions from time to time, so this can't be exhaustive; the authoritative
  # answer comes from `explain_review_submission_errors` when a submission fails.
  def warn_unanswered_age_rating(app_id:)
    info = request(:get, "apps/#{app_id}/appInfos")["data"]
      .reject { |i| SUPERSEDED_APP_INFO_STATES.include?(i.dig("attributes", "state")) }
      .min_by { |i| EDITABLE_APP_INFO_STATES.index(i.dig("attributes", "state")) || EDITABLE_APP_INFO_STATES.size }
    return UI.important("No editable app info found; skipped the age rating check.") if info.nil?

    attributes = request(:get, "appInfos/#{info["id"]}/ageRatingDeclaration").dig("data", "attributes")
    missing = attributes.select { |key, value| value.nil? && !OPTIONAL_AGE_RATING_ATTRIBUTES.include?(key) }.keys
    missing << "socialMediaAgeRestricted" if attributes["socialMedia"] == true && attributes["socialMediaAgeRestricted"].nil?
    return UI.message("Age rating questions look answered.") if missing.empty?

    UI.important("These age rating questions look unanswered (App Information → Age Rating): #{missing.join(", ")}")
  end

  # App Clip default experiences belong to a single App Store version. When the
  # version has none yet, copy the most recent one (action, subtitle, header image).
  def ensure_app_clip_default_experience!(app_id:, version_string:, dry_run: false)
    clip = request(:get, "apps/#{app_id}/appClips")["data"].first
    return if clip.nil?

    version = app_store_version(app_id: app_id, version_string: version_string)
    if version.dig("relationships", "appClipDefaultExperience", "data")
      return UI.message("App Clip default experience is already set for #{version_string}.")
    end

    experiences = request(:get, "appClips/#{clip["id"]}/appClipDefaultExperiences?include=releaseWithAppStoreVersion&limit=200")
    release_versions = (experiences["included"] || []).select { |i| i["type"] == "appStoreVersions" }.to_h { |v| [v["id"], v] }
    released_with = ->(experience) { release_versions[experience.dig("relationships", "releaseWithAppStoreVersion", "data", "id")] }

    template = experiences["data"]
      .select { |e| released_with.(e) && released_with.(e)["id"] != version["id"] }
      .max_by { |e| released_with.(e).dig("attributes", "createdDate") }
    UI.user_error!("No App Clip default experience to copy. Set one up for #{version_string} in App Store Connect.") if template.nil?

    source = released_with.(template).dig("attributes", "versionString")
    return UI.important("Would copy the App Clip default experience of #{source} to #{version_string}.") if dry_run

    request(:post, "appClipDefaultExperiences", {
      data: {
        type: "appClipDefaultExperiences",
        attributes: { action: template.dig("attributes", "action") },
        relationships: {
          appClip: { data: { type: "appClips", id: clip["id"] } },
          releaseWithAppStoreVersion: { data: { type: "appStoreVersions", id: version["id"] } },
          appClipDefaultExperienceTemplate: { data: { type: "appClipDefaultExperiences", id: template["id"] } },
        },
      },
    })
    UI.success("Copied the App Clip default experience of #{source} to #{version_string}.")
  end

  # `deliver` reports a rejected review item only by its title. Adding the version
  # to the draft submission again returns the per-field reasons
  # (meta.associatedErrors); print them so the fix is obvious. Called while
  # handling deliver's error, so it never raises and leaves the draft as it was.
  def explain_review_submission_errors(app_id:, version_string:)
    version = app_store_version(app_id: app_id, version_string: version_string)
    submission = request(:get, "apps/#{app_id}/reviewSubmissions?filter[platform]=IOS&filter[state]=READY_FOR_REVIEW")["data"].first
    return if submission.nil?

    res, json = raw_request(:post, "reviewSubmissionItems", {
      data: {
        type: "reviewSubmissionItems",
        relationships: {
          reviewSubmission: { data: { type: "reviewSubmissions", id: submission["id"] } },
          appStoreVersion: { data: { type: "appStoreVersions", id: version["id"] } },
        },
      },
    })
    if res.is_a?(Net::HTTPSuccess)
      # deliver refuses a draft that already has items, so take this one back out.
      removed, = raw_request(:delete, "reviewSubmissionItems/#{json.dig("data", "id")}")
      return UI.important("#{version_string} passed review item checks on retry; run submit_review again.") if removed.is_a?(Net::HTTPSuccess)

      return UI.important("#{version_string} was added to draft review submission #{submission["id"]}. Remove it in App Store Connect before running submit_review again.")
    end

    errors = json["errors"] || []
    reasons = errors.flat_map { |error| (error.dig("meta", "associatedErrors") || {}).flat_map { |path, items| items.map { |e| "#{path}: #{e["detail"]}" } } }
    reasons = errors.map { |error| [error["title"], error["detail"]].compact.join(" ") } if reasons.empty?
    UI.error("App Store Connect did not accept #{version_string} for review (#{res.code}):")
    reasons.each { |reason| UI.error("  - #{reason}") }
  rescue StandardError => e
    UI.important("Could not fetch the rejection reasons: #{e.message}. Check the draft review submission in App Store Connect.")
  end
end
