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
        
        context.saveGState()
        
        let cxpx = screenResolution.pixels(mm: cx)
        let cypx = screenResolution.pixels(mm: -cy)
        let rpx = screenResolution.pixels(mm: r)
        
        var doStroke = false
        var doFill = false
        for classPart in classParts {
            for e in colorPalette.css.entriesByClassSelector[classPart] ?? [] {
                if let _ = e as? CSS.DisplayNone {
                    context.restoreGState()
                    return
                }
                if let stroke = e as? CSS.Stroke, stroke.color != nil {
                    doStroke = true
                }
                if let fill = e as? CSS.Fill, fill.color != nil {
                    doFill = true
                }
                e.ececute(context: context, screenResolution: screenResolution, colorPalette: colorPalette)
            }
        }
        
        if let strokeWidth = strokeWidth {
            context.setLineWidth(screenResolution.pixels(mm: strokeWidth))
        }

        let rect = CGRect(x: cxpx - rpx, y: cypx - rpx, width: 2.0 * rpx, height: 2.0 * rpx)
        context.addEllipse(in: rect)

        if doStroke, doFill {
            context.drawPath(using: .eoFillStroke)
        } else if doStroke {
            context.drawPath(using: .stroke)
        } else if doFill {
            context.drawPath(using: .eoFill)
        }

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
