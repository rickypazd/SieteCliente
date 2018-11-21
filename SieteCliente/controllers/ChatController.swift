import Alamofire
import SVProgressHUD
import SwiftyJSON
import UIKit

class ChatController: UIViewController {

    @IBOutlet var screenView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tfMensaje: UITextField!
    @IBOutlet var contentView: UIView!
//    var chat:JSON = []
    var json:JSON = []
    var chat = ["andrea", "beatriz", "zarco", "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."]
    var containerViewBottomAnchor:NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* estas 2 lineas son necesarias para que el mensaje y el boton de enviar se pongan encima del teclado cuando éste aparezca */
        containerViewBottomAnchor = contentView.bottomAnchor.constraint(equalTo: screenView.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
        
        /* hay que estar atentos cuando el teclado se muestre */
        observarCuandoElTecladoSeMuestre()
        observarCuandoElTecladoSeOculte()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func observarCuandoElTecladoSeMuestre() {
//        NotificationCenter.default.addObserver(self, selector: #selector(UIView.keyboardWillChange(_:)), name:
//            UIApplication.keyboardWillChangeFrameNotification
//            , object: nil)
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(elTecladoSeEstaMostrando(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func elTecladoSeEstaMostrando(notification: NSNotification) {
        let keyboardFrame: NSValue = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)!
        
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        /* reduzco la parte inferior de la vista con el alto del teclado*/
        containerViewBottomAnchor?.constant = -keyboardHeight
    }
    
    func observarCuandoElTecladoSeOculte() {
          let center2 = NotificationCenter.default
        center2.addObserver(self, selector: #selector(elTecladoSeEstaOcultando(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func elTecladoSeEstaOcultando(notification: NSNotification) {
        containerViewBottomAnchor?.constant = 0
    }

    @IBAction func enviarMensaje(_ sender: Any) {
        let mensaje = tfMensaje.text!
        
        if mensaje.isEmpty {
            return
        }
        
        let parametros: Parameters = [
            "evento": "enviar_mensaje",
            "id_emisor": Util.getUsuario()!["id"].int!,
            "id_receptor": json["id"].string!,
            "mensaje": mensaje
        ]
        
        Alamofire.request(Util.urlAdminCtrl, parameters: parametros).response { response in
            if response.error == nil {
                self.tfMensaje.text = ""
                
                let mensaje = [
                    "id_emisor": Util.getUsuario()!["id"].int!,
                    "id_receptor": self.json["id"].string!,
                    "mensaje" : mensaje
                ] as [String : Any]
                
                self.guardarChat(mensaje: mensaje)
            } else {
                Util.mostrarAlerta(titulo: "Hubo un error", mensaje: "No se pudo conectar al servidor.")
            }
        }
    }
    
    func guardarChat(mensaje: [String : Any]) {
        // TODO: guardar la lista en UserDefaults
        
        let chat = Util.getChat()
        // TODO: agregar el mensaje a la lista en JSON
        
        // TODO: creo que esto va a fallar
        Util.setChat(chat: chat!.dictionaryObject)
    }
    
}

extension ChatController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return chat.count
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
        if indexPath.section % 2 == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatCell
            
            cell.lbMensaje.text = "  \(chat[indexPath.section])"
            cell.lbMensaje.layer.cornerRadius = 5
            cell.lbMensaje.clipsToBounds = true

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "chatEmisorCell", for: indexPath) as! ChatEmisorCell
            
            cell.lbMensaje.text = "\(chat[indexPath.section])  "
            cell.lbMensaje.layer.cornerRadius = 5
            cell.lbMensaje.clipsToBounds = true

            return cell
        }
    }
    
    
}
