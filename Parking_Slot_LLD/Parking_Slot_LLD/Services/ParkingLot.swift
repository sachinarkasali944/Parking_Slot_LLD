import Foundation
import Observation

/// Singleton class representing the main Parking Lot system.
/// Orchestrates floors, gates, tickets, pricing/allocation strategy configurations, and tracking earnings.
/// Conforms to @Observable for seamless UI bindings in SwiftUI.
@Observable
public class ParkingLot {
    
    // Singleton Instance
    public static let shared: ParkingLot = {
        let lot = ParkingLot(name: "Grand Plaza Parking Lot")
        lot.setupDefaultParkingLot()
        return lot
    }()
    
    // Properties
    public let name: String
    public var floors: [ParkingFloor]
    public var entryGates: [EntryGate]
    public var exitGates: [ExitGate]
    
    // Ticket & Payment tracking
    public var activeTickets: [ParkingTicket]
    public var completedTransactions: [PaymentTransaction]
    public var earnings: Double
    
    // Configurable strategies
    public var selectedAllocationStrategyType: AllocationStrategyType
    public var selectedPricingStrategyType: PricingStrategyType
    
    // Simulation audit logs
    public var actionLogs: [String]
    
    // Strategy enum definitions
    public enum AllocationStrategyType: String, CaseIterable, Identifiable {
        case nearest = "Nearest to Entrance"
        case typeOptimized = "Type Optimized (Best Fit)"
        
        public var id: String { self.rawValue }
        
        public var strategy: SlotAllocationStrategy {
            switch self {
            case .nearest:
                return NearestToEntranceAllocationStrategy()
            case .typeOptimized:
                return TypeOptimizedAllocationStrategy()
            }
        }
    }
    
    public enum PricingStrategyType: String, CaseIterable, Identifiable {
        case hourly = "Hourly Rate"
        case flat = "Flat Rate"
        case surge = "Surge Pricing (1.5x Hourly)"
        
        public var id: String { self.rawValue }
        
        public var strategy: PricingStrategy {
            switch self {
            case .hourly:
                return HourlyPricingStrategy()
            case .flat:
                return FlatRatePricingStrategy()
            case .surge:
                return SurgePricingStrategy(baseStrategy: HourlyPricingStrategy(), multiplier: 1.5)
            }
        }
    }
    
    // Initializer
    private init(name: String) {
        self.name = name
        self.floors = []
        self.entryGates = []
        self.exitGates = []
        self.activeTickets = []
        self.completedTransactions = []
        self.earnings = 0.0
        self.selectedAllocationStrategyType = .typeOptimized
        self.selectedPricingStrategyType = .hourly
        self.actionLogs = []
    }
    
    /// Sets up a default lot configuration for simulation purposes.
    private func setupDefaultParkingLot() {
        // Create 3 floors
        let floorNames = ["Floor G", "Floor 1", "Floor 2"]
        
        for (fIndex, fName) in floorNames.enumerated() {
            let floor = ParkingFloor(name: fName)
            
            // Create 10 slots per floor:
            // 2 Motorcycle, 4 Compact, 2 Large, 1 Electric, 1 Handicapped
            let layout: [(type: ParkingSlotType, count: Int)] = [
                (.motorcycle, 2),
                (.compact, 4),
                (.large, 2),
                (.electric, 1),
                (.handicapped, 1)
            ]
            
            var slotIndex = 1
            for config in layout {
                for _ in 0..<config.count {
                    let slotNumber = "\(fName.first ?? "F")-\(String(format: "%02d", slotIndex))"
                    let slot = ParkingSlot(number: slotNumber, type: config.type)
                    floor.addSlot(slot)
                    slotIndex += 1
                }
            }
            
            self.floors.append(floor)
        }
        
        // Setup Gates
        self.entryGates = [
            EntryGate(name: "North Entry Gate A"),
            EntryGate(name: "South Entry Gate B")
        ]
        
        self.exitGates = [
            ExitGate(name: "East Exit Gate C"),
            ExitGate(name: "West Exit Gate D")
        ]
        
        logAction("Parking Lot \(name) initialized with 3 floors, 30 slots, 2 entry gates, and 2 exit gates.")
    }
    
    // MARK: - Simulation APIs
    
    /// Simulates parking a vehicle.
    /// Uses Entry Gate, Vehicle Factory, and Allocation Strategy.
    @discardableResult
    public func parkVehicle(
        type: VehicleType,
        licensePlate: String,
        isHandicapped: Bool,
        entryGateIndex: Int
    ) -> ParkingTicket? {
        
        guard entryGateIndex < entryGates.count else {
            logAction("Error: Invalid entry gate selection.")
            return nil
        }
        
        let gate = entryGates[entryGateIndex]
        let vehicle = VehicleFactory.createVehicle(type: type, licensePlate: licensePlate, isHandicapped: isHandicapped)
        
        logAction("Vehicle \(licensePlate) (\(type.rawValue)\(isHandicapped ? ", Handicapped" : "")) arriving at \(gate.name)")
        
        // Delegate entry processing to selected entry gate
        let strategy = selectedAllocationStrategyType.strategy
        if let ticket = gate.processEntry(vehicle: vehicle, allocationStrategy: strategy, floors: floors) {
            activeTickets.append(ticket)
            logAction("Success: Parked vehicle \(licensePlate) at \(ticket.floorName) slot \(ticket.slotNumber). Ticket issued: \(ticket.ticketNumber)")
            return ticket
        } else {
            logAction("Failed: No parking slot available for vehicle \(licensePlate) (\(type.rawValue)) using \(selectedAllocationStrategyType.rawValue).")
            return nil
        }
    }
    
    /// Simulates unparking a vehicle, calculating fares, processing payments, and vacating slots.
    @discardableResult
    public func unparkVehicle(
        ticketNumber: String,
        paymentMethod: PaymentMethod,
        exitGateIndex: Int,
        customHours: Double? = nil
    ) -> Bool {
        
        guard exitGateIndex < exitGates.count else {
            logAction("Error: Invalid exit gate selection.")
            return false
        }
        
        guard let ticketIndex = activeTickets.firstIndex(where: { $0.ticketNumber == ticketNumber }) else {
            logAction("Error: Ticket \(ticketNumber) not found in active records.")
            return false
        }
        
        let gate = exitGates[exitGateIndex]
        var ticket = activeTickets[ticketIndex]
        
        logAction("Vehicle \(ticket.vehiclePlate) exiting via \(gate.name) with Ticket \(ticket.ticketNumber)")
        
        // Delegate exit calculation and slot vacating to exit gate
        let pricing = selectedPricingStrategyType.strategy
        let fare = gate.processExit(ticket: &ticket, floors: floors, pricingStrategy: pricing, customHours: customHours)
        
        // Process Payment simulation
        let paymentService = PaymentService()
        let transaction = paymentService.processPayment(amount: fare, method: paymentMethod, ticketNumber: ticketNumber)
        
        completedTransactions.append(transaction)
        earnings += fare
        
        // Remove ticket from active records
        activeTickets.remove(at: ticketIndex)
        
        logAction("Success: Vehicle \(ticket.vehiclePlate) checked out. Duration: \(String(format: "%.1f", customHours ?? 0.1)) hrs. Paid $\(String(format: "%.2f", fare)) via \(paymentMethod.rawValue). Transaction ID: \(transaction.transactionId)")
        
        return true
    }
    
    /// Logger helper
    public func logAction(_ message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let timestamp = formatter.string(from: Date())
        
        // Keep logs capped at 100 entries for simulation performance
        if actionLogs.count >= 100 {
            actionLogs.removeLast()
        }
        actionLogs.insert("[\(timestamp)] \(message)", at: 0)
    }
    
    /// Helper to check occupancy status
    public var totalCapacity: Int {
        return floors.reduce(0) { $0 + $1.slots.count }
    }
    
    public var occupiedSlotsCount: Int {
        return floors.reduce(0) { count, floor in
            count + floor.slots.filter { !$0.isFree }.count
        }
    }
    
    public var freeSlotsCount: Int {
        return totalCapacity - occupiedSlotsCount
    }
}
