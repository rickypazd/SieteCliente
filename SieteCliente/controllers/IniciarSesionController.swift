import UIKit
import Alamofire
import FBSDKLoginKit
import SwiftyJSON
import SVProgressHUD
import SwiftHash

class IniciarSesionController: UIViewController {
    
    @IBOutlet weak var btnLoginFacebook: RoundButton!
    var estaIngresandoConFb:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Util.getUsuario() != nil {
            let viewController = storyboard?.instantiateViewController(withIdentifier: "TabBarMainController") as! TabBarMainController
            viewController.selectedViewController = viewController.viewControllers?[1]
            present(viewController, animated: false, completion: nil)
            return
        }
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás", style: .plain, target: nil, action: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        estaIngresandoConFb = false
    }
    
    @IBAction func ingresarConFacebook(_ sender: UIButton) {
        FBSDKLoginManager().logIn(withReadPermissions: ["email"], from: self) { (result, err) in
            if (err != nil) {
                print("Custom FB login failed:", err!)
                return
            }
            
            FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, first_name, last_name, email, birthday, gender"]).start{ (connection, result, err) in
                
                if err != nil {
                    print("Failed to start graph request:", err!)
                    return
                }
                
                let gerson = result as! [String: AnyObject]
                let json = JSON(gerson)
                self.estaIngresandoConFb = true
                
                self.getUsuarioFb(id: json["id"].string!, usuarioFb: json)
            }
        }
    }
    
    func getUsuarioFb(id:String, usuarioFb: JSON) {
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: "Enlazando tu cuenta de facebook...")
        
        let parametros: Parameters = [
            "evento": "get_usuario_face",
            "id_usr": id
        ]
        
        Alamofire.request(Util.urlIndexCtrl, parameters: parametros).responseJSON { response in
            switch response.result {
            case .success:
                let respuesta = JSON(response.data!)
                
                if respuesta["exito"].string == "si" {
                    Util.setUsuario(usuario: respuesta.dictionaryObject!)
                    
                    let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarMainController") as! TabBarMainController
                    viewController.selectedViewController = viewController.viewControllers?[1]
                    self.present(viewController, animated: true, completion: nil)
                } else {
                    self.performSegue(withIdentifier: "Registrarse", sender: usuarioFb)
                }
                
                break
                
            case .failure:
                Util.mostrarAlerta(titulo: "Error", mensaje: "No se pudo conectar con el servidor.")
                break
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Registrarse" {
            let destinoVC = segue.destination as! RegistrarController
            if estaIngresandoConFb {
                destinoVC.usuarioFb = sender as! JSON
                destinoVC.estaIngresandoConFb = true
            }
        }
    }
    
}
