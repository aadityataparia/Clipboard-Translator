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

    var languages = ["Afrikaans": "af",
                     "Albanian": "sq",
                     "Amharic": "am",
                     "Arabic": "ar",
                     "Armenian": "hy",
                     "Azeerbaijani": "az",
                     "Basque": "eu",
                     "Belarusian": "be",
                     "Bengali": "bn",
                     "Bosnian": "bs",
                     "Bulgarian": "bg",
                     "Catalan": "ca",
                     "Cebuano": "ceb",
                     "Chinese (Simplified)": "zh-CN",
                     "Chinese (Traditional)": "zh-TW",
                     "Corsican": "co",
                     "Croatian": "hr",
                     "Czech": "cs",
                     "Danish": "da",
                     "Dutch": "nl",
                     "English": "en",
                     "Esperanto": "eo",
                     "Estonian": "et",
                     "Finnish": "fi",
                     "French": "fr",
                     "Frisian": "fy",
                     "Galician": "gl",
                     "Georgian": "ka",
                     "German": "de",
                     "Greek": "el",
                     "Gujarati": "gu",
                     "Haitian": "Creole",
                     "Hausa": "ha",
                     "Hawaiian": "haw",
                     "Hebrew": "iw",
                     "Hindi": "hi",
                     "Hmong": "hmn",
                     "Hungarian": "hu",
                     "Icelandic": "is",
                     "Igbo": "ig",
                     "Indonesian": "id",
                     "Irish": "ga",
                     "Italian": "it",
                     "Japanese": "ja",
                     "Javanese": "jw",
                     "Kannada": "kn",
                     "Kazakh": "kk",
                     "Khmer": "km",
                     "Korean": "ko",
                     "Kurdish": "ku",
                     "Kyrgyz": "ky",
                     "Lao": "lo",
                     "Latin": "la",
                     "Latvian": "lv",
                     "Lithuanian": "lt",
                     "Luxembourgish": "lb",
                     "Macedonian": "mk",
                     "Malagasy": "mg",
                     "Malay": "ms",
                     "Malayalam": "ml",
                     "Maltese": "mt",
                     "Maori": "mi",
                     "Marathi": "mr",
                     "Mongolian": "mn",
                     "Myanmar(Burmese)": "my",
                     "Nepali": "ne",
                     "Norwegian": "no",
                     "Nyanja(Chichewa)": "ny",
                     "Pashto": "ps",
                     "Persian": "fa",
                     "Polish": "pl",
                     "Portuguese": "pt",
                     "Punjabi": "pa",
                     "Romanian": "ro",
                     "Russian": "ru",
                     "Samoan": "sm",
                     "Scots Gaelic": "gd",
                     "Serbian": "sr",
                     "Sesotho": "st",
                     "Shona": "sn",
                     "Sindhi": "sd",
                     "Sinhala (Sinhalese)": "si",
                     "Slovak": "sk",
                     "Slovenian": "sl",
                     "Somali": "so",
                     "Spanish": "es",
                     "Sundanese": "su",
                     "Swahili": "sw",
                     "Swedish": "sv",
                     "Tagalog(Filipino)": "tl",
                     "Tajik": "tg",
                     "Tamil": "ta",
                     "Telugu": "te",
                     "Thai": "th",
                     "Turkish": "tr",
                     "Ukrainian": "uk",
                     "Urdu": "ur",
                     "Uzbek": "uz",
                     "Vietnamese": "vi",
                     "Welsh": "cy",
                     "Xhosa": "xh",
                     "Yiddish": "yi",
                     "Yoruba": "yo",
                     "Zulu": "zu"]

    var google_api_key = "#{Your-google-translate-api-key}"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        let options = Array(languages.keys)
        fromLanguage.addItems(withTitles: options)
        fromLanguage.selectItem(withTitle: "Japanese")
        toLanguage.addItems(withTitles: options)
        toLanguage.selectItem(withTitle: "English")
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

    @objc func translate() {
        self.convertedText.stringValue = "Translating ..."
        if self.task != nil {
            self.task.cancel()
        }
        let target = self.languages[self.toLanguage.titleOfSelectedItem!]! as String
        self.HTTPdetect {
            language in
            print(language, target)
            let lang = (self.languages as NSDictionary).allKeys(for: language) as! [String]
            if (lang.isEmpty) {
                self.convertedText.stringValue = "Language not detected"
            } else {
                DispatchQueue.main.async {
                    self.fromLanguage.selectItem(withTitle: lang[0])
                    if (language == target){
                        self.convertedText.stringValue = "Source Language is same as target language, Choose a different language to translate to!"
                        return
                    }
                    self.HTTPtranslate(source: language, target: target, string: self.textLabel.stringValue)
                }
            }
        }
    }

    override func controlTextDidChange(_ notification: Notification) {
        fromText(textLabel)
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
        translate()
    }

    @IBAction func toLanguagePop(_ sender: NSPopUpButton) {
        translate()
    }

    @IBAction func fromText(_ sender: NSTextField) {
        translate()
    }
}
extension TranslateViewController {
    func clipboardContent() -> String? {
        return NSPasteboard.general.pasteboardItems?.first?.string(forType: .string)
    }

    func HTTPtranslate(source: String, target: String, string: String) {

        let json: [String: Any] = ["q": string,
                                   "source": source,
                                   "target": target,
                                   "format": "text"]

        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        // create post request
        let url = URL(string: "https://translation.googleapis.com/language/translate/v2?key=\(google_api_key)")!
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

    func HTTPdetect(completionHandler: @escaping (_ language: String) -> ()) {
        let json: [String: Any] = ["q": textLabel.stringValue]

        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        // create post request
        let url = URL(string: "https://translation.googleapis.com/language/translate/v2/detect?key=\(google_api_key)")!
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
            let detections = inside["detections"] as! NSArray
            let insid = detections[0] as! NSArray
            let text = insid[0] as! NSDictionary
            let language = text["language"] as! String
            completionHandler(language)
        }
        task.resume()
    }
}
