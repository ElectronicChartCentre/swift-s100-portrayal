//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

import SwiftS101
import SwiftGeo

struct AugmentedPoint: GeometryCommand, HasGeometry {
    
    let crs: CRSType
    let x: Int
    let y: Int
    
    func geometry(dsf: DataSetFile, geometry: Geometry, geometryCreator: GeometryCreator, renderer: any Renderer) -> Geometry? {
        
        if crs != .GeographicCRS {
            print("TODO: implement \(self.self) for \(crs)")
            return nil
        }
        
        guard let coordinate = dsf.generalInformation?.dssi?.createCoordinate2D(xcoo: x, ycoo: y, creator: geometryCreator) else {
            return nil
        }
        return geometryCreator.createPoint(coord: coordinate)
    }

    
    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        
        if args.count != 3 {
            print("TODO: implement \(self.self) for args: \(args)")
            return nil
        }
        
        guard let crs = CRSType(rawValue: args[0]) else {
            return nil
        }

        guard let x = Int(args[1]), let y = Int(args[2]) else {
            return nil
        }
        
        if crs != .GeographicCRS {
            print("TODO: implement \(self.self) for \(crs)")
        }
        
        let augmentedPoint = AugmentedPoint(crs: crs, x: x, y: y)
        state.geometryState.augmentedGeometry = augmentedPoint
        
        return nil
    }
    
}
