import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON

class PrincipalController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var contentView: UIView!
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0
    let geocoder = GMSGeocoder()

    @IBOutlet weak var tfInicio: UITextField!
    @IBOutlet weak var tfDestino: UITextField!
    var marcadorInicio = GMSMarker()
    var marcadorDestino = GMSMarker()
    var polyline = GMSPolyline(path: GMSPath()) // la ruta dibujada en el mapa
    
    // lo que recibe de ElegirTipoSiete
    var tipoCarrera: Int = 0
    
    @IBOutlet weak var tiposCarrerasCollectionView: UICollectionView!
    let tiposViajes = ["Estándar", "4x4", "Camioneta", "3 filas"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás", style: .plain, target: nil, action: nil)
        
        tiposCarrerasCollectionView.dataSource = self
        self.tiposCarrerasCollectionView.backgroundColor = UIColor.clear
        
        if (tipoCarrera != Util.ESTANDAR) {
            tiposCarrerasCollectionView.isHidden = true
        } else {
            self.navigationItem.title = "Siete estándar"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        
        contentView.addSubview( mapView )
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        obtenerDireccion(latitud: location.coordinate.latitude, longitud: location.coordinate.longitude, completionHandler: { direccion in
            marker.snippet = direccion
            self.tfInicio.text = direccion
        })
        
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
    
    @IBAction func mostrarLugaresVisitados(_ sender: UIButton) {
        // TODO: añadir efecto de toque al boton
        self.performSegue(withIdentifier: "MostrarHistorial", sender: tfDestino)
    }
    
    @IBAction func confirmarDestino(_ sender: Any) {
        let latInicial = mapView.myLocation?.coordinate.latitude ?? -17.744559
        let longInicial = mapView.myLocation?.coordinate.longitude ?? -63.168864
        let latFinal = self.marcadorDestino.position.latitude
        let longFinal = self.marcadorDestino.position.longitude
        
//        print("inicio \(mapView.myLocation?.coordinate.latitude), \(mapView.myLocation?.coordinate.longitude)")
//        print("inicio \(self.marcadorDestino.position.latitude), \(self.marcadorDestino.position.longitude)")
        
        /* de servisis a las brisas */
        /* servisis */
//        let latInicial = -17.744559
//        let longInicial = -63.168864
        
        /* las brisas */
//        let latFinal = -17.749444
//        let longFinal = -63.175742
        
        let iosApiKey = "AIzaSyD2uXL3TKoMAza8aP3q6RAozz4cL4ysnPc"
        
        let URL = "https://maps.googleapis.com/maps/api/directions/json?origin=\(latInicial),\(longInicial)&destination=\(latFinal),\(longFinal)&key=\(iosApiKey)"
//        let URL = "https://maps.googleapis.com/maps/api/directions/json?origin=\(latInicial!),\(longInicial!)&destination=\(latFinal),\(longFinal)&key=\(iosApiKey)"
//        print(URL)
        Alamofire.request(URL).responseJSON {
            response in
            
            let respuesta = JSON(response.data!)
            
            let routes = respuesta["routes"]
//            print(routes)
            
            // OVERVIEW POLYINE!!!!!
            // zvhkBptp`K]jAxCz@tC|@xLtDhCx@jCr@|Cz@SvCSrCs@jGOh@MZULKLIJIRC\\BZBNDHD^
            
            if (routes.isEmpty) {
//                print("no hay ruta establecida")
                return
            }
            
            self.mapView.clear()
            
            let path = GMSPath(fromEncodedPath: routes[0]["overview_polyline"]["points"].string!)
            self.polyline = GMSPolyline(path: path)

            self.polyline.map = self.mapView
            
            // todo crear el layout para el tipo de vehiculo
            let json:JSON = [
                "tipo": self.tipoCarrera,
                "lat": latInicial, // todo esta esto al pedo?
                "lng": longInicial, // todo esto tambien...
                "latinicio": latInicial,
                "lnginicio": longInicial,
                "latfinal": latFinal,
                "lngfinal": longFinal,
                "routes": routes // la respuesta de la api de direcciones de Google
            ]
     
            self.performSegue(withIdentifier: "CalcularRuta", sender: json)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CalcularRuta" {
            let destinoVC = segue.destination as! CalcularRutaController
            destinoVC.tipoCarrera = self.tipoCarrera
            destinoVC.json = sender as! JSON
        }else if segue.identifier == "MostrarHistorial" {
            let destinoVC = segue.destination as! HistorialController
            destinoVC.textselecte = self.tfDestino
//            destinoVC.json = sender as! JSON
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
    
}

extension PrincipalController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tiposViajes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TipoViaje", for: indexPath) as! TiposViajeCollectionCell
        
        switch tiposViajes[indexPath.row] {
        case "Estándar":
            cell.btnImagen.setImage(UIImage(named: "background_siete_estadar"), for: UIControlState.normal)
            cell.btnImagen.addTarget(self, action: #selector(self.seleccionarTipoSieteEstandar(_:)), for: .touchUpInside)
            cell.btnImagen.tag = Util.ESTANDAR
            
            break
            
        case "4x4":
            cell.btnImagen.setImage(UIImage(named: "background_siete_4x4"), for: UIControlState.normal)
            cell.btnImagen.addTarget(self, action: #selector(self.seleccionarTipoSieteEstandar(_:)), for: .touchUpInside)
            cell.btnImagen.tag = Util.TIPO_4X4
            
            break
            
        case "Camioneta":
            cell.btnImagen.setImage(UIImage(named: "background_siete_camioneta"), for: UIControlState.normal)
            cell.btnImagen.addTarget(self, action: #selector(self.seleccionarTipoSieteEstandar(_:)), for: .touchUpInside)
            cell.btnImagen.tag = Util.CAMIONETA
            
            break
            
        case "3 filas":
            cell.btnImagen.setImage(UIImage(named: "backgroud_tres_filas"), for: UIControlState.normal)
            cell.btnImagen.addTarget(self, action: #selector(self.seleccionarTipoSieteEstandar(_:)), for: .touchUpInside)
            cell.btnImagen.tag = Util.TIPO_3_FILAS
            
            break
            
        default:
            break
        }
        
        cell.btnImagen.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        
        return cell
    }
    
    @objc func seleccionarTipoSieteEstandar(_ sender: UIButton) {
        switch sender.tag {
        case Util.ESTANDAR:
            self.navigationItem.title = "Siete estándar"
            break
            
        case Util.TIPO_4X4:
            self.navigationItem.title = "Siete 4x4"
            break
            
        case Util.CAMIONETA:
            self.navigationItem.title = "Siete camioneta"
            break
            
        case Util.TIPO_3_FILAS:
            self.navigationItem.title = "Siete 3 filas"
            break
            
        default:
            break
        }
        
        tipoCarrera = sender.tag
    }
    
}
