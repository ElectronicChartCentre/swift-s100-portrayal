//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

public struct ColorPalette {
    
    public let name: String
    public let cssFileName: String
    public let itemByToken: [String: ColorItem]
    public let css: CSS
    
    static func create(_ e: Element, bundle: Bundle, portrayalCataloguePath: String) -> ColorPalette? {
        guard let name = e.attributeByKey["name"] else {
            return nil
        }
        guard let cssFileName = e.attributeByKey["css"] else {
            return nil
        }
        
        var itemByToken: [String: ColorItem] = [:]
        for colorItemElement in e.children(name: "item") {
            if let colorItem = ColorItem.create(colorItemElement) {
                itemByToken[colorItem.token] = colorItem
            }
        }
        
        guard let css = CSSParser.parse(bundle: bundle, portrayalCataloguePath: portrayalCataloguePath, cssFileName: cssFileName) else {
            return nil
        }
        
        return ColorPalette(name: name, cssFileName: cssFileName, itemByToken: itemByToken, css: css)
    }
    
}
