//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

public class TextStyleState {
    
    var fontColorToken: String = ""
    var fontColorTransparency: Double = 0.0

    var fontSize: Double = 10
    var fontWeight: FontWeight.FontWeightVariant = .Medium
    var fontSlant: FontSlant.FontSlantVariant = .Upright
    
    var textAlignHorizontal = TextAlignHorizontal.Start
    var textAlignVertical = TextAlignVertical.Bottom
    
    var verticalOffset: Double = 0
    
    public func toRecord() -> Record {
        return .init(fontColorToken: fontColorToken, fontColorTransparency: fontColorTransparency, fontSize: fontSize, fontWeight: fontWeight, fontSlant: fontSlant, textAlignHorizontal: textAlignHorizontal, textAlignVertical: textAlignVertical, verticalOffset: verticalOffset)
    }

    public struct Record: Sendable {
        
        let fontColorToken: String
        let fontColorTransparency: Double

        let fontSize: Double
        let fontWeight: FontWeight.FontWeightVariant
        let fontSlant: FontSlant.FontSlantVariant
        
        let textAlignHorizontal: String
        let textAlignVertical: String
        
        let verticalOffset: Double
        
    }
    
}
