local GRAVITY_EFFECT_ID = 1227  -- 光效 ID
local GRAVITY_AREA_SIZE = {x = 10, y = 4, z = 10}  -- 重力异常区域尺寸

-- **重力施加方向的系数**
local GRAVITY_FORCE_DOWN = -10  -- 向下重力（超重力）
local GRAVITY_FORCE_UP = 1     -- 向上重力（反重力）

-- **重力异常区域**
local function createGravityField(event)
    local playerId = event.eventobjid
    local result, itemid = Player:getCurToolID(playerId)  -- 获取玩家使用的道具ID

    -- **获取玩家快捷栏索引**
    local result, scutIdx = Player:getCurShotcut(playerId)

    -- **判断超重力场和反重力场**
    local gravityEffect = GRAVITY_FORCE_DOWN  -- 默认超重力场
    if scutIdx >= 3 and scutIdx <= 7 then
        gravityEffect = GRAVITY_FORCE_UP  -- 如果快捷栏是4到8，设置为反重力场
    end

    -- **获取玩家位置**
    local result, px, py, pz = Actor:getPosition(playerId)
    if result ~= 0 then return end  -- 获取失败则返回
    local dirx, diry, dirz = Actor:getFaceDirection(playerId)
    local gx = math.floor(px + dirx * 2) - GRAVITY_AREA_SIZE.x / 2
    local gy = math.floor(py)
    local gz = math.floor(pz + dirz * 2) - GRAVITY_AREA_SIZE.z / 2
    local effectPositions = {}
    -- **在 5x5 范围内生成光效**
    for i = 0, GRAVITY_AREA_SIZE.x - 1 do
        for j = 0, GRAVITY_AREA_SIZE.z - 1 do
            local ex, ez = gx + i, gz + j
            World:playParticalEffect(ex, gy, ez, GRAVITY_EFFECT_ID, 1, 300, true)
            table.insert(effectPositions, {x = ex, y = gy, z = ez})
        end
    end

    local startTime = os.time()
    -- **持续施加重力**
    while os.time() - startTime < 30 do  -- 持续时间为 15 秒
        threadpool:wait(0.1)  -- 每 0.5 秒检查一次

        -- 查找范围内的玩家和生物
        local areaStart = {x = gx, y = gy +2, z = gz}
        local areaEnd = {x = gx + GRAVITY_AREA_SIZE.x - 1, y = gy + GRAVITY_AREA_SIZE.y, z = gz + GRAVITY_AREA_SIZE.z - 1}
        local resultPlayers, playerIds = Area:getAllObjsInAreaRange(areaStart, areaEnd, 1)
        local resultMobs, mobIds = Area:getAllObjsInAreaRange(areaStart, areaEnd, 2)
        
        
        local areaStart1 = {x = gx, y = gy -1, z = gz}
        local areaEnd1 = {x = gx + GRAVITY_AREA_SIZE.x - 1, y = gy + GRAVITY_AREA_SIZE.y, z = gz + GRAVITY_AREA_SIZE.z - 1}
        local result3, shoot = Area:getAllObjsInAreaRange(areaStart1, areaEnd1, 3)
        local result4, drop = Area:getAllObjsInAreaRange(areaStart1, areaEnd1, 4)
        -- 对玩家施加重力
        for _, objid in ipairs(playerIds or {}) do
            Actor:appendSpeed(objid, 0, gravityEffect, 0)
        end

        -- 对生物施加重力
        for _, objid in ipairs(mobIds or {}) do
            Actor:appendSpeed(objid, 0, gravityEffect, 0)
        end
        for _, objid in ipairs(shoot or {}) do
            Actor:appendSpeed(objid, 0, gravityEffect, 0)
        end
        for _, objid in ipairs(drop or {}) do
            Actor:appendSpeed(objid, 0, gravityEffect, 0)
        end
    end
    for _, pos in ipairs(effectPositions) do
        World:stopEffectOnPosition(pos.x, pos.y, pos.z, GRAVITY_EFFECT_ID)
    end

    Chat:sendSystemMsg("重力异常区域消失！", playerId)
end

-- **注册事件监听**
ScriptSupportEvent:registerEvent([=[Player.UseItem]=], createGravityField)
