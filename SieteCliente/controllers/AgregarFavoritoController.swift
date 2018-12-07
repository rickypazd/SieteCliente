//
//  AgregarFavoritoController.swift
//  SieteCliente
//
//  Created by Ricardo Paz Demiquel on 23/11/18.
//  Copyright © 2018 Ricardo Paz Demiquel. All rights reserved.
//


import UIKit
import Alamofire
import SVProgressHUD
import SwiftyJSON
import TinyConstraints
import GoogleMaps

import CRGradientNavigationBar

class AgregarFavoritoController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    @IBOutlet weak var tfInicio: UITextField!
    @IBOutlet weak var contentView: GMSMapView!
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0
    let geocoder = GMSGeocoder()
    var ubic_inicial: JSON = ["direccion": "", "lat": 0, "lng": 0, "nombre":" "]
    
    @IBAction func okaggfav(_ sender: Any) {
        if ubic_inicial["lat"].double != 0 && ubic_inicial["lng"] != 0{
        mostrarAlerta()
        }
    }
    func mostrarAlerta() {
        let alerta = UIAlertController(title: "Ingrese un nombre.", message: "", preferredStyle: .alert)
            alerta.view.backgroundColor = UIColor.init(red: 93, green: 56, blue: 148)
        alerta.addTextField { (textField) in
            textField.placeholder = "Nombre"
            
        }
        
        
        let accionOk = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            let nombre = alerta.textFields?.first?.text
            
            
           
            self.agregarNuevoPedido(producto: nombre!)
           
            
            alerta.dismiss(animated: true, completion: nil)
        })
        let accionCancelar = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
        
        alerta.addAction(accionCancelar)
        alerta.addAction(accionOk)
        
        UIApplication.topViewController()?.present(alerta, animated: true, completion: nil)
    }
    
    func agregarNuevoPedido(producto:String) {
        ubic_inicial["nombre"].string = producto
        var obj: JSON! = Util.getFavoritos()
                    if obj != nil {
        
                        let arr: [JSON]! = obj["arr"].arrayValue + [ubic_inicial]
                        let ob: JSON = ["arr": arr]
                        Util.setFavoritos(favoritos: ob.dictionaryObject!)
                    }else{
                        let ob: JSON = ["arr": [ubic_inicial]]
                        Util.setFavoritos(favoritos: ob.dictionaryObject!)
                    }
         navigationController?.popViewController(animated: true)
        
    }
    
    let imgMarker: UIImageView = {
        let images = UIImageView()
        images.image = #imageLiteral(resourceName: "pointer_map")
        //images.backgroundColor = .red
        
        return images
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(imgMarker)
        imgMarker.translatesAutoresizingMaskIntoConstraints = false
        imgMarker.widthAnchor.constraint(equalToConstant: 24).isActive = true
        imgMarker.heightAnchor.constraint(equalToConstant: 24).isActive = true
        imgMarker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imgMarker.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -15).isActive = true
         self.navigationItem.title = "Favorito"
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @objc func back(){
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //if !entro {
            //self.entro = true
          //  self.listo = false
            let location: CLLocation = locations.last!
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)
            mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
            mapView.settings.myLocationButton = true
            mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            mapView.isMyLocationEnabled = true
            mapView.delegate = self
            
            contentView.addSubview( mapView )
            
            self.ubic_inicial["lat"].double = Double(location.coordinate.latitude )
            self.ubic_inicial["lng"].double = Double(location.coordinate.longitude )
            self.ubic_inicial["direccion"].string = "nil"
            obtenerDireccion(latitud: location.coordinate.latitude, longitud: location.coordinate.longitude, completionHandler: { direccion in
                self.ubic_inicial["direccion"].string = direccion
                self.ubic_inicial["lat"].double = location.coordinate.latitude
                self.ubic_inicial["lng"].double = location.coordinate.longitude
                self.tfInicio.text = direccion
              //  self.tfDestino.becomeFirstResponder()
              //  self.tselect = self.tfDestino!
               // self.objSelect = self.ubic_final
              //  self.inselect = 1
                
            })
            
            mapView.animate(to: camera)
        }
        
    
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        //if !listo {
        //    self.listo = true
       // } else {
        //    if self.tselect != nil {
                
         let geo = GMSGeocoder()
                geo.reverseGeocodeCoordinate(position.target) { (response, error) in
                    guard error == nil else {
                        return
                    }
                    if let result = response?.firstResult(){
                        //  self.marcadorDestino.title = result.lines?[0]
                        // self.marcadorDestino.map = mapView
                        self.tfInicio.text = result.lines?[0]
                        self.ubic_inicial["direccion"].string = result.lines?[0]
                        self.ubic_inicial["lat"].double = position.target.latitude
                        self.ubic_inicial["lng"].double = position.target.longitude
                    }
                }
            }
            

        

    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        // self.marcadorDestino.position = position.target
        // self.marcadorDestino.map = mapView
    }
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
