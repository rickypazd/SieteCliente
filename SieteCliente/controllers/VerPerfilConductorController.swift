import Alamofire
import SwiftyJSON
import SVProgressHUD
import UIKit

class VerPerfilConductorController: UIViewController {

    @IBOutlet weak var imgPerfil: UIImageView!
    @IBOutlet weak var lbNombre: UILabel!
    @IBOutlet weak var lbVehiculo: UILabel!
    @IBOutlet weak var lbPlaca: UILabel!
    @IBOutlet weak var lbViajesCompletados: UILabel!
    
    var conductor:JSON = []
    var idCarrera:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // todo creo que seria mejor que esto vaya en esperando conductor
        obtenerPerfilConductor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func obtenerPerfilConductor() -> Void {
        if idCarrera == 0 {
            return
        }
        
        SVProgressHUD.setDefaultMaskType(.black)
        
        let parametros: Parameters = [
            "evento": "get_info_con_carrera",
            "id_carrera": idCarrera
        ]
        
        Alamofire.request(Util.urlIndexCtrl, parameters: parametros).responseJSON {
            response in
            
            switch response.result {
            case .success:
                let respuesta = JSON(response.data!) // todo creo que esto acá no va
                
                if respuesta.isEmpty {
                    Util.mostrarAlerta(titulo: "Hubo un error!", mensaje: "No se pudo cargar la información del conductor.")
                    return
                }
                
                self.conductor = respuesta
                
                let nombreConductor = respuesta["nombre"].string!
                let apellidoPa = respuesta["apellido_pa"].string!
                let apellidoMa = respuesta["apellido_ma"].string!
                let modelo = respuesta["modelo"].string!
                let marca = respuesta["marca"].string!
                let viajes = respuesta["cant_car"].int!
                let placa = respuesta["placa"].string!
                
                if !respuesta["foto_perfil"].string!.isEmpty {
                    self.obtenerFotoDePerfil(url: respuesta["foto_perfil"].string!)
                }
                
                self.lbNombre.text = "\(nombreConductor) \(apellidoPa) \(apellidoMa)"
                self.lbVehiculo.text = "\(marca)-\(modelo)"
                self.lbPlaca.text = placa
                self.lbViajesCompletados.text = "Ha completado \(viajes) viajes."
                
                break
                
            case .failure:
                Util.mostrarAlerta(titulo: "Error", mensaje: "No se pudo conectar con el servidor.")
                break
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    func obtenerFotoDePerfil(url:String) {
        Alamofire.request(Util.urlFoto + url).responseData { response in
            
            if let datos = response.result.value {
                let imagen = UIImage(data: datos)
                
                DispatchQueue.main.async {
                    self.imgPerfil.image = imagen
                }
            }
            
        }
    }
    
    @IBAction func llamarAlConductor(_ sender: Any) {
        let url:NSURL = NSURL(string: "tel://76656576")!
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "VerChat" {
            let destinoVc = segue.destination as! ChatController
            destinoVc.json = conductor
        }
    }
    
}
