local widgets = {}

-- Objective widget
function widgets.drawObjective(stages)
    gui.text(screenWidth * 0.07, screenHeight * 0.12, "Objective: " .. stages.getCurrentObjective())
end


-- Hint widget
function widgets.drawHint(stages, screenHeight)
    gui.text(screenWidth * 0.07, screenHeight * 0.80, "Hint: " .. stages.getCurrentHint())
end


-- Guide marker label (not the marker itself)
function widgets.drawGuideMarkerLabel(screenWidth)
    gui.text(screenWidth * 0.83, screenHeight * 0.64, "Guide Marker: ACTIVE")
end


-- Walkthrough popup widget
function widgets.drawWalkthroughPopup(screenWidth, screenHeight)
    gui.text(screenWidth - 480, screenHeight - 140, "Walkthrough")
    gui.text(screenWidth - 480, screenHeight - 120,
        "Open OoT wiki / guide in browser")
end


return widgets