--脚本由迷你世界王者——制作，迷你号：64324186，盗版必究！
local gradients3D = {
    {1, 1, 0}, {-1, 1, 0}, {1, -1, 0}, {-1, -1, 0}, 
    {1, 0, 1}, {-1, 0, 1}, {1, 0, -1}, {-1, 0, -1},
    {0, 1, 1}, {0, -1, 1}, {0, 1, -1}, {0, -1, -1}  
}
local perm = {}
for i = 0, 255 do
    perm[i] = math.random(0, 255)
end
for i = 0, 255 do
    perm[256 + i] = perm[i]
end
local function fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end
local function lerp(a, b, t)
    return a + t * (b - a)
end
local function grad3(hash, x, y, z)
    local g = gradients3D[(hash % #gradients3D) + 1]
    return g[1] * x + g[2] * y + g[3] * z
end
local function perlin3D(x, y, z)
    local X = math.floor(x) % 256
    local Y = math.floor(y) % 256
    local Z = math.floor(z) % 256

    local xf = x - math.floor(x)
    local yf = y - math.floor(y)
    local zf = z - math.floor(z)

    -- 计算平滑插值值
    local u = fade(xf)
    local v = fade(yf)
    local w = fade(zf)

    -- 计算顶点哈希值
    local aaa = perm[perm[perm[X] + Y] + Z]
    local aba = perm[perm[perm[X] + Y + 1] + Z]
    local aab = perm[perm[perm[X] + Y] + Z + 1]
    local abb = perm[perm[perm[X] + Y + 1] + Z + 1]
    local baa = perm[perm[perm[X + 1] + Y] + Z]
    local bba = perm[perm[perm[X + 1] + Y + 1] + Z]
    local bab = perm[perm[perm[X + 1] + Y] + Z + 1]
    local bbb = perm[perm[perm[X + 1] + Y + 1] + Z + 1]
    local x1 = lerp(grad3(aaa, xf, yf, zf), grad3(baa, xf - 1, yf, zf), u)
    local x2 = lerp(grad3(aba, xf, yf - 1, zf), grad3(bba, xf - 1, yf - 1, zf), u)
    local y1 = lerp(x1, x2, v)
    local x3 = lerp(grad3(aab, xf, yf, zf - 1), grad3(bab, xf - 1, yf, zf - 1), u)
    local x4 = lerp(grad3(abb, xf, yf - 1, zf - 1), grad3(bbb, xf - 1, yf - 1, zf - 1), u)
    local y2 = lerp(x3, x4, v)

    -- 返回最终插值结果
    return lerp(y1, y2, w)
end
local function f(e)
    -- 获取玩家当前位置
    local x, z = 0, 0
    -- 地形参数
    local CHUNK_RADIUS = 90
    local HEIGHT_SCALE = 20
    local GROUND_LEVEL = 15
    local BLOCK_GRASS = 100
    local BLOCK_DIRT = 104
    local BLOCK_AIR = 0
    local MINERAL_IDS = {400, 401, 402, 403, 404, 405, 406, 407,445,446,451,452,453,454,455,598,5} -- 矿物ID列表
    
    
    local flower={150049,150050,150051,150052,150053,150054,150055,150056,150057,150058,150059,150060,150061,150062,150063,150064,150065,300,301,302,303,304,305,307,308,309,310,311,312,313,234,737,243,110}
    local flowerP=0.02
    local MINERAL_PROBABILITY = 0.03 -- 矿物生成概率
    local min = 0.1
    local result, px, py, pz = Actor:getPosition(e.eventobjid)

    -- 计算生成范围
    local startX = math.floor(px) - CHUNK_RADIUS
    local endX = math.floor(px) + CHUNK_RADIUS
    local startZ = math.floor(pz) - CHUNK_RADIUS
    local endZ = math.floor(pz) + CHUNK_RADIUS

    for x = startX, endX do
        for z = startZ, endZ do
            local noiseValue = perlin3D(x / HEIGHT_SCALE, 0, z / HEIGHT_SCALE)
            local height = math.floor(noiseValue * HEIGHT_SCALE) + GROUND_LEVEL

             for y = 0, height do
                if y == height then
                    -- 顶层为草块
                    Block:setBlockAll(x, y, z, BLOCK_GRASS, 0)
                    if math.random() < flowerP then
                        local flowerid = flower[math.random(1, #flower)] 
                        Block:setBlockAll(x, y+1, z, flowerid, 0) -- 设置植物
                    end
                elseif y >= height - 3 then
                    -- 草块下面两层为土块
                    Block:setBlockAll(x, y, z, 101, 0)
                elseif y <= height - 4 then
                    -- 石块层和矿物生成逻辑
                    if math.random() < MINERAL_PROBABILITY then
                        local mineralID = MINERAL_IDS[math.random(1, #MINERAL_IDS)] -- 随机选择矿物ID
                        Block:setBlockAll(x, y, z, mineralID, 0) -- 设置矿物方块
                    elseif math.random() < min then
                        Block:setBlockAll(x, y, z, 107, 0)
                    else
                        Block:setBlockAll(x, y, z, BLOCK_DIRT, 0) -- 普通石块
                    end
                end
            end
            for y = height + 1, GROUND_LEVEL + HEIGHT_SCALE do
                Block:setBlockAll(x, y, z, BLOCK_AIR, 0) -- 空气方块
            end
        end
    end

    -- 将玩家传送到高空观察生成的地形
    Actor:setPosition(e.eventobjid, px, py + 40, pz)
    local result, areaid = Area:createAreaRect({x = px, y = py + 4, z = pz}, {x = CHUNK_RADIUS, y = 1, z = CHUNK_RADIUS})
    Area:fillBlock(areaid, 4, 0)
    for i = 1, 30 do
        threadpool:wait(0.1)
        World:spawnProjectile(e.eventobjid, 12282, px, py + 100, pz, px + math.random(-CHUNK_RADIUS, CHUNK_RADIUS), py, pz + math.random(-CHUNK_RADIUS, CHUNK_RADIUS), 5000)
    end
end
ScriptSupportEvent:registerEvent([=[Player.UseItem]=], f)



local obj={}
BLOCK_AIR = 0
BLOCK_LOG = 200       -- 树干
BLOCK_LEAVES = 218    -- 树叶
local function generateTree(x, y, z)
    -- 树干的随机高度
    trunkHeight = math.random(5, 7)
    
    -- 生成树干
    for i = 0, trunkHeight - 1 do
        Block:setBlockAll(x, y + i, z, BLOCK_LOG, 0)
    end
    -- 树叶半径
    local leafRadius = 3
    for dx = -leafRadius, leafRadius do
        for dy = -leafRadius, leafRadius do
            for dz = -leafRadius, leafRadius do
                local distance = math.sqrt(dx * dx + dy * dy + dz * dz)
                if distance <= leafRadius then
                    local leafX = x + dx
                    local leafY = y + trunkHeight + dy - 1
                    local leafZ = z + dz
                    if not (dx == 0 and dz == 0 and dy <= 0) then
                        Block:setBlockAll(leafX, leafY, leafZ, BLOCK_LEAVES, 0)
                    end
                end
            end
        end
    end
end
local function crt(e)
		obj[e.toobjid]=e.eventobjid
end
ScriptSupportEvent:registerEvent([=[Missile.Create]=],crt)
local function hit(e)
    if obj[e.eventobjid]~=nil then
        kjl=math.random(0,7)
        if kjl==0 then
            BLOCK_LOG = 200       -- 树干
            BLOCK_LEAVES = 218    -- 树叶
        elseif kjl==1 then
            BLOCK_LOG = 201       -- 树干
            BLOCK_LEAVES = 219    -- 树叶
        elseif kjl==2 then
            BLOCK_LOG = 202       -- 树干
            BLOCK_LEAVES = 220    -- 树叶
        elseif kjl==3 then
            BLOCK_LOG = 203       -- 树干
            BLOCK_LEAVES = 221    -- 树叶
        elseif kjl==4 then
            BLOCK_LOG = 205       -- 树干
            BLOCK_LEAVES = 223    -- 树叶
        elseif kjl==5 then
            BLOCK_LOG = 254       -- 树干
            BLOCK_LEAVES = 255    -- 树叶
        elseif kjl==6 then
            BLOCK_LOG = 200390       -- 树干
            BLOCK_LEAVES = 200391    -- 树叶
        elseif kjl==7 then
            BLOCK_LOG = 151019       -- 树干
            BLOCK_LEAVES = 151018    -- 树叶
        end
        threadpool:wait(1)
        generateTree(math.floor(e.x), math.floor(e.y+1), math.floor(e.z))
        for m=0,4 do
            local result,objids=World:spawnCreature(e.x,e.y+1,e.z-1,math.random(3400,3403),1)
        end
        obj[e.eventobjid]=nil
	end
end
ScriptSupportEvent:registerEvent([=[Actor.Projectile.Hit]=],hit)