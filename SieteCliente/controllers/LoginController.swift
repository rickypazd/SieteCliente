import Alamofire
import UIKit
import SVProgressHUD
import SwiftHash
import SwiftyJSON

class LoginController: UIViewController {
    
    @IBOutlet weak var tfUsuario: UITextField!
    @IBOutlet weak var tfClave: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func validarLogin(_ sender: Any) {
        let usuario = tfUsuario.text!
        let clave = tfClave.text!
        
        if usuario.isEmpty {
            Util.mostrarAlerta(titulo: "Hubo un error!", mensaje: "El nombre de usuario no puede estar vacío.")
            return
        }
        
        if clave.isEmpty {
            Util.mostrarAlerta(titulo: "Hubo un error!", mensaje: "La contraseña no puede estar vacía.")
            return
        }
        
        iniciarSesion(usuario: usuario, clave: clave)
    }
    
    func iniciarSesion(usuario: String, clave: String) -> Void {
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: "Iniciando sesión...")
        
        let parametros: Parameters = [
            "evento": "login_cliente",
            "pass": MD5(clave).lowercased(),
            "usuario": usuario,
            "token": Util.getToken() ?? " "
        ]
        
        Alamofire.request(Util.urlIndexCtrl, parameters: parametros).responseJSON {
            response in
            
            switch response.result {
            case .success:
                let usuario = JSON(response.data!)
                
                if usuario["exito"] == "si" {
                    Util.setUsuario(usuario: usuario.dictionaryObject!)

                    let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarMainController") as! TabBarMainController
                    viewController.selectedViewController = viewController.viewControllers?[1]
                    self.present(viewController, animated: true, completion: nil)
                } else {
                    Util.mostrarAlerta(titulo: "Error", mensaje: "Datos incorrectos")
                }
                
                break
                
            case .failure:
                Util.mostrarAlerta(titulo: "Error", mensaje: "No se pudo conectar con el servidor")
                break
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    /* estoy sobreescribiendo este metodo para que el teclado se oculte si toco algo que no sea un campo de texto */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         self.view.endEditing(true)
    }
    
}
