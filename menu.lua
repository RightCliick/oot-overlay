local menu = {}

function menu.getOptionState(index, state)
    if index == 1 then
        return state.showObjective
    elseif index == 2 then
        return state.showHints
    elseif index == 3 then
        return state.showGuideMarkers
    elseif index == 4 then
        return nil
    end

    return false
end

function menu.toggleSelectedOption(index, state)
    if index == 1 then
        state.showObjective = not state.showObjective
    elseif index == 2 then
        state.showHints = not state.showHints
    elseif index == 3 then
        state.showGuideMarkers = not state.showGuideMarkers
    end
end

function menu.drawOverlayOptionsMenu(screenWidth, menuOptions, selectedOption, state)
    local menuX = screenWidth * 0.0625
    local menuY = screenHeight * 0.25

    gui.text(menuX + 20, menuY + 20, "Overlay Options")

    for i = 1, #menuOptions do -- options navigation
        local prefix = "  "
        if i == selectedOption then
            prefix = "> "
        end

        local optionState = menu.getOptionState(i, state)

        if optionState == nil then
            gui.text(menuX + 20, menuY + 40 + (i * 20), prefix .. menuOptions[i])
        else
            local stateText = optionState and "ON" or "OFF"
            gui.text(menuX + 20, menuY + 40 + (i * 20), prefix .. menuOptions[i] .. " [" .. stateText .. "]")
        end
    end

    gui.text(menuX + 20, menuY + 180, "L+R: Open/Close")
    gui.text(menuX + 20, menuY + 195, "Up/Down: Move")
    gui.text(menuX + 20, menuY + 210, "A: Toggle")
    gui.text(menuX + 20, menuY + 225, "C Up: Next Objective")
    gui.text(menuX + 20, menuY + 240, "C Down: Previous Objective")
    gui.text(menuX + 20, menuY + 270, "Note: if the map disappears,")
    gui.text(menuX + 20, menuY + 285, "press the L button again!")
end

return menu