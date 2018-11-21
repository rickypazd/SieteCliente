import UIKit

class OpcionesController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        var colors = [UIColor]()
        colors.append(UIColor(red: 119/255, green: 65/255, blue: 185/255, alpha: 1))
        colors.append(UIColor(red: 244/255, green: 53/255, blue: 69/255, alpha: 1))
        navigationController?.navigationBar.setGradientBackground(colors: colors)

        navigationItem.title = "Opciones"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás", style: .plain, target: nil, action: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func confirmarCerrarSesion(_ sender: Any) {
        let alerta = UIAlertController(title: "Desea cerrar su sesión?", message: "",  preferredStyle: .alert)
        
        let accionOk = UIAlertAction(title: "Si", style: .default, handler: { (action) in
            self.cerrarSesion()
            
            alerta.dismiss(animated: true, completion: nil)
        })
        let accionCancelar = UIAlertAction(title: "No", style: .default, handler: nil)
        
        alerta.addAction(accionCancelar)
        alerta.addAction(accionOk)
        
        UIApplication.topViewController()?.present(alerta, animated: true, completion: nil)
    }
    
    func cerrarSesion() {
        Util.setUsuario(usuario: nil)
        
        let inicioVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainNavigationController") as! MainNavigationController
        self.present(inicioVC, animated: false, completion: nil)    }
    
}
