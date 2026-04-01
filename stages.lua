local stages = {}

stages.stageList = {
    {
        objective = "Talk to Mido!", -- State 1
        hint = "Find Mido and interact with him!",
        markerX = 0.42,
        markerY = 0.62
    },

    {
        objective = "Find the sword!", -- State 2
        hint = "Find the sword training area, and explore the maze!",
        markerX = 0.16,
        markerY = 0.72
    },

    {
        objective = "Buy the shield!", -- State 3
        hint = "Explore the village to acquire 40 rupees!",
        markerX = 0.36,
        markerY = 0.42
    },

    {
        objective = "Talk to Mido again!", -- State 4
        hint = "Go back to Mido!",
        markerX = 0.42,
        markerY = 0.62
    }
}

stages.currentIndex = 1

function stages.getCurrentObjective()
    return stages.stageList[stages.currentIndex].objective
end

function stages.getCurrentHint()
    return stages.stageList[stages.currentIndex].hint
end

function stages.getCurrentMarkerPosition()
    local stage = stages.stageList[stages.currentIndex]
    return stage.markerX, stage.markerY
end

function stages.nextStage()
    if stages.currentIndex < #stages.stageList then
        stages.currentIndex = stages.currentIndex + 1
    end
end

function stages.previousStage()
    if stages.currentIndex > 1 then
        stages.currentIndex = stages.currentIndex - 1
    end
end

return stages