//
//  daemon1.swift
//  daemon1
//
//  Created by nikodem on 06/11/2024.
//

import Figlet
import Foundation
import AppKit
import SwiftUI




func getFrontmostApplication() -> String {
    if let frontmost = NSWorkspace.shared.frontmostApplication?.localizedName {
        return frontmost
    }
    return "Error"
}

@main
struct daemon1 {
    static func main() {
        var frontmostApplication = getFrontmostApplication()
        print(NSWorkspace.shared.frontmostApplication?.)
        
        
    }
}




