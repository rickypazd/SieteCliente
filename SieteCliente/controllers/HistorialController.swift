import Alamofire
import GoogleMaps
import UIKit
import SVProgressHUD
import SwiftyJSON

class HistorialController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var viajes:[JSON] = []
    var favoritos:[JSON] = []
    @IBOutlet weak var tableViewHistorial: UITableView!
    @IBOutlet weak var tableviewFavorito: UITableView!
    var delegate: controlsInput?
    
    
    var textselecte:UITextField!
    var objSelect: JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableViewHistorial.isHidden = true
        obtenerFavoritos()
        NotificationCenter.default.addObserver(self, selector: #selector(notifiMensaje(notification:)), name: .nuevo_mensaje , object: nil)
        
   
        obtenerHistorialDeViajes()
    }
    @objc func notifiMensaje(notification: Notification){
        obtenerHistorialDeViajes()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: /* Favoritos */
            tableViewHistorial.isHidden = true
            tableviewFavorito.isHidden = false
            break
            
        case 1: /* Historial */
            tableViewHistorial.isHidden = false
            tableviewFavorito.isHidden = true
            break
            
        default:
            break
        }
    }
    

    func obtenerHistorialDeViajes() {
        var obj: JSON! = Util.getHistorial()
        if obj != nil {
            self.viajes = obj["arr"].arrayValue
            self.tableViewHistorial.reloadData()
        }
        
    }
    
    func obtenerFavoritos() {
        var obj: JSON! = Util.getFavoritos()
        if obj != nil {
                   self.favoritos = obj["arr"].arrayValue
                self.tableviewFavorito.reloadData()
        }
 
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if tableView ==  self.tableViewHistorial{
            let viaje = viajes[indexPath.row]
            self.textselecte.text = viaje["fn_direccion"].string
            self.objSelect["lat"].double = viaje["fn_lat"].double
            self.objSelect["lng"].double = viaje["fn_lng"].double
            delegate?.setJson(obj: self.objSelect)
            //        obtenerDireccion(latitud: viaje["latfinal"].double!, longitud: viaje["lngfinal"].double!, completionHandler: { direccion in
            //
            ////            cell.lbUbicacion?.text = direccion
            ////            cell.lbUbicacion?.numberOfLines = 0
            //
            //            //            self.tableViewHistorial.reloadData()
            //        })
            
            navigationController?.popViewController(animated: true)
           
        }else if tableView == self.tableviewFavorito{
            if indexPath.row-1 < 0 {
                //agregarFavoritos
                let json = JSON(["agg_boton":1])
                delegate?.setJson(obj: json)
                
            }else{
                let viaje = favoritos[indexPath.row-1]
                self.textselecte.text = viaje["nombre"].string
                self.objSelect["lat"].double = viaje["lat"].double
                self.objSelect["lng"].double = viaje["lng"].double
                delegate?.setJson(obj: self.objSelect)
                //        obtenerDireccion(latitud: viaje["latfinal"].double!, longitud: viaje["lngfinal"].double!, completionHandler: { direccion in
                //
                ////            cell.lbUbicacion?.text = direccion
                ////            cell.lbUbicacion?.numberOfLines = 0
                //
                navigationController?.popViewController(animated: true)
            }
           
        }
     return false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView ==  self.tableViewHistorial{
          return viajes.count
        }else if tableView == self.tableviewFavorito{
            return favoritos.count+1
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView ==  self.tableViewHistorial{
            let cell = tableView.dequeueReusableCell(withIdentifier: "historialCell", for: indexPath) as! HistorialTableViewCell
            
            let viaje = viajes[indexPath.row]
            
            obtenerDireccion(latitud: viaje["latfinal"].double!, longitud: viaje["lngfinal"].double!, completionHandler: { direccion in
                cell.lbUbicacion?.text = direccion
                cell.lbUbicacion?.numberOfLines = 0
                self.viajes[indexPath.row]["fn_direccion"].string = direccion
                self.viajes[indexPath.row]["fn_lat"].double = viaje["latfinal"].double!
                self.viajes[indexPath.row]["fn_lng"].double = viaje["lngfinal"].double!
                //            self.tableViewHistorial.reloadData()
            })
            
            return cell
        }else if tableView == self.tableviewFavorito{
            
            if (indexPath.row-1) < 0{
               let cell = tableView.dequeueReusableCell(withIdentifier: "aggfavoritoCell", for: indexPath) as! HistorialTableViewCell
                
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "favoritoCell", for: indexPath) as! HistorialTableViewCell
                let viaje = favoritos[indexPath.row-1]
                cell.lbUbicacion?.text = viaje["nombre"].string
                cell.lbUbicacion?.numberOfLines = 0
                
                return cell
            }
        }
        return nil!
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
