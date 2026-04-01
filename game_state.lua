-- THIS FILE IS NO LONGER IN USE, I DIDNT WANNA DO ANY MORE MEMORY READING STUFF AND I'VE PIVOTED TO MANUAL CHANGING

local game_state = {}

local printedDomains = false

function game_state.printDomainsOnce()
    if printedDomains then
        return
    end

    local domains = memory.getmemorydomainlist()
    print("BizHawk memory domains:")
    for i, domain in ipairs(domains) do
        print(i, domain)
    end

    printedDomains = true
end

function game_state.read()
    local state = {}

    local swordShieldByte = 0x00

    state.rawSwordShield = swordShieldByte
    state.hasSword = (swordShieldByte & 0x01) ~= 0
    state.hasShield = (swordShieldByte & 0x10) ~= 0

    return state
end

return game_state