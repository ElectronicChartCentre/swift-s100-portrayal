//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

public class VisibilityState {
    
    var scaleMinimum: Int?
    var scaleMaximum: Int?
    var displayPlaneIsOverRadar = false
    var drawingPriority: Int = 0
    var viewingGroups: Set<Int> = []
    
    func toRecord() -> Record {
        .init(scaleMinimum: scaleMinimum, scaleMaximum: scaleMaximum, displayPlaneIsOverRadar: displayPlaneIsOverRadar, drawingPriority: drawingPriority, viewingGroups: viewingGroups)
    }
    
    public struct Record: Sendable {
        
        var scaleMinimum: Int?
        var scaleMaximum: Int?
        var displayPlaneIsOverRadar = false
        var drawingPriority: Int = 0
        var viewingGroups: Set<Int>
        
    }
    
}
