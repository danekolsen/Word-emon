//
//  CameraVC.swift
//  Tesseract
//
//  Created by Developer on 7/13/18.
//  Copyright © 2018 Dane Olsen. All rights reserved.
//

import UIKit
import TesseractOCR

class CameraVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, G8TesseractDelegate {

    
    var image: UIImage?
    
    var foundStringArray:[String] = []
    
    @IBOutlet weak var cameraView: UIImageView!
    
    @IBAction func takePicturePressed(_ sender: UIButton) {
        
        let catchImage = UIImagePickerController()
        catchImage.delegate = self
        catchImage.sourceType = UIImagePickerControllerSourceType.camera
        catchImage.allowsEditing = true
        self.present(catchImage, animated: true)
        {
            
        }
        }
    
    func imagePickerController(_ picker:UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]){
        if let takeImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            cameraView.image = takeImage
            image = takeImage
        }else{
            //Error
        }
        self.dismiss(animated:true,completion:nil)
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if let imageexists = image{
            performOCR(image: imageexists)
        }else{
            return
        }
        print("RECOGNIZED TEXT ARRAY AFTER OCR ATTEMPT: ",foundStringArray)
        
        performSegue(withIdentifier: "segueCameraToWP", sender: sender)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is WordPickerVC
        {
            let vc = segue.destination as? WordPickerVC
            vc?.captureTableData = foundStringArray
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func performOCR(image: UIImage){
        if let tesseract = G8Tesseract(language: "eng"){
            tesseract.delegate = self
            tesseract.image = image.g8_blackAndWhite()
            tesseract.recognize()
            print("RECOGNIZED TEXT: ",tesseract.recognizedText)
            let foundString = tesseract.recognizedText
            if let FSA = foundString?.components(separatedBy: " "){
                foundStringArray = FSA
                 print("RECOGNIZED TEXT ARRAY: ",foundStringArray)
            }
        }
    }
   

}
