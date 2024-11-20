import AppKit
import AXSwift
import Swindler


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
        let ignoredApplications: [String] = ["Stats"]
        
        
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
                    print("app still have existing windows")
                }
            }
        }
        swindler.on { (event: ApplicationMainWindowChangedEvent) in
            // app main window changed logic
        }
        swindler.on { (event: FrontmostApplicationChangedEvent) in
            let newFrontmostApp = String(event.newValue?.bundleIdentifier?.split(separator: ".").last ?? "unknown")
            let oldFrontmostapp = String(event.oldValue?.bundleIdentifier?.split(separator: ".").last ?? "unknown")
            
            guard !ignoredApplications.contains(newFrontmostApp) && !ignoredApplications.contains(oldFrontmostapp) else {
                return
            }
            print("new frontmost app: \(newFrontmostApp).",
                  "[old: \(event.oldValue?.bundleIdentifier?.split(separator: ".").last ?? "unknown")]")
            
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
        if windows?.count == 0{
            if let URL = NSWorkspace.shared.frontmostApplication?.bundleURL {
                NSWorkspace.shared.openApplication(at: URL, configuration: OpenConfig())
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

func openApplicationByNSWorkspace(_ url: URL){
    let OpenConfig = OpenConfig()
    NSWorkspace.shared.openApplication(at: url, configuration: OpenConfig)
}

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






