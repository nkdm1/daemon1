import AppKit
import ApplicationServices

func getFrontmostApplication() -> NSRunningApplication? {
    return NSWorkspace.shared.frontmostApplication
}

func hasOpenedWindows(_ app: NSRunningApplication) -> Bool {
    let appElement = AXUIElementCreateApplication(app.processIdentifier)
    var windows: CFTypeRef?
    
    let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windows)
    if result == .success, let windowList = windows as? [AXUIElement], !windowList.isEmpty {
        return true
    } else {
        return false
    }
}

func openDefaultWindow(_ appName: String) {
    let script = """
        tell application "\(appName)"
            activate
            try
                tell application "\(appName)" to open
            on error
                try
                    tell application "\(appName)" to make new document
                end try
            end try
        end tell
        """
    
    if let appleScript = NSAppleScript(source: script) {
        var error: NSDictionary?
        appleScript.executeAndReturnError(&error)
        
        if let error = error {
            print("AppleScript error: \(error)")
        } else {
            print("Opened a new window in \(appName).")
        }
    }
}

func setupApplicationObserver() {
    DispatchQueue.main.async {
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { notification in
            print("Application activation detected.")
            if let frontmostApp = getFrontmostApplication(),
               let frontmostAppName = frontmostApp.localizedName {
                
                // Open a new window if none are open
                if !hasOpenedWindows(frontmostApp) {
                    openDefaultWindow(frontmostAppName)
                } else {
                    print("Frontmost application \(frontmostAppName) already has open windows.")
                }
            } else {
                print("No frontmost application found.")
            }
        }
        print("Observer setup completed.")
    }
}

@main
struct Daemon1 {
    static func main() {
        print("Starting Daemon1...")
        
        // Setup observer on the main thread
        DispatchQueue.main.async {
            setupApplicationObserver()
            print("AXIsProcessTrusted: \(AXIsProcessTrusted())")

        }
        
        // Add a timer to print "looping" every second
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            
        }
        
        // Start the RunLoop indefinitely
        RunLoop.main.run()
    }
}
