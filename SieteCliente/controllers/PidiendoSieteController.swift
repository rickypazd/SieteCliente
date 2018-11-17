import Alamofire
import SVProgressHUD
import SwiftyJSON
import UIKit

class PidiendoSieteController: UIViewController {

    var json:JSON = [] // los datos que recibo desde CalcularRutaController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás", style: .plain, target: nil, action: nil)
        
        actualizarToken()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func actualizarToken() -> Void {
        if json.isEmpty {
            return
        }
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: "Preparando tu dispositivo para recibir notificaciones...")
        
        let parametros: Parameters = [
            "evento": "actualizar_token",
            "id_usr": Util.getUsuario()!["id"].int!,
            "token": Util.getUsuario()!["token"].string ?? self.json["token"].string! // todo en qué momento obtengo el token de firebase?
        ]

        Alamofire.request(Util.urlAdminCtrl, parameters: parametros).response { response in
            if response.error == nil {
                if let resp = String(data: response.data!, encoding: .utf8) {
                    if resp == "exito" {
                        if self.json["tipo"].int == Util.TO_GO {
                            self.buscarCarreraToGo()
                        } else {
                            self.buscarCarrera()
                        }
                    }
                }
            } else {
              Util.mostrarAlerta(titulo: "Error", mensaje: "No se pudo conectar con el servidor.")
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    func buscarCarrera() -> Void {
        if json.isEmpty {
            return
        }
        
        SVProgressHUD.setDefaultMaskType(.black)
        
        let parametros: Parameters = [
            "evento": "buscar_carrera",
            "latInicio": json["latinicio"].double!,
            "lngInicio": json["lnginicio"].double!,
            "latFin": json["latfinal"].double!,
            "lngFin": json["lngfinal"].double!,
            "token": Util.getUsuario()!["token"].string ?? self.json["token"].string!, // todo en qué momento obtengo el token de firebase?
            "id": Util.getUsuario()!["id"].int!,
            "tipo": json["tipo"].int!,
            "tipo_pago": json["tipo_pago"].int!
        ]
        
        Alamofire.request(Util.urlIndexCtrl, parameters: parametros).response { response in
            if response.error == nil {
                
                if let resp = String(data: response.data!, encoding: .utf8) {
                    if resp == "falso" {
                        Util.mostrarAlerta(titulo: "", mensaje: "No se encontró un conductor disponible")
                    } else if let datos = resp.data(using: .utf8, allowLossyConversion: false) {
                        /* fecha_pedido, id_usuario, latinicial, detalle_costo, tipo_pago, turno: id_conductor id_vehiculo estado id tipo fecha_inicio, distancia, lnginicial, lngfinal, costo_final, estado, id, id_turno, latfinal, fecha_confirmacion, id_tipo */
                        let objCarrera = try! JSON(data: datos)
                        self.performSegue(withIdentifier: "CarreraAceptada", sender: objCarrera)
                    }
                }

            } else {
                Util.mostrarAlerta(titulo: "Error", mensaje: "No se pudo conectar con el servidor.")
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    func buscarCarreraToGo() -> Void {
        if json.isEmpty {
            return
        }
        
        SVProgressHUD.setDefaultMaskType(.black)
        
        let parametros: Parameters = [
            "evento": "buscar_carrera_togo",
            "latFin": json["latFin"].double!,
            "lngFin": json["lngFin"].double!,
            "token": Util.getUsuario()!["token"].string ?? self.json["token"].string!, // TODO: en qué momento obtengo el token de firebase?
            "id": Util.getUsuario()!["id"].int!,
            "tipo": json["tipo"].int!,
            "tipo_pago": json["tipo_pago"].int!,
            "productos": json["productos"].arrayObject! // TODO: esto esta bien??
        ]
        
        Alamofire.request(Util.urlIndexCtrl, parameters: parametros).response { response in
            if response.error == nil {
                
                if let resp = String(data: response.data!, encoding: .utf8) {
                    if resp == "falso" {
                        Util.mostrarAlerta(titulo: "", mensaje: "No se encontró un conductor disponible")
                    } else if let datos = resp.data(using: .utf8, allowLossyConversion: false) {
                        /* fecha_pedido, id_usuario, latinicial, detalle_costo, tipo_pago, turno: id_conductor id_vehiculo estado id tipo fecha_inicio, distancia, lnginicial, lngfinal, costo_final, estado, id, id_turno, latfinal, fecha_confirmacion, id_tipo */
                        let objCarrera = try! JSON(data: datos)
                        self.performSegue(withIdentifier: "CarreraToGoAceptada", sender: objCarrera)
                    }
                }
                
            } else {
                Util.mostrarAlerta(titulo: "Error", mensaje: "No se pudo conectar con el servidor.")
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CarreraAceptada" {
            let destinoVC = segue.destination as! EsperandoConductorController
            destinoVC.json = sender as! JSON
        } else if segue.identifier == "CarreraToGoAceptada" {
            let destinoVC = segue.destination as! EsperandoConductorToGoController
            destinoVC.json = sender as! JSON
        }
    }
    
}
