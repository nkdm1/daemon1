# daemon1 - addition to macos window management
daemon1 is simple background process that changes the default behaviour of macos windows management and makes it a little more intuitive (imo)

## features
*   switching between applications in macos with command+tab doesn't open a new window if none are opened, which i find really annoying
 
    daemon1 automatically opens a new window if switched-to application has zero windows, making you forget about command+tab+option-command shortcut
*   i've never minimized my windows because it's a struggle to unminimize them back

    now, if switched-to application has all minimized windows, daemon1 unminimizes the last minimized one
*   in macos, closing the last window of an application doesn't quit it, which in my opinion makes sense, especially when you know how macos manages energy and memory

    the one think i don't understand is why closing/minimizing the last window of an application doesn't hide it 

    fortunately, we don't have to, because daemon1 hides an application when we close/minimize it's last window

## installation

daemon1 is compatible with macos 10.15 and newer

1.  download daemon1 executable and .plist file [here](https://github.com/nkdm1/daemon1/releases/tag/v0.1)
2. move daemon1 to your desired directory, like "/Applications" or "~/Library/"
3. copy the daemon1 path and paste it into .plist file under "ProgramArguments" -> "Item 0"
4. move .plist to "~/Library/LaunchAgents"
5. open terminal and type `launchctl load ~/Library/LaunchAgents`

`brew install daemon1` - hopefully coming soon 

### troubleshooting
open your activity monitor, go to memory tab and type "daemon1" in right upper corner
 
if you see daemon1 but it doesn't work, you are doomed :0 (check for a typo in .plist)

if you don't see daemon1:

###### check for daemon1 in activity monitor after completing every step, you likely won't have to  go through all of them

1. type `launchctl start nkdm1.daemon1` to the terminal
2. restart your computer
3.  unload with `launchctl unload ~/Library/LaunchAgents` and load it back with `launchctl load ~/Library/LaunchAgents`
4. change your daemon1 executable directory, update your .plist, unload with `launchctl unload ~/Library/LaunchAgents` and load back with `launchctl load ~/Library/LaunchAgents`, then start with `launchctl start nkdm1.daemon1`
5. if nothing works, please make a new [issue](https://github.com/nkdm1/daemon1/issues)


## usage
daemon1 is working as a background process called "agent", which is automatically
    launched when you log in to your account

   after installation you don't have to do anything, it just works

if you don't want to use daemon1 anymore: 
1. delete .plist file from your ~/Library/LaunchAgents/ directory
2. type `launchctl unload ~/Library/LaunchAgents` into the terminal
3. remove daemon1 executable from your chosen directory 
    
## contribution 
pull requests are more than welcome

for major changes, please open an [issue](https://github.com/nkdm1/daemon1/issues) first to discuss what you would like to change

## known problems 
when an apppication has some windows minimized and you close the last not-minimized window (which triggers app-switch), switching back to that 
    application unminiaturizes the oldest window, not the last minimized one

i made it unminiaturize all windows, instead of the oldest, until i fix 

## license
this project is under [gnu gplv3](https://www.gnu.org/licenses/gpl-3.0.en.html#license-text)  license

## credits
big thanks to every contributor of [swindler](https://github.com/tmandry/Swindler), this project was fucking annoying to write until i found your work guys
