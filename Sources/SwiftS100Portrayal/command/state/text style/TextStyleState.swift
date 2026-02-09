//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

public class TextStyleState {
    
    var fontColorToken: String = ""
    var fontColorTransparency: Double = 0.0

    var fontSize: Double = 10
    
    var textAlignHorizontal = TextAlignHorizontal.Start
    var textAlignVertical = TextAlignVertical.Bottom
    
    public func toRecord() -> Record {
        return .init(fontColorToken: fontColorToken, fontColorTransparency: fontColorTransparency, fontSize: fontSize, textAlignHorizontal: textAlignHorizontal, textAlignVertical: textAlignVertical)
    }

    public struct Record: Sendable {
        
        let fontColorToken: String
        let fontColorTransparency: Double

        let fontSize: Double
        
        let textAlignHorizontal: String
        let textAlignVertical: String
        
    }
    
}
