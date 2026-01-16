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
            lua.registerFunction(.init(name: "HostDebuggerEntry", parameters: [String.arg, String.arg, Nil.arg], fn: HostDebuggerEntry(_:)))
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
        lua.registerFunction(.init(name: "HostFeatureGetAssociatedInformationIDs", parameters: [String.arg, String.arg, String.arg], fn: HostFeatureGetAssociatedInformationIDs(_:)))
        lua.registerFunction(.init(name: "HostGetComplexAttributeTypeInfo", parameters: [String.arg], fn: HostGetComplexAttributeTypeInfo(_:)))
        lua.registerFunction(.init(name: "HostFeatureGetSimpleAttribute", parameters: [String.arg, String.arg, String.arg], fn: HostFeatureGetSimpleAttribute(_:)))
        lua.registerFunction(.init(name: "HostFeatureGetComplexAttributeCount", parameters: [String.arg, String.arg, String.arg], fn: HostFeatureGetComplexAttributeCount(_:)))
        lua.registerFunction(.init(name: "HostInformationTypeGetSimpleAttribute", parameters: [String.arg, String.arg, String.arg], fn: HostInformationTypeGetSimpleAttribute(_:)))
        lua.registerFunction(.init(name: "HostPortrayalEmit", parameters: [String.arg, String.arg, String.arg], fn: HostPortrayalEmit(_:)))

    }
    
    func setUp(dsf: DataSetFile) {
        
        featureById.removeAll()
        
        self.dsf = dsf

        for feature in dsf.featureTypeRecords() {
            let featureId = LuaRuleExecutor.createRecordId(dsf: dsf, record: feature)
            featureById[featureId] = feature
        }

        var contextParameters: [any Value] = []
        for contextParameter in ContextParameters.defaultContextParameters().parameterByName.values {
            if let cp = luaPortrayalCreateContextParameter(contextParameter) {
                contextParameters.append(cp)
            }
        }
        
        let _ = call("PortrayalInitializeContextParameters", [toLuaTable(contextParameters)])
    }

    func portrayal(features: [FeatureTypeRecord]) -> [DrawingCommand] {
        
        guard let dsf = dsf else {
            return []
        }
        
        var featureIdsToPortray: Set<String> = []
        for feature in features {
            let featureId = LuaRuleExecutor.createRecordId(dsf: dsf, record: feature)
            featureIdsToPortray.insert(featureId)
        }
        
        let _ = call("PortrayalMain", [toLuaTable(featureIdsToPortray.sorted())])
        
        return []
    }
    
    private static func createRecordId(dsf: DataSetFile, record: Record) -> String {
        return createRecordId(dsf: dsf, recordIdentifier: record.recordIdentifier())
    }
    
    private static func createRecordId(dsf: DataSetFile, recordIdentifier: RecordIdentifier) -> String {
        let dsnm = dsf.generalInformation?.dsid.dsnm ?? "unknown"
        return "\(dsnm):\(recordIdentifier.rcnm):\(recordIdentifier.rcid)"
    }
    
    private static func createRecordIdentifier(recordId: String) -> RecordIdentifier? {
        let parts = recordId.split(separator: ":")
        if let rcnm = Int(parts[1]), let rcid = Int(parts[2]) {
            return RecordIdentifier(rcnm: rcnm, rcid: rcid)
        }
        return nil
    }
    
    private func luaPortrayalCreateContextParameter(_ cp: ContextParameter) -> Value? {
        var args: [Value] = []
        args.append(cp.name)
        args.append(cp.type)
        args.append(cp.value)
        return call("PortrayalCreateContextParameter", args)
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
        print("DEBUG: HostDebuggerEntry. \(key), \(name)")
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
        return .value(toLuaTable(featureCatalogue.roleByCode.keys.sorted()))
    }
    
    private func HostGetInformationAssociationTypeCodes(_ args: Arguments) -> SwiftReturnValue {
        print("DEBUG: HostGetInformationAssociationTypeCodes")
        return .value(toLuaTable(featureCatalogue.informationAssociationByCode.keys.sorted()))
    }
    
    private func HostGetFeatureAssociationTypeCodes(_ args: Arguments) -> SwiftReturnValue {
        print("DEBUG: HostGetFeatureAssociationTypeCodes")
        return .value(toLuaTable(featureCatalogue.featureAssociationByCode.keys.sorted()))
    }
    
    /**
     * To make it easier to call Lua including handling of nil arguments
     */
    private func call(_ functionName: String, _ args: [Value?]) -> Value? {
        
        var nonNilArgs: [Value] = []
        
        var luaCode = "local args = {...} \n return \(functionName)("
        for arg in args {
            if let arg = arg {
                luaCode.append("args[\(nonNilArgs.count + 1)]")
                nonNilArgs.append(arg)
            } else {
                luaCode.append("nil")
            }
            luaCode.append(", ")
        }
        if luaCode.hasSuffix(", ") {
            luaCode.removeLast(2)
        }
        luaCode.append(")")
        
        do {
            let result = try lua.execute(string: luaCode, args: nonNilArgs)
            if case .values(let values) = result, values.count == 1, let v = values.first {
                return v
            }
            
            print("DEBUG: \(functionName) returned nil")
            return nil
        } catch {
            print("ERROR: \(functionName) problem. \(error)")
        }
        
        return nil
    }
    
    private func luaCreateItem(_ item: Item) -> Value? {
        var args: [Value?] = []
        args.append(item.code)
        args.append(item.name)
        args.append(item.definition)
        args.append(item.remarks ?? "what?")
        args.append(toLuaTable(item.alias))
        return call("CreateItem", args)
    }
    
    private func luaCreateAttributeBinding(_ ab: AttributeBinding) -> Value? {
        var args: [Value?] = []
        args.append(ab.attributeReference)
        args.append(ab.multiplicity.lower)
        args.append(ab.multiplicity.upper)
        args.append(ab.sequential)
        args.append(toLuaTable(ab.permittedValues))
        return call("CreateAttributeBinding", args)
    }
    
    private func luaCreateNamedType(_ namedType: NamedType) -> Value? {
        var args: [Value] = []
        args.append(luaCreateItem(namedType) ?? "")
        args.append(namedType.isAbstract)

        var luaAttributeBindings: [Value] = []
        for attributeBinding in namedType.attributeBindingByName.values {
            if let ab = luaCreateAttributeBinding(attributeBinding) {
                luaAttributeBindings.append(ab)
            }
        }
        args.append(toLuaTable(luaAttributeBindings))
        
        return call("CreateNamedType", args)
    }
    
    private func luaCreateObjectType(_ objectType: ObjectType) -> Value? {
        var args: [Value] = []
        args.append(luaCreateNamedType(objectType) ?? "")
        args.append(toLuaTable([])) // TODO: information bindings
        return call("CreateObjectType", args)
    }
    
    private func luaCreateFeatureType(_ featureType: FeatureType) -> Value? {
        var args: [Value?] = []
        args.append(luaCreateObjectType(featureType) ?? "")
        args.append(featureType.featureUseType)
        args.append(toLuaTable(featureType.permittedPrimitives))
        args.append(toLuaTable([])) // TODO: featureBindings
        args.append(featureType.superType)
        args.append(toLuaTable(featureType.subType))
        return call("CreateFeatureType", args)
    }
    
    private func HostGetFeatureTypeInfo(_ args: Arguments) -> SwiftReturnValue {
        print("DEBUG: HostGetFeatureTypeInfo")
        let code = args.string
        
        // TODO: a cache for this?
        
        guard let featureType = featureCatalogue.featureTypeByCode[code] else {
            return .nothing
        }
        
        if let ft = luaCreateFeatureType(featureType) {
            return .value(ft)
        }
        
        return .nothing
    }
    
    private func luaCreateSpatialAssociation(_ spas: SPAS) -> Value? {
        
        guard let dsf = dsf else {
            return nil
        }
        
        guard let record = dsf.record(forIdentifier: spas.referencedRecordIdentifier) else {
            return nil
        }
        
        var spatialType: String = "Unknown"
        if let geometryRecord = record as? GeometryRecord {
            spatialType = geometryRecord.spatialType()
        }
        
        var orientation: String = "Unknown"
        switch spas.ornt {
        case SPAS.orntForvard:
            orientation = "Forward"
        case SPAS.orntReverse:
            orientation = "Reverse"
        default:
            break
        }
        
        let recordId = LuaRuleExecutor.createRecordId(dsf: dsf, record: record)
        
        let args: [String] = [spatialType, recordId, orientation, spas.smin.description, spas.smax.description]
        
        return call("CreateSpatialAssociation", args)
    }
    
    private func HostFeatureGetSpatialAssociations(_ args: Arguments) -> SwiftReturnValue {
        let featureId = args.string
        guard let feature = featureById[featureId] else {
            return .nothing
        }
        
        var spass: [any Value] = []
        for spas in feature.spass() {
            if let r = luaCreateSpatialAssociation(spas) {
                spass.append(r)
            }
        }
        
        print("DEBUG: HostFeatureGetSpatialAssociations. \(featureId) -> \(feature.spass().count) \(spass.count)")
        return .value(toLuaTable(spass))
    }
    
    private func HostFeatureGetAssociatedInformationIDs(_ args: Arguments) -> SwiftReturnValue {
        let featureId = args.string
        let associationCode = args.string
        let roleCode = args.string
        print("DEBUG: HostFeatureGetAssociatedInformationIDs. \(featureId) \(associationCode) \(roleCode)")
        
        guard let dsf = dsf else {
            return .nothing
        }
        
        guard let feature = featureById[featureId] else {
            return .nothing
        }
        
        var associatedFeatureIds: [String] = []
        for fasc in feature.fascs() {
            // TODO: filter on associationCode and roleCode
            
            let associatedFeatureId = LuaRuleExecutor.createRecordId(dsf: dsf, recordIdentifier: fasc.referencedRecordIdentifier)
            associatedFeatureIds.append(associatedFeatureId)
        }
        
        return .value(toLuaTable(associatedFeatureIds))
    }
    
    private func luaCreateComplexAttribute(_ ca: ComplexAttribute) -> Value? {

        var args: [Value?] = []
        args.append(luaCreateItem(ca) ?? "")
        
        var attributeBindings: [Value] = []
        for ab in ca.subAttributeBindingByCode.values {
            if let attributeBinding = luaCreateAttributeBinding(ab) {
                attributeBindings.append(attributeBinding)
            }
        }
        args.append(toLuaTable(attributeBindings))
        
        return call("CreateComplexAttribute", args)
    }
    
    private func HostGetComplexAttributeTypeInfo(_ args: Arguments) -> SwiftReturnValue {
        print("DEBUG: HostGetComplexAttributeTypeInfo")
        let attributeCode = args.string
        guard let complexAttribute = featureCatalogue.complexAttributeByCode[attributeCode] else {
            return .nothing
        }
        return .value(luaCreateComplexAttribute(complexAttribute))
    }
    
    private func HostFeatureGetSimpleAttribute(_ args: Arguments) -> SwiftReturnValue {
        print("DEBUG: HostFeatureGetSimpleAttribute")
        let featureId = args.string
        let path = args.string
        let attributeCode = args.string
        
        guard let dsf = dsf else {
            return .nothing
        }
        
        guard let feature = featureById[featureId] else {
            return .nothing
        }
        
        let attributePath = AttributePath(definition: path)

        var values: [String] = []
        for value in attributePath.resolveAttributePath(dsf: dsf, record: feature, atcd: attributeCode) {
            // TODO: GetUnknownAttributeString?
            values.append(value)
        }
        
        return .value(toLuaTable(values))
    }
    
    private func HostFeatureGetComplexAttributeCount(_ args: Arguments) -> SwiftReturnValue {
        print("DEBUG: HostFeatureGetComplexAttributeCount")
        let featureId = args.string
        let path = args.string
        let attributeCode = args.string
        
        guard let dsf = dsf else {
            return .nothing
        }
        
        guard let feature = featureById[featureId] else {
            return .nothing
        }
        
        let attributePath = AttributePath(definition: path)
        
        return .value(attributePath.resolveAttributePath(dsf: dsf, record: feature, atcd: attributeCode).count)
    }
    
    private func HostInformationTypeGetSimpleAttribute(_ args: Arguments) -> SwiftReturnValue {
        print("DEBUG: HostInformationTypeGetSimpleAttribute")
        let informationTypeId = args.string
        let path = args.string
        let attributeCode = args.string
        
        guard let dsf = dsf else {
            return .nothing
        }
        
        guard let recordIdentifier = LuaRuleExecutor.createRecordIdentifier(recordId: informationTypeId) else {
            return .nothing
        }
        
        guard let record = dsf.record(forIdentifier: recordIdentifier) as? InformationTypeRecord else {
            return .nothing
        }
        
        let attributePath = AttributePath(definition: path)

        var values: [String] = []
        for value in attributePath.resolveAttributePath(dsf: dsf, record: record, atcd: attributeCode) {
            // TODO: GetUnknownAttributeString?
            values.append(value)
        }
        
        return .value(toLuaTable(values))
    }
        
    private func HostPortrayalEmit(_ args: Arguments) -> SwiftReturnValue {
        
        let featureId = args.string
        let drawingInstructions = args.string
        let observedParameters = args.string
        
        var ftcd: String = ""
        if let feature = featureById[featureId] {
            ftcd = feature.frid.ftcd
        }
        
        print("DEBUG: HostPortrayalEmit. featureId: \(featureId)(\(ftcd)), drawing instructions: \(drawingInstructions), observed parameters:  \(observedParameters)")
        // TODO: implement
        return .value(true as Value)
    }
    
}
