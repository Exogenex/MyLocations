//
//  String+AddText.swift
//  MyLocations
//
//  Created by Micah on 2/28/22.
//

import Foundation

extension String {
    mutating func add(text: String?, separatedBy separator: String = "") {
        if let text = text {
            if !isEmpty { self += separator }
            
            self += text
        }
    }
}
