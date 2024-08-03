//
//  ContentView.swift
//  Catan in AR
//
//  Created by Parth Antala on 8/3/24.
//
import SwiftUI
import SceneKit
import ARKit

struct ARView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView()
        sceneView.delegate = context.coordinator
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        return sceneView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        let configuration = ARImageTrackingConfiguration()
        
        if let imageToTrack = ARReferenceImage.referenceImages(inGroupNamed: "Catan Cards", bundle: Bundle.main) {
            configuration.trackingImages = imageToTrack
            configuration.maximumNumberOfTrackedImages = 6
            print("Images Successfully Added")
        }
        
        uiView.session.run(configuration)
    }
    
    static func dismantleUIView(_ uiView: ARSCNView, coordinator: Coordinator) {
        uiView.session.pause()
    }

    class Coordinator: NSObject, ARSCNViewDelegate {
        var parent: ARView

        init(_ parent: ARView) {
            self.parent = parent
        }

        func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
            let node = SCNNode()

            if let imageAnchor = anchor as? ARImageAnchor {
                let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width,
                                     height: imageAnchor.referenceImage.physicalSize.height)
                plane.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0)

                let planeNode = SCNNode(geometry: plane)
                planeNode.eulerAngles.x = -.pi / 2
                node.addChildNode(planeNode)

                if let imageName = imageAnchor.referenceImage.name {
                    let sceneName: String?
                    switch imageName {
                    case "hay-card":
                        sceneName = "art.scnassets/hay.scn"
                    case "stone-card":
                        sceneName = "art.scnassets/stone.scn"
                    case "goat-card":
                        sceneName = "art.scnassets/goat.scn"
                    case "wood-card":
                        sceneName = "art.scnassets/wood.scn"
                    case "brick-card":
                        sceneName = "art.scnassets/bricks.scn"
                    default:
                        sceneName = nil
                    }

                    if let sceneName = sceneName, let pokeScene = SCNScene(named: sceneName) {
                        if let pokeNode = pokeScene.rootNode.childNodes.first {
                            if imageName == "stone-card" {
                                pokeNode.scale = SCNVector3(0.0006, 0.0006, 0.0006)
                            }
                            if imageName == "hay-card" || imageName == "goat-card" || imageName == "wood-card" || imageName == "brick-card" {
                                pokeNode.eulerAngles.x = .pi / 2
                                pokeNode.eulerAngles.z = .pi / 2
                            }
                            planeNode.addChildNode(pokeNode)
                        }
                    }
                }
            }
            return node
        }
    }
}

struct ContentView: View {
    var body: some View {
        ARView()
            .edgesIgnoringSafeArea(.all)
    }
}


#Preview {
    ContentView()
}
