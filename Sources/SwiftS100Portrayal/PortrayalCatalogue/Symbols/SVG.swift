//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

import SwiftGeo

#if canImport(CoreGraphics)
import CoreGraphics
#elseif canImport(Silica)
import Silica
#endif

public struct SVG {
    
    public let width: Double
    public let height: Double
    
    public let viewBox: SVGViewBox
    
    public let name: String
    public let shapes: [SVGShape]
    
    public func draw(context: CGContext, screenResolution: ScreenResolution, colorPalette: ColorPalette) {
        for shape in shapes {
            shape.draw(context: context, screenResolution: screenResolution, colorPalette: colorPalette)
        }
    }
    
}
