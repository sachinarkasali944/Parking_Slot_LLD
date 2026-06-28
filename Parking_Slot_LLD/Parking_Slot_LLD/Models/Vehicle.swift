import Foundation

/// Defines the types of vehicles that can be parked in the system.
/// Demonstrates the use of Enums for clear categorisation in LLD.
public enum VehicleType: String, Codable, CaseIterable, Identifiable {
    case motorcycle = "Motorcycle"
    case car = "Car"
    case truck = "Truck"
    case electric = "Electric Car"
    
    public var id: String { self.rawValue }
    
    public var iconName: String {
        switch self {
        case .motorcycle: return "bicycle"
        case .car: return "car.fill"
        case .truck: return "box.truck.fill"
        case .electric: return "bolt.car.fill"
        }
    }
}

/// Abstract representation of a Vehicle.
/// Demonstrates the Dependency Inversion Principle (SOLID) - coding to an interface/protocol rather than concrete implementation.
public protocol Vehicle {
    var licensePlate: String { get }
    var type: VehicleType { get }
    var isHandicapped: Bool { get }
}

// Concrete Implementations of Vehicle:
// Demonstrates Liskov Substitution Principle - any subclass/implementation of Vehicle can be used interchangeably.

public struct Car: Vehicle {
    public let licensePlate: String
    public let type: VehicleType = .car
    public let isHandicapped: Bool
    
    public init(licensePlate: String, isHandicapped: Bool = false) {
        self.licensePlate = licensePlate
        self.isHandicapped = isHandicapped
    }
}

public struct Motorcycle: Vehicle {
    public let licensePlate: String
    public let type: VehicleType = .motorcycle
    public let isHandicapped: Bool
    
    public init(licensePlate: String, isHandicapped: Bool = false) {
        self.licensePlate = licensePlate
        self.isHandicapped = isHandicapped
    }
}

public struct Truck: Vehicle {
    public let licensePlate: String
    public let type: VehicleType = .truck
    public let isHandicapped: Bool
    
    public init(licensePlate: String, isHandicapped: Bool = false) {
        self.licensePlate = licensePlate
        self.isHandicapped = isHandicapped
    }
}

public struct ElectricCar: Vehicle {
    public let licensePlate: String
    public let type: VehicleType = .electric
    public let isHandicapped: Bool
    public let batteryCapacity: Double // Specific property for Electric Vehicle
    
    public init(licensePlate: String, isHandicapped: Bool = false, batteryCapacity: Double = 100.0) {
        self.licensePlate = licensePlate
        self.isHandicapped = isHandicapped
        self.batteryCapacity = batteryCapacity
    }
}

/// Factory pattern to decouple vehicle creation logic from the rest of the application.
public struct VehicleFactory {
    public static func createVehicle(type: VehicleType, licensePlate: String, isHandicapped: Bool) -> Vehicle {
        switch type {
        case .motorcycle:
            return Motorcycle(licensePlate: licensePlate, isHandicapped: isHandicapped)
        case .car:
            return Car(licensePlate: licensePlate, isHandicapped: isHandicapped)
        case .truck:
            return Truck(licensePlate: licensePlate, isHandicapped: isHandicapped)
        case .electric:
            return ElectricCar(licensePlate: licensePlate, isHandicapped: isHandicapped)
        }
    }
}
