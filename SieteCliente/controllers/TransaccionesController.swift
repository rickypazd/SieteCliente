import Alamofire
import UIKit
import SVProgressHUD
import SwiftyJSON
import MaterialComponents

class TransaccionesController: UIViewController {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var transacciones:[JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: "Cargando transacciones")
        
        let parametros: Parameters = [
            "evento": "get_transacciones_id",
            "id": Util.getUsuario()!["id"]
        ]
        
        Alamofire.request(Util.urlAdminCtrl, parameters: parametros).responseJSON {
            response in
            
            let transacciones = JSON(response.data!)
            self.transacciones = transacciones.array!
            
            self.tableView.reloadData()
            
            SVProgressHUD.dismiss()
        }
    }
    
}

extension TransaccionesController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return transacciones.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TransaccionesTableViewCell

        let indice = indexPath.row
        let transaccion = transacciones[indice]

        cell.lbFecha.text = transaccion["fecha"].string
        cell.lbMonto.text =  "bs. \(String(format: "%.2f", transaccion["cantidad"].double!))"
        cell.lbTipo.text = transaccion["tipo_nombre"].string

        cell.layer.cornerRadius = 5

        return cell
    }
    
}
