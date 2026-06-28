import SwiftUI

/// A component that renders a grid layout of slots on a floor.
/// Integrates interactive click states to select slots for checkout or inspect vehicle metadata.
struct FloorGridView: View {
    let floor: ParkingFloor
    @Binding var selectedSlot: ParkingSlot?
    @Binding var selectedFloor: ParkingFloor?
    
    // Grid configuration for slots
    private let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 110), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Floor Header & Display Board stats
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(floor.name)
                        .font(.title3)
                        .bold()
                        .foregroundColor(.primary)
                    
                    Text("\(floor.slots.filter({ $0.isFree }).count) / \(floor.slots.count) Slots Available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Miniature Display Board View
                HStack(spacing: 8) {
                    ForEach(ParkingSlotType.allCases) { type in
                        let count = floor.displayBoard.freeSlotsCount[type] ?? 0
                        HStack(spacing: 4) {
                            Image(systemName: type.symbol)
                                .font(.system(size: 10))
                            Text("\(count)")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(count > 0 ? Color.green.opacity(0.15) : Color.red.opacity(0.1))
                        .cornerRadius(6)
                        .foregroundColor(count > 0 ? .green : .red)
                        .help("Free \(type.rawValue) slots")
                    }
                }
            }
            .padding(.bottom, 4)
            
            // Grid of Slots
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(floor.slots) { slot in
                    SlotCardView(slot: slot, isSelected: selectedSlot?.id == slot.id)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedSlot = slot
                                selectedFloor = floor
                            }
                        }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.platformWindowBackground.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

/// Individual Slot rendering card.
/// Demonstrates high-fidelity visual representations (green/red indicators, badges).
struct SlotCardView: View {
    let slot: ParkingSlot
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 6) {
            // Slot Number & Icon
            HStack {
                Image(systemName: slot.type.symbol)
                    .font(.caption)
                Spacer()
                Text(slot.number)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
            }
            .foregroundColor(isSelected ? .white : .secondary)
            
            Spacer()
            
            // Occupancy state visualizer
            if let vehicle = slot.parkedVehicle {
                VStack(spacing: 2) {
                    Text(vehicle.licensePlate)
                        .font(.system(size: 10, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    Text(vehicle.type.rawValue)
                        .font(.system(size: 8))
                        .opacity(0.8)
                }
                .foregroundColor(isSelected ? .white : .primary)
            } else {
                Text("VACANT")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .green)
                    .tracking(1)
            }
            
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .frame(height: 70)
        .background(
            ZStack {
                if isSelected {
                    LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(slot.isFree ? Color.green.opacity(0.08) : Color.red.opacity(0.08))
                }
            }
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isSelected ? Color.blue : (slot.isFree ? Color.green.opacity(0.3) : Color.red.opacity(0.3)),
                    lineWidth: 1
                )
        )
        .shadow(color: isSelected ? Color.blue.opacity(0.3) : Color.clear, radius: 6, x: 0, y: 3)
        .scaleEffect(isSelected ? 1.05 : 1.0)
    }
}
