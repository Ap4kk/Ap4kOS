local baseUrl = "https://raw.githubusercontent.com/Ap4kk/Ap4kOS/main/"

local files = {
    "startup.lua",
    "Ap4k/system.lua",
    "Ap4k/assets.lua"
}

print("Connecting to GitHub...")

for _, path in ipairs(files) do
    -- Создаем папку если нужно (например Ap4k/)
    local dir = fs.getDir(path)
    if not fs.exists(dir) and dir ~= "" then
        fs.makeDir(dir)
    end

    -- Качаем файл
    print("Downloading " .. path .. "...")
    local response = http.get(baseUrl .. path)
    
    if response then
        local file = fs.open(path, "w")
        file.write(response.readAll())
        file.close()
        response.close()
    else
        error("Failed to download: " .. path)
    end
end

-- Отдельно качаем Basalt v2 (библиотеку)
if not fs.exists("basalt.lua") then
    print("Downloading Basalt v2 Library...")
    shell.run("wget https://github.com/Pyroxenium/Basalt2/releases/download/v2.0.0-beta/basalt.lua basalt.lua")
end

print("\nSuccess! Rebooting...")
sleep(2)
os.reboot()
