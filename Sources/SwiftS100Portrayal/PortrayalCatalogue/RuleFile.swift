//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

struct RuleFile {
    
    /*
     <ruleFile id="Coastline">
        <description>
           <name>Coastline</name>
           <description>Rules for feature type Coastline</description>
           <language>eng</language>
        </description>
        <fileName>Coastline.lua</fileName>
        <fileType>Rule</fileType>
        <fileFormat>LUA</fileFormat>
        <ruleType>SubTemplate</ruleType>
     </ruleFile>
     */
    
    /*
     <ruleFile id="NavwarnAreaAffected">
         <description>
             <name>NavwarnAreaAffected</name>
             <description>NavwarnAreaAffected</description>
             <language>eng</language>
         </description>
         <fileName>NavwarnAreaAffected.xsl</fileName>
         <fileType>Rule</fileType>
         <fileFormat>XSLT</fileFormat>
         <ruleType>SubTemplate</ruleType>
     </ruleFile>
     */
    
    let id: String
    let description: Description
    let fileName: String
    let fileType: String
    let fileFormat: String
    let ruleType: String
    
    let ruleLanguage: RuleLanguage
    
    enum RuleLanguage {
        case LUA
        case XSLT
    }
    
    static func create(_ kv: [String: String], id: String, description: Description) -> RuleFile? {
        guard let fileName = kv["fileName"] else {
            return nil
        }
        guard let fileType = kv["fileType"] else {
            return nil
        }
        guard let fileFormat = kv["fileFormat"] else {
            return nil
        }
        guard let ruleType = kv["ruleType"] else {
            return nil
        }

        let ruleLanguage: RuleLanguage
        switch fileFormat {
        case "LUA":
            ruleLanguage = .LUA
        case "XSLT":
            ruleLanguage = .XSLT
        default:
            return nil
        }
        
        return RuleFile(id: id, description: description, fileName: fileName, fileType: fileType, fileFormat: fileFormat, ruleType: ruleType, ruleLanguage: ruleLanguage)
    }
    
}
