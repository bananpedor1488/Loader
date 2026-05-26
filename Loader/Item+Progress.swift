//
//  Item+Progress.swift
//  Loader
//

import Foundation

extension Item {
    var simulatedProgress: Double {
        let seed = abs(timestamp.timeIntervalSince1970.bitPattern.hashValue)
        return 0.35 + Double(seed % 60) / 100.0
    }

    var isLoading: Bool {
        simulatedProgress < 0.95
    }
}
