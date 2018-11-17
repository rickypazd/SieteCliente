import SwiftyJSON
import UIKit

class PedidosToGoController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var lista:JSON = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lista = Util.getPedidos()!
        
        let btnAgregarPedido = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(agregarPedido))
        self.navigationItem.rightBarButtonItem = btnAgregarPedido
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func agregarPedido() {
        mostrarAlerta(nuevoPedido: true, indice: nil)
    }
    
    func mostrarAlerta(nuevoPedido:Bool, indice:Int?) {
        let alerta = UIAlertController(title: nuevoPedido ? "Agregar pedido" : "Editar pedido", message: "", preferredStyle: .alert)
        
        alerta.addTextField { (textField) in
            textField.placeholder = "Producto"
            textField.text = nuevoPedido ? "" : self.lista[indice!]["producto"].string
        }
        
        alerta.addTextField { (textField) in
            textField.placeholder = "Descripción"
            textField.text = nuevoPedido ? "" : self.lista[indice!]["descripcion"].string
        }
        
        alerta.addTextField { (textField) in
            textField.placeholder = "Cantidad"
            textField.text = nuevoPedido ? "" : self.lista[indice!]["cantidad"].string
        }
        
        let accionOk = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            let producto = alerta.textFields?.first?.text!
            let descripcion = alerta.textFields![1].text!
            let cantidad = alerta.textFields![2].text!
            
            if nuevoPedido {
                self.agregarNuevoPedido(producto: producto!, descripcion: descripcion, cantidad: cantidad)
            } else {
                self.actualizarPedido(indice: indice!, producto: producto!, descripcion: descripcion, cantidad: cantidad)
            }
            
            alerta.dismiss(animated: true, completion: nil)
        })
        let accionCancelar = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
        
        alerta.addAction(accionCancelar)
        alerta.addAction(accionOk)
        
        UIApplication.topViewController()?.present(alerta, animated: true, completion: nil)
    }
    
    func agregarNuevoPedido(producto:String, descripcion:String, cantidad:String) {
        let nuevoItem = [
            "producto" : producto,
            "descripcion" : descripcion,
            "cantidad" : cantidad,
            ] as [String : String]

        lista.arrayObject?.append(nuevoItem)
        Util.setPedidos(pedidos: lista.arrayObject)

        tableView.reloadData()
    }
    
    func actualizarPedido(indice:Int, producto:String, descripcion:String, cantidad:String) {
        let nuevoItem = [
            "producto" : producto,
            "descripcion" : descripcion,
            "cantidad" : cantidad,
            ] as [String : String]
        
        lista.arrayObject![indice] = nuevoItem
        Util.setPedidos(pedidos: lista.arrayObject)

        tableView.reloadData()
    }
    
}

extension PedidosToGoController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lista.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pedidoCell", for: indexPath) as! PedidoTableViewCell
        
        cell.btnEditar.tag = indexPath.row
        cell.btnEditar.addTarget(self, action: #selector(self.editarPedido(_:)), for: .touchUpInside)
        
        cell.btnEliminar.tag = indexPath.row
        cell.btnEliminar.addTarget(self, action: #selector(self.eliminarPedido(_:)), for: .touchUpInside)
        
        cell.lbProducto.text = "\(lista[indexPath.row]["cantidad"].string!) \(lista[indexPath.row]["producto"].string!)"
        cell.lbDescripcion.text = lista[indexPath.row]["descripcion"].string
        
        return cell
    }
    
    @objc func editarPedido(_ sender: UIButton) {
        mostrarAlerta(nuevoPedido: false, indice: sender.tag)
    }
    
    @objc func eliminarPedido(_ sender: UIButton) {
        lista.arrayObject!.remove(at: sender.tag)
        Util.setPedidos(pedidos: lista.arrayObject)
        
        tableView.reloadData()
    }

}
