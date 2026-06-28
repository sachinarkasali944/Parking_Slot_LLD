import SwiftUI

struct EducationView: View {
    @State private var selectedTab = "patterns"
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Selection for Education View
            Picker("Topic", selection: $selectedTab) {
                Text("Design Patterns").tag("patterns")
                Text("SOLID Principles").tag("solid")
                Text("Architecture & Schema").tag("architecture")
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if selectedTab == "patterns" {
                        patternsSection
                    } else if selectedTab == "solid" {
                        solidSection
                    } else {
                        architectureSection
                    }
                }
                .padding(20)
            }
        }
    }
    
    // MARK: - Design Patterns Section
    
    private var patternsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("OOD Design Patterns Implemented")
                .font(.title2)
                .bold()
            
            Text("This learning project demonstrates several core Gang of Four (GoF) design patterns commonly evaluated in Low-Level Design (LLD) interviews.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
            
            // 1. Singleton
            PatternExplanationCard(
                title: "1. Singleton Pattern",
                fileLink: "ParkingLot.swift",
                purpose: "Ensures that there is only one instance of the central Parking Lot management system across the entire application.",
                codeSnippet: """
public class ParkingLot {
    // Shared single instance
    public static let shared = ParkingLot(name: "...")
    
    // Private initializer prevents outside instantiation
    private init(name: String) { ... }
}
"""
            )
            
            // 2. Strategy
            PatternExplanationCard(
                title: "2. Strategy Pattern",
                fileLink: "PricingStrategy.swift / AllocationStrategy.swift",
                purpose: "Encapsulates a family of algorithms (e.g., fee calculation, slot search) and makes them interchangeable at runtime. The Exit/Entry gates execute these algorithms polymorphically.",
                codeSnippet: """
public protocol PricingStrategy {
    func calculatePrice(durationHours: Double, vehicleType: VehicleType) -> Double
}

// Concrete strategies are swapped at runtime via the UI:
// - HourlyPricingStrategy
// - FlatRatePricingStrategy
// - SurgePricingStrategy (Wrapper/Decorator)
"""
            )
            
            // 3. Factory
            PatternExplanationCard(
                title: "3. Factory Method Pattern",
                fileLink: "Vehicle.swift",
                purpose: "Decouples the client code from concrete vehicle instantiation. The system requests a vehicle by type and the factory manages creation details.",
                codeSnippet: """
public struct VehicleFactory {
    public static func createVehicle(type: VehicleType, licensePlate: String, isHandicapped: Bool) -> Vehicle {
        switch type {
        case .motorcycle: return Motorcycle(...)
        case .car: return Car(...)
        ...
        }
    }
}
"""
            )
            
            // 4. Observer Pattern
            PatternExplanationCard(
                title: "4. Observer Pattern",
                fileLink: "ParkingFloor.swift",
                purpose: "Propagates state changes from individual slots to aggregate displays board reactively. When slot parking/vacation happens, the floor triggers an update on its DisplayBoard.",
                codeSnippet: """
public class ParkingFloor {
    public var slots: [ParkingSlot]
    public let displayBoard: ParkingDisplayBoard
    
    public func addSlot(_ slot: ParkingSlot) {
        slots.append(slot)
        updateDisplayBoard() // Updates observer target
    }
}
"""
            )
        }
    }
    
    // MARK: - SOLID Section
    
    private var solidSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("SOLID Design Principles")
                .font(.title2)
                .bold()
            
            Text("A review of how the codebase adheres to standard SOLID OOD requirements.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
            
            SolidPrincipleRow(
                letter: "S",
                title: "Single Responsibility Principle (SRP)",
                desc: "Every class has one responsibility. For example, ParkingTicket is a simple data record, PaymentService strictly processes payments, and EntryGate is only responsible for assigning slots and issuing tickets.",
                exampleFile: "Gate.swift / PaymentService.swift"
            )
            
            SolidPrincipleRow(
                letter: "O",
                title: "Open/Closed Principle (OCP)",
                desc: "Classes are open for extension but closed for modification. We can add new pricing (e.g., WeekendSurgePricingStrategy) or allocation engines (e.g., RandomAllocationStrategy) without modifying the EntryGate/ExitGate codes.",
                exampleFile: "PricingStrategy.swift / AllocationStrategy.swift"
            )
            
            SolidPrincipleRow(
                letter: "L",
                title: "Liskov Substitution Principle (LSP)",
                desc: "Concrete objects can substitute their interfaces. Any type conforming to the Vehicle protocol (Car, Motorcycle, Truck, ElectricCar) can be passed seamlessly into EntryGate's park operations.",
                exampleFile: "Vehicle.swift"
            )
            
            SolidPrincipleRow(
                letter: "I",
                title: "Interface Segregation Principle (ISP)",
                desc: "Protocols are small and highly specific. Vehicle and PricingStrategy protocols have simple, tightly-bound methods instead of massive general-purpose designs.",
                exampleFile: "Vehicle.swift / PricingStrategy.swift"
            )
            
            SolidPrincipleRow(
                letter: "D",
                title: "Dependency Inversion Principle (DIP)",
                desc: "High-level components (Gates, ParkingLot) depend on abstractions (Vehicle protocol, PricingStrategy protocol) rather than concrete instances (Car, HourlyPricingStrategy).",
                exampleFile: "Gate.swift"
            )
        }
    }
    
    // MARK: - Architecture & Schema Section
    
    private var architectureSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Architecture & Class Diagram")
                .font(.title2)
                .bold()
            
            Text("Below is the hierarchical domain model mapping relationships in this Parking Lot LLD.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Domain Structure Flow")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 10) {
                    HierarchyRow(parent: "ParkingLot (Singleton)", child: "Manages multiple ParkingFloors, EntryGates, and ExitGates.")
                    HierarchyRow(parent: "ParkingFloor", child: "Holds multiple ParkingSlots and 1 ParkingDisplayBoard.")
                    HierarchyRow(parent: "ParkingSlot", child: "Holds 0 or 1 Vehicle instance.")
                    HierarchyRow(parent: "EntryGate / ExitGate", child: "Interacts with SlotAllocationStrategy and PricingStrategy.")
                }
                .padding()
                .background(Color.secondary.opacity(0.06))
                .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Low-Level Entity Design Decisions")
                    .font(.headline)
                
                BulletPoint(text: "Slot Compatibility: Managed inside `ParkingSlot.canAccommodate(vehicle:)`. Trucks require Large slots, Electric cars prefer Electric slots, and Handicapped vehicles are prioritised for Handicapped slots.")
                BulletPoint(text: "Decorator Strategy: `SurgePricingStrategy` wraps an underlying `PricingStrategy` and multiplies the output, showcasing composition over inheritance.")
                BulletPoint(text: "Mutable State: In-memory simulation stores logs and active tickets directly on the `ParkingLot` singleton, making it an excellent Sandbox play-testing environment.")
            }
        }
    }
}

// MARK: - Subcomponents

struct PatternExplanationCard: View {
    let title: String
    let fileLink: String
    let purpose: String
    let codeSnippet: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                    .bold()
                Spacer()
                Text(fileLink)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.blue)
            }
            
            Text(purpose)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal) {
                Text(codeSnippet)
                    .font(.system(.caption, design: .monospaced))
                    .padding(8)
                    .background(Color.platformControlBackground)
                    .cornerRadius(6)
            }
        }
        .padding(14)
        .background(Color.secondary.opacity(0.04))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
    }
}

struct SolidPrincipleRow: View {
    let letter: String
    let title: String
    let desc: String
    let exampleFile: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text(letter)
                .font(.title)
                .bold()
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(desc)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Demonstrated in: \(exampleFile)")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
}

struct HierarchyRow: View {
    let parent: String
    let child: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "arrow.turn.down.right")
                .font(.caption)
                .foregroundColor(.blue)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(parent)
                    .font(.system(.subheadline, design: .monospaced))
                    .bold()
                Text(child)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•")
                .bold()
                .foregroundColor(.blue)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
