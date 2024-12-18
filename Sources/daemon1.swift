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
        
        // dodac observer command+w
        // i przy zamknieciu okna sprawdzac czy command+w nie zostalo klikniete w przeciagu idk 0.5s
        // jesli nie, to dopiero po dispatchqueue.delay, 0.5s - 1s sprawdzac czy okna istnieja
        
        
    }
}
