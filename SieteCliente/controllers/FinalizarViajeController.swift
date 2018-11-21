import Alamofire
import GoogleMaps
import SVProgressHUD
import TinyConstraints
import SwiftyJSON
import UIKit

class FinalizarViajeController: UIViewController {

   
    
    var json:JSON = [] // los datos que recibo desde EsperandoConductor
    var hiloCarrera:Timer!
    var califi:Int = 0
    @IBOutlet weak var tfNombre: UILabel!{
        didSet{
            tfNombre.text = "Placa ⦁ Telefono"
            tfNombre.backgroundColor = UIColor.init(red: 146, green: 58, blue: 237)
            tfNombre.layer.masksToBounds = true
            tfNombre.layer.cornerRadius = 10
            tfNombre.textColor = UIColor.white
            
            //        label.layer.borderWidth = 1
            //        label.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
            tfNombre.textAlignment = .center
        }
    }
  
    @IBOutlet weak var viewFeeling: FeelingsView!
    
    @IBOutlet weak var tfInicio: UILabel!{
        didSet{
            tfInicio.text = "Direccion inicio"
            
            
            tfInicio.backgroundColor = UIColor.init(red: 255, green: 255, blue: 255)
            //label.layer.masksToBounds = true
            tfInicio.layer.cornerRadius = 5
            tfInicio.textColor =  UIColor.init(red: 80, green: 80, blue: 80)
            tfInicio.layer.borderWidth = 1
            tfInicio.layer.borderColor = UIColor(red:0, green:0, blue:0, alpha: 1).cgColor
            tfInicio.numberOfLines = 0
        }
    }
    @IBOutlet weak var tfFinal: UILabel!{
        didSet{
            tfFinal.text = "Direccion final"
            
            tfFinal.backgroundColor = UIColor.init(red: 255, green: 255, blue: 255)
            //label.layer.masksToBounds = true
            tfFinal.layer.cornerRadius = 5
            tfFinal.textColor =  UIColor.init(red: 80, green: 80, blue: 80)
            tfFinal.layer.borderWidth = 1
            tfFinal.layer.borderColor = UIColor(red:0, green:0, blue:0, alpha: 1).cgColor
            tfFinal.numberOfLines = 0
        }
    }
    
    @IBOutlet weak var tfFormaDePago: UILabel!
    @IBOutlet weak var tfTipoDeViaje: UILabel!
    @IBOutlet weak var tfTotal: UILabel!
    
    @IBOutlet weak var CustonV: UICustomView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if hiloCarrera != nil {
            hiloCarrera.invalidate()
        }
        
        // TODO: ocultar la barra de navegacion para impedir que vuelva a la pantalla anterior
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás", style: .plain, target: nil, action: nil)
       carge_star()
        getViajeDetalle()
      
    }
    
    func carge_star(){
        let rows = [""]
        let columns = ["","","","","","",""]
        let values = [1,2,3,4,5,6,7]
        viewFeeling.columnTitles = columns
        viewFeeling.rowTitles = rows
        //Reload
        viewFeeling.reloadFeelingView()
        //Detect selection of Feelings value
        viewFeeling.onFilledCompletion = { (row,column) in
            //Note: row and column are the Int which a user tapped in the 
            
                self.califi = values[column]
              self.performSegue(withIdentifier: "CalificarViaje", sender: self.json)
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getViajeDetalle() {
        if json.isEmpty {
            return
        }
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: "Obteniendo detalles de la carrera...")
        
        let parametros: Parameters = [
            "evento": "get_viaje_detalle",
            "id": json["id"].int!
        ]
        
        Alamofire.request(Util.urlIndexCtrl, parameters: parametros).response { response in
            if response.error == nil {
                
                if let resp = String(data: response.data!, encoding: .utf8) {
                    if resp == "falso" {
                        Util.mostrarAlerta(titulo: "", mensaje: "Hubo un problema al calificar al conductor.")
                    } else if let datos = resp.data(using: .utf8, allowLossyConversion: false) {
                        let objCarrera = try! JSON(data: datos)
                        
                        self.tfNombre.text = "\(objCarrera["placa"].string!) ⦁ \(objCarrera["nombre"].string!)"
                        switch objCarrera["tipo"].int {
                        case 1:
                            self.tfTipoDeViaje.text = "Siete estándar"
                            break
                            
                        case 2:
                            self.tfTipoDeViaje.text = "Siete to go"
                            break
                            
                        case 3:
                            self.tfTipoDeViaje.text = "Siete maravilla"
                            break
                            
                        case 4:
                            self.tfTipoDeViaje.text = "Super siete"
                            break
                            
                        case 5:
                            self.tfTipoDeViaje.text = "Siete 4x4"
                            break
                            
                        case 6:
                            self.tfTipoDeViaje.text = "Siete camioneta"
                            break
                            
                        case 7:
                            self.tfTipoDeViaje.text = "Siete 3 filas"
                            break
                            
                        default:
                            break
                        }
                        
                        switch objCarrera["tipo_pago"].int {
                        case 1:
                            self.tfFormaDePago.text = "Efectivo"
                            break
                            
                        case 2:
                            self.tfFormaDePago.text = "Crédito"
                            break
                            
                        default:
                            break
                        }
                        
                        if objCarrera["estado"].int == 10 {
                            self.tfFormaDePago.text = "Cancelado"
                        }
                        
                        switch objCarrera["estado"].int {
                        case 7:
                            self.obtenerDireccion(latitud: objCarrera["latinicial"].double!, longitud: objCarrera["lnginicial"].double!, completionHandler: { direccion in
                               
                                let fullString = NSMutableAttributedString(string: "")
                                let image1Attachment = ImageAttachment()
                                image1Attachment.image = UIImage(named: "pointer_map")
                                let image1String = NSAttributedString(attachment: image1Attachment)
                                fullString.append(image1String)
                                fullString.append(NSAttributedString(string: direccion))
                                self.tfInicio.attributedText = fullString
                            })
                            
                            self.obtenerDireccion(latitud: objCarrera["latfinalreal"].double!, longitud: objCarrera["lngfinalreal"].double!, completionHandler: { direccion in
                                let fullString = NSMutableAttributedString(string: "")
                                let image1Attachment = ImageAttachment()
                                image1Attachment.image = UIImage(named: "pointer_map2")
                                let image1String = NSAttributedString(attachment: image1Attachment)
                                fullString.append(image1String)
                                fullString.append(NSAttributedString(string: direccion))
                                self.tfFinal.attributedText = fullString
                            })
                            
                            self.tfTotal.text = "\(objCarrera["costo_final"].double!) Bs."
                            
                            break
                        case 10:
                            self.obtenerDireccion(latitud: objCarrera["latinicial"].double!, longitud: objCarrera["lnginicial"].double!, completionHandler: { direccion in
                                self.tfInicio.text = direccion
                            })
                            
                            self.obtenerDireccion(latitud: objCarrera["latfinal"].double!, longitud: objCarrera["lngfinal"].double!, completionHandler: { direccion in
                                self.tfFinal.text = direccion
                            })
                            
                            self.tfTotal.text = "0 Bs."
                            
                            break
                        default:
                            break
                        }
                        
                    }
                }
                
            } else {
                Util.mostrarAlerta(titulo: "Error", mensaje: "No se pudo conectar con el servidor.")
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    // esta funcion se encarga de llamar a obtenerDireccion() porque se ejecuta en 2do plano
    func obtenerDireccionDeCoordenadas(latitud: Double, longitud: Double, completionHandler: @escaping (String) -> ()) {
        obtenerDireccion(latitud: latitud, longitud: longitud, completionHandler: completionHandler)
    }
    
    // no llamar a esta funcion directamente
    func obtenerDireccion( latitud: Double, longitud: Double, completionHandler: @escaping (String) -> ()) {
        let location = CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
        
        let geo = GMSGeocoder()
        geo.reverseGeocodeCoordinate(location) { (response, error) in
            if error != nil {
                completionHandler("")
                return
            }
            
            if response == nil {
                completionHandler("")
                return
            }
            
            let results = response?.results()
            
            var direccion:String = ""
            
            for i in (results?.first?.lines)! {
                direccion += i + " "
            }
            
            completionHandler(direccion)
        }
    }
    
 
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CalificarViaje" {
            let destinoVC = segue.destination as! CalificarViajeController
            destinoVC.json = sender as! JSON
            destinoVC.calificacion = Int(self.califi)
        }
    }
    
}
