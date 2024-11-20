local wezterm = require("wezterm")

local config = wezterm.config_builder()

config = {
	automatically_reload_config = true,
	enable_tab_bar = false,
	window_close_confirmation = "NeverPrompt",
	window_decorations = "RESIZE",
	default_cursor_style = "BlinkingBar",
	color_scheme = "Gruvbox dark, hard (base16)",
	font = wezterm.font("FiraCode Nerd Font", {
		weight = "Regular",
		stretch = "Normal",
		style = "Normal",
	}),
	font_size = 12.5,
	window_background_opacity = 0.90,

	keys = {
		{
			key = "<",
			mods = "SUPER",
    		action = wezterm.action{SplitVertical={domain="CurrentPaneDomain"}}
		},
		{
			key = "|",
			mods = "SUPER",
    		action = wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}}
		}
	},
	mouse_bindings = {
		{
			event = { Drag = { streak = 1, button = "Left" } },
			mods = "CTRL|SHIFT",
			action = wezterm.action.StartWindowDrag,
		},
	},
	wsl_domains = {
		{
			name = "WSL:Ubuntu",
			distribution = "Ubuntu",
			username = "tobsve",
			default_cwd = "/home/tobsve/",
		},
	},
	default_domain = "WSL:Ubuntu"
}

return config
