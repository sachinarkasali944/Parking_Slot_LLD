import Foundation

/// Strategy Pattern: Defines the contract for calculating parking fees.
/// Demonstrates high flexibility to change pricing engines without changing checkout/exit logic.
public protocol PricingStrategy {
    func calculatePrice(durationHours: Double, vehicleType: VehicleType) -> Double
}

/// Dynamic hourly billing strategy.
/// Rates scale by vehicle type to reflect space utilization.
public struct HourlyPricingStrategy: PricingStrategy {
    public init() {}
    
    public func calculatePrice(durationHours: Double, vehicleType: VehicleType) -> Double {
        let roundedHours = ceil(durationHours)
        
        let hourlyRate: Double
        switch vehicleType {
        case .motorcycle:
            hourlyRate = 2.0
        case .car:
            hourlyRate = 4.0
        case .electric:
            hourlyRate = 5.0 // Includes charging infrastructure premium
        case .truck:
            hourlyRate = 8.0
        }
        
        return roundedHours * hourlyRate
    }
}

/// Flat rate billing strategy, regardless of time parked.
/// Often used for short-term events or special parking lots.
public struct FlatRatePricingStrategy: PricingStrategy {
    public init() {}
    
    public func calculatePrice(durationHours: Double, vehicleType: VehicleType) -> Double {
        switch vehicleType {
        case .motorcycle:
            return 5.0
        case .car:
            return 12.0
        case .electric:
            return 15.0
        case .truck:
            return 25.0
        }
    }
}

/// Decorator Pattern: Wraps an existing pricing strategy and applies a surge multiplier.
/// Highlights how we can dynamically compose objects to add behaviors at runtime.
public struct SurgePricingStrategy: PricingStrategy {
    private let baseStrategy: PricingStrategy
    private let multiplier: Double
    
    public init(baseStrategy: PricingStrategy, multiplier: Double = 1.5) {
        self.baseStrategy = baseStrategy
        self.multiplier = multiplier
    }
    
    public func calculatePrice(durationHours: Double, vehicleType: VehicleType) -> Double {
        let basePrice = baseStrategy.calculatePrice(durationHours: durationHours, vehicleType: vehicleType)
        return basePrice * multiplier
    }
}
