//
//  Test.swift
//  SwiftS100Portrayal
//

import Testing
import Foundation
import SwiftGeo
import SwiftS101
import SwiftS100FeatureCatalogue
@testable import SwiftS100Portrayal

struct LuaRuleExecutorTests {
        
    @Test func testPortrayal101AA00DS0001() async throws {
        try drawSingle(dataSetId: "101AA00DS0001")
    }

    @Test func testPortrayalAllS101TestDatasets() async throws {
        // https://github.com/iho-ohi/S-101-Test-Datasets/tree/main/S-101_Test_DataSets/cells
        guard let folderURL = Bundle.module.url(forResource: "TestResources", withExtension: nil) else {
            Issue.record("Could not find TestResources directory")
            return
        }
        
        let fileManager = FileManager.default
        do {
            let urls = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: [])
            for url in urls {
                guard let fileName = url.pathComponents.last else {
                    continue
                }
                
                if !(fileName.starts(with: "101") && fileName.hasSuffix(".000")) {
                    continue
                }
                
                let dataSetId = String(fileName.split(separator: ".")[0])
                try drawSingle(dataSetId: dataSetId)
            }
        } catch {
            Issue.record("Trouble iterating files")
            return
        }
    }
    
    func drawSingle(dataSetId: String) throws {
        guard let pc = PortrayalCatalogueParser.parse(bundle: Bundle.module, portrayalCataloguePath: "TestResources/101_PC_2.0.0") else {
            Issue.record("Could not find or parse S-101 portrayal catalogue")
            return
        }

        guard let featureCatalogueXMLURL = Bundle.module.url(forResource: "TestResources/101_Feature_Catalogue_2.0.0", withExtension: "xml") else {
            Issue.record("could not find S-101 portrayal catalogue XML file")
            return
        }
        
        guard let fc = FeatureCatalogueParser.parse(url: featureCatalogueXMLURL) else {
            Issue.record("Could not parse S-101 feature catalogue")
            return
        }

        guard let testDataURL = Bundle.module.url(forResource: "TestResources/\(dataSetId)", withExtension: "000") else {
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
        let featureDrawingCommands = lre.portrayal(features: dsf.featureTypeRecords())
        #expect(!featureDrawingCommands.isEmpty)
        
        guard let boundingBox = dsf.boundingBox() else {
            Issue.record("Dataset has no bounding box")
            return
        }
        
        let widthPoint = 600
        let heightPoint = 600
        
        let projection = LLXYProjection(bbox: boundingBox, widthPoint: widthPoint, heightPoint: heightPoint, pixelsPrPoint: 2)
        
        guard let colorPalette = pc.colorPaletteByName["Day"] else {
            Issue.record("Could not find color palette")
            return
        }
        
        let screenResolution = ScreenResolution(pixelsPrPoint: 2)
        
        guard let renderer = CoreGraphicsRenderer(widthPoint: widthPoint, heightPoint: heightPoint, pixelsPrPoint: 2, projection: projection, colorPalette: colorPalette, screenResolution: screenResolution, portrayalCatalogue: pc) else {
            Issue.record("Could not create renderer")
            return
        }
        
        let geometryCreator = DefaultGeometryCreator()
        
        // an extra run-through to find lines suppressing other lines..
        let lineSuppressor = LineSuppressor(dsf: dsf, creator: geometryCreator)
        for featureDrawingCommand in featureDrawingCommands {
            let drawingCommand = featureDrawingCommand.drawingCommand
            if !(drawingCommand is LineInstruction || drawingCommand is LineInstructionUnsuppressed) {
                continue
            }
            
            guard let recordIdentifier = LuaRuleExecutor.createRecordIdentifier(recordId: featureDrawingCommand.featureId) else {
                Issue.record("Could not create record identifier from \(featureDrawingCommand.featureId)")
                return
            }
            
            guard let feature = dsf.record(forIdentifier: recordIdentifier) as? FeatureTypeRecord else {
                Issue.record("Could not find feature record from \(recordIdentifier)")
                return
            }
            
            var geometry = feature.createGeometry(dsf: dsf, creator: geometryCreator)
            
            if let drawingCommandGeometry = featureDrawingCommand.drawingCommand.geometryState.geometry(dsf: dsf, geometry: geometry, geometryCreator: geometryCreator, renderer: renderer) {
                geometry = drawingCommandGeometry
            }
            
            lineSuppressor.add(featureRecordIdentifier: recordIdentifier, geometry: geometry)
        }

        for featureDrawingCommand in featureDrawingCommands {
            guard let recordIdentifier = LuaRuleExecutor.createRecordIdentifier(recordId: featureDrawingCommand.featureId) else {
                Issue.record("Could not create record identifier from \(featureDrawingCommand.featureId)")
                return
            }
            
            guard let feature = dsf.record(forIdentifier: recordIdentifier) as? FeatureTypeRecord else {
                Issue.record("Could not find feature record from \(recordIdentifier)")
                return
            }
            
            var geometry = feature.createGeometry(dsf: dsf, creator: geometryCreator)
            
            if let drawingCommandGeometry = featureDrawingCommand.drawingCommand.geometryState.geometry(dsf: dsf, geometry: geometry, geometryCreator: geometryCreator, renderer: renderer) {
                geometry = drawingCommandGeometry
            }
            
            if featureDrawingCommand.drawingCommand is LineInstruction  {
                geometry = lineSuppressor.geometryAfterSuppression(featureRecordIdentifier: recordIdentifier, geometry: geometry)
            }
            
            renderer.add(geometry: geometry, drawingCommand: featureDrawingCommand.drawingCommand)
        }
        
        guard let imageData = renderer.asPNGData() else {
            Issue.record("Could not encode as PNG")
            return
        }
        
        do {
            try imageData.write(to: URL(fileURLWithPath: "/tmp/\(dataSetId).000.png"))
        } catch {
            Issue.record("Could not write PNG. \(error)")
            return
        }
        
    }

}
