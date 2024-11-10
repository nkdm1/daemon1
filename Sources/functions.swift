import AppKit

class OpenConfig: NSWorkspace.OpenConfiguration{
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

struct FrontmostApplication {
    let NSRunningApplicationElement: NSRunningApplication!
    let AXUIElement: AXUIElement
    
    init() {
        self.NSRunningApplicationElement = NSWorkspace.shared.frontmostApplication
        self.AXUIElement = AXUIElementCreateApplication(NSRunningApplicationElement.processIdentifier)
    }
    
    func hasOpenedWindows() -> Bool {
        var windowsList: CFTypeRef?
        
        let result = AXUIElementCopyAttributeValue(AXUIElement, kAXWindowsAttribute as CFString, &windowsList)
        if result == .success, let windowsList = windowsList as? [AXUIElement], !windowsList.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    func hasAllWindowsMiniaturized() -> Bool {
        var windowsList: CFTypeRef?
        var minimizedCount: Int = 0
        
        let result = AXUIElementCopyAttributeValue(AXUIElement, kAXWindowsAttribute as CFString, &windowsList)
        if result == .success, let windowsList = windowsList as? [AXUIElement], !windowsList.isEmpty {
            for window in windowsList {
                var isMinimized: CFTypeRef?
                let minimizedResult = AXUIElementCopyAttributeValue(window, kAXMinimizedAttribute as CFString, &isMinimized)
                    
                if minimizedResult == .success, let isMinimized = isMinimized, CFBooleanGetValue((isMinimized as! CFBoolean)) {
                        minimizedCount += 1
                    }
                }
        }
        if let windowsList, minimizedCount == windowsList.count {
            return true
        }
        return false
    }
    
    func unminiaturizeAllMiniaturizedWindows() {
        var windowsList: CFTypeRef?
        
        let result = AXUIElementCopyAttributeValue(AXUIElement, kAXWindowsAttribute as CFString, &windowsList)
        if result == .success, let windowsList = windowsList as? [AXUIElement], !windowsList.isEmpty {
            for window in windowsList {
                var isMinimized: CFTypeRef?
                let minimizedResult = AXUIElementCopyAttributeValue(window, kAXMinimizedAttribute as CFString, &isMinimized)
                    
                if minimizedResult == .success, let isMinimized = isMinimized, CFBooleanGetValue((isMinimized as! CFBoolean)) {
                    let unminiaturizeResult = AXUIElementSetAttributeValue(window, kAXMinimizedAttribute as CFString, kCFBooleanFalse)
                    if unminiaturizeResult != .success {
                        print("Failed to unminiaturize window \(window)")
                    }
                }
            }
        }
    }
    
}

func setupApplicationObserver() {
    NSWorkspace.shared.notificationCenter.addObserver(
        forName: NSWorkspace.didActivateApplicationNotification,
        object: nil,
        queue: .main
    )
    { notification in
        let frontmostApplication = FrontmostApplication()
        if !frontmostApplication.hasOpenedWindows() {
            openApplicationByNSWorkspace(frontmostApplication.NSRunningApplicationElement.bundleURL!)
            print("Opened window for \(frontmostApplication.NSRunningApplicationElement.localizedName!).")
        } else if frontmostApplication.hasAllWindowsMiniaturized(){
            frontmostApplication.unminiaturizeAllMiniaturizedWindows()
            print("Unminiaturized window for \(frontmostApplication.NSRunningApplicationElement.localizedName!).")
        } else {
            print("\(frontmostApplication.NSRunningApplicationElement.localizedName!) has open windows.")
        }
    }
}



func openApplicationByNSWorkspace(_ url: URL){
    let OpenConfig = OpenConfig()
    NSWorkspace.shared.openApplication(at: url, configuration: OpenConfig)
}






