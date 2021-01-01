//
//  Stopwatch.swift
//  Stopwatch
//
//  Created by bht on 2021/01/01.
//

import Foundation

class Stopwatch: NSObject {
    var counter: Double
    var timer: Timer
    
    override init() {
        counter = 0.0
        timer = Timer()
    }
}
