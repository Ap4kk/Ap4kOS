-- Ap4kOS Professional Installer v2.0
local REPO_URL = "https://raw.githubusercontent.com/Ap4kk/Ap4kOS/main/"
local BASALT_URL = "https://github.com/Pyroxenium/Basalt2/releases/download/v2.0.0-beta/basalt.lua"

local filesToDownload = {
    { path = "startup.lua", url = REPO_URL .. "startup.lua" },
    { path = "Ap4k/system.lua", url = REPO_URL .. "Ap4k/system.lua" },
    { path = "Ap4k/assets.lua", url = REPO_URL .. "Ap4k/assets.lua" },
    -- Библиотека Basalt v2 (всегда обновляем)
    { path = "basalt.lua", url = BASALT_URL }
}

-- === GUI Утилиты ===
local w, h = term.getSize()
local function drawHeader()
    term.setBackgroundColor(colors.blue)
    term.clear()
    term.setCursorPos(1,1)
    term.setTextColor(colors.white)
    print(string.rep(" ", w))
    term.setCursorPos(math.floor(w/2 - 6), 1)
    print("Ap4kOS Setup")
    term.setBackgroundColor(colors.black)
end

local function drawProgress(percent, status)
    local barWidth = w - 4
    local filled = math.floor(percent * barWidth)
    
    term.setCursorPos(2, h/2)
    term.write(status)
    
    term.setCursorPos(3, h/2 + 2)
    term.setBackgroundColor(colors.gray)
    term.write(string.rep(" ", barWidth)) -- Пустой бар
    
    term.setCursorPos(3, h/2 + 2)
    term.setBackgroundColor(colors.lime)
    term.write(string.rep(" ", filled))   -- Заполненный бар
    
    term.setBackgroundColor(colors.black)
end

-- === Логика скачивания ===
local function downloadFile(url, path)
    -- Создаем папку, если её нет
    local dir = fs.getDir(path)
    if dir ~= "" and not fs.exists(dir) then fs.makeDir(dir) end
    
    -- Пытаемся скачать 3 раза (Retry logic)
    for i = 1, 3 do
        local response = http.get(url)
        if response then
            local content = response.readAll()
            response.close()
            
            local file = fs.open(path, "w")
            file.write(content)
            file.close()
            return true
        end
        sleep(0.5) -- Ждем перед повтором
    end
    return false
end

-- === Главная функция ===
local function install()
    drawHeader()
    
    -- 1. Проверка HTTP
    if not http then
        term.setTextColor(colors.red)
        print("\nError: HTTP API is disabled!")
        print("Enable it in ComputerCraft config.")
        return
    end

    -- 2. Удаление старой версии (Clean Install)
    drawProgress(0.1, "Cleaning old files...")
    if fs.exists("Ap4k") then fs.delete("Ap4k") end
    if fs.exists("startup.lua") then fs.delete("startup.lua") end
    sleep(0.5)

    -- 3. Скачивание файлов
    for i, file in ipairs(filesToDownload) do
        local progress = 0.1 + ((i / #filesToDownload) * 0.8)
        drawProgress(progress, "Downloading: " .. file.path)
        
        local success = downloadFile(file.url, file.path)
        if not success then
            term.setBackgroundColor(colors.black)
            term.clear()
            term.setCursorPos(1,1)
            term.setTextColor(colors.red)
            print("Error downloading: " .. file.path)
            print("Check your internet connection.")
            return
        end
    end

    -- 4. Завершение
    drawProgress(1.0, "Installation Complete!")
    sleep(1)
    
    term.setBackgroundColor(colors.green)
    term.clear()
    term.setCursorPos(w/2 - 5, h/2)
    term.setTextColor(colors.black)
    print(" Rebooting... ")
    sleep(1)
    os.reboot()
end

-- Запуск
install()
