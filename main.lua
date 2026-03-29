--[[ 
This script is meant to be used using the Lua Console in the BizHawk emulator
Using the GLideN64 Plugin, the aspect ratio was set to 16:9,
and the video resolution is set to 1920 x 1080.
]]--

local screenWidth = client.screenwidth() -- initialized out here for the outside functions
local screenHeight = client.screenheight() 

local showStartupHint = true
local startupFramesRemaining = 300 -- set to ~5 seconds at 60fps

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
    local menuX = screenWidth - 420
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
end

local function drawWidgets() -- example widgets
    if showObjective then
        gui.text(60, 80, "Objective: Enter the Deku Tree")
    end

    if showHints then
        gui.text(60, screenHeight - 80, "Hint: Visit the shop for a shield")
    end

    if showGuideMarkers then
        gui.text(screenWidth - 300, screenHeight / 1.65, "Guide Marker: Active")
    end

    if walkthroughPopupFrames > 0 then
    gui.text(screenWidth - 480, screenHeight - 140, "Walkthrough")
    gui.text(screenWidth - 480, screenHeight - 120, "Open OoT wiki / guide in browser")
    end
end

while true do -- main
	local pad = joypad.getimmediate(1)

	local screenWidth = client.screenwidth() -- these two are also needed in the loop because changing screensize is a big no no without this apparently
	local screenHeight = client.screenheight() 

	gui.clearGraphics() -- need this in loop because every draw rectangle decides to linger for funsies (thanks lua)
	
	showJoypadInput()

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

	-- widgets are on by default
	drawWidgets()

	-- startup hint
	if showStartupHint and startupFramesRemaining > 0 then -- shows startup hint
		gui.text(screenWidth / 4, screenHeight / 4, "Press 'L1 + R1' together to configure the overlay!")
		startupFramesRemaining = startupFramesRemaining - 1
	end

	-- menu only works while menu is open 
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
