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
    public let style: SVGShapeStyle
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double
    
    public func draw(context: CGContext, screenResolution: ScreenResolution, colorPalette: ColorPalette) {
        
        context.saveGState()
        
        let xpx = screenResolution.pixels(mm: x)
        let ypx = screenResolution.pixels(mm: -y)
        let wpx = screenResolution.pixels(mm: width)
        let hpx = screenResolution.pixels(mm: height)

        var doStroke = false
        var doFill = false
        for classPart in classParts {
            for e in colorPalette.css.entriesByClassSelector[classPart] ?? [] {
                if let _ = e as? CSS.DisplayNone {
                    context.restoreGState()
                    return
                }
                if e is CSS.Stroke {
                    doStroke = true
                }
                if let fill = e as? CSS.Fill, fill.color != nil {
                    doFill = true
                }
                e.ececute(context: context, screenResolution: screenResolution, colorPalette: colorPalette, style: style)
            }
        }

        let path = CGMutablePath()
        path.move(to: CGPoint(x: xpx, y: ypx))
        path.addLine(to: CGPoint(x: xpx, y: ypx - hpx))
        path.addLine(to: CGPoint(x: xpx + wpx, y: ypx - hpx))
        path.addLine(to: CGPoint(x: xpx + wpx, y: ypx))
        path.closeSubpath()
        
        if let strokeWidth = style.strokeWidth {
            context.setLineWidth(screenResolution.pixels(mm: strokeWidth))
        }

        context.addPath(path)

        if doStroke, doFill {
            context.drawPath(using: .eoFillStroke)
        } else if doStroke {
            context.drawPath(using: .stroke)
        } else if doFill {
            context.drawPath(using: .eoFill)
        }

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
        let style = SVGShapeStyle.create(kv)
        
        return SVGRect(classParts: classParts, style: style, x: x, y: y, width: width, height: height)
    }
    
}
