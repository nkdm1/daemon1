import AppKit
import Swindler

@main
struct daemon1 {
    static func main() {
        let applicationDelegate = AppDelegate()
        let application = NSApplication.shared
        applicationDelegate.VC.viewDidLoad()
        application.setActivationPolicy(NSApplication.ActivationPolicy.accessory)
        application.delegate = applicationDelegate
        application.run()
        
        
    }
}
