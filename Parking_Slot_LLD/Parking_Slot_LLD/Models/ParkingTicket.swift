import Foundation

public enum TicketStatus: String, Codable {
    case active = "Active"
    case paid = "Paid"
    case lost = "Lost"
}

/// Represents the ticket generated upon vehicle parking.
/// It holds metadata required for processing checkout, time calculations, and payments.
public struct ParkingTicket: Identifiable, Codable {
    public let id: UUID
    public let ticketNumber: String
    public let vehiclePlate: String
    public let vehicleType: VehicleType
    public let slotNumber: String
    public let floorName: String
    public let entryTime: Date
    public var exitTime: Date?
    public var amountCharged: Double?
    public var status: TicketStatus
    
    public init(vehiclePlate: String, vehicleType: VehicleType, slotNumber: String, floorName: String, entryTime: Date = Date()) {
        self.id = UUID()
        self.ticketNumber = "TKT-\(UUID().uuidString.prefix(8).uppercased())"
        self.vehiclePlate = vehiclePlate
        self.vehicleType = vehicleType
        self.slotNumber = slotNumber
        self.floorName = floorName
        self.entryTime = entryTime
        self.exitTime = nil
        self.amountCharged = nil
        self.status = .active
    }
}
