import AppKit
import Swindler
import ApplicationServices
import Cocoa
@main
struct daemon1 {
    static func main() {
        print("Starting daemon1...")
        let applicationDelegate = AppDelegate()
        let application = NSApplication.shared
        application.setActivationPolicy(NSApplication.ActivationPolicy.accessory)
        application.delegate = applicationDelegate
        // watchForApplicationActivation()
        application.run()
        
    }
}
