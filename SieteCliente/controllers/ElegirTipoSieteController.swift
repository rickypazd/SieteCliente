import UIKit

class ElegirTipoSieteController: UIViewController {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var btnSiete: UIButton!
    @IBOutlet weak var btnSuperSiete: UIButton!
    @IBOutlet weak var btnSieteMaravilla: UIButton!
    @IBOutlet weak var btnSieteToGo: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var colors = [UIColor]()
        colors.append(UIColor(red: 119/255, green: 65/255, blue: 185/255, alpha: 1))
        colors.append(UIColor(red: 244/255, green: 53/255, blue: 69/255, alpha: 1))
        navigationController?.navigationBar.setGradientBackground(colors: colors)
        navigationItem.title = "Tipos de siete"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás", style: .plain, target: nil, action: nil)
         
        let ancho = contentView.bounds.size.width / 2
      
        var alto = contentView.bounds.size.height / 2
          alto -= alto*0.15
        btnSiete.frame = CGRect(x: 0, y: 0, width: ancho, height: alto)
        btnSuperSiete.frame = CGRect(x: ancho, y: 0, width: ancho, height: alto)
        btnSieteMaravilla.frame = CGRect(x: 0, y: alto, width: ancho, height: alto)
        btnSieteToGo.frame = CGRect(x: ancho, y: alto, width: ancho, height: alto)
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás", style: .plain, target: nil, action: nil)
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás", style: .plain, target: nil, action: nil)
        self.navigationController?.isNavigationBarHidden = false
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
