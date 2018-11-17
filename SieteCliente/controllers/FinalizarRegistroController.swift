import Alamofire
import UIKit
import SwiftyJSON
import SVProgressHUD
import DatePickerDialog
import SwiftHash

class FinalizarRegistroController: UIViewController {
    
    @IBOutlet weak var tfFechaNacimiento: UITextField!
    @IBOutlet weak var tfUsuario: UITextField!
    @IBOutlet weak var tfClave: UITextField!
    @IBOutlet weak var tfCorreo: UITextField!
    var json:JSON = []
    var estaIngresandoConFb:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if json["correo"].string != nil {
            tfCorreo.text = json["correo"].string
        }
        
        if estaIngresandoConFb {
            tfUsuario.isEnabled = false
            tfClave.isUserInteractionEnabled = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func validarCampos(_ sender: Any) {
        let fechaNacimiento = tfFechaNacimiento.text!
        let usuario = tfUsuario.text!
        let clave = tfClave.text!
        let correo = tfCorreo.text!
        
        if !estaIngresandoConFb && fechaNacimiento.isEmpty {
            Util.mostrarAlerta(titulo: "Hubo un error!", mensaje: "La fecha de nacimiento no puede estar vacía.")
            return
        }
        
        if !estaIngresandoConFb && usuario.isEmpty {
            Util.mostrarAlerta(titulo: "Hubo un error!", mensaje: "El nombre de usuario no puede estar vacío.")
            return
        }
        
        if !estaIngresandoConFb && clave.isEmpty {
            Util.mostrarAlerta(titulo: "Hubo un error!", mensaje: "La contraseña no puede estar vacía.")
            return
        }
        
        if correo.isEmpty {
            Util.mostrarAlerta(titulo: "Hubo un error!", mensaje: "El correo no puede estar vacío.")
            return
        }
        
        finalizarRegistro(fechaNacimiento: fechaNacimiento, usuario: usuario, clave: clave, correo: correo)
    }
    
    func finalizarRegistro(fechaNacimiento:String, usuario:String, clave:String, correo:String) {
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: "Registrando cuenta...")
        
        var parametros:Parameters = [
            "evento": "registrar_usuario_cliente",
            "nombre": json["nombre"],
            "apellido_pa": json["apellidoPaterno"],
            "apellido_ma": json["apellidoMaterno"],
            "telefono": json["telefono"],
            "sexo": json["sexo"],
            "fecha": fechaNacimiento,
            "usuario": usuario,
            "pass": MD5(clave).lowercased(),
            "correo": correo
        ]
        
        if estaIngresandoConFb {
            parametros = [
                "evento": "registrar_usuario_face",
                "id": json["id"].string!,
                "nombre": json["nombre"],
                "apellidos": "\(json["apellidoPaterno"]) \(json["apellidoMaterno"])",
                "telefonos": json["telefono"],
                "Sexo": json["sexo"],
                "correo": correo
            ]
            
            Alamofire.request(Util.urlAdminCtrl, parameters: parametros).response { response in
                if let data = response.data, let idGenerado = String(data: data, encoding: .utf8) {
                    if idGenerado != "falso" {
                        let respuesta = JSON(response.data!)
                        
                        if respuesta["exito"].string == "si" {
                            Util.setUsuario(usuario: respuesta.dictionaryObject!)
                            
                            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarMainController") as! TabBarMainController
                            viewController.selectedViewController = viewController.viewControllers?[1]
                            self.present(viewController, animated: true, completion: nil)
                        } else {
                            Util.mostrarAlerta(titulo: "Hubo un error", mensaje: "No se pudo registrar el usuario.")
                        }
                        
                        SVProgressHUD.dismiss()
                    }
                } else {
                    Util.mostrarAlerta(titulo: "Hubo un error", mensaje: "Parece que no hay una conexión.")
                    SVProgressHUD.dismiss()
                }
            }
        } else {
            Alamofire.request(Util.urlAdminCtrl, parameters: parametros).response { response in
                if let data = response.data, let idGenerado = String(data: data, encoding: .utf8) {
                    if idGenerado != "falso" {
                        let usuario = [
                            "id" : idGenerado,
                            "nombre" : self.json["nombre"].string!,
                            "apellido_pa" : self.json["apellidoPaterno"].string!,
                            "apellido_ma" : self.json["apellidoMaterno"].string!,
                            "usuario" : usuario,
                            "sexo" : self.json["sexo"].string!,
                            "fecha_nac" : fechaNacimiento,
                            "telefono" : self.json["telefono"].string!,
                            "correo" : correo,
                            "creditos" : 0,
                            "exito": "si"
                            ] as [String : Any]
                        
                        Util.setUsuario(usuario: usuario)
                        
                        let inicioVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarMainController") as! TabBarMainController
                        self.present(inicioVC, animated: true, completion: nil)
                        
                        SVProgressHUD.dismiss()
                    }
                } else {
                    Util.mostrarAlerta(titulo: "Hubo un error", mensaje: "Parece que no hay una conexión.")
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    func finalizarRegistroNormal(parametros: Parameters) {
        
    }
    
    func finalizarRegistroConFb(parametros: Parameters) {
        
    }
    
    @IBAction func mostrarDatePicker(_ sender: Any) {
        DatePickerDialog(locale: Locale(identifier: "es_BO")).show("Seleccione su fecha de nacimiento", doneButtonTitle: "Listo", cancelButtonTitle: "Cancelar", datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                self.tfFechaNacimiento.text = formatter.string(from: dt)
            }
        }
    }
    
    /* estoy sobreescribiendo este metodo para que el teclado se oculte si toco algo que no sea un campo de texto */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
