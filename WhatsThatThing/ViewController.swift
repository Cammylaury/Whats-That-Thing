//
//  ViewController.swift
//  WhatsThatThing
//
//  Created by Cameron Laury on 2/28/18.
//  Copyright © 2018 Cameron Laury. All rights reserved.
//

import UIKit
import Foundation
import CoreML
import Vision
import Lumina

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LuminaDelegate {
    
    let camera = LuminaViewController()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var objectLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        camera.delegate = self
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CIImage")
            }
            
            detect(image: ciimage)
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading coreML model failed!")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image!")
            }
            
//            if let firstResult = results.first {
//                if firstResult.identifier.contains("hotdog") {
//                    self.objectLabel.text = "Hotdog!"
//                } else {
//                    self.objectLabel.text = "Not Hotdog!"
//                }
//            }
            
            
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        cameraSetup()

        
    }
    
    func cameraSetup() {
        present(camera, animated: true, completion:nil)
        
        // Setting up camera default settings
        
        camera.position = .back
        camera.streamFrames = true
        camera.textPrompt = ""
        camera.resolution = .highest
        camera.frameRate = 60
        camera.maxZoomScale = 5.0
        camera.streamingModelTypes = [Inceptionv3()]
        
        
    }
    
    func dismissed(controller: LuminaViewController) {
        objectLabel.text = ""
        camera.dismiss(animated: true, completion:nil)
    }
    
    func captured(stillImage: UIImage, livePhotoAt: URL?, depthData: Any?, from controller: LuminaViewController) {
        controller.dismiss(animated: true) {
            // still images always come back through this function, but live photos and depth data are returned here as well for a given still image
            let returnedImage = stillImage
            self.imageView.image = returnedImage
        }
    }
        
        func streamed(videoFrame: UIImage, with predictions: [LuminaRecognitionResult]?, from controller: LuminaViewController) {
            if #available(iOS 11.0, *) {
                guard let predicted = predictions else {
                    return
                }
                var resultString = String()
                for prediction in predicted {
                    guard let values = prediction.predictions else {
                        continue
                    }
                    guard let bestPrediction = values.first else {
                        continue
                    }
                    resultString.append("\(String(describing: prediction.type)): \(bestPrediction.name)" + "\r\n")
                }
                controller.textPrompt = resultString
                objectLabel.text = resultString
            } else {
                print("CoreML not available in iOS 10.0")
            }
            
            
        }
    
}


