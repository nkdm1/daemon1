import AppKit
import AXSwift
import Swindler
import ApplicationServices
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var swindler: Swindler.State!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard AXSwift.checkIsProcessTrusted(prompt: true) else {
            print("Not trusted as an AX process; please authorize and re-launch")
            NSApp.terminate(self)
            return
        }
        
        Swindler.initialize().done { state in
            self.swindler = state
            self.setupEventHandlers()
        }.catch { error in
            print("Fatal error: failed to initialize Swindler: \(error)")
            NSApp.terminate(self)
        }
    }
    
    private func setupEventHandlers() {
        
        swindler.on { (event: WindowCreatedEvent) in
            //window creation logic
        }
        swindler.on { (event: WindowFrameChangedEvent) in
           // window movement logic
        }
        swindler.on { (event: WindowDestroyedEvent) in
            if event.window.application.bundleIdentifier == self.swindler.frontmostApplication.value?.bundleIdentifier {
                print("window destroyed: \(event.window.title.value)")
                let windows = self.swindler.frontmostApplication.value?.knownWindows
                var minimizedWindowsCount = 0
                for window in windows ?? [] {
                    if window.isMinimized.value {
                        minimizedWindowsCount += 1
                    }
                }
                if minimizedWindowsCount == windows?.count {
                    print("last window closed")
                    event.window.application.isHidden.value = true
                } else{
                    print("unable to count windows, line 39")
                }
            }
        }
        swindler.on { (event: ApplicationMainWindowChangedEvent) in
            // app main window changed logic
        }
        swindler.on { (event: FrontmostApplicationChangedEvent) in
            print("new frontmost app: \(event.newValue?.bundleIdentifier ?? "unknown").",
                  "[old: \(event.oldValue?.bundleIdentifier ?? "unknown")]")
            self.frontmostApplicationChanged()
        }
        swindler.on { (event: WindowMinimizedChangedEvent) in
            print("window (un)minimized: \(event.window.title.value)")
            var minimizedWindowsCount = 0
            let windows: [Window]? = self.swindler.frontmostApplication.value?.knownWindows
            for window in windows ?? [] {
                if window.isMinimized.value {
                    minimizedWindowsCount += 1
                }
            }
            if windows?.count == minimizedWindowsCount {
                self.swindler.frontmostApplication.value?.isHidden.value = true
            }
        }
    }
    
    private func frontmostApplicationChanged() {
        let windows: [Window]? = swindler.frontmostApplication.value?.knownWindows
        if windows?.count == 0 {
            if let URL = NSWorkspace.shared.frontmostApplication?.bundleURL {
                NSWorkspace.shared.openApplication(at: URL, configuration: OpenConfigActivation())
            }
        } else {
            var allMinimized = true
            if let windows = windows {
                for window in windows {
                    if window.isMinimized.value == false {
                        allMinimized = false
                        break
                    }
                }
            }
            else{
                print("Error: not able to get windows array")
            }
            
            if allMinimized{
                if swindler.frontmostApplication.value?.mainWindow.value?.isValid == true {
                    swindler.frontmostApplication.value?.mainWindow.value?.isMinimized.value = false
                }
                else { // unminizes all of windows if mainWindow is invalid
                    
                    swindler.frontmostApplication.value?.knownWindows.forEach { $0.isMinimized.value = false }
                }
            }
        }
    }
}

    


struct FrontmostApplication{
    let NSRunningApplicationElement: NSRunningApplication!
    let AXUIElement: AXUIElement
    var windowsList: CFTypeRef?
    var resultOfAXUIEleementCopyAttributeValue: AXError
    
    init() {
        self.NSRunningApplicationElement = NSWorkspace.shared.frontmostApplication
        self.AXUIElement = AXUIElementCreateApplication(NSRunningApplicationElement.processIdentifier)
        self.resultOfAXUIEleementCopyAttributeValue = AXUIElementCopyAttributeValue(AXUIElement, kAXWindowsAttribute as CFString, &windowsList)
    }
    
    func hasOpenedWindows() -> Bool {
        if resultOfAXUIEleementCopyAttributeValue == .success, let windowsList = windowsList as? [AXUIElement], !windowsList.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    func hasAllWindowsMiniaturized() -> Bool {
        var minimizedCount: Int = 0
        
        if resultOfAXUIEleementCopyAttributeValue == .success, let windowsList = windowsList as? [AXUIElement], !windowsList.isEmpty {
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
    
    func countOpenedWindows() -> Int {
        if let windowsList = windowsList as? [AXUIElement], !windowsList.isEmpty {
            return windowsList.count
        }
        return 0
    }
}

func watchForApplicationActivation() {
    NSWorkspace.shared.notificationCenter.addObserver(
        forName: NSWorkspace.didActivateApplicationNotification,
        object: nil,
        queue: .main
    )
    { notification in
        let frontmostApplication = FrontmostApplication()
        print(frontmostApplication.countOpenedWindows())
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
    let OpenConfig = OpenConfigActivation()
    NSWorkspace.shared.openApplication(at: url, configuration: OpenConfig)
}

class OpenConfigActivation: NSWorkspace.OpenConfiguration{
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
class OpenConfigNoneActivation: NSWorkspace.OpenConfiguration{
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





