local function f(e)
    Actor:playBodyEffectById(e.eventobjid,1497,3,25)
    for i=0,500 do
        threadpool:wait(0.02)
        local result,x,y,z=Player:getPosition(e.eventobjid)
        local result1,num,objids=World:getActorsByBox(4,x-5,y-5,z-5,x+5,y+5,z+5)
        local result2,num1,objids2=World:getActorsByBox(1,x-5,y-5,z-5,x+5,y+5,z+5)
        local result3,num2,objids3=World:getActorsByBox(2,x-5,y-5,z-5,x+5,y+5,z+5)
        if num>0 then
            for k,v in pairs(objids) do
                local result,dirx,diry,dirz=Actor:getFaceDirection(v)
                Actor:turnFaceYaw(v,150)
                Actor:appendSpeed(v,dirx*-5.5,diry*-5.5,dirz*-5.5)
            end
        end
        if num2>0 then
            for k,v in pairs(objids3) do
                local result,dirx1,diry1,dirz1=Actor:getFaceDirection(v)
                Actor:appendSpeed(v,dirx1*-0.2,diry1*-0.2,dirz1*-0.2)
                Buff:addBuff(v, 33, 2, 10)
            end
        end
        if num1>0 then
            for k,v in pairs(objids2) do
                local result,dirx1,diry1,dirz1=Actor:getFaceDirection(v)
                Actor:appendSpeed(v,dirx1*-0.2,diry1*-0.2,dirz1*-0.2)
                Actor:appendSpeed(e.eventobjid,dirx1*0.2,diry1*0.2,dirz1*0.2)
                    Buff:addBuff(v, 33, 2, 10)
            end
        end
        Buff:clearAllBadBuff(e.eventobjid)
    end
end
ScriptSupportEvent:registerEvent([=[Player.UseItem]=],f)