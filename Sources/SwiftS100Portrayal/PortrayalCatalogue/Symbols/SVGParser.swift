//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

// FoundationXML needed on Linux and does not exist on macOS..
#if canImport(FoundationXML)
import FoundationXML
#endif

class SVGParser: NSObject, XMLParserDelegate {
    
    private var shapes: [SVGShape] = []
    
    private var elementStack: [Element] = []
    private var currentElementValue = ""
    private var elementLevel = 0
    
    override private init() {
    }
    
    static func parse(bundle: Bundle, portrayalCataloguePath: String, symbolFile: SymbolFile) -> SVG? {
        
        guard let symbolSVGURL = bundle.url(forResource: "\(portrayalCataloguePath)/Symbols/\(symbolFile.fileNameWithoutSuffix())", withExtension: "svg") else {
            return nil
        }
        
        do {
            let data = try Data.init(contentsOf: symbolSVGURL)
            
            let parser = SVGParser()
            
            let xmlParser = XMLParser(data: data)
            xmlParser.delegate = parser
            xmlParser.parse()
            
            return SVG(name: symbolFile.id, shapes: parser.shapes)
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
        
        if elementLevel == 1 {
            switch (elementName) {
                // do we need some svg header values?
            default:
                break
            }
        }
        
        if elementLevel == 2 {
            switch (elementName) {
            case "rect":
                let element = elementStack[elementLevel]
                if let rect = SVGRect.create(element.attributeByKey) {
                    shapes.append(rect)
                }
            case "circle":
                let element = elementStack[elementLevel]
                if let circle = SVGCircle.create(element.attributeByKey) {
                    shapes.append(circle)
                }
            case "path":
                let element = elementStack[elementLevel]
                if let path = SVGPath.create(element.attributeByKey) {
                    shapes.append(path)
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
