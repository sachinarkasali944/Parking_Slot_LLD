import Foundation
import Observation

/// Represents the type of parking slots.
/// Demonstrates the Single Responsibility Principle - each slot type has a defined set of capabilities.
public enum ParkingSlotType: String, Codable, CaseIterable, Identifiable {
    case motorcycle = "Motorcycle Only"
    case compact = "Compact"
    case large = "Large"
    case electric = "Electric Vehicle"
    case handicapped = "Handicapped Accessible"
    
    public var id: String { self.rawValue }
    
    public var symbol: String {
        switch self {
        case .motorcycle: return "bicycle"
        case .compact: return "car"
        case .large: return "box.truck"
        case .electric: return "bolt.car"
        case .handicapped: return "figure.roll"
        }
    }
}

/// Represents a physical parking slot.
/// Marked with @Observable (Swift 5.9+) for reactive SwiftUI updates.
@Observable
public class ParkingSlot: Identifiable {
    public let id: UUID
    public let number: String
    public let type: ParkingSlotType
    
    // The current vehicle parked in this slot.
    // Protocols are not directly Codable, so we use type erasure or keep it optional.
    public var parkedVehicle: Vehicle?
    
    public var isFree: Bool {
        return parkedVehicle == nil
    }
    
    public init(number: String, type: ParkingSlotType) {
        self.id = UUID()
        self.number = number
        self.type = type
        self.parkedVehicle = nil
    }
    
    /// Logic to determine if a vehicle can fit/park in this slot.
    /// Demonstrates business rule enforcement inside the domain model.
    public func canAccommodate(vehicle: Vehicle) -> Bool {
        // Handicapped vehicles take priority in Handicapped slots.
        if vehicle.isHandicapped {
            return type == .handicapped || type == .large || type == .compact
        }
        
        // Non-handicapped vehicle trying to park in Handicapped slot.
        if type == .handicapped {
            return false // reserved
        }
        
        switch vehicle.type {
        case .motorcycle:
            // Motorcycles can park in motorcycle, compact, or large slots
            return type == .motorcycle || type == .compact || type == .large
        case .car:
            // Cars can park in compact or large slots
            return type == .compact || type == .large
        case .truck:
            // Trucks can only park in large slots
            return type == .large
        case .electric:
            // Electric cars prefer electric slots, but can park in compact or large in emergencies.
            // For LLD simulation, let's keep electric vehicles to Electric slots, or Compact/Large slots.
            return type == .electric || type == .compact || type == .large
        }
    }
    
    /// Parks a vehicle in the slot if it is free and fits.
    @discardableResult
    public func park(vehicle: Vehicle) -> Bool {
        guard isFree, canAccommodate(vehicle: vehicle) else {
            return false
        }
        self.parkedVehicle = vehicle
        return true
    }
    
    /// Vacates the parking slot.
    public func vacate() {
        self.parkedVehicle = nil
    }
}
