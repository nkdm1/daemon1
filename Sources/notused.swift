import AppKit

func openWindowByAS(_ appName: String) {
    let script = """
        tell application "\(appName)"
            activate
            try
                tell application "\(appName)" to open
            on error
                try
                    tell application "\(appName)" to make new window
                end try
            end try
        end tell
        """

    if let appleScript = NSAppleScript(source: script) {
        var error: NSDictionary?
        appleScript.executeAndReturnError(&error)
        
        if let error = error {
            print("AppleScript error: \(error)")
        } else {
            print("Opened a new window in \(appName).")
        }
    }
}

