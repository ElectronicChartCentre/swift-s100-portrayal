//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

struct ColorProfile {
    
    /*
     <colorProfile id="1">
        <description>
           <name>Color Profile</name>
           <description>Color profile with day, dusk, and night color palettes</description>
           <language>eng</language>
        </description>
        <fileName>colorProfile.xml</fileName>
        <fileType>ColorProfile</fileType>
        <fileFormat>XML</fileFormat>
     </colorProfile>

     */
    
    let id: String
    let description: Description
    let fileName: String
    let fileType: String
    let fileFormat: String
    
    static func create(_ kv: [String: String], id: String, description: Description) -> ColorProfile? {
        guard let fileName = kv["fileName"] else {
            return nil
        }
        guard let fileType = kv["fileType"] else {
            return nil
        }
        guard let fileFormat = kv["fileFormat"] else {
            return nil
        }
        return ColorProfile(id: id, description: description, fileName: fileName, fileType: fileType, fileFormat: fileFormat)
    }

}
