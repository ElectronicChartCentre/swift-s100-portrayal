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
        if let lineInstruction = drawingCommand as? LineInstruction {
            add(geometry: geometry, lineInstruction: lineInstruction)
        } else {
            print("TODO: handle \(drawingCommand)")
        }
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
        
        print("DEBUG: intervalLength: \(lineStyle.intervalLength), dashs: \(lineStyle.dashs) ")

        context.setLineWidth(screenResolution.pixels(mm: lineStyle.pen.width))
        
        if let polygonXY = geometryXY as? SwiftGeo.Polygon {
            strokePath(polygonXY.shell.coordinates)
            for hole in polygonXY.holes {
                strokePath(hole.coordinates)
            }
        } else if let lineStringXY = geometryXY as? SwiftGeo.LineString {
            strokePath(lineStringXY.coordinates)
        } else {
            print("ERROR: unsupported geometry type for LineInstruction")
        }
        
        context.restoreGState()
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
            // TODO: cache?
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
