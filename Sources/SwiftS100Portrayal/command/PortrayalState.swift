//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

class PortrayalState {
    
    let geometryState = GeometryState()
    let lineStyleState = LineStyleState()
    var lineStyles: [LineStyle] = []
    let visibilityState = VisibilityState()
    let transformState = TransformState()
    let textStyleState = TextStyleState()
        
}
