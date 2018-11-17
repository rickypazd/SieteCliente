import UIKit

class ElegirTipoSieteController: UIViewController {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var btnSiete: UIButton!
    @IBOutlet weak var btnSuperSiete: UIButton!
    @IBOutlet weak var btnSieteMaravilla: UIButton!
    @IBOutlet weak var btnSieteToGo: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 142, green: 85, blue: 131)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás", style: .plain, target: nil, action: nil)
        
        let ancho = contentView.bounds.size.width / 2
        let alto = contentView.bounds.size.height / 2
        
        btnSiete.frame = CGRect(x: 0, y: 0, width: ancho, height: alto)
        btnSuperSiete.frame = CGRect(x: ancho, y: 0, width: ancho, height: alto)
        btnSieteMaravilla.frame = CGRect(x: 0, y: alto, width: ancho, height: alto)
        btnSieteToGo.frame = CGRect(x: ancho, y: alto, width: ancho, height: alto)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func elegirSiete2(_ sender: Any) {
        performSegue(withIdentifier: "TipoSieteSeleccionado", sender: Util.ESTANDAR)
    }
    
    @IBAction func elegirSuperSiete2(_ sender: Any) {
        performSegue(withIdentifier: "TipoSieteSeleccionado", sender: Util.SUPER_7)
    }
    
    @IBAction func elegirSieteMaravilla2(_ sender: Any) {
        performSegue(withIdentifier: "TipoSieteSeleccionado", sender: Util.MARAVILLA)
    }
    
//    @IBAction func elegirSieteToGo2(_ sender: Any) {
//        performSegue(withIdentifier: "TipoSieteSeleccionado", sender: Util.TO_GO)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TipoSieteSeleccionado" {
            let destinoVC = segue.destination as! PrincipalController
            destinoVC.tipoCarrera = sender as! Int
        }
    }
    
}
