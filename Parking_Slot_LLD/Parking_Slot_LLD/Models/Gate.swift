import Foundation

/// Base class representing a Gate in the parking lot.
public class Gate: Identifiable {
    public let id: UUID
    public let name: String
    
    public init(name: String) {
        self.id = UUID()
        self.name = name
    }
}

/// Represents the Entry Gate where vehicles enter.
/// Responsible for finding a slot, parking the vehicle, and generating a ticket.
public class EntryGate: Gate {
    
    /// Entry gate operation: Find a slot, park the vehicle, and issue a ticket.
    /// Demonstrates interaction between Gates, Vehicles, Slots, and Allocation Strategy.
    public func processEntry(
        vehicle: Vehicle,
        allocationStrategy: SlotAllocationStrategy,
        floors: [ParkingFloor]
    ) -> ParkingTicket? {
        
        // Use strategy to find an available slot
        guard let slot = allocationStrategy.allocateSlot(for: vehicle, in: floors) else {
            return nil // Lot is full for this vehicle type
        }
        
        // Attempt to park the vehicle in that slot
        guard slot.park(vehicle: vehicle) else {
            return nil
        }
        
        // Find which floor this slot belongs to for ticket information
        let floorName = floors.first(where: { floor in
            floor.slots.contains(where: { $0.id == slot.id })
        })?.name ?? "Unknown Floor"
        
        // Update floor display board
        floors.forEach { $0.updateDisplayBoard() }
        
        // Generate and return ticket
        let ticket = ParkingTicket(
            vehiclePlate: vehicle.licensePlate,
            vehicleType: vehicle.type,
            slotNumber: slot.number,
            floorName: floorName,
            entryTime: Date() // Uses current date
        )
        
        return ticket
    }
}

/// Represents the Exit Gate where vehicles check out.
/// Responsible for calculating the fee, collecting payment, and vacating the slot.
public class ExitGate: Gate {
    
    /// Exit gate operation: Process payment, vacate the slot, and mark the ticket as paid.
    public func processExit(
        ticket: inout ParkingTicket,
        floors: [ParkingFloor],
        pricingStrategy: PricingStrategy,
        customHours: Double? = nil // Allows simulation of elapsed time
    ) -> Double {
        
        guard ticket.status == .active else {
            return ticket.amountCharged ?? 0.0
        }
        
        // Calculate elapsed time (simulated or real)
        let exitTime = Date()
        ticket.exitTime = exitTime
        
        let durationHours: Double
        if let customHours = customHours {
            durationHours = customHours
        } else {
            let interval = exitTime.timeIntervalSince(ticket.entryTime)
            durationHours = max(0.1, interval / 3600.0) // at least 6 minutes (0.1 hr)
        }
        
        // Calculate fare using PricingStrategy
        let fare = pricingStrategy.calculatePrice(durationHours: durationHours, vehicleType: ticket.vehicleType)
        ticket.amountCharged = fare
        ticket.status = .paid
        
        // Vacate slot
        for floor in floors {
            if let slot = floor.slots.first(where: { $0.number == ticket.slotNumber }) {
                slot.vacate()
                floor.updateDisplayBoard()
                break
            }
        }
        
        return fare
    }
}
