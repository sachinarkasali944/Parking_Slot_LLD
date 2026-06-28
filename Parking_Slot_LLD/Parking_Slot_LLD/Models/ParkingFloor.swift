import Foundation
import Observation

/// Represents the display board on each floor.
/// Demonstrates the Single Responsibility Principle - displaying slot status.
/// Also used as the Observer target where it reflects slot counts.
@Observable
public class ParkingDisplayBoard: Identifiable {
    public let id: UUID
    public var freeSlotsCount: [ParkingSlotType: Int]
    
    public init() {
        self.id = UUID()
        self.freeSlotsCount = [:]
        // Initialize all slot types to zero
        for type in ParkingSlotType.allCases {
            self.freeSlotsCount[type] = 0
        }
    }
    
    public func update(freeSlots: [ParkingSlotType: Int]) {
        self.freeSlotsCount = freeSlots
    }
}

/// Represents a parking floor containing multiple slots.
/// Shows aggregate slot metrics and manages floor layout.
@Observable
public class ParkingFloor: Identifiable {
    public let id: UUID
    public let name: String
    public var slots: [ParkingSlot]
    public let displayBoard: ParkingDisplayBoard
    
    public init(name: String) {
        self.id = UUID()
        self.name = name
        self.slots = []
        self.displayBoard = ParkingDisplayBoard()
    }
    
    /// Adds a slot to the floor.
    public func addSlot(_ slot: ParkingSlot) {
        slots.append(slot)
        updateDisplayBoard()
    }
    
    /// Updates the display board.
    /// Demonstrates the Observer concept by propagating slot updates to the display board.
    public func updateDisplayBoard() {
        var counts: [ParkingSlotType: Int] = [:]
        for type in ParkingSlotType.allCases {
            counts[type] = slots.filter { $0.type == type && $0.isFree }.count
        }
        displayBoard.update(freeSlots: counts)
    }
    
    /// Finds the first available slot that can accommodate the vehicle.
    public func findAvailableSlot(for vehicle: Vehicle) -> ParkingSlot? {
        // Find slots that are free and can accommodate the vehicle.
        // We prioritize matching slot types if possible (e.g., electric vehicle -> electric slot).
        // Let's filter compatible slots.
        let compatibleSlots = slots.filter { $0.isFree && $0.canAccommodate(vehicle: vehicle) }
        
        // Sorting strategy:
        // Try to match the exact slot type first. For example, if vehicle is electric, prefer electric slot.
        // If vehicle is motorcycle, prefer motorcycle slot.
        // If vehicle is handicapped, prefer handicapped slot.
        return compatibleSlots.sorted { (slot1, slot2) -> Bool in
            let match1 = slot1.type.rawValue.contains(vehicle.type.rawValue)
            let match2 = slot2.type.rawValue.contains(vehicle.type.rawValue)
            if match1 && !match2 { return true }
            if !match1 && match2 { return false }
            return slot1.number < slot2.number
        }.first
    }
}
