import DLRadioButton
import GoogleMaps
import SwiftyJSON
import UIKit

class SieteToGoController: UIViewController {

    @IBOutlet weak var tfDestino: UITextField!
    @IBOutlet weak var mapContentView: UIView!
    @IBOutlet weak var radioPagoEfectivo: DLRadioButton!
    @IBOutlet weak var radioPagoCredito: DLRadioButton!

    var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    var zoomLevel: Float = 15.0
    var currentLocation: CLLocation?
    let geocoder = GMSGeocoder()
    var marcadorDestino = GMSMarker()

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
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás", style: .plain, target: nil, action: nil)    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func confirmarCarrera(_ sender: Any) {
        let creditos = Util.getUsuario()!["creditos"].double!

        let tipoPago = radioPagoEfectivo.isSelected ? TIPO_PAGO_EFECTIVO : (radioPagoCredito.isSelected ? TIPO_PAGO_CREDITO : TIPO_PAGO_NO_SELECCIONADO)
        
        switch tipoPago {
        case TIPO_PAGO_NO_SELECCIONADO:
            Util.mostrarAlerta(titulo: "Hubo un error!", mensaje: "Debe seleccionar un tipo de pago.")
            return
            
        case TIPO_PAGO_CREDITO:
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
        let json:JSON = [
            "tipo": Util.TO_GO,
            "latFin": self.marcadorDestino.position.latitude,
            "lngFin": self.marcadorDestino.position.longitude,
            "token": "token", // TODO: de donde obtengo el token?
            "productos": Util.getPedidos()!,
            "tipo_pago": tipoPago
        ]
        
        self.performSegue(withIdentifier: "PedirSieteToGo", sender: json)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PedirSieteToGo" {
            let destinoVC = segue.destination as! PidiendoSieteController
            destinoVC.json = sender as! JSON
        }
    }
    
}

extension SieteToGoController : CLLocationManagerDelegate, GMSMapViewDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location:CLLocation = locations.last!
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: mapContentView.bounds, camera: camera)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        
        mapContentView.addSubview(mapView)
        
        mapView.animate(to: camera)
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {        geocoder.reverseGeocodeCoordinate(position.target) { (response, error) in
        guard error == nil else {
            return
        }
        
        if let result = response?.firstResult() {
            self.marcadorDestino.title = result.lines?[0]
            self.marcadorDestino.map = mapView
            
            self.tfDestino.text = result.lines?[0]
        }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        self.marcadorDestino.position = position.target
        self.marcadorDestino.map = mapView
    }
    
}
