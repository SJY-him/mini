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
    x,z=0,0
    -- 地形参数
    CHUNK_RADIUS = 50 
    HEIGHT_SCALE = 25 
    GROUND_LEVEL = 15
    BLOCK_GRASS = 100 
    BLOCK_DIRT = 104 
    BLOCK_AIR = 0
    local result,px,py,pz=Actor:getPosition(0)
    -- 计算生成范围
    local startX = math.floor(px) - CHUNK_RADIUS
    local endX = math.floor(px) + CHUNK_RADIUS
    local startZ = math.floor(pz) - CHUNK_RADIUS
    local endZ = math.floor(pz) + CHUNK_RADIUS
    for x = startX, endX do
        for z = startZ, endZ do
            local noiseValue = perlin3D(x / HEIGHT_SCALE, 0, z / HEIGHT_SCALE)
            local height = math.floor(noiseValue * HEIGHT_SCALE) + GROUND_LEVEL
            -- 设置地形方块
            for y = 0, height do
                --threadpool:wait(0.1)
                if y <= height-4 then
                    Block:setBlockAll(x, y, z, BLOCK_DIRT, 0)--石头填充
                else
                    Block:setBlockAll(x, y, z, BLOCK_GRASS, 0) -- 表层草方块
                end
            end
            for y = height + 1, GROUND_LEVEL + HEIGHT_SCALE do
                --threadpool:wait(0.1)
                Block:setBlockAll(x, y, z, BLOCK_AIR, 0)--空气方块
            end
        end
    end
end
ScriptSupportEvent:registerEvent([=[Player.UseItem]=], f)