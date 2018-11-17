import UIKit
import Firebase

class TabMenuController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás", style: .plain, target: nil, action: nil)
    }
    
    @IBAction func cerrarSesion(_ sender: Any) {
        Util.setUsuario(usuario: nil)
        
        let inicioVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainNavigationController") as! MainNavigationController
        self.present(inicioVC, animated: false, completion: nil)
    }
    
    @IBAction func obtenerToken(_ sender: Any) {
        let token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "")")
    }
    
}
