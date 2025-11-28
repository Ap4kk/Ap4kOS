-- startup.lua
term.clear()
term.setCursorPos(1,1)
textutils.slowPrint("Booting Ap4kOS...", 20)

-- 1. Авто-установка Basalt v2 (если нет)
if not fs.exists("basalt.lua") then
    print("\n[!] Basalt lib missing. Downloading...")
    if not http then error("Need HTTP API enabled!") end
    -- Ссылка на Release v2 (пример, лучше проверить актуальную)
    shell.run("wget https://github.com/Pyroxenium/Basalt2/releases/download/v2.0.0-beta/basalt.lua basalt.lua")
end

-- 2. Загрузка ресурсов
if not fs.exists("Ap4k/system.lua") then
    print("[!] OS System files missing!")
    return
end

package.path = "/?.lua;/Ap4k/?.lua;" .. package.path

-- 3. Анимация загрузки (фейковая, для красоты)
local w, h = term.getSize()
paintutils.drawFilledBox(w/2-10, h/2, w/2+10, h/2, colors.gray)
for i=1, 20 do
    paintutils.drawFilledBox(w/2-10, h/2, w/2-10+i, h/2, colors.lime)
    sleep(0.05)
end

-- 4. Запуск
shell.run("Ap4k/system.lua")
