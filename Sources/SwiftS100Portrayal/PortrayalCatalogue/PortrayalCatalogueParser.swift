//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

// FoundationXML needed on Linux and does not exist on macOS..
#if canImport(FoundationXML)
import FoundationXML
#endif

public class PortrayalCatalogueParser: NSObject, XMLParserDelegate {
    
    private let bundle: Bundle
    private let portrayalCataloguePath: String
    
    private var currentKV: [String: String] = [:]
    private var currentElementValue = ""
    private var currentDescription: Description?
    private var currentId: String?
    private var elementLevel = 0
    
    private var areaFillById: [String: AreaFill] = [:]
    private var ruleFileById: [String: RuleFile] = [:]
    private var symbolFileById: [String: SymbolFile] = [:]
    private var lineStyleById: [String: LineStyleFile] = [:]
    private var colorProfileFileById: [String: ColorProfileFile] = [:]
    private var styleSheetFileById: [String: StyleSheetFile] = [:]
    private var viewingGroupById: [String: ViewingGroup] = [:]
    
    private init(bundle: Bundle, portrayalCataloguePath: String) {
        self.bundle = bundle
        self.portrayalCataloguePath = portrayalCataloguePath
    }

    public static func parse(bundle: Bundle, portrayalCataloguePath: String) -> PortrayalCatalogue? {
        
        guard let portrayalCatalogueXMLURL = bundle.url(forResource: "\(portrayalCataloguePath)/portrayal_catalogue", withExtension: "xml") else {
            return nil
        }
        
        do {
            let data = try Data.init(contentsOf: portrayalCatalogueXMLURL)
            
            let parser = PortrayalCatalogueParser(bundle: bundle, portrayalCataloguePath: portrayalCataloguePath)
            
            let xmlParser = XMLParser(data: data)
            xmlParser.delegate = parser
            xmlParser.parse()
            
            var colorPaletteByName: [String: ColorPalette] = [:]
            for colorProfile in parser.colorProfileFileById.values {
                if let aColorPaletteByName = ColorProfileParser.parse(bundle: bundle, portrayalCataloguePath: portrayalCataloguePath, colorProfile: colorProfile) {
                    colorPaletteByName.merge(aColorPaletteByName, uniquingKeysWith: { (_, new) in new })
                }
            }
            
            var lineStyleByName: [String: LineStyle] = [:]
            for lineStyleFile in parser.lineStyleById.values {
                if let lineStyle = LineStyleParser.parse(bundle: bundle, portrayalCataloguePath: portrayalCataloguePath, lineStyleFile: lineStyleFile) {
                    lineStyleByName[lineStyle.name] = lineStyle
                }
            }
            
            var symbolSVGByName: [String: SVG] = [:]
            for symbolFile in parser.symbolFileById.values {
                if let svg = SVGParser.parse(bundle: bundle, portrayalCataloguePath: portrayalCataloguePath, symbolFile: symbolFile) {
                    symbolSVGByName[svg.name] = svg
                }
            }
            
            return PortrayalCatalogue(bundle: bundle, path: portrayalCataloguePath, areaFillById: parser.areaFillById, ruleFileById: parser.ruleFileById, symbolFileById: parser.symbolFileById, lineStyleByName: lineStyleByName, colorProfileFileById: parser.colorProfileFileById, styleSheetFileById: parser.styleSheetFileById, viewingGroupById: parser.viewingGroupById, colorPaletteByName: colorPaletteByName, symbolSVGByName: symbolSVGByName)
        } catch {
            return nil
        }
    }
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        elementLevel += 1
        currentElementValue = ""
        
        if elementLevel == 4 {
            if "description" == elementName {
                currentKV.removeAll()
            }
        }
        
        if elementLevel == 3 {
            currentId = attributeDict["id"]
            currentKV.removeAll()
        }

    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentElementValue.append(string)
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementLevel == 4 {
            if "description" == elementName, !currentKV.isEmpty {
                currentDescription = Description.create(currentKV)
                if currentDescription == nil {
                    print("DEBUG: could not parse \(elementName) from \(currentKV)")
                }
            }
        }
        
        if elementLevel == 3 {
            if let id = currentId, let description = currentDescription {
                switch (elementName) {
                case "areaFill":
                    if let areaFill = AreaFill.create(currentKV, id: id, description: description) {
                        areaFillById[areaFill.id] = areaFill
                    } else {
                        print("DEBUG: could not parse \(elementName) from \(currentKV)")
                    }
                case "ruleFile":
                    if let ruleFile = RuleFile.create(currentKV, id: id, description: description) {
                        ruleFileById[ruleFile.id] = ruleFile
                    } else {
                        print("DEBUG: could not parse \(elementName) from \(currentKV)")
                    }
                case "symbol":
                    if let symbol = SymbolFile.create(currentKV, id: id, description: description) {
                        symbolFileById[symbol.id] = symbol
                    } else {
                        print("DEBUG: could not parse \(elementName) from \(currentKV)")
                    }
                case "lineStyle":
                    if let lineStyle = LineStyleFile.create(currentKV, id: id, description: description) {
                        lineStyleById[lineStyle.id] = lineStyle
                    } else {
                        print("DEBUG: could not parse \(elementName) from \(currentKV)")
                    }
                case "colorProfile":
                    if let colorProfile = ColorProfileFile.create(currentKV, id: id, description: description) {
                        colorProfileFileById[colorProfile.id] = colorProfile
                    } else {
                        print("DEBUG: could not parse \(elementName) from \(currentKV)")
                    }
                case "styleSheet":
                    if let styleSheet = StyleSheetFile.create(currentKV, id: id, description: description) {
                        styleSheetFileById[styleSheet.id] = styleSheet
                    } else {
                        print("DEBUG: could not parse \(elementName) from \(currentKV)")
                    }
                case "viewingGroup":
                    if let viewingGroup = ViewingGroup.create(currentKV, id: id, description: description) {
                        viewingGroupById[viewingGroup.id] = viewingGroup
                    } else {
                        print("DEBUG: could not parse \(elementName) from \(currentKV)")
                    }
                default:
                    break
                }
            }
        }
        
        currentKV[elementName] = String(currentElementValue)
        elementLevel -= 1
    }
    
}
