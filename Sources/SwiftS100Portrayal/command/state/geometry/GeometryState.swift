//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

import SwiftS101
import SwiftGeo

public class GeometryState {
    
    var spatialReferences: [SpatialReference] = []
    var augmentedGeometry: HasGeometry?

    public func toRecord() -> Record {
        return .init(spatialReferences: spatialReferences, augmentedGeometry: augmentedGeometry)
    }
    
    public struct Record: Sendable {
        
        let spatialReferences: [SpatialReference]
        let augmentedGeometry: HasGeometry?
        
        public func geometry(dsf: DataSetFile, geometry: Geometry, geometryCreator: GeometryCreator, renderer: Renderer) -> Geometry? {
            
            if let augmentedGeometry = augmentedGeometry {
                return augmentedGeometry.geometry(dsf: dsf, geometry: geometry, geometryCreator: geometryCreator, renderer: renderer)
            }
            
            if !spatialReferences.isEmpty {
                var geometries: [Geometry] = []
                for spatialReference in spatialReferences {
                    if let spatialReferenceGeometry = spatialReference.geometry(dsf: dsf, geometry: geometry, geometryCreator: geometryCreator, renderer: renderer) {
                        geometries.append(spatialReferenceGeometry)
                    }
                }
                return geometryCreator.createGeometry(geometries: geometries)
            }
            
            return geometry
        }

        
    }
    
}
