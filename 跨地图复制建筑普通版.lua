--作者：B站UP--王者巅峰--，仅供学习，严禁商用。
local CHAR_MAP = {
    [0] = "A", [1] = "B", [2] = "C", [3] = "D", [4] = "E",
    [5] = "F", [6] = "G", [7] = "H", [8] = "I", [9] = "J",
    [10] = "K", [11] = "L", [12] = "M", [13] = "N", [14] = "O",
    [15] = "P", [16] = "Q", [17] = "R", [18] = "S", [19] = "T",
    [20] = "U", [21] = "V", [22] = "W", [23] = "X", [24] = "Y",
    [25] = "Z"
}

local function numToChar(num)
    return CHAR_MAP[num % 26] or "A" 
end

local function exportBlocks(event)
    -- **获取玩家当前位置作为基准点**
    local playerId = event.eventobjid
    local result, px, py, pz = Actor:getPosition(playerId)
    if result ~= 0 then return end

    -- **定义区域范围（相对玩家位置）**
    local AREA_SIZE = {x = 20, y = 10, z = 20} 

    -- **存储方块数据**
    local blockData = {}

    -- **遍历区域，获取方块 ID**
    for dx = 0, AREA_SIZE.x - 1 do
        for dy = 0, AREA_SIZE.y - 1 do
            for dz = 0, AREA_SIZE.z - 1 do
                local x, y, z = px + dx, py + dy, pz + dz
                local result, blockId = Block:getBlockID(x, y, z)
                if blockId ~= 0 then
                    local charX = numToChar(dx)
                    local charY = numToChar(dy)
                    local charZ = numToChar(dz)
                    table.insert(blockData, charX .. charY .. charZ .. tostring(blockId))
                end
            end
        end
    end

    local compressedData = table.concat(blockData, ";") -- **用";"分隔**
    print(compressedData)
    Chat:sendSystemMsg("方块数据已导出，请复制粘贴到粘贴脚本使用。", playerId)
    Customui:setText(event.eventobjid, "7474446149803672154-22859", "7474446149803672154-22859_4", compressedData)
end
ScriptSupportEvent:registerEvent([=[Player.UseItem]=], exportBlocks)