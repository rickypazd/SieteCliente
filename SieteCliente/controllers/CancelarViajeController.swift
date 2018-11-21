import Alamofire
import SVProgressHUD
import UIKit
import SwiftyJSON

class CancelarViajeController: UIViewController {
    
    var json:JSON = [] // los datos que recibo desde EsperandoConductor
    var hiloCarrera:Timer!
    @IBOutlet weak var lbAviso: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if json.isEmpty {
            return
        }
        
        if json["cobro"].boolValue {
            let monto = json["total"].int!
            lbAviso.text = "Se le cobrará bs. \(monto) por la cancelación."
        } else {
            lbAviso.text = "Cancelar en este punto aún es gratuito."
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancelarViaje(_ sender: Any) {
        if json.isEmpty {
            return
        }
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: "Cancelando carrera...")
        
        let parametros: Parameters = [
            "evento": "ok_cancelar_carrera",
            "json": json.rawString()!
        ]
        
        Alamofire.request(Util.urlAdminCtrl, parameters: parametros).response { response in
            if response.error == nil {
                if let resp = String(data: response.data!, encoding: .utf8) {
                    if resp == "exito" {
                        self.hiloCarrera.invalidate()
                        
                        let alerta = UIAlertController(title: "Listo!", message: "Viaje cancelado.", preferredStyle: UIAlertController.Style.alert)
                        let accionOk = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                            alerta.dismiss(animated: true, completion: nil)
                            
                            // TODO: puede que tenga que cambiar esto
                            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarMainController") as! TabBarMainController
                            viewController.selectedViewController = viewController.viewControllers?[1]
                            
                            self.present(viewController, animated: false, completion: nil)
                        })
                        
                        alerta.addAction(accionOk)
                        
                        UIApplication.topViewController()?.present(alerta, animated: true, completion: nil)
                    } else {
                        Util.mostrarAlerta(titulo: "Error", mensaje: "No se pudo cancelar la carrera.")
                    }
                }
            } else {
                Util.mostrarAlerta(titulo: "Error", mensaje: "No se pudo conectar con el servidor para calcular la tarifa.")
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
}
