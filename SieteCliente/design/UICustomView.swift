import UIKit

@IBDesignable
class UICustomView: UIView {

    @IBInspectable var primerColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var segundoColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var tercerColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    func updateView() {
        let layer = self.layer as! CAGradientLayer
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        layer.colors = [ primerColor.cgColor, segundoColor.cgColor, tercerColor.cgColor ]
    }
    
//    var view = UIView()
//
////    override var backgroundColor: UIColor? {
////        didSet {
////            print("here: "); // break point 1
////        }
////    }
//
////    func setup() {
////        self.backgroundColor = UIColor.redColor()  // break point 2
////        view.backgroundColor = UIColor.greenColor()
////        view.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
////        addSubview(view)
////    }
//
//    @IBInspectable var background: UIColor = UIColor.clear {
//        didSet {
////            self.backgroundColor = UIColor.init(hex: 0xC23E54)
//            self.setAttributes(outlineColor: UIColor.init(hex: 0xC23E54), outlineWidth: self.segundoColor, tercerColor: tercerColor)
//        }
//    }
//
//    @IBInspectable var segundoColor: UIColor = UIColor.clear {
//        didSet {
////            self.backgroundColor = UIColor.init(hex: 0x8e5583)
//            self.setAttributes(outlineColor: self.background, outlineWidth: UIColor.init(hex: 0x8e5583), tercerColor: tercerColor)
//        }
//    }
//
//    @IBInspectable var tercerColor: UIColor = UIColor.clear {
//        didSet {
////            self.backgroundColor = UIColor.init(hex: 0x715a9e)
//            self.setAttributes(outlineColor: self.background, outlineWidth: self.segundoColor, tercerColor: UIColor.init(hex: 0x715a9e))
//        }
//    }
//
//    func setAttributes(outlineColor:UIColor, outlineWidth: UIColor, tercerColor: UIColor) {
//        let layer = CAGradientLayer()
//
//
////        layer.colors = [outlineColor, outlineWidth, tercerColor]
//        layer.colors = [UIColor.init(hex: 0xC23E54), UIColor.init(hex: 0x8e5583), UIColor.init(hex: 0x715a9e)]
//        layer.frame = self.frame
////        layer.startPoint = CGPoint(x: 0, y: 0)
////        layer.endPoint = CGPoint(x: 1, y: 1)
//
//        self.layer.addSublayer(layer)
////        view.backgroundColor = UIColor.greenColor()
////        view = self
////        view.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
////        view.layer.addSublayer(layer)
////        addSubview(view)
//    }

}
