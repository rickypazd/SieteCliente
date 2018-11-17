import Foundation
import UIKit
import SwiftyJSON

/* acá se tienen métodos para usarlos en toda la app, el equivalente a SharedPreferences en android es UserDefaults */
class Util {
    
//    static let urlIndexCtrl:String = "http://192.168.0.11:8080/siete/indexController"
//    static let urlAdminCtrl:String = "http://192.168.0.11:8080/siete/admin/adminController"
    static let urlIndexCtrl:String = "http://204.93.196.61:8080/sietePrueva/indexController"
    static let urlAdminCtrl:String = "http://204.93.196.61:8080/sietePrueva/admin/adminController"
    static let urlFoto:String = "http://204.93.196.61:8080/sietePrueva/"
    
    /* TIPOS DE CARRERA */
    static let ESTANDAR = 1
    static let TO_GO = 2
    static let MARAVILLA = 3
    static let SUPER_7 = 4
    static let TIPO_4X4 = 5
    static let CAMIONETA = 6
    static let TIPO_3_FILAS = 7
    
    private static let KEY_USUARIO = "usuario"
    private static let KEY_CHAT = "chat"
    private static let KEY_PEDIDOS = "pedidos"
    
    class func getUsuario() -> JSON? {
        let usuario = UserDefaults.standard.dictionary(forKey: KEY_USUARIO)
        
        if usuario == nil {
            return nil
        }
        
        return JSON(usuario!)
    }
    
    class func setUsuario(usuario:Any?) {
        if usuario == nil {
            UserDefaults.standard.removeObject(forKey: KEY_USUARIO)
            return
        }
        
        UserDefaults.standard.setValue(usuario, forKey: KEY_USUARIO)
    }
    
    class func getChat() -> JSON? {
        let chat = UserDefaults.standard.array(forKey: KEY_CHAT)
        
        if chat == nil {
            return []
        }
        
        return JSON(chat!)
    }
    
    class func setChat(chat:Any?) {
        if chat == nil {
            UserDefaults.standard.removeObject(forKey: KEY_CHAT)
            return
        }
        
        UserDefaults.standard.setValue(chat, forKey: KEY_CHAT)
    }
    
    class func getPedidos() -> JSON? {
        let pedidos = UserDefaults.standard.array(forKey: KEY_PEDIDOS)
        
        if pedidos == nil {
            return []
        }
        
        return JSON(pedidos!)
    }
    
    class func setPedidos(pedidos:Any?) {
        if pedidos == nil {
            UserDefaults.standard.removeObject(forKey: KEY_PEDIDOS)
            return
        }
        
        UserDefaults.standard.setValue(pedidos, forKey: KEY_PEDIDOS)
    }
    
    class func getTipoCarrera(tipo:Int) -> String {
        switch tipo {
        case ESTANDAR:
            return "Siete estándar"
        case TO_GO:
            return "Siete TOGO"
        case MARAVILLA:
            return "Siete maravilla"
        case SUPER_7:
            return "Super siete"
        case TIPO_4X4:
            return "Siete 4x4"
        case CAMIONETA:
            return "Siete camioneta"
        case TIPO_3_FILAS:
            return "Siete 6 pasajeros"
        default:
            return ""
        }
    }
    
    /* este método es para no estar haciendo lo sgte. en toda la app:
     let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: UIAlertControllerStyle.alert)
         alerta.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
         alerta.dismiss(animated: true, completion: nil)
     }))
     self.present(alerta, animated: true, completion: nil)
     */
    class func mostrarAlerta(titulo: String, mensaje: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            alerta.dismiss(animated: true, completion: nil)
        }))
        
        UIApplication.topViewController()?.present(alerta, animated: true, completion: nil)
    }
    
    class func colorWithHexString(hexString: String, alpha:CGFloat? = 1.0) -> UIColor {
        // Convert hex string to an integer
        let hexint = Int(self.intFromHexString(hexStr: hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha!
        
        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        
        return color
    }
    
    class func intFromHexString(hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        // Create scanner
        let scanner: Scanner = Scanner(string: hexStr)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        // Scan hex value
        scanner.scanHexInt32(&hexInt)
        return hexInt
    }
    
}

/* esta clase es como un equivalente a obtener el Context en android, para usarla: UIApplication.topViewController()? */
extension UIApplication {
    
    static func topViewController(base: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
    
}
