//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

public struct ColorPalette {
    
    public let name: String
    public let css: String
    public let itemByToken: [String: ColorItem]
    
    static func create(_ e: Element) -> ColorPalette? {
        guard let name = e.attributeByKey["name"] else {
            return nil
        }
        guard let css = e.attributeByKey["css"] else {
            return nil
        }
        
        var itemByToken: [String: ColorItem] = [:]
        for colorItemElement in e.children(name: "item") {
            if let colorItem = ColorItem.create(colorItemElement) {
                itemByToken[colorItem.token] = colorItem
            }
        }
        
        return ColorPalette(name: name, css: css, itemByToken: itemByToken)
    }
    
}
