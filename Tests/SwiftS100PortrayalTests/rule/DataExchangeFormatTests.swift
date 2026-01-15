//
//  Test.swift
//  SwiftS100Portrayal
//

import Testing
@testable import SwiftS100Portrayal

struct DataExchangeFormatTests {
    
    @Test func testConstructor() async throws {
        let def = DataExchangeFormat("PenWidth:0.64;PenColor:LANDF,0.75;DrawLine;DrawTextStrings:Hello&m world!,,Foo&cbar")
        #expect(def.entries[0].arguments == ["0.64"])
        #expect(def.entries[1].arguments == ["LANDF", "0.75"])
        #expect(def.entries[2].key == "DrawLine")
        #expect(def.entries[2].arguments.isEmpty)
        #expect(def.entries[3].arguments == ["Hello, world!", "", "Foo:bar"])
    }
    
    @Test func testEmptyArgument() async throws {
        let def = DataExchangeFormat("ScaleMinimum:89999;ViewingGroup:33020;DrawingPriority:5;DisplayPlane:OverRADAR;LineStyle:,,0.32,DEPCN;SpatialReference:VC0000001558;LineInstruction:;ClearGeometry;ViewingGroup:33022;LinePlacement:Relative,0.5;PointInstruction:SAFCON24;PointInstruction:SAFCON10")
        #expect(def.entries[4].key == "LineStyle")
        #expect(def.entries[4].arguments == ["", "", "0.32", "DEPCN"])
        #expect(def.entries[6].key == "LineInstruction")
        #expect(def.entries[6].arguments.isEmpty)
    }

}
