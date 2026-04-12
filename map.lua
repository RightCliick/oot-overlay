local map = {}

function map.getMapConstraint(screenWidth, screenHeight)
    local mapWidth = screenWidth * 0.26
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

function map.drawStageMarker(screenWidth, screenHeight, stages)
    local constraint = map.getMapConstraint(screenWidth, screenHeight)
    local markerXPercent, markerYPercent = stages.getCurrentMarkerPosition()

    local markerX = constraint.x + (markerXPercent * constraint.width)
    local markerY = constraint.y + (markerYPercent * constraint.height)

    gui.text(markerX, markerY, "!")
end

return map