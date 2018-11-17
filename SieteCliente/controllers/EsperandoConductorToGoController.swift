import Alamofire
import GoogleMaps
import SVProgressHUD
import SwiftyJSON
import UIKit

class EsperandoConductorToGoController: UIViewController {

    var json:JSON = [] // los datos que recibo desde PidiendoSiete
    var objCarreraJson:JSON = []
    @IBOutlet weak var mapContentView: UIView!
    var hiloCarrera:Timer!

    // TODO: hay que ver qué hace cada cosa
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0
    let geocoder = GMSGeocoder()
    var marcadorInicio = GMSMarker()
    var marcadorDestino = GMSMarker()
    var polyline = GMSPolyline(path: GMSPath()) // la ruta dibujada en el mapa    `
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: creo que esto es para solicitar el permiso para usar los mapas
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        hilo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func hilo() {
        // TODO: esto se puede optimizar volviendo a hacer la petición no en un hilo, sino al finalizar la petición
        hiloCarrera = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: Selector("getPosicionConductor"), userInfo: nil, repeats: true)
    }
    
    @objc func getPosicionConductor() {
        if json.isEmpty {
            return
        }
        
        let parametros:Parameters = [
            "evento": "get_pos_conductor_x_id_carrera",
            "id": json["id"].int!
        ]
        
        Alamofire.request(Util.urlIndexCtrl, parameters: parametros).response { response in
            if response.error == nil {
                
                if let resp = String(data: response.data!, encoding: .utf8) {
                    if resp == "falso" {
                        Util.mostrarAlerta(titulo: "", mensaje: "No se encontró un conductor disponible, disculpe las molestias.")
                    } else if let datos = resp.data(using: .utf8, allowLossyConversion: false) {
                        let respuesta = try! JSON(data: datos)
                        
                        self.objCarreraJson = respuesta
                        
                        switch respuesta["estado"].int {
                        case 1: // en pedido
                            break
                        case 2: //carrera confirmada
                            break
                        case 3: // conductor cerca
                            // TODO: notificationReceiver()
                            break
                        case 4: // conductor llego
                            self.inicioCarrera()
                            break
                        case 5: // inicio carrera
                            self.finalizoCarrera(json: respuesta)
                            break
                        case 6: // en cobro
                            break
                        case 7: //finalizada`
                            self.performSegue(withIdentifier: "FinalizarViajeToGo", sender: self.json)
                            break
                        case 10: // cancelada
                            self.hiloCarrera.invalidate()
                            let alerta = UIAlertController(title: "", message: "El conductor canceló la carrera", preferredStyle: UIAlertControllerStyle.alert)
                            alerta.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                                alerta.dismiss(animated: true, completion: nil)
                                
                                let inicioVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarMain") as! TabBarMainController
                                
                                self.present(inicioVC, animated: false, completion: nil)
                            }))
                        
                            UIApplication.topViewController()?.present(alerta, animated: true, completion: nil)
                            break
                        default:
                            
                            break
                        }
                        
                        
                        let lat = respuesta["lat"].double!
                        let lng = respuesta["lng"].double!
                        
                        let ll1 = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                        var ll2:CLLocationCoordinate2D
                        var lat2=0.0;
                        var lng2=0.0;
                        if respuesta["estado"].int == 4 {
                            lat2 = self.json["latfinal"].double!
                            lng2 = self.json["lngfinal"].double!
                            
                            
                            ll2 = CLLocationCoordinate2D(latitude: lat2, longitude: lng2)
                        } else {
                            lat2 = self.json["latinicial"].double!
                            lng2 = self.json["lnginicial"].double!
                            ll2 = CLLocationCoordinate2D(latitude: lat2, longitude: lng2)
                        }
                        
                        let results = GMSGeometryDistance(ll1, ll2)
                        
                        self.mapView.clear()
                        
                        // coloco el marcador el el destino
                        let marker = GMSMarker()
                        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                        marker.map = self.mapView
                        let dist = 0.0
                        
                        /* para no consumir a cada rato el api de google */
                        if dist-results > 20.0 || dist - results < -20 || dist == 0.0 {
                            print("consumiendo api de google")
                            self.obtenerDireccion(latInicial:lat2, lngInicial:lng2, latFinal: lat, lngFinal: lng)
                        }
                    }
                }
            } else {
                Util.mostrarAlerta(titulo: "Error", mensaje: "No se pudo conectar con el servidor.")
            }
        }
    }
    
    func inicioCarrera() {
        if json.isEmpty {
            return
        }
        
        let parametros:Parameters = [
            "evento": "get_carrera_id",
            "id": json["id"].int!
        ]
        
        Alamofire.request(Util.urlIndexCtrl, parameters: parametros).responseJSON { response in
            switch response.result {
            case .success:
                let respuesta = JSON(response.data!)
                self.json = respuesta
                break
                
            case .failure:
                Util.mostrarAlerta(titulo: "Error", mensaje: "No se pudo conectar con el servidor.")
                break
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    func finalizoCarrera(json:JSON) {
        if json.isEmpty {
            return
        }
        
        self.hiloCarrera.invalidate()
        self.performSegue(withIdentifier: "FinalizarViajeToGo", sender: json)
    }
    
    @IBAction func cancelarViaje(_ sender: Any) {
        if json["estado"].int == 4 {
            verPerfilConductor()
        } else {
            cancelarViaje()
        }
    }
    
    func verPerfilConductor() {
        self.performSegue(withIdentifier: "VerPerfilConductorToGo", sender: self.json["id"].int)
    }
    
    func cancelarViaje() -> Void {
        if json.isEmpty {
            return
        }
        
        let parametros: Parameters = [
            "evento": "cancelar_carrera",
            "id_carrera": json["id"].int!,
            "id_usr": Util.getUsuario()!["id"].int!,
            "tipo_cancelacion": 2,
            "id_tipo": 0
        ]
        
        Alamofire.request(Util.urlAdminCtrl, parameters: parametros).responseJSON {
            response in
            
            switch response.result {
            case .success:
                let json = JSON(response.data!)
                
                self.performSegue(withIdentifier: "CancelarViajeToGo", sender: json)
                
                break
                
            case .failure:
                Util.mostrarAlerta(titulo: "Error", mensaje: "No se pudo conectar con el servidor para calcular la tarifa.")
                break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CancelarViajeToGo" {
            let destinoVC = segue.destination as! CancelarViajeController
            destinoVC.json = sender as! JSON
            destinoVC.hiloCarrera = self.hiloCarrera
        } else if segue.identifier == "FinalizarViajeToGo" {
            let destinoVC = segue.destination as! FinalizarViajeController
            destinoVC.json = sender as! JSON
            destinoVC.hiloCarrera = self.hiloCarrera
        } else if segue.identifier == "VerPerfilConductorGo" {
            let destinoVC = segue.destination as! VerPerfilConductorController
            destinoVC.idCarrera = sender as! Int
        }
    }
    
    func obtenerDireccion(latInicial:Double, lngInicial:Double, latFinal:Double, lngFinal:Double) {
        let iosApiKey = "AIzaSyD2uXL3TKoMAza8aP3q6RAozz4cL4ysnPc"
        
        let URL = "https://maps.googleapis.com/maps/api/directions/json?origin=\(latInicial),\(lngInicial)&destination=\(latFinal),\(lngFinal)&key=\(iosApiKey)"
        
        Alamofire.request(URL).responseJSON {
            response in
            
            let respuesta = JSON(response.data!)
            
            let routes = respuesta["routes"]
            
            if (routes.isEmpty) {
                /* no hay ruta establecida */
                return
            }
            
            let path = GMSPath(fromEncodedPath: routes[0]["overview_polyline"]["points"].string!)
            self.polyline = GMSPolyline(path: path)
            //pintar
            self.polyline.map = self.mapView
        }
    }
    
}

extension EsperandoConductorToGoController: CLLocationManagerDelegate, GMSMapViewDelegate {
    
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
    
}
