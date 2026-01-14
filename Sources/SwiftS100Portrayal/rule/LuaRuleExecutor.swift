//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation
import SwiftS101
import SwiftS100FeatureCatalogue
import SwiftyLua

public class LuaRuleExecutor {
    
    private let portrayalCatalogue: PortrayalCatalogue
    private let featureCatalogue: FeatureCatalogue
    
    private let lua: LuaVM
    
    private var dsf: DataSetFile?
    private var featureById: [String: FeatureTypeRecord] = [:]
    
    private let debug: Bool = true
    
    public init(portrayalCatalogue: PortrayalCatalogue, featureCatalogue: FeatureCatalogue) {
        self.portrayalCatalogue = portrayalCatalogue
        self.featureCatalogue = featureCatalogue
        self.lua = LuaVM()
        
        if debug {
            self.lua.debuggingEnabled = true
        }
        
        setPath()
        loadPortrayalCatalogue()
        registerHostFunctions()
    }
    
    private func setPath() {
        
        let fileNameWithoutSuffix = "\(portrayalCatalogue.path)/Rules/main"
        guard let url = Bundle.module.url(forResource: fileNameWithoutSuffix, withExtension: "lua") else {
            print("DEBUG: could not find \(fileNameWithoutSuffix).lua")
            return
        }

        let path = url.deletingLastPathComponent().path()
        
        do {
            try lua.execute(string: "package.path = package.path .. \";\" .. \"\(path)?.lua\"")
        } catch {
            print("ERROR: could not set path: Error: \(error)")
        }
    }
    
    private func loadPortrayalCatalogue() {
        do {
            
            let fileNameWithoutSuffix = "\(portrayalCatalogue.path)/Rules/main"
            guard let url = Bundle.module.url(forResource: fileNameWithoutSuffix, withExtension: "lua") else {
                print("DEBUG: could not find \(fileNameWithoutSuffix).lua")
                return
            }

            try lua.execute(url: url)
        } catch {
            print("ERROR: could not load portrayal catalogue lua files. \(error)")
        }
    }
    
    private func registerHostFunctions() {
        if debug {
            lua.registerFunction(.init(name: "HostDebuggerEntry", parameters: [String.arg, String.arg], fn: HostDebuggerEntry(_:)))
        }

        lua.registerFunction(.init(name: "HostGetFeatureIDs", fn: HostGetFeatureIDs(_:)))
        lua.registerFunction(.init(name: "HostFeatureGetCode", parameters: [String.arg], fn: HostFeatureGetCode(_:)))
        lua.registerFunction(.init(name: "HostGetFeatureTypeCodes", fn: HostGetFeatureTypeCodes(_:)))
        lua.registerFunction(.init(name: "HostGetInformationTypeCodes", fn: HostGetInformationTypeCodes(_:)))
        lua.registerFunction(.init(name: "HostGetSimpleAttributeTypeCodes", fn: HostGetSimpleAttributeTypeCodes(_:)))
        lua.registerFunction(.init(name: "HostGetComplexAttributeTypeCodes", fn: HostGetComplexAttributeTypeCodes(_:)))
        lua.registerFunction(.init(name: "HostGetRoleTypeCodes", fn: HostGetRoleTypeCodes(_:)))
        lua.registerFunction(.init(name: "HostGetInformationAssociationTypeCodes", fn: HostGetInformationAssociationTypeCodes(_:)))
        lua.registerFunction(.init(name: "HostGetFeatureAssociationTypeCodes", fn: HostGetFeatureAssociationTypeCodes(_:)))
        lua.registerFunction(.init(name: "HostGetFeatureTypeInfo", parameters: [String.arg], fn: HostGetFeatureTypeInfo(_:)))
        lua.registerFunction(.init(name: "HostFeatureGetSpatialAssociations", parameters: [String.arg], fn: HostFeatureGetSpatialAssociations(_:)))

    }
    
    func setUp(dsf: DataSetFile) {
        
        featureById.removeAll()
        
        self.dsf = dsf

        for feature in dsf.featureTypeRecords() {
            let featureId = LuaRuleExecutor.createFeatureId(dsf: dsf, feature: feature)
            featureById[featureId] = feature
        }

        var contextParameters: [any Value] = []
        if let cp = luaPortrayalCreateContextParameter(ContextParameter(name: "SafetyDepth", type: "real", value: "10")) {
            contextParameters.append(cp)
        }
        
        do {
            try lua.execute(string: "return PortrayalInitializeContextParameters(...);", args: contextParameters)
        } catch {
            print("ERROR: PortrayalInitializeContextParameters failed. Error: \(error)")
        }

    }

    func portrayal(features: [FeatureTypeRecord]) -> [DrawingCommand] {
        
        guard let dsf = dsf else {
            return []
        }
        
        var featureIdsToPortray: Set<String> = []
        for feature in features {
            let featureId = LuaRuleExecutor.createFeatureId(dsf: dsf, feature: feature)
            featureIdsToPortray.insert(featureId)
        }
        
        do {
            let r = try lua.execute(string: "local args = {...} \n return PortrayalMain(args);", args: Array(featureIdsToPortray))
            print("DEBUG: ret: \(r)")
        } catch {
            print("ERROR: PortrayalMain failed. Error: \(error)")
        }
        
        return []
    }
    
    private static func createFeatureId(dsf: DataSetFile, feature: FeatureTypeRecord) -> String {
        let dsnm = dsf.generalInformation?.dsid.dsnm ?? "unknown"
        let recordIdentifier = feature.frid.recordIdentifier
        return "\(dsnm):\(recordIdentifier.rcnm):\(recordIdentifier.rcid)"
    }
    
    private func luaPortrayalCreateContextParameter(_ cp: ContextParameter) -> Value? {
        
        var args: [Value] = []
        args.append(cp.name)
        args.append(cp.type)
        args.append(cp.value)

        do {
            let result = try lua.execute(string: "local args = {...} \n return PortrayalCreateContextParameter(args[1], args[2], args[3]);", args: args)
            if case .values(let values) = result, values.count == 1, let v = values.first {
                return v
            }
            return nil
        } catch {
            print("ERROR: PortrayalCreateContextParameter failed. Error: \(error)")
            return nil
        }
    }
    
    private func toLuaTable(_ values: [any Value]) -> Table {
        let table = lua.vm.createTable()
        var index = 1
        for value in values {
            table[index] = value
            index += 1
        }
        return table
    }
    
    private func HostDebuggerEntry(_ args: Arguments) -> SwiftReturnValue {
        let key = args.string
        let name = args.string
        if key != "start_performance", key != "stop_performance" {
            print("DEBUG: HostDebuggerEntry. \(key), \(name)")
        }
        return .nothing
    }
    
    private func HostGetFeatureIDs(_ args: Arguments) -> SwiftReturnValue {
        print("DEBUG: HostGetFeatureIDs")
        return .value(toLuaTable(featureById.keys.sorted()))
    }
    
    private func HostFeatureGetCode(_ args: Arguments) -> SwiftReturnValue {
        let featureId = args.string
        guard let feature = featureById[featureId] else {
            print("DEBUG: HostFeatureGetCode. unknown feature. \(featureId)")
            return .nothing
        }
        print("DEBUG: HostFeatureGetCode. \(feature.frid.ftcd)")
        return .value(feature.frid.ftcd)
    }
    
    private func HostGetFeatureTypeCodes(_ args: Arguments) -> SwiftReturnValue {
        print("DEBUG: HostGetFeatureTypeCodes")
        return .value(toLuaTable(featureCatalogue.featureTypeByCode.keys.sorted()))
    }
    
    private func HostGetInformationTypeCodes(_ args: Arguments) -> SwiftReturnValue {
        print("DEBUG: HostGetInformationTypeCodes")
        return .value(toLuaTable(featureCatalogue.informationTypeByCode.keys.sorted()))
    }

    private func HostGetSimpleAttributeTypeCodes(_ args: Arguments) -> SwiftReturnValue {
        print("DEBUG: HostGetSimpleAttributeTypeCodes")
        return .value(toLuaTable(featureCatalogue.simpleAttributeByCode.keys.sorted()))
    }
    
    private func HostGetComplexAttributeTypeCodes(_ args: Arguments) -> SwiftReturnValue {
        print("DEBUG: HostGetComplexAttributeTypeCodes")
        return .value(toLuaTable(featureCatalogue.complexAttributeByCode.keys.sorted()))
    }
    
    private func HostGetRoleTypeCodes(_ args: Arguments) -> SwiftReturnValue {
        print("DEBUG: HostGetRoleTypeCodes")
        // TODO: implement
        return .nothing
    }
    
    private func HostGetInformationAssociationTypeCodes(_ args: Arguments) -> SwiftReturnValue {
        print("DEBUG: HostGetInformationAssociationTypeCodes")
        // TODO: implement
        return .nothing
    }
    
    private func HostGetFeatureAssociationTypeCodes(_ args: Arguments) -> SwiftReturnValue {
        print("DEBUG: HostGetFeatureAssociationTypeCodes")
        // TODO: implement
        return .nothing
    }
    
    private func HostGetFeatureTypeInfo(_ args: Arguments) -> SwiftReturnValue {
        print("DEBUG: HostGetFeatureTypeInfo")
        let code = args.string
        // TODO: implement
        return .nothing
    }
    
    private func HostFeatureGetSpatialAssociations(_ args: Arguments) -> SwiftReturnValue {
        print("DEBUG: HostFeatureGetSpatialAssociations")
        let id = args.string
        // TODO: implement
        return .value(toLuaTable([]))
    }
    
}
