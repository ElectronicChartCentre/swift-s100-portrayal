//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

import SwiftS101
import SwiftGeo

struct ArcByRadius: GeometryCommand, SegmentListPart {
    
    let centerX: Double
    let centerY: Double
    let radius: Double
    let startAngle: Double
    let angularDistance: Double

    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        
        if args.count < 3 {
            return nil
        }
        
        guard args.count >= 3, let centerX = Double(args[0]), let centerY = Double(args[1]), let radius = Double(args[2]) else {
            return nil
        }
        
        var startAngle: Double = 0.0
        var angularDistance: Double = 360.0
        
        if args.count > 3, let a = Double(args[3]) {
            startAngle = a
        }
        if args.count > 4, let a = Double(args[4]) {
            angularDistance = a
        }
        
        state.geometryState.segments.append(ArcByRadius(centerX: centerX, centerY: centerY, radius: radius, startAngle: startAngle, angularDistance: angularDistance))
        
        return nil
    }
    
    func geometry(dsf: DataSetFile, geometry: any Geometry, geometryCreator: any GeometryCreator, renderer: any Renderer, crsPosition: CRSType, crsAngle: CRSType, crsDistance: CRSType) -> (any Geometry)? {
        
        guard let point = geometry as? Point else {
            print("ERROR: unsupported geometry \(geometry) for \(self.self)")
            return nil
        }
        
        let centerXY = renderer.projection.forward(coordinate: point.coordinate)
        
        var radiusDegrees: Double = 0
        var radiusPx: Double = 0
        switch crsDistance {
        case .GeographicCRS:
            // convert meter on earth to degrees. direction not important here.
            let otherLL = GreatCircle.sphericalDestinationFrom(point.coordinate, distance: radius, direction: startAngle)
            radiusDegrees = point.coordinate.distance2D(to: otherLL)
            let otherXY = renderer.projection.inverse(coordinate: otherLL)
            radiusPx = centerXY.distance2D(to: otherXY)
        case .LocalCRS, .PortrayalCRS:
            // convert mm on screen to degrees.
            radiusPx = renderer.screenResolution.pixels(mm: radius)
            let radiusPxPart = radiusPx / sqrt(2.0)
            // this is not correct direction. just same for all so that projected radius is same for same point.
            let otherXY = geometryCreator.createCoordinate2D(x: centerXY.x + radiusPxPart, y: centerXY.y + radiusPxPart)
            let otherLL = renderer.projection.inverse(coordinate: otherXY)
            radiusDegrees = point.coordinate.distance2D(to: otherLL)
        default:
            print("ERROR: unsupported crsDistance: \(crsDistance) for \(self.self)")
        }
        
        var theStartAngle = Angle(degreesCWNorth: startAngle)
        var theEndAngle = Angle(degreesCWNorth: startAngle + angularDistance)
        
        switch crsAngle {
        case .GeographicCRS:
            // Angles are defined clockwise from the true north direction.
            // should use a more correct meter distance here, but not important
            let otherLLStart = GreatCircle.sphericalDestinationFrom(point.coordinate, distance: 100, direction: theStartAngle.asDegreesCWNorth())
            let otherLLEnd = GreatCircle.sphericalDestinationFrom(point.coordinate, distance: 100, direction: theEndAngle.asDegreesCWNorth())
            theStartAngle = Vector2D(from: point.coordinate, to: otherLLStart).angle()
            theEndAngle = Vector2D(from: point.coordinate, to: otherLLEnd).angle()
        case .LocalCRS, .PortrayalCRS:
            // Angles are measured in degrees clockwise from the positive y-axis.
            let centerXY = renderer.projection.forward(coordinate: point.coordinate)
            let otherXYStart = geometryCreator.createCoordinate2D(x: centerXY.x + radiusPx * cos(theStartAngle.asRadiansCCWPositiveX()), y: centerXY.y + radiusPx * sin(theStartAngle.asRadiansCCWPositiveX()))
            let otherXYEnd = geometryCreator.createCoordinate2D(x: centerXY.x + radiusPx * cos(theEndAngle.asRadiansCCWPositiveX()), y: centerXY.y + radiusPx * sin(theEndAngle.asRadiansCCWPositiveX()))
            let otherLLStart = renderer.projection.inverse(coordinate: otherXYStart)
            let otherLLEnd = renderer.projection.inverse(coordinate: otherXYEnd)
            theStartAngle = Vector2D(from: point.coordinate, to: otherLLStart).angle()
            theEndAngle = Vector2D(from: point.coordinate, to: otherLLEnd).angle()
        default:
            print("ERROR: unsupported crsAngle: \(crsAngle) for \(self.self)")
        }
        
        return Arc(center: point.coordinate, radius: radiusDegrees, startAngle: theStartAngle, endAngle: theEndAngle)
    }
    
    // perhaps this should move to SwiftGeo if/when it stabilizes?
    struct Arc: Geometry {
        
        let center: any Coordinate
        let radius: Double
        let startAngle: Angle
        let endAngle: Angle
        
        func isEmpty() -> Bool {
            false
        }
        
        func isValid() -> Bool {
            true
        }
        
        func bbox() -> (any BoundingBox)? {
            return nil
        }
        
        func transform(_ transform: (any Coordinate) -> any Coordinate) -> ArcByRadius.Arc {
            let newCenter = transform(center)
            
            // transform radius
            let radiusPart = radius / sqrt(2.0)
            let other = center.transform(newX: center.x + radiusPart, newY: center.y + radiusPart)
            let newOther = transform(other)
            let newRadius = newCenter.distance2D(to: newOther)
            
            // TODO: transform angles as well
            return Arc(center: newCenter, radius: newRadius, startAngle: startAngle, endAngle: endAngle)
        }
        
        func refs() -> [any Hashable] {
            return []
        }
        
    }
    
}
