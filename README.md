# daemon1
-   changes behaviour of hold_cmd+tab to hold_cmd+tab+hold_opt-cmd which
	opens new window if swithed-to application doesn't have
	any windows opened (ignores unminimizing rules)
-   unminiaturizes last minimized window if every window of switched-to
	application is minimized
-   performs hold_cmd+tab if the last window of application has been closed


# known problems 
-   when an apppication has some windows minimized and you close the last not-minimized window (which triggers app-switch), switch back to that 
    application unminiaturizes the oldest window, not the last minimized.
    i made it unminiaturize all windows, instead of the oldest, until i fix it.


