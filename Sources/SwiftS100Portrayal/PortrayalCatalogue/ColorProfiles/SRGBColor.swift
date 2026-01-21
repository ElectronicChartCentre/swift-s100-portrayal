//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

public struct SRGBColor {
    
    public let red: Int
    public let green: Int
    public let blue: Int
    
    static func create(_ e: Element) -> SRGBColor? {
        guard let red = e["red"].flatMap(Int.init),
              let green = e["green"].flatMap(Int.init),
              let blue = e["blue"].flatMap(Int.init) else {
            return nil
        }
        return SRGBColor(red: red, green: green, blue: blue)
    }
    
}
