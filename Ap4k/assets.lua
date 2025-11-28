-- Ap4k/assets.lua
local assets = {}

-- Цветовая схема (Theme)
assets.theme = {
    desktop = colors.black,       -- Цвет рабочего стола
    taskbar = colors.gray,        -- Цвет панели задач
    window_bg = colors.white,     -- Фон окон
    window_header = colors.lightGray, -- Заголовок окна
    text_main = colors.black,     -- Основной текст
    text_header = colors.black,   -- Текст заголовков
    accent = colors.cyan,         -- Акцентный цвет (кнопки)
    close_btn = colors.red        -- Кнопка закрытия
}

-- Иконки (текстовые символы)
assets.icons = {
    menu = "\14",     -- Значок меню (гамбургер)
    terminal = ">_",
    folder = "\19",   -- Папка
    file = "\22",     -- Файл
    close = "\215",   -- Крестик (x)
    settings = "\15"
}

return assets
