//
//  Test.swift
//  swift-s100-portrayal
//

import Testing
@testable import SwiftS100Portrayal

struct SVGPathTests {

    @Test func testPath() async throws {
        var kv: [String: String] = [:]
        kv["d"] = " M 2.55,0.72 L 1.03,2.24 L -0.94,2.24 L -2.51,0.69"
        kv["class"] = "sl f0 sCHMGD"
        kv["stroke-width"] = "0.32"
        
        guard let path = SVGPath.create(kv) else {
            Issue.record("Could not parse SVG")
            return
        }
        
        #expect(path.pathCommands.count == 4)
        #expect(path.pathCommands[0] is SVGPath.M)
        #expect(path.pathCommands[1] is SVGPath.L)
        #expect(path.pathCommands[2] is SVGPath.L)
        #expect(path.pathCommands[3] is SVGPath.L)

    }

}
