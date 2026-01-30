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

struct SVGPath: SVGShape {
    
    /*
     <path d=" M -3.5,0 L -0.5,0" class="sl f0 sCHGRD" stroke-width="0.96" />
     <path d=" M 12.12,5.13 L 12.12,8.42 L 8.94,8.42 L 8.94,9.54 L 12.12,9.54 L 12.12,16.38 L 10.06,15.92 L 8.19,14.51 L 6.4,14.51 L 8.94,16.38 L 12.69,18.17 L 16.15,16.38 L 18.69,14.51 L 17.19,14.51 L 14.94,15.92 L 12.87,16.38 L 12.87,9.54 L 16.15,9.54 L 16.15,8.42 L 12.87,8.42 L 12.87,5.13 L 12.12,5.13" class="sl f0 sCHMGF" stroke-width="0.32" />
     */
    
    public let classParts: [String]
    public let strokeWidth: Double?
    public let fillOpacity: Double?
    public let pathCommands: [PathCommand]
    
    public func draw(context: CGContext, screenResolution: ScreenResolution, colorPalette: ColorPalette) {
        
        context.saveGState()
        
        var doFill = false
        for classPart in classParts {
            for e in colorPalette.css.entriesByClassSelector[classPart] ?? [] {
                if let _ = e as? CSS.DisplayNone {
                    context.restoreGState()
                    return
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

        let path = CGMutablePath()
        for pathCommand in pathCommands {
            pathCommand.execute(path: path, sr: screenResolution)
        }
        context.addPath(path)
        
        context.strokePath()
        if doFill {
            context.fillPath()
        }
        
        context.restoreGState()
    }
    
    static func create(_ kv: [String: String]) -> SVGPath? {
        guard let d = kv["d"], let cssClass = kv["class"] else {
            return nil
        }
        
        let classParts = cssClass.components(separatedBy: " ")
        let strokeWidth = kv["stroke-width"].flatMap(Double.init)
        let fillOpacity = kv["fill-opacity"].flatMap(Double.init)

        var pathCommands: [PathCommand] = []
        
        var currentCommand = ""
        var currentString = ""
        var currentNumbers: [Double] = []
        for c in d {
            switch (c) {
            case "M", "L":
                currentCommand = String(c)
                currentString = ""
            case "Z":
                pathCommands.append(Z())
                currentCommand = ""
                currentString = ""
                currentNumbers.removeAll()
            case ",":
                if let num = Double(currentString) {
                    currentNumbers.append(num)
                }
                currentString = ""
            case " ":
                if currentCommand.count == 1, currentNumbers.count == 2, let x = currentNumbers.first, let y = currentNumbers.last {
                    switch (currentCommand) {
                    case "M":
                        pathCommands.append(M(x: x, y: y))
                    case "L":
                        pathCommands.append(L(x: x, y: y))
                    default:
                        print("ERROR: unexpected path command: \(currentCommand)")
                        break
                    }

                    currentCommand = ""
                    currentString = ""
                    currentNumbers.removeAll()
                } else {
                    if let num = Double(currentString) {
                        currentNumbers.append(num)
                    }
                    currentString = ""
                    
                    if currentCommand.count == 1, currentNumbers.count == 2, let x = currentNumbers.first, let y = currentNumbers.last {
                        switch (currentCommand) {
                        case "M":
                            pathCommands.append(M(x: x, y: y))
                        case "L":
                            pathCommands.append(L(x: x, y: y))
                        default:
                            print("ERROR: unexpected path command: \(currentCommand)")
                            break
                        }

                        currentCommand = ""
                        currentString = ""
                        currentNumbers.removeAll()
                    }

                }
            default:
                currentString.append(c)
                break
            }
        }
        
        // after last
        if currentCommand.count == 1 {
            
            if let num = Double(currentString) {
                currentNumbers.append(num)
            }
            currentString = ""
            
            if currentCommand == "Z" {
                pathCommands.append(Z())
            } else if currentNumbers.count == 2, let x = currentNumbers.first, let y = currentNumbers.last {
                switch (currentCommand) {
                case "M":
                    pathCommands.append(M(x: x, y: y))
                case "L":
                    pathCommands.append(L(x: x, y: y))
                default:
                    print("ERROR: unexpected path command: \(currentCommand)")
                    break
                }
            }
        }
        
        if pathCommands.isEmpty {
            return nil
        }
        
        return SVGPath(classParts: classParts, strokeWidth: strokeWidth, fillOpacity: fillOpacity, pathCommands: pathCommands)
    }

    protocol PathCommand {
        
        func execute(path: CGMutablePath, sr: ScreenResolution)
        
    }
    
    struct M: PathCommand {
        
        let x: Double
        let y: Double
        
        func execute(path: CGMutablePath, sr: ScreenResolution) {
            path.move(to: CGPoint(x: sr.pixels(mm: x), y: sr.pixels(mm: -y)))
        }
        
    }
    
    struct L: PathCommand {
        
        let x: Double
        let y: Double
        
        func execute(path: CGMutablePath, sr: ScreenResolution) {
            path.addLine(to: CGPoint(x: sr.pixels(mm: x), y: sr.pixels(mm: -y)))
        }
        
    }

    struct Z: PathCommand {
        
        func execute(path: CGMutablePath, sr: ScreenResolution) {
            path.closeSubpath()
        }
        
    }
    
}
