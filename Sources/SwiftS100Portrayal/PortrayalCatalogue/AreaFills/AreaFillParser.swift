//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

// FoundationXML needed on Linux and does not exist on macOS..
#if canImport(FoundationXML)
import FoundationXML
#endif

import SwiftGeo

class AreaFillParser: NSObject, XMLParserDelegate {
    
    private let name: String
    private var areaCRS: String?
    private var symbolName: String?
    private var v1: Vector2D?
    private var v2: Vector2D?
    
    private var elementStack: [Element] = []
    private var currentElementValue = ""
    private var elementLevel = 0
    
    private init(name: String) {
        self.name = name
    }
    
    static func parse(bundle: Bundle, portrayalCataloguePath: String, areaFillFile: AreaFillFile) -> AreaFill? {
        guard let areaFillXMLURL = bundle.url(forResource: "\(portrayalCataloguePath)/AreaFills/\(areaFillFile.fileNameWithoutSuffix())", withExtension: "xml") else {
            return nil
        }
        
        do {
            let data = try Data.init(contentsOf: areaFillXMLURL)
            
            let parser = AreaFillParser(name: areaFillFile.id)
            
            let xmlParser = XMLParser(data: data)
            xmlParser.delegate = parser
            xmlParser.parse()

            guard let areaCRS = parser.areaCRS, let symbolName = parser.symbolName, let v1 = parser.v1, let v2 = parser.v2 else {
                return nil
            }

            return AreaFill(name: parser.name, areaCRS: areaCRS, symbolName: symbolName, v1: v1, v2: v2)
        } catch {
            return nil
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        elementLevel += 1
        currentElementValue = ""
        
        let element = Element(attributeByKey: attributeDict)
        while elementStack.count > elementLevel {
            elementStack.removeLast()
        }
        
        if let parentElement = elementStack.last {
            parentElement.addChild(name: elementName, child: element)
        }
        
        elementStack.append(element)
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentElementValue.append(string)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementLevel == 2 {
            switch elementName {
            case "areaCRS":
                areaCRS = String(currentElementValue)
            case "symbol":
                let element = elementStack[elementLevel]
                symbolName = element.attributeByKey["reference"]
            case "v1":
                let element = elementStack[elementLevel]
                if let x = element["x"].flatMap(Double.init), let y = element["y"].flatMap(Double.init) {
                    v1 = Vector2D(x: x, y: y)
                }
            case "v2":
                let element = elementStack[elementLevel]
                if let x = element["x"].flatMap(Double.init), let y = element["y"].flatMap(Double.init) {
                    v2 = Vector2D(x: x, y: y)
                }
            default:
                break
            }
        }
        
        elementLevel -= 1
        
        let parentElement = elementStack[elementLevel]
        parentElement.append(elementName, String(currentElementValue))
    }
        
}
