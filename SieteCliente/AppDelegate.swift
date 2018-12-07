import UIKit
import GoogleMaps
import FBSDKCoreKit
import Firebase
import SwiftyJSON
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey("AIzaSyD2uXL3TKoMAza8aP3q6RAozz4cL4ysnPc")
        
        
        
       // UIApplication.shared.statusBarStyle = .lightContent //titulos blancos
        UINavigationBar.appearance().isTranslucent = false
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { (isSuccess, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            })
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        FirebaseApp.configure()
        application.registerForRemoteNotifications()

        return true
    }
    
    func ConnectToFCM() {
       // messaging.messaging().shouldEstablishDirectChannel = true
        
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        
        return handled
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
      //  messaging.messaging().shouldEstablishDirectChannel = false
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        ConnectToFCM()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                 Util.setToken(token: result.token)
                print("Remote instance ID token: \(result.token)")
            }
        }
        
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Registration failed!")
    }
    
   // Firebase notification received
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        
        // custom code to handle push while app is in the foreground
        print("Handle push from foreground \(notification.request.content.userInfo)")
        
        let str = notification.request.content.userInfo["json"] as! String
//        var obj = JSON(str)
        let obj2 = JSON.init(parseJSON: str)
        
            switch notification.request.content.userInfo["evento"] as! String{
            case "mensaje_recibido":
                mensaje_recibido(obj: obj2)
                
                break
                
            default:
                
                break
            }
        
        // Reading message body
        let dict = notification.request.content.userInfo["aps"] as! NSDictionary
        
        var messageBody:String?
        var messageTitle:String = "Alert"
        
        if let alertDict = dict["alert"] as? Dictionary<String, String> {
            messageBody = alertDict["body"]!
            if alertDict["title"] != nil {
                messageTitle  = alertDict["title"]! }
            
        } else {
            messageBody = dict["alert"] as? String
            
        }
        
        print("Message body is \(messageBody!) ")
        print("Message messageTitle is \(messageTitle) ")
        // Let iOS to display message
        completionHandler([.alert,.sound, .badge])
    }
    //Called When Cloud Message is Received While App is in Background or is Closed
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("Message \(response.notification.request.content.userInfo)")
        
        completionHandler()
    }
    
    //Called When Silent Push Notification Arrives
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("Entire message \(userInfo)")
        
        let state : UIApplication.State = application.applicationState
        switch state {
        case UIApplication.State.active:
            print("If needed notify user about the message")
        default:
            print("Run code to download content")
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                Util.setToken(token: result.token)
                print("Remote instance ID token: \(result.token)")
            }
        }
    }
    func updateBadgeCount()
    {
        var badgeCount = UIApplication.shared.applicationIconBadgeNumber
        if badgeCount > 0
        {
            badgeCount = badgeCount-1
        }
        
        UIApplication.shared.applicationIconBadgeNumber = badgeCount
    }
    
    ////EVENTOS FIREBASE
    
    func mensaje_recibido(obj: JSON){
        let mensaje = [
            "id_emisor": obj["id_emisor"].int!,
            "id_receptor": obj["id_receptor"].int!,
            "mensaje" : obj["mensaje"].string!
            ] as [String : Any]
        guardarChat(mensaje: mensaje)
        NotificationCenter.default.post(name: .nuevo_mensaje, object: nil)
    }
    
    func guardarChat(mensaje: [String : Any]) {
        // TODO: guardar la lista en UserDefaults
        var chats: JSON = []
        chats = Util.getChat()!
        chats.arrayObject?.append(mensaje)
        // TODO: agregar el mensaje a la lista en JSON
        // TODO: creo que esto va a fallar
        Util.setChat(chat: chats.arrayObject)
        // self.chat = Util.getChat()?.arrayValue
    }

}

