import Alamofire
import GoogleMaps
import UIKit
import MapKit
import SVProgressHUD
import SwiftyJSON

class MisViajesController : UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var viajes:[JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: "Cargando tu historial de viajes...")

        let parametros: Parameters = [
            "evento": "get_mis_viajes",
            "id": Util.getUsuario()!["id"]
        ]

        Alamofire.request(Util.urlIndexCtrl, parameters: parametros).responseJSON {
            response in

            let carreras = JSON(response.data!)
            self.viajes = carreras.array!

            self.tableView.reloadData()

            SVProgressHUD.dismiss()
        }
        
//        let location = CLLocationCoordinate2D(latitude: -17.7689764, longitude: -63.1834192)
        
//        let geo = GMSGeocoder()
//        geo.reverseGeocodeCoordinate(location) { (response, error) in
//            let results = response?.results()
//
//            var direccion:String = ""
//
//            for i in (results?.first?.lines)! {
//                direccion += i + " "
//            }
//
//            print(direccion)
//        }
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

extension MisViajesController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viajes.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
         // dismiss(animated: true, completion: nil)
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MisViajesTableViewCell
        
        let indice = indexPath.row
        let viaje = viajes[indice]
        
        cell.lbFecha.text = viaje["fecha_pedido"].string!
        cell.lbVehiculo.text = viaje["marca"].string
        
        let estado = viaje["estado"].int
        
        if estado == 7 {
            obtenerDireccion(latitud: viaje["latinicial"].double!, longitud: viaje["lnginicial"].double!, completionHandler: { direccion in
                cell.lbPartida.text = direccion
            })
            
            obtenerDireccion(latitud: viaje["latfinalreal"].double!, longitud: viaje["lngfinalreal"].double!, completionHandler: { direccion in
                cell.lbLlegada.text = direccion
            })
            
            cell.lbMontoPago.text = "bs. \(viaje["costo_final"].int!)"// String(describing: viaje["costo_final"].int)
        } else {
            obtenerDireccion(latitud: viaje["latinicial"].double!, longitud: viaje["lnginicial"].double!, completionHandler: { direccion in
                cell.lbPartida.text = direccion
            })
            
            obtenerDireccion(latitud: viaje["latfinal"].double!, longitud: viaje["lngfinal"].double!, completionHandler: { direccion in
                cell.lbLlegada.text = direccion
            })
            
            cell.lbMontoPago.text = "cancelado"
        }
        
        cell.lbPartida.text = String(format:"%f", viaje["latinicial"].double!)
        cell.lbLlegada.text = String(format:"%f", viaje["latfinalreal"].double!)
        
        switch viaje["tipo_pago"].int {
        case 1: // EFECTIVO
            cell.lbTipoPago.text = "Efectivo"
            break
            
        case 2: // CREDITO
            cell.lbTipoPago.text = "Crédito"
            break
            
        default:
            break
        }
        
        return cell
    }
    
}
