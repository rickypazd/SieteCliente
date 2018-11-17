//
//  TransaccionesTableViewCell.swift
//  SieteCliente
//
//  Created by Ricardo Paz Demiquel on 11/9/18.
//  Copyright © 2018 Ricardo Paz Demiquel. All rights reserved.
//

import UIKit

class TransaccionesTableViewCell: UITableViewCell {

    @IBOutlet weak var lbFecha: UILabel!
    @IBOutlet weak var lbMonto: UILabel!
    @IBOutlet weak var lbTipo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
