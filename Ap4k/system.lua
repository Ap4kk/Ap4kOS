-- Ap4k/system.lua
local basalt = require("basalt")
local assets = require("Ap4k.assets")

local main = basalt.getMainFrame()
main:setBackground(assets.theme.desktop_bg)

-- === СИСТЕМНЫЕ ПЕРЕМЕННЫЕ ===
local openWindows = 0

-- === 1. МЕНЕДЖЕР ОКОН (Window Manager v2) ===
local function spawnWindow(title, w, h, id)
    openWindows = openWindows + 1
    
    -- Эффект "каскада": каждое новое окно чуть ниже и правее
    local xPos = 3 + (openWindows * 2)
    local yPos = 3 + (openWindows * 1)
    
    local win = main:addFrame()
        :setSize(w or 30, h or 12)
        :setPosition(xPos, yPos)
        :setMovable(true)
        :setShadow(true)
        :setBackground(assets.theme.window_bg)
    
    -- Анимация открытия (Zoom In)
    win:animateSize(w or 30, h or 12, 0.4)
    win:setSize(1,1)

    -- Заголовок (Header) с градиентом (эмуляция через 2 цвета)
    local header = win:addFrame()
        :setSize("parent.w", 1)
        :setBackground(assets.theme.window_header)
    
    header:addLabel():setText(title):setPosition(2,1):setForeground(assets.theme.window_header_text)
    
    -- Кнопка закрытия
    header:addButton()
        :setText(assets.icons.close)
        :setPosition("parent.w", 1):setSize(1,1)
        :setBackground(assets.theme.error):setForeground(colors.white)
        :onClick(function() 
            win:remove() 
            openWindows = openWindows - 1
        end)

    local content = win:addFrame():setPosition(1,2):setSize("parent.w", "parent.h - 1"):setBackground(colors.transparent)
    return content, win
end

-- === 2. ПРИЛОЖЕНИЕ: ФАЙЛОВЫЙ МЕНЕДЖЕР ===
local function openFileManager(path)
    path = path or ""
    local body, win = spawnWindow("Files: /"..path, 34, 14)
    
    -- Список файлов
    local list = body:addList()
        :setSize("parent.w - 2", "parent.h - 2")
        :setPosition(2, 2)
        :setBackground(colors.white)
        :setSelectionColor(assets.theme.accent, colors.black)

    local function refresh()
        list:clear()
        -- Кнопка "Назад"
        if path ~= "" then 
            list:addItem(".. [UP]", nil, nil) 
        end
        
        local files = fs.list(path)
        for _, file in pairs(files) do
            local fullPath = fs.combine(path, file)
            local isDir = fs.isDir(fullPath)
            local icon = isDir and assets.icons.folder or assets.icons.lua
            list:addItem(icon .. " " .. file, nil, {path=fullPath, isDir=isDir})
        end
    end
    
    list:onChange(function(self, item)
        local data = item.args
        if not data then -- Это кнопка "Назад"
            path = fs.getDir(path)
            if path == ".." then path = "" end
        elseif data.isDir then
            path = data.path
        else
            -- Запуск файла
            shell.run("bg " .. data.path)
            basalt.debug("Running " .. data.path)
            return
        end
        win:getChild(1):getChild(1):setText("Files: /"..path) -- Обновляем заголовок
        refresh()
    end)
    
    refresh()
end

-- === 3. РАБОЧИЙ СТОЛ (Desktop Grid) ===
-- Используем Flexbox для автоматического выравнивания иконок
local desktopGrid = main:addFlex()
    :setPosition(6, 2) -- Отступ слева для Дока
    :setSize("parent.w - 6", "parent.h")
    :setDirection("row")
    :setWrap("wrap")
    :setJustifyContent("flex-start")
    :setGap(2) -- Расстояние между иконками

local function addDesktopIcon(name, icon, func)
    -- Контейнер иконки
    local item = desktopGrid:addFrame()
        :setSize(8, 4)
        :setBackground(colors.transparent)
    
    -- Сама кнопка-иконка
    item:addButton()
        :setPosition(3, 1):setSize(3, 2)
        :setText(icon)
        :setBackground(colors.lightGray) -- Цвет "плашки" иконки
        :setForeground(colors.black)
        :onClick(func)
        :setShadow(true)
    
    -- Подпись
    item:addLabel()
        :setText(name)
        :setPosition(1, 3):setSize(8, 1)
        :setTextAlign("center")
        :setForeground(colors.white)
end

-- === 4. DOCK (Боковая панель) ===
local dock = main:addFrame()
    :setSize(4, "parent.h")
    :setBackground(assets.theme.dock_bg)
    :setZIndex(50)

-- Анимированная кнопка "Пуск"
local startBtn = dock:addButton()
    :setText(assets.icons.menu)
    :setPosition(1, 1):setSize(4, 3)
    :setBackground(colors.orange)
    :onClick(function()
        -- Здесь можно открыть меню Пуск (pop-up)
        main:addLabel():setText("Menu WIP"):setPosition(6, 2):setForeground(colors.white):animatePosition(6, -2, 2)
    end)

-- === 5. CONTEXT MENU (ПКМ) ===
-- Скрытый фрейм меню
local contextMenu = main:addFrame()
    :setSize(12, 6):setVisible(false):setZIndex(100):setBackground(colors.lightGray):setShadow(true)

contextMenu:addButton():setText("New Folder"):setPosition(1,1):setSize(12,1):onClick(function() contextMenu:hide() end)
contextMenu:addButton():setText("Refresh"):setPosition(1,2):setSize(12,1):onClick(function() contextMenu:hide() end)
contextMenu:addButton():setText("Properties"):setPosition(1,3):setSize(12,1):onClick(function() contextMenu:hide() end)

-- Ловим клик правой кнопкой по рабочему столу
main:onClick(function(self, event, btn, x, y)
    if btn == 2 then -- 2 = Right Click
        contextMenu:setPosition(x, y)
        contextMenu:show()
        contextMenu:setFocused(true) -- Чтобы закрыть при клике мимо
    else
        contextMenu:hide()
    end
end)

-- === 6. УВЕДОМЛЕНИЯ (Toast System) ===
local notifContainer = main:addFlex()
    :setPosition("parent.w - 25", "parent.h - 10")
    :setSize(25, 10)
    :setDirection("column-reverse") -- Новые снизу
    :setGap(1)
    :setZIndex(200)

local function sendNotification(title, msg)
    local card = notifContainer:addFrame()
        :setSize(22, 4)
        :setBackground(colors.yellow)
        :setShadow(true)
    
    card:addLabel():setText(title):setPosition(1,1):setForeground(colors.black)
    card:addLabel():setText(msg):setPosition(1,2):setSize(20,2):setForeground(colors.gray)
    
    -- Авто-удаление через 4 секунды
    basalt.schedule(function()
        sleep(4)
        card:remove()
    end)
end

-- === ИНИЦИАЛИЗАЦИЯ ===

-- Добавляем иконки на рабочий стол
addDesktopIcon("Shell", ">_", function() shell.run("fg shell") end)
addDesktopIcon("Files", assets.icons.folder, function() openFileManager("/") end)
addDesktopIcon("Lua", assets.icons.lua, function() shell.run("bg lua") end)
addDesktopIcon("Store", "$", function() sendNotification("AppStore", "Connection failed") end)

-- Приветствие
sendNotification("System", "Welcome to Ap4kOS Pro")

basalt.autoUpdate()
