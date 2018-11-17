import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON

class SeleccionarDestinoSieteEstandarController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var contentView: UIView!
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0
    let geocoder = GMSGeocoder()
    
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
        tiposCarrerasCollectionView.layer.zPosition = 20
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
    
    @IBAction func confirmarDestino(_ sender: Any) {
        //        let latInicial = mapView.myLocation?.coordinate.latitude
        //        let longInicial = mapView.myLocation?.coordinate.longitude
        //        let latFinal = self.marcadorDestino.position.latitude
        //        let longFinal = self.marcadorDestino.position.longitude
        
        /* de servisis a las brisas */
        /* servisis */
        let latInicial = -17.744559
        let longInicial = -63.168864
        
        /* las brisas */
        let latFinal = -17.749444
        let longFinal = -63.175742
        
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
            destinoVC.json = sender as! JSON
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

extension SeleccionarDestinoSieteEstandarController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tiposViajes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TipoViaje", for: indexPath) as! TiposViajeCollectionCell
        cell.btnImagen.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        //cell.btnImagen.setImage(UIImage(named: "icono.png"), for: UIControlState.normal)
        
        return cell
    }
    
}
