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

public struct SVGCircle: SVGShape {
    
    /*
     <circle class="pivotPoint layout" fill="none" cx="0" cy="0" r="1"/>
     <circle class="fCHBLK" cx="-2.97" cy="-0.5" r="0.16"/>
     */
    
    public let classParts: [String]
    public let fill: String?
    public let strokeWidth: Double?
    public let fillOpacity: Double?
    public let cx: Double
    public let cy: Double
    public let r: Double
    
    public func draw(context: CGContext, screenResolution: ScreenResolution, colorPalette: ColorPalette) {
        
        if classParts.contains("pivotPoint") || classParts.contains("layout") {
            return
        }
        
        context.saveGState()
        
        let cxpx = screenResolution.pixels(mm: cx)
        let cypx = screenResolution.pixels(mm: -cy)
        let rpx = screenResolution.pixels(mm: r)
        
        if let strokeWidth = strokeWidth {
            context.setLineWidth(screenResolution.pixels(mm: strokeWidth))
        } else {
            // TODO: look in css as well?
            context.setLineWidth(screenResolution.pixels(mm: 0.5))
        }
        
        // TODO: color from something?
        context.setStrokeColor(CGColor(red: 1, green: 0, blue: 0, alpha: 1))

        let rect = CGRect(x: cxpx - rpx, y: cypx - rpx, width: 2.0 * rpx, height: 2.0 * rpx)
        context.addEllipse(in: rect)

        context.strokePath()
        
        // TODO: handle fill?

        context.restoreGState()
    }
    
    static func create(_ kv: [String: String]) -> SVGCircle? {
        guard let cssClass = kv["class"],
                let cx = kv["cx"].flatMap(Double.init),
                let cy = kv["cy"].flatMap(Double.init),
                let r = kv["r"].flatMap(Double.init) else {
            return nil
        }
        
        let classParts = cssClass.components(separatedBy: " ")
        let fill = kv["fill"]
        let strokeWidth = kv["stroke-width"].flatMap(Double.init)
        let fillOpacity = kv["fill-opacity"].flatMap(Double.init)
        
        return SVGCircle(classParts: classParts, fill: fill, strokeWidth: strokeWidth, fillOpacity: fillOpacity, cx: cx, cy: cy, r: r)
    }
    
}
