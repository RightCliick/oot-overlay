local stages = {}

stages.currentStage = "kokiri_start"

stages.stageContent = {
    kokiri_start = { -- on start of game
        objective = "Talk to Kokiri and get ready to visit the Great Deku Tree.",
        hint = "You will need equipment before moving forward.",
        marker = "Village center"
    },

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

function stages.readGameState()
    local state = {}

    state.entranceIndex = 0
    state.savedSceneIndex = 0
    state.hasSword = false
    state.hasShield = false

    return state
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

function stages.updateCurrentStage()
    local state = stages.readGameState()
    stages.currentStage = stages.determineStage(state)
    return state
end

return stages