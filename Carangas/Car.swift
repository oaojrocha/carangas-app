//
//  Car.swift
//  Carangas
//
//  Created by School Picture Dev on 23/05/18.
//  Copyright © 2018 Eric Brito. All rights reserved.
//

import Foundation

class Car: Codable {
    
    var _id: String?
    var brand: String = ""
    var gasType: Int = 0
    var name: String = ""
    var price: Double = 0.0
    
    var gas: String {
        switch gasType {
            case 0:
                return "Flex"
            case 1:
                return "Etanol"
            default:
                return "Gasolina"
        }
    }
}

struct Brand: Codable {
    let fipe_name: String
}
