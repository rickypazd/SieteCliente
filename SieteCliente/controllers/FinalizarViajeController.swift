import Alamofire
import GoogleMaps
import SVProgressHUD
import SwiftyJSON
import UIKit

class FinalizarViajeController: UIViewController {

    @IBOutlet weak var sliderCalificacion: UISlider!
    
    var json:JSON = [] // los datos que recibo desde EsperandoConductor
    var hiloCarrera:Timer!
    
    @IBOutlet weak var tfNombre: UILabel!
    @IBOutlet weak var tfPlaca: UILabel!
    @IBOutlet weak var tfInicio: UILabel!
    @IBOutlet weak var tfFinal: UILabel!
    @IBOutlet weak var tfFormaDePago: UILabel!
    @IBOutlet weak var tfTipoDeViaje: UILabel!
    @IBOutlet weak var tfTotal: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if hiloCarrera != nil {
            hiloCarrera.invalidate()
        }
        
        // TODO: ocultar la barra de navegacion para impedir que vuelva a la pantalla anterior
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás", style: .plain, target: nil, action: nil)
        
        getViajeDetalle()
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
                        
                        self.tfPlaca.text = objCarrera["placa"].string
                        self.tfNombre.text = objCarrera["nombre"].string
                        
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
                                self.tfInicio.text = direccion
                            })
                            
                            self.obtenerDireccion(latitud: objCarrera["latfinalreal"].double!, longitud: objCarrera["lngfinalreal"].double!, completionHandler: { direccion in
                                self.tfFinal.text = direccion
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
    
    @IBAction func listo(_ sender: Any) {
        self.performSegue(withIdentifier: "CalificarViaje", sender: self.json)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CalificarViaje" {
            let destinoVC = segue.destination as! CalificarViajeController
            destinoVC.json = sender as! JSON
            destinoVC.calificacion = Int(self.sliderCalificacion.value)
        }
    }
    
}
