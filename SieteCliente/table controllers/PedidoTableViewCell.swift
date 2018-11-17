import UIKit

class PedidoTableViewCell: UITableViewCell {

    @IBOutlet weak var lbProducto: UILabel!
    @IBOutlet weak var lbDescripcion: UILabel!
    @IBOutlet weak var btnEditar: UIButton!
    @IBOutlet weak var btnEliminar: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
