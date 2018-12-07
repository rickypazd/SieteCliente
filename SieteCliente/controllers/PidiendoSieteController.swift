import Alamofire
import SVProgressHUD
import SwiftyJSON
import UIKit

class PidiendoSieteController: UIViewController {

    var json:JSON = [] // los datos que recibo desde CalcularRutaController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás", style: .plain, target: nil, action: nil)
        
        actualizarToken()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás", style: .plain, target: nil, action: nil)
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás", style: .plain, target: nil, action: nil)
        self.navigationController?.isNavigationBarHidden = false
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
            "token": Util.getToken()! 
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
            "token": Util.getToken()!,// todo en qué momento obtengo el token de firebase?
            "id": Util.getUsuario()!["id"].int!,
            "tipo": json["tipo"].int!,
            "tipo_pago": json["tipo_pago"].int!
        ]
        
        Alamofire.request(Util.urlIndexCtrl, parameters: parametros).response { response in
            if response.error == nil {
                
                if let resp = String(data: response.data!, encoding: .utf8) {
                    if resp == "falso" {
                      //  Util.mostrarAlerta(titulo: "", mensaje: "")
                        let alerta = UIAlertController(title: "", message: "No se encontró un conductor disponible", preferredStyle: .alert)
                        alerta.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                            alerta.dismiss(animated: true, completion: nil)
                            self.navigationController?.isNavigationBarHidden = false
                            self.tabBarController?.tabBar.isHidden = false;
                            self.navigationController?.popViewController(animated: true)
                        }))
                        
                        UIApplication.topViewController()?.present(alerta, animated: true, completion: nil)
                        
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
            "token": Util.getToken()!,
            "id": Util.getUsuario()!["id"].int!,
            "tipo": json["tipo"].int!,
            "tipo_pago": json["tipo_pago"].int!,
            "productos": json["productos"].arrayObject! // TODO: esto esta bien??
        ]
        
        Alamofire.request(Util.urlIndexCtrl, parameters: parametros).response { response in
            if response.error == nil {
                
                if let resp = String(data: response.data!, encoding: .utf8) {
                    if resp == "falso" {
                        //  Util.mostrarAlerta(titulo: "", mensaje: "")
                        let alerta = UIAlertController(title: "", message: "No se encontró un conductor disponible", preferredStyle: .alert)
                        alerta.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                            alerta.dismiss(animated: true, completion: nil)
                            self.navigationController?.isNavigationBarHidden = false
                            self.tabBarController?.tabBar.isHidden = false;
                            self.navigationController?.popViewController(animated: true)
                        }))
                        
                        UIApplication.topViewController()?.present(alerta, animated: true, completion: nil)
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
