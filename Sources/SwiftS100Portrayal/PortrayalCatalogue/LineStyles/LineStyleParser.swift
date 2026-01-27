//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

// FoundationXML needed on Linux and does not exist on macOS..
#if canImport(FoundationXML)
import FoundationXML
#endif

class LineStyleParser: NSObject, XMLParserDelegate {
    
    private let lineStyleName: String
    private var intervalLength: Double?
    private var pen: Pen?
    private var dashs: [Dash] = []
    private var symbols: [LineSymbol] = []
    
    private var elementStack: [Element] = []
    private var currentElementValue = ""
    private var elementLevel = 0
    
    init(lineStyleName: String) {
        self.lineStyleName = lineStyleName
    }
    
    static func parse(bundle: Bundle, portrayalCataloguePath: String, lineStyleFile: LineStyleFile) -> LineStyle? {
        
        guard let lineStyleXMLURL = bundle.url(forResource: "\(portrayalCataloguePath)/LineStyles/\(lineStyleFile.fileNameWithoutSuffix())", withExtension: "xml") else {
            return nil
        }
        
        do {
            let data = try Data.init(contentsOf: lineStyleXMLURL)
            
            let parser = LineStyleParser(lineStyleName: lineStyleFile.id)
            
            let xmlParser = XMLParser(data: data)
            xmlParser.delegate = parser
            xmlParser.parse()
            
            guard let intervalLength = parser.intervalLength, let pen = parser.pen else {
                return nil
            }
            
            return LineStyle(name: lineStyleFile.id, intervalLength: intervalLength, pen: pen, dashs: parser.dashs, symbols: parser.symbols)
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
            switch (elementName) {
            case "intervalLength":
                if let intervalLength = Double(currentElementValue) {
                    self.intervalLength = intervalLength
                }
            case "pen":
                let element = elementStack[elementLevel]
                if let pen = Pen.create(element) {
                    self.pen = pen
                }
            case "dash":
                let element = elementStack[elementLevel]
                if let dash = Dash.create(element) {
                    self.dashs.append(dash)
                }
            case "symbol":
                let element = elementStack[elementLevel]
                if let symbol = LineSymbol.create(element) {
                    self.symbols.append(symbol)
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
