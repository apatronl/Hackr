//
//  String+Quantity.swift
//  Hackr
//
//  Created by Alejandrina Patron on 12/3/18.
//  Copyright © 2018 Alejandrina Patron. All rights reserved.
//

import Foundation

func getQuantityString(for quantity: Int, singular: String, plural: String) -> String {
  return "\(quantity) \(quantity == 1 ? singular : plural)"
}
