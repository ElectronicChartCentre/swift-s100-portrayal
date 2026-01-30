//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

public struct PortrayalCatalogue {
    
    let bundle: Bundle
    let path: String
    
    let areaFillById: [String: AreaFill]
    let ruleFileById: [String: RuleFile]
    let symbolFileById: [String: SymbolFile]
    let lineStyleByName: [String: LineStyle]
    let colorProfileFileById: [String: ColorProfileFile]
    let styleSheetFileById: [String: StyleSheetFile]
    let viewingGroupById: [String: ViewingGroup]

    public let colorPaletteByName: [String: ColorPalette]
    public let symbolSVGByName: [String: SVG]
    
}
