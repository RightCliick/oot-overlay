local stages = {}

stages.currentStage = "need_sword"

stages.stageContent = {
    need_sword = {
        objective = "Find the Kokiri Sword.",
        hint = "Check the training area maze for something useful.",
        marker = "Sword training area"
    },

    need_shield = {
        objective = "Get a Deku Shield.",
        hint = "The shop may have the equipment you need.",
        marker = "Kokiri Shop"
    },

    ready_for_deku_tree = {
        objective = "Go to the Great Deku Tree.",
        hint = "You now have what you need to continue.",
        marker = "Great Deku Tree entrance"
    }
}

function stages.getCurrentObjective()
    return stages.stageContent[stages.currentStage].objective
end

function stages.getCurrentHint()
    return stages.stageContent[stages.currentStage].hint
end

function stages.getCurrentMarker()
    return stages.stageContent[stages.currentStage].marker
end

function stages.determineStage(state)
    if not state.hasSword then
        return "need_sword"
    elseif not state.hasShield then
        return "need_shield"
    else
        return "ready_for_deku_tree"
    end
end

function stages.updateCurrentStage(state)
    stages.currentStage = stages.determineStage(state)
end

return stages