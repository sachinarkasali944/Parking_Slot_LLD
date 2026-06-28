import SwiftUI

struct ControlPanelView: View {
    @Bindable var parkingLot: ParkingLot
    
    // Selection inputs
    @Binding var selectedSlot: ParkingSlot?
    @Binding var selectedFloor: ParkingFloor?
    
    // Park vehicle state
    @State private var licensePlate: String = ""
    @State private var vehicleType: VehicleType = .car
    @State private var isHandicapped: Bool = false
    @State private var selectedEntryGateIndex: Int = 0
    
    // Checkout state
    @State private var simulatedHours: Double = 2.0
    @State private var paymentMethod: PaymentMethod = .upi
    @State private var selectedExitGateIndex: Int = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // 1. PARK VEHICLE PANEL
            VStack(alignment: .leading, spacing: 12) {
                Text("Entry Gate Simulation")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(spacing: 10) {
                    // License Plate input + Random button
                    HStack {
                        TextField("License Plate (e.g. MH-12-AB-4567)", text: $licensePlate)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(.body, design: .monospaced))
                        
                        Button("Random") {
                            licensePlate = generateRandomLicensePlate()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.secondary)
                    }
                    
                    // Vehicle Type Selector
                    Picker("Vehicle Type", selection: $vehicleType) {
                        ForEach(VehicleType.allCases) { type in
                            HStack {
                                Image(systemName: type.iconName)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    // Handicapped Accessible toggle
                    Toggle(isOn: $isHandicapped) {
                        HStack {
                            Image(systemName: "figure.roll")
                                .foregroundColor(.blue)
                            Text("Requires Handicapped Slot")
                                .font(.subheadline)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    
                    // Entry Gate Selector
                    Picker("Entry Gate", selection: $selectedEntryGateIndex) {
                        ForEach(0..<parkingLot.entryGates.count, id: \.self) { index in
                            Text(parkingLot.entryGates[index].name).tag(index)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    // Submit Park Button
                    Button(action: parkVehicle) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                            Text("Generate Ticket & Park")
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(licensePlate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(14)
                .background(Color.platformControlBackground.opacity(0.5))
                .cornerRadius(12)
            }
            
            // 2. CHECKOUT/UNPARK PANEL
            VStack(alignment: .leading, spacing: 12) {
                Text("Exit Gate Simulation")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let slot = selectedSlot, let vehicle = slot.parkedVehicle {
                    let ticket = parkingLot.activeTickets.first(where: { $0.slotNumber == slot.number })
                    
                    VStack(spacing: 12) {
                        // Display Ticket Details
                        VStack(alignment: .leading, spacing: 6) {
                            DetailRow(label: "Slot Number", value: slot.number)
                            DetailRow(label: "Plate", value: vehicle.licensePlate, monospaced: true)
                            DetailRow(label: "Vehicle Type", value: vehicle.type.rawValue)
                            if let ticket = ticket {
                                DetailRow(label: "Ticket ID", value: ticket.ticketNumber, monospaced: true)
                            }
                        }
                        .padding(8)
                        .background(Color.secondary.opacity(0.08))
                        .cornerRadius(8)
                        
                        Divider()
                        
                        // Simulated Parking Duration Slider
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Simulated Duration:")
                                    .font(.subheadline)
                                Spacer()
                                Text(String(format: "%.1f Hours", simulatedHours))
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.blue)
                            }
                            
                            Slider(value: $simulatedHours, in: 0.5...24, step: 0.5)
                        }
                        
                        // Price Calculation Preview
                        let activePricing = parkingLot.selectedPricingStrategyType.strategy
                        let price = activePricing.calculatePrice(durationHours: simulatedHours, vehicleType: vehicle.type)
                        
                        HStack {
                            Text("Estimated Price:")
                                .font(.headline)
                            Spacer()
                            Text(String(format: "$%.2f", price))
                                .font(.title3)
                                .bold()
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 4)
                        
                        // Exit Gate Picker
                        Picker("Exit Gate", selection: $selectedExitGateIndex) {
                            ForEach(0..<parkingLot.exitGates.count, id: \.self) { index in
                                Text(parkingLot.exitGates[index].name).tag(index)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        // Payment Method
                        Picker("Payment Method", selection: $paymentMethod) {
                            ForEach(PaymentMethod.allCases) { method in
                                HStack {
                                    Image(systemName: method.iconName)
                                    Text(method.rawValue)
                                }
                                .tag(method)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        // Unpark / Pay Button
                        Button(action: {
                            if let ticket = ticket {
                                unparkVehicle(ticketNumber: ticket.ticketNumber)
                            }
                        }) {
                            HStack {
                                Image(systemName: "creditcard.fill")
                                Text("Process Payment & Checkout")
                                    .bold()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                    }
                    .padding(14)
                    .background(Color.platformControlBackground.opacity(0.5))
                    .cornerRadius(12)
                } else {
                    VStack {
                        Image(systemName: "info.circle")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 4)
                        Text("Select an occupied parking slot from the grid above to checkout or view ticket details.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .padding(.horizontal, 20)
                    .background(Color.platformControlBackground.opacity(0.3))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    // MARK: - Simulation Actions
    
    private func parkVehicle() {
        let cleanedPlate = licensePlate.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !cleanedPlate.isEmpty else { return }
        
        parkingLot.parkVehicle(
            type: vehicleType,
            licensePlate: cleanedPlate,
            isHandicapped: isHandicapped,
            entryGateIndex: selectedEntryGateIndex
        )
        
        // Reset fields
        licensePlate = ""
        isHandicapped = false
    }
    
    private func unparkVehicle(ticketNumber: String) {
        let success = parkingLot.unparkVehicle(
            ticketNumber: ticketNumber,
            paymentMethod: paymentMethod,
            exitGateIndex: selectedExitGateIndex,
            customHours: simulatedHours
        )
        
        if success {
            selectedSlot = nil
            selectedFloor = nil
            simulatedHours = 2.0 // reset slider
        }
    }
    
    // Helper to generate mock plates
    private func generateRandomLicensePlate() -> String {
        let states = ["NY", "CA", "TX", "FL", "MH", "KA", "DL"]
        let state = states.randomElement() ?? "CA"
        let num1 = Int.random(in: 10...99)
        let letters = String((0..<2).map { _ in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".randomElement()! })
        let num2 = Int.random(in: 1000...9999)
        return "\(state)-\(num1)-\(letters)-\(num2)"
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    var monospaced: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(monospaced ? .system(.caption, design: .monospaced) : .caption)
                .bold()
                .foregroundColor(.primary)
        }
    }
}
