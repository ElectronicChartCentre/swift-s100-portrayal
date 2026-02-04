//
//  File.swift
//  swift-s100-portrayal
//

import Foundation
import SwiftGeo

#if canImport(Cocoa)
import Cocoa
#endif

#if canImport(UIKit)
import UIKit
#endif

// CoreGraphics is only available on Apple platforms.
// https://github.com/PureSwift/Silica is a replacement on non-Apple platforms.

#if canImport(CoreGraphics)
import CoreGraphics
#elseif canImport(Silica)
import Silica
#endif

public struct CoreGraphicsRenderer: Renderer {

    private let context: CGContext
    
    private let widthPoint: Int
    private let heightPoint: Int
    private let widthPixel: Int
    private let heightPixel: Int
    private let pixelsPrPoint: Int
    private let projection: Projection
    private let colorPalette: ColorPalette
    private let screenResolution: ScreenResolution
    private let portrayalCatalogue: PortrayalCatalogue
    
    private let largeBoundingBoxPixel: BoundingBox
    private let largeBoundingBoxWorld: BoundingBox
    
    private let geometryCreator = DefaultGeometryCreator()
    
    public init(context: CGContext, widthPoint: Int, heightPoint: Int, pixelsPrPoint: Int, projection: Projection, colorPalette: ColorPalette, screenResolution: ScreenResolution, portrayalCatalogue: PortrayalCatalogue) {
        self.context = context
        self.widthPoint = widthPoint
        self.heightPoint = heightPoint
        self.pixelsPrPoint = pixelsPrPoint
        self.widthPixel = widthPoint * pixelsPrPoint
        self.heightPixel = heightPoint * pixelsPrPoint
        self.projection = projection
        self.colorPalette = colorPalette
        self.screenResolution = screenResolution
        self.portrayalCatalogue = portrayalCatalogue
        
        self.largeBoundingBoxPixel = DefaultBoundingBox(minX: 0, maxX: Double(widthPixel), minY: 0, maxY: Double(heightPixel)).grow(factor: 1.5)
        self.largeBoundingBoxWorld = self.largeBoundingBoxPixel.transform( self.projection.inverse)
    }
    
    public init?(widthPoint: Int, heightPoint: Int, pixelsPrPoint: Int, projection: Projection, colorPalette: ColorPalette, screenResolution: ScreenResolution, portrayalCatalogue: PortrayalCatalogue) {

        self.widthPoint = widthPoint
        self.heightPoint = heightPoint
        self.pixelsPrPoint = pixelsPrPoint
        self.widthPixel = widthPoint * pixelsPrPoint
        self.heightPixel = heightPoint * pixelsPrPoint
        self.projection = projection
        self.colorPalette = colorPalette
        self.screenResolution = screenResolution
        self.portrayalCatalogue = portrayalCatalogue
        
        self.largeBoundingBoxPixel = DefaultBoundingBox(minX: 0, maxX: Double(widthPixel), minY: 0, maxY: Double(heightPixel)).grow(factor: 1.5)
        self.largeBoundingBoxWorld = self.largeBoundingBoxPixel.transform( self.projection.inverse)

        let bitsPerComponent = 8
        let bytesPerPixel = 4 // RGBA
        let bytesPerRow = widthPixel * bytesPerPixel
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        
        guard let context = CGContext(
            data: nil,
            width: widthPixel,
            height: heightPixel,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }
        self.context = context
    }
    
    public func add(geometry: Geometry, drawingCommand: DrawingCommand) {
        if let colorFill = drawingCommand as? ColorFill {
            add(geometry: geometry, colorFill: colorFill)
        } else if let lineInstruction = drawingCommand as? LineInstruction {
            add(geometry: geometry, lineInstruction: lineInstruction)
        } else if let pointInstruction = drawingCommand as? PointInstruction {
            add(geometry: geometry, pointInstruction: pointInstruction)
        } else {
            print("TODO: handle \(drawingCommand)")
        }
    }
    
    private func add(geometry: Geometry, colorFill: ColorFill) {
        context.saveGState()
        
        let geometryXY = projection.forward(geometry: geometry)
        
        if let color = cgcolor(colorFill.token, transparency: colorFill.transparency) {
            context.setStrokeColor(color)
            context.setFillColor(color)
        } else {
            context.setStrokeColor(CGColor(red: 1.0, green: 0, blue: 0, alpha: 0.5))
            context.setFillColor(CGColor(red: 1.0, green: 0, blue: 0, alpha: 0.5))
        }
        
        if let polygonXY = geometryXY as? SwiftGeo.Polygon {
            context.beginPath()
            for (idx, point) in polygonXY.shell.coordinates.enumerated() {
                if idx == 0 {
                    context.move(to: CGPoint(x: CGFloat(point.x), y: CGFloat(point.y)))
                } else {
                    context.addLine(to: CGPoint(x: CGFloat(point.x), y: CGFloat(point.y)))
                }
            }
            context.closePath()
            context.fillPath()
            context.strokePath()
            
            // TODO: holes..
        } else {
            print("ERROR: unsupported geometry type \(geometryXY) for fill")
        }
        
        context.restoreGState()
    }
    
    private func add(geometry: Geometry, lineInstruction: LineInstruction) {
        guard let lineStyle = lineInstruction.lineStyles(portrayalCatalogue: portrayalCatalogue).first else {
            return
        }
        
        context.saveGState()
        
        let geometryXY = projection.forward(geometry: geometry)
        
        if let color = cgcolor(lineStyle.pen.color) {
            context.setStrokeColor(color)
        } else {
            context.setStrokeColor(CGColor(red: 1.0, green: 0, blue: 0, alpha: 0.5))
        }

        if !lineStyle.dashs.isEmpty {
            var dashPhase: CGFloat = 0.0
            var dashLengths: [CGFloat] = []
            let intervalLengthPx = screenResolution.pixels(mm: lineStyle.intervalLength)
            for dash in lineStyle.dashs {
                let dashStartPx = screenResolution.pixels(mm: dash.start)
                if dashStartPx > intervalLengthPx {
                    continue
                }
                var dashLengthPx = screenResolution.pixels(mm: dash.length)
                if dashLengthPx > intervalLengthPx {
                    dashLengthPx = intervalLengthPx - dashStartPx
                }
                let gap = intervalLengthPx - dashLengthPx
                dashPhase = intervalLengthPx - dashStartPx
                
                // only last?
                dashLengths.removeAll()
                
                dashLengths.append(max(0, dashLengthPx))
                dashLengths.append(gap)
            }
            context.setLineDash(phase: dashPhase, lengths: dashLengths)
        }

        context.setLineWidth(screenResolution.pixels(mm: lineStyle.pen.width))
        
        strokePath(geometryXY)
        
        context.restoreGState()
    }
    
    private func add(geometry: Geometry, pointInstruction: PointInstruction) {
        
        if type(of: geometry) != MultiPoint.self, let multiGeometry = geometry as? MultiGeometry {
            for geometryPart in multiGeometry.geometries() {
                add(geometry: geometryPart, pointInstruction: pointInstruction)
            }
            return
        }
        
        guard let svg = portrayalCatalogue.symbolSVGByName[pointInstruction.symbol] else {
            return
        }
        
        let geometryXY = projection.forward(geometry: geometry)
        
        if let pointXY = geometryXY as? Point {
            context.saveGState()
            context.translateBy(x: pointXY.coordinate.x, y: pointXY.coordinate.y)
            
            if let rotationCRS = pointInstruction.rotationCRS, let rotation = pointInstruction.rotation {
                if rotationCRS == RotationCommand.RotationCRS.GeographicCRS.rawValue {
                    // TODO: calculate screen rotation using projection
                    context.rotate(by: rotation * .pi / 180.0)
                } else {
                    context.rotate(by: rotation * .pi / 180.0)
                }
            }
            
            svg.draw(context: context, screenResolution: screenResolution, colorPalette: colorPalette)
            context.restoreGState()
        } else if let multiPointXY = geometryXY as? MultiPoint {
            for coordinateXY in multiPointXY.coordinates() {
                
                if !largeBoundingBoxPixel.intersects(coordinateXY) {
                    continue
                }
                
                context.saveGState()
                context.translateBy(x: coordinateXY.x, y: coordinateXY.y)
                svg.draw(context: context, screenResolution: screenResolution, colorPalette: colorPalette)
                context.restoreGState()
            }
        } else if let lineStringXY = geometryXY as? LineString {
            let lineStringWalkerXY = LineStringWalker(lineString: lineStringXY)
            guard let coordinateXY = lineStringWalkerXY.coordinate2DAtFactor(factor: 0.5, creator: geometryCreator) else {
                return
            }
            
            context.saveGState()
            context.translateBy(x: coordinateXY.x, y: coordinateXY.y)
            
            if let rotationCRS = pointInstruction.rotationCRS, let rotation = pointInstruction.rotation {
                if rotationCRS == RotationCommand.RotationCRS.GeographicCRS.rawValue {
                    // TODO: calculate screen rotation using projection
                    context.rotate(by: rotation * .pi / 180.0)
                } else {
                    context.rotate(by: rotation * .pi / 180.0)
                }
            }
            
            svg.draw(context: context, screenResolution: screenResolution, colorPalette: colorPalette)
            context.restoreGState()
        } else if let polygonXY = geometryXY as? Polygon {
            // all rings?
            let lineStringWalkerXY = LineStringWalker(linearRing: polygonXY.shell)
            guard let coordinateXY = lineStringWalkerXY.coordinate2DAtFactor(factor: 0.5, creator: geometryCreator) else {
                return
            }
            
            context.saveGState()
            context.translateBy(x: coordinateXY.x, y: coordinateXY.y)
            
            if let rotationCRS = pointInstruction.rotationCRS, let rotation = pointInstruction.rotation {
                if rotationCRS == RotationCommand.RotationCRS.GeographicCRS.rawValue {
                    // TODO: calculate screen rotation using projection
                    context.rotate(by: rotation * .pi / 180.0)
                } else {
                    context.rotate(by: rotation * .pi / 180.0)
                }
            }
            
            svg.draw(context: context, screenResolution: screenResolution, colorPalette: colorPalette)
            context.restoreGState()
        } else {
            print("DEBUG: unsupported PointInstruction type. \(geometryXY)")
        }
        
    }
    
    private func strokePath(_ geometryXY: Geometry) {
        if let polygonXY = geometryXY as? SwiftGeo.Polygon {
            strokePath(polygonXY.shell.coordinates)
            for hole in polygonXY.holes {
                strokePath(hole.coordinates)
            }
        } else if let lineStringXY = geometryXY as? SwiftGeo.LineString {
            strokePath(lineStringXY.coordinates)
        } else if let _ = geometryXY as? Point {
            // ignore
        } else if let multiGeometryXY = geometryXY as? MultiGeometry {
            for subGeometryXY in multiGeometryXY.geometries() {
                strokePath(subGeometryXY)
            }
        } else {
            print("ERROR: unsupported geometry type \(geometryXY) for stroke")
        }
    }
    
    private func strokePath(_ coordinates: [Coordinate]) {
        for (idx, coordinate) in coordinates.enumerated() {
            let point = CGPoint(x: coordinate.x, y: coordinate.y)
            if idx == 0 {
                context.move(to:point)
            } else {
                context.addLine(to: point)
            }
        }
        context.strokePath()
    }
    
    private func cgcolor(_ token: String) -> CGColor? {
        if let color = colorPalette.itemByToken[token]?.srgb {
            return CGColor(red: Double(color.red) / 255.0, green: Double(color.green) / 255.0, blue: Double(color.blue) / 255.0, alpha: 1.0)
        }
        return nil
    }
    
    private func cgcolor(_ token: String, transparency: Double) -> CGColor? {
        if let color = colorPalette.itemByToken[token]?.srgb {
            
            if transparency > 0 {
                return CGColor(red: Double(color.red) / 255.0, green: Double(color.green) / 255.0, blue: Double(color.blue) / 255.0, alpha: 1.0 - transparency)
            }
            
            return CGColor(red: Double(color.red) / 255.0, green: Double(color.green) / 255.0, blue: Double(color.blue) / 255.0, alpha: 1.0)
        }
        return nil
    }
    
    public func asPNGData() -> Data? {
        guard let cgImage = context.makeImage() else {
            return nil
        }

        var imageData: Data? = nil
        #if os(iOS) || os(tvOS) || os(linux)
        let uiImage = UIImage(cgImage: cgImage)
        imageData = uiImage.pngData()
        #elseif os(macOS)
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        imageData = bitmapRep.representation(using: .png, properties: [:])
        #endif
        
        return imageData
    }
    
}
