--[[ 
This script is meant to be used using the Lua Console in the BizHawk emulator
Using the GLideN64 Plugin, the aspect ratio was set to 16:9,
and the video resolution is set to 1920 x 1080.
]]--

local stages = require("stages")

local prevCUp = false -- edge detection for debugging
local prevCRight = false
local prevCDown = false

local screenWidth = client.screenwidth() -- initialized out here for the outside functions
local screenHeight = client.screenheight() 

local showStartupHint = true
local startupFramesRemaining = 300 -- set to ~5 seconds at 60fps

-- debug states
local showInputDebug = false
local prevDebugCombo = false

-- widget states
local showObjective = false
local showHints = false
local showGuideMarkers = false
local walkthroughPopupFrames = 0

-- option menu states
local prevLRCombo = false -- these two are used for l + r toggle
local toggleOverlayOptions = false

-- menu navigation states
local selectedOption = 1
local menuOptions = {
	"Objective Widget",
	"Context Hints",
	"Guide Markers",
    "Walkthrough"
}

-- previous button states for edge detection
local prevUp = false
local prevDown = false
local prevA = false

-- debug functions
function showJoypadInput() -- draws controller inputs at top of screen
	local y = 20
	local pad = joypad.getimmediate(1)

	gui.text(screenWidth / 3, 5, "Controller inputs:")

    for button, pressed in pairs(pad) do
        if pressed then
            gui.text(screenWidth / 3, y, button)
            y = y + 15
		end
	end
end

function showScreenHeight()
    gui.text (screenWidth / 2, screenHeight / 2, "X = " .. screenWidth) -- debug grab screen height
    gui.text (screenWidth / 2, (screenHeight / 2) - 15, "Y = " .. screenHeight)
end

local function applyDeadzone(value, threshold) -- deadzone function because my controller sucks
    if math.abs(value) < threshold then
        return 0
    end
    return value
end

-- the next two functions are for the overlay toggles
local function getOptionState(index) -- returns ON/OFF text for each option
    if index == 1 then
        return showObjective
    elseif index == 2 then
        return showHints
    elseif index == 3 then
        return showGuideMarkers
    elseif index == 4 then
        return nil
    end
    return false
end


local function toggleSelectedOption(index) -- flips the selected option
    if index == 1 then
        showObjective = not showObjective
    elseif index == 2 then
        showHints = not showHints
    elseif index == 3 then
        showGuideMarkers = not showGuideMarkers
    end
end

local function triggerWalkthroughPopup() -- specifically for walkthrough popup
    walkthroughPopupFrames = 180
end

local function drawOverlayOptionsMenu()
    local menuX = screenWidth / 16
    local menuY = 180
    local menuWidth = 360
    local menuHeight = 220

    gui.text(menuX + 20, menuY + 20, "Overlay Options")

    for i = 1, #menuOptions do
        local prefix = "  "
        if i == selectedOption then
            prefix = "> "
        end

        local state = getOptionState(i)

        if state == nil then
            gui.text(menuX + 20, menuY + 40 + (i * 20), prefix .. menuOptions[i])
        else
            local stateText = state and "ON" or "OFF"
            gui.text(menuX + 20, menuY + 40 + (i * 20), prefix .. menuOptions[i] .. " [" .. stateText .. "]")
        end
    end

    gui.text(menuX + 20, menuY + 180, "L+R: Open/Close")
    gui.text(menuX + 20, menuY + 195, "Up/Down: Move")
    gui.text(menuX + 20, menuY + 210, "A: Toggle")
    gui.text(menuX + 20, menuY + 225, "C Up: Next Objective")
    gui.text(menuX + 20, menuY + 240, "C Right: Previous Objective")
    gui.text(menuX + 20, menuY + 270, "Note: if the map disappears,")
    gui.text(menuX + 20, menuY + 285, "press the L button again!")

end

local function getMapConstraint() -- constrains the map size to the screen size

    local mapWidth = screenWidth * 0.26 -- these numbers took a LOT of trial and error oh my goodness)
    local mapHeight = screenHeight * 0.22
    local mapX = screenWidth * 0.62
    local mapY = screenHeight * 0.66

    return {
        x = mapX,
        y = mapY,
        width = mapWidth,
        height = mapHeight
    }
end

local function drawStageMarker() -- draws map markers
    local map = getMapConstraint()
    local markerXPercent, markerYPercent = stages.getCurrentMarkerPosition()

    local markerX = map.x + (markerXPercent * map.width)
    local markerY = map.y + (markerYPercent * map.height)

    gui.text(markerX, markerY, "!")
end

local function drawWidgets()
    if showObjective then
        gui.text(60, 80, "Objective: " .. stages.getCurrentObjective())
    end

    if showHints then
        gui.text(60, screenHeight - 80, "Hint: " .. stages.getCurrentHint())
    end

    if showGuideMarkers then
        gui.text(screenWidth - 300, screenHeight / 1.65, "! = important!" )
        drawStageMarker()
    end

    if walkthroughPopupFrames > 0 then
        gui.text(screenWidth - 480, screenHeight - 140, "Walkthrough function WIP")
        gui.text(screenWidth - 480, screenHeight - 120, "Good source: ZeldaDungeon.net")
    end
end

while true do -- main

	local pad = joypad.getimmediate(1)

	local screenWidth = client.screenwidth() -- these two are also needed in the loop because changing screensize is a big no no without this apparently
	local screenHeight = client.screenheight() 

	gui.clearGraphics() -- need this in loop because every draw rectangle decides to linger for funsies (thanks lua)
	

    -- debug, show controller inputs with DPAD L + A + Z
    local dpadLeftPressed = pad["DPad L"] or false
    local aPressedForDebug = pad["A"] or false
    local zPressed = pad["Z"] or false

    local debugCombo = dpadLeftPressed and aPressedForDebug and zPressed

    if debugCombo and not prevDebugCombo then
        showInputDebug = not showInputDebug
    end

    prevDebugCombo = debugCombo
    
	if showInputDebug then
    showJoypadInput()
    end

    local xAxis = applyDeadzone(pad["X Axis"] or 0, 20)
    local yAxis = applyDeadzone(pad["Y Axis"] or 0, 20)

	-- open options menu
	local lPressed = pad["L"] or false
    local rPressed = pad["R"] or false
    local lrCombo = lPressed and rPressed
    if lrCombo and not prevLRCombo then
        toggleOverlayOptions = not toggleOverlayOptions
    end
    prevLRCombo = lrCombo

    local cUpPressed = pad["C Up"] or false
    local cDownPressed = pad["C Down"] or false

    if cUpPressed and not prevCUp then
        stages.nextStage()
    end

    if cDownPressed and not prevCDown then
        stages.previousStage()
    end

    prevCUp = cUpPressed
    prevCDown = cDownPressed

    -- gui.text(40, 150, "Stage #: " .. stages.currentIndex) -- debug for stage index

	-- widgets are on by default
	drawWidgets()

	-- startup hint
	if showStartupHint and startupFramesRemaining > 0 then -- shows startup hint
		gui.text(screenWidth / 4, screenHeight / 4, "Press 'L1 + R1' together to configure the overlay!")
		startupFramesRemaining = startupFramesRemaining - 1
	end

	if toggleOverlayOptions then

        local upPressed = pad["DPad U"] or false
        local downPressed = pad["DPad D"] or false
        local aPressed = pad["A"] or false

        if upPressed and not prevUp then
            selectedOption = selectedOption - 1
            if selectedOption < 1 then
                selectedOption = #menuOptions
            end
        end

        if downPressed and not prevDown then
            selectedOption = selectedOption + 1
            if selectedOption > #menuOptions then
                selectedOption = 1
            end
        end

        if aPressed and not prevA then
            if selectedOption == 4 then
                triggerWalkthroughPopup()
            else
                toggleSelectedOption(selectedOption)
        end
end

        prevUp = upPressed
        prevDown = downPressed
        prevA = aPressed

        drawOverlayOptionsMenu()
    else
        -- reset edge detection when menu is closed
        prevUp = false
        prevDown = false
        prevA = false
    end


    if walkthroughPopupFrames > 0 then -- decrement for walkthrough check
    walkthroughPopupFrames = walkthroughPopupFrames - 1
    end

	emu.frameadvance();
end
