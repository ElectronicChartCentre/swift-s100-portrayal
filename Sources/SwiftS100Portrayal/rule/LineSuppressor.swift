//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

import SwiftS101
import SwiftGeo

public class LineSuppressor {
    
    private let creator: GeometryCreator
    
    private var priorityDrawingCommandIdBySpatialRecordId: [RecordIdentifier: String] = [:]
    private var allSpatialRecordIdsByDrawingCommandId: [String: Set<RecordIdentifier>] = [:]
    
    public init(creator: GeometryCreator) {
        self.creator = creator
    }
    
    public func add(drawingCommandId: String, geometry: Geometry) {
        let refs = geometry.refs()
        if refs.isEmpty {
            return
        }

        var recordIdentifiers: Set<RecordIdentifier> = []
        for ref in refs {
            if let recordIdentifier = ref as? RecordIdentifier {
                priorityDrawingCommandIdBySpatialRecordId[recordIdentifier] = drawingCommandId
                recordIdentifiers.insert(recordIdentifier)
            }
        }
        allSpatialRecordIdsByDrawingCommandId[drawingCommandId] = recordIdentifiers
    }
    
    public func geometryAfterSuppression(drawingCommandId: String, geometry: Geometry) -> Geometry {
        
        if geometry.refs().isEmpty {
            return geometry
        }
        
        var recordIdentifiersToInclude = Set<RecordIdentifier>()
        var recordIdentifiersToExclude = Set<RecordIdentifier>()
        for recordId in allSpatialRecordIdsByDrawingCommandId[drawingCommandId] ?? [] {
            if priorityDrawingCommandIdBySpatialRecordId[recordId] == drawingCommandId {
                recordIdentifiersToInclude.insert(recordId)
            } else {
                recordIdentifiersToExclude.insert(recordId)
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
        findLinearGeometries(in: geometry, recordIdentifiersToInclude: recordIdentifiersToInclude, appendTo: &lines)
        return creator.createGeometry(geometries: lines)
    }
    
    private func findLinearGeometries(in geometry: Geometry, recordIdentifiersToInclude: Set<RecordIdentifier>, appendTo result: inout [any LinearGeometry]) {
        
        if let line = geometry as? LinearGeometry, let ref = line.ref as? RecordIdentifier, recordIdentifiersToInclude.contains(ref) {
            result.append(line)
            return
        }
        
        if let polygon = geometry as? Polygon {
            findLinearGeometries(in: polygon.shell, recordIdentifiersToInclude: recordIdentifiersToInclude, appendTo: &result)
            for hole in polygon.holes {
                findLinearGeometries(in: hole, recordIdentifiersToInclude: recordIdentifiersToInclude, appendTo: &result)
            }
            return
        }
        
        if let multiGeometry = geometry as? MultiGeometry {
            for subGeometry in multiGeometry.geometries() {
                findLinearGeometries(in: subGeometry, recordIdentifiersToInclude: recordIdentifiersToInclude, appendTo: &result)
            }
            return
        }
    }
    
}
