# Parking Lot — Low-Level Design

> An interactive SwiftUI simulator for parking allocation, ticketing, and pricing.

A learning project that models floors, gates, vehicles, parking slots, tickets, and transactions. It demonstrates how allocation and pricing strategies fit into a domain service.

## Highlights

- Multiple floors and vehicle-compatible slots.
- Nearest-to-entrance and best-fit allocation strategies.
- Hourly, flat, and surge pricing strategies.
- Parking tickets, simulated checkout, earnings, and activity logs.

## Open and run

1. Clone this repository and open `Parking_Slot_LLD/Parking_Slot_LLD.xcodeproj` in Xcode.
2. Select the app scheme and a simulator compatible with the deployment target in **Build Settings → iOS Deployment Target**. Use an Xcode version with SDK support for that target.
3. Build and run with **⌘R**. For a physical device, select your development team.

```bash
git clone https://github.com/sachinarkasali944/Parking_Slot_LLD.git
cd Parking_Slot_LLD
open "Parking_Slot_LLD/Parking_Slot_LLD.xcodeproj"
```

## Demo scope

Parking state and payments are simulated. Payment method labels do not represent live payment-provider integrations.

## Explore the code

- [Xcode project](./Parking_Slot_LLD/Parking_Slot_LLD.xcodeproj)
- [Project files](./Parking_Slot_LLD)
