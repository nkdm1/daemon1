import AppKit

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

func getFrontmostApplication() -> NSRunningApplication? {
    return NSWorkspace.shared.frontmostApplication
}

func hasOpenedWindows(_ app: NSRunningApplication) -> Bool {
    let appElement = AXUIElementCreateApplication(app.processIdentifier)
    var windowsList: CFTypeRef?
    
    let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsList)
    if result == .success, let windowsList = windowsList as? [AXUIElement], !windowsList.isEmpty {
        return true
    } else {
        return false
    }
}

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

func openWindowByNSWorkspace(_ url: URL){
    let openConfig = openConfig()
    NSWorkspace.shared.openApplication(at: url, configuration: openConfig)
}
