import AppKit
import AXSwift
import Swindler
import Quartz
import Cocoa

 

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    let VC = ViewController()
    var swindler: Swindler.State!
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard AXSwift.checkIsProcessTrusted(prompt: true) else {
            print("Not trusted as an AX process; please authorize and re-launch")
            sleep(10)
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
        let ignoredApplicationsList = self.setupIgnoredApplications()
        let delayedApplicationsList = self.setupDelayedApplications()
        
        swindler.on { (event: WindowDestroyedEvent) in
            guard !ignoredApplicationsList.contains(event.window.application.bundleIdentifier?.split(separator: ".").last?.lowercased() ?? "unknown") && self.swindler.runningApplications.contains(event.window.application) else {
                return
            }
//            guard event.window.application.bundleIdentifier == self.swindler.frontmostApplication.value?.bundleIdentifier && NSWorkspace.shared.menuBarOwningApplication?.bundleIdentifier == event.window.application.bundleIdentifier else {
//                return
//            }
            let lastCommandWTimestamp = self.VC.lastCommandWTimestamp
            let finder = self.swindler.runningApplications.first(where: {$0.bundleIdentifier?.split(separator: ".").last?.lowercased() ?? "unknown" == "finder"})
            let allApplications = self.swindler.runningApplications
            var minimizedApplicationWindowsCount = 0
            var visibleOtherWindowsCount = 0
            print("window destroyed: \(event.window.title.value)")
            
            for app in allApplications {
                if app == event.window.application {
                    for window in app.knownWindows{
                        if window.isMinimized.value {
                            minimizedApplicationWindowsCount += 1
                        }
                    }
                }
                else {
                    for window in app.knownWindows{
                        if !window.isMinimized.value && !app.isHidden.value{
                            visibleOtherWindowsCount += 1
                        }
                    }
                }
            }
            
            if Date().timeIntervalSinceReferenceDate - lastCommandWTimestamp > 0.1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)){
                    if minimizedApplicationWindowsCount == event.window.application.knownWindows.count {
                        if visibleOtherWindowsCount != 0 {
                            print("last window closed")
                            event.window.application.isHidden.value = true
                        }
                        else {
                            print("app still have existing windows or it was the last visible window")
                            if let finder {
                                self.swindler.frontmostApplication.value = finder
                            }
                        }
                    }
                }
            }
            else {
                if minimizedApplicationWindowsCount == event.window.application.knownWindows.count {
                    if visibleOtherWindowsCount != 0 {
                        print("last window closed")
                        event.window.application.isHidden.value = true
                    }
                    else {
                        print("app still have existing windows or it was the last visible window")
                        if let finder {
                            self.swindler.frontmostApplication.value = finder
                        }
                    }
                }
            }
            
        }
        
        swindler.on { (event: FrontmostApplicationChangedEvent) in
            let finder = self.getFinder()
            let newFrontmostApp = String(event.newValue?.bundleIdentifier?.split(separator: ".").last?.lowercased() ?? "unknown")
            let oldFrontmostApp = String(event.oldValue?.bundleIdentifier?.split(separator: ".").last?.lowercased() ?? "unknown")
            
            guard !ignoredApplicationsList.contains(newFrontmostApp) && !ignoredApplicationsList.contains(oldFrontmostApp) else {
                return
            }
            
            guard event.newValue?.bundleIdentifier == self.swindler.frontmostApplication.value?.bundleIdentifier && NSWorkspace.shared.menuBarOwningApplication?.bundleIdentifier == event.newValue?.bundleIdentifier && event.external == true else {
                return
            }
            if event.newValue == finder {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(25)){
                    let noWindowsVisible: Bool = self.noWindowsAreVisible()
                    if noWindowsVisible{
                        return
                    }
                    print("new frontmost app: \(newFrontmostApp).",
                          "[old: \(oldFrontmostApp)]")
                    
                    self.frontmostApplicationChanged()
                }
            }
            else {
                print("new frontmost app: \(newFrontmostApp).",
                      "[old: \(oldFrontmostApp)]")
                
                self.frontmostApplicationChanged()
            }
            
            
            
            
        }
        
        swindler.on { (event: WindowMinimizedChangedEvent) in
            guard !ignoredApplicationsList.contains(event.window.application.bundleIdentifier?.split(separator: ".").last?.lowercased() ?? "unknown")
             && event.newValue.description.contains("true")
            else {
                return
            }
            
            let finder = self.getFinder()
            let allApplications = self.swindler.runningApplications
            var minimizedApplicationWindowsCount = 0
            var visibleOtherWindowsCount = 0
            print("window (un)minimized: \(event.window.title.value)")
            
            
            for app in allApplications {
                if app == event.window.application {
                    for window in app.knownWindows{
                        if window.isMinimized.value {
                            minimizedApplicationWindowsCount += 1
                        }
                    }
                }
                else {
                    for window in app.knownWindows{
                        if !window.isMinimized.value && !app.isHidden.value {
                            visibleOtherWindowsCount += 1
                        }
                    }
                }
            }
            
            if minimizedApplicationWindowsCount == event.window.application.knownWindows.count {
                if visibleOtherWindowsCount != 0 {
                    print("last window minimized")
                    event.window.application.isHidden.value = true
                }
                else {
                    print("app still have existing windows or it was the last visible window")
                    // switch to finder without opening the window
                    if let finder {
                        self.swindler.frontmostApplication.value = finder
                    }
                }
            }
        }
        
//        swindler.on {(event: ApplicationIsHiddenChangedEvent) in // it sometimes does sometimes doesn't bring finder window to front i dont know why
//            let finder = self.getFinder()
//            guard event.external == true && self.swindler.frontmostApplication.value != finder ?? .none && event.newValue.description.contains("true") else {
//                return
//            }
//            
//            var noWindowVisible = true
//            print(event.newValue.description)
//            for app in self.swindler.runningApplications {
//                var shouldBrake = false
//                for window in app.knownWindows {
//                    if !window.isMinimized.value || !app.isHidden.value {
//                        noWindowVisible = false
//                        shouldBrake = true
//                        break
//                    }
//                }
//                if shouldBrake {
//                    break
//                }
//            }
//            if noWindowVisible {
//                if let finder {
//                    self.swindler.frontmostApplication.value = finder
//                }
//            }
//        }
//        swindler.on { (event: ApplicationTerminatedEvent) in
//            guard !ignoredApplicationsList.contains(event.application.bundleIdentifier?.split(separator: ".").last?.lowercased() ?? "unknown")
//            else {return}
//            
//            let finder = self.getFinder()
//            var noWindowVisible = true
//            for app in self.swindler.runningApplications {
//                var shouldBrake = false
//                for window in app.knownWindows {
//                    if !window.isMinimized.value || !app.isHidden.value {
//                        noWindowVisible = false
//                        shouldBrake = true
//                        break
//                    }
//                }
//                if shouldBrake {
//                    break
//                }
//            }
//            if noWindowVisible {
//                if let finder {
//                    self.swindler.frontmostApplication.value = finder
//                }
//            }
//            
//        }
            
                
            
        
        
        /*
        swindler.on { (event: WindowCreatedEvent) in
            event.window.application.isHidden.value = false
        }
        */
//        swindler.on { (event: ApplicationMainWindowChangedEvent) in
//            self.swindler.frontmostApplication.value = event.application
//            event.application.isHidden.value = false
//        }
        /*
        swindler.on { (event: WindowFrameChangedEvent) in
           // window movement logic
        }
        */
    }
    
    
    private func noWindowsAreVisible() -> Bool {
        let finder = getFinder()
        var noWindowVisible = true
        for app in self.swindler.runningApplications {
            
            if app.isHidden.value {
                continue
            }
            var shouldBrake = false
            for window in app.knownWindows {
                if !window.isMinimized.value {
                    noWindowVisible = false
                    shouldBrake = true
                    break
                }
            }
            if shouldBrake {
                break
            }
        }
        return noWindowVisible
    }
    
    private func setupIgnoredApplications() -> [String] {
        var ignoredApplicationsList: [String] = ["loginwindow"]
        
        if !FileManager.default.fileExists(atPath: NSHomeDirectory() + "/Library/daemon1") {
            try? FileManager.default.createDirectory(atPath: NSHomeDirectory() + "/Library/daemon1", withIntermediateDirectories: true)
        }
        
        let ignoredApplicationsFilePath = NSHomeDirectory() + "/Library/daemon1/ignoredapplications.txt"
        
        if FileManager.default.fileExists(atPath: ignoredApplicationsFilePath) {
            let readApplications = try? String(contentsOfFile: ignoredApplicationsFilePath).split(separator: "\n")
            for application in readApplications ?? [] {
                ignoredApplicationsList.append(String(application).lowercased())
            }
        }
        
        return ignoredApplicationsList  
    }
    private func setupDelayedApplications() -> [String] {
        var ignoredApplicationsList: [String] = ["stats","textedit","preview","word","excel","powerpoint"]
        
        if !FileManager.default.fileExists(atPath: NSHomeDirectory() + "/Library/daemon1") {
            try? FileManager.default.createDirectory(atPath: NSHomeDirectory() + "/Library/daemon1", withIntermediateDirectories: true)
        }
        
        let delayed = NSHomeDirectory() + "/Library/daemon1/delayed.txt"
        
        if FileManager.default.fileExists(atPath: delayed) {
            let readApplications = try? String(contentsOfFile: delayed).split(separator: "\n")
            for application in readApplications ?? [] {
                ignoredApplicationsList.append(String(application).lowercased())
            }
        }
        
        return ignoredApplicationsList
    }
    private func hideApplication(_ app: Swindler.Application)
    {
        app.isHidden.value = true
    }
    
    func getFinder() -> Swindler.Application?{
        return swindler.runningApplications.first(where: {$0.bundleIdentifier?.split(separator: ".").last?.lowercased() ?? "unknown" == "finder"})
    }
    
    private func frontmostApplicationChanged() {
        let windows: [Window]? = swindler.frontmostApplication.value?.knownWindows
        if windows?.count == 0 {
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

@MainActor
class ViewController: NSViewController {
    public var lastCommandWTimestamp: Double = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        NSEvent.addGlobalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { (event) in
            if event.keyCode == 13 && event.modifierFlags.intersection(.deviceIndependentFlagsMask) == [.command] {
                print("kurwa działa", Date().timeIntervalSinceReferenceDate)
                self.lastCommandWTimestamp = Date().timeIntervalSinceReferenceDate
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







