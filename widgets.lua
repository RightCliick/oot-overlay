local widgets = {}

-- Objective widget
function widgets.drawObjective(stages)
    gui.text(60, 80, "Objective: " .. stages.getCurrentObjective())
end


-- Hint widget
function widgets.drawHint(stages, screenHeight)
    gui.text(60, screenHeight - 80, "Hint: " .. stages.getCurrentHint())
end


-- Guide marker label (not the marker itself)
function widgets.drawGuideMarkerLabel(screenWidth)
    gui.text(screenWidth - 320, 120, "Guide Marker: WIP")
end


-- Walkthrough popup widget
function widgets.drawWalkthroughPopup(screenWidth, screenHeight)
    gui.text(screenWidth - 480, screenHeight - 140, "Walkthrough")
    gui.text(screenWidth - 480, screenHeight - 120,
        "Open OoT wiki / guide in browser")
end


return widgets