//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

public struct PortrayalCatalogue {
    
    let path: String
    
    let areaFillById: [String: AreaFill]
    let ruleFileById: [String: RuleFile]
    let symbolById: [String: Symbol]
    let lineStyleById: [String: LineStyle]
    let colorProfileById: [String: ColorProfile]
    let styleSheetById: [String: StyleSheet]
    let viewingGroupById: [String: ViewingGroup]

}
