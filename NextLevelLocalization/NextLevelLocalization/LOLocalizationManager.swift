
import Foundation

struct DictionaryLanguage: Codable {
    let code: String
    var fullName: String
}

public final class LOLocalizationManager  {
    
    public typealias LanguageKey = String
    public typealias Language = Dictionary<String, String>
    public typealias Translations = Dictionary<LanguageKey, Language>
    
    let tableName: String = "Localizable"
    let translations = Translations()
    

    let LOBundleName = "LOLocalizable.bundle"

    var currentBundle = Bundle.main
    var languagesArray: [DictionaryLanguage] = [DictionaryLanguage(code: "en", fullName: "English"),DictionaryLanguage(code: "ta", fullName: "Tamil"),DictionaryLanguage(code: "hi",fullName: "Hindi")]
    let manager = FileManager.default
    lazy var bundlePath: URL = {
        let documents = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)
        let bundlePath = documents.appendingPathComponent(LOBundleName, isDirectory: true)
        return bundlePath
    }()

    func setCurrentBundle(forLanguage:String){
        if let bundle = returnCurrentBundleForLanguage(lang: forLanguage) {
            currentBundle = bundle
        } else {
            if let bundle = Bundle(path: getPathForLocalLanguage(language: "en")) {
                currentBundle = bundle
            }
        }
    }
 
    public func getLanguagesFromServer(url: URL)  {
        let task = URLSession.shared.dataTask(with: url as URL) { data, response, error in
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: []) as?  [String : Any]
                if let languagesArray = jsonResponse!["languages"] as? [[String : Any]] {
                    for lang in languagesArray {
                        let translations = lang["translations"] as! Dictionary<String,String>
                        let langName = lang["code"] as! String
                        let dict : Dictionary<String, Dictionary<String, String>> = [langName: translations]
                        self.writeToBundle(translations: dict, bundlePath: self.bundlePath)
                    }
                }
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        
        task.resume()

    }
    
    private func writeToBundle(translations: Translations, bundlePath: URL) {
        
        if manager.fileExists(atPath: bundlePath.path) == false {
            do {
            try manager.createDirectory(at: bundlePath, withIntermediateDirectories: true, attributes: [FileAttributeKey.protectionKey : FileProtectionType.complete])
            } catch {
                print("error creating directory")
            }
        }
        
        for language in translations {
            let lang = language.key
            let langPath = bundlePath.appendingPathComponent("\(lang).lproj", isDirectory: true)
            if manager.fileExists(atPath: langPath.path) == false {
                do {
                try manager.createDirectory(at: langPath, withIntermediateDirectories: true, attributes: [FileAttributeKey.protectionKey : FileProtectionType.complete])
                } catch {
                    print("error creating directory")
                }
            }
            
            let sentences = language.value
            let res = sentences.reduce("", { $0 + "\"\($1.key)\" = \"\($1.value)\";\n" })
            
            let filePath = langPath.appendingPathComponent("\(tableName).strings")
            let data = res.data(using: .utf32)
            manager.createFile(atPath: filePath.path, contents: data, attributes: [FileAttributeKey.protectionKey : FileProtectionType.complete])
        }
    }

    public func returnCurrentBundleForLanguage(lang:String) -> Bundle? {
        if manager.fileExists(atPath: bundlePath.path) == false {
            return Bundle(path: getPathForLocalLanguage(language: lang))
        }
        let resourceKeys : [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
        let enumerator = manager.enumerator(at: bundlePath ,
                                                        includingPropertiesForKeys: resourceKeys,
                                                        options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                                                            return true
        })!
        for case let folderURL as URL in enumerator {
            if folderURL.lastPathComponent == ("\(lang).lproj"){
                let enumerator2 = manager.enumerator(at: folderURL,
                                                                 includingPropertiesForKeys: resourceKeys,
                                                                 options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                                                                    return true
                })!
                for case let fileURL as URL in enumerator2 {
                    if fileURL.lastPathComponent == "Localizable.strings" {
                        return Bundle(url: folderURL)
                    }
                }
            }
        }
        return Bundle(path: getPathForLocalLanguage(language: lang))
    }
    
    func getLocalLanguageVersions() -> [DictionaryLanguage] {
        return [DictionaryLanguage(code: "en", fullName: "English"),DictionaryLanguage(code: "ta", fullName: "Tamil"),DictionaryLanguage(code: "hi",fullName: "Hindi")]
    }
    private func getPathForLocalLanguage(language: String) -> String {
        return Bundle.main.path(forResource: language, ofType: "lproj")!
    }
}

