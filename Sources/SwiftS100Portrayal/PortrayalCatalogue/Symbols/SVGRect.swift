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

public struct SVGRect: SVGShape {
    
    /*
     <rect class="svgBox layout" fill="none" x="-3.89" y="-3.9" height="7.78" width="7.78"/>
     */
    
    public let classParts: [String]
    public let fill: String?
    public let strokeWidth: Double?
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double
    
    public func draw(context: CGContext, screenResolution: ScreenResolution, colorPalette: ColorPalette) {
        
        if classParts.contains("pivotPoint") || classParts.contains("layout") {
            return
        }
        
        context.saveGState()
        
        let xpx = screenResolution.pixels(mm: x)
        let ypx = screenResolution.pixels(mm: -y)
        let wpx = screenResolution.pixels(mm: width)
        let hpx = screenResolution.pixels(mm: height)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: xpx, y: ypx))
        path.addLine(to: CGPoint(x: xpx, y: ypx - hpx))
        path.addLine(to: CGPoint(x: xpx + wpx, y: ypx - hpx))
        path.addLine(to: CGPoint(x: xpx + wpx, y: ypx))
        path.closeSubpath()
        
        if let strokeWidth = strokeWidth {
            context.setLineWidth(screenResolution.pixels(mm: strokeWidth))
        } else {
            // TODO: look in css as well?
            context.setLineWidth(screenResolution.pixels(mm: 0.5))
        }
        
        // TODO: color from something?
        context.setStrokeColor(CGColor(red: 1, green: 0, blue: 0, alpha: 1))

        context.addPath(path)
        context.strokePath()
        
        // TODO: handle fill?
        
        context.restoreGState()
    }
    
    static func create(_ kv: [String: String]) -> SVGRect? {
        
        guard let cssClass = kv["class"],
              let x = kv["x"].flatMap(Double.init),
              let y = kv["y"].flatMap(Double.init),
              let width = kv["width"].flatMap(Double.init),
              let height = kv["height"].flatMap(Double.init) else {
            return nil
        }
        
        let classParts = cssClass.components(separatedBy: " ")
        let fill = kv["fill"]
        let strokeWidth = kv["stroke-width"].flatMap(Double.init)
        
        return SVGRect(classParts: classParts, fill: fill, strokeWidth: strokeWidth, x: x, y: y, width: width, height: height)
    }
    
}
