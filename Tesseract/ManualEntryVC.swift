//
//  ManualEntryVC.swift
//  Tesseract
//
//  Created by Developer on 7/13/18.
//  Copyright © 2018 Dane Olsen. All rights reserved.
//

import UIKit
import AVFoundation

class ManualEntryVC: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var wordTextView: UITextView!
    
    
    @IBOutlet weak var definitionLabel: UILabel!
    
    
    var holdMyWord: String?
    var holdMyDefinition: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func hideKeyboard(){
        wordTextView.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func checkWordPressed(_ sender: UIButton) {
        hideKeyboard()
        if let word_pre = wordTextView.text{
            holdMyWord = word_pre
            let word = word_pre.trimmingCharacters(in: .whitespaces)
            getDefinition(word: word)
        }else{
            return
        }
    }
    

    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        hideKeyboard()
        let newWord = Word(context: context)
        newWord.word = holdMyWord
        newWord.definition = holdMyDefinition
        newWord.dateCaptured = Date()
        appDelegate.saveContext()
        performSegue(withIdentifier: "segueBackToMainVC", sender: sender)
    }
    
    //TTS func
    func speakWord(speakText: String) {
        let string = speakText
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
    }

    
    func getDefinition(word:String){
        
        let appId = "57223611"
        let appKey = "efb6a7d183a316f8e5552e779c7358b9"
        let language = "en"
        let word = word
        let word_id = word.lowercased() //word id is case sensitive and lowercase is required
        let url = URL(string: "https://od-api.oxforddictionaries.com:443/api/v1/entries/\(language)/\(word_id)")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(appId, forHTTPHeaderField: "app_id")
        request.addValue(appKey, forHTTPHeaderField: "app_key")
        
        let session = URLSession.shared
        _ = session.dataTask(with: request, completionHandler: { data, response, error in
            if let response = response,
                let data = data,
                let jsonData = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
                let jsonData = jsonData as! NSDictionary
                
                if let resultsArray = jsonData["results"] as? [Any] {

                    if let firstResultsArray = resultsArray[0] as? NSDictionary{
                        if let lexicalEntries = firstResultsArray["lexicalEntries"] as? [Any] {
                            if let lexicalArrays = lexicalEntries as? [Any] {
                                if let lexicalArray = lexicalArrays[0] as? NSDictionary {
                                    if let entries = lexicalArray["entries"] as? [Any] {
                                        if let entry = entries[0] as? NSDictionary {
                                            if let senses = entry["senses"] as? [Any] {
                                                if let sense = senses[0] as? NSDictionary {
                                                    if let definitions = sense["definitions"] as? [Any] {
                                                        if let definition = definitions[0] as? String {
                                                            
                                                            self.holdMyDefinition = definition
                                                            print(definition)
                                                            DispatchQueue.main.async {
                                                                self.definitionLabel.text = definition
                                                            }
                                                            self.speakWord(speakText: "the definition is," + definition)
                                                            
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
                DispatchQueue.main.async {
                    self.definitionLabel.text = "No definition found"
                }
                self.speakWord(speakText: "No definition found,")
                
//                print(error)
//                print(NSString.init(data: data!, encoding: String.Encoding.utf8.rawValue))
            }
        }).resume()
        definitionLabel.text = holdMyDefinition
    }
}
