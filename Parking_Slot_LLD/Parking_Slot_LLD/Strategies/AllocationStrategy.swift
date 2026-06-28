import Foundation

/// Strategy Pattern: Defines the contract for allocating a parking slot to an incoming vehicle.
/// Demonstrates the Open/Closed Principle (SOLID) - we can add new strategies without changing existing code.
public protocol SlotAllocationStrategy {
    func allocateSlot(for vehicle: Vehicle, in floors: [ParkingFloor]) -> ParkingSlot?
}

/// Allocates the first available slot starting from the lowest floor and scanning slots sequentially.
/// Mimics parking near the entrance.
public struct NearestToEntranceAllocationStrategy: SlotAllocationStrategy {
    public init() {}
    
    public func allocateSlot(for vehicle: Vehicle, in floors: [ParkingFloor]) -> ParkingSlot? {
        // Search floor by floor, starting from the first floor
        for floor in floors {
            if let slot = floor.findAvailableSlot(for: vehicle) {
                return slot
            }
        }
        return nil
    }
}

/// Optimization Strategy: Allocates the smallest compatible slot for a vehicle.
/// This prevents a Motorcycle from taking up a Large (truck) slot if compact/motorcycle slots are available.
public struct TypeOptimizedAllocationStrategy: SlotAllocationStrategy {
    public init() {}
    
    public func allocateSlot(for vehicle: Vehicle, in floors: [ParkingFloor]) -> ParkingSlot? {
        // Find all free, compatible slots across all floors
        var allCompatibleSlots: [(floor: ParkingFloor, slot: ParkingSlot)] = []
        
        for floor in floors {
            for slot in floor.slots where slot.isFree && slot.canAccommodate(vehicle: vehicle) {
                allCompatibleSlots.append((floor, slot))
            }
        }
        
        // Sort slots such that we prefer the best fit:
        // 1. Check if the slot type exactly matches the vehicle type profile
        // 2. Sort by floor level (lowest floor first)
        // 3. Sort by slot number (nearest/alphabetical first)
        let sorted = allCompatibleSlots.sorted { (item1, item2) -> Bool in
            let score1 = suitabilityScore(slotType: item1.slot.type, vehicleType: vehicle.type)
            let score2 = suitabilityScore(slotType: item2.slot.type, vehicleType: vehicle.type)
            
            if score1 != score2 {
                return score1 > score2 // higher score is a better fit (more specific)
            }
            
            // If suitability is equal, check floor
            if item1.floor.name != item2.floor.name {
                return item1.floor.name < item2.floor.name
            }
            
            // If floor is equal, check slot number
            return item1.slot.number < item2.slot.number
        }
        
        return sorted.first?.slot
    }
    
    /// Returns a score reflecting how specific a slot is for a vehicle type.
    /// Higher is better (exact fits get higher scores, oversized backups get lower).
    private func suitabilityScore(slotType: ParkingSlotType, vehicleType: VehicleType) -> Int {
        switch (vehicleType, slotType) {
        // Perfect matches
        case (.motorcycle, .motorcycle): return 10
        case (.car, .compact): return 10
        case (.truck, .large): return 10
        case (.electric, .electric): return 10
        
        // Secondary compatibility
        case (.motorcycle, .compact): return 5
        case (.motorcycle, .large): return 1
        case (.car, .large): return 5
        case (.electric, .compact): return 3
        case (.electric, .large): return 1
            
        // Fallbacks
        default: return 0
        }
    }
}
