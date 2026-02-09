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
        } else if let textInstruction = drawingCommand as? TextInstruction {
            add(geometry: geometry, textInstruction: textInstruction)
        } else if let _ = drawingCommand as? NullInstruction {
            // nothing to do
        } else {
            print("TODO: handle \(drawingCommand)")
        }
    }
    
    private func add(geometry: Geometry, colorFill: ColorFill) {
        
        if let multiGeometry = geometry as? MultiGeometry {
            for subGeometry in multiGeometry.geometries() {
                add(geometry: subGeometry, colorFill: colorFill)
            }
            return
        }
        
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
        
        if geometry is Point || geometry is MultiPoint {
            return
        }
        
        if let polygon = geometry as? SwiftGeo.Polygon {
            add(geometry: polygon.shell, lineInstruction: lineInstruction)
            for hole in polygon.holes {
                add(geometry: hole, lineInstruction: lineInstruction)
            }
            return
        }
        
        if let multiGeometry = geometry as? MultiGeometry {
            for subGeometry in multiGeometry.geometries() {
                add(geometry: subGeometry, lineInstruction: lineInstruction)
            }
            return
        }
        
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
        
        let intervalLengthPx = screenResolution.pixels(mm: lineStyle.intervalLength)
        
        if !lineStyle.dashs.isEmpty {
            var dashPhase: CGFloat = 0.0
            var dashLengths: [CGFloat] = []
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
        
        if !lineStyle.symbols.isEmpty {
            if let lineXY = geometryXY as? LinearGeometry {
                placeSymbolsAlongLine(lineXY: lineXY.removeDuplicatePoints(), lineStyle: lineStyle)
            } else {
                print("TODO: line symbol in non-linear geometry. \(type(of: geometryXY))")
            }
        }

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
                    context.rotate(by: rotation * .pi / -180.0)
                } else {
                    context.rotate(by: rotation * .pi / -180.0)
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
        } else {
            guard let coordinateXY = CenterFinder.centerCoordinate2D(geometry: geometryXY, creator: geometryCreator) else {
                return
            }
            
            context.saveGState()
            context.translateBy(x: coordinateXY.x, y: coordinateXY.y)
            
            if let rotationCRS = pointInstruction.rotationCRS, let rotation = pointInstruction.rotation {
                if rotationCRS == RotationCommand.RotationCRS.GeographicCRS.rawValue {
                    // TODO: calculate screen rotation using projection
                    context.rotate(by: rotation * .pi / -180.0)
                } else {
                    context.rotate(by: rotation * .pi / -180.0)
                }
            }
            
            svg.draw(context: context, screenResolution: screenResolution, colorPalette: colorPalette)
            context.restoreGState()
        }
        
    }
    
    private func add(geometry: Geometry, textInstruction: TextInstruction) {
        
        if let multiGeometry = geometry as? MultiGeometry {
            for subGeometry in multiGeometry.geometries() {
                add(geometry: subGeometry, textInstruction: textInstruction)
            }
            return
        }
        
        let geometryXY = projection.forward(geometry: geometry)
        
        if let pointXY = geometryXY as? Point {
            drawText(coordinateXY: pointXY.coordinate, textInstruction: textInstruction)
        } else if let polygonXY = geometryXY as? SwiftGeo.Polygon {
            if let centerCoordinateXY = CenterFinder.centerCoordinate2D(geometry: polygonXY, creator: geometryCreator) {
                drawText(coordinateXY: centerCoordinateXY, textInstruction: textInstruction)
            }
        } else if let lineStringXY = geometryXY as? LineString {
            if let centerCoordinateXY = CenterFinder.centerCoordinate2D(geometry: lineStringXY, creator: geometryCreator) {
                drawText(coordinateXY: centerCoordinateXY, textInstruction: textInstruction)
            }
        } else {
            print("TODO: unsupported geometry type for text instruction. \(type(of: geometryXY))")
        }
    }
    
    private func drawText(coordinateXY: any Coordinate, textInstruction: TextInstruction) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        switch (textInstruction.textStyleState.textAlignHorizontal) {
        case TextAlignHorizontal.Start:
            paragraphStyle.alignment = .left
        case TextAlignHorizontal.Center:
            paragraphStyle.alignment = .center
        case TextAlignHorizontal.End:
            paragraphStyle.alignment = .right
        default:
            paragraphStyle.alignment = .left
        }
        
        var attributes: [NSAttributedString.Key : Any] = [:]
        attributes[.paragraphStyle] = paragraphStyle
        
        if let color = cgcolor(textInstruction.textStyleState.fontColorToken, transparency: textInstruction.textStyleState.fontColorTransparency) {
            attributes[.foregroundColor] = color
        }
        
        let attributedString = NSAttributedString(string: textInstruction.text, attributes: attributes)
        let line = CTLineCreateWithAttributedString(attributedString)
        
        context.saveGState()
        context.translateBy(x: coordinateXY.x, y: coordinateXY.y)
        context.textPosition = CGPoint(x: 0, y: 0)
        CTLineDraw(line, context)
        context.restoreGState()
    }
    
    private func strokePath(_ geometryXY: Geometry) {
        if let lineXY = geometryXY as? LinearGeometry {
            strokePath(lineXY.coordinates)
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
    
    private func strokePath(_ coordinates: [any Coordinate]) {
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
    
    private func placeSymbolsAlongLine(lineXY: LinearGeometry, lineStyle: LineStyle) {
        
        let intervalPx = screenResolution.pixels(mm: lineStyle.intervalLength)
        
        for lineSymbol in lineStyle.symbols {
            
            guard let svg = portrayalCatalogue.symbolSVGByName[lineSymbol.reference] else {
                continue
            }
            
            let symbolOffsetRelativeToViewBox = Vector2D(x: screenResolution.pixels(mm: svg.viewBox.x),
                                                         y: screenResolution.pixels(mm: svg.viewBox.y))
            
            let symbolHalfWidthPx = screenResolution.pixels(mm: svg.width / 2.0)
            var distanceToNextSymbolPx = screenResolution.pixels(mm: lineSymbol.position)
            
            for (i, segmentEndXY) in lineXY.coordinates.enumerated() {
                if i == 0 {
                    continue
                }
                
                guard let segmentStartXY = lineXY.coordinate(index: i, skip: -1) else {
                    continue
                }
                
                let segmentLengthPx = segmentStartXY.distance2D(to: segmentEndXY)
                
                if distanceToNextSymbolPx > segmentLengthPx {
                    distanceToNextSymbolPx -= segmentLengthPx
                    continue
                }
                
                let unitAlongSegment = Vector2D.unit(from: segmentStartXY, to: segmentEndXY)
                
                repeat {
                    
                    var rotation = unitAlongSegment.direction()
                    
                    // adjust rotation if close to start or end of segment
                    let distanceFromNextSegmentPx = segmentLengthPx - distanceToNextSymbolPx
                    if distanceFromNextSegmentPx < symbolHalfWidthPx, let nextSegmentEndXY = lineXY.coordinate(index: i, skip: 1) {
                        let stepAlongNextSegment = Vector2D.unit(from: segmentEndXY, to: nextSegmentEndXY).scale(symbolHalfWidthPx - distanceFromNextSegmentPx)
                        let bisector = stepAlongNextSegment.add(unitAlongSegment.scale(distanceFromNextSegmentPx + symbolHalfWidthPx))
                        rotation = bisector.direction()
                    } else if distanceToNextSymbolPx < symbolHalfWidthPx, let prevSegmentStartXY = lineXY.coordinate(index: i, skip: 2) {
                        let stepAlongPrevSegment = Vector2D.unit(from: prevSegmentStartXY, to: segmentStartXY).scale(symbolHalfWidthPx - distanceToNextSymbolPx)
                        let bisector = stepAlongPrevSegment.add(unitAlongSegment.scale(distanceToNextSymbolPx + symbolHalfWidthPx))
                        rotation = bisector.direction()
                    }
                    
                    let translation = unitAlongSegment.scale(distanceToNextSymbolPx).add(segmentStartXY)
                    
                    context.saveGState()
                    context.translateBy(x: translation.x, y: translation.y)
                    context.rotate(by: rotation)
                    context.translateBy(x: symbolOffsetRelativeToViewBox.x, y: symbolOffsetRelativeToViewBox.y)
                    svg.draw(context: context, screenResolution: screenResolution, colorPalette: colorPalette)
                    context.restoreGState()

                    distanceToNextSymbolPx += intervalPx
                    
                } while distanceToNextSymbolPx < segmentLengthPx
                
                distanceToNextSymbolPx -= segmentLengthPx
            }
        }
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
