import Alamofire
import UIKit
import SVProgressHUD
import SwiftyJSON

class CalificarViajeController: UIViewController {

    @IBOutlet weak var tfComentario: UITextField!
    var json:JSON = [] // los datos que recibo desde FinalizarViaje
    var calificacion:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func listo(_ sender: Any) {
        calificarViaje()
    }
    
    func calificarViaje() -> Void {
        if json.isEmpty {
            return
        }
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: "Calificando viaje...")
        
        let parametros: Parameters = [
            "evento": "finalizo_carrera_cliente",
            "id_carrera": json["id"].int!,
            "calificacion": calificacion,
            "amable": true,
            "auto_limpio": true,
            "buena_ruta": true,
            "mensaje": tfComentario.text!
        ]
        
        Alamofire.request(Util.urlIndexCtrl, parameters: parametros).response { response in
            if response.error == nil {
                
                if let resp = String(data: response.data!, encoding: .utf8) {
                    if resp == "falso" {
                        Util.mostrarAlerta(titulo: "", mensaje: "Hubo un problema al calificar al conductor.")
                    } else {
                        // TODO: puede que tenga que cambiar esto
                        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarMainController") as! TabBarMainController
                        viewController.selectedViewController = viewController.viewControllers?[1]
                        
                        self.present(viewController, animated: false, completion: nil)
                    }
                }
                
            } else {
                Util.mostrarAlerta(titulo: "Error", mensaje: "No se pudo conectar con el servidor.")
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
}
