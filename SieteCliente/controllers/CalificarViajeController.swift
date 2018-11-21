import Alamofire
import UIKit
import SVProgressHUD
import SwiftyJSON

class CalificarViajeController: UIViewController {

    @IBOutlet weak var tfComentario: UITextField!{
        didSet{
          
        }
    }
    var json:JSON = [] // los datos que recibo desde FinalizarViaje
    var calificacion:Int = 0
    
    @IBOutlet weak var b_amable: UIButton!
    @IBOutlet weak var b_buena_ruta: UIButton!
    @IBOutlet weak var b_auto_limpio: UIButton!
    
    var isAmable: Bool = false
    var isBuenaRuta: Bool = false
    var isAutoLimpio: Bool = false
    @IBAction func btn_auto_limpio(_ sender: Any) {
        if !isAutoLimpio{
            self.b_auto_limpio.layer.opacity = 0.3
            isAutoLimpio = true
        }else{
            self.b_auto_limpio.layer.opacity = 1
            isAutoLimpio = false
        }
       
    }
    @IBAction func btn_amable(_ sender: Any) {
        if !isAmable{
            self.b_amable.layer.opacity = 0.3
            isAmable = true
        }else{
            self.b_amable.layer.opacity = 1
            isAmable = false
        }
    }
    @IBAction func btn_buena_ruta(_ sender: UIButton) {
        if !isBuenaRuta{
            self.b_buena_ruta.layer.opacity = 0.3
            isBuenaRuta = true
        }else{
            self.b_buena_ruta.layer.opacity = 1
            isBuenaRuta = false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBOutlet weak var bt_listo: UIButton!{
        didSet{
            bt_listo.setTitle("Listo", for: .normal)
            bt_listo.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            bt_listo.backgroundColor = UIColor.init(red: 146, green: 58, blue: 237)
            bt_listo.layer.masksToBounds = true
            bt_listo.layer.cornerRadius = 10
            bt_listo.setTitleColor(.white, for: .normal)
        }
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
            "amable": isAmable,
            "auto_limpio": isAutoLimpio,
            "buena_ruta": isBuenaRuta,
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
