//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

import SwiftS101
import SwiftGeo

struct AugmentedPath: GeometryCommand, HasGeometry {
    
    let crsPosition: CRSType
    let crsAngle: CRSType
    let crsDistance: CRSType
    let segments: [SegmentListPart]

    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        
        if args.count == 3, let crsPosition = CRSType(rawValue: args[0]), let crsAngle = CRSType(rawValue: args[1]), let crsDistance = CRSType(rawValue: args[2]) {

            let segments = state.geometryState.segments
            state.geometryState.segments.removeAll()
            
            let augmentedPath = AugmentedPath(crsPosition: crsPosition, crsAngle: crsAngle, crsDistance: crsDistance, segments: segments)
            state.geometryState.augmentedGeometry = augmentedPath
            
        } else {
            print("TODO: implement \(self.self) for args: \(args)")
        }
        
        return nil
    }
    
    func geometry(dsf: DataSetFile, geometry: any Geometry, geometryCreator: any GeometryCreator, renderer: any Renderer) -> (any Geometry)? {
        
        var geometries: [any Geometry] = []
        for segment in segments {
            if let segmentGeometry = segment.geometry(dsf: dsf, geometry: geometry, geometryCreator: geometryCreator, renderer: renderer, crsPosition: crsPosition, crsAngle: crsAngle, crsDistance: crsDistance) {
                geometries.append(segmentGeometry)
            }
        }
        
        return geometryCreator.createGeometry(geometries: geometries)
    }
    
}
