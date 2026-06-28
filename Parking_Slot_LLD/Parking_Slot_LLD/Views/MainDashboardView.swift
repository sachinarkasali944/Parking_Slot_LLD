import SwiftUI

struct MainDashboardView: View {
    @State private var parkingLot = ParkingLot.shared
    @State private var selectedTab = "simulator"
    
    // Selection state passed between Grid and Control Panel
    @State private var selectedSlot: ParkingSlot? = nil
    @State private var selectedFloor: ParkingFloor? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Top Bar / Navigation
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(parkingLot.name)
                        .font(.title)
                        .bold()
                        .foregroundColor(.primary)
                    Text("Low-Level Design Simulator & Interactive SandBox")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Segmented tab control
                Picker("Tab Selection", selection: $selectedTab) {
                    Text("Simulator").tag("simulator")
                    Text("Design Patterns & LLD Guide").tag("education")
                }
                .pickerStyle(.segmented)
                .frame(width: 320)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color.platformWindowBackground)
            
            Divider()
            
            // Content switching
            if selectedTab == "simulator" {
                simulatorLayout
            } else {
                EducationView()
                    .background(Color.platformUnderlyingWindowBackground)
            }
        }
        .frame(minWidth: 900, minHeight: 650)
    }
    
    // MARK: - Simulator Dashboard Layout
    
    private var simulatorLayout: some View {
        HStack(alignment: .top, spacing: 20) {
            
            // Left Panel: Floor Grids & System Configurations
            ScrollView {
                VStack(spacing: 20) {
                    // System Strategy Settings
                    HStack(spacing: 16) {
                        // Allocation strategy dropdown
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Allocation Strategy")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.secondary)
                            
                            Picker("", selection: $parkingLot.selectedAllocationStrategyType) {
                                ForEach(ParkingLot.AllocationStrategyType.allCases) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Pricing strategy dropdown
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Pricing Strategy")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.secondary)
                            
                            Picker("", selection: $parkingLot.selectedPricingStrategyType) {
                                ForEach(ParkingLot.PricingStrategyType.allCases) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(16)
                    .background(Color.platformControlBackground.opacity(0.4))
                    .cornerRadius(12)
                    
                    // Floors Display List
                    ForEach(parkingLot.floors) { floor in
                        FloorGridView(
                            floor: floor,
                            selectedSlot: $selectedSlot,
                            selectedFloor: $selectedFloor
                        )
                    }
                }
                .padding(.vertical, 20)
            }
            .frame(maxWidth: .infinity)
            
            Divider()
                .padding(.vertical, 20)
            
            // Right Panel: Form Actions & System Audit Logs Console
            VStack(spacing: 20) {
                // Metrics bar
                metricsBar
                    .padding(.top, 20)
                
                // Form controls for entry and exit gates
                ControlPanelView(
                    parkingLot: parkingLot,
                    selectedSlot: $selectedSlot,
                    selectedFloor: $selectedFloor
                )
                
                // System Audit Log console
                logConsole
                    .padding(.bottom, 20)
            }
            .frame(width: 380)
        }
        .padding(.horizontal, 24)
        .background(Color.platformUnderlyingWindowBackground)
    }
    
    // MARK: - Subviews
    
    private var metricsBar: some View {
        HStack(spacing: 12) {
            // Free slots count
            MetricBox(
                title: "Available Slots",
                value: "\(parkingLot.freeSlotsCount) / \(parkingLot.totalCapacity)",
                icon: "checkmark.circle.fill",
                color: .green
            )
            
            // Total system earnings
            MetricBox(
                title: "Total Earnings",
                value: String(format: "$%.2f", parkingLot.earnings),
                icon: "dollarsign.circle.fill",
                color: .blue
            )
        }
    }
    
    private var logConsole: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("System Operations Console")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.secondary)
                Spacer()
                Button("Clear Logs") {
                    parkingLot.actionLogs.removeAll()
                    parkingLot.logAction("Console log cleared.")
                }
                .buttonStyle(.plain)
                .font(.system(size: 10))
                .foregroundColor(.blue)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    if parkingLot.actionLogs.isEmpty {
                        Text("No logs yet.")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(parkingLot.actionLogs, id: \.self) { log in
                            Text(log)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(log.contains("Success") ? .green : log.contains("Failed") || log.contains("Error") ? .red : .primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(8)
            }
            .frame(height: 120)
            .background(Color.platformControlBackground.opacity(0.6))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
    }
}

struct MetricBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.headline)
                    .bold()
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding(12)
        .background(Color.platformWindowBackground.opacity(0.8))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}
