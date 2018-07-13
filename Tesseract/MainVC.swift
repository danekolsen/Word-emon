//
//  ViewController.swift
//  Tesseract
//
//  Created by Developer on 7/12/18.
//  Copyright © 2018 Dane Olsen. All rights reserved.
//

import UIKit
import TesseractOCR
import CoreData
import AVFoundation

class MainVC: UIViewController, G8TesseractDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let saveContext = (UIApplication.shared.delegate as! AppDelegate).saveContext
    

    @IBOutlet weak var mainTableView: UITableView!
    
    var player: AVAudioPlayer?
    var didAudioPlay = false
    
    var mainTableData: [Word] = []
    
   
    
    var image: UIImage? = UIImage(named: "text")
    
    @IBAction func catchButtonPressed(_ sender: UIButton) {
    
        performSegue(withIdentifier: "segueToCameraView", sender: sender)
        
    }
    
    @IBAction func manualEntryPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "segueToManualEntry", sender: sender)
    }
    
    @IBAction func photoLibraryPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "segueToPhotoLibrary", sender: sender)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchWords()
        mainTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchWords()
        mainTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchWords()
        print("ALL ITEMS ARE: ", mainTableData)
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.reloadData()
        mainTableView.rowHeight = 150
        
//        if didAudioPlay == false{
//            playSound()
//            didAudioPlay = true
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func playSound() {
//        guard let url = Bundle.main.url(forResource: "pokemon_go", withExtension: "mp3") else { return }
//
//        do {
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//            try AVAudioSession.sharedInstance().setActive(true)
//
//
//
//            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
//            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
//
//            /* iOS 10 and earlier require the following line: */
////             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
//
//            guard let player = player else { return }
//
//            player.play()
//
//        } catch let error {
//            print(error.localizedDescription)
//        }
//    }
    

    func fetchWords(){
        let req:NSFetchRequest<Word> = Word.fetchRequest()
        do {
            let fetchedWords = try context.fetch(req)
            mainTableData = fetchedWords
            mainTableView.reloadData()
            // Here we can store the fetched data in an array
        } catch {
            print(error)
        }
    }
    
    //TTS func
    func speakWord(speakText: String) {
        let string = speakText
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
    }

    func translateWord(word: String, sourceLang: String, endLang: String){
        let appId = "57223611"
        let appKey = "efb6a7d183a316f8e5552e779c7358b9"
        let language = sourceLang
        let target_lang = endLang
        let word = word
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
                print(response)
                print(jsonData)
//                place JSON unwrapper for translation here
            } else {
                print(error)
                print(NSString.init(data: data!, encoding: String.Encoding.utf8.rawValue))
            }
        }).resume()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = sender as? IndexPath{
//            print(mainTableView.cellForRow(at: indexPath)?.textLabel!.text)
            let text = mainTableView.cellForRow(at: indexPath)?.textLabel!.text
            print("------>", text!)
            let dest = segue.destination as! TranslateVC
            dest.temptext = text!
            
        }else{
    }
    }
    
    @IBAction func unwindFromTranslate(segue: UIStoryboardSegue){
    
    }
}

extension MainVC: UITableViewDataSource, UITableViewDelegate{
    
    
    
    func tableView(_ mainTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainTableData.count
       
      
    }
    
    func tableView(_ mainTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mainTableView.dequeueReusableCell(withIdentifier: "wordCell", for: indexPath)
        cell.textLabel?.text = mainTableData[indexPath.row].word
        cell.detailTextLabel?.text = mainTableData[indexPath.row].definition
        return cell
    }
    
    //translate
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Translate"){action, view, completionHandler in
            self.performSegue(withIdentifier: "segueToTranslate", sender: indexPath)
            completionHandler(false)
            
        }
        editAction.backgroundColor = UIColor.purple
        let swipeConfig = UISwipeActionsConfiguration(actions: [editAction])
        return swipeConfig
    }
    
    // delete
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete"){action,view,completionHandler in
            //            print(indexPath.row, self.tableData[indexPath.row])
            self.context.delete(self.mainTableData[indexPath.row])
            self.mainTableData.remove(at: indexPath.row)
            self.saveContext()
            tableView.reloadData()
        }
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfig
    }
    
    //tap to speak
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath){
            let word = cell.textLabel?.text
            let definition = cell.detailTextLabel?.text
            speakWord(speakText: "the word is \(word!). And the Definition is, \(definition!)")
        }
    }
    
    
    

    
    
    
}



extension Date {
    func string(with format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

