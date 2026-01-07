//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

struct LineStyle {
    
    /*
     <lineStyle id="RCRTCL13">
        <description>
           <name>RCRTCL13</name>
           <description>regulated two-way recommended route centreline, based on fixed-marks</description>
           <language>eng</language>
        </description>
        <fileName>RCRTCL13.xml</fileName>
        <fileType>LineStyle</fileType>
        <fileFormat>XML</fileFormat>
     </lineStyle>

     */
    
    let id: String
    let description: Description
    let fileName: String
    let fileType: String
    let fileFormat: String
    
    static func create(_ kv: [String: String], id: String, description: Description) -> LineStyle? {
        guard let fileName = kv["fileName"] else {
            return nil
        }
        guard let fileType = kv["fileType"] else {
            return nil
        }
        guard let fileFormat = kv["fileFormat"] else {
            return nil
        }
        return LineStyle(id: id, description: description, fileName: fileName, fileType: fileType, fileFormat: fileFormat)
    }

}
