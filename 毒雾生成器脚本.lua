local POISON_GAS_DURATION = 30 -- 毒雾持续时间
local POISON_GAS_DAMAGE = 10 -- 每秒扣血量
local POISON_GAS_RADIUS = 2 
local POISON_GAS_EFFECT_ID = 1001
local POISON_GAS_UPDATE_INTERVAL = 0.5 
local function createPoisonGas(event)
    local playerId = event.eventobjid
    local result, px, py, pz = Actor:getPosition(playerId)
    local result, dirx, diry, dirz = Actor:getFaceDirection(playerId)
    if result ~= 0 then return end
    local gx = math.floor(px + dirx * 2) - POISON_GAS_RADIUS
    local gy = math.floor(py)
    local gz = math.floor(pz + dirz * 2) - POISON_GAS_RADIUS
    local effectPositions = {}
    -- 在 4×4 范围内生成毒雾特效
    for i = 0, 3 do
        for j = 0, 3 do
            local ex, ez = gx + i, gz + j
            World:playParticalEffect(ex, gy, ez, POISON_GAS_EFFECT_ID, 1, POISON_GAS_DURATION * 30, true)
            table.insert(effectPositions, {x = ex, y = gy, z = ez})
        end
    end
    local startTime = os.time()
    while os.time() - startTime < POISON_GAS_DURATION do
        threadpool:wait(POISON_GAS_UPDATE_INTERVAL) -- 每秒执行
        -- 查找范围内的玩家和生物
        local areaStart = {x = gx, y = gy - 1, z = gz}
        local areaEnd = {x = gx + 3, y = gy + 2, z = gz + 3}
        local resultPlayers, playerIds = Area:getAllObjsInAreaRange(areaStart, areaEnd, 1) -- 获取玩家
        local resultMobs, mobIds = Area:getAllObjsInAreaRange(areaStart, areaEnd, 2) -- 获取生物
        -- 对玩家造成伤害
        for _, objid in ipairs(playerIds or {}) do
            local result,HP=Actor:getHP(objid)
            Actor:addHP(objid,-HP*0.05)
            Actor:addHP(objid, -POISON_GAS_DAMAGE)
            Buff:addBuff(objid, 8, 3, 50)
        end
        -- 对生物造成伤害
        for _, objid in ipairs(mobIds or {}) do
            local result,HP=Actor:getHP(objid)
            Actor:addHP(objid,-HP*0.05)
            Actor:addHP(objid, -POISON_GAS_DAMAGE)
            Buff:addBuff(objid, 8, 3, 50)
        end
    end
    for _, pos in ipairs(effectPositions) do--清除所有的特效
        World:stopEffectOnPosition(pos.x, pos.y, pos.z, POISON_GAS_EFFECT_ID)
    end
end
ScriptSupportEvent:registerEvent([=[Player.UseItem]=], createPoisonGas)