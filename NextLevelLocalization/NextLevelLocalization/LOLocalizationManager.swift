
import Foundation

struct DictionaryLanguage: Codable {
    let code: String
    var fullName: String
}

public final class LOLocalizationManager : NSObject {
 
    static let shared = LOLocalizationManager()

    var currentBundle = Bundle.main
    
    let manager = FileManager.default
    lazy var bundlePath: URL = {
        let documents = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)
        let bundlePath = documents.appendingPathComponent(LOLocalizable.LOBundleName, isDirectory: true)
        return bundlePath
    }()

    func setCurrentBundle(forLanguage:String){
        do {
            currentBundle = try returnCurrentBundleForLanguage(lang: forLanguage)
        }catch {
            currentBundle = Bundle(path: getPathForLocalLanguage(language: "en"))!
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
                        let translations = lang["translations"] as? Dictionary<String,String>
                        let langName = lang["code"] as? String
                        let dict : Dictionary<String, Dictionary<String, String>> = [langName!: translations!]
                        let rt = LOLocalizable(translations:dict)
                        do {
                            _ = try rt.writeToBundle()
                        }catch {
                            print("error")
                        }
                    }
                }
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        
        task.resume()

    }

    public func returnCurrentBundleForLanguage(lang:String) throws -> Bundle {
        if manager.fileExists(atPath: bundlePath.path) == false {
            return Bundle(path: getPathForLocalLanguage(language: lang))!
        }
        do {
            let resourceKeys : [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
            _ = try manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let enumerator = FileManager.default.enumerator(at: bundlePath ,
                                                            includingPropertiesForKeys: resourceKeys,
                                                            options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                                                                return true
            })!
            for case let folderURL as URL in enumerator {
                _ = try folderURL.resourceValues(forKeys: Set(resourceKeys))
                if folderURL.lastPathComponent == ("\(lang).lproj"){
                    let enumerator2 = FileManager.default.enumerator(at: folderURL,
                                                                     includingPropertiesForKeys: resourceKeys,
                                                                     options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                                                                        return true
                    })!
                    for case let fileURL as URL in enumerator2 {
                        _ = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                        if fileURL.lastPathComponent == "Localizable.strings" {
                            return Bundle(url: folderURL)!
                        }
                    }
                }
            }
        } catch {
            return Bundle(path: getPathForLocalLanguage(language: lang))!
        }
        return Bundle(path: getPathForLocalLanguage(language: lang))!
    }
    
    func getLocalLanguageVersions() -> [DictionaryLanguage] {
        return [DictionaryLanguage(code: "en", fullName: "English"),DictionaryLanguage(code: "ta", fullName: "Tamil"),DictionaryLanguage(code: "hi",fullName: "Hindi")]
    }
    private func getPathForLocalLanguage(language: String) -> String {
        return Bundle.main.path(forResource: language, ofType: "lproj")!
    }
}

