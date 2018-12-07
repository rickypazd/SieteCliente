import Alamofire
import UIKit
import SVProgressHUD
import SwiftyJSON

class PerfilClienteController: UIViewController {
    
    @IBOutlet weak var imgPerfil: UIImageView!
    @IBOutlet weak var lbCreditos: UILabel!
    @IBOutlet weak var lbNombre: UILabel!
    @IBOutlet weak var lbApellido: UILabel!
    @IBOutlet weak var lbTelefono: UILabel!
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var contentImageView: UICustomView!
    @IBOutlet weak var contentViewCreditos: UIView!
    
    let TAG_NOMBRE = 1
    let TAG_APELLIDOS = 2
    let TAG_TELEFONO = 3
    let TAG_CORREO = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var colors = [UIColor]()
        colors.append(UIColor(red: 119/255, green: 65/255, blue: 185/255, alpha: 1))
        colors.append(UIColor(red: 244/255, green: 53/255, blue: 69/255, alpha: 1))
        navigationController?.navigationBar.setGradientBackground(colors: colors)
        navigationItem.title = "Mi perfil"
        let usuario = Util.getUsuario()
        
        if usuario != nil {
            obtenerPerfil()
            
            self.lbNombre.text = usuario!["nombre"].stringValue
            self.lbApellido.text = "\(usuario!["apellido_pa"].string!) \(usuario!["apellido_ma"].string!)"
            self.lbTelefono.text = usuario!["telefono"].string
            self.lbEmail.text = usuario!["correo"].string
        }
        
    }
    
    func obtenerPerfil() {
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: "Obteniendo tu perfil...")
        
        let parametros: Parameters = [
            "evento": "get_usuario",
            "id": Util.getUsuario()!["id"].int!
        ]
        
        Alamofire.request(Util.urlIndexCtrl, parameters: parametros).responseJSON {
            response in
            
            switch response.result {
            case .success:
                let respuesta = JSON(response.data!)
                
                if respuesta["exito"].string == "si" {
                    Util.setUsuario(usuario: respuesta.dictionaryObject!)
                }
                
                if let creditos = respuesta["creditos"].double {
                    self.lbCreditos.text = "\(creditos)"
                }
                
                if let fotoPerfil = respuesta["id_face"].string {
                  
                    
                    //let facebookProfileUrl = "http://graph.facebook.com/\(fotoPerfil)/picture?type=large"
                    let url = NSURL(string: "https://graph.facebook.com/\(fotoPerfil)/picture?type=large&return_ssl_resources=1")
                    self.imgPerfil.image = UIImage(data: NSData(contentsOf: url! as URL)! as Data)
                }
             
                break
                
            case .failure:
                Util.mostrarAlerta(titulo: "Error", mensaje: "No se pudo conectar con el servidor.")
                break
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    func obtenerFotoDePerfil(url:String) {
        Alamofire.request(url).responseData { response in
            if let datos = response.result.value {
                let imagen = UIImage(data: datos)
                
                DispatchQueue.main.async {
                    self.imgPerfil.image = imagen
                }
            }
        }
    }
    
    @IBAction func cambiarCampo(_ sender: UIButton) {
        switch sender.tag {
        case TAG_NOMBRE:
            mostrarAlerta(campo: "nombre", valor: Util.getUsuario()!["nombre"].string!)
            break
            
        case TAG_APELLIDOS:
            mostrarAlertaApellidos(primerApellido: Util.getUsuario()!["apellido_pa"].string!, segundoApellido: Util.getUsuario()!["apellido_ma"].string!)
            break
            
        case TAG_TELEFONO:
            mostrarAlerta(campo: "teléfono", valor: Util.getUsuario()!["telefono"].string!)
            break
            
        case TAG_CORREO:
            mostrarAlerta(campo: "correo", valor: Util.getUsuario()!["correo"].string!)
            break
            
        default:
            break
        }
    }
    
    /* una alerta con un sólo campo de texto */
    func mostrarAlerta(campo:String, valor:String) {
        let alerta = UIAlertController(title: "Cambiar \(campo)", message: "", preferredStyle: .alert)
        
        alerta.addTextField { (textField) in
            textField.placeholder = "Introduzca su \(campo)"
            textField.text = valor
        }
        
        let accionOk = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            let nuevoValor = alerta.textFields?.first?.text!
            print(nuevoValor!)
            
            self.actualizarPerfil(campo: campo, valor: nuevoValor!, segundoValor: "")
            
            alerta.dismiss(animated: true, completion: nil)
        })
        let accionCancelar = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
        
        alerta.addAction(accionCancelar)
        alerta.addAction(accionOk)
        
        UIApplication.topViewController()?.present(alerta, animated: true, completion: nil)
    }
    
    /* una alerta con 2 campos de texto, para cambiar los apellidos */
    func mostrarAlertaApellidos(primerApellido:String, segundoApellido:String) {
        let alerta = UIAlertController(title: "Cambiar apellido", message: "", preferredStyle: .alert)
        
        alerta.addTextField { (textField) in
            textField.placeholder = "Apellido paterno"
            textField.text = primerApellido
        }
        
        alerta.addTextField { (textField) in
            textField.placeholder = "Apellido materno"
            textField.text = segundoApellido
        }
        
        let accionOk = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            let primerApellido = alerta.textFields?.first?.text!
            let segundoApellido = alerta.textFields![1].text!
            
            self.actualizarPerfil(campo: "apellido", valor: primerApellido!, segundoValor: segundoApellido)
            
            alerta.dismiss(animated: true, completion: nil)
        })
        let accionCancelar = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
        
        alerta.addAction(accionCancelar)
        alerta.addAction(accionOk)
        
        UIApplication.topViewController()?.present(alerta, animated: true, completion: nil)
    }
    
    func actualizarPerfil(campo:String, valor:String, segundoValor:String?) {
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: "Actualizando tu perfil...")

        let parametros: Parameters = [
            "evento": "editar_perfil_cliente",
            "id_usuario": Util.getUsuario()!["id"].int!,
            "nombre": campo == "nombre" ? valor : Util.getUsuario()!["nombre"].string!,
            "apellido_pa": campo == "apellido" ? valor : Util.getUsuario()!["apellido_pa"].string!,
            "apellido_ma": campo == "apellido" ? segundoValor! : Util.getUsuario()!["apellido_ma"].string!,
            "telefono": campo == "telefono" ? valor : Util.getUsuario()!["telefono"].string!,
            "correo": campo == "correo" ? valor : Util.getUsuario()!["correo"].string!
        ]
        
        Alamofire.request(Util.urlAdminCtrl, parameters: parametros).response { response in
            if response.error == nil {
                if let resp = String(data: response.data!, encoding: .utf8) {
                    if resp == "exito" {
                        self.actualizarCampoDeTexto(campo: campo, valor: valor, segundoValor: segundoValor)
                    } else {
                        Util.mostrarAlerta(titulo: "", mensaje: "Hubo un error al actualizar tu perfil.")
                    }
                }
            } else {
                Util.mostrarAlerta(titulo: "Error", mensaje: "No se pudo conectar con el servidor.")
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    /* actualiza el campo en la vista */
    func actualizarCampoDeTexto(campo:String, valor:String, segundoValor:String?) {
        var usuario = Util.getUsuario()
        
        switch campo {
        case "nombre":
            usuario!["nombre"].string = valor
            self.lbNombre.text = valor
            break
            
        case "apellido":
            usuario!["apellido_pa"].string = valor
            usuario!["apellido_ma"].string = segundoValor
            self.lbApellido.text = "\(valor) \(segundoValor!)"
            break
            
        case "telefono":
            usuario!["telefono"].string = valor
            self.lbTelefono.text = "\(valor)"
            break
            
        case "correo":
            usuario!["correo"].string = valor
            self.lbEmail.text = "\(valor)"
            break
            
        default:
            break
        }
        
        Util.setUsuario(usuario: usuario!.dictionaryObject)
    }
    
}
