//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

struct DrawingCommandCreator: Sendable {
    
    static let shared = DrawingCommandCreator()
    
    private let registry: [String: @Sendable (PortrayalState, [String]) -> DrawingCommand?]
    
    private init() {
        var registry: [String: @Sendable (PortrayalState, [String]) -> DrawingCommand?] = [:]
        
        // visibility state commands
        registry["ViewingGroup"] = ViewingGroupCommand.handle(state:args:)
        registry["DisplayPlane"] = DisplayPlane.handle(state:args:)
        registry["DrawingPriority"] = DrawingPriorityCommand.handle(state:args:)
        registry["ScaleMinimum"] = ScaleMinimumCommand.handle(state:args:)
        registry["ScaleMaximum"] = ScaleMaximumCommand.handle(state:args:)
        registry["Id"] = IdCommand.handle(state:args:)
        registry["Parent"] = ParentCommand.handle(state:args:)
        registry["Hover"] = HoverCommand.handle(state:args:)
        
        // transform
        registry["LocalOffset"] = LocalOffsetCommand.handle(state:args:)
        registry["LinePlacement"] = LinePlacementCommand.handle(state:args:)
        registry["AreaPlacement"] = AreaPlacementCommand.handle(state:args:)
        registry["AreaCRS"] = AreaCRSCommand.handle(state:args:)
        registry["Rotation"] = RotationCommand.handle(state:args:)
        registry["ScaleFactor"] = ScaleFactorCommand.handle(state:args:)

        // line style
        registry["Dash"] = DashCommand.handle(state:args:)
        registry["LineStyle"] = LineStyleCommand.handle(state:args:)
        
        // text style
        registry["FontColor"] = FontColor.handle(state:args:)
        registry["FontSize"] = FontSize.handle(state:args:)
        registry["FontProportion"] = FontProportion.handle(state:args:)
        registry["FontWeight"] = FontWeight.handle(state:args:)
        registry["FontSlant"] = FontSlant.handle(state:args:)
        registry["FontSerifs"] = FontSerifs.handle(state:args:)
        registry["FontUnderline"] = FontUnderline.handle(state:args:)
        registry["FontStrikethrough"] = FontStrikethrough.handle(state:args:)
        registry["FontUpperline"] = FontUpperline.handle(state:args:)
        registry["FontReference"] = FontReference.handle(state:args:)
        registry["TextAlignHorizontal"] = TextAlignHorizontal.handle(state:args:)
        registry["TextAlignVertical"] = TextAlignVertical.handle(state:args:)
        registry["TextVerticalOffset"] = TextVerticalOffset.handle(state:args:)

        // geometry
        registry["SpatialReference"] = SpatialReference.handle(state:args:)
        registry["AugmentedPoint"] = AugmentedPoint.handle(state:args:)
        registry["AugmentedRay"] = AugmentedRay.handle(state:args:)
        registry["AugmentedPath"] = AugmentedPath.handle(state:args:)
        registry["Polyline"] = Polyline.handle(state:args:)
        registry["Arc3Points"] = Arc3Points.handle(state:args:)
        registry["ArcByRadius"] = ArcByRadius.handle(state:args:)
        registry["Annulus"] = Annulus.handle(state:args:)
        registry["ClearGeometry"] = ClearGeometry.handle(state:args:)
        
        // alert
        registry["AlertReference"] = AlertReference.handle(state:args:)

        // drawing commands
        registry["PointInstruction"] = PointInstruction.init(state:args:)
        registry["LineInstruction"] = LineInstruction.init(state:args:)
        registry["ColorFill"] = ColorFill.init(state:args:)
        registry["TextInstruction"] = TextInstruction.init(state:args:)
        
        // null instruction
        registry["NullInstruction"] = NullInstruction.init(state:args:)
        
        self.registry = registry

    }
    
    func create(def: DataExchangeFormat) -> [DrawingCommand] {
        var drawingCommands = [DrawingCommand]()
        
        let state = PortrayalState()
        for entry in def.entries {
            // dictionary instead of switch for faster lookup
            if let function = registry[entry.key] {
                if let drawingCommand = function(state, entry.arguments) {
                    drawingCommands.append(drawingCommand)
                }
            } else {
                print("TODO: unknown instruction: \(entry.key) for args: \(entry.arguments)")
            }
        }
        
        return drawingCommands
    }
    
}
