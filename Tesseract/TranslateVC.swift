//
//  TranslateVC.swift
//  Tesseract
//
//  Created by Developer on 7/13/18.
//  Copyright © 2018 Dane Olsen. All rights reserved.
//

import UIKit
import AVFoundation

class TranslateVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var heldWordLabel: UILabel!
    
    var temptext = ""
    
    var userLanguage:String?
    
    var pickerData: [String] = ["de", "nso", "ro", "ms", "zu", "id", "tn", "es", "pt"]
    
    @IBOutlet weak var translatedWordLabel: UILabel!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        userLanguage = pickerData[row]
    }
    
    @IBAction func getTranslationPressed(_ sender: UIButton) {
        getTranslation(word: temptext, target: userLanguage!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        heldWordLabel.text = temptext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TEMPTTEXT ====> ", temptext)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //TTS func
    func speakWordDE(speakText: String) {
        let string = speakText
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: "de-GE")
        
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
    }
    
    func speakWordES(speakText: String) {
        let string = speakText
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: "es-ES")
        
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
    }
    
    // ============ API translation ============
    func getTranslation(word: String, target: String) {
        
        let appId = "57223611"
        let appKey = "efb6a7d183a316f8e5552e779c7358b9"
        let language = "en"
        var target_lang = target
        var word = word
        let word_id = word.lowercased() //word id is case sensitive and lowercase is required
        let url = URL(string: "https://od-api.oxforddictionaries.com:443/api/v1/entries/\(language)/\(word_id)/translations=\(target_lang)")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(appId, forHTTPHeaderField: "app_id")
        request.addValue(appKey, forHTTPHeaderField: "app_key")
        
        let session = URLSession.shared
        _ = session.dataTask(with: request, completionHandler: { data, response, error in
            if let response = response,
                let data = data,
                let jsonData = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
                //        print(response)
                //        print(jsonData)
                print("getting data...")
                print("*********************")
                
                let jsonData = jsonData as! NSDictionary
                
                if let resultsArray = jsonData["results"] as? [Any] {
                    //                                        print(resultsArray)
                                                        print(resultsArray[0])
                    if let firstResultsArray = resultsArray[0] as? NSDictionary{
                        //                        print(firstResultsArray)
                        if let lexicalEntries = firstResultsArray["lexicalEntries"] as? [Any] {
                            //                            print(lexicalEntries)
                            if let lexicalArrays = lexicalEntries as? [Any] {
                                //                                print(lexicalArrays)
                                if let lexicalArray = lexicalArrays[0] as? NSDictionary {
                                    //                                    print(lexicalArray)
                                    if let entries = lexicalArray["entries"] as? [Any] {
                                        //                                        print(entries)
                                        if let entry = entries[0] as? NSDictionary {
                                            //                                            print(entry)
                                            if let senses = entry["senses"] as? [Any] {
                                                //                                                print(senses)
                                                if let sense = senses[0] as? NSDictionary {
                                                    //                                                                                                    print(sense)
                                                    //                                                print("-------end------")
                                                    if let trans = sense["translations"] as? [Any] {
//                                                                                                            print(trans)
                                                        if let arr = trans[0] as? NSDictionary {
                                                            //                                                        print(arr)
                                                            //                                                        print("---")
                                                            if let translatedText = arr["text"] as? String {
                                                            
                                                                DispatchQueue.main.async {
                                                                    self.translatedWordLabel.text = translatedText
                                                                }
                                                                print(translatedText)
                                                       
                                                                
                                                                if self.userLanguage == "de" {
                                                                    self.speakWordDE(speakText: "das Wort auf Deutsch ist ," + translatedText)
                                                                }else if self.userLanguage == "es"{
                                                                    self.speakWordES(speakText: "Esta palabra en espanol significa ," + translatedText)
                                                                }
                                                                
                                                                
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                print(error)
                print(NSString.init(data: data!, encoding: String.Encoding.utf8.rawValue))
                print("====== ERROR ======")
                print("sorry, Oxford API doesn't have a translation for that word")
            }
        }).resume()
    }

}
