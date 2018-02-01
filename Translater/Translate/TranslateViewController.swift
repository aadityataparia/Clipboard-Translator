//
//  TranslateViewController.swift
//  Translater
//
//  Created by aaditya-taparia on 2017/10/27.
//  Copyright © 2017 aaditya-taparia. All rights reserved.
//

import Cocoa

class TranslateViewController: NSViewController, NSTextFieldDelegate {
    var task: URLSessionDataTask!
    var convertedString = "Enter text"

    @IBOutlet var textLabel: NSTextField!
    @IBOutlet var convertedText: NSTextField!
    @IBOutlet var fromLanguage: NSPopUpButton!
    @IBOutlet var toLanguage: NSPopUpButton!

    let delegate = NSApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        textLabel.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.translateClipboard), name: NSNotification.Name(rawValue: "translateClipboard"), object: nil)
        if textLabel.acceptsFirstResponder {
            textLabel.window?.makeFirstResponder(textLabel)
        }
    }

    @objc func translateClipboard(notification: NSNotification) {
        self.textLabel.stringValue = clipboardContent()!
        translate()
    }

    override func controlTextDidChange(_ notification: Notification) {
        translate()
    }

}
extension TranslateViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> TranslateViewController {
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "TranslateViewController")
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? TranslateViewController else {
            fatalError("Why cant i find TranslateViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}
extension TranslateViewController {
    @IBAction func fromLanguagePop(_ sender: NSPopUpButton) {
        print(fromLanguage.titleOfSelectedItem!)
    }

    @IBAction func toLanguagePop(_ sender: NSPopUpButton) {
        print(toLanguage.titleOfSelectedItem!)
    }

    @IBAction func fromText(_ sender: NSTextField) {
        print(textLabel.stringValue)
        translate()
    }
}
extension TranslateViewController {
    func translate(){
        self.convertedText.stringValue = "Translating ..."
        if task != nil {
            task.cancel()
        }
        let json: [String: Any] = ["q": textLabel.stringValue,
                                   "source": "ja",
                                   "target": "en",
                                   "format": "text"]

        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        // create post request
        let url = URL(string: "https://translation.googleapis.com/language/translate/v2?key=#{Your-google-translate-api-key}")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // insert json data to the request
        request.httpBody = jsonData

        task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)

            let responseArray = responseJSON as! [String: Any]
            let inside = responseArray["data"] as! [String: Any]
            let translations = inside["translations"] as! NSArray
            let text = translations[0] as! [String: String]
            self.convertedString = text["translatedText"]!
            DispatchQueue.main.async { // Correct
                self.convertedText.stringValue = self.convertedString
            }
        }
        task.resume()
    }

    func clipboardContent() -> String? {
        return NSPasteboard.general.pasteboardItems?.first?.string(forType: .string)
    }
}