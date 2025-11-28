-- Ap4k/system.lua

-- === Надежное подключение Basalt ===
local basalt
if fs.exists("basalt.lua") then
    basalt = require("basalt")
elseif fs.exists("/basalt.lua") then
    basalt = require("/basalt")
else
    error("Basalt lib missing! Check startup.lua paths.")
end

-- Подключаем ресурсы
local assets = require("Ap4k.assets") -- Ищет Ap4k/assets.lua

-- === Инициализация UI ===
local main = basalt.getMainFrame()
main:setBackground(assets.theme.desktop_bg)

-- Переменная для подсчета открытых окон
local winCounter = 0

-- === ФУНКЦИЯ: Создать Окно ===
local function spawnWindow(title, width, height)
    winCounter = winCounter + 1
    local xPos = 2 + (winCounter * 2)
    local yPos = 2 + winCounter
    
    if xPos > 20 then winCounter = 0; xPos=2; yPos=2 end

    -- Само окно
    local win = main:addFrame()
        :setPosition(xPos, yPos)
        :setSize(width, height)
        :setMovable(true)
        :setBackground(assets.theme.window_bg)
        :setShadow(assets.theme.window_shadow)

    -- Анимация
    win:animateSize(width, height, 0.4)
    win:setSize(1,1) -- Старт анимации с точки

    -- Заголовок
    local header = win:addFrame()
        :setPosition(1, 1)
        :setSize("parent.w", 1)
        :setBackground(assets.theme.window_header)
    
    header:addLabel()
        :setText(title)
        :setPosition(2, 1)
        :setForeground(colors.black)
        
    -- Кнопка закрытия
    header:addButton()
        :setText(assets.icons.close)
        :setPosition("parent.w", 1):setSize(1,1)
        :setBackground(assets.theme.error)
        :setForeground(colors.white)
        :onClick(function() win:remove() end)

    -- Рабочая область (контент)
    local content = win:addFrame()
        :setPosition(1, 2)
        :setSize("parent.w", "parent.h - 1")
        :setBackground(colors.transparent)

    return content
end

-- === ПРИЛОЖЕНИЕ: Файлы ===
local function appFiles(dir)
    dir = dir or ""
    local body = spawnWindow("Files: /"..dir, 32, 12)
    
    local list = body:addList()
        :setSize("parent.w-2", "parent.h-2")
        :setPosition(2,2)
        :setBackground(colors.lightGray)
        :setSelectionColor(assets.theme.accent, colors.black)
        
    local function updateList()
        list:clear()
        if dir ~= "" then list:addItem(".. [BACK]", nil, {back=true}) end
        
        local files = fs.list(dir)
        for _, file in pairs(files) do
            local fullPath = fs.combine(dir, file)
            local isDir = fs.isDir(fullPath)
            local icon = isDir and assets.icons.folder or assets.icons.file
            list:addItem(icon.." "..file, nil, {path=fullPath, isDir=isDir})
        end
    end
    
    list:onChange(function(self, item)
        if item.args.back then
            dir = fs.getDir(dir)
            if dir == ".." then dir = "" end
        elseif item.args.isDir then
            dir = item.args.path
        else
            shell.run("bg "..item.args.path)
        end
        updateList()
    end)
    updateList()
end

-- === ПРИЛОЖЕНИЕ: Терминал ===
local function appTerminal()
    local body = spawnWindow("Terminal", 36, 14)
    body:setBackground(colors.black)
    
    local logs = body:addList()
        :setSize("parent.w", "parent.h-1")
        :setSelectionColor(colors.black, colors.white)
    
    body:addInput()
        :setPosition(1, "parent.h")
        :setSize("parent.w", 1)
        :setBackground(colors.gray):setForeground(colors.white)
        :onSubmit(function(self)
            local cmd = self:getValue()
            logs:addItem("> "..cmd)
            if cmd == "exit" then body:getParent():remove() end
            -- Тут можно добавить shell.execute
            self:setValue("")
            logs:setOffsetIndex(#logs:getItems())
        end)
end

-- === РАБОЧИЙ СТОЛ (Desktop) ===
local grid = main:addFlex()
    :setPosition(2, 2)
    :setSize("parent.w - 2", "parent.h - 2")
    :setDirection("column")
    :setGap(1)

local function addIcon(name, icon, func)
    grid:addButton()
        :setSize(12, 3)
        :setText(icon.."  "..name)
        :setBackground(colors.gray)
        :setForeground(colors.white)
        :onClick(func)
end

addIcon("My Files", assets.icons.folder, function() appFiles("") end)
addIcon("Terminal", assets.icons.terminal, appTerminal)
addIcon("Lua", assets.icons.lua, function() shell.run("bg lua") end)

-- === ПАНЕЛЬ ЗАДАЧ (Dock) ===
local dock = main:addFrame()
    :setPosition(1, "parent.h")
    :setSize("parent.w", 1)
    :setBackground(assets.theme.dock_bg)
    :setZIndex(50)

dock:addButton()
    :setText(assets.icons.menu.." Start")
    :setBackground(assets.theme.accent)
    :setSize(8, 1)
    :onClick(function()
        -- Простое меню пуск
        local menu = main:addFrame():setSize(10, 4):setPosition(1, "parent.h-4"):setZIndex(100)
        menu:addButton():setText("Reboot"):setSize("parent.w", 1):setPosition(1,1):onClick(function() os.reboot() end)
        menu:addButton():setText("Shutdown"):setSize("parent.w", 1):setPosition(1,2):setBackground(colors.red):onClick(function() os.shutdown() end)
    end)

-- Старт
basalt.autoUpdate()
