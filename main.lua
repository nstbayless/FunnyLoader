import("CoreLibs/graphics")
import("CoreLibs/keyboard")
import("CoreLibs/timer")
import("CoreLibs/object")
import("CoreLibs/sprites")

gfx = playdate.graphics
fle = playdate.file

font = gfx.getLargeUIFont()
loading_img = gfx.image.new(400,240,gfx.kColorBlack)

firstUpdate = true

datastore_path = "/Shared/FunnyLoader/funnyLoaderConfig"
default_config = {
    default = "",
}
config = default_config

launchers = {}
icons = {}
selected = 1

function saveConfig()
    print("SAVED CONFIG \""..datastore_path..".\"")
    playdate.datastore.write(config,datastore_path)
end

function loadConfig()
    config = playdate.datastore.read(datastore_path)
    if config == nil then
        config = default_config
        print("INVALID OR NIL CONFIG, SET DEFAULT.")
    else
        print("LOADED CONFIG \""..datastore_path..".\"")    
    end
    for k,v in pairs(default_config) do
        if config[k] == nil then
            config[k] = v
            print("INVALID CONFIG VALUE AT KEY \""..k..",\" SET DEFAULT.")
        end
    end
    saveConfig()
end

function generateDrawTextScaledImage(text, x, y, scale, font)
if font == nil then font = gfx.getLargeUIFont() end
    local padding = string.upper(text) == text and 6 or 0 -- Weird padding hack?
    local w <const> = font:getTextWidth(text)
    local h <const> = font:getHeight() - padding
    local img <const> = gfx.image.new(w, h, gfx.kColorClear)
    local img2 <const> = gfx.image.new(w*scale*2, h*scale*2, gfx.kColorClear)
    gfx.lockFocus(img)
    gfx.setFont(font)
    gfx.drawTextAligned(text, w / 2, 0, kTextAlignment.center)
    gfx.unlockFocus()
    gfx.lockFocus(img2)
    img:drawScaled((scale * w) / 2, (scale * h) / 2, scale)
    gfx.unlockFocus()
    return img2
end

function listCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else
        copy = orig
    end
    return copy
end

function dirSetup()
	fle.mkdir("/Shared/FunnyLoader")
    print("ENSURED EXISTENCE OF \"/Shared/FunnyLoader\" DIRECTORY")
    img = gfx.image.new("/Shared/FunnyLoader/load.pdi")
    if img then
        print("LOADED CUSTOM LOADING SCREEN FROM \"/Shared/FunnyLoader/load.pdi.\"")
        local w,h = img:getSize()
        img = img:scaledImage(1/(w/400))
        loading_img = img
    end
end

function playdate.update()
    playdate.timer.updateTimers()
	playdate.resetElapsedTime()
	if firstUpdate then
		firstUpdate=false
		main()
	end
    
    updateCursor()
end

function updateCursor()
    if playdate.buttonJustPressed(playdate.kButtonUp) and selected > 1 then
        selected -= 1
        drawSelection(selected)
    end
    if playdate.buttonJustPressed(playdate.kButtonDown) and selected < #launchers then
        selected += 1
        drawSelection(selected)
    end
    if playdate.buttonJustReleased(playdate.kButtonA) then
        if launchers[selected] then
            print("FOUND OS PDX \""..launchers[selected]..",\" LAUNCHING.")
            playdate.system.switchToGame("/System/Launchers/"..launchers[selected], "FunnyLoader")  
        else
            print("NO LAUNCHERS TO LAUNCH.")    
        end  
    end
    if playdate.buttonJustPressed(playdate.kButtonB) then
        
        if launchers[selected] then
            print("FOUND OS PDX \""..launchers[selected]..",\" SETTING DEFAULT.")
            config["default"] = launchers[selected]
            saveConfig()
            drawSelection(selected)
        else
            print("NO LAUNCHERS TO LAUNCH.")    
        end  
    end
end

function boot()
    -- if not holding bootloader combo and a default is set then go to default
    if (config["default"] ~= "") then -- load default os
        if  (not playdate.isCrankDocked()) and playdate.getCrankPosition() > 45 and playdate.getCrankPosition() < 135 then 
            print("CRANK POSITIONED FOR BOOTLOADER, SKIPPING DEFAULT")
	elseif playdate.argv[1] == "nodefault" then
	    print("NODEFAULT FLAG PASSED, SKIPPING DEFAULT")
        else
            if fle.exists("/System/Launchers/"..config["default"]) then
                print("FOUND DEFAULT OS PDX \""..config["default"]..",\" LAUNCHING.")
                playdate.system.switchToGame("/System/Launchers/"..config["default"], "FunnyLoader")
                return
            else
                print("INVALID DEFAULT OS PDX \""..config["default"]..",\" RESETTING DEFAULT VALUE.")    
                config["default"] = default_config["default"]
                saveConfig()
            end
        end
    else
        print("NO DEFAULT OS PDX, CONTINUING TO BOOT SELECTION.")
    end
    selected = 1
    local files = fle.listFiles("/System/Launchers")
    print("FOUND LAUNCHER .PDX FILES: ")
    for i,v in ipairs(files) do
        v = v:sub(1,#v-1)
        files[i] = v
        if string.lower(v:sub(#v-3,#v)) == ".pdx" then
            print("- "..string.upper(v))
            table.insert(launchers,v)
            if fle.exists("/System/Launchers/"..v.."/icon.pdi") then
                print("- - ".."FOUND ICON FOR \""..v..",\" LOADED.")
                icons[v] = gfx.image.new("/System/Launchers/"..v.."/icon.pdi")
            elseif fle.exists("/System/Launchers/"..v.."/images/list_icon_default.pdi") then
                print("- - ".."FOUND ICON FOR \""..v..",\" LOADED.")
                icons[v] = gfx.image.new("/System/Launchers/"..v.."/images/list_icon_default.pdi")
            else
                local f = fle.open("/System/Launchers/"..v.."/pdxinfo")   
                local firstLine = f:readline()
                if firstLine == "name=Index OS" then
                    print("- - ".."FOUND ICON FOR \""..v..",\" LOADED.")
                    local img = gfx.image.new(32,32,gfx.kColorClear)
                    gfx.lockFocus(img)
                    gfx.setColor(gfx.kColorWhite)
                    gfx.fillRoundRect(0, 0, 32, 32, 3)
                    gfx.image.new("images/indexOS"):draw(0,0)
                    gfx.unlockFocus()
                    icons[v] = img
                else
                    print(firstLine:gsub("\n", "bsn"))    
                end
                
                -- check for launcher assets directory in pdxinfo
                local line = firstLine
                local imagePathField = "imagePath="
                while line do
                    if line:sub(1, #imagePathField) == imagePathField then
                        local imagePath = line:sub(#imagePathField+1)
                        
                        -- remove trailing '/'
                        if imagePath:sub(-1) == "/" then
                            imagePath = imagePath:sub(1, -2)
                        end
                        
                        if fle.exists("/System/Launchers/"..v.."/"..imagePath.."/list_icon_default.pdi") then
                            if not icons[v] then -- only use this icon if no other icon is provided
                                print("- - ".."FOUND ICON FOR \""..v..",\" LOADED.")
                                icons[v] = gfx.image.new("/System/Launchers/"..v.."/"..imagePath.."/list_icon_default.pdi")
                            end
                        end
                        
                        if fle.exists("/System/Launchers/"..v.."/"..imagePath.."/icon.pdi") then
                            if not icons[v] then -- only use this icon if no other icon is provided
                                print("- - ".."FOUND ICON FOR \""..v..",\" LOADED.")
                                icons[v] = gfx.image.new("/System/Launchers/"..v.."/"..imagePath.."/icon.pdi")
                            end
                        end
                    end
                    line = f:readline()
                end
            end
        end
    end
    drawSelection(selected)
end

function drawSelection(index) 
    local rowheight = 34
    local default_yoffset = 8
    local yoffset = rowheight*(index-6) + default_yoffset
    if index <= 6 then yoffset = default_yoffset end

    gfx.clear(gfx.kColorBlack)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillCircleAtPoint(16, index*rowheight-2 - yoffset, 6)
    for i,v in ipairs(launchers) do
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        font:drawText(v:sub(1,#v-4), 32, i*rowheight -rowheight/2 - yoffset)
        if icons[v] then
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRect(400-41, i*rowheight-18 - yoffset, 34, 34)
            icons[v]:draw(400-40,i*rowheight - rowheight/2 - yoffset)    
        end 
            if v == config["default"] then
                gfx.setColor(gfx.kColorWhite)
                gfx.fillCircleAtPoint(16, i*rowheight-2 - yoffset, 5)
                gfx.setColor(gfx.kColorBlack)
                gfx.fillCircleAtPoint(16, i*rowheight-2 - yoffset, 3)
        end
    end
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, 240-24, 400, 24)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.getUIFont():drawText("Ⓐ Launch                                         Set as Default Ⓑ", 5, 218)
end

function main()
    
    print("---------------------------------")
    print("     FunnyLoader by RintaDev")
    print("\"Competent\" Playdate OS switcher")
    print("---------------------------------")
    print("")
    -- load files n shit
    dirSetup()
    -- draw the loading screen then continue processing
    loading_img:draw(0,0)
    playdate.display.flush()
    -- load config first
    loadConfig()
    -- set target fps
    playdate.display.setRefreshRate(20)
    
    -- clear screen once loaded
    gfx.clear(gfx.kColorBlack)
    
    local menu = playdate.getSystemMenu()
    menu:removeAllMenuItems()
    
    playdate.resetElapsedTime()
    
    print("BEGINNING BOOT PROCESS.")
    boot()
    
end
