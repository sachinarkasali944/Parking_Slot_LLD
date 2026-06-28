import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension Color {
    public static var platformWindowBackground: Color {
        #if os(macOS)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color(UIColor.systemBackground)
        #endif
    }
    
    public static var platformUnderlyingWindowBackground: Color {
        #if os(macOS)
        return Color(NSColor.underlyingWindowBackgroundColor)
        #else
        return Color(UIColor.secondarySystemBackground)
        #endif
    }
    
    public static var platformControlBackground: Color {
        #if os(macOS)
        return Color(NSColor.controlBackgroundColor)
        #else
        return Color(UIColor.tertiarySystemBackground)
        #endif
    }
}
