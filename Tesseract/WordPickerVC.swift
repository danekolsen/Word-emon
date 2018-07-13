//
//  WordPickerVC.swift
//  Tesseract
//
//  Created by Developer on 7/13/18.
//  Copyright © 2018 Dane Olsen. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class WordPickerVC: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var holdMyWord: String?
    var holdMyDefinition: String?
    
    @IBOutlet weak var tableView: UITableView!
    
    var captureTableData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("THE FOUND STRING ARRAY IN THE WORDPICKERVC IS: ", captureTableData)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
                                                            self.saveDef(definition: definition)
                                                            print("THE DEFINITION IS IN THE CALLBACK",definition)

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
                self.speakWord(speakText: "No definition found,")
                //                print(error)
                //                print(NSString.init(data: data!, encoding: String.Encoding.utf8.rawValue))
            }
        }).resume()
        
    }
    
    
    func saveDef(definition:String){
        print("IN THE SAVE FUNCTION def=>", definition)
        let newWord = Word(context: context)
        newWord.word = holdMyWord
        newWord.definition = holdMyDefinition
        newWord.dateCaptured = Date()
        appDelegate.saveContext()
    }
    
    
    
//
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath){
            let word = cell.textLabel?.text
            print("Word in word ticker table view select at is:", word)
            holdMyWord = word
            getDefinition(word: word!)
//            print("word:",word, "definition:", holdMyDefinition)
//            let newWord = Word(context: context)
//            newWord.word = word
//            if let def = holdMyDefinition {
//                newWord.definition = def
//            }
//            newWord.dateCaptured = Date()
//            appDelegate.saveContext()
            performSegue(withIdentifier: "segueBackToMainVC", sender: cell)
        }
    }
}

extension WordPickerVC: UITableViewDataSource, UITableViewDelegate{
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return captureTableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allWordsCell", for: indexPath)
        cell.textLabel?.text = captureTableData[indexPath.row]
       
        return cell
    }
    
    
}
