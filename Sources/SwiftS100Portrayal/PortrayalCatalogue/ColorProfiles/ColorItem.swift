//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

public struct ColorItem {
    
    public let token: String
    public let srgb: SRGBColor
    
    static func create(_ e: Element) -> ColorItem? {
        guard let token = e.attributeByKey["token"] else {
            return nil
        }
        guard let c = e.children(name: "srgb").first, let srgb = SRGBColor.create(c) else {
            return nil
        }
        return ColorItem(token: token, srgb: srgb)
    }
    
}
