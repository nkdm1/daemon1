import AppKit

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

/*
func openWindowByAS(_ appName: String) {
    let script = """
        tell application "\(appName)"
            activate
            try
                tell application "\(appName)" to open
            on error
                try
                    tell application "\(appName)" to make new window
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
*/

func setupApplicationObserver() {
    NSWorkspace.shared.notificationCenter.addObserver(
        forName: NSWorkspace.didActivateApplicationNotification,
        object: nil,
        queue: .main
    )
    { notification in
        if  let frontmostApp = getFrontmostApplication(),
            let frontmostAppName = frontmostApp.localizedName,
            let bundleURL = frontmostApp.bundleURL{
                
            if !hasOpenedWindows(frontmostApp) {
                openWindowByNSWorkspace(bundleURL)
                print("Opened window for \(frontmostAppName).")
            } else {
                print("\(frontmostAppName) has open windows.")
            }
        } else {
            print("No frontmost application found.")
        }
    }
}

class openConfig: NSWorkspace.OpenConfiguration{
    override init() {
        super.init()
        requiresUniversalLinks = false
        isForPrinting = false
        activates = false
        addsToRecentItems = false
        allowsRunningApplicationSubstitution = false
        createsNewApplicationInstance = false
        hides = false
        hidesOthers = false
    }
    
}

func openWindowByNSWorkspace(_ url: URL){
    let openConfig = openConfig()
    NSWorkspace.shared.openApplication(at: url, configuration: openConfig)
}
