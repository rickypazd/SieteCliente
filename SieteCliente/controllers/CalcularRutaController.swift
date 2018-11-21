import Alamofire
import DLRadioButton
import GoogleMaps
import UIKit
import SVProgressHUD
import SwiftyJSON

extension DLRadioButton {
    func setSelected(_ selected: Bool) {
        if self.isSelected != selected {
            self.sendActions(for: .touchUpInside)
        }
    }
}
class CalcularRutaController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    @IBOutlet weak var imgTipoVehiculo: UIImageView!
    @IBOutlet weak var radioPagoEfectivo: DLRadioButton!
    @IBOutlet weak var radioPagoCredito: DLRadioButton!
    @IBOutlet weak var lbMonto: UILabel!
    @IBOutlet weak var mapContentView: UIView!
    var monto:Double = 0.0 /* el costo de la carrera */
    
    var json:JSON = [] // los datos que recibo desde TabPrincipalController
    var tipoCarrera = 0
    
    // todo hay que ver qué hace cada cosa
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0
    let geocoder = GMSGeocoder()
    var marcadorInicio = GMSMarker()
    var marcadorDestino = GMSMarker()
    var polyline = GMSPolyline(path: GMSPath()) // la ruta dibujada en el mapa
    
    /* CONSTANTES */
    let TIPO_PAGO_NO_SELECCIONADO:Int = 0
    let TIPO_PAGO_EFECTIVO:Int = 1
    let TIPO_PAGO_CREDITO:Int = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // todo creo que esto es para solicitar el permiso para usar los mapas
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        radioPagoEfectivo.setSelected(true)
        if !json.isEmpty {
            navigationItem.title = Util.getTipoCarrera(tipo: json["tipo"].int!)
        }
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás", style: .plain, target: nil, action: nil)
        
        obtenerCostoDeCarrera()
        actualizarImagenTipoCarrera()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func actualizarImagenTipoCarrera() {
        switch tipoCarrera {
        case Util.ESTANDAR:
            imgTipoVehiculo.image = UIImage(named: "icon_siete_cr")
            break
            
        case Util.TIPO_4X4:
            imgTipoVehiculo.image = UIImage(named: "icon_4x4_cr")
            break
            
        case Util.CAMIONETA:
            imgTipoVehiculo.image = UIImage(named: "icon_camioneta_cr")
            break
            
        case Util.TIPO_3_FILAS:
            imgTipoVehiculo.image = UIImage(named: "icon_4filas_cr")
            break
            
        case Util.SUPER_7:
            imgTipoVehiculo.image = UIImage(named: "icon_super_siete_cr")
            break
            
        case Util.MARAVILLA:
            imgTipoVehiculo.image = UIImage(named: "icon_maravilla_cr")
            break
            
        case Util.TO_GO:
            imgTipoVehiculo.image = UIImage(named: "icon_togo_cr")
            break
            
        default:
            return
        }
        
        imgTipoVehiculo.contentMode = UIView.ContentMode.scaleAspectFit
    }
    
    func obtenerCostoDeCarrera() -> Void {
        if json.isEmpty {
            return
        }
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: "Calculando tarifa...")

        let parametros: Parameters = [
            "evento": "get_costo",
            "id": json["tipo"].int!
        ]
        
        Alamofire.request(Util.urlAdminCtrl, parameters: parametros).responseJSON {
            response in
            
            switch response.result {
            case .success:
                let respuesta = JSON(response.data!)
                
                let routes = self.json["routes"].array![0]
                // esto lo consigo iterando en la respuesta de la peticion a google directions
                let sum = routes["legs"][0]["steps"].count
                
                let costo_metro = respuesta["costo_metro"].double!
                let costo_minuto = respuesta["costo_minuto"].double!
                let costo_basico = respuesta["costo_basico"].double!
                self.monto = costo_basico + (costo_metro * Double(sum)) + ((Double(sum) / 500) * costo_minuto)
                
                self.lbMonto.text = "Monto aproximado: \(Int(self.monto) - 2) - \(Int(self.monto) + 2) Bs."
                break
                
            case .failure:
                Util.mostrarAlerta(titulo: "Error", mensaje: "No se pudo conectar con el servidor para calcular la tarifa.")
                break
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location:CLLocation = locations.last!
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: mapContentView.bounds, camera: camera)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.delegate = self

        mapContentView.addSubview(mapView)
        
        if !json.isEmpty {
            self.mapView.clear()
            
            let routes = json["routes"].array![0]
            
            // dibujo la ruta desde el punto de partida hasta el inicio
            // (la ruta está en overview_polyline)
            let path = GMSPath(fromEncodedPath: routes["overview_polyline"]["points"].string!)//json["overview_polyline"].string!)
            self.polyline = GMSPolyline(path: path)
            
            self.polyline.map = self.mapView
            
            // coloco el marcador el el destino
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: json["latfinal"].double!, longitude: json["lngfinal"].double!)
            marker.map = mapView
            let marker2 = GMSMarker()
            marker2.position = CLLocationCoordinate2D(latitude: json["latinicio"].double!, longitude: json["lnginicio"].double!)
            marker2.map = mapView
            
          
            var bounds = GMSCoordinateBounds()
            bounds = bounds.includingCoordinate(marker.position)
            bounds = bounds.includingCoordinate(marker2.position)
            mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100))
            
        }
        
        //mapView.animate(to: camera)
    }
 
    @IBAction func confirmarCarrera(_ sender: Any) {
        // validación para obtener los creditos del usuario
        obtenerPerfilUsuario()
    }
    
    func obtenerPerfilUsuario() {
        if json.isEmpty {
            return
        }
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: "Verificando créditos suficientes...")
        
        let parametros: Parameters = [
            "evento": "get_usuario",
            "id": Util.getUsuario()!["id"].int!
        ]
        
        Alamofire.request(Util.urlIndexCtrl, parameters: parametros).responseJSON {
            response in
            
            switch response.result {
            case .success:
                let respuesta = JSON(response.data!)
                
                if respuesta["exito"].string == "si" {
                    Util.setUsuario(usuario: respuesta.dictionaryObject!)
                }
                
                self.verificarCreditosSuficientes()
                
                break
                
            case .failure:
                Util.mostrarAlerta(titulo: "Error", mensaje: "No se pudo conectar con el servidor.")
                break
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    func verificarCreditosSuficientes() {
        let creditos = Util.getUsuario()!["creditos"].double!
        
        let tipoPago = radioPagoEfectivo.isSelected ? TIPO_PAGO_EFECTIVO : (radioPagoCredito.isSelected ? TIPO_PAGO_CREDITO : TIPO_PAGO_NO_SELECCIONADO)
        
        switch tipoPago {
        case TIPO_PAGO_NO_SELECCIONADO:
            Util.mostrarAlerta(titulo: "Hubo un error!", mensaje: "Debe seleccionar un tipo de pago.")
            return
            
        case TIPO_PAGO_CREDITO:
            if creditos < self.monto {
                Util.mostrarAlerta(titulo: "", mensaje: "No cuentas con créditos suficientes.")
                return
            }
            
            self.okPedirCarrera(tipoPago: tipoPago)
            
            break
            
        case TIPO_PAGO_EFECTIVO:
            if creditos < 0 {
                let alerta = UIAlertController(title: "", message: "Se le cobrará \(creditos * -1) por la cancelación anterior.", preferredStyle: .alert)
                
                let accionOk = UIAlertAction(title: "Ok", style: .default, handler: { accion in
                    self.okPedirCarrera(tipoPago: tipoPago)
                })
                
                let accionCancelar = UIAlertAction(title: "Cancelar", style: .default, handler: { accion in
                    alerta.dismiss(animated: true, completion: nil)
                    return
                })
                
                alerta.addAction(accionCancelar)
                alerta.addAction(accionOk)
                
                UIApplication.topViewController()?.present(alerta, animated: true, completion: nil)
            } else {
                self.okPedirCarrera(tipoPago: tipoPago)
            }
            
            break
            
        default:
            break
        }
    }
    
    func okPedirCarrera(tipoPago:Int) {
        self.json["token"].string = "token"
        self.json["tipo_pago"].int = tipoPago
        
        self.performSegue(withIdentifier: "PedirSiete", sender: self.json)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PedirSiete" {
            let destinoVC = segue.destination as! PidiendoSieteController
            destinoVC.json = sender as! JSON
        }
    }
    
}
