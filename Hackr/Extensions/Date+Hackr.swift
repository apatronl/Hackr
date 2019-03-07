//
//  Date+Format.swift
//  Hackr
//
//  Created by Alejandrina Patron on 11/25/18.
//  Copyright © 2018 Alejandrina Patron. All rights reserved.
//

import Foundation

extension Date {
    
  /// Creates a `String` from a `Date` with the format MMMM dd, yyyy.
  /// For example, "February 7, 1996"
  ///
  /// - Returns: A string of a formatted date.
  func formatted() -> String? {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM dd, yyyy"
    return formatter.string(from: self)
  }
}
