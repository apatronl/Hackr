//
//  UITableViewCell+Identifier.swift
//  Hackr
//
//  Created by Alejandrina Patron on 12/4/18.
//  Copyright © 2018 Alejandrina Patron. All rights reserved.
//

import UIKit

extension UITableViewCell {
    class var identifier: String {
        return  String(describing: self)
    }
}
