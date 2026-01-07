//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

struct Symbol {
    
    /*
     <symbol id="WATFAL01">
        <description>
           <name>WATFAL01</name>
           <description>Waterfall (conspicuous)</description>
           <language>eng</language>
        </description>
        <fileName>WATFAL01.svg</fileName>
        <fileType>Symbol</fileType>
        <fileFormat>SVG</fileFormat>
     </symbol>
     */
    
    let id: String
    let description: Description
    let fileName: String
    let fileType: String
    let fileFormat: String
    
    static func create(_ kv: [String: String], id: String, description: Description) -> Symbol? {
        guard let fileName = kv["fileName"] else {
            return nil
        }
        guard let fileType = kv["fileType"] else {
            return nil
        }
        guard let fileFormat = kv["fileFormat"] else {
            return nil
        }
        return Symbol(id: id, description: description, fileName: fileName, fileType: fileType, fileFormat: fileFormat)
    }
    
}
