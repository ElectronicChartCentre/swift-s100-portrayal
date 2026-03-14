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
    private var drawingCommands: [FeatureDrawingCommand] = []
    private var associatedFeatureIdsBySpatialId: [String: [String]] = [:]
    
    private let debug: Bool = false
    
    public init(portrayalCatalogue: PortrayalCatalogue, featureCatalogue: FeatureCatalogue) {
        self.portrayalCatalogue = portrayalCatalogue
        self.featureCatalogue = featureCatalogue
        self.lua = LuaVM()

        self.lua.debuggingEnabled = debug

        setPath()
        loadPortrayalCatalogue()
        registerHostFunctions()
    }
    
    private func setPath() {
        
        let fileNameWithoutSuffix = "\(portrayalCatalogue.path)/Rules/main"
        guard let url = portrayalCatalogue.bundle.url(forResource: fileNameWithoutSuffix, withExtension: "lua") else {
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
            guard let url = portrayalCatalogue.bundle.url(forResource: fileNameWithoutSuffix, withExtension: "lua") else {
                print("DEBUG: could not find \(fileNameWithoutSuffix).lua")
                return
            }
            
            try lua.execute(url: url)
        } catch {
            print("ERROR: could not load portrayal catalogue lua files. \(error)")
        }
    }
    
    private func registerHostFunctions() {
        // IMPORTANT: every closure must capture self weakly to avoid a retain
        // cycle.  The call chain is:
        //   VirtualMachine.functionWrappers → SwiftFunctionWrapper → fn closure
        //   → LuaRuleExecutor (self) → LuaVM → VirtualMachine
        // Without [weak self] that cycle prevents LuaRuleExecutor from ever
        // being deallocated, causing all Lua-side state to accumulate forever.

        if debug {
            lua.registerFunction(.init(name: "HostDebuggerEntry", parameters: [String.arg, String.arg], fn: { [weak self] args in self?.HostDebuggerEntry(args) ?? .nothing }))
            lua.registerFunction(.init(name: "HostDebuggerEntry", parameters: [String.arg, String.arg, Nil.arg], fn: { [weak self] args in self?.HostDebuggerEntry(args) ?? .nothing }))
        }

        lua.registerFunction(.init(name: "HostGetFeatureIDs", fn: { [weak self] args in self?.HostGetFeatureIDs(args) ?? .nothing }))
        lua.registerFunction(.init(name: "HostFeatureGetCode", parameters: [String.arg], fn: { [weak self] args in self?.HostFeatureGetCode(args) ?? .nothing }))
        lua.registerFunction(.init(name: "HostGetFeatureTypeCodes", fn: { [weak self] args in self?.HostGetFeatureTypeCodes(args) ?? .nothing }))
        lua.registerFunction(.init(name: "HostGetInformationTypeCodes", fn: { [weak self] args in self?.HostGetInformationTypeCodes(args) ?? .nothing }))
        lua.registerFunction(.init(name: "HostGetInformationTypeInfo", parameters: [String.arg], fn: { [weak self] args in self?.HostGetInformationTypeInfo(args) ?? .nothing }))
        lua.registerFunction(.init(name: "HostGetSimpleAttributeTypeCodes", fn: { [weak self] args in self?.HostGetSimpleAttributeTypeCodes(args) ?? .nothing }))
        lua.registerFunction(.init(name: "HostGetComplexAttributeTypeCodes", fn: { [weak self] args in self?.HostGetComplexAttributeTypeCodes(args) ?? .nothing }))
        lua.registerFunction(.init(name: "HostGetRoleTypeCodes", fn: { [weak self] args in self?.HostGetRoleTypeCodes(args) ?? .nothing }))
        lua.registerFunction(.init(name: "HostGetInformationAssociationTypeCodes", fn: { [weak self] args in self?.HostGetInformationAssociationTypeCodes(args) ?? .nothing }))
        lua.registerFunction(.init(name: "HostGetFeatureAssociationTypeCodes", fn: { [weak self] args in self?.HostGetFeatureAssociationTypeCodes(args) ?? .nothing }))
        lua.registerFunction(.init(name: "HostGetFeatureTypeInfo", parameters: [String.arg], fn: { [weak self] args in self?.HostGetFeatureTypeInfo(args) ?? .nothing }))
        lua.registerFunction(.init(name: "HostGetSimpleAttributeTypeInfo", parameters: [String.arg], fn: { [weak self] args in self?.HostGetSimpleAttributeTypeInfo(args) ?? .nothing }))
        lua.registerFunction(.init(name: "HostFeatureGetSpatialAssociations", parameters: [String.arg], fn: { [weak self] args in self?.HostFeatureGetSpatialAssociations(args) ?? .nothing }))
        lua.registerFunction(.init(name: "HostFeatureGetAssociatedInformationIDs", parameters: [String.arg, String.arg, String.arg], fn: { [weak self] args in self?.HostFeatureGetAssociatedInformationIDs(args) ?? .nothing }))
        lua.registerFunction(.init(name: "HostGetComplexAttributeTypeInfo", parameters: [String.arg], fn: { [weak self] args in self?.HostGetComplexAttributeTypeInfo(args) ?? .nothing }))
        lua.registerFunction(.init(name: "HostFeatureGetSimpleAttribute", parameters: [String.arg, String.arg, String.arg], fn: { [weak self] args in self?.HostFeatureGetSimpleAttribute(args) ?? .nothing }))
        lua.registerFunction(.init(name: "HostFeatureGetComplexAttributeCount", parameters: [String.arg, String.arg, String.arg], fn: { [weak self] args in self?.HostFeatureGetComplexAttributeCount(args) ?? .nothing }))
        lua.registerFunction(.init(name: "HostInformationTypeGetSimpleAttribute", parameters: [String.arg, String.arg, String.arg], fn: { [weak self] args in self?.HostInformationTypeGetSimpleAttribute(args) ?? .nothing }))
        lua.registerFunction(.init(name: "HostGetSpatial", parameters: [String.arg], fn: { [weak self] args in self?.HostGetSpatial(args) ?? .nothing }))
        lua.registerFunction(.init(name: "HostFeatureGetAssociatedFeatureIDs", parameters: [String.arg, String.arg, String.arg], fn: { [weak self] args in self?.HostFeatureGetAssociatedFeatureIDs(args) ?? .nothing }))
        lua.registerFunction(.init(name: "HostSpatialGetAssociatedInformationIDs", parameters: [String.arg, String.arg, String.arg], fn: { [weak self] args in self?.HostSpatialGetAssociatedInformationIDs(args) ?? .nothing }))
        lua.registerFunction(.init(name: "HostSpatialGetAssociatedFeatureIDs", parameters: [String.arg], fn: { [weak self] args in self?.HostSpatialGetAssociatedFeatureIDs(args) ?? .nothing }))
        lua.registerFunction(.init(name: "HostInformationTypeGetCode", parameters: [String.arg], fn: { [weak self] args in self?.HostInformationTypeGetCode(args) ?? .nothing }))
        lua.registerFunction(.init(name: "HostPortrayalEmit", parameters: [String.arg, String.arg, String.arg], fn: { [weak self] args in self?.HostPortrayalEmit(args) ?? .nothing }))
    }
    
    deinit {
        // lua4swift's StoredValue uses `unowned var vm: VirtualMachine`.
        // Swift does not guarantee the order in which stored properties are
        // released after deinit, so any cache that holds StoredValue objects
        // (Function, Table, etc.) might outlive VirtualMachine — causing an
        // "unowned reference was already deallocated" crash on deinit.
        //
        // By clearing them explicitly here, while the deinit body is still
        // executing and ALL stored properties (including `lua`) are guaranteed
        // to still be alive, we ensure StoredValue.deinit can safely call
        // vm.unref() without the VM already being gone.
        callFunctionCache.removeAll()
        _luaCreateFeatureType.removeAll()
        _luaCreateSimpleAttribute.removeAll()
        _luaGetUnknownAttributeString = nil
    }

    public func clearState() {
        featureById.removeAll()
        drawingCommands.removeAll()
        associatedFeatureIdsBySpatialId.removeAll()
    }
    
    public func setUp(dsf: DataSetFile) {
        setUp(dsf: dsf, overrideContextParameters: [:])
    }
    
    public func setUp(dsf: DataSetFile, overrideContextParameters: [String: String]) {
        clearState()
        
        self.dsf = dsf
        
        for feature in dsf.featureTypeRecords() {
            let featureId = LuaRuleExecutor.createRecordId(dsf: dsf, record: feature)
            featureById[featureId] = feature
            
            for spas in feature.spass() {
                let spatialId = LuaRuleExecutor.createRecordId(dsf: dsf, recordIdentifier: spas.referencedRecordIdentifier)
                if let associatedFeatureIds = associatedFeatureIdsBySpatialId[spatialId] {
                    var newAssociatedFeatureIds = Array(associatedFeatureIds)
                    newAssociatedFeatureIds.append(featureId)
                    associatedFeatureIdsBySpatialId[spatialId] = newAssociatedFeatureIds
                } else {
                    associatedFeatureIdsBySpatialId[spatialId] = [featureId]
                }
            }
        }
        
        var contextParameters: [any Value] = []
        for contextParameter in ContextParameters.defaultContextParameters().parameterByName.values {
            if let value = overrideContextParameters[contextParameter.name] {
                let overrideCP = ContextParameter(name: contextParameter.name, type: contextParameter.type, value: value)
                if let cp = luaPortrayalCreateContextParameter(overrideCP) {
                    contextParameters.append(cp)
                }
            } else {
                if let cp = luaPortrayalCreateContextParameter(contextParameter) {
                    contextParameters.append(cp)
                }
            }
        }
        
        let _ = call("PortrayalInitializeContextParameters", [toLuaTable(contextParameters)])
    }
    
    public func portrayal(features: [FeatureTypeRecord]) -> [FeatureDrawingCommand] {
        
        drawingCommands.removeAll()
        
        guard let dsf = dsf else {
            return []
        }
        
        var featureIdsToPortray: Set<String> = []
        for feature in features {
            let featureId = LuaRuleExecutor.createRecordId(dsf: dsf, record: feature)
            featureIdsToPortray.insert(featureId)
        }
        
        let _ = call("PortrayalMain", [toLuaTable(featureIdsToPortray.sorted())])
        
        // sort drawing commands. if client is mixing in cached drawing
        // commands, then it will need to sort again
        drawingCommands.sort()
        
        // Run a full Lua GC cycle to reclaim tables and other temporaries
        // created during portrayal.  Without this, Lua's incremental
        // collector falls behind when portrayal() is called repeatedly
        // (e.g. every tile render), causing unbounded memory growth.
        lua.collectGarbage()
        
        return drawingCommands
    }
    
    public static func createRecordId(dsf: DataSetFile, record: Record) -> String {
        return createRecordId(dsf: dsf, recordIdentifier: record.recordIdentifier())
    }
    
    private static func createRecordId(dsf: DataSetFile, recordIdentifier: RecordIdentifier) -> String {
        let dsnm = dsf.generalInformation?.dsid.dsnm ?? "unknown"
        return "\(dsnm):\(recordIdentifier.rcnm):\(recordIdentifier.rcid)"
    }
    
    public static func createRecordIdentifier(recordId: String) -> RecordIdentifier? {
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
        
        if debug {
            print("DEBUG: HostDebuggerEntry. \(key), \(name)")
        }
        
        return .nothing
    }
    
    private func HostGetFeatureIDs(_ args: Arguments) -> SwiftReturnValue {
        if debug {
            print("DEBUG: HostGetFeatureIDs")
        }
        
        return .value(toLuaTable(featureById.keys.sorted()))
    }
    
    private func HostFeatureGetCode(_ args: Arguments) -> SwiftReturnValue {
        let featureId = args.string
        guard let feature = featureById[featureId] else {
            print("ERROR: HostFeatureGetCode. unknown feature. \(featureId)")
            return .nothing
        }
        
        if debug {
            print("DEBUG: HostFeatureGetCode. \(feature.frid.ftcd)")
        }
        
        return .value(feature.frid.ftcd)
    }
    
    private func HostGetFeatureTypeCodes(_ args: Arguments) -> SwiftReturnValue {
        if debug {
            print("DEBUG: HostGetFeatureTypeCodes")
        }
        
        return .value(toLuaTable(featureCatalogue.featureTypeByCode.keys.sorted()))
    }
    
    private func HostGetInformationTypeCodes(_ args: Arguments) -> SwiftReturnValue {
        if debug {
            print("DEBUG: HostGetInformationTypeCodes")
        }
        
        return .value(toLuaTable(featureCatalogue.informationTypeByCode.keys.sorted()))
    }
    
    private func luaCreateInformationType(_ it: InformationType) -> Value? {
        var args: [Value?] = []
        args.append(luaCreateObjectType(it))
        args.append("") // TODO: super type
        args.append(toLuaTable([])) // TODO: sub types
        return call("CreateInformationType", args)
    }
    
    private func HostGetInformationTypeInfo(_ args: Arguments) -> SwiftReturnValue {
        let informationCode = args.string
        
        if debug {
            print("DEBUG: HostGetInformationTypeInfo. \(informationCode)")
        }
        
        guard let it = featureCatalogue.informationTypeByCode[informationCode] else {
            return .nothing
        }
        
        return .value(luaCreateInformationType(it))
    }
    
    private func HostGetSimpleAttributeTypeCodes(_ args: Arguments) -> SwiftReturnValue {
        if debug {
            print("DEBUG: HostGetSimpleAttributeTypeCodes")
        }
        
        return .value(toLuaTable(featureCatalogue.simpleAttributeByCode.keys.sorted()))
    }
    
    private func HostGetComplexAttributeTypeCodes(_ args: Arguments) -> SwiftReturnValue {
        if debug {
            print("DEBUG: HostGetComplexAttributeTypeCodes")
        }
        
        return .value(toLuaTable(featureCatalogue.complexAttributeByCode.keys.sorted()))
    }
    
    private func HostGetRoleTypeCodes(_ args: Arguments) -> SwiftReturnValue {
        if debug {
            print("DEBUG: HostGetRoleTypeCodes")
        }
        
        return .value(toLuaTable(featureCatalogue.roleByCode.keys.sorted()))
    }
    
    private func HostGetInformationAssociationTypeCodes(_ args: Arguments) -> SwiftReturnValue {
        if debug {
            print("DEBUG: HostGetInformationAssociationTypeCodes")
        }
        
        return .value(toLuaTable(featureCatalogue.informationAssociationByCode.keys.sorted()))
    }
    
    private func HostGetFeatureAssociationTypeCodes(_ args: Arguments) -> SwiftReturnValue {
        if debug {
            print("DEBUG: HostGetFeatureAssociationTypeCodes")
        }
        
        return .value(toLuaTable(featureCatalogue.featureAssociationByCode.keys.sorted()))
    }
    
    // Cache of compiled Lua wrapper functions, keyed by "functionName:nilPattern"
    // where nilPattern is a string of 'v' (value) and 'n' (nil) characters,
    // one per argument position.  Caching avoids recompiling the same Lua
    // chunk on every call, which was the primary source of memory growth.
    private var callFunctionCache: [String: Function] = [:]

    /**
     * To make it easier to call Lua including handling of nil arguments.
     *
     * The compiled wrapper chunk is cached and reused on every subsequent
     * call with the same function name and nil-pattern, so `luaL_loadstring`
     * is invoked at most once per unique (functionName, nil-pattern) pair.
     */
    private func call(_ functionName: String, _ args: [Value?]) -> Value? {
        
        var nonNilArgs: [Value] = []
        var placeholders: [String] = []
        
        for arg in args {
            if let arg = arg {
                nonNilArgs.append(arg)
                placeholders.append("args[\(nonNilArgs.count)]")
            } else {
                placeholders.append("nil")
            }
        }
        
        // Build a cache key that encodes the function name and which positions
        // are nil so the same compiled chunk can be reused across calls.
        let nilPattern = args.map { $0 == nil ? "n" : "v" }.joined()
        let cacheKey = "\(functionName):\(nilPattern)"
        
        let fn: Function
        if let cached = callFunctionCache[cacheKey] {
            fn = cached
        } else {
            let luaCode = "local args = {...}\nreturn \(functionName)(\(placeholders.joined(separator: ", ")))"
            switch lua.vm.createFunction(luaCode) {
            case .value(let f):
                callFunctionCache[cacheKey] = f
                fn = f
            case .error(let message):
                print("ERROR: \(functionName) compile problem. \(message)")
                return nil
            }
        }
        
        let result = fn.call(nonNilArgs)
        if case .values(let values) = result, values.count == 1, let v = values.first {
            return v
        }
        
        if debug {
            print("DEBUG: \(functionName) returned nil")
        }
        
        return nil
    }
    
    private func luaCreateItem(_ item: Item) -> Value? {
        var args: [Value?] = []
        args.append(item.code)
        args.append(item.name)
        args.append(item.definition)
        args.append(item.remarks)
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
    
    var _luaCreateFeatureType: [String: Value] = [:]
    
    private func luaCreateFeatureType(_ featureType: FeatureType) -> Value? {
        if let ft = _luaCreateFeatureType[featureType.code] {
            return ft
        }
        var args: [Value?] = []
        args.append(luaCreateObjectType(featureType) ?? "")
        args.append(featureType.featureUseType)
        args.append(toLuaTable(featureType.permittedPrimitives))
        args.append(toLuaTable([])) // TODO: featureBindings
        args.append(featureType.superType)
        args.append(toLuaTable(featureType.subType))
        if let ft = call("CreateFeatureType", args) {
            _luaCreateFeatureType[featureType.code] = ft
            return ft
        }
        return nil
    }
    
    private func HostGetFeatureTypeInfo(_ args: Arguments) -> SwiftReturnValue {
        if debug {
            print("DEBUG: HostGetFeatureTypeInfo")
        }
        
        let code = args.string
        
        guard let featureType = featureCatalogue.featureTypeByCode[code] else {
            return .nothing
        }
        
        if let ft = luaCreateFeatureType(featureType) {
            return .value(ft)
        }
        
        return .nothing
    }
    
    private func luaCreateAttributeConstraints() -> Value? {
        // TODO: implement
        let args: [Value?] = []
        return call("CreateAttributeConstraints", args)
    }
    
    private func luaCreateListedValue(_ lv: ListedValue) -> Value? {
        var args: [Value?] = []
        args.append(lv.label)
        args.append(lv.definition)
        args.append(lv.code)
        args.append(lv.remarks)
        args.append(toLuaTable(lv.alias))
        return call("CreateListedValue", args)
    }
    
    var _luaCreateSimpleAttribute: [String: Value] = [:]
    
    private func luaCreateSimpleAttribute(_ attribute: SimpleAttribute) -> Value? {
        if let ft = _luaCreateSimpleAttribute[attribute.code] {
            return ft
        }
        var args: [Value?] = []
        args.append(luaCreateItem(attribute))
        args.append(attribute.valueType)
        args.append(attribute.uom?.name)
        args.append(attribute.quantitySpecification)
        args.append(luaCreateAttributeConstraints())
        
        var luaListedValues: [Value] = []
        for listedValue in attribute.listedValues {
            if let lv = luaCreateListedValue(listedValue) {
                luaListedValues.append(lv)
            }
        }
        args.append(toLuaTable(luaListedValues))
        
        if let a = call("CreateSimpleAttribute", args) {
            _luaCreateFeatureType[attribute.code] = a
            return a
        }
        return nil
    }
    
    
    private func HostGetSimpleAttributeTypeInfo(_ args: Arguments) -> SwiftReturnValue {
        if debug {
            print("DEBUG: HostGetSimpleAttributeTypeInfo")
        }
        
        let code = args.string
        
        guard let attribute = featureCatalogue.simpleAttributeByCode[code] else {
            return .nothing
        }
        
        if let ft = luaCreateSimpleAttribute(attribute) {
            return .value(ft)
        }
        
        return .nothing
    }
    
    private func luaCreateSpatialAssociation(_ spas: SPAS) -> Value? {
        return luaCreateSpatialAssociation(spas.referencedRecordIdentifier, spas.ornt, smin: spas.smin, smax: spas.smax)
    }
    
    private func luaCreateSpatialAssociation(_ cuco: CUCO) -> Value? {
        return luaCreateSpatialAssociation(cuco.referencedRecordIdentifier, cuco.ornt, smin: nil, smax: nil)
    }
    
    private func luaCreateSpatialAssociation(_ rias: RIAS) -> Value? {
        return luaCreateSpatialAssociation(rias.referencedRecordIdentifier, rias.ornt, smin: nil, smax: nil)
    }
    
    private func luaCreateSpatialAssociation(_ referencedRecordIdentifier: RecordIdentifier, _ ornt: Int, smin: Int?, smax: Int?) -> Value? {
        
        guard let dsf = dsf else {
            return nil
        }
        
        guard let record = dsf.record(forIdentifier: referencedRecordIdentifier) else {
            return nil
        }
        
        var spatialType: String = "Unknown"
        if let geometryRecord = record as? GeometryRecord {
            spatialType = geometryRecord.spatialType()
        }
        
        var orientation: String = "Forward"
        switch ornt {
        case SPAS.orntForvard:
            orientation = "Forward"
        case SPAS.orntReverse:
            orientation = "Reverse"
        default:
            break
        }
        
        let recordId = LuaRuleExecutor.createRecordId(dsf: dsf, recordIdentifier: referencedRecordIdentifier)
        
        let args: [Value?] = [spatialType, recordId, orientation, smin, smax]
        
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
        
        if debug {
            print("DEBUG: HostFeatureGetSpatialAssociations. \(featureId)(\(feature.frid.ftcd)) -> \(feature.spass().count) \(spass.count)")
        }
        
        return .value(toLuaTable(spass))
    }
    
    private func HostFeatureGetAssociatedInformationIDs(_ args: Arguments) -> SwiftReturnValue {
        let featureId = args.string
        let associationCode = args.string
        let roleCode = args.string
                
        guard let dsf = dsf else {
            return .nothing
        }
        
        guard let feature = featureById[featureId] else {
            return .nothing
        }
        
        if debug {
            print("DEBUG: HostFeatureGetAssociatedInformationIDs. \(featureId)(\(feature.frid.ftcd)) \(associationCode) \(roleCode)")
        }
        
        var associatedFeatureIds: Set<String> = []
        for fasc in feature.fascs() {
            
            if fasc.facd != associationCode {
                continue
            }
            
            if fasc.arcd != roleCode {
                continue
            }

            if let _ = dsf.record(forIdentifier: fasc.referencedRecordIdentifier) as? InformationTypeRecord {
                let associatedFeatureId = LuaRuleExecutor.createRecordId(dsf: dsf, recordIdentifier: fasc.referencedRecordIdentifier)
                associatedFeatureIds.insert(associatedFeatureId)
            }
        }
        
        return .value(toLuaTable(associatedFeatureIds.sorted()))
    }
    
    private func HostSpatialGetAssociatedInformationIDs(_ args: Arguments) -> SwiftReturnValue {
        let spatialId = args.string
        let associationCode = args.string
        let roleCode = args.string
        
        guard let dsf = dsf else {
            return .nothing
        }

        guard let recordIdentifier = LuaRuleExecutor.createRecordIdentifier(recordId: spatialId) else {
            return .nothing
        }
        
        guard let spatial = dsf.record(forIdentifier: recordIdentifier) as? GeometryRecord else {
            return .nothing
        }
        
        if debug {
            print("DEBUG: HostSpatialGetAssociatedInformationIDs. \(spatialId) \(associationCode) \(roleCode)")
        }

        var associatedInformationIds: Set<String> = []
        for inas in spatial.inass {
            
            if inas.iacd != associationCode {
                continue
            }
            
            if inas.arcd != roleCode {
                continue
            }

            associatedInformationIds.insert(LuaRuleExecutor.createRecordId(dsf: dsf, recordIdentifier: inas.referencedRecordIdentifier))
        }

        return .value(toLuaTable(associatedInformationIds.sorted()))
    }
    
    private func HostSpatialGetAssociatedFeatureIDs(_ args: Arguments) -> SwiftReturnValue {
        let spatialId = args.string
        
        if debug {
            print("DEBUG: HostSpatialGetAssociatedFeatureIDs. \(spatialId)")
        }
        
        if let associatedFeatureIds = associatedFeatureIdsBySpatialId[spatialId] {
            return .value(toLuaTable(associatedFeatureIds))
        } else {
            return .value(toLuaTable([]))
        }
    }
    
    private func luaCreateComplexAttribute(_ ca: ComplexAttribute) -> Value? {
        
        var args: [Value?] = []
        args.append(luaCreateItem(ca))
        
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
        if debug {
            print("DEBUG: HostGetComplexAttributeTypeInfo")
        }
        
        let attributeCode = args.string
        guard let complexAttribute = featureCatalogue.complexAttributeByCode[attributeCode] else {
            return .nothing
        }
        return .value(luaCreateComplexAttribute(complexAttribute))
    }
    
    private var _luaGetUnknownAttributeString: Value? = nil
    
    private func luaGetUnknownAttributeString() -> Value? {
        if let l = _luaGetUnknownAttributeString {
            return l
        } else {
            if let l = call("GetUnknownAttributeString", []) {
                _luaGetUnknownAttributeString = l
                return l
            }
        }
        return nil
    }
    
    private func HostFeatureGetSimpleAttribute(_ args: Arguments) -> SwiftReturnValue {
        if debug {
            print("DEBUG: HostFeatureGetSimpleAttribute")
        }
        
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
        
        var values: [Value] = []
        for value in attributePath.resolveAttributePath(dsf: dsf, record: feature, atcd: attributeCode) {
            if value != "" {
                values.append(value)
            } else if let uk = luaGetUnknownAttributeString() {
                values.append(uk)
            }
        }
        
        return .value(toLuaTable(values))
    }
    
    private func HostFeatureGetComplexAttributeCount(_ args: Arguments) -> SwiftReturnValue {
        if debug {
            print("DEBUG: HostFeatureGetComplexAttributeCount")
        }
        
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
        if debug {
            print("DEBUG: HostInformationTypeGetSimpleAttribute")
        }
        
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
        
        var values: [Value] = []
        for value in attributePath.resolveAttributePath(dsf: dsf, record: record, atcd: attributeCode) {
            if value != "" {
                values.append(value)
            } else if let uk = luaGetUnknownAttributeString() {
                values.append(uk)
            }
        }
        
        return .value(toLuaTable(values))
    }
    
    private func luaCreatePoint(xcoo: Int, ycoo: Int, zcoo: Int?) -> Value? {
        var args: [Value?] = []
        args.append(String(xcoo))
        args.append(String(ycoo))
        if let zcoo = zcoo {
            args.append(String(zcoo))
        } else {
            args.append(nil)
        }
        return call("CreatePoint", args)
    }
    
    private func luaCreateMultiPoint(points: [Value]) -> Value? {
        var args: [Value] = []
        args.append(toLuaTable(points))
        return call("CreateMultiPoint", args)
    }
    
    private func luaCreateSurface(ext: Value?, ints: [Value]) -> Value? {
        var args: [Value?] = []
        args.append(ext)
        if ints.isEmpty {
            args.append(nil)
        } else {
            args.append(toLuaTable(ints))
        }
        
        return call("CreateSurface", args)
    }
    
    private func luaCreateCompositeCurve(_ curveAssociations: [Value]) -> Value? {
        var args: [Value?] = []
        args.append(toLuaTable(curveAssociations))
        return call("CreateCompositeCurve", args)
    }
    
    private func luaCreateCurveSegment(_ controlPoints: [Value], _ interpolation: Value?) -> Value? {
        var args: [Value?] = []
        args.append(toLuaTable(controlPoints))
        args.append(interpolation)
        return call("CreateCurveSegment", args)
    }
    
    private func luaCreateCurve(startPoint: Value?, endPoint: Value?, segments: [Value]) -> Value? {
        var args: [Value?] = []
        args.append(startPoint)
        args.append(endPoint)
        args.append(toLuaTable(segments))
        return call("CreateCurve", args)
    }
    
    private func HostGetSpatial(_ args: Arguments) -> SwiftReturnValue {
        let spatialId = args.string
        
        if debug {
            print("DEBUG: HostGetSpatial(\(spatialId))")
        }
        
        guard let dsf = dsf else {
            return .nothing
        }
        
        guard let recordIdentifier = LuaRuleExecutor.createRecordIdentifier(recordId: spatialId) else {
            return .nothing
        }
        
        guard let record = dsf.record(forIdentifier: recordIdentifier) as? GeometryRecord else {
            return .nothing
        }
        
        if debug {
            print("DEBUG: HostGetSpatial(\(spatialId)) \(record.spatialType())" )
        }
        
        if let pointRecord = record as? PointRecord {
            if let c2it = pointRecord.c2it {
                return .value(luaCreatePoint(xcoo: c2it.xcoo, ycoo: c2it.ycoo, zcoo: nil))
            } else if let c3it = pointRecord.c3it {
                return .value(luaCreatePoint(xcoo: c3it.xcoo, ycoo: c3it.ycoo, zcoo: c3it.zcoo))
            } else {
                return .nothing
            }
        } else if let multiPointRecord = record as? MultiPointRecord {
            var points: [Value] = []
            for c2il in multiPointRecord.c2ils {
                if let p = luaCreatePoint(xcoo: c2il.xcoo, ycoo: c2il.ycoo, zcoo: nil) {
                    points.append(p)
                }
            }
            for c3il in multiPointRecord.c3ils {
                for c3it in c3il.c3its {
                    if let p = luaCreatePoint(xcoo: c3it.xcoo, ycoo: c3it.ycoo, zcoo: c3it.zcoo) {
                        points.append(p)
                    }
                }
            }
            return .value(luaCreateMultiPoint(points: points))
        } else if let surfaceRecord = record as? SurfaceRecord {
            var exteriorRing: Value? = nil
            var interiorRings: [Value] = []
            for rias in surfaceRecord.riass {
                switch rias.usag {
                case RIAS.usagExterior:
                    if exteriorRing != nil {
                        print("ERROR: Found multiple exterior rings")
                    }
                    exteriorRing = luaCreateSpatialAssociation(rias)
                case RIAS.usagInterior:
                    if let r = luaCreateSpatialAssociation(rias) {
                        interiorRings.append(r)
                    }
                default:
                    print("ERROR: Unsupported RIAS usage \(rias.usag)")
                }
            }
            return .value(luaCreateSurface(ext: exteriorRing, ints: interiorRings))
        } else if let curveRecord = record as? CurveRecord {
            var segments: [Value] = []
            var startPoint: Value? = nil
            var endPoint: Value? = nil
            for segment in curveRecord.segments {
                var controlPoints: [any Value] = []
                for c2il in segment.c2ils {
                    if let controlPoint = luaCreatePoint(xcoo: c2il.xcoo, ycoo: c2il.ycoo, zcoo: nil) {
                        controlPoints.append(controlPoint)
                        
                        // pick up first and last. or should just use curveRecord.ptas thing?
                        if startPoint == nil {
                            startPoint = controlPoint
                        }
                        endPoint = controlPoint
                    }
                }
                if let segment = luaCreateCurveSegment(controlPoints, segment.segh.intp) {
                    segments.append(segment)
                }
            }
            return .value(luaCreateCurve(startPoint: startPoint, endPoint: endPoint, segments: segments))
        } else if let compositeCurveRecord = record as? CompositeCurveRecord {
            var associations: [Value] = []
            for cuco in compositeCurveRecord.cucos {
                if let association = luaCreateSpatialAssociation(cuco) {
                    associations.append(association)
                }
            }
            return .value(luaCreateCompositeCurve(associations))
        } else {
            print("ERROR: HostGetSpatial invalid geometry record type. \(record)")
            return .nothing
        }
    }
    
    private func HostFeatureGetAssociatedFeatureIDs(_ args: Arguments) -> SwiftReturnValue {
        if debug {
            print("DEBUG: HostFeatureGetAssociatedFeatureIDs")
        }
        
        // TODO: implement
        
        // let featureId = args.string
        // let associationCode = args.string
        // how to handle optional argument?
        //let roleCode = args.string
        
        return .value(toLuaTable([]))
    }
    
    private func HostInformationTypeGetCode(_ args: Arguments) -> SwiftReturnValue {
        if debug {
            print("DEBUG: HostInformationTypeGetCode")
        }
        
        let informationTypeID = args.string
        
        guard let recordIdenfier = LuaRuleExecutor.createRecordIdentifier(recordId: informationTypeID) else {
            return .nothing
        }
        
        guard let informationTypeRecord = dsf?.record(forIdentifier: recordIdenfier) as? InformationTypeRecord else {
            return .nothing
        }
        
        guard let code = dsf?.generalInformation?.itcd(itnc: informationTypeRecord.irid.nitc) else {
            return .nothing
        }
        
        return .value(code)
    }

    private func HostPortrayalEmit(_ args: Arguments) -> SwiftReturnValue {
        
        let featureId = args.string
        let drawingInstructions = args.string
        let observedParameters = args.string
        
        let def = DataExchangeFormat(drawingInstructions)

        // parse observed parameters for use by caches
        var observedParameterValueByName: [String: String] = [:]
        if observedParameters.count > 0 {
            for entry in DataExchangeFormat(observedParameters).entries {
                if let value = entry.arguments.first {
                    observedParameterValueByName[entry.key] = value
                }
            }
        }
        
        for drawingCommand in DrawingCommandCreator.shared.create(def: def) {
            let drawingCommandId = "\(featureId)-\(self.drawingCommands.count)"
            let featureDrawingCommand = FeatureDrawingCommand(featureId: featureId, drawingCommandId: drawingCommandId, drawingCommand: drawingCommand, observedParameters: observedParameterValueByName)
            self.drawingCommands.append(featureDrawingCommand)
        }
        
        return .value(true as Value)
    }
    
}
