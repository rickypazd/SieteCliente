import SwiftyJSON
import UIKit

class PedidosToGoController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var lista:JSON = []
    
     var listaProductos: JSON!
    var btn_productos:UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        var colors = [UIColor]()
        colors.append(UIColor(red: 119/255, green: 65/255, blue: 185/255, alpha: 1))
        colors.append(UIColor(red: 244/255, green: 53/255, blue: 69/255, alpha: 1))
        navigationController?.navigationBar.setGradientBackground(colors: colors)

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
    
    @IBAction func addproducto(_ sender: Any) {
        mostrarAlerta(nuevoPedido: true, indice: nil)

    }
    func mostrarAlerta(nuevoPedido:Bool, indice:Int?) {
        let alerta = UIAlertController(title: nuevoPedido ? "Agregar pedido" : "Editar pedido", message: "", preferredStyle: .alert)
        alerta.view.backgroundColor = UIColor.init(red: 93, green: 56, blue: 148)
        alerta.view.layer.opacity = 1
        alerta.view.isOpaque = true
        alerta.view.layer.cornerRadius =  15
        
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
            textField.keyboardType = UIKeyboardType.numberPad
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
        self.btn_productos.setTitle("Productos ( "+String(lista.count)+" )", for: .normal)
        self.listaProductos = lista
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
        self.btn_productos.setTitle("Productos ( "+String(lista.count)+" )", for: .normal)
        self.listaProductos = lista
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
        self.btn_productos.setTitle("Productos ( "+String(lista.count)+" )", for: .normal)
        return cell
    }
    
    @objc func editarPedido(_ sender: UIButton) {
        mostrarAlerta(nuevoPedido: false, indice: sender.tag)
    }
    
    @objc func eliminarPedido(_ sender: UIButton) {
        lista.arrayObject!.remove(at: sender.tag)
        Util.setPedidos(pedidos: lista.arrayObject)
         self.btn_productos.setTitle("Productos ( "+String(lista.count)+" )", for: .normal)
        self.listaProductos = lista
        tableView.reloadData()
    }

}
