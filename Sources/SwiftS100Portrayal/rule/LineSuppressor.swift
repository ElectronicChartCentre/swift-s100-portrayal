//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

import SwiftS101
import SwiftGeo

public class LineSuppressor {
    
    private let dsf: DataSetFile
    private let creator: GeometryCreator
    
    private var latestFeatureIdByRecordId: [RecordIdentifier: RecordIdentifier] = [:]
    private var allRecordIdsByFeatureId: [RecordIdentifier: Set<RecordIdentifier>] = [:]
    
    public init(dsf: DataSetFile, creator: GeometryCreator) {
        self.dsf = dsf
        self.creator = creator
    }
    
    public func add(featureRecordIdentifier: RecordIdentifier, geometry: Geometry) {
        guard let _ = dsf.record(forIdentifier: featureRecordIdentifier) as? FeatureTypeRecord else {
            return
        }
        
        let refs = geometry.refs()
        if refs.isEmpty {
            return
        }

        var recordIdentifiers: Set<RecordIdentifier> = []
        for ref in refs {
            if let recordIdentifier = ref as? RecordIdentifier {
                latestFeatureIdByRecordId[recordIdentifier] = featureRecordIdentifier
                recordIdentifiers.insert(recordIdentifier)
            }
        }
        allRecordIdsByFeatureId[featureRecordIdentifier] = recordIdentifiers
    }
    
    public func geometryAfterSuppression(featureRecordIdentifier: RecordIdentifier, geometry: Geometry) -> Geometry {
        
        guard let _ = dsf.record(forIdentifier: featureRecordIdentifier) as? FeatureTypeRecord else {
            return creator.createEmptyGeometry()
        }
        
        if geometry.refs().isEmpty {
            return geometry
        }
        
        var recordIdentifiersToInclude = Set<RecordIdentifier>()
        var recordIdentifiersToExclude = Set<RecordIdentifier>()
        for recordId in allRecordIdsByFeatureId[featureRecordIdentifier] ?? [] {
            if latestFeatureIdByRecordId[recordId] == featureRecordIdentifier {
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
        if let _ = geometry as? LinearGeometry {
            // single one to exclude
            return creator.createEmptyGeometry()
        } else if let polygon = geometry as? Polygon {
            var geometries: [Geometry] = []
            if let ref = polygon.shell.ref as? RecordIdentifier, recordIdentifiersToInclude.contains(ref) {
                geometries.append(polygon.shell)
            }
            for hole in polygon.holes {
                if let ref = hole.ref as? RecordIdentifier, recordIdentifiersToInclude.contains(ref) {
                    geometries.append(hole)
                }
            }
            return creator.createGeometry(geometries: geometries)
        } else {
            print("TODO: LineSuppressor geometryAfterSuppression add support for \(type(of: geometry))")
        }
        
        return creator.createEmptyGeometry()
    }
    
}
