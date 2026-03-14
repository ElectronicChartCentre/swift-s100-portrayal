//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

import SwiftS101
import SwiftGeo

public class LineSuppressor {
    
    private let creator: GeometryCreator
    
    private var priorityDrawingCommandByLineRecordIdentifier: [RecordIdentifier: String] = [:]
    private var allLineRecordIdentifiersByDrawingCommand: [String: Set<RecordIdentifier>] = [:]
    
    public init(creator: GeometryCreator) {
        self.creator = creator
    }
    
    public func add(drawingCommandId: String, geometry: Geometry) {
        var lineRecordIdentifiers: Set<RecordIdentifier> = []
        findLineRecordIdentifiers(geometry, recordIdentifiers: &lineRecordIdentifiers)
        if lineRecordIdentifiers.isEmpty {
            return
        }

        for lineRecordIdentifier in lineRecordIdentifiers {
            priorityDrawingCommandByLineRecordIdentifier[lineRecordIdentifier] = drawingCommandId
        }
        allLineRecordIdentifiersByDrawingCommand[drawingCommandId] = lineRecordIdentifiers
    }
    
    public func geometryAfterSuppression(drawingCommandId: String, geometry: Geometry) -> Geometry {
        
        let allLineRecordIdentifiersForDrawingCommand = allLineRecordIdentifiersByDrawingCommand[drawingCommandId] ?? []
        
        if allLineRecordIdentifiersForDrawingCommand.isEmpty {
            return geometry
        }
        
        var recordIdentifiersToInclude = Set<RecordIdentifier>()
        var recordIdentifiersToExclude = Set<RecordIdentifier>()
        for lineRecordIdentifier in allLineRecordIdentifiersByDrawingCommand[drawingCommandId] ?? [] {
            if priorityDrawingCommandByLineRecordIdentifier[lineRecordIdentifier] == drawingCommandId {
                recordIdentifiersToInclude.insert(lineRecordIdentifier)
            } else {
                recordIdentifiersToExclude.insert(lineRecordIdentifier)
            }
        }
        
        // easy ones first..
        if recordIdentifiersToInclude.isEmpty {
            return creator.createEmptyGeometry()
        }
        if recordIdentifiersToExclude.isEmpty {
            return geometry
        }
        
        // then the partly
        var lines: [any LinearGeometry] = []
        var restRecordIdentifiersToInclude: Set<RecordIdentifier> = recordIdentifiersToInclude
        findLinearGeometries(geometry, restRecordIdentifiersToInclude: &restRecordIdentifiersToInclude, lines: &lines)
        return creator.createGeometry(geometries: lines)
    }
    
    private func findLineRecordIdentifiers(_ geometry: Geometry, recordIdentifiers: inout Set<RecordIdentifier>) {
        
        if let line = geometry as? LinearGeometry {
            findLineRecordIdentifiers(line.coordinates, recordIdentifiers: &recordIdentifiers)
            return
        }
        
        if let polygon = geometry as? Polygon {
            findLineRecordIdentifiers(polygon.shell, recordIdentifiers: &recordIdentifiers)
            for hole in polygon.holes {
                findLineRecordIdentifiers(hole, recordIdentifiers: &recordIdentifiers)
            }
            return
        }
        
        if let multiGeometry = geometry as? MultiGeometry {
            for subGeometry in multiGeometry.geometries() {
                findLineRecordIdentifiers(subGeometry, recordIdentifiers: &recordIdentifiers)
            }
            return
        }
    }
    
    private func findLineRecordIdentifiers(_ coordinates: any CoordinateSequence, recordIdentifiers: inout Set<RecordIdentifier>) {
        
        if let coords = coordinates as? ArrayCoordinateSequence, let recordIdentifier = coords.ref as? RecordIdentifier {
            recordIdentifiers.insert(recordIdentifier)
            return
        }

        if let rev = coordinates as? ReverseCoordinateSequence {
            findLineRecordIdentifiers(rev.cs, recordIdentifiers: &recordIdentifiers)
            return
        }
        
        if let multi = coordinates as? MultiCoordinateSequence {
            for sub in multi.css {
                findLineRecordIdentifiers(sub, recordIdentifiers: &recordIdentifiers)
            }
            return
        }

    }
    
    private func findLinearGeometries(_ geometry: Geometry, restRecordIdentifiersToInclude: inout Set<RecordIdentifier>, lines: inout [any LinearGeometry]) {
        
        if let line = geometry as? LinearGeometry {
            findLinearGeometries(line.coordinates, restRecordIdentifiersToInclude: &restRecordIdentifiersToInclude, lines: &lines, reverse: false)
            return
        }
        
        if let polygon = geometry as? Polygon {
            findLinearGeometries(polygon.shell, restRecordIdentifiersToInclude: &restRecordIdentifiersToInclude, lines: &lines)
            for hole in polygon.holes {
                findLinearGeometries(hole, restRecordIdentifiersToInclude: &restRecordIdentifiersToInclude, lines: &lines)
            }
            return
        }
        
        if let multiGeometry = geometry as? MultiGeometry {
            for subGeometry in multiGeometry.geometries() {
                findLinearGeometries(subGeometry, restRecordIdentifiersToInclude: &restRecordIdentifiersToInclude, lines: &lines)
            }
            return
        }
    }
    
    private func findLinearGeometries(_ coordinates: any CoordinateSequence, restRecordIdentifiersToInclude: inout Set<RecordIdentifier>, lines: inout [any LinearGeometry], reverse: Bool) {
        
        if let coords = coordinates as? ArrayCoordinateSequence, let recordIdentifier = coords.ref as? RecordIdentifier, restRecordIdentifiersToInclude.contains(recordIdentifier) {
            
            var lineStringCoords: any CoordinateSequence = coords
            if reverse {
                lineStringCoords = ReverseCoordinateSequence(lineStringCoords)
            }
            
            let lineString = creator.createLineString(coords: lineStringCoords)
            lines.append(lineString)
            
            restRecordIdentifiersToInclude.remove(recordIdentifier)
            return
        }
        
        if let rev = coordinates as? ReverseCoordinateSequence {
            findLinearGeometries(rev.cs, restRecordIdentifiersToInclude: &restRecordIdentifiersToInclude, lines: &lines, reverse: !reverse)
            return
        }
        
        if let multi = coordinates as? MultiCoordinateSequence {
            for sub in multi.css {
                findLinearGeometries(sub, restRecordIdentifiersToInclude: &restRecordIdentifiersToInclude, lines: &lines, reverse: reverse)
            }
            return
        }
        
    }
    
}
