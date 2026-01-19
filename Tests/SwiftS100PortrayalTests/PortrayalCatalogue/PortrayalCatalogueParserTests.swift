//
//  Test.swift
//  SwiftS100Portrayal
//

import Testing
import Foundation
@testable import SwiftS100Portrayal

struct PortrayalCatalogueParserTests {

    @Test func parseS101PortrayalCatalogue() async throws {
        
        guard let portrayalCatalogueXMLURL = Bundle.module.url(forResource: "TestResources/101_PC_2.0.0/portrayal_catalogue", withExtension: "xml") else {
            Issue.record("could not find S-101 portrayal catalogue XML file")
            return
        }
        
        guard let pc = PortrayalCatalogueParser.parse(portrayalCatalogueXMLURL: portrayalCatalogueXMLURL) else {
            Issue.record("Could not parse S-101 portrayal catalogue")
            return
        }

        #expect(pc.areaFillById.count == 25)
        #expect(pc.ruleFileById.count == 215)
        #expect(pc.symbolById.count == 718)
        #expect(pc.lineStyleById.count == 59)
        #expect(pc.colorProfileById.count == 1)
        #expect(pc.styleSheetById.count == 3)
        #expect(pc.viewingGroupById.count == 133)

    }
    
    @Test func parseS124PortrayalCatalogue() async throws {
        
        guard let portrayalCatalogueXMLURL = Bundle.module.url(forResource: "TestResources/124_PC_2.0.0/portrayal_catalogue", withExtension: "xml") else {
            Issue.record("could not find S-124 portrayal catalogue XML file")
            return
        }
        
        guard let pc = PortrayalCatalogueParser.parse(portrayalCatalogueXMLURL: portrayalCatalogueXMLURL) else {
            Issue.record("Could not parse S-124 portrayal catalogue")
            return
        }
        
        #expect(pc.areaFillById.count == 1)
        #expect(pc.ruleFileById.count == 9)
        #expect(pc.symbolById.count == 5)
        #expect(pc.lineStyleById.count == 2)
        #expect(pc.colorProfileById.count == 1)
        #expect(pc.styleSheetById.count == 3)
        #expect(pc.viewingGroupById.count == 3)

    }

}
