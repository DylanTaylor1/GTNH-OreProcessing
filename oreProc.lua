local component = require('component')
local sides = require('sides')
local oreList = require('oreList')
local transposers = {}
local transposerSides = {}
local orientation = 'West'
local targetInv

-- ==================== SETUP =====================

local function findTransposers()
    for address in component.list('transposer') do
        table.insert(transposers, component.proxy(component.get(address)))
    end
end


local function setSides()
    if orientation == 'North' then
        transposerSides[1] = sides.north
        transposerSides[2] = sides.west
        transposerSides[3] = sides.south
        transposerSides[4] = sides.south
        transposerSides[5] = sides.east
        transposerSides[6] = sides.north
        -- transposerSides[7] = sides.up
        -- transposerSides[8] = sides.up
        transposerSides['work'] = {sides.east, sides.west}
    elseif orientation == 'South' then
        transposerSides[1] = sides.south
        transposerSides[2] = sides.east
        transposerSides[3] = sides.north
        transposerSides[4] = sides.north
        transposerSides[5] = sides.west
        transposerSides[6] = sides.south
        -- transposerSides[7] = sides.up
        -- transposerSides[8] = sides.up
        transposerSides['work'] = {sides.west, sides.east}
    elseif orientation == 'East' then
        transposerSides[1] = sides.east
        transposerSides[2] = sides.north
        transposerSides[3] = sides.west
        transposerSides[4] = sides.west
        transposerSides[5] = sides.south
        transposerSides[6] = sides.east
        -- transposerSides[7] = sides.up
        -- transposerSides[8] = sides.up
        transposerSides['work'] = {sides.south, sides.north}
    elseif orientation == 'West' then
        transposerSides[1] = sides.east
        transposerSides[2] = sides.south
        transposerSides[3] = sides.west
        transposerSides[4] = sides.up
        transposerSides[5] = sides.east
        transposerSides[6] = sides.north
        transposerSides[7] = sides.west
        transposerSides[8] = sides.up
        transposerSides['work'] = {sides.north, sides.south}
    end
end

-- =================== LOOPING ====================

local function checkInventory(inventory)
    local item
    local toUse

    -- No Transposers Found
    if transposers[1] == nil or transposers[2] == nil then
        return nil
    end

    -- Look at Working Inventory
    if inventory == 0 then
        item = transposers[1].getStackInSlot(transposerSides['work'][1], 1)
        -- print(output)

    -- Look at Target Inventory with Transposer 1
    elseif inventory <= 4 then
        item = transposers[1].getStackInSlot(transposerSides[inventory], 1)
        toUse = 1

    -- Look at Target Inventory with Transposer 2
    else
        item = transposers[2].getStackInSlot(transposerSides[inventory], 1)
        toUse = 2
    end

    -- An Item is Present
    return {item, toUse}
end


local function searchFilter(keyword)
    for ID, entry in pairs(oreList) do
        if entry.name == keyword then
            return ID
        end
    end
    return false
end


local function checkDatabase()

    -- Check Working Inventory
    local item, _ = table.unpack(checkInventory(0))

    -- If Item is Present and in Filter
    local F = searchFilter(item.label)
    if item and F then
        return oreList[F].filter
    elseif item then
        print(string.format('No Filter: %s', item.label))
        return 8
    end
    return false
end


local function moveItem(targetInv)
    local used, toUse = table.unpack(checkInventory(targetInv))
    if not used then
        transposers[toUse].transferItem(transposerSides['work'][toUse], transposerSides[targetInv])
        return true
    end
    return false
end

-- ===================== MAIN =====================

local function init()
    findTransposers()
    setSides()
end


local function main()
    init()

    while true do
        targetInv = checkDatabase()
        if targetInv then
            moveItem(targetInv)
        end
    end
end

main()