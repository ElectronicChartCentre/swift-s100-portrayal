//
//  File.swift
//  swift-s100-feature-catalogue
//

import Foundation

class Element {

    let attributeByKey: [String: String]
    
    private var kv: [String: String] = [:]
    private var mkv: [String: [String]] = [:]
    
    private var childrenWithName: [String: [Element]] = [:]
    
    init(attributeByKey: [String: String]) {
        self.attributeByKey = attributeByKey
    }
    
    func append(_ k: String, _ v: String) {
        kv[k] = v
        if var vs = mkv[k] {
            vs.append(v)
            mkv[k] = vs
        } else {
            mkv[k] = [v]
        }
    }
    
    subscript(_ k: String) -> String? {
        return kv[k]
    }
    
    func values(_ k: String) -> [String] {
        return mkv[k] ?? []
    }
    
    func addChild(name: String, child: Element) {
        if var es = childrenWithName[name] {
            es.append(child)
            childrenWithName[name] = es
        } else {
            childrenWithName[name] = [child]
        }
    }
    
    func children(name: String) -> [Element] {
        return childrenWithName[name] ?? []
    }

}
