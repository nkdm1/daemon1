# daemon1 - addition to macos window management

## description
daemon1 is simple background process that changes the default behaviour of macos windows management and makes it a little more intuitive (imo)

## features
-   switching between applications in macos with command+tab doesn't open a new window if none are opened, which i find really annoying 
    daemon1 automatically opens a new window if switched-to application has zero windows, making you forget about command+tab+option-command shortcut
-   i've never minimized my windows because it's a struggle to unminimize them back
    now, if switched-to application has all minimized windows, daemon1 unminimizes the last minimized one
-   in macos, closing the last window of an application doesn't quit it, which in my opinion makes sense, especially when you know how macos manages energy and memory
    the one think i don't understand is why closing/minimizing the last window of an application doesn't hide it
    fortunately, we don't have to, because daemon1 hides an application when we close/minimize it's last window

## installation
-   by compiling the code and adding .plist file to your ~/Library/LaunchAgents/ directory,
    make sure to update .plist programarguments with correct path to compiled program
-   by homebrew (tba)

## usage
daemon1 is working as a background process called "agent", which is automatically
    launched when you log in to your account
    after installation you don't have to do anything, it just works
    if you don't want to use daemon1 anymore just delete .plist file from your ~/Library/LaunchAgents/ directory and then remove files you downloaded from this website
    
## contribution 
pull requests are more than welcome, for major changes, please open an issue first to discuss what you would like to change

## known problems 
-   when an apppication has some windows minimized and you close the last not-minimized window (which triggers app-switch), switching back to that 
    application unminiaturizes the oldest window, not the last minimized
    i made it unminiaturize all windows, instead of the oldest, until i fix it


