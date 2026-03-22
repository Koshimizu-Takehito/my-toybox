import CoreMotion
import SpriteKit

#if os(iOS)

// MARK: - PhysicsTagScene

/// SpriteKit scene that manages physics simulation, CoreMotion, and touch handling.
final class PhysicsTagScene: SKScene {
    private let motionManager = CMMotionManager()
    /// Child node that hosts spawn `SKAction`s, decoupled from the scene's `removeAllActions()` so the
    /// spawn sequence does not stop during transient SwiftUI/Navigation `willMove` events.
    private let spawnRunner = SKNode()
    private var draggedNode: SKSpriteNode?
    private var dragOffset: CGPoint = .zero
    private var lastDragPosition: CGPoint = .zero
    private var lastDragTimestamp: TimeInterval = 0
    private var hasSpawnedInitially = false

    var usesDeviceMotion = true {
        didSet {
            guard usesDeviceMotion != oldValue else { return }
            if usesDeviceMotion {
                startMotionUpdates()
            } else {
                motionManager.stopDeviceMotionUpdates()
                physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
            }
        }
    }
}

// MARK: - Lifecycle

extension PhysicsTagScene {
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        anchorPoint = .zero

        updatePhysicsBounds()

        if spawnRunner.parent == nil {
            spawnRunner.zPosition = -10_000
            addChild(spawnRunner)
        }

        startMotionUpdates()
        spawnTagsIfLayoutReady()
    }

    override func willMove(from view: SKView) {
        super.willMove(from: view)
        releaseDraggedNode()
        motionManager.stopDeviceMotionUpdates()
        // Spawn runs on `spawnRunner`, so only remove actions attached directly to the scene.
        removeAllActions()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard oldSize != size else { return }
        updatePhysicsBounds()
        spawnTagsIfLayoutReady()
    }

    /// `edgeLoop` extended upward for spawning. Visible area is `0...size.height`, with an invisible buffer above.
    private func updatePhysicsBounds() {
        let extraHeight = Self.physicsTopExtension(for: size)
        physicsBody = SKPhysicsBody(
            edgeLoopFrom: CGRect(x: 0, y: 0, width: size.width, height: size.height + extraHeight)
        )
    }
}

// MARK: - CoreMotion

extension PhysicsTagScene {
    fileprivate func startMotionUpdates() {
        #if !targetEnvironment(simulator)
        guard !motionManager.isDeviceMotionActive else { return }
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let gravity = motion?.gravity else { return }
            self?.physicsWorld.gravity = CGVector(dx: gravity.x * 9.8, dy: gravity.y * 9.8)
        }
        #endif
    }
}

// MARK: - Spawn

/// Placement using minimum enclosing circles:
/// Collision uses circumradius r = hypot(w,h)/2 for the rectangle (tagWidth × tagHeight).
/// Circles are rotation-invariant, so sample (x, y) uniformly across the full width first, then assign θ independently.
extension PhysicsTagScene {
    private static let spawnInterval: TimeInterval = 0.15
    private static let tagCount = 20
    private static let tagNodeName = "physicsTag"
    private static let maxSpawnZRotation: CGFloat = .pi / 2.2
    private static let spawnWallPadding: CGFloat = 2
    private static let spawnBandAboveScreen: CGFloat = 4
    private static let spawnAttemptsPerTag = 5_000
    private static let spawnBatchRetries = 5
    private static let maxThrowSpeed: CGFloat = 2000
    private static let minimumDragDeltaTime: TimeInterval = 1e-4

    private struct SpawnSpecification {
        var position: CGPoint
        var rotation: CGFloat
    }

    /// Circumradius of the tag rectangle (rotation-invariant).
    private static var enclosingRadius: CGFloat {
        0.5 * hypot(tagWidth, tagHeight)
    }

    // MARK: Placement

    private func physicsWorldTotalHeight() -> CGFloat {
        size.height + Self.physicsTopExtension(for: size)
    }

    /// Places `tagCount` items via rejection sampling on enclosing circles, then assigns θ independently.
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

        for _ in 0..<Self.spawnBatchRetries {
            var centers: [CGPoint] = []
            centers.reserveCapacity(Self.tagCount)
            var success = true

            for _ in 0..<Self.tagCount {
                var placed = false
                for _ in 0..<Self.spawnAttemptsPerTag {
                    let cx = CGFloat.random(in: xMin...xMax)
                    let cy = CGFloat.random(in: yMin...yMax)
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
                if !placed { success = false; break }
            }

            if success {
                return centers.map { center in
                    SpawnSpecification(
                        position: center,
                        rotation: CGFloat.random(in: -Self.maxSpawnZRotation...Self.maxSpawnZRotation)
                    )
                }
            }
        }
        return []
    }

    /// Height of physics space reserved above the visible area.
    /// Rejection sampling needs a packing fraction of 25% or less for reliable success.
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

    // MARK: Lifecycle helpers

    private func spawnTagsIfLayoutReady() {
        guard !hasSpawnedInitially else { return }
        guard size.width > Self.tagWidth, size.height > Self.tagHeight else { return }
        hasSpawnedInitially = true
        spawnTags()
    }

    private func spawnTags() {
        let specs = buildSpawnSpecifications().shuffled()
        let colors = TagColor.allCases.flatMap { [$0, $0] }.shuffled()
        let actions: [SKAction] = colors.enumerated().map { index, color in
            .sequence([
                .wait(forDuration: Self.spawnInterval),
                .run { [weak self] in
                    guard let self, index < specs.count else { return }
                    let s = specs[index]
                    self.addTagNode(color: color, zOrder: index, position: s.position, rotation: s.rotation)
                },
            ])
        }
        spawnRunner.run(.sequence(actions))
    }

    func resetSimulation() {
        spawnRunner.removeAllActions()
        removeAllActions()
        releaseDraggedNode()
        enumerateChildNodes(withName: Self.tagNodeName) { node, _ in
            node.removeFromParent()
        }
        if usesDeviceMotion {
            #if targetEnvironment(simulator)
            physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
            #else
            startMotionUpdates()
            #endif
        } else {
            motionManager.stopDeviceMotionUpdates()
            physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        }
        spawnTags()
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

// MARK: - Tag Node

extension PhysicsTagScene {
    private static let tagHeight: CGFloat = 36
    private static let dotDiameter: CGFloat = 10
    private static let leftPadding: CGFloat = 8
    private static let dotTextGap: CGFloat = 6
    private static let rightPadding: CGFloat = 10
    private static let font = UIFont.systemFont(ofSize: 14, weight: .bold)
    private static var textWidth: CGFloat = {
        let attr = NSAttributedString(string: "example", attributes: [.font: font])
        return ceil(attr.size().width)
    }()
    private static var tagWidth: CGFloat = {
        leftPadding + dotDiameter + dotTextGap + textWidth + rightPadding
    }()

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
            body.linearDamping = 0.1
            body.angularDamping = 0.3
            body.allowsRotation = true
            body.affectedByGravity = true
            return body
        }()
        return node
    }

    private func renderTagImage(color: TagColor) -> UIImage {
        let size = CGSize(width: Self.tagWidth, height: Self.tagHeight)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let cgCtx = ctx.cgContext
            let rect = CGRect(origin: .zero, size: size)

            let capsule = UIBezierPath(roundedRect: rect, cornerRadius: size.height / 2)
            cgCtx.saveGState()
            capsule.addClip()
            color.backgroundColor.setFill()
            UIRectFill(rect)
            cgCtx.restoreGState()

            let dotRect = CGRect(
                x: Self.leftPadding,
                y: (size.height - Self.dotDiameter) / 2,
                width: Self.dotDiameter, height: Self.dotDiameter
            )
            color.foregroundColor.setFill()
            UIBezierPath(ovalIn: dotRect).fill()

            let attr = NSAttributedString(
                string: "example",
                attributes: [.font: Self.font, .foregroundColor: color.foregroundColor]
            )
            let textSize = attr.boundingRect(
                with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin], context: nil
            ).size
            let textOrigin = CGPoint(
                x: Self.leftPadding + Self.dotDiameter + Self.dotTextGap,
                y: (size.height - textSize.height) / 2
            )
            attr.draw(at: textOrigin)
        }
    }
}

// MARK: - Dragging

extension PhysicsTagScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, draggedNode == nil else { return }
        let location = touch.location(in: self)
        let tapped = nodes(at: location).first { $0.name == Self.tagNodeName } as? SKSpriteNode
        guard let node = tapped else { return }
        node.physicsBody?.isDynamic = false
        node.physicsBody?.velocity = .zero
        node.physicsBody?.angularVelocity = 0
        dragOffset = CGPoint(x: location.x - node.position.x, y: location.y - node.position.y)
        lastDragPosition = node.position
        lastDragTimestamp = touch.timestamp
        draggedNode = node
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let node = draggedNode else { return }
        let location = touch.location(in: self)
        let newPos = clampedPosition(
            CGPoint(x: location.x - dragOffset.x, y: location.y - dragOffset.y),
            nodeSize: node.size,
            rotation: node.zRotation
        )
        lastDragPosition = node.position
        lastDragTimestamp = touch.timestamp
        node.position = newPos
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        applyThrowVelocity(from: touches.first)
        releaseDraggedNode()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        releaseDraggedNode()
    }

    private func applyThrowVelocity(from touch: UITouch?) {
        guard let node = draggedNode, let body = node.physicsBody, let touch else { return }
        let dt = touch.timestamp - lastDragTimestamp
        guard dt > Self.minimumDragDeltaTime else { return }
        var v = CGVector(
            dx: (node.position.x - lastDragPosition.x) / dt,
            dy: (node.position.y - lastDragPosition.y) / dt
        )
        let speed = hypot(v.dx, v.dy)
        if speed > Self.maxThrowSpeed {
            let scale = Self.maxThrowSpeed / speed
            v = CGVector(dx: v.dx * scale, dy: v.dy * scale)
        }
        body.velocity = v
    }

    private func releaseDraggedNode() {
        draggedNode?.physicsBody?.isDynamic = true
        draggedNode = nil
        dragOffset = .zero
        lastDragPosition = .zero
        lastDragTimestamp = 0
    }

    /// Clamps the node's center inside the physics world (`edgeLoop`). Accounts for the rotated AABB.
    private func clampedPosition(_ position: CGPoint, nodeSize: CGSize, rotation: CGFloat) -> CGPoint {
        let c = abs(cos(rotation))
        let s = abs(sin(rotation))
        let hw = (nodeSize.width * c + nodeSize.height * s) / 2
        let hh = (nodeSize.width * s + nodeSize.height * c) / 2
        let x = min(max(position.x, hw), size.width - hw)
        let y = min(max(position.y, hh), size.height - hh)
        return CGPoint(x: x, y: y)
    }
}

// MARK: - TagColor

enum TagColor: CaseIterable {
    case red, pink, orange, yellow, green, mint, blue, indigo, purple, brown

    var hue: CGFloat {
        switch self {
        case .red:    return 0.00
        case .pink:   return 0.92
        case .orange: return 0.08
        case .yellow: return 0.13
        case .green:  return 0.33
        case .mint:   return 0.47
        case .blue:   return 0.58
        case .indigo: return 0.70
        case .purple: return 0.78
        case .brown:  return 0.07
        }
    }

    var foregroundColor: UIColor {
        UIColor(hue: hue, saturation: 0.7, brightness: 0.8, alpha: 1.0)
    }

    var backgroundColor: UIColor {
        UIColor(hue: hue, saturation: 0.15, brightness: 1.0, alpha: 0.2)
    }
}

#endif
