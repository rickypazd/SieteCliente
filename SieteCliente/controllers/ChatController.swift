import Alamofire
import SVProgressHUD
import SwiftyJSON
import UIKit

class ChatController: UIViewController ,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var screenView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tfMensaje: UITextField!
    @IBOutlet var contentView: UIView!
    //    var chat:JSON = []
    var json:JSON = []
    var chat = ["andrea", "beatriz", "zarco", "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."]
    
    var chats: JSON = []
    var containerViewBottomAnchor:NSLayoutConstraint?
    var id_emisor = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* estas 2 lineas son necesarias para que el mensaje y el boton de enviar se pongan encima del teclado cuando éste aparezca */
        containerViewBottomAnchor = contentView.bottomAnchor.constraint(equalTo: screenView.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
        setNavigationBar()
        id_emisor = Util.getUsuario()!["id"].int!
        self.tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi))
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: tableView.bounds.size.width - 8.0)
        self.chats = Util.getChat()!
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
      //scrollToBottom()
        /* hay que estar atentos cuando el teclado se muestre */
        //self.tableView.reloadData()
        observarCuandoElTecladoSeMuestre()
        observarCuandoElTecladoSeOculte()
         NotificationCenter.default.addObserver(self, selector: #selector(notifiMensaje(notification:)), name: .nuevo_mensaje , object: nil)
        
        
    }

    @objc func notifiMensaje(notification: Notification){
        self.chats = Util.getChat()!
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        
    }
    func setNavigationBar() {
        let screenSize: CGRect = UIScreen.main.bounds
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 44))
        let navItem = UINavigationItem(title: "")
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: nil, action: #selector(Atras))
        doneItem.tintColor = UIColor.black
        navItem.leftBarButtonItem = doneItem
        navBar.setItems([navItem], animated: false)
        self.view.addSubview(navBar)
    }
    
    @objc func Atras() { // remove @objc for Swift 3
        dismiss(animated: true, completion: nil)
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

            let mensajeibj = [
                "id_emisor": Util.getUsuario()!["id"].int!,
                "id_receptor": self.json["id"].string!,
                "mensaje" : mensaje
                ] as [String : Any]
            
            self.guardarChat(mensaje: mensajeibj)
            self.tfMensaje.text = ""
            Alamofire.request(Util.urlIndexCtrl, parameters: parametros).response { response in
                if response.error == nil {
                    
                    
            
                } else {
                    Util.mostrarAlerta(titulo: "Hubo un error", mensaje: "No se pudo conectar al servidor.")
                }
            }
        
    }
    
    func guardarChat(mensaje: [String : Any]) {
        // TODO: guardar la lista en UserDefaults
        
        chats.arrayObject?.append(mensaje)
        // TODO: agregar el mensaje a la lista en JSON
        // TODO: creo que esto va a fallar
        Util.setChat(chat: chats.arrayObject)
        
        self.chats = Util.getChat()!
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
       // self.chat = Util.getChat()?.arrayValue
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.contentInset = UIEdgeInsets(top: 0,left: 0,bottom: 55,right: 0)
    }
    



    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        headerView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
        self.tableView.tableFooterView = headerView
        return headerView
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = (self.chats.count-indexPath.section)-1
          if chats[index]["id_emisor"].int != id_emisor {
            let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath) as! ChatCell
            
            cell.lbMensaje.text = "  \(chats[index]["mensaje"].string!)"
            cell.lbMensaje.layer.cornerRadius = 5
            cell.lbMensaje.clipsToBounds = true
            cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "chatEmisorCell", for: indexPath) as! ChatEmisorCell
            
         cell.lbMensaje.text = "  \(chats[index]["mensaje"].string!)"
            cell.lbMensaje.layer.cornerRadius = 5
            cell.lbMensaje.clipsToBounds = true
            cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
            return cell
        }
    }
    

}
extension Notification.Name{
    static let nuevo_mensaje = Notification.Name(rawValue: "nuevo_mensaje")
}
