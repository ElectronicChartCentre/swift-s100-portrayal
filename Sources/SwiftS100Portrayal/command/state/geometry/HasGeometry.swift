//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

import SwiftS101
import SwiftGeo

protocol HasGeometry: Sendable {
    
    func geometry(dsf: DataSetFile, geometry: Geometry, geometryCreator: GeometryCreator, renderer: Renderer) -> Geometry?
    
}
