--[[ 
This script is meant to be used using the Lua Console in the BizHawk emulator
Using the GLideN64 Plugin, the aspect ratio was set to 16:9,
and the video resolution is set to 1920 x 1080.
]]--

package.loaded["widgets"] = nil -- makes bizhawk recache the other lua files on refresh
package.loaded["stages"] = nil 
package.loaded["menu"] = nil 
package.loaded["map"] = nil 
local widgets = require("widgets")
local stages = require("stages")
local menu = require("menu")
local map = require("map")


local prevCUp = false -- edge detection for debugging
local prevCRight = false
local prevCDown = false

screenWidth = client.screenwidth() -- initialized out here for the outside functions
screenHeight = client.screenheight() 

local showStartupHint = true
local startupFramesRemaining = 300 -- set to ~5 seconds at 60fps

-- debug states
local showInputDebug = false
local prevDebugCombo = false

-- widget states
local widgetState = {
    showObjective = false,
    showHints = false,
    showGuideMarkers = false
}

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


local function triggerWalkthroughPopup() -- specifically for walkthrough popup
    walkthroughPopupFrames = 180
end

local function drawWidgets()
    if widgetState.showObjective then
        widgets.drawObjective(stages)
    end

    if widgetState.showHints then
        widgets.drawHint(stages, screenHeight)
    end

    if widgetState.showGuideMarkers then
        widgets.drawGuideMarkerLabel(screenWidth)
        map.drawStageMarker(screenWidth, screenHeight, stages)
    end

    if walkthroughPopupFrames > 0 then
        widgets.drawWalkthroughPopup(screenWidth, screenHeight)
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
                menu.toggleSelectedOption(selectedOption, widgetState)
            end
    end

        prevUp = upPressed
        prevDown = downPressed
        prevA = aPressed

        menu.drawOverlayOptionsMenu(screenWidth, menuOptions, selectedOption, widgetState)
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
