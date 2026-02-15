//
//  Test.swift
//  SwiftS100Portrayal
//

import Testing
import Foundation
@testable import SwiftS100Portrayal

struct PortrayalCatalogueParserTests {

    @Test func parseS101PortrayalCatalogue() async throws {
        
        guard let pc = PortrayalCatalogueParser.parse(bundle: Bundle.module, portrayalCataloguePath: "TestResources/101_PC_2.0.0") else {
            Issue.record("Could not find or parse S-101 portrayal catalogue")
            return
        }

        #expect(pc.areaFillFileById.count == 25)
        #expect(pc.ruleFileById.count == 215)
        #expect(pc.symbolFileById.count == 718)
        // TODO: handle compositeLineStyle
        #expect(pc.lineStyleByName.count == 57)
        #expect(pc.colorProfileFileById.count == 1)
        #expect(pc.styleSheetFileById.count == 3)
        #expect(pc.viewingGroupById.count == 133)

        #expect(pc.colorPaletteByName.count == 3)
        for palette in pc.colorPaletteByName.values {
            #expect(palette.itemByToken.count == 67)
            #expect(palette.css.entriesByClassSelector.count == 140)
        }
        
        #expect(pc.symbolSVGByName.count == 718)
        #expect(pc.areaFillByName.count == 25)
    }
    
    @Test func parseS124PortrayalCatalogue() async throws {
        
        guard let pc = PortrayalCatalogueParser.parse(bundle: Bundle.module, portrayalCataloguePath: "TestResources/124_PC_2.0.0") else {
            Issue.record("Could not find or parse S-124 portrayal catalogue")
            return
        }
        
        #expect(pc.areaFillFileById.count == 1)
        #expect(pc.ruleFileById.count == 9)
        #expect(pc.symbolFileById.count == 5)
        #expect(pc.lineStyleByName.count == 2)
        #expect(pc.colorProfileFileById.count == 1)
        #expect(pc.styleSheetFileById.count == 3)
        #expect(pc.viewingGroupById.count == 3)
        
        #expect(pc.colorPaletteByName.count == 3)
        for palette in pc.colorPaletteByName.values {
            #expect(palette.itemByToken.count == 69)
            #expect(palette.css.entriesByClassSelector.count >= 142)
            #expect(palette.css.entriesByClassSelector.count <= 144)
        }

        #expect(pc.symbolSVGByName.count == 5)
        
    }

}
