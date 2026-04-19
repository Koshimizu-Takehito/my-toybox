#if os(iOS)
import SpriteKit

// MARK: - PhysicsTagThumbnailScene

/// Compact SpriteKit scene for the sidebar thumbnail: same capsule-tag concept as `PhysicsTagScene`,
/// scaled for `defaultMinListRowHeight`-sized views (no CoreMotion, no touch).
final class PhysicsTagThumbnailScene: SKScene {
    private let spawnRunner = SKNode()
    private var hasSpawnedInitially = false

    override init(size: CGSize) {
        super.init(size: size)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override convenience init() {
        self.init(size: .zero)
    }

    private func commonInit() {
        backgroundColor = .black
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
    }
}

// MARK: - Lifecycle

extension PhysicsTagThumbnailScene {
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        anchorPoint = .zero

        updatePhysicsBounds()

        if spawnRunner.parent == nil {
            spawnRunner.zPosition = -10000
            addChild(spawnRunner)
        }

        spawnTagsIfLayoutReady()
    }

    override func willMove(from view: SKView) {
        super.willMove(from: view)
        spawnRunner.removeAllActions()
        removeAllActions()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard oldSize != size else { return }
        updatePhysicsBounds()
        spawnTagsIfLayoutReady()
    }

    private func updatePhysicsBounds() {
        let extraHeight = Self.physicsTopExtension(for: size)
        physicsBody = SKPhysicsBody(
            edgeLoopFrom: CGRect(x: 0, y: 0, width: size.width, height: size.height + extraHeight)
        )
    }
}

// MARK: - Spawn

extension PhysicsTagThumbnailScene {
    private static let spawnInterval: TimeInterval = 0.1
    private static let tagCount = 8
    private static let tagNodeName = "physicsTagThumbnail"
    private static let maxSpawnZRotation: CGFloat = .pi / 3
    private static let spawnWallPadding: CGFloat = 1
    private static let spawnBandAboveScreen: CGFloat = 2
    private static let spawnAttemptsPerTag = 5000
    private static let spawnBatchRetries = 8

    private struct SpawnSpecification {
        var position: CGPoint
        var rotation: CGFloat
    }

    private static var enclosingRadius: CGFloat {
        0.5 * hypot(tagWidth, tagHeight)
    }

    private func physicsWorldTotalHeight() -> CGFloat {
        size.height + Self.physicsTopExtension(for: size)
    }

    private func buildSpawnSpecifications() -> [SpawnSpecification] {
        let r = Self.enclosingRadius
        let d = 2 * r
        let pad = Self.spawnWallPadding
        let xMin = r + pad
        let xMax = size.width - r - pad
        let yMin = size.height + r + Self.spawnBandAboveScreen
        let yMax = physicsWorldTotalHeight() - r - pad
        guard xMin <= xMax, yMin <= yMax else { return [] }
        let dSq = d * d

        for _ in 0 ..< Self.spawnBatchRetries {
            var centers: [CGPoint] = []
            centers.reserveCapacity(Self.tagCount)
            var success = true

            for _ in 0 ..< Self.tagCount {
                var placed = false
                for _ in 0 ..< Self.spawnAttemptsPerTag {
                    let cx = CGFloat.random(in: xMin ... xMax)
                    let cy = CGFloat.random(in: yMin ... yMax)
                    let overlaps = centers.contains { existing in
                        let dx = cx - existing.x
                        let dy = cy - existing.y
                        return dx * dx + dy * dy < dSq
                    }
                    if !overlaps {
                        centers.append(CGPoint(x: cx, y: cy))
                        placed = true
                        break
                    }
                }
                if !placed { success = false
                    break
                }
            }

            if success {
                return centers.map { center in
                    SpawnSpecification(
                        position: center,
                        rotation: CGFloat.random(in: -Self.maxSpawnZRotation ... Self.maxSpawnZRotation)
                    )
                }
            }
        }
        return []
    }

    private static func physicsTopExtension(for sceneSize: CGSize) -> CGFloat {
        let r = enclosingRadius
        let pad = spawnWallPadding
        let xRange = sceneSize.width - 2 * (r + pad)
        guard xRange > 0 else { return 4 * r }
        let totalCircleArea = CGFloat(tagCount) * .pi * r * r
        let targetPackingFraction: CGFloat = 0.25
        let yRange = totalCircleArea / (targetPackingFraction * xRange)
        return yRange + 2 * r + pad + spawnBandAboveScreen
    }

    private func spawnTagsIfLayoutReady() {
        guard !hasSpawnedInitially else { return }
        guard size.width > Self.tagWidth, size.height > Self.tagHeight else { return }
        hasSpawnedInitially = true
        spawnTags()
    }

    private func spawnTags() {
        let specs = buildSpawnSpecifications().shuffled()
        let palette = (TagColor.allCases + TagColor.allCases).shuffled()
        let colors = Array(palette.prefix(Self.tagCount))
        let actions: [SKAction] = colors.enumerated().map { index, color in
            .sequence([
                .wait(forDuration: Self.spawnInterval),
                .run { [weak self] in
                    guard let self, index < specs.count else { return }
                    let s = specs[index]
                    addTagNode(color: color, zOrder: index, position: s.position, rotation: s.rotation)
                },
            ])
        }
        spawnRunner.run(.sequence(actions))
    }

    private func addTagNode(color: TagColor, zOrder: Int, position: CGPoint, rotation: CGFloat) {
        guard size.width > Self.tagWidth, size.height > Self.tagHeight else { return }
        let node = makeTagNode(color: color)
        node.position = position
        node.zRotation = rotation
        node.zPosition = CGFloat(zOrder)
        addChild(node)
    }
}

// MARK: - Tag node (compact)

extension PhysicsTagThumbnailScene {
    private static let tagHeight: CGFloat = 12
    private static let dotDiameter: CGFloat = 3
    private static let leftPadding: CGFloat = 2
    private static let dotTextGap: CGFloat = 2
    private static let rightPadding: CGFloat = 2
    private static let label = "tag"
    private static let font = UIFont.systemFont(ofSize: 6, weight: .bold)
    private static var textWidth: CGFloat = {
        let attr = NSAttributedString(string: label, attributes: [.font: font])
        return ceil(attr.size().width)
    }()

    private static var tagWidth: CGFloat {
        leftPadding + dotDiameter + dotTextGap + textWidth + rightPadding
    }

    private static var textureCache: [TagColor: SKTexture] = [:]

    private func makeTagNode(color: TagColor) -> SKSpriteNode {
        let texture = Self.textureCache[color] ?? {
            let tex = SKTexture(image: renderTagImage(color: color))
            Self.textureCache[color] = tex
            return tex
        }()
        let tagSize = CGSize(width: Self.tagWidth, height: Self.tagHeight)
        let node = SKSpriteNode(texture: texture, size: tagSize)
        node.name = Self.tagNodeName
        node.physicsBody = {
            let body = SKPhysicsBody(rectangleOf: tagSize)
            body.restitution = 0.2
            body.friction = 0.3
            body.linearDamping = 0.12
            body.angularDamping = 0.35
            body.allowsRotation = true
            body.affectedByGravity = true
            return body
        }()
        return node
    }

    private func renderTagImage(color: TagColor) -> UIImage {
        let size = CGSize(width: Self.tagWidth, height: Self.tagHeight)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            let rect = CGRect(origin: .zero, size: size)

            let capsule = UIBezierPath(roundedRect: rect, cornerRadius: size.height / 2)
            color.backgroundColor.setFill()
            capsule.fill()

            let dotRect = CGRect(
                x: Self.leftPadding,
                y: (size.height - Self.dotDiameter) / 2,
                width: Self.dotDiameter,
                height: Self.dotDiameter
            )
            color.foregroundColor.setFill()
            UIBezierPath(ovalIn: dotRect).fill()

            let attr = NSAttributedString(
                string: Self.label,
                attributes: [.font: Self.font, .foregroundColor: color.foregroundColor]
            )
            let textSize = attr.boundingRect(
                with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin],
                context: nil
            ).size
            let textOrigin = CGPoint(
                x: Self.leftPadding + Self.dotDiameter + Self.dotTextGap,
                y: (size.height - textSize.height) / 2
            )
            attr.draw(at: textOrigin)
        }
    }
}

#endif
