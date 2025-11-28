-- Ap4k/assets.lua
local assets = {}

assets.theme = {
    desktop_bg = colors.black,
    dock_bg = colors.gray,
    dock_active = colors.lightBlue,
    window_header = colors.lightGray,
    window_header_text = colors.black,
    window_bg = colors.white,
    accent = colors.cyan,
    error = colors.red
}

-- Иконки (NFP-подобные символы или текст)
assets.icons = {
    folder = "\19", -- Папка
    file = "\22",   -- Файл
    lua = "\15",    -- Скрипт
    trash = "\127",
    menu = "\18",
    close = "\215"
}

return assets
