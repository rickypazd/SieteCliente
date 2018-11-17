import Alamofire
import GoogleMaps
import UIKit
import SVProgressHUD
import SwiftyJSON

class HistorialController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var viajes:[JSON] = []
    @IBOutlet weak var tableViewHistorial: UITableView!
    
    var textselecte:UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableViewHistorial.isHidden = true
        obtenerHistorialDeViajes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: /* Favoritos */
            tableViewHistorial.isHidden = true
            break
            
        case 1: /* Historial */
            tableViewHistorial.isHidden = false
            break
            
        default:
            break
        }
    }
    
    func obtenerHistorialDeViajes() {
        SVProgressHUD.setDefaultMaskType(.black)
        
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
                self.tableViewHistorial.reloadData()
                break
            case .failure:
                Util.mostrarAlerta(titulo: "Error", mensaje: "No se pudo conectar con el servidor.")
                break
            }
            SVProgressHUD.dismiss()
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        self.textselecte.text = "asdasda"
         navigationController?.popViewController(animated: true)
        return false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viajes.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historialCell", for: indexPath) as! HistorialTableViewCell
        
        let viaje = viajes[indexPath.row]
        
        obtenerDireccion(latitud: viaje["latfinal"].double!, longitud: viaje["lngfinal"].double!, completionHandler: { direccion in
            cell.lbUbicacion?.text = direccion
            cell.lbUbicacion?.numberOfLines = 0

//            self.tableViewHistorial.reloadData()
        })
        
        return cell
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
