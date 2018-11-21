import DLRadioButton
import GoogleMaps
import SwiftyJSON
import UIKit
import FittedSheets

class SieteToGoController: UIViewController {

    var listaProductos: JSON = []
    @IBOutlet weak var tfDestino: UITextField!{
        didSet{
             tfDestino.setIcon(#imageLiteral(resourceName: "icon_pointer2_map"))
        }
    }
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
    
    let imgMarker: UIImageView = {
        let images = UIImageView()
        images.image = #imageLiteral(resourceName: "pointer_map")
        //images.backgroundColor = .red
        
        return images
    }()
    @IBOutlet weak var stackView: UICustonStack!{
        didSet{
            stackView.layer.cornerRadius = 25
        }
    }

    @IBOutlet weak var btn_verproductos: UIButton!
    @IBAction func clickProductos(_ sender: Any) {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "productosto") as! PedidosToGoController
        vc.btn_productos = self.btn_verproductos
        vc.listaProductos = self.listaProductos
        let controller = SheetViewController(controller: vc, sizes: [.fullScreen, .fixed(200)])
        
        
        //controller.blurBottomSafeArea = false
        
        self.present(controller, animated: false, completion: nil)
        
    }
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
        self.view.addSubview(imgMarker)
        imgMarker.translatesAutoresizingMaskIntoConstraints = false
        imgMarker.widthAnchor.constraint(equalToConstant: 24).isActive = true
        imgMarker.heightAnchor.constraint(equalToConstant: 24).isActive = true
        imgMarker.centerXAnchor.constraint(equalTo: self.mapContentView.centerXAnchor).isActive = true
        imgMarker.centerYAnchor.constraint(equalTo: self.mapContentView.centerYAnchor, constant: -15).isActive = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás", style: .plain, target: nil, action: nil)
        self.navigationItem.title = "Siete To Go"
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "productosto") as! PedidosToGoController
        vc.btn_productos = self.btn_verproductos
        let controller = SheetViewController(controller: vc, sizes: [.halfScreen, .fixed(200)])
        
        
        //controller.blurBottomSafeArea = false
        
        self.present(controller, animated: false, completion: nil)
    }

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
        
        case TIPO_PAGO_EFECTIVO:
            self.okPedirCarrera(tipoPago: tipoPago)
            break
            
        default:
            return
        }
    }
    var json: JSON = []
    func okPedirCarrera(tipoPago:Int) {
        self.json = [
            "tipo": Util.TO_GO,
            "latFin": self.marcadorDestino.position.latitude,
            "lngFin": self.marcadorDestino.position.longitude,
            "token": "token", // TODO: de donde obtengo el token?
            "productos": Util.getPedidos() ?? [],
            "tipo_pago": tipoPago
        ]
        
        self.performSegue(withIdentifier: "PedirSieteToGo", sender: json)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PedirSieteToGo" {
            let destinoVC = segue.destination as! PidiendoSieteController
            destinoVC.json = self.json
            
        }else if segue.identifier == "Productostogo" {
            let destinoVC = segue.destination as! PedidosToGoController
            destinoVC.btn_productos = self.btn_verproductos
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
           // self.marcadorDestino.title = result.lines?[0]
            //self.marcadorDestino.map = mapView
            
            self.tfDestino.text = result.lines?[0]
        }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
     //   self.marcadorDestino.position = position.target
      //  self.marcadorDestino.map = mapView
    }
    
}
