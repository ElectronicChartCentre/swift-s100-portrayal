//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

struct ContextParameters {
    
    let parameterByName: [String: ContextParameter]
    
    init(parameters: [ContextParameter]) {
        var parameterByName: [String: ContextParameter] = [:]
        for parameter in parameters {
            parameterByName[parameter.name] = parameter
        }
        self.parameterByName = parameterByName
    }
    
    static func defaultContextParameters() -> ContextParameters {
        var parameters: [ContextParameter] = []

        parameters.append(.init(name: "SafetyDepth", type: "real", value: "10"))
        parameters.append(.init(name: "ShallowContour", type: "real", value: "2"))
        parameters.append(.init(name: "SafetyContour", type: "real", value: "10"))
        parameters.append(.init(name: "TwoShades", type: "boolean", value: "false"))
        parameters.append(.init(name: "FourShades", type: "boolean", value: "false"))
        parameters.append(.init(name: "DeepContour", type: "real", value: "30"))
        parameters.append(.init(name: "ShallowPattern", type: "boolean", value: "false"))
        parameters.append(.init(name: "ShowIsolatedDangersInShallowWaters", type: "boolean", value: "false"))
        parameters.append(.init(name: "ShallowWaterDangers", type: "boolean", value: "false"))
        parameters.append(.init(name: "PlainBoundaries", type: "boolean", value: "false"))
        parameters.append(.init(name: "SimplifiedPoints", type: "boolean", value: "false"))
        parameters.append(.init(name: "SimplifiedSymbols", type: "boolean", value: "false"))
        parameters.append(.init(name: "FullSectors", type: "boolean", value: "true"))
        parameters.append(.init(name: "FullLightLines", type: "boolean", value: "true"))
        parameters.append(.init(name: "RadarOverlay", type: "boolean", value: "true"))
        parameters.append(.init(name: "IgnoreScaleMinimum", type: "boolean", value: "false"))
        parameters.append(.init(name: "NationalLanguage", type: "text", value: "eng"))
        
        return ContextParameters(parameters: parameters)
    }
    
}
