//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

// FoundationXML needed on Linux and does not exist on macOS..
#if canImport(FoundationXML)
import FoundationXML
#endif

class PortrayalCatalogueParser: NSObject, XMLParserDelegate {
    
    private let bundle: Bundle
    private let portrayalCataloguePath: String
    
    private var currentKV: [String: String] = [:]
    private var currentElementValue = ""
    private var currentDescription: Description?
    private var currentId: String?
    private var elementLevel = 0
    
    private var areaFillById: [String: AreaFill] = [:]
    private var ruleFileById: [String: RuleFile] = [:]
    private var symbolById: [String: Symbol] = [:]
    private var lineStyleById: [String: LineStyle] = [:]
    private var colorProfileById: [String: ColorProfile] = [:]
    private var styleSheetById: [String: StyleSheet] = [:]
    private var viewingGroupById: [String: ViewingGroup] = [:]
    
    private init(bundle: Bundle, portrayalCataloguePath: String) {
        self.bundle = bundle
        self.portrayalCataloguePath = portrayalCataloguePath
    }

    static func parse(bundle: Bundle, portrayalCataloguePath: String) -> PortrayalCatalogue? {
        
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
            for colorProfile in parser.colorProfileById.values {
                if let aColorPaletteByName = ColorProfileParser.parse(bundle: bundle, portrayalCataloguePath: portrayalCataloguePath, colorProfile: colorProfile) {
                    colorPaletteByName.merge(aColorPaletteByName, uniquingKeysWith: { (_, new) in new })
                }
            }
            
            return PortrayalCatalogue(bundle: bundle, path: portrayalCataloguePath, areaFillById: parser.areaFillById, ruleFileById: parser.ruleFileById, symbolById: parser.symbolById, lineStyleById: parser.lineStyleById, colorProfileById: parser.colorProfileById, styleSheetById: parser.styleSheetById, viewingGroupById: parser.viewingGroupById, colorPaletteByName: colorPaletteByName)
        } catch {
            return nil
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
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
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentElementValue.append(string)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementLevel == 4 {
            if "description" == elementName {
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
                    if let symbol = Symbol.create(currentKV, id: id, description: description) {
                        symbolById[symbol.id] = symbol
                    } else {
                        print("DEBUG: could not parse \(elementName) from \(currentKV)")
                    }
                case "lineStyle":
                    if let lineStyle = LineStyle.create(currentKV, id: id, description: description) {
                        lineStyleById[lineStyle.id] = lineStyle
                    } else {
                        print("DEBUG: could not parse \(elementName) from \(currentKV)")
                    }
                case "colorProfile":
                    if let colorProfile = ColorProfile.create(currentKV, id: id, description: description) {
                        colorProfileById[colorProfile.id] = colorProfile
                    } else {
                        print("DEBUG: could not parse \(elementName) from \(currentKV)")
                    }
                case "styleSheet":
                    if let styleSheet = StyleSheet.create(currentKV, id: id, description: description) {
                        styleSheetById[styleSheet.id] = styleSheet
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
