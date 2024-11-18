# daemon1
-   changes behaviour of hold_cmd+tab to hold_cmd+tab+hold_opt-cmd which
	opens new window if swithed-to application doesn't have
	any windows opened (ignores unminimizing rules)
-   unminiaturizes last minimized window if every window of switched-to
	application is minimized
-   performs hold_cmd+tab if the last window of application has been closed


# known problems
-   switching to finder always displays "finder has open windows" for some reason 
-   when unminiaturizing safari window, which has more than 1 tab open,
    the hold_cmd+tab bar is not properly disappearing,
    which creates illusion of lag (prolly macOS issue, because the same happens when 
    unminiaturizing with hold_cmd+tab+hold_opt-cmd)

