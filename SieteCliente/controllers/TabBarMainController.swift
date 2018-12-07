import UIKit
import Alamofire
import SVProgressHUD
import SwiftyJSON

class TabBarMainController: UITabBarController {
    
    @IBOutlet weak var TapBar: UITabBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.selectedIndex = 2
        
        let usuario = Util.getUsuario()
        if usuario == nil {
            //SVProgressHUD.dismiss()
            let inicioVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IniciarSesionController") as! IniciarSesionController
            self.present(inicioVC, animated: false, completion: nil)
           // return
        }else{
            verificarSiHayCarreraEnCurso()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func verificarSiHayCarreraEnCurso() {
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: "Verificando si hay una carrera en curso...")
        let usuario = Util.getUsuario()
    
        let id = usuario?["id"].stringValue
        let parametros: Parameters = [
            "evento": "get_carrera_cliente",
            "id_usr": id ?? "0"
       ]
        
        Alamofire.request(Util.urlIndexCtrl, parameters: parametros).responseJSON { response in
            if response.error == nil {
                
                if let resp = String(data: response.data!, encoding: .utf8) {
                    if resp == "falso" {
                        Util.mostrarAlerta(titulo: "Error", mensaje: "Hubo un error al comprobar si hay una carrera en curso.")
                    } else if let datos = resp.data(using: .utf8, allowLossyConversion: false) {
                        let respuesta = try! JSON(data: datos)
                        
                        if respuesta["exito"].boolValue {
                            if respuesta["id_tipo"].int == 2 {
                                // todo lanza togo
                            } else {
                                self.performSegue(withIdentifier: "CarreraEnCurso", sender: respuesta)
                            }
                        } else {
                            // todo borrar el char de userdefaults
                        }
                    }
                }
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CarreraEnCurso" {
            let destinoVC = segue.destination as! EsperandoConductorController
            destinoVC.json = sender as! JSON
        }
    }
    
}
