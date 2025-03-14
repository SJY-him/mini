local MAX_SPLIT = 3--最大分裂次数
local PROJECTILE_SPEED = 150--投掷物发射速度
local SPLIT_INTERVAL = 0.01
local missile_splits = {}
local function Missile_Create(event)
    local objid = event.toobjid 
    local shooter = event.eventobjid 
    if not objid or not shooter then return end
    -- 获取当前投掷物的位置
    local result, x, y, z = Actor:getPosition(objid)
    if result ~= 0 then return end
    -- 获取当前投掷物的分裂次数
    local split_count = missile_splits[objid] or 0
    -- 超过最大分裂次数就不再分裂
    if split_count >= MAX_SPLIT then return end
    local result, dirx, diry, dirz = Actor:getFaceDirection(shooter)
    if result ~= 0 then return end
    threadpool:wait(SPLIT_INTERVAL)
    local result, x, y, z = Actor:getPosition(objid)
    if result ~= 0 then return end
    -- 进行分裂
    local num_splits = math.random(5, 6) -- 随机生成3~5个子弹
    for i = 1, num_splits do
        local code, new_objid = World:spawnProjectileByDir(
            shooter,  
            12285, 
            x+math.random(-0.5,0.5), y+math.random(-0.5,0.5), z+math.random(-0.5,0.5),   -- 起点
            dirx, diry, dirz,
            PROJECTILE_SPEED )
        -- 记录新投掷物的分裂次数
        if code == 0 and new_objid then
            missile_splits[new_objid] = split_count + 1
        end
    end
    World:despawnActor(objid)
end
ScriptSupportEvent:registerEvent([=[Missile.Create]=], Missile_Create)