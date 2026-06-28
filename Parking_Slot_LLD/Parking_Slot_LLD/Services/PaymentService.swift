import Foundation

public enum PaymentMethod: String, Codable, CaseIterable, Identifiable {
    case cash = "Cash"
    case creditCard = "Credit/Debit Card"
    case upi = "UPI (QR Code)"
    case mobileWallet = "Apple Pay / Wallet"
    
    public var id: String { self.rawValue }
    
    public var iconName: String {
        switch self {
        case .cash: return "banknote.fill"
        case .creditCard: return "creditcard.fill"
        case .upi: return "qrcode"
        case .mobileWallet: return "iphone.smartcard"
        }
    }
}

public enum PaymentStatus: String, Codable {
    case pending = "Pending"
    case completed = "Completed"
    case failed = "Failed"
}

public struct PaymentTransaction: Identifiable, Codable {
    public let id: UUID
    public let transactionId: String
    public let ticketNumber: String
    public let amount: Double
    public let method: PaymentMethod
    public let timestamp: Date
    public let status: PaymentStatus
    
    public init(ticketNumber: String, amount: Double, method: PaymentMethod, status: PaymentStatus = .completed) {
        self.id = UUID()
        self.transactionId = "TXN-\(UUID().uuidString.prefix(10).uppercased())"
        self.ticketNumber = ticketNumber
        self.amount = amount
        self.method = method
        self.timestamp = Date()
        self.status = status
    }
}

/// Simulates payment processing for ticket checkouts.
public class PaymentService {
    
    public init() {}
    
    /// Processes a simulated payment and returns a transaction record.
    public func processPayment(
        amount: Double,
        method: PaymentMethod,
        ticketNumber: String
    ) -> PaymentTransaction {
        // Here we simulate external gateway payment.
        // In a real system, this integrates with Stripe/PayPal/UPI APIs.
        
        // Let's assume the transaction completes successfully for this simulation.
        let transaction = PaymentTransaction(
            ticketNumber: ticketNumber,
            amount: amount,
            method: method,
            status: .completed
        )
        
        return transaction
    }
}
