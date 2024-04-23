//
//  ViewController.swift
//  CAShapeLayer
//
//  Created by 紹郁 on 2024/4/20.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var signatureView: SignatureView!
    
    @IBOutlet weak var penColor: UIColorWell!
    
    @IBOutlet weak var penSize: UISlider!
    
    @IBOutlet weak var camera: UIImageView!
    
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //將signatureView的多點觸碰功能關閉
        signatureView.isMultipleTouchEnabled = false
        
        //設定只顯示signatureView的範圍，超過的裁切掉
        signatureView.clipsToBounds = true
        
        //設定penColor
        penColor.selectedColor = signatureView.lineColor
        
        //設定penSizeSlider
        penSize.value = Float(signatureView.lineWidth)
        
        //penColor監聽
        penColor.addTarget(self, action: #selector(penColorChanged(_:)), for: .valueChanged)
        
        //penSizeSlider監聽
        penSize.addTarget(self, action: #selector(penSizeChanged(_:)), for: .valueChanged)
        
        setupCamera()
    }
    
    func setupCamera() {
        //建立AVCaptureSession
        captureSession = AVCaptureSession()
        
        //開啟前鏡頭
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Unable to access front camera")
            return
        }
        
        do {
            //建立AVCaptureDeviceInput
            let input = try AVCaptureDeviceInput(device: frontCamera)
            
            //添加输入到AVCaptureSession
            if captureSession?.canAddInput(input) ?? false {
                captureSession?.addInput(input)
            }
            
            // 创建 AVCaptureVideoPreviewLayer 并配置
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            previewLayer?.videoGravity = .resizeAspectFill
            previewLayer?.frame = camera.bounds
            
            if let previewLayer = previewLayer {
                camera.layer.addSublayer(previewLayer)
            }
            
            //啟用AVCaptureSession
            captureSession?.startRunning()
        } catch {
            print("Error setting up camera input: \(error.localizedDescription)")
        }
    }
    
    //清除畫面
    @IBAction func clearBtn(_ sender: UIButton) {
        signatureView.clearView()
    }
    
    //儲存簽名
    @IBAction func saveBtn(_ sender: UIButton) {
        
        var screenshotImage :UIImage?
        //取得目前的視窗
        let layer = signatureView.layer
        //取得畫面比例
        let scale = UIScreen.main.scale
        //繪製成圖片
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        guard let context = UIGraphicsGetCurrentContext() else { return }
        layer.render(in:context)
        screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let image = screenshotImage {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            popAlert()
        }
    }
    
    func popAlert() {
        let controller = UIAlertController(title: "提示", message: "已存入手機相簿", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            self.signatureView.clearView()
        }
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }
    
    @objc func penColorChanged(_ sender: UIColorWell) {
        //更新SignatureView的顏色
        signatureView.lineColor = sender.selectedColor!
    }
    
    @objc func penSizeChanged(_ sender: UISlider) {
        //更新SignatureView的畫筆大小
        signatureView.lineWidth = CGFloat(sender.value)
    }
    
    deinit {
        //停止AVCaptureSession
        captureSession?.stopRunning()
    }
}

