import RealityKit
import ARKit
import SwiftUI

struct 👐HandTrackingComponent: Component, Codable {
    init() {}
}

struct 👐HandTrackingSystem: System {
    private let session = ARKitSession()
    private let provider = HandTrackingProvider()
    
    init(scene: RealityKit.Scene) {
        self.setUpSession()
    }
    
    private func setUpSession() {
        Task {
            do {
#if targetEnvironment(simulator)
                print("Not support handTracking in simulator.")
#else
                try await self.session.run([self.provider])
#endif
            } catch {
                assertionFailure()
            }
        }
    }
    
    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: .init(where: .has(👐HandTrackingComponent.self)),
                                       updatingSystemWhen: .rendering) {
            guard let leftAnchor = self.provider.latestAnchors.leftHand,
                  let rightAnchor = self.provider.latestAnchors.rightHand,
                  leftAnchor.isTracked,
                  rightAnchor.isTracked,
                  let leftJoint = leftAnchor.handSkeleton?.joint(.indexFingerTip),
                  let rightJoint = rightAnchor.handSkeleton?.joint(.indexFingerTip),
                  leftJoint.isTracked,
                  rightJoint.isTracked else {
                return
            }
            let leftTransform = Transform(matrix: leftAnchor.originFromAnchorTransform * leftJoint.anchorFromJointTransform)
            let rightTransform = Transform(matrix: rightAnchor.originFromAnchorTransform * rightJoint.anchorFromJointTransform)
            let leftPosition = leftTransform.translation
            let rightPosition = rightTransform.translation
            switch entity.name {
                case 🧩Name.fingerLeft:
                    entity.setTransformMatrix(
                        leftAnchor.originFromAnchorTransform * leftJoint.anchorFromJointTransform,
                        relativeTo: nil
                    )
                case 🧩Name.fingerRight:
                    entity.setTransformMatrix(
                        rightAnchor.originFromAnchorTransform * rightJoint.anchorFromJointTransform,
                        relativeTo: nil
                    )
                case 🧩Name.line:
                    entity.components.set(🧩Model.line(leftPosition, rightPosition))
                    entity.look(at: leftPosition,
                                         from: entity.position,
                                         relativeTo: nil)
                case 🧩Name.resultLabel:
                    entity.position = (leftPosition + rightPosition) / 2
                default:
                    assertionFailure()
            }
        }
    }
}

