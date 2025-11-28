-- Ap4k/assets.lua
local assets = {}

assets.theme = {
    desktop_bg = colors.black,      -- Исправлено для совпадения с system.lua
    taskbar_bg = colors.gray,       -- Исправлено
    dock_active = colors.lightBlue,
    
    window_bg = colors.white,
    window_header = colors.lightGray,
    window_text = colors.black,
    window_shadow = true,           -- Нужно для system.lua
    
    accent = colors.cyan,
    error = colors.red,
    success = colors.lime
}

assets.icons = {
    menu = "\14",
    terminal = ">_",
    folder = "\19",
    file = "\22",
    close = "\215",
    settings = "\15",
    lua = "\14"    -- Добавил, так как используется в system.lua
}

return assets
