//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

struct RuleFile {
    
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
