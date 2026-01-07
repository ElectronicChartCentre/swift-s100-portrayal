//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

struct AreaFill {
    
    /*
     <areaFill id="DQUALB01">
        <description>
           <name>DQUALB01</name>
           <description>pattern of symbols for a chart with 50m accuracy from standard survey based on lines of continuous soundings</description>
           <language>eng</language>
        </description>
        <fileName>DQUALB01.xml</fileName>
        <fileType>AreaFill</fileType>
        <fileFormat>XML</fileFormat>
     </areaFill>

     */
    
    let id: String
    let description: Description
    let fileName: String
    let fileType: String
    let fileFormat: String
    
    static func create(_ kv: [String: String], id: String, description: Description) -> AreaFill? {
        guard let fileName = kv["fileName"] else {
            return nil
        }
        guard let fileType = kv["fileType"] else {
            return nil
        }
        guard let fileFormat = kv["fileFormat"] else {
            return nil
        }
        return AreaFill(id: id, description: description, fileName: fileName, fileType: fileType, fileFormat: fileFormat)
    }
    
}
