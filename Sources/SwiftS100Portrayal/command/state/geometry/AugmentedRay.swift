//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

import SwiftS101
import SwiftGeo

struct AugmentedRay: GeometryCommand, HasGeometry {
    
    let crsDirection: CRSType
    let direction: Double
    let crsLength: CRSType
    let length: Double
    
    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        
        if args.count == 4, let crsDirection = CRSType(rawValue: args[0]), let direction = Double(args[1]), let crsLength = CRSType(rawValue: args[2]), let length = Double(args[3]) {
            
            let augmentedRay = AugmentedRay(crsDirection: crsDirection, direction: direction, crsLength: crsLength, length: length)
            state.geometryState.augmentedGeometry = augmentedRay
            
        } else {
            print("TODO: implement \(self.self) for args: \(args)")
        }
        
        return nil
    }
    
    func geometry(dsf: DataSetFile, geometry: any Geometry, geometryCreator: any GeometryCreator, renderer: any Renderer) -> (any Geometry)? {
        
        if crsDirection == .GeographicCRS, crsLength == .GeographicCRS {
            if let point = geometry as? Point {
                let start = point.coordinate
                let end = GreatCircle.sphericalDestinationFrom(start, distance: length, direction: direction)
                let coordinates = [start, end]
                return geometryCreator.createLineString(coords: coordinates)
            }
        }
        
        print("TODO: implement \(self.self) geometry from \(geometry)");
        return nil
    }
    
}
