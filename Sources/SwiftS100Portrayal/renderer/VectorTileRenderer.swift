//
//  File.swift
//  swift-s100-portrayal
//

import Foundation
import SwiftGeo
import SwiftVectorTile
import OrderedCollections

/**
 * A Renderer that can create Mapbox Vector Tile (MVT) and/or Maplibre Vector Tile (MLT).
 */
public class VectorTileRenderer: Renderer {
    
    public let projection: any Projection
    public let screenResolution: ScreenResolution
    private let colorPalette: ColorPalette
    private let portrayalCatalogue: PortrayalCatalogue
    
    private let encoder: VTEncoder
    
    public enum VectorTileVariant {
        case MVT
    }
    
    public init(projection: WebMercatorTile, colorPalette: ColorPalette, screenResolution: ScreenResolution, portrayalCatalogue: PortrayalCatalogue, variant: VectorTileVariant) {
        self.projection = FlipScreenYProjection(wrappedProjection: projection)
        self.colorPalette = colorPalette
        self.screenResolution = screenResolution
        self.portrayalCatalogue = portrayalCatalogue
        
        switch variant {
        case .MVT:
            self.encoder = MVTEncoderHelper(projection: self.projection)
        }
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
        } else if let areaFillReference = drawingCommand as? AreaFillReference {
            add(geometry: geometry, areaFillReference: areaFillReference)
        } else if let _ = drawingCommand as? NullInstruction {
            // nothing to do
        } else {
            print("TODO: handle drawing command: \(type(of: drawingCommand))")
        }
    }
    
    private func add(geometry: Geometry, colorFill: ColorFill) {
        encoder.startFeature(name: "ColorFill")
        if let color = color(colorFill.token, transparency: colorFill.transparency) {
            encoder.setAttribute(name: "fill-color", value: color)
        }
        encoder.setGeometry(geometry)
        encoder.appendFeature()
    }
    
    private func add(geometry: Geometry, lineInstruction: LineInstruction) {
        guard let lineStyle = lineInstruction.lineStyles(portrayalCatalogue: portrayalCatalogue).first else {
            return
        }

        encoder.startFeature(name: "LineInstruction")
        
        if let color = color(lineStyle.pen.color) {
            encoder.setAttribute(name: "line-color", value: color)
        }
        encoder.setAttribute(name: "line-width", value: screenResolution.pixels(mm: lineStyle.pen.width))
        
        encoder.setGeometry(geometry)
        encoder.appendFeature()
    }
    
    private func add(geometry: Geometry, pointInstruction: PointInstruction) {
        encoder.startFeature(name: "PointInstruction")
        encoder.setGeometry(geometry)
        encoder.appendFeature()
    }

    private func add(geometry: Geometry, textInstruction: TextInstruction) {
        encoder.startFeature(name: "TextInstruction")
        encoder.setAttribute(name: "text", value: textInstruction.text)
        encoder.setGeometry(geometry)
        encoder.appendFeature()
    }
    
    private func add(geometry: Geometry, areaFillReference: AreaFillReference) {
        encoder.startFeature(name: "AreaFillReference")
        encoder.setGeometry(geometry)
        encoder.appendFeature()
    }
    
    private func color(_ token: String) -> String? {
        if let color = colorPalette.itemByToken[token]?.srgb {
            return "rgb(\(color.red), \(color.green), \(color.blue))"
        }
        return nil
    }
    
    private func color(_ token: String, transparency: Double) -> String? {
        if let color = colorPalette.itemByToken[token]?.srgb {
            
            if transparency > 0 {
                return "rgba(\(color.red), \(color.green), \(color.blue), \(1.0 - transparency))"
            }
            
            return "rgb(\(color.red), \(color.green), \(color.blue))"
        }
        return nil
    }

    public func output() -> RendererOutput? {
        return encoder.output()
    }
    
}

protocol VTEncoder {
    
    func startFeature(name: String)
    
    func setAttribute(name: String, value: Any)
    
    func setGeometry(_ geometry: Geometry)
    
    func appendFeature()
    
    func output() -> RendererOutput?
    
}

private class MVTEncoderHelper: VTEncoder {
    
    
    let projection: Projection
    
    let vectorTileEncoder = VectorTileEncoder()
    
    var name: String?
    var attributes: [String: VectorTileAttribute] = [:]
    var geometry: Geometry?
    
    init(projection: Projection) {
        self.projection = projection
    }
    
    func startFeature(name: String) {
        self.name = name
        self.attributes.removeAll()
        self.geometry = nil
    }
    
    func setAttribute(name: String, value: Any) {
        if let s = value as? String {
            attributes[name] = .attString(s)
        } else if let i = value as? Int {
            attributes[name] = .attInt(Int64(i))
        } else if let f = value as? Float {
            attributes[name] = .attFloat(f)
        } else if let d = value as? Double {
            attributes[name] = .attDouble(d)
        } else {
            print("TODO: unsupported MVT attribute type: \(type(of: value))")
        }
    }

    func setGeometry(_ geometry: Geometry) {
        self.geometry = projection.forward(geometry: geometry)
    }
    
    func appendFeature() {
        if let name, let geometry {
            vectorTileEncoder.addFeature(layerName: name, attributes: attributes, geometry: geometry)
        }
        self.name = nil
        self.attributes.removeAll()
        self.geometry = nil
    }
    
    func output() -> RendererOutput? {
        let data = vectorTileEncoder.encode()
        return RendererOutput(data: data, contentType: "application/vnd.mapbox-vector-tile")
    }
    
}
