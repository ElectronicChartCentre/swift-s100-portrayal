//
//  Test.swift
//  swift-s100-portrayal
//

import Testing
@testable import SwiftS100Portrayal

struct CSSParserTests {

    @Test func testCSSParser() async throws {
        let s = """
            .layout {display:none}  /* used to control visibility of symbolBox, svgBox, pivotPoint (none or inline) */
            .symbolBox {stroke:black;stroke-width:0.32;}  /* show the cover of the symbol graphics */
            .svgBox {stroke:blue;stroke-width:0.32;}  /* show the entire SVG cover */
            .pivotPoint {stroke:red;stroke-width:0.64;}  /* show the pivot/anchor point, 0,0 */
            .sl {stroke-linecap:round;stroke-linejoin:round} /* default line style elements */
            .f0 {fill:none}  /* no fill */
            .sNODTA {stroke:#93AEBB}
            .fNODTA {fill:#93AEBB}
            """
        
        guard let css = CSSParser.parse(css: s) else {
            Issue.record("Could not parse CSS")
            return
        }
        
        #expect(css.entriesByClassSelector.count == 8)
    }
    
}
