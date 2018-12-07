import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON
import FittedSheets
import UserNotifications
protocol controlsInput {
    func setJson(obj: JSON)
}
extension UITextField {
    func setIcon(_ image: UIImage) {
        let iconView = UIImageView(frame:
            CGRect(x: 10, y: 5, width: 20, height: 20))
        iconView.image = image
        let iconContainerView: UIView = UIView(frame:
            CGRect(x: 20, y: 0, width: 30, height: 30))
        iconContainerView.addSubview(iconView)
        leftView = iconContainerView
        leftViewMode = .always
    }
}



class PrincipalController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UITextFieldDelegate, controlsInput, UIGestureRecognizerDelegate, UNUserNotificationCenterDelegate {
   
   
    
  
    @IBOutlet weak var contentView: UIView!
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0
    let geocoder = GMSGeocoder()
    var ubic_inicial: JSON = ["direccion": "", "lat": 0, "lng": 0]
    var ubic_final: JSON = ["direccion": "", "lat": 0, "lng": 0]
    var objDetalle: JSON!
    

    
    @IBOutlet weak var tfInicio: UITextField! {
        didSet {
//            tfInicio.tintColor = UIColor.lightGray
            tfInicio.setIcon(#imageLiteral(resourceName: "icon_pointer_map"))
            
        }
    }
    @IBOutlet weak var tfDestino: UITextField!{
        didSet {
//            tfDestino.tintColor = UIColor.lightGray
            tfDestino.setIcon(#imageLiteral(resourceName: "icon_pointer2_map"))
            
        }
    }
    
    var tselect: UITextField!
    var objSelect: JSON!
    var inselect: Int = 0
    var entro: Bool = false
    var listo: Bool = false
    var presListo: Bool = false
    var marcadorInicio = GMSMarker()
    var marcadorDestino = GMSMarker()
    var polyline = GMSPolyline(path: GMSPath()) // la ruta dibujada en el mapa
    var controller: SheetViewController!
    
    // lo que recibe de ElegirTipoSiete
    var tipoCarrera: Int = 0
    
    @IBAction func editing(_ sender: UITextField!) {
        self.tselect = sender
        self.objSelect = self.ubic_inicial
        self.inselect = 0
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "historialid") as! HistorialController
            vc.textselecte = self.tselect
            vc.objSelect = self.ubic_inicial
            vc.delegate = self
            self.tfInicio.becomeFirstResponder()
            // self.btn_accion.isHidden = false
        controller = SheetViewController(controller: vc, sizes: [.fixed(self.contentView.frame.height-150)])
        //controller.blurBottomSafeArea = false
        self.view.endEditing(true)
        self.present(controller, animated: false, completion: nil)
    }
    @IBAction func editingfinal(_ sender: UITextField!) {
        self.tselect = sender
        self.objSelect = self.ubic_final
        self.inselect = 1
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "historialid") as! HistorialController
        
        vc.textselecte = self.tselect
        vc.objSelect = self.ubic_final
        vc.delegate = self
        // self.btn_accion.isHidden = false
        self.tfDestino.becomeFirstResponder()
        controller = SheetViewController(controller: vc, sizes: [.fixed(self.contentView.frame.height-150)])
        //controller.blurBottomSafeArea = false
        self.view.endEditing(true)
        self.present(controller, animated: false, completion: nil)
        
    }
    
  
 
    
    @IBOutlet weak var tiposCarrerasCollectionView: UICollectionView!
    
    func setJson(obj: JSON) {
        if obj["agg_boton"].int != nil {
            self.performSegue(withIdentifier: "AgregarFavoritoIden", sender: nil)
        } else {
            if self.inselect == 1 {
                self.ubic_final = obj
                self.btn_accion.isHidden = true
                self.confirmar_pedido()
            }else if self.inselect == 0{
                self.ubic_inicial = obj
                self.btn_accion.isHidden = true
                self.confirmar_pedido()
            }
          
        }
         self.controller.closeSheet()
       
    }
    let tiposViajes = ["Estándar", "4x4", "Camioneta", "3 filas"]
    
    let imgMarker: UIImageView = {
        let images = UIImageView()
        images.image = #imageLiteral(resourceName: "pointer_map")
        //images.backgroundColor = .red
        
        return images
    }()
    
    let btn_accion : UIButton = {
        let buton = UIButton()
        buton.setTitle("Listo", for: .normal)
        buton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        buton.backgroundColor = UIColor.init(red: 146, green: 58, blue: 237)
        buton.layer.masksToBounds = true
        buton.layer.cornerRadius = 10
        buton.setTitleColor(.white, for: .normal)
        return buton
    }()
    
    let btn_maravilla : UIButton = {
        let buton = UIButton()
        buton.setImage(UIImage(named: "background_siete_maravilla"), for: UIControl.State.normal)
        buton.tag = Util.MARAVILLA
        return buton
    }()
    let btn_super : UIButton = {
        let buton = UIButton()
        buton.setImage(UIImage(named: "background_super_siete"), for: UIControl.State.normal)
        buton.tag = Util.SUPER_7
        return buton
    }()
    

    func addConstrains(){
          self.view.addSubview(imgMarker)
        imgMarker.translatesAutoresizingMaskIntoConstraints = false
        imgMarker.widthAnchor.constraint(equalToConstant: 24).isActive = true
        imgMarker.heightAnchor.constraint(equalToConstant: 24).isActive = true
                imgMarker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imgMarker.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -15).isActive = true
        self.view.addSubview(btn_accion)
        btn_accion.translatesAutoresizingMaskIntoConstraints = false
        btn_accion.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.3).isActive = true
        btn_accion.heightAnchor.constraint(equalToConstant: 24).isActive = true
        btn_accion.topAnchor.constraint(equalTo: self.imgMarker.bottomAnchor, constant: 20).isActive = true
        btn_accion.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        self.view.addSubview(btn_maravilla)
        btn_maravilla.translatesAutoresizingMaskIntoConstraints = false
        btn_maravilla.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.6).isActive = true
        btn_maravilla.heightAnchor.constraint(equalToConstant: 90).isActive = true
        btn_maravilla.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -24).isActive = true
        btn_maravilla.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        self.view.addSubview(btn_super)
        btn_super.translatesAutoresizingMaskIntoConstraints = false
        btn_super.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.6).isActive = true
        btn_super.heightAnchor.constraint(equalToConstant: 90).isActive = true
        btn_super.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -24).isActive = true
        btn_super.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        addConstrains()
        
        let tap :UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(ok_listo(sender:)))
        tap.numberOfTapsRequired=1
        btn_accion.addGestureRecognizer(tap)
        
//        tfInicio.addTarget(self, action: #selector(myTargetFunction), for: UIControl.Event.touchUpOutside)
//        tfDestino.addTarget(self, action: #selector(myTargetFunction), for: UIControl.Event.touchUpOutside)
        
  
        
        self.tfInicio.delegate = self
        self.tfDestino.delegate = self
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás", style: .plain, target: self, action:#selector(back(sender:)))
        
        tfInicio.layer.cornerRadius = 20
        tiposCarrerasCollectionView.dataSource = self
        self.tiposCarrerasCollectionView.backgroundColor = UIColor.clear
         self.btn_accion.isHidden = true
         tiposCarrerasCollectionView.isHidden = true
        btn_super.isHidden = true
            btn_maravilla.isHidden = true
        if (tipoCarrera != Util.ESTANDAR) {
            if(tipoCarrera == Util.MARAVILLA){
                  self.navigationItem.title = "Siete Maravilla"
                let tapmaravilla :UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(calcular_maravilla(sender:)))
                tapmaravilla.numberOfTapsRequired=1
                btn_maravilla.addGestureRecognizer(tapmaravilla)
                btn_maravilla.isHidden = false
            }
            if(tipoCarrera == Util.SUPER_7){
                 self.navigationItem.title = "Super Siete"
                let tapsuper :UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(calcular_super(sender:)))
                tapsuper.numberOfTapsRequired=1
                btn_super.addGestureRecognizer(tapsuper)
                  btn_super.isHidden = false
            }
           
        } else {
             tiposCarrerasCollectionView.isHidden = false
            self.navigationItem.title = "Siete Estándar"
        }
        
        self.tselect = self.tfDestino
        self.objSelect = self.ubic_final
        self.inselect = 1
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "historialid") as! HistorialController
        
        vc.textselecte = self.tselect
        vc.objSelect = self.ubic_final
        vc.delegate = self
        // self.btn_accion.isHidden = false
        
        controller = SheetViewController(controller: vc, sizes: [.fixed(self.contentView.frame.height-150)])
        //controller.blurBottomSafeArea = false
        
        self.present(controller, animated: false, completion: nil)
        
        self.cargar_historia()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tfInicio.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {    //delegate method
        print("1")
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {  //delegate method
        print("2")
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        self.view.endEditing(true)
        return false
    }
    @objc func handleTap(_ sender: UILongPressGestureRecognizer) {
        
      self.view.endEditing(true)
    }
    @objc func back(sender: UIBarButtonItem) {
        self.navigationController?.isNavigationBarHidden = true; self.navigationController?.popViewController(animated: true)
    }
   
    @objc func ok_listo(sender: UITapGestureRecognizer){
           self.confirmar_pedido()
    }

    @objc func calcular_maravilla(sender: UITapGestureRecognizer){
        self.ok_calcular_ruta(tipo: Util.MARAVILLA)
    }
    @objc func calcular_super(sender: UITapGestureRecognizer){
        self.ok_calcular_ruta(tipo: Util.SUPER_7)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !entro {
            self.entro = true
            self.listo = false
            let location: CLLocation = locations.last!
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)
            mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
            mapView.settings.myLocationButton = true
            mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            mapView.isMyLocationEnabled = true
            mapView.delegate = self
            
            contentView.addSubview( mapView )
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            gestureRecognizer.delegate = self
            self.mapView.addGestureRecognizer(gestureRecognizer)
            //self.ubic_inicial["lat"].double = Double(location.coordinate.latitude )
            //self.ubic_inicial["lng"].double = Double(location.coordinate.longitude )
            //self.ubic_inicial["direccion"].string = "nil"
            obtenerDireccion(latitud: location.coordinate.latitude, longitud: location.coordinate.longitude, completionHandler: { direccion in
                if self.ubic_inicial["lat"].double == 0 && self.ubic_inicial["lng"].double == 0 {
                    self.ubic_inicial["direccion"].string = direccion
                    self.ubic_inicial["lat"].double = location.coordinate.latitude
                    self.ubic_inicial["lng"].double = location.coordinate.longitude
                    self.tfInicio.text = direccion
                    self.tfDestino.becomeFirstResponder()
                    self.view.endEditing(true)
                    self.tselect = self.tfDestino!
                    self.objSelect = self.ubic_final
                    self.inselect = 1
                }
             
                
            })
            
            mapView.animate(to: camera)
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if !listo {
            self.listo = true
        } else {
            if self.tselect != nil {
                
                if self.inselect == 1 {
                    self.ubic_final["lat"].double = position.target.latitude
                    self.ubic_final["lng"].double = position.target.longitude
                    self.btn_accion.isHidden = false
                }else if self.inselect == 0{
                    self.ubic_inicial["lat"].double =  position.target.latitude
                    self.ubic_inicial["lng"].double = position.target.longitude
                    self.btn_accion.isHidden = false
                }
            geocoder.reverseGeocodeCoordinate(position.target) { (response, error) in
                guard error == nil else {
                    return
                }
                if let result = response?.firstResult() {
                    //  self.marcadorDestino.title = result.lines?[0]
                    // self.marcadorDestino.map = mapView
                   self.presListo = false
                    self.tselect.text = result.lines?[0]
                    
                }
            }
        }
            
        }
        
    }

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
       // self.marcadorDestino.position = position.target
       // self.marcadorDestino.map = mapView
    }
    
    @IBAction func mostrarLugaresVisitados(_ sender: UIButton) {
        // TODO: añadir efecto de toque al boton
        self.performSegue(withIdentifier: "MostrarHistorial", sender: tfDestino)
    }
    
    
    func confirmar_pedido(){
        self.view.endEditing(true)
        let latInicial: Double =   self.ubic_inicial["lat"].double!
        let longInicial: Double = self.ubic_inicial["lng"].double!
        let latFinal: Double =  self.ubic_final["lat"].double!
        let longFinal: Double = self.ubic_final["lng"].double!
        
        //        print("inicio \(mapView.myLocation?.coordinate.latitude), \(mapView.myLocation?.coordinate.longitude)")
        //        print("inicio \(self.marcadorDestino.position.latitude), \(self.marcadorDestino.position.longitude)")
        
        /* de servisis a las brisas */
        /* servisis */
//                let latInicial = -17.744559
//                let longInicial = -63.168864
        
        /* las brisas */
//                let latFinal = -17.749444
//                let longFinal = -63.175742
        
        let iosApiKey = "AIzaSyD2uXL3TKoMAza8aP3q6RAozz4cL4ysnPc"
        
        let URL = "https://maps.googleapis.com/maps/api/directions/json?origin=\(latInicial),\(longInicial)&destination=\(latFinal),\(longFinal)&key=\(iosApiKey)"
        //        let URL = "https://maps.googleapis.com/maps/api/directions/json?origin=\(latInicial!),\(longInicial!)&destination=\(latFinal),\(longFinal)&key=\(iosApiKey)"
        //        print(URL)
        self.mapView.clear()
        let markerini = GMSMarker()
        markerini.position = CLLocationCoordinate2D(latitude: latInicial, longitude: longInicial)
        
        markerini.map = mapView
        let markerfin = GMSMarker()
        markerfin.position = CLLocationCoordinate2D(latitude: latFinal, longitude: longFinal)
        markerfin.map = mapView
        self.listo = false
        var bounds = GMSCoordinateBounds()
        bounds = bounds.includingCoordinate(markerini.position)
        bounds = bounds.includingCoordinate(markerfin.position)
        mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100))
        
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
            
            
            let path = GMSPath(fromEncodedPath: routes[0]["overview_polyline"]["points"].string!)
            self.polyline = GMSPolyline(path: path)
            
            self.polyline.map = self.mapView
            self.btn_accion.isHidden = true
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
            self.objDetalle = json
            self.presListo = true
        
        }
    }
    
    func ok_calcular_ruta(tipo: Int){
        if presListo {
                self.objDetalle["tipo"].int = tipo
                self.tipoCarrera = tipo
                self.performSegue(withIdentifier: "CalcularRuta", sender: objDetalle)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CalcularRuta" {
            let destinoVC = segue.destination as! CalcularRutaController
            destinoVC.tipoCarrera = self.tipoCarrera
            destinoVC.json = sender as! JSON
        }else if segue.identifier == "MostrarHistorial" {
            let destinoVC = segue.destination as! HistorialController
            if self.inselect == 1 {
                destinoVC.textselecte = self.tfDestino
                destinoVC.objSelect = self.ubic_final
                destinoVC.delegate = self
                destinoVC.viajes = self.viajes
               // self.btn_accion.isHidden = false
            }else if self.inselect == 0{
                destinoVC.textselecte = self.tfInicio
                destinoVC.objSelect = self.ubic_inicial
                destinoVC.delegate = self
                    destinoVC.viajes = self.viajes
                //self.btn_accion.isHidden = false
            }
          
            
//            destinoVC.json = sender as! JSON
        }
    }
    var viajes: [JSON]!
    func cargar_historia(){
       // SVProgressHUD.setDefaultMaskType(.black)
        
        let parametros: Parameters = [
            "evento": "get_historial_ubic",
            "id": Util.getUsuario()!["id"].int!
        ]
        
        Alamofire.request(Util.urlIndexCtrl, parameters: parametros).responseJSON { response in
            switch response.result {
            case .success:
                let respuesta = JSON(response.data!)
                // todo:
                self.viajes = respuesta.array!
                let ob: JSON = ["arr": self.viajes]
            
                Util.setHitorial(historial: ob.dictionaryObject )
                NotificationCenter.default.post(name: .nuevo_mensaje, object: nil)
                
                break
            case .failure:
                Util.mostrarAlerta(titulo: "Error", mensaje: "No se pudo conectar con el servidor.")
                break
            }
         //   SVProgressHUD.dismiss()
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
            cell.btnImagen.setImage(UIImage(named: "background_siete_estadar"), for: UIControl.State.normal)
            cell.btnImagen.addTarget(self, action: #selector(self.seleccionarTipoSieteEstandar(_:)), for: .touchUpInside)
            cell.btnImagen.tag = Util.ESTANDAR
            
            break
            
        case "4x4":
            cell.btnImagen.setImage(UIImage(named: "background_siete_4x4"), for: UIControl.State.normal)
            cell.btnImagen.addTarget(self, action: #selector(self.seleccionarTipoSieteEstandar(_:)), for: .touchUpInside)
            cell.btnImagen.tag = Util.TIPO_4X4
            
            break
            
        case "Camioneta":
            cell.btnImagen.setImage(UIImage(named: "background_siete_camioneta"), for: UIControl.State.normal)
            cell.btnImagen.addTarget(self, action: #selector(self.seleccionarTipoSieteEstandar(_:)), for: .touchUpInside)
            cell.btnImagen.tag = Util.CAMIONETA
            
            break
            
        case "3 filas":
            cell.btnImagen.setImage(UIImage(named: "backgroud_tres_filas"), for: UIControl.State.normal)
            cell.btnImagen.addTarget(self, action: #selector(self.seleccionarTipoSieteEstandar(_:)), for: .touchUpInside)
            cell.btnImagen.tag = Util.TIPO_3_FILAS
            
            break
            
        default:
            break
        }
        
        cell.btnImagen.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        
        return cell
    }
    
    @objc func seleccionarTipoSieteEstandar(_ sender: UIButton) {
        switch sender.tag {
        case Util.ESTANDAR:
            self.navigationItem.title = "Siete estándar"
            ok_calcular_ruta(tipo: Util.ESTANDAR)
            break
            
        case Util.TIPO_4X4:
            self.navigationItem.title = "Siete 4x4"
              ok_calcular_ruta(tipo: Util.TIPO_4X4)
            break
            
        case Util.CAMIONETA:
            self.navigationItem.title = "Siete camioneta"
             ok_calcular_ruta(tipo: Util.CAMIONETA)
            break
            
        case Util.TIPO_3_FILAS:
            self.navigationItem.title = "Siete 3 filas"
            ok_calcular_ruta(tipo: Util.TIPO_3_FILAS)
            break
            
        default:
            break
        }
        
        tipoCarrera = sender.tag
    }
 

    
}
