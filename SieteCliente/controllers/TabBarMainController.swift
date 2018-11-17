import UIKit
import Alamofire
import SVProgressHUD
import SwiftyJSON

class TabBarMainController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verificarSiHayCarreraEnCurso()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func verificarSiHayCarreraEnCurso() {
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: "Verificando si hay una carrera en curso...")
        
        let parametros: Parameters = [
            "evento": "get_carrera_cliente",
            "id_usr": Util.getUsuario()!["id"].int!,
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
