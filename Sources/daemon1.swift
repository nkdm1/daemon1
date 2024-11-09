import AppKit

@main
struct daemon1 {
    static func main() {
        print("Starting daemon1...")
        setupApplicationObserver()
        print("AXIsProcessTrusted: \(AXIsProcessTrusted())")
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            
        }
        
        RunLoop.main.run()
    }
}
