//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

struct ViewingGroup {
    
    /*
     <viewingGroup id="11050">
        <description>
           <name>no data [colour NODTA, AP(NODATA03)], unsurveyed (UNSARE), incompletely surveyed area  </name>
           <description>Base: A, B - Chart Furniture</description>
           <language>eng</language>
        </description>
     </viewingGroup>
     */
    
    let id: String
    let description: Description
    
    static func create(_ kv: [String: String], id: String, description: Description) -> ViewingGroup? {
        return ViewingGroup(id: id, description: description)
    }

    
}
