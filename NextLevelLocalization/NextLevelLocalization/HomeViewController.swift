
import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var lblOne: UILabel!
    @IBOutlet weak var lblTwo: UILabel!
    @IBOutlet weak var lblThree: UILabel!
    @IBOutlet weak var lblFour: UILabel!
    @IBOutlet weak var lblFive: UILabel!
    @IBOutlet weak var lblSix: UILabel!
    @IBOutlet weak var lblSeven: UILabel!
    @IBOutlet weak var lblEight: UILabel!
    @IBOutlet weak var lblNine: UILabel!
    @IBOutlet weak var lblTen: UILabel!
    @IBOutlet weak var langSwitch: UISwitch!
    
    var picker = LanguagePickerView()
    var bottomConstraintHidden: NSLayoutConstraint = NSLayoutConstraint()
    var bottomConstraintVisible: NSLayoutConstraint = NSLayoutConstraint()
    var bottomConstraintHiddenToolBar: NSLayoutConstraint = NSLayoutConstraint()
    var isHidden = true
    var viewController: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        langSwitch.setOn(false, animated: false)
        langSwitch.addTarget(self, action: #selector(doToggle(langSwitch:)), for: .valueChanged)
        LOLocalizationManager.shared.setCurrentBundle(forLanguage: UserDefaults.selectedLanguage)
        enableLanguageSelection(isNavigationBarButton: true, forViewController: self)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(LOConstants.Notifications.LanguageChangeNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateView), name: Notification.Name(LOConstants.Notifications.LanguageChangeNotification), object: nil)
        updateView()
    }
    @objc func doToggle(langSwitch: UISwitch) {
        if langSwitch.isOn && !langSwitch.isSelected {
            langSwitch.isSelected = true
            LOLocalizationManager.shared.getLanguagesFromServer(url: URL(string: "https://api.jsonbin.io/b/5f12a6c1918061662843e6bc")!)
        } else {
            langSwitch.isSelected = false
        }
    }
    @objc func updateView() {
        lblOne.text = NSLocalizedString(LOConstants.Labels.key1, tableName: "", bundle: LOLocalizationManager.shared.currentBundle, value: "", comment: "")
        lblTwo.text = NSLocalizedString(LOConstants.Labels.key2, tableName: "", bundle: LOLocalizationManager.shared.currentBundle, value: "", comment: "")
        lblThree.text = NSLocalizedString(LOConstants.Labels.key3, tableName: "", bundle: LOLocalizationManager.shared.currentBundle, value: "", comment: "")
        lblFour.text = NSLocalizedString(LOConstants.Labels.key4, tableName: "", bundle: LOLocalizationManager.shared.currentBundle, value: "", comment: "")
        lblFive.text = NSLocalizedString(LOConstants.Labels.key5, tableName: "", bundle: LOLocalizationManager.shared.currentBundle, value: "", comment: "")
        lblSix.text = NSLocalizedString(LOConstants.Labels.key6, tableName: "", bundle: LOLocalizationManager.shared.currentBundle, value: "", comment: "")
        lblSeven.text = NSLocalizedString(LOConstants.Labels.key7, tableName: "", bundle: LOLocalizationManager.shared.currentBundle, value: "", comment: "")
        lblEight.text = NSLocalizedString(LOConstants.Labels.key8, tableName: "", bundle: LOLocalizationManager.shared.currentBundle, value: "", comment: "")
        lblNine.text = NSLocalizedString(LOConstants.Labels.key9, tableName: "", bundle: LOLocalizationManager.shared.currentBundle, value: "", comment: "")
        lblTen.text =  NSLocalizedString(LOConstants.Labels.key10, tableName: "", bundle: LOLocalizationManager.shared.currentBundle, value: "", comment: "")
        changeBGColor()
    }
    func changeBGColor()  {
        let labels = contentView.subviews.compactMap { $0 as? UILabel }
        for label in labels {
            UIView.transition(with: label, duration: 0.2, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
                label.backgroundColor = UIColor(hue: CGFloat(drand48()), saturation: 1, brightness: 1, alpha: 1)
            }) { (completed) in
            }
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print(self.scrollView.contentSize)
    }
    
}

extension HomeViewController: LanguagePickerViewDelegate {
   
    @objc func showOrHidePicker()  {
        picker.reloadAllComponents()
        if isHidden == true {
            UIView.animate(withDuration: 0.2, animations: {
                if #available(iOS 11.0, *) {
                    if self.bottomConstraintHidden.isActive {
                        NSLayoutConstraint.deactivate([self.bottomConstraintHidden])
                        NSLayoutConstraint.activate([self.bottomConstraintVisible])
                        self.viewController.view.layoutIfNeeded()
                        self.viewController.view.setRecursiveUserInteraction(enable: false)
                    }
                }
            }) { (testBoolean) in
                self.isHidden = false
            }
        }else {
            UIView.animate(withDuration: 0.2, animations: {
                if #available(iOS 11.0, *) {
                    if self.bottomConstraintVisible.isActive {
                        NSLayoutConstraint.deactivate([self.bottomConstraintVisible])
                        NSLayoutConstraint.activate([self.bottomConstraintHidden])
                        self.viewController.view.layoutIfNeeded()
                        self.viewController.view.setRecursiveUserInteraction(enable: true)
                        
                    }
                }
            }) { (testBoolean) in
                self.isHidden = true
            }
        }
    }
   
    func addPickerToView(){
        picker.tag = 1000
        picker.toolbar?.tag = 1001
        picker.languagePickerDelegate = self
        viewController.view.addSubview(picker)
        picker.reloadAllComponents()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.toolbar?.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(picker.toolbar!)
        viewController.view.addSubview(picker)
        if #available(iOS 11.0, *) {
            bottomConstraintHidden = self.picker.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor,constant: 300.0)
            bottomConstraintVisible = self.picker.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor,constant: 0.0)
            bottomConstraintHiddenToolBar = (self.picker.toolbar?.bottomAnchor.constraint(equalTo: self.picker.topAnchor,constant: 0.0))!
            NSLayoutConstraint.activate([
                picker.leadingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.leadingAnchor),
                picker.trailingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.trailingAnchor),
                (picker.toolbar?.leadingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.leadingAnchor))!,
                (picker.toolbar?.trailingAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.trailingAnchor))!,
                bottomConstraintHidden,bottomConstraintHiddenToolBar
                ])
        }
        
    }
   
    func enableLanguageSelection(isNavigationBarButton: Bool = false,forViewController:UIViewController) {
        viewController = forViewController
        self.removeViews()
            let button:UIButton = UIButton()
            button.tag = 1002
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Change Language", for: .normal)
            button.setTitleColor(.red, for: .normal)
            button.addTarget(self, action: #selector(showOrHidePicker), for: .touchUpInside)
            if isNavigationBarButton == true {
                viewController.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: button)
            }else {
                viewController.view.addSubview(button)
                if #available(iOS 11.0, *) {
                    NSLayoutConstraint.activate([
                        button.widthAnchor.constraint(equalToConstant: 40.0),
                        button.heightAnchor.constraint(equalToConstant: 40.0),
                        button.topAnchor.constraint(equalTo: self.viewController.view.topAnchor,constant: 15.0),
                        button.trailingAnchor.constraint(equalTo: self.viewController.view.safeAreaLayoutGuide.trailingAnchor,constant: -15.0),
                        ])
                }
            }
        self.addPickerToView()
    }
    func removeViews()  {
        for view in viewController.view.subviews {
            if view.tag == 1000 || view.tag == 1001 || view.tag == 1002 {
                view.removeFromSuperview()
            }
        }
    }
    func didTapDone(lang: DictionaryLanguage) {
        showOrHidePicker()
        LOLocalizationManager.shared.setCurrentBundle(forLanguage: lang.code)
        UserDefaults.selectedLanguage = lang.code
        NotificationCenter.default.post(name: Notification.Name(LOConstants.Notifications.LanguageChangeNotification), object: nil)
        picker.updateViewForLocalisation()
    }
    
    func didTapCancel() {
        showOrHidePicker()
    }

}
extension UIView {
    func setRecursiveUserInteraction(enable:Bool)  {
        for view in self.subviews {
            if view.tag == 1000 || view.tag == 1001 || view.tag == 1002 {
                view.isUserInteractionEnabled = true
            }else {
                view.isUserInteractionEnabled = enable
            }
        }
    }
}
// Required modals

extension UserDefaults {
    
    class var selectedLanguage:String {
        get {
            if (standard.string(forKey: "SelectedLanguage") == nil) {
                return "en"
            }
            else {
                return standard.string(forKey: "SelectedLanguage")!
            }
        }
        set {
            standard.set(newValue, forKey: "SelectedLanguage")
            standard.synchronize()
        }
    }
}
struct LOConstants {
    struct Notifications {
        static let LanguageChangeNotification = "LanguageChanged"
    }
    struct Labels {
        static let key1 = "key1"
        static let key2 = "key2"
        static let key3 = "key3"
        static let key4 = "key4"
        static let key5 = "key5"
        static let key6 = "key6"
        static let key7 = "key7"
        static let key8 = "key8"
        static let key9 = "key9"
        static let key10 = "key10"
    }
}
