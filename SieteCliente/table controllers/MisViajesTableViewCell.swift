//
//  MisViajesTableViewCell.swift
//  SieteCliente
//
//  Created by Ricardo Paz Demiquel on 17/8/18.
//  Copyright © 2018 Ricardo Paz Demiquel. All rights reserved.
//

import UIKit

class MisViajesTableViewCell: UITableViewCell {

    @IBOutlet weak var lbFecha: UILabel!
    @IBOutlet weak var lbVehiculo: UILabel!
    @IBOutlet weak var lbPartida: UILabel!
    @IBOutlet weak var lbLlegada: UILabel!
    @IBOutlet weak var lbTipoPago: UILabel!
    @IBOutlet weak var lbMontoPago: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
