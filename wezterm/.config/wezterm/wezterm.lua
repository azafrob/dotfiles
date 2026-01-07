-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.
config.window_background_opacity = 0.9
config.hide_tab_bar_if_only_one_tab = true

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28

-- or, changing the font size and color scheme.
config.font_size = 10
config.color_scheme = "Noctalia"

-- Read mono font from noctalia config
local mono_font = "JetBrains Mono"
local noctalia_config = os.getenv("HOME") .. "/.config/noctalia/settings.json"
local f = io.open(noctalia_config, "r")
if f then
	local content = f:read("*a")
	f:close()
	local ok, json = pcall(wezterm.json_parse, content)
	if ok and json.ui and json.ui.fontFixed then
		mono_font = json.ui.fontFixed
	end
end

config.font = wezterm.font(mono_font)
config.term = "wezterm"

-- Finally, return the configuration to wezterm:
return config
