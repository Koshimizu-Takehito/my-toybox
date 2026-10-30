require "json"
require "net/http"

# App Store Connect API calls for submission prerequisites that `deliver`
# doesn't handle. Uses the token set by `app_store_connect_api_key`.
module ASCHelper
  UI = FastlaneCore::UI

  # Age rating questions that may stay unanswered. Apple adds required ones
  # from time to time (e.g. `socialMedia`); an unanswered one makes the review
  # submission fail with a bare 409.
  OPTIONAL_AGE_RATING_ATTRIBUTES = %w[
    developerAgeRatingInfoUrl
    gracRatingClassificationNumber
    kidsAgeBand
    socialMediaAgeRestricted
  ].freeze

  module_function

  def request(method, path, body = nil)
    token = Spaceship::ConnectAPI.token
    token.refresh! if token.expired?

    uri = URI("https://api.appstoreconnect.apple.com/v1/#{path}")
    req = Net::HTTP.const_get(method.to_s.capitalize).new(uri)
    req["Authorization"] = "Bearer #{token.text}"
    req["Content-Type"] = "application/json"
    req.body = JSON.generate(body) if body

    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req) }
    json = res.body.to_s.empty? ? {} : JSON.parse(res.body)
    UI.user_error!("ASC API #{method.upcase} #{path} failed (#{res.code}): #{json["errors"].to_json}") unless res.is_a?(Net::HTTPSuccess)
    json
  end

  def app_id(bundle_id)
    Spaceship::ConnectAPI::App.find(bundle_id)&.id || UI.user_error!("App #{bundle_id} not found on App Store Connect.")
  end

  # Fails with the names of unanswered age rating questions on the editable app info.
  def verify_age_rating_answered!(app_id:)
    infos = request(:get, "apps/#{app_id}/appInfos")["data"]
    info = infos.find { |i| i.dig("attributes", "state") != "READY_FOR_DISTRIBUTION" } || infos.first
    attributes = request(:get, "appInfos/#{info["id"]}/ageRatingDeclaration").dig("data", "attributes")

    missing = attributes.select { |key, value| value.nil? && !OPTIONAL_AGE_RATING_ATTRIBUTES.include?(key) }.keys
    return UI.message("Age rating questions are all answered.") if missing.empty?

    UI.user_error!("Answer these age rating questions in App Store Connect (App Information → Age Rating) before submitting: #{missing.join(", ")}")
  end

  # App Clip default experiences belong to a single App Store version. When the
  # version has none yet, copy the most recent one (action, subtitle, header image).
  def ensure_app_clip_default_experience!(app_id:, version_string:)
    clip = request(:get, "apps/#{app_id}/appClips")["data"].first
    return if clip.nil?

    version = request(:get, "apps/#{app_id}/appStoreVersions?filter[platform]=IOS&filter[versionString]=#{version_string}")["data"].first
    UI.user_error!("App Store version #{version_string} not found. Run `make metadata-push VERSION=#{version_string}` first.") if version.nil?

    experiences = request(:get, "appClips/#{clip["id"]}/appClipDefaultExperiences?include=releaseWithAppStoreVersion")
    release_versions = (experiences["included"] || []).select { |i| i["type"] == "appStoreVersions" }.to_h { |v| [v["id"], v] }
    released_with = ->(experience) { release_versions[experience.dig("relationships", "releaseWithAppStoreVersion", "data", "id")] }

    if experiences["data"].any? { |e| released_with.(e)&.dig("id") == version["id"] }
      return UI.message("App Clip default experience is already set for #{version_string}.")
    end

    template = experiences["data"]
      .select { |e| released_with.(e) }
      .max_by { |e| released_with.(e).dig("attributes", "createdDate") }
    UI.user_error!("No App Clip default experience to copy. Set one up for #{version_string} in App Store Connect.") if template.nil?

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
    UI.success("Copied the App Clip default experience of #{released_with.(template).dig("attributes", "versionString")} to #{version_string}.")
  end
end
