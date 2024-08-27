import RealityKit
import ARKit

enum 🧩Entity {
    static func line() -> Entity {
        let value = Entity()
        value.components.set(OpacityComponent(opacity: 0.75))
        
        ["1", "2"].forEach {
            let partEntity = Entity()
            partEntity.name = $0
            partEntity.orientation = .init(angle: .pi / 2, axis: [1, 0, 0])
            value.addChild(partEntity)
        }
        
        return value
    }
    static func updateLine(_ entity: Entity,
                           _ leftPosition: SIMD3<Float>,
                           _ rightPosition: SIMD3<Float>) {
        let centerPosition = (leftPosition + rightPosition) / 2
        entity.position = centerPosition
        let lineLength = distance(leftPosition, rightPosition)
        
        //let lineModel = ModelComponent(mesh: .generateBox(width: 0.01,
        //                                                  height: 0.01,
        //                                                  depth: (lineLength / 3),
        //                                                  cornerRadius: 0.005),
        //                               materials: [SimpleMaterial(color: .white,
        //                                                          isMetallic: false)])//これだとOKだが端が丸い
        //
        //let lineModel = ModelComponent(mesh: .generateCylinder(height: (lineLength / 3),
        //                                                        radius: 0.005),
        //                                materials: [SimpleMaterial(color: .white,
        //                                                           isMetallic: false)])//これだとダメ
        
        let lineModel = ModelComponent(mesh: Self.meterLine,
                                       materials: [SimpleMaterial(color: .white,
                                                                  isMetallic: false)])//Workaround
        
        ["1", "2"].forEach {
            let partEntity = entity.findEntity(named: $0)!
            partEntity.position.z = (lineLength / 3) * ($0 == "1" ? 1 : -1)
            partEntity.scale.y = (lineLength / 3)//Workaround
            partEntity.components.set(lineModel)
        }
        
        entity.look(at: leftPosition, from: centerPosition, relativeTo: nil)
    }
    static let meterLine = MeshResource.generateCylinder(height: 1, radius: 0.005)//Workaround
    static func fingerTip(_ chirality: HandAnchor.Chirality) -> Entity {
        let value = Entity()
        switch chirality {
            case .left:
                value.name = "left"
                value.position = Self.Placeholder.leftPosition
            case .right:
                value.name = "right"
                value.position = Self.Placeholder.rightPosition
        }
        value.components.set([InputTargetComponent(allowedInputTypes: .indirect),
                              CollisionComponent(shapes: [.generateSphere(radius: 0.04)]),
                              HoverEffectComponent(),
                              🧩Model.fingerTip()])
        return value
    }
    static func fixedLine(_ log: 💾Log) -> Entity {
        let lineEntity = Self.line()
        Self.updateLine(lineEntity, log.leftPosition, log.rightPosition)
        return lineEntity
    }
    static func fixedPointer(_ position: SIMD3<Float>) -> Entity {
        let value = Entity()
        value.position = position
        value.components.set(🧩Model.fixedPointer())
        return value
    }
    static func fixedRuler(_ log: 💾Log, _ worldAnchor: WorldAnchor) -> Entity {
        let value = Entity()
        value.name = "fixedRuler\(log.worldAnchorID)"
        value.setTransformMatrix(worldAnchor.originFromAnchorTransform, relativeTo: nil)
        let lineEntity = 🧩Entity.line()
        🧩Entity.updateLine(lineEntity, log.leftPosition, log.rightPosition)
        value.addChild(lineEntity)
        value.addChild(🧩Entity.fixedPointer(log.leftPosition))
        value.addChild(🧩Entity.fixedPointer(log.rightPosition))
        return value
    }
    enum Placeholder {
        static let leftPosition: SIMD3<Float> = .init(x: -0.2, y: 1.5, z: -0.7)
        static let rightPosition: SIMD3<Float> = .init(x: 0.2, y: 1.5, z: -0.7)
        static var lineLength: Float { distance(Self.leftPosition, Self.rightPosition) }
    }
}
