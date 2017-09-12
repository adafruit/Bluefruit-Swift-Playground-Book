//
//  UartDataChunk.swift
//  
//
//  Created by Trevor Beaton on 9/1/17.
//
//

import Foundation

class UartDataChunk {      // A chunk of data received or sent
    var timestamp : CFAbsoluteTime
    enum TransferMode {
        case tx
        case rx
    }
    var mode : TransferMode
    var data : Data
    
    init(timestamp: CFAbsoluteTime, mode: TransferMode, data: Data) {
        self.timestamp = timestamp
        self.mode = mode
        self.data = data
    }
}
