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
        if conductor["id"].string != nil {
            cargar_perfil()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func cargar_perfil(){
        
        let nombreConductor = conductor["nombre"].string!
        let apellidoPa = conductor["apellido_pa"].string!
        let apellidoMa = conductor["apellido_ma"].string!
        let modelo = conductor["modelo"].string!
        let marca = conductor["marca"].string!
        let viajes = conductor["cant_car"].int!
        let placa = conductor["placa"].string!
        
        if !conductor["foto_perfil"].string!.isEmpty {
            self.obtenerFotoDePerfil(url: conductor["foto_perfil"].string!)
        }
        self.comentario.text = conductor["comentario"].string
        self.lbNombre.text = "\(nombreConductor) \(apellidoPa) \(apellidoMa)"
        self.lbVehiculo.text = "\(marca)-\(modelo)"
        self.lbPlaca.text = placa
        self.lbViajesCompletados.text = "Ha completado \(viajes) viajes."
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
