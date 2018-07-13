//
//  CameraVC.swift
//  Tesseract
//
//  Created by Developer on 7/13/18.
//  Copyright © 2018 Dane Olsen. All rights reserved.
//

import UIKit
import TesseractOCR

class PhotoLibraryVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, G8TesseractDelegate {
    
    
    var image: UIImage?
    
    var foundStringArray:[String] = []
    
    @IBOutlet weak var photoLibView: UIImageView!
    
    @IBAction func getLibraryPressed(_ sender: UIButton) {
        
        let catchImage = UIImagePickerController()
        catchImage.delegate = self
        catchImage.sourceType = UIImagePickerControllerSourceType.photoLibrary
        catchImage.allowsEditing = true
        self.present(catchImage, animated: true)
        {
            
        }
    }
    
    func imagePickerController(_ picker:UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]){
        if let takeImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            photoLibView.image = takeImage
            image = takeImage
        }else{
            //Error
        }
        self.dismiss(animated:true,completion:nil)
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        performOCR(image: image!)
        print("RECOGNIZED TEXT ARRAY AFTER OCR ATTEMPT: ",foundStringArray)
        performSegue(withIdentifier: "segueToTableOutputVC", sender: sender)
        
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
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func performOCR(image: UIImage){
        if let tesseract = G8Tesseract(language: "eng"){
            tesseract.delegate = self
            tesseract.image = image.g8_blackAndWhite()
            tesseract.recognize()
            print("RECOGNIZED TEXT: ",tesseract.recognizedText)
            let foundString = tesseract.recognizedText
            if let FSA = foundString?.words{
                foundStringArray = FSA
                print("RECOGNIZED TEXT ARRAY: ",foundStringArray)
            }
        }
    }
    
    
}

extension String {
    var words: [String] {
        return components(separatedBy: .punctuationCharacters)
            .joined()
            .components(separatedBy: .whitespaces)
            .filter{!$0.isEmpty}
    }
}
