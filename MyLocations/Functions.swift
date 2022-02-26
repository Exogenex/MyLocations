//
//  Functions.swift
//  MyLocations
//
//  Created by Micah on 2/25/22.
//

import Foundation

func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}
