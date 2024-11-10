import AppKit

class openConfig: NSWorkspace.OpenConfiguration{
    override init() {
        super.init()
        requiresUniversalLinks = false
        isForPrinting = false
        activates = true
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

func hasAllWindowsMiniaturized(_ app: NSRunningApplication) -> Bool {
    let appElement = AXUIElementCreateApplication(app.processIdentifier)
    var windowsList: CFTypeRef?
    var minimizedCount = 0
    var windowsCount = 0
    
    let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsList)
    if result == .success, let windowsList = windowsList as? [AXUIElement], !windowsList.isEmpty {
        windowsCount = windowsList.count
        for window in windowsList {
            var isMinimized: CFTypeRef?
            let minimizedResult = AXUIElementCopyAttributeValue(window, kAXMinimizedAttribute as CFString, &isMinimized)
                
            if minimizedResult == .success, let isMinimized = isMinimized, CFBooleanGetValue((isMinimized as! CFBoolean)) {
                    minimizedCount += 1
                }
            }
    }
    if minimizedCount == windowsCount {
        return true
    }
    return false
    
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
                openApplicationByNSWorkspace(bundleURL)
                print("Opened window for \(frontmostAppName).")
            } else if hasAllWindowsMiniaturized(frontmostApp){
                openApplicationByNSWorkspace(bundleURL)
                print("Unminiaturized window for \(frontmostAppName).")
            } else {
                print("\(frontmostAppName) has open windows.")
            }
        } else {
            print("No frontmost application found.")
        }
    }
}

func openApplicationByNSWorkspace(_ url: URL){
    let openConfig = openConfig()
    NSWorkspace.shared.openApplication(at: url, configuration: openConfig)
}

