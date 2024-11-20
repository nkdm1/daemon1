# daemon1
daemon1 is simple background process that changes the default behaviour of macos windows management and makes it a little more intuitive (imo)

## features
*  daemon1 automatically opens a new window if switched-to application has zero windows, making you forget about command+tab+option-command shortcut
*  if switched-to application has all minimized windows, daemon1 unminimizes the last minimized one

* closing/minimizing the last window of an application hides it (performs command+tab)

## installation

daemon1 is compatible with apple m-series chips on macos 10.15 or higher

1. download daemon1 executable and .plist file [here](https://github.com/nkdm1/daemon1/releases/tag/v0.1)
2. move daemon1 to "/Applications" directory
3. open terminal and type `cd /Applications` and then `chmod 755 "daemon1"`
4. paste `/Applications/daemon1` into .plist file under "ProgramArguments" -> "Item 0"
5. move .plist to "~/Library/LaunchAgents"
6. open terminal and type `launchctl load ~/Library/LaunchAgents/daemon1.plist`
7. ignore prompt "daemon1 not opened", don't close it
8. go to system settings -> privacy&security -> scroll down and click "open/allow anyway" 
9. click "open" when prompted (again) that the application couldn't be verified 
10. you will be prompted to grant accessibility privilege, grant them in system settings -> privacy&security -> accessibility
11. there is a possibility that you will get "There is no application set to open the document 'coreautha.bundle'." error. ignore it :)

`brew install daemon1` - hopefully coming soon 

### troubleshooting
open your activity monitor, go to memory tab and type "daemon1" in right upper corner
 
if you see daemon1 but it doesn't work, you are doomed :0 (check for a typo in .plist)

if you don't see daemon1:

###### check for daemon1 in activity monitor after completing every step, you likely won't have to  go through all of them

1. type `launchctl start nkdm1.daemon1` to the terminal
2. restart your computer
3. unload with `launchctl unload ~/Library/LaunchAgents` and load it back with `launchctl load ~/Library/LaunchAgents`
4. change your daemon1 executable directory, update your .plist, unload with `launchctl unload ~/Library/LaunchAgents` and load back with `launchctl load ~/Library/LaunchAgents`, then start with `launchctl start nkdm1.daemon1`
5. if nothing works, please make a new [issue](https://github.com/nkdm1/daemon1/issues)


## usage
daemon1 is working as a background process called "agent", which is automatically
    launched when you log in to your account

it incoureges you to think a little diffrent when managing your windows

first of all, it is mainly written to meet my own requirements, which are:

1. speed up command+tab application switching
2. make command+w and command+m less irritating to use
3. forget about command+h and command+tab+option-command
4. make not quitting all of your application a good habit

having mail, notes, safari, terminal and spotify opened in the background is important to me, because i use them all the time

i don't want to launch them everytime i want to use them again, that's why i don't quit them

i'm a fan of "i'm done" kind of thinking - i use the application untill my mind is hit with "ok, i'm done", then i close it

i want the application to be at default state the next time i switch to it, not the state i stopped using it

that's where command+h fails to do it's job - it is good when you want the app to only temporarily hide and you will be switching back to it soon, with a purpose to continue your work - which is exactly what command+tab does :)

closing the last window of application and then hiding it/switching to other application is what you want to do when you are done with application, but at this point you have to use two shortcuts to perform one activity and you are met with another problem - switching back to that application doesn't automatically open a default window

  





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
