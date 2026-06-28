//
//  Parking_Slot_LLDTests.swift
//  Parking_Slot_LLDTests
//
//  Created by Sachin Arkasali on 14/06/26.
//

import XCTest
@testable import Parking_Slot_LLD

final class Parking_Slot_LLDTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testVehicleCreationAndFactory() {
        let car = VehicleFactory.createVehicle(type: .car, licensePlate: "CAR-01", isHandicapped: false)
        XCTAssertEqual(car.type, .car)
        XCTAssertEqual(car.licensePlate, "CAR-01")
        XCTAssertFalse(car.isHandicapped)
        
        let electric = VehicleFactory.createVehicle(type: .electric, licensePlate: "EV-01", isHandicapped: true)
        XCTAssertEqual(electric.type, .electric)
        XCTAssertTrue(electric.isHandicapped)
    }
    
    func testSlotAccommodationRules() {
        let compactSlot = ParkingSlot(number: "C-01", type: .compact)
        let largeSlot = ParkingSlot(number: "L-01", type: .large)
        let motorSlot = ParkingSlot(number: "M-01", type: .motorcycle)
        let evSlot = ParkingSlot(number: "E-01", type: .electric)
        let handicappedSlot = ParkingSlot(number: "H-01", type: .handicapped)
        
        let car = Car(licensePlate: "CAR-1")
        let truck = Truck(licensePlate: "TRUCK-1")
        let motor = Motorcycle(licensePlate: "BIKE-1")
        let ev = ElectricCar(licensePlate: "EV-1")
        let handicappedCar = Car(licensePlate: "H-CAR", isHandicapped: true)
        
        // Compact slot fits car, motorcycle, but NOT truck
        XCTAssertTrue(compactSlot.canAccommodate(vehicle: car))
        XCTAssertTrue(compactSlot.canAccommodate(vehicle: motor))
        XCTAssertFalse(compactSlot.canAccommodate(vehicle: truck))
        XCTAssertTrue(compactSlot.canAccommodate(vehicle: handicappedCar)) // handicapped vehicles can also use standard slots
        
        // Large slot fits truck, car, motorcycle
        XCTAssertTrue(largeSlot.canAccommodate(vehicle: truck))
        XCTAssertTrue(largeSlot.canAccommodate(vehicle: car))
        XCTAssertTrue(largeSlot.canAccommodate(vehicle: motor))
        
        // Motorcycle slot fits motorcycle only
        XCTAssertTrue(motorSlot.canAccommodate(vehicle: motor))
        XCTAssertFalse(motorSlot.canAccommodate(vehicle: car))
        XCTAssertFalse(motorSlot.canAccommodate(vehicle: truck))
        
        // EV slot fits EV only (in this design)
        XCTAssertTrue(evSlot.canAccommodate(vehicle: ev))
        XCTAssertFalse(evSlot.canAccommodate(vehicle: car))
        
        // Handicapped slot fits handicapped vehicles only
        XCTAssertTrue(handicappedSlot.canAccommodate(vehicle: handicappedCar))
        XCTAssertFalse(handicappedSlot.canAccommodate(vehicle: car))
    }
    
    func testPricingStrategies() {
        let hourly = HourlyPricingStrategy()
        let flat = FlatRatePricingStrategy()
        let surge = SurgePricingStrategy(baseStrategy: hourly, multiplier: 1.5)
        
        // Hourly rate: Car = $4/hr. 2.5 hours rounds up to 3 hours = $12
        XCTAssertEqual(hourly.calculatePrice(durationHours: 2.5, vehicleType: .car), 12.0)
        // Motorcycle = $2/hr. 1.0 hour = $2
        XCTAssertEqual(hourly.calculatePrice(durationHours: 1.0, vehicleType: .motorcycle), 2.0)
        
        // Flat rate: Car = $12 flat, Truck = $25 flat
        XCTAssertEqual(flat.calculatePrice(durationHours: 10.0, vehicleType: .car), 12.0)
        XCTAssertEqual(flat.calculatePrice(durationHours: 0.5, vehicleType: .truck), 25.0)
        
        // Surge pricing: Car = $4/hr * 3 hrs * 1.5 = $18
        XCTAssertEqual(surge.calculatePrice(durationHours: 2.5, vehicleType: .car), 18.0)
    }
    
    func testAllocationStrategies() {
        let floor = ParkingFloor(name: "Test Floor")
        let slotM = ParkingSlot(number: "M-01", type: .motorcycle)
        let slotC = ParkingSlot(number: "C-01", type: .compact)
        let slotL = ParkingSlot(number: "L-01", type: .large)
        
        floor.addSlot(slotM)
        floor.addSlot(slotC)
        floor.addSlot(slotL)
        
        let nearest = NearestToEntranceAllocationStrategy()
        let optimized = TypeOptimizedAllocationStrategy()
        
        let motor = Motorcycle(licensePlate: "BIKE")
        
        // Nearest allocates the first compatible: M-01 is first and matches motorcycle.
        let allocatedNearest = nearest.allocateSlot(for: motor, in: [floor])
        XCTAssertEqual(allocatedNearest?.number, "M-01")
        
        // TypeOptimized allocates the best fit first.
        // For motorcycle, M-01 is best fit.
        let allocatedOpt = optimized.allocateSlot(for: motor, in: [floor])
        XCTAssertEqual(allocatedOpt?.number, "M-01")
        
        // If M-01 is occupied, TypeOptimized should fall back to C-01
        slotM.park(vehicle: motor)
        let allocatedOpt2 = optimized.allocateSlot(for: motor, in: [floor])
        XCTAssertEqual(allocatedOpt2?.number, "C-01")
    }

}
