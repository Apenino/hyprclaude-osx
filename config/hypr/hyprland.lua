-- ── Hyprland — rice sobre façon macOS ────────────────────────────
-- Config Lua (le format .conf est obsolète à partir de Hyprland 0.57)

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

local terminal = "kitty"
local menu     = "wofi --show drun"
local files    = "nautilus"
local drawer   = "nwg-drawer -term " .. terminal .. " -fm " .. files .. " -wm hyprland"
local mod      = "SUPER"

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("TERMINAL", "kitty")

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("nwg-dock-hyprland -r -i 44 -mb 8 -x -c '" .. drawer .. "'")
    hl.exec_cmd("wl-paste --watch cliphist store")
end)

hl.config({
    -- VM VMware : curseurs logiciels (sinon curseur invisible)
    cursor = {
        no_hardware_cursors = true,
    },

    general = {
        gaps_in          = 5,
        gaps_out         = 12,
        border_size      = 1,
        col = {
            active_border   = "rgba(ffffff40)",
            inactive_border = "rgba(ffffff15)",
        },
        layout           = "dwindle",
        resize_on_border = true,
    },

    decoration = {
        rounding         = 12,
        active_opacity   = 1.0,
        inactive_opacity = 0.97,
        shadow = {
            enabled      = true,
            range        = 30,
            render_power = 3,
            color        = "rgba(00000055)",
        },
        blur = {
            enabled  = true,
            size     = 8,
            passes   = 3,
            vibrancy = 0.2,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        force_default_wallpaper  = 0,
    },

    input = {
        kb_layout    = "fr",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.curve("mac", { type = "bezier", points = { {0.25, 1}, {0.5, 1} } })

hl.animation({ leaf = "windows",    enabled = true, speed = 5, bezier = "mac", style = "popin 85%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "mac", style = "popin 85%" })
hl.animation({ leaf = "fade",       enabled = true, speed = 4, bezier = "mac" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "mac", style = "slide" })
hl.animation({ leaf = "layers",     enabled = true, speed = 4, bezier = "mac", style = "fade" })

-- Flou derrière la barre, le dock, le tiroir d'apps, le lanceur et les notifs
hl.layer_rule({ name = "blur-waybar", match = { namespace = "waybar" },                blur = true, ignore_alpha = 0 })
hl.layer_rule({ name = "blur-wofi",   match = { namespace = "wofi" },                  blur = true })
hl.layer_rule({ name = "blur-swaync", match = { namespace = "swaync-control-center" }, blur = true })
hl.layer_rule({ name = "blur-dock",   match = { namespace = "nwg-dock" },              blur = true, ignore_alpha = 0 })
hl.layer_rule({ name = "blur-drawer", match = { namespace = "nwg-drawer" },            blur = true })

-- ── Raccourcis (inspirés de macOS : Super = ⌘) ───────────────────
hl.bind(mod .. " + RETURN",    hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + SPACE",     hl.dsp.exec_cmd(menu))
hl.bind(mod .. " + Q",         hl.dsp.window.close())
hl.bind(mod .. " + E",         hl.dsp.exec_cmd(files))
hl.bind(mod .. " + F",         hl.dsp.window.fullscreen())
hl.bind(mod .. " + V",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + L",         hl.dsp.exec_cmd("hyprlock"))
hl.bind(mod .. " + N",         hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mod .. " + SHIFT + M", hl.dsp.exit())
hl.bind(mod .. " + SHIFT + V", hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy"))
hl.bind(mod .. " + SHIFT + 3", hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind(mod .. " + SHIFT + 4", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))

for _, dir in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(mod .. " + " .. dir,           hl.dsp.focus({ direction = dir }))
    hl.bind(mod .. " + SHIFT + " .. dir,   hl.dsp.window.move({ direction = dir }))
end

-- Bureaux 1-9 (touches AZERTY via keycodes 10-18)
for i = 1, 9 do
    local key = "code:" .. (i + 9)
    hl.bind(mod .. " + " .. key,          hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + CTRL + " .. key,   hl.dsp.window.move({ workspace = i }))
end
hl.bind(mod .. " + TAB",         hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 5%+"),                            { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"),                            { locked = true, repeating = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"),                           { locked = true })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),                                 { locked = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),                             { locked = true })
