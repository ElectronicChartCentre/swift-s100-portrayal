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

public protocol SVGShape {
    
    func draw(context: CGContext, screenResolution: ScreenResolution, colorPalette: ColorPalette)
    
}
