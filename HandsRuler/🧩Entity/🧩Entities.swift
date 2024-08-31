import RealityKit
import ARKit

@MainActor
class 🧩Entities {
    let root = Entity()
    let line = 🧩Entity.line()
    let left = 🧩Entity.fingerTip(.left)
    let right = 🧩Entity.fingerTip(.right)
    var surrounding: [UUID: Entity] = [:]
}

extension 🧩Entities {
    func setUpChildren() {
        self.root.addChild(self.line)
        self.root.addChild(self.left)
        self.root.addChild(self.right)
    }
    var resultBoard: Entity? {
        self.root.findEntity(named: "resultBoard")
    }
    var currentLineLength: Float {
        distance(self.left.position, self.right.position)
    }
    func add(_ entity: Entity) {
        self.root.addChild(entity)
    }
    func updateLineAndResultBoard() {
        🧩Entity.updateLine(self.line,
                            self.left.position,
                            self.right.position)
        
        self.resultBoard?.setPosition((self.left.position + self.right.position) / 2,
                                      relativeTo: nil)
    }
    func hideAndShow() {
        Task {
            let entities = [self.line,
                            self.left,
                            self.right,
                            self.resultBoard!]
            entities.forEach { $0.isEnabled = false }
            try await Task.sleep(for: .seconds(2.5))
            entities.forEach { $0.isEnabled = true }
        }
    }
    func setFixedRuler(_ logs: 💾Logs, _ worldAnchor: WorldAnchor) {
        if let log = logs[worldAnchor.id] {
            self.root.addChild(🧩Entity.fixedRuler(log, worldAnchor))
        }
    }
    func updateFixedRuler(_ logs: 💾Logs, _ worldAnchor: WorldAnchor) {
        if let log = logs[worldAnchor.id],
           let fixedRulerEntity = self.root.findEntity(named: "fixedRuler\(worldAnchor.id)") {
            fixedRulerEntity.removeFromParent()
            self.root.addChild(🧩Entity.fixedRuler(log, worldAnchor))
        }
    }
    func removeFixedRuler(_ worldAnchorID: UUID) {
        if let fixedRulerEntity = self.root.findEntity(named: "fixedRuler\(worldAnchorID)") {
            fixedRulerEntity.removeFromParent()
        }
    }
    func raycast() -> CollisionCastHit? {
        var hits = self.root.scene?.raycast(from: self.right.position,
                                            to: self.root.convert(position: [-5, 0, 0],
                                                                  from: self.right))
        hits?.removeAll(where: { $0.entity == self.left })
        return hits?.first
    }
}
