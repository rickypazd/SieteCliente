import Alamofire
import DLRadioButton
import SwiftyJSON
import UIKit

class RegistrarController: UIViewController {
    
    var usuarioFb:JSON = [] // los datos que recibo desde IniciarSesion (de facebook)
    @IBOutlet weak var tfNombre: UITextField!
    @IBOutlet weak var tfApellidoPaterno: UITextField!
    @IBOutlet weak var tfApellidoMaterno: UITextField!
    @IBOutlet weak var tfTelefono: UITextField!
    @IBOutlet weak var btnCrearCuenta: UIButton!
    @IBOutlet weak var radioHombre: DLRadioButton!
    @IBOutlet weak var radioMujer: DLRadioButton!
    var estaIngresandoConFb:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás", style: .plain, target: nil, action: nil)
        
        if usuarioFb["first_name"].string != nil {
            tfNombre.text = usuarioFb["first_name"].string!
        }
        
        if usuarioFb["last_name"].string != nil {
            tfApellidoPaterno.text = usuarioFb["last_name"].string!
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func validarCampos(_ sender: Any) {
        let nombre = tfNombre.text
        let apellidoPaterno = tfApellidoPaterno.text
        let apellidoMaterno = tfApellidoMaterno.text
        let telefono = tfTelefono.text
        var sexo = radioHombre.isSelected ? "Hombre" : (radioMujer.isSelected ? "Mujer" : "")
        
        if (nombre?.isEmpty)! {
            Util.mostrarAlerta(titulo: "Hubo un error!", mensaje: "Debe ingresar su nombre.")
            return
        }
        
        if (apellidoPaterno?.isEmpty)! {
            Util.mostrarAlerta(titulo: "Hubo un error!", mensaje: "El apellido paterno requerido.")
            return
        }
        
        if (telefono?.isEmpty)! {
            Util.mostrarAlerta(titulo: "Hubo un error!", mensaje: "El teléfono es obligatorio.")
            return
        }
        
        if sexo.isEmpty {
            //Util.mostrarAlerta(titulo: "Hubo un error!", mensaje: "Debe seleccionar un género.")
            sexo = "null"
            //return
        }
        
        crearCuenta(nombre: nombre!, apellidoPaterno: apellidoPaterno!, apellidoMaterno: apellidoMaterno!, telefono: telefono!, genero: sexo)
    }
    
    func crearCuenta(nombre: String, apellidoPaterno: String, apellidoMaterno: String, telefono: String, genero: String) {
        let json:JSON = [
            "id": usuarioFb["id"].string ?? "",
            "nombre": nombre,
            "apellidoPaterno": apellidoPaterno,
            "apellidoMaterno": apellidoMaterno,
            "telefono": telefono,
            "sexo": genero,
            "correo": usuarioFb["email"].string ?? "",
            "fechaNacimiento": usuarioFb["birthday"].string ?? ""
        ]
        
        performSegue(withIdentifier: "CompletarRegistro", sender: json)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CompletarRegistro" {
            let destinoVC = segue.destination as! FinalizarRegistroController
            destinoVC.json = sender as! JSON
            if estaIngresandoConFb {
                destinoVC.estaIngresandoConFb = true
            }
        }
    }
    
    /* estoy sobreescribiendo este metodo para que el teclado se oculte si toco algo que no sea un campo de texto */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
