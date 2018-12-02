//
//  ViewController.swift
//  arkit-test
//
//  Created by 梅田佳孝 on 2018/12/02.
//  Copyright © 2018 y-umeda. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let mySession = ARSession()
//        sceneView.session = mySession
        
        // viewに表示するための設定、SceneKitで3Dオブジェクトを配置するときに必要
        let scene = SCNScene()
        sceneView.scene = scene
        
        // デバッグ情報の表示
        sceneView.showsStatistics = true
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
    }
    
    // このControllerに遷移したときに実行
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // デバイスの向きや位置などを検出するためのオブジェクト
        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        sceneView.session.pause()
    }
    
    

    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        // 現在のARFrameオブジェクトを受け取る
        guard let currentFrame = sceneView.session.currentFrame else { return  }
        
        let viewWidth  = sceneView.bounds.width
        let viewHeight = sceneView.bounds.height
        // 6000は何の数字？仮想空間の解像度のようなもの？
        let imagePlane = SCNPlane(width: viewWidth/6000, height: viewHeight/6000)
        // マテリアルを１つしか使わない場合firstMaterialを使う。複数の場合var materials: [SCNMaterial]
        // contentsにビジュアルに関する情報をセット、
        //sceneView.snapshot()はUIImage{1125, 2436}のスナップショットを生成する
        imagePlane.firstMaterial?.diffuse.contents = sceneView.snapshot()
        // lightingModelはレンダリングが軽い処理に利用する　.constantはレンダリングが一様なとき
        imagePlane.firstMaterial?.lightingModel = .constant
        
        //ノードの生成
        let planeNode = SCNNode(geometry: imagePlane)
        sceneView.scene.rootNode.addChildNode(planeNode)
        
        var translation = matrix_identity_float4x4
        // xyzw
        translation.columns.3.z = -0.1
        
        // オブジェクトの向きがおかしいので補正。原因は今のところ不明。取り込んだ情報がおかしいのか、設定の仕方がおかしいのか。
        // 本当はcurrentFrame.camera.transformを直接いじったほうが良い？
        translation.columns.0.x = 0
        translation.columns.0.y = 1
        translation.columns.1.x = -1
        translation.columns.1.y = 0
        // これ消すと最初にデバイスの傾きが反映されていないオブジェクトを生成したあと、タップするごとに画像を書き換える。これはオブジェクトが１しか生成されないのではなく、オブジェクトの位置情報が更新されないため
        planeNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        
    }
}

