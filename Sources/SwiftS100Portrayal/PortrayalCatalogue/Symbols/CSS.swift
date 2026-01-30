//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

public struct CSS {
    
    let entriesByClassSelector: [String: [Entry]]
    
    static func createEntry(k: String, v: String) -> Entry? {
        
        switch (k) {
        case "display":
            if v == "none" {
                return DisplayNone()
            }
        case "stroke-width":
            if let value = Double(v) {
                return StrokeWidth(value: value)
            }
        case "stroke":
            if let color = Color.create(v) {
                return Stroke(color: color)
            }
        case "fill":
            if let color = Color.create(v) {
                return Fill(color: color)
            }
        default:
            break
        }
        
        print("DEBUG: unsupported CSS entry: \(k):\(v)")
        return nil
    }
    
    public protocol Entry {
        
    }
    
    public struct DisplayNone: Entry {
        
    }
    
    public struct StrokeWidth: Entry {
        
        public let value: Double
        
    }
    
    public struct Stroke: Entry {
        
        public let color: Color
        
    }
    
    public struct Fill: Entry {
        
        public let color: Color
        
    }

    
    public struct Color {
        
        public let r: Int
        public let g: Int
        public let b: Int
        
        static func create(_ def: String) -> Color? {
            if def == "red" {
                return Color(r: 255, g: 0, b: 0)
            }
            if def == "green" {
                return Color(r: 0, g: 255, b: 0)
            }
            if def == "blue" {
                return Color(r: 0, g: 0, b: 255)
            }

            if def.hasPrefix("#"), def.count == 7 {
                if let r = Int(def.dropFirst().dropLast(4), radix: 16),
                    let g = Int(def.dropFirst(3).dropLast(2), radix: 16),
                    let b = Int(def.dropFirst(5), radix: 16) {
                    return Color(r: r, g: g, b: b)
                }
            }
            
            print("DEBUG: unsupported CSS color: \(def)")
            return nil
        }
        
    }
    
}
