# daemon1
- changes behaviour of hold_cmd+tab to hold_cmd+tab+hold_opt-cmd which
	opens new window if swithed-to application doesn't have
	any windows opened (ignores unminimizing rules)
- unminimize last minimized window if every window of switched-to
	application is minimized
- performs hold_cmd+tab if the last window of application has been closed
