//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

struct StyleSheet {
    
    /*
     <styleSheet id="duskSvgStyle">
        <description>
           <name>Dusk</name>
           <description>CSS file for dusk palette</description>
           <language>eng</language>
        </description>
        <fileName>duskSvgStyle.css</fileName>
        <fileType>StyleSheet</fileType>
        <fileFormat>XML</fileFormat> <!-- fileFormat will need to be updated when Part 9 is updated to include CSS file format. -->

     */
    
    let id: String
    let description: Description
    let fileName: String
    let fileType: String
    let fileFormat: String
    
    static func create(_ kv: [String: String], id: String, description: Description) -> StyleSheet? {
        guard let fileName = kv["fileName"] else {
            return nil
        }
        guard let fileType = kv["fileType"] else {
            return nil
        }
        guard let fileFormat = kv["fileFormat"] else {
            return nil
        }
        return StyleSheet(id: id, description: description, fileName: fileName, fileType: fileType, fileFormat: fileFormat)
    }

}
