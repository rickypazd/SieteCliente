import Alamofire
import SwiftyJSON
import SVProgressHUD
import UIKit

class VerPerfilConductorController: UIViewController {

    @IBOutlet weak var imgPerfil: UIImageView!
    @IBOutlet weak var lbNombre: UILabel!{
        didSet{
            
            lbNombre.backgroundColor = UIColor.init(red: 146, green: 58, blue: 237)
            lbNombre.layer.masksToBounds = true
            lbNombre.layer.cornerRadius = 10
            lbNombre.textColor = UIColor.white
        }
    }
    @IBOutlet weak var lbVehiculo: UILabel!{
        didSet{
            lbVehiculo.backgroundColor = UIColor.init(red: 146, green: 58, blue: 237)
            lbVehiculo.layer.masksToBounds = true
            lbVehiculo.layer.cornerRadius = 10
            lbVehiculo.textColor = UIColor.white
        }
    }
    @IBOutlet weak var lbPlaca: UILabel!{
        didSet{
            lbPlaca.backgroundColor = UIColor.init(red: 146, green: 58, blue: 237)
            lbPlaca.layer.masksToBounds = true
            lbPlaca.layer.cornerRadius = 10
            lbPlaca.textColor = UIColor.white
        }
    }
    @IBOutlet weak var lbViajesCompletados: UILabel!{
        didSet{
            
        }
    }
    
    @IBOutlet weak var comentario: UILabel!{
        didSet{
            comentario.backgroundColor = UIColor.init(red: 255, green: 255, blue: 255,a:0.2)
            comentario.layer.masksToBounds = true
            comentario.layer.cornerRadius = 10
            comentario.textColor = UIColor.white

        }
    }
    
    var conductor:JSON = []
    var idCarrera:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.setNavigationBar()
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
                self.comentario.text = respuesta["comentario"].string
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
