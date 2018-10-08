//
//  ViewController.swift
//  SeeFood
//
//  Created by Hugo Bernal on Sep/30/18.
//  Copyright © 2018 Hugo Bernal. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML model failed.")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Request failed.")
            }
            
            print(results)
            
            if let firstResult = results.first,
                firstResult.identifier.contains("hotdog") {
                self.navigationItem.title = "Hotdog!"
            } else {
                self.navigationItem.title = "Not Hotdog!"
            }
            
//            if let firstResult = results.first {
//                self.navigationItem.titleView?.sizeToFit()
//                self.navigationItem.title = "\(firstResult.identifier) with \(firstResult.confidence * 100)% Acc"
//            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
         try handler.perform([request])
        } catch {
            print(error)
        }
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CIImage")
            }
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
