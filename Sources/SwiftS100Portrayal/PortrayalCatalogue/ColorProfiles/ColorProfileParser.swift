//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

// FoundationXML needed on Linux and does not exist on macOS..
#if canImport(FoundationXML)
import FoundationXML
#endif

class ColorProfileParser: NSObject, XMLParserDelegate {
    
    private let bundle: Bundle
    private let portrayalCataloguePath: String
    
    private var colorPaletteByName: [String: ColorPalette] = [:]
    
    private var elementStack: [Element] = []
    private var currentElementValue = ""
    private var elementLevel = 0
    
    init(bundle: Bundle, portrayalCataloguePath: String) {
        self.bundle = bundle
        self.portrayalCataloguePath = portrayalCataloguePath
    }
    
    static func parse(bundle: Bundle, portrayalCataloguePath: String, colorProfile: ColorProfileFile) -> [String: ColorPalette]? {
        
        guard let colorProfileXMLURL = bundle.url(forResource: "\(portrayalCataloguePath)/ColorProfiles/\(colorProfile.fileNameWithoutSuffix())", withExtension: "xml") else {
            return nil
        }
        
        do {
            let data = try Data.init(contentsOf: colorProfileXMLURL)
            
            let parser = ColorProfileParser(bundle: bundle, portrayalCataloguePath: portrayalCataloguePath)
            
            let xmlParser = XMLParser(data: data)
            xmlParser.delegate = parser
            let _ = xmlParser.parse()
            
            return parser.colorPaletteByName
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
            let element = elementStack[elementLevel]
            switch (elementName) {
            case "palette":
                if let palette = ColorPalette.create(element, bundle: bundle, portrayalCataloguePath: portrayalCataloguePath) {
                    colorPaletteByName[palette.name] = palette
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
