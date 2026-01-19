//
//  Test.swift
//  SwiftS100Portrayal
//

import Testing
import Foundation
@testable import SwiftS100Portrayal
@testable import SwiftS101
@testable import SwiftS100FeatureCatalogue

struct LuaRuleExecutorTests {

    @Test func testPortrayal101AA00DS0003() async throws {
        guard let pc = PortrayalCatalogueParser.parse(name: "101_PC_2.0.0") else {
            Issue.record("Could not parse S-101 portrayal catalogue")
            return
        }
        
        guard let fc = FeatureCatalogues.defaultVersion(prodSpecNr: 101) else {
            Issue.record("Could not parse S-101 feature catalogue")
            return
        }
        
        // from https://github.com/iho-ohi/S-101-Test-Datasets/blob/main/S-101_Test_DataSets/cells/101AA00DS0003/9/101AA00DS0003.000
        guard let testDataURL = Bundle.module.url(forResource: "TestResources/101AA00DS0003", withExtension: "000") else {
            Issue.record("Could not load test data")
            return
        }

        let (dsf, _) = DataSetFileParser.parse(data: try Data.init(contentsOf: testDataURL))
        guard let dsf = dsf else {
            Issue.record("Could not parse test data")
            return
        }

        let lre = LuaRuleExecutor(portrayalCatalogue: pc, featureCatalogue: fc)
        lre.setUp(dsf: dsf)
        let drawingCommands = lre.portrayal(features: dsf.featureTypeRecords())
        // #expect(!drawingCommands.isEmpty)
    }
    
    @Test func testPortrayal101AA00DS0016() async throws {
        guard let pc = PortrayalCatalogueParser.parse(name: "101_PC_2.0.0") else {
            Issue.record("Could not parse S-101 portrayal catalogue")
            return
        }
        
        guard let fc = FeatureCatalogues.defaultVersion(prodSpecNr: 101) else {
            Issue.record("Could not parse S-101 feature catalogue")
            return
        }
        
        // from https://github.com/iho-ohi/S-101-Test-Datasets/blob/main/S-101_Test_DataSets/cells/101AA00DS0003/9/101AA00DS0016.000
        guard let testDataURL = Bundle.module.url(forResource: "TestResources/101AA00DS0016", withExtension: "000") else {
            Issue.record("Could not load test data")
            return
        }

        let (dsf, _) = DataSetFileParser.parse(data: try Data.init(contentsOf: testDataURL))
        guard let dsf = dsf else {
            Issue.record("Could not parse test data")
            return
        }

        let lre = LuaRuleExecutor(portrayalCatalogue: pc, featureCatalogue: fc)
        lre.setUp(dsf: dsf)
        let drawingCommands = lre.portrayal(features: dsf.featureTypeRecords())
        // #expect(!drawingCommands.isEmpty)
    }

}
