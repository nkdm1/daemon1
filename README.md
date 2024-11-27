# daemon1
daemon1 is a background process that changes the default behaviour of macos windows management and makes it a little more intuitive (imo)

## main features
* automatically opens a new window if switched-to application has zero windows, no need for command+tab+option-command shortcut
* if switched-to application has all minimized windows, daemon1 unminimizes the last minimized one
* closing/minimizing the last window of an application hides it (performs command+tab)

## installation

daemon1 is compatible with apple m-series chips on macos 10.15 or higher

1. download daemon1 executable and .plist file [here](https://github.com/nkdm1/daemon1/releases/tag/v0.2.0)
2. move daemon1 executable to "/Applications" directory
3. open terminal and paste `cd /Applications; chmod 755 "daemon1"`
4. move .plist to "~/Library/LaunchAgents"
5. paste `launchctl load ~/Library/LaunchAgents/daemon1.plist` into terminal
6. ignore prompt "daemon1 not opened", don't close it
7. go to system settings -> privacy&security -> scroll down and click "open/allow anyway" 
8. click "open" when prompted (again) that the application couldn't be verified 
9. you will be prompted to grant accessibility privilege, grant them in system settings -> privacy&security -> accessibility
10. there is a possibility that you will get "There is no application set to open the document 'coreautha.bundle'." error -> ignore it 

`brew install daemon1` - hopefully coming soon 

## additional features
* if you want daemon1 to ignore some applications, `touch ignoredapplications.txt` and move it under "~/Library/daemon1", type names of applications each in new line:
```
stats
systempreferences
terminal
```

### troubleshooting
open your activity monitor, go to memory tab and type "daemon1" in the right upper corner
 
if you see daemon1 but it doesn't work, you are doomed (uninstall and install again)

if you don't see daemon1:

###### check for daemon1 in activity monitor after completing every step, you likely won't have to  go through all of them

1. type `launchctl start nkdm1.daemon1` in the terminal
2. restart your computer
3. unload with `launchctl unload ~/Library/LaunchAgents/daemon1.plist` and load it back with `launchctl load ~/Library/LaunchAgents/daemon1.plist`
4. change your daemon1 executable directory, update your .plist, unload with `launchctl unload ~/Library/LaunchAgents/daemon1.plist` and load back with `launchctl load ~/Library/LaunchAgents/daemon1.plist`, then start with `launchctl start nkdm1.daemon1`
5. if nothing works, please make a new [issue](https://github.com/nkdm1/daemon1/issues)

## uninstallation
1. paste this into the terminal:
```bash
launchctl unload ~/Library/LaunchAgents/daemon1.plist
rm ~/Library/LaunchAgents/daemon1.plist
rm /Applications/daemon1
```
2. remove daemon1 from system settings -> privacy&security -> accessibility
## usage
daemon1 is working as a background process called "agent", which is automatically
    launched when you log in to your account

## why was daemon1 written?
daemon1 encourages you to think a little differently when managing your windows

first of all, it is mainly written to meet my own requirements, which are:

1. speed up command+tab application switching
2. make command+w and command+m less irritating to use
3. forget about command+h and command+tab+option-command
4. make not quitting all of your applications a good habit

for those interested in the thinking method that guides me through this project::

- there are some applications that i don't want to quit, because they're used often [mail for example]
- when i'm done with that application i close its windows, not the whole application
- i want the application to be in the default state the next time i switch to it, not the state i stopped using it
- that’s where command+h fails to do its job - it is good when you want the app to only temporarily hide and you will be switching back to it soon, with a purpose to continue your work - which is exactly what command+tab does
- closing the last window of an application and then hiding it/switching to another application is what you want to do when you are done with the application, but at this point you have to use two shortcuts to perform one activity and you are met with another problem - switching back to that application doesn't automatically open a default window

this project has been started to address this issues and hopefully make your macos life easier

## contribution 
any type of pull requests are more than welcome

## known problems 
1. when an apppication has some windows minimized and you close the last not-minimized window (which triggers app-switch), switching back to that 
    application unminiaturizes the oldest window, not the last minimized one. i made it unminiaturize all windows, instead of the oldest, until i fix 
2. from time to time hiding the last application does bring the finder window to the front for some reason

## license
this project is under [gnu gplv3](https://www.gnu.org/licenses/gpl-3.0.en.html#license-text) license

## credits
big thanks to every contributor of [swindler](https://github.com/tmandry/Swindler), this project was fucking annoying to write until i found your work guys
