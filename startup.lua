-- startup.lua: Загрузчик Ap4kOS

-- 1. Магия путей (Это решает вашу ошибку!)
-- Мы говорим: ищи файлы везде - в корне, в папке lib, в папке Ap4k
package.path = "/?.lua;/?/init.lua;/Ap4k/?.lua;/lib/?.lua;" .. package.path

-- 2. Проверка наличия Basalt
if not fs.exists("basalt.lua") then
    term.clear()
    term.setCursorPos(1,1)
    term.setTextColor(colors.red)
    print("CRITICAL ERROR: 'basalt.lua' not found!")
    print("Please run 'installer' to download libraries.")
    term.setTextColor(colors.white)
    return
end

-- 3. Запуск системы
-- Используем pcall, чтобы если ОС упадет, мы увидели ошибку, а не черный экран
local ok, err = pcall(function()
    shell.run("Ap4k/system.lua")
end)

if not ok then
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1,1)
    term.setTextColor(colors.red)
    print("System Crashed:")
    print(err)
    print("\nPress any key to reboot...")
    os.pullEvent("key")
    os.reboot()
end
