//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

import SwiftS101
import SwiftGeo

struct SpatialReference: GeometryCommand, HasGeometry {
    
    let spatialId: String
    let forward: Bool
    
    func geometry(dsf: DataSetFile, geometry: Geometry, geometryCreator: GeometryCreator, renderer: Renderer) -> Geometry? {
        
        guard let recordIdentifier = LuaRuleExecutor.createRecordIdentifier(recordId: spatialId) else {
            print("ERROR: SpatialReference: could not create recordIdentifier for \(spatialId)")
            return nil
        }
        
        guard let record = dsf.record(forIdentifier: recordIdentifier) as? GeometryRecord else {
            print("ERROR: SpatialReference: could not find geometry record for \(recordIdentifier)")
            return nil
        }
        
        return record.createGeometry(dsf: dsf, creator: geometryCreator, forward: forward)
    }
    
    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        guard let spatialId = args.first else {
            return nil
        }
        let forward: Bool = (args.count == 1 || args[1] == "true")
        
        let spatialReference = SpatialReference(spatialId: spatialId, forward: forward)
        state.geometryState.spatialReferences.append(spatialReference)
        
        return nil
    }

}
