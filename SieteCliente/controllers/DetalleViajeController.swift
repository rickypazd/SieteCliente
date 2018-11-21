//
//  DetalleViajeController.swift
//  SieteCliente
//
//  Created by Ricardo Paz Demiquel on 16/11/18.
//  Copyright © 2018 Ricardo Paz Demiquel. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import SwiftyJSON
import TinyConstraints
import GoogleMaps
import UIKit
import CRGradientNavigationBar

class DetalleViajeController: UIViewController {
    
    var selected: JSON!
    
    //ELEMENTOS
    let foto_perfil: UIImageView = {
        let images = UIImageView()
        images.image = #imageLiteral(resourceName: "bolivia")
        //images.backgroundColor = .red
        return images
    }()

    
    let lb_nombre : UILabel = {
        let label = UILabel()
        label.text = "Nombre"
         label.textColor =  UIColor.init(red: 80, green: 80, blue: 80)
//        label.backgroundColor = UIColor.blue
//        label.layer.borderWidth = 1
//        label.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        label.textAlignment = .center
        return label
    }()
    
    let btn_accion : UIButton = {
        let buton = UIButton()
        buton.setTitle("Ver recorrido", for: .normal)
        buton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        buton.backgroundColor = UIColor.init(red: 146, green: 58, blue: 237)
        buton.layer.masksToBounds = true
        buton.layer.cornerRadius = 10
        buton.setTitleColor(.white, for: .normal)
        return buton
    }()
    
    let lb_placa : UILabel = {
        let label = UILabel()
        label.text = "Placa ⦁ Telefono"
          label.font = label.font.withSize(14)
        label.backgroundColor = UIColor.init(red: 146, green: 58, blue: 237)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        label.textColor = UIColor.white

        //        label.layer.borderWidth = 1
        //        label.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        label.textAlignment = .center
        return label
    }()
    
    let lb_ubic_inicio : UILabel = {
        let label = UILabel()
        label.text = "Direccion inicio"
        label.font = label.font.withSize(14)
        label.backgroundColor = UIColor.init(red: 255, green: 255, blue: 255)
        //label.layer.masksToBounds = true
      //  label.layer.cornerRadius = 10
        label.textColor =  UIColor.init(red: 80, green: 80, blue: 80)
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        label.numberOfLines = 0
       // label.textAlignment = .center
        return label
    }()
    let lb_ubic_fin : UILabel = {
        let label = UILabel()
        label.text = "Direccion fin"
           label.font = label.font.withSize(14)
        label.backgroundColor = UIColor.init(red: 255, green: 255, blue: 255)
        //label.layer.masksToBounds = true
        //  label.layer.cornerRadius = 10
        label.textColor =  UIColor.init(red: 80, green: 80, blue: 80)
        label.layer.borderWidth = 1
            label.numberOfLines = 0
        label.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        // label.textAlignment = .center
        return label
    }()
    
    let lb_tipo_viaje : UILabel = {
        let label = UILabel()
        label.text = "Tipo viaje"
        label.font = label.font.withSize(12)
        label.backgroundColor = UIColor.init(red: 255, green: 255, blue: 255)
        //label.layer.masksToBounds = true
        //  label.layer.cornerRadius = 10
        label.textColor =  UIColor.init(red: 80, green: 80, blue: 80)
        
       // label.layer.borderWidth = 1
        //label.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        // label.textAlignment = .center
 
        return label
    }()
   
    let lb_tipo_viaje_desc : UILabel = {
        let label = UILabel()
        label.text = "Siete"
        label.font = label.font.withSize(12)
        label.backgroundColor = UIColor.init(red: 255, green: 255, blue: 255)
        //label.layer.masksToBounds = true
        //  label.layer.cornerRadius = 10
              label.textColor =  UIColor.init(red: 80, green: 80, blue: 80)
        // label.layer.borderWidth = 1
        //label.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
         label.textAlignment = .right
        return label
    }()
    
    let lb_fecha : UILabel = {
        let label = UILabel()
        label.text = "Fecha"
        label.font = label.font.withSize(12)
        label.backgroundColor = UIColor.init(red: 255, green: 255, blue: 255)
        //label.layer.masksToBounds = true
        //  label.layer.cornerRadius = 10
        label.textColor =  UIColor.init(red: 80, green: 80, blue: 80)
        // label.layer.borderWidth = 1
        //label.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        // label.textAlignment = .center
        return label
    }()
    
    let lb_vehiculo : UILabel = {
        let label = UILabel()
        label.text = "Vehiculo"
        label.font = label.font.withSize(12)
        label.backgroundColor = UIColor.init(red: 255, green: 255, blue: 255)
        //label.layer.masksToBounds = true
        //  label.layer.cornerRadius = 10
        label.textColor =  UIColor.init(red: 80, green: 80, blue: 80)
        label.textAlignment = .right
        // label.layer.borderWidth = 1
        //label.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        // label.textAlignment = .center
        return label
    }()
    
    let line : UIView = {
        let line = UIView(frame: CGRect(x: 0, y: 100, width: 320, height: 1.0))
        line.layer.borderWidth = 1.0
        line.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        return line
    }()
    let lb_forma : UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = label.font.withSize(14)
        label.backgroundColor = UIColor.init(red: 255, green: 255, blue: 255)
        label.textColor =  UIColor.init(red: 0, green: 0, blue: 0)
        
        label.numberOfLines = 0
        return label
    }()
    
    let lb_monto : UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = label.font.withSize(14)
        label.backgroundColor = UIColor.init(red: 255, green: 255, blue: 255)
        label.textColor =  UIColor.init(red: 80, green: 80, blue: 80)
        label.textAlignment = .right
        label.numberOfLines = 0
        return label
    }()
    
   
    
    func setConstraint(){
        self.view.addSubview(foto_perfil)
        foto_perfil.translatesAutoresizingMaskIntoConstraints = false
//        foto_perfil.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.3).isActive = true
        foto_perfil.widthAnchor.constraint(equalToConstant: 70).isActive = true
        foto_perfil.heightAnchor.constraint(equalToConstant: 70).isActive = true
        // leadingAnchor   trillinAnchor posisones
        foto_perfil.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        
        //        lb_nombre.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        foto_perfil.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 16).isActive = true
        
        self.view.addSubview(lb_nombre)
        lb_nombre.translatesAutoresizingMaskIntoConstraints = false
        lb_nombre.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.7).isActive = true
        lb_nombre.heightAnchor.constraint(equalToConstant: 24).isActive = true
//        lb_nombre.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        lb_nombre.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        lb_nombre.topAnchor.constraint(equalTo: self.foto_perfil.topAnchor, constant: 0).isActive = true
        lb_nombre.leadingAnchor.constraint(equalTo: self.foto_perfil.trailingAnchor , constant: 10).isActive = true
        
        self.view.addSubview(lb_placa)
        lb_placa.translatesAutoresizingMaskIntoConstraints = false
        lb_placa.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.7).isActive = true
        lb_placa.heightAnchor.constraint(equalToConstant: 24).isActive = true
        lb_placa.topAnchor.constraint(equalTo: self.lb_nombre.bottomAnchor, constant: 8).isActive = true
        lb_placa.leadingAnchor.constraint(equalTo: self.foto_perfil.trailingAnchor , constant: 10).isActive = true

        self.view.addSubview(lb_ubic_inicio)
        lb_ubic_inicio.translatesAutoresizingMaskIntoConstraints = false
        lb_ubic_inicio.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.9).isActive = true
        lb_ubic_inicio.heightAnchor.constraint(equalToConstant: 48).isActive = true
        lb_ubic_inicio.topAnchor.constraint(equalTo: self.foto_perfil.bottomAnchor, constant: 8).isActive = true
        lb_ubic_inicio.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        self.view.addSubview(lb_ubic_fin)
        lb_ubic_fin.translatesAutoresizingMaskIntoConstraints = false
        lb_ubic_fin.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.9).isActive = true
        lb_ubic_fin.heightAnchor.constraint(equalToConstant: 48).isActive = true
        lb_ubic_fin.topAnchor.constraint(equalTo: self.lb_ubic_inicio.bottomAnchor, constant: 8).isActive = true
        lb_ubic_fin.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        self.view.addSubview(btn_accion)
        btn_accion.translatesAutoresizingMaskIntoConstraints = false
        btn_accion.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.3).isActive = true
        btn_accion.heightAnchor.constraint(equalToConstant: 24).isActive = true
        btn_accion.topAnchor.constraint(equalTo: self.lb_ubic_fin.bottomAnchor, constant: 8).isActive = true
        btn_accion.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        self.view.addSubview(lb_tipo_viaje)
        lb_tipo_viaje.translatesAutoresizingMaskIntoConstraints = false
        lb_tipo_viaje.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.45).isActive = true
        lb_tipo_viaje.heightAnchor.constraint(equalToConstant: 14).isActive = true
        lb_tipo_viaje.topAnchor.constraint(equalTo: self.btn_accion.bottomAnchor, constant: 8).isActive = true
      //  lb_tipo_viaje.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        lb_tipo_viaje.leadingAnchor.constraint(equalTo: self.view.leadingAnchor , constant: 14).isActive = true
    
        self.view.addSubview(lb_tipo_viaje_desc)
        lb_tipo_viaje_desc.translatesAutoresizingMaskIntoConstraints = false
        lb_tipo_viaje_desc.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.45).isActive = true
        lb_tipo_viaje_desc.heightAnchor.constraint(equalToConstant: 14).isActive = true
        lb_tipo_viaje_desc.topAnchor.constraint(equalTo: self.btn_accion.bottomAnchor, constant: 8).isActive = true
        //  lb_tipo_viaje.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
          lb_tipo_viaje_desc.trailingAnchor.constraint(equalTo: self.view.trailingAnchor , constant: -14).isActive = true
        
       
        self.view.addSubview(lb_fecha)
        lb_fecha.translatesAutoresizingMaskIntoConstraints = false
        lb_fecha.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.45).isActive = true
        lb_fecha.heightAnchor.constraint(equalToConstant: 14).isActive = true
        lb_fecha.topAnchor.constraint(equalTo: self.lb_tipo_viaje.bottomAnchor, constant: 8).isActive = true
        //  lb_tipo_viaje.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        lb_fecha.leadingAnchor.constraint(equalTo: self.view.leadingAnchor , constant: 14).isActive = true
        
        self.view.addSubview(lb_vehiculo)
        lb_vehiculo.translatesAutoresizingMaskIntoConstraints = false
        lb_vehiculo.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.45).isActive = true
        lb_vehiculo.heightAnchor.constraint(equalToConstant: 14).isActive = true
        lb_vehiculo.topAnchor.constraint(equalTo: self.lb_fecha.topAnchor, constant: 0).isActive = true
        
        //  lb_tipo_viaje.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
          lb_vehiculo.trailingAnchor.constraint(equalTo: self.view.trailingAnchor , constant: -14).isActive = true
        
        
        self.view.addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.9).isActive = true
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        line.topAnchor.constraint(equalTo: self.lb_fecha.bottomAnchor, constant: 8).isActive = true
        line.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
       // line.leadingAnchor.constraint(equalTo: self.view.leadingAnchor , constant: 0).isActive = true
        
        self.view.addSubview(lb_forma)
        lb_forma.translatesAutoresizingMaskIntoConstraints = false
        lb_forma.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.45).isActive = true
        lb_forma.heightAnchor.constraint(equalToConstant: 200).isActive = true
        lb_forma.topAnchor.constraint(equalTo: self.line.bottomAnchor, constant: 8).isActive = true
        //  lb_tipo_viaje.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        lb_forma.leadingAnchor.constraint(equalTo: self.view.leadingAnchor , constant: 14).isActive = true
        
        self.view.addSubview(lb_monto)
        lb_monto.translatesAutoresizingMaskIntoConstraints = false
        lb_monto.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.45).isActive = true
        lb_monto.heightAnchor.constraint(equalToConstant: 200).isActive = true
        lb_monto.topAnchor.constraint(equalTo: self.line.bottomAnchor, constant: 8).isActive = true
        //  lb_tipo_viaje.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
      lb_monto.trailingAnchor.constraint(equalTo: self.view.trailingAnchor , constant: -14).isActive = true
        
       
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // self.view.setGradientBackground(colorOne: UIColor.init(red: 255, green: 255, blue: 255), colorTwo: UIColor.init(red: 0, green: 0, blue: 0))
       
        var colors = [UIColor]()
        colors.append(UIColor(red: 119/255, green: 65/255, blue: 185/255, alpha: 1))
        colors.append(UIColor(red: 244/255, green: 53/255, blue: 69/255, alpha: 1))
        
        navigationController?.navigationBar.setGradientBackground(colors: colors)
        //navigationController?.navigationBar.setGradientBackground(colors)
        self.view.backgroundColor = UIColor.init(red: 255, green: 255, blue: 255)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás", style: .plain, target: nil, action: nil)
        
        setConstraint()
        print(selected)
        let tap :UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(ver_as(sender:)))
        tap.numberOfTapsRequired=1
        btn_accion.addGestureRecognizer(tap)
        obtenerViaje()
        //        title="Atras"
        // Do any additional setup after loading the view.
    }
    
    func obtenerViaje() {
        SVProgressHUD.setDefaultMaskType(.black)
        
        let parametros: Parameters = [
            "evento": "get_viaje_detalle",
            "id": selected["id_carrera"].int!
        ]
        
        Alamofire.request(Util.urlIndexCtrl, parameters: parametros).responseJSON { response in
            switch response.result {
            case .success:
                let respuesta = JSON(response.data!)
                print(respuesta)
                
                self.lb_nombre.text = "\(respuesta["nombre"].string!) \(respuesta["apellido_pa"].string!)"
                self.lb_placa.text = "\(respuesta["placa"].string!) ⦁ \(respuesta["telefono"].string!)"
                self.lb_tipo_viaje_desc.text = Util.getTipoCarrera(tipo: respuesta["tipo"].int!)
                let fecha = respuesta["fecha_pedido"].string!
                let index = fecha.index(fecha.startIndex, offsetBy: 16)
                self.lb_fecha.text = String(fecha[..<index])
                self.lb_vehiculo.text = "\(respuesta["marca"].string!) \(respuesta["modelo"].string!)"
                var datos = ""
                datos += "Forma de pago \n\n"
                var costo = ""
                if respuesta["tipo_pago"].int == 1 {
                    costo += "Efectivo \n\n"
                } else if respuesta["tipo_pago"].int == 2 {
                    costo += "Credito \n\n"
                }
                var costo_total = 0
                if let items = respuesta["detalle_costo"].array {
                    for item in items {
                        if let title = item["nombre"].string {
                            datos += "\(title) \n\n" 
                        }
                        if let cost = item["costo"].double {
                            costo += "\(Double(round(100*cost)/100)) Bs.\n\n"
                            costo_total += Int(cost)
                        }
                    }
                }
                    datos += "Total"
                costo += "\(costo_total) Bs."
                self.lb_forma.text = datos
                self.lb_monto.text = costo
                
                let estado = respuesta["estado"].int
                
                if estado == 7 {
                    self.obtenerDireccion(latitud: respuesta["latinicial"].double!, longitud: respuesta["lnginicial"].double!, completionHandler: { direccion in
                        let fullString = NSMutableAttributedString(string: "")
                        let image1Attachment = ImageAttachment()
                        image1Attachment.image = UIImage(named: "pointer_map")
                        let image1String = NSAttributedString(attachment: image1Attachment)
                        fullString.append(image1String)
                        fullString.append(NSAttributedString(string: direccion))
                        self.lb_ubic_inicio.attributedText = fullString
                    })
                    
                    self.obtenerDireccion(latitud: respuesta["latfinalreal"].double!, longitud: respuesta["lngfinalreal"].double!, completionHandler: { direccion in
                        let fullString = NSMutableAttributedString(string: "")
                        let image1Attachment = ImageAttachment()
                        image1Attachment.image = UIImage(named: "pointer_map2")
                        let image1String = NSAttributedString(attachment: image1Attachment)
                        fullString.append(image1String)
                        fullString.append(NSAttributedString(string: direccion))
                         self.lb_ubic_fin.attributedText = fullString
                    })
                    

                } else {
                    self.obtenerDireccion(latitud: respuesta["latinicial"].double!, longitud: respuesta["lnginicial"].double!, completionHandler: { direccion in
                        let fullString = NSMutableAttributedString(string: "")
                        let image1Attachment = ImageAttachment()
                        image1Attachment.image = UIImage(named: "pointer_map")
                        let image1String = NSAttributedString(attachment: image1Attachment)
                        fullString.append(image1String)
                        fullString.append(NSAttributedString(string: direccion))
                        self.lb_ubic_inicio.attributedText = fullString
                    })
                    
                    self.obtenerDireccion(latitud: respuesta["latfinal"].double!, longitud: respuesta["lngfinal"].double!, completionHandler: { direccion in
                        let fullString = NSMutableAttributedString(string: "")
                        let image1Attachment = ImageAttachment()
                        image1Attachment.image = UIImage(named: "pointer_map2")
                        let image1String = NSAttributedString(attachment: image1Attachment)
                        fullString.append(image1String)
                        fullString.append(NSAttributedString(string: direccion))
                        self.lb_ubic_fin.attributedText = fullString
                    })

                }
                break
            case .failure:
                Util.mostrarAlerta(titulo: "Error", mensaje: "No se pudo conectar con el servidor.")
                break
            }
            SVProgressHUD.dismiss()
        }
    }
    
    
    @objc func ver_as( sender: UITapGestureRecognizer){
        print("asdas")
    }
    
    func obtenerDireccion( latitud: Double, longitud: Double, completionHandler: @escaping (String) -> ()) {
        let location = CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
        
        let geo = GMSGeocoder()
        geo.reverseGeocodeCoordinate(location) { (response, error) in
            if error != nil {
                completionHandler("")
                return
            }
            
            if response == nil {
                completionHandler("")
                return
            }
            
            let results = response?.results()
            
            var direccion:String = ""
            
            for i in (results?.first?.lines)! {
                direccion += i + " "
            }
            
            completionHandler(direccion)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //cambiar titulo del centro
//        self.navigationItem.title="Atras"
        // cambiar el texto del boton back
//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Atrás", style: .plain, target: nil, action: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
   
    
}
