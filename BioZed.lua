-- Zed Script --
 
if VIP_USER then
        PrintChat("Dont forgot to give me feedback :)If u want to support me,VIP will be appreciated.")
else
        PrintChat("<font color=\"#FF0000\" >>Zed By Lucas<</font> ")
end
 
local   RREADY, QREADY, WREADY, EREADY
local   ts
local   prediction
 
if myHero.charName ~= "Zed" then return end
 
function OnLoad()
        LoadMenu()
        LoadVariables()
        Ignite()
				for i=1, heroManager.iCount do
                local champ = heroManager:GetHero(i)
                if champ.team ~= myHero.team then
                        EnemysInTable = EnemysInTable + 1
                        EnemyTable[EnemysInTable] = { hero = champ, Name = champ.charName, p = 0, q = 0, q2 = 0, e = 0, r = 0, IndicatorText = "", IndicatorPos, NotReady = false, Pct = 0}
                end
        end
        PrintFloatText(myHero,11,"LETS RAPE >:D !")
end
 
function LoadMenu()
        Config = scriptConfig("Zed by Lucas", "Die")
        Config:addParam("Fight", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
        Config:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
        Config:addParam("AutoE", "Auto E", SCRIPT_PARAM_ONOFF, true)
				Config:addParam("sep", "----- [ KS Settings ] -----", SCRIPT_PARAM_INFO, "")
        Config:addParam("autoIgnite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
				Config:addParam("sep", "----- [ Draw Settings ] -----", SCRIPT_PARAM_INFO, "")
        Config:addParam("DmgIndic","Kill text", SCRIPT_PARAM_ONOFF, true)
        Config:addParam("Edraw", "Draw E", SCRIPT_PARAM_ONOFF, true)
        Config:addParam("Qdraw", "Draw Q", SCRIPT_PARAM_ONOFF, true)
        Config:addParam("Movement", "Move To Mouse", SCRIPT_PARAM_ONOFF, true)
				Config:addSubMenu("Combo Settings", "ComboS")
        Config.ComboS:addParam("SwapUlt","Swap back with ult if hp < %", SCRIPT_PARAM_SLICE, 15, 2, 100, 0)
        Config.ComboS:addParam("NoWWhenUlt","Don't use W when Zed ult", SCRIPT_PARAM_ONOFF, true)
        Config:permaShow("Fight")
        Config:permaShow("Harass")
        ts = TargetSelector(TARGET_LOW_HP_PRIORITY, 1190, DAMAGE_PHYSICAL, true)
        ts.name = "Zed"
        Config:addTS(ts)
end
 
function LoadVariables()
        wClone, rClone = nil, nil
				RREADY, QREADY, WREADY, EREADY = false, false, false, false
        ignite = nil
        lastW = 0
        delay, qspeed = 235, 1.742

				        --Helpers
        lastAttack, lastWindUpTime, lastAttackCD, lastAnimation  = 0, 0, 0, ""
        EnemyTable = {}
        EnemysInTable = 0
        HealthLeft = 0
        PctLeft = 0
        BarPct = 0
        orange = 0xFFFFE303
        green = ARGB(255,0,255,0)
        blue = ARGB(255,0,0,255)
        red = ARGB(255,255,0,0)
end
 
function OnUnload()
        PrintFloatText(myHero,9,"U NO RAPE ?! :,( ")
end
 
function OnTick()
        ts:update()
				Calculations()
				GlobalInfos()
				        for i = 1, heroManager.iCount, 1 do
        local enemyhero = heroManager:getHero(i)
                if enemyhero.team ~= myHero.team and TargetHaveBuff("zedulttargetmark", enemyhero) then        
                        ts.target = enemyhero
                end
        end
        SetCooldowns() 
        if ValidTarget(ts.target) then
                if Config.AutoE then autoE() end
                prediction = qPred()
                if Config.Fight then Fight() end
                if Config.Harass then Harass() end
                if Config.autoIgnite then autoIgnite() end
        end
        if ts.target == nil and Config.Fight and Config.Movement then
                myHero:MoveTo(mousePos.x, mousePos.z)
        end
end

function autoIgnite()
        if Config.autoIgnite then
                if iReady then
                        local ignitedmg = 0
                        for i = 1, heroManager.iCount, 1 do
                                local enemyhero = heroManager:getHero(i)
                                        if ValidTarget(enemyhero,600) then
                                                ignitedmg = 50 + 20 * myHero.level
                                                if enemyhero.health <= ignitedmg then
                                                        CastSpell(ignite, enemyhero)
                                                end
                                        end
                        end
                end
        end
end
 
function OnDraw()
 if Config.Qdraw then
                if QREADY then
                        DrawCircle(myHero.x, myHero.y, myHero.z, 900, ARGB(255,0,255,0))
                else
                        DrawCircle(myHero.x, myHero.y, myHero.z, 900, ARGB(255,255,0,0))
                end
        end
        if Config.Edraw then
                if EREADY then
                        DrawCircle(myHero.x, myHero.y, myHero.z, 290, ARGB(255,0,255,0))
                else
                        DrawCircle(myHero.x, myHero.y, myHero.z, 290, ARGB(255,255,0,0))
                end
        end
 
 
        if Config.DmgIndic then
                for i=1, EnemysInTable do
                        local enemy = EnemyTable[i].hero
                        if ValidTarget(enemy) then
--                              enemy.barData = GetEnemyBarData()
                                local barPos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
                local PosX = barPos.x - 35
                local PosY = barPos.y - 50
--                              local barPosOffset = GetUnitHPBarOffset(enemy)
--                              local barOffset = { x = enemy.barData.PercentageOffset.x, y = enemy.barData.PercentageOffset.y }
--                              local barPosPercentageOffset = { x = enemy.barData.PercentageOffset.x, y = enemy.barData.PercentageOffset.y }
--                              local BarPosOffsetX = 171
--                              local BarPosOffsetY = 46
--                              local CorrectionY =  14.5
--                              local StartHpPos = 31
--                              local IndicatorPos = EnemyTable[i].IndicatorPos
                                local Text = EnemyTable[i].IndicatorText
--                              barPos.x = barPos.x + (barPosOffset.x - 0.5 + barPosPercentageOffset.x) * BarPosOffsetX + StartHpPos
--                              barPos.y = barPos.y + (barPosOffset.y - 0.5 + barPosPercentageOffset.y) * BarPosOffsetY + CorrectionY
                                if EnemyTable[i].NotReady == true then
               
                                        DrawText(tostring(Text),15,PosX ,PosY  ,orange)
--                                      DrawText("|",13,barPos.x+IndicatorPos ,barPos.y ,orange)
--                                      DrawText("|",13,barPos.x+IndicatorPos ,barPos.y-9 ,orange)
--                                      DrawText("|",13,barPos.x+IndicatorPos ,barPos.y-18 ,orange)
                                else
                                        DrawText(tostring(Text),15,PosX ,PosY ,ARGB(255,0,255,0))      
--                                      DrawText("|",13,barPos.x+IndicatorPos ,barPos.y ,ARGB(255,0,255,0))
--                                      DrawText("|",13,barPos.x+IndicatorPos ,barPos.y-9 ,ARGB(255,0,255,0))
--                                      DrawText("|",13,barPos.x+IndicatorPos ,barPos.y-18 ,ARGB(255,0,255,0))
                                end
                        end
                end
        end
end
 
function OnProcessSpell(unit, spell)
        if unit.isMe and spell.name == "ZedShadowDash" then
                lastW = GetTickCount()
        end
end
 
function Fight()
  if RREADY then CastR(ts.target) end
        if not RREADY or rClone ~= nil then
                if myHero:GetSpellData(_W).name ~= "zedw2" and WREADY and ((GetDistance(ts.target) < 700) or (GetDistance(ts.target) > 125 and not RREADY)) then
                        if not (Config.ComboS.NoWWhenUlt and ((myHero:GetSpellData(_R).name == "ZedR2") or (rClone ~= nil and rClone.valid))) then
                                CastSpell(_W, ts.target.x, ts.target.z)
                        end
                end
                if not WREADY or wClone ~= nil or Config.ComboS.NoWWhenUlt then qPred()  
                        if EREADY then  
                                if ValidTarget(ts.target) then    
                                       autoE()
                                end
                        end
                        if QREADY then  
                                if prediction ~= nil and GetDistance(prediction) < 900 then
                                        CastSpell(_Q, prediction.x, prediction.z)
                                end
                        end
                end
        end
        

        CastItems(ts.target)
       
        if not QREADY and not EREADY then
                local wDist = 0
                local rDist = 0
                if wClone and wClone.valid then wDist = GetDistance(ts.target, wClone) end
                if rClone and rClone.valid then rDist = GetDistance(ts.target, rClone) end     
                if GetDistance(ts.target) > 125 then
                        if wDist < rDist and wDist ~= 0 and GetDistance(ts.target) > wDist then
                                CastSpell(_W)
                        elseif rDist < wDist and rDist ~= 0 and GetDistance(ts.target) > rDist then
                                CastSpell(_R)

                        end
                end
        end
				if myHero:GetSpellData(_R).name == "ZedR2" and ((myHero.health / myHero.maxHealth * 100) <= Config.ComboS.SwapUlt) then
                CastSpell(_R)
        end
        myHero:Attack(ts.target)
end
 
function Harass()
        if prediction ~= nil and (QREADY and WREADY and GetDistance(prediction) < 700) or (QREADY and wClone ~= nil and wClone.valid and GetDistance(prediction, wClone) < 900) then
                if myHero:GetSpellData(_W).name ~= "zedw2" and GetTickCount() > lastW + 1000 then
                        CastSpell(_W, ts.target.x, ts.target.z)
                else
                        CastSpell(_Q, prediction.x, prediction.z)
                end
        elseif QREADY and not WREADY and prediction and GetDistance(prediction) < 900 then
                CastSpell(_Q, prediction.x, prediction.z)
        end
end
 
function autoE()
        local box = 280
        if GetDistance(ts.target, myHero) < box or (wClone ~= nil and wClone.valid and GetDistance(ts.target, wClone) < box) or (rClone ~= nil and rClone.valid and GetDistance(ts.target, rClone) < box) then
                CastSpell(_E)
        else
                for i = 1, heroManager.iCount do
                        local enemy = heroManager:getHero(i)
                        if ValidTarget(enemy) and GetDistance(enemy) < box or (wClone ~= nil and wClone.valid and GetDistance(enemy, wClone) < box) or (rClone ~= nil and rClone.valid and GetDistance(enemy, rClone) < box) then
                                CastSpell(_E)
                        end
                end
        end
end
 
function CastR()
       if not RREADY then return end
        if ValidTarget(ts.target) then
                if GetDistance(ts.target) <= 625 and RREADY and myHero:GetSpellData(_R).name ~= "ZedR2" then
                        CastSpell(_R, ts.target)
                end
        else
                return
        end
end
 
function rUsed()
        if myHero:GetSpellData(_R).name == "ZedR2" then
                return true
        else
                return false
        end
end
function GlobalInfos()
        QREADY = (myHero:CanUseSpell(_Q) == READY)
        WREADY = (myHero:CanUseSpell(_W) == READY)
        EREADY = (myHero:CanUseSpell(_E) == READY)
        RREADY = (myHero:CanUseSpell(_R) == READY)
        QMana = myHero:GetSpellData(_Q).mana
        WMana = myHero:GetSpellData(_W).mana
        EMana = myHero:GetSpellData(_E).mana
        RMana = myHero:GetSpellData(_R).mana
       
        MyMana = myHero.mana
       
        TemSlot = GetInventorySlotItem(3153)
        BOTRKREADY = (TemSlot ~= nil and myHero:CanUseSpell(TemSlot) == READY) --Blade Of The Ruined King
       
        TemSlot = GetInventorySlotItem(3144)
        BCREADY = (TemSlot ~= nil and myHero:CanUseSpell(TemSlot) == READY) --Bilgewater Cutlass
       
        TemSlot = GetInventorySlotItem(3074)
        HYDRAREADY = (TemSlot ~= nil and myHero:CanUseSpell(TemSlot) == READY) --Ravenous Hydra
       
        TemSlot = GetInventorySlotItem(3077)
        TIAMATREADY = (TemSlot ~= nil and myHero:CanUseSpell(TemSlot) == READY) --Tiamat
       
        iReady = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
end
function CastItems(target)
        if not ValidTarget(target) then
                return
        else
                if GetDistance(Target) <=500 then
                        CastItem(3144, target) --Bilgewater Cutlass
                        CastItem(3153, target) --Blade Of The Ruined King
                end
                if GetDistance(Target) <= 350 then
                        CastItem(3074, target) --Ravenous Hydra
                        CastItem(3077, target) --Tiamat
                        CastItem(3142, target) --Youmuu's Ghostblade
                end
        end
end  
 
function OnCreateObj(obj)
        if obj.valid and obj.name:find("Zed_Clone_idle.troy") then
                if wClone == nil then
                        wClone = obj
                elseif rClone == nil then
                        rClone = obj
                end
        end
end
 
function OnDeleteObj(obj)
        if obj.valid and wClone and obj == wClone then
                wClone = nil
        elseif obj.valid and rClone and obj == rClone then
                rClone = nil
        end
end
 
function Ignite()
        if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
        elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2
        end
end
 
function SetCooldowns()
        QREADY = (myHero:CanUseSpell(_Q) == READY)
        WREADY = (myHero:CanUseSpell(_W) == READY)
        EREADY = (myHero:CanUseSpell(_E) == READY)
        RREADY = (myHero:CanUseSpell(_R) == READY)
        iReady = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
end
 
function qPred()
        local travelDuration = (delay + GetDistance(myHero, ts.target)/qspeed)
        travelDuration = (delay + GetDistance(GetPredictionPos(ts.target, travelDuration))/qspeed)
        travelDuration = (delay + GetDistance(GetPredictionPos(ts.target, travelDuration))/qspeed)
        travelDuration = (delay + GetDistance(GetPredictionPos(ts.target, travelDuration))/qspeed)      
        if ts.target ~= nil then
                return GetPredictionPos(ts.target, travelDuration)
        end
end
 
function CastItems(target)
        if not ValidTarget(target) then
                return
        else
                if GetDistance(ts.target) <=500 then
                        CastItem(3144, target) --Bilgewater Cutlass
                        CastItem(3153, target) --Blade Of The Ruined King
                end
                if GetDistance(ts.target) <=400 then
                        CastItem(3146, target) --Hextech Gunblade
                end
                if GetDistance(ts.target) <= 350 then
                        CastItem(3184, target) --Entropy
                        CastItem(3143, target) --Randuin's Omen
                        CastItem(3074, target) --Ravenous Hydra
                        CastItem(3131, target) --Sword of the Divine
                        CastItem(3077, target) --Tiamat
                        CastItem(3142, target) --Youmuu's Ghostblade
                end
                if GetDistance(ts.target) <= 1000 then
                        CastItem(3023, target) --Twin Shadows
                end
        end
end

function Calculations()
       
        for i=1, EnemysInTable do
               
                local enemy = EnemyTable[i].hero
                if ValidTarget(enemy) and enemy.visible then
                        caaDmg = getDmg("AD",enemy,myHero)
                        cpDmg = getDmg("P", enemy, myHero)
                        cqDmg = getDmg("Q", enemy, myHero)
                        ceDmg = getDmg("E", enemy, myHero)
                        ciDmg = getDmg("IGNITE", enemy, myHero)
               
                        UltExtraDmg = 0
                        cItemDmg = 0
                        cTotal = 0
       
                        if BCREADY then
                                cItemDmg = cItemDmg + getDmg("BWC", enemy, myHero)
                        end
                        if BOTRKREADY then
                                cItemDmg = cItemDmg + getDmg("RUINEDKING", enemy, myHero, 2)
                        end
                        if HYDRAREADY then
                                cItemDmg = cItemDmg + getDmg("HYDRA", enemy, myHero)
                        end
                        if TIAMATREADY then
                                cItemDmg = cItemDmg + getDmg("TIAMAT", enemy, myHero)
                        end
                       
                        EnemyTable[i].p = cpDmg
                       
                        EnemyTable[i].q = cqDmg
                       
                        if WillQCol then
                                EnemyTable[i].q = EnemyTable[i].q / 2          
                        end
                        EnemyTable[i].q2 = EnemyTable[i].q + (cqDmg / 2)
                       
                        EnemyTable[i].e = ceDmg
                        if RREADY then
                                UltExtraDmg = myHero.totalDamage
                                if WREADY then
                                        UltExtraDmg = UltExtraDmg + (15*myHero:GetSpellData(_R).level+5) * (EnemyTable[i].q2 + EnemyTable[i].e + EnemyTable[i].p + caaDmg)
                                else
                                        UltExtraDmg = UltExtraDmg + (15*myHero:GetSpellData(_R).level+5) * (EnemyTable[i].q + EnemyTable[i].e + EnemyTable[i].p + caaDmg)
                                end
                                UltExtraDmg = myHero:CalcDamage(enemy, UltExtraDmg)
                        end
                        EnemyTable[i].r = UltExtraDmg
                       
                       
                        if enemy.health < EnemyTable[i].e  then
                                EnemyTable[i].IndicatorText = "E Kill"
                                EnemyTable[i].IndicatorPos = 0
                        if not EReady then
                                        EnemyTable[i].NotReady = true
                                else
                                        EnemyTable[i].NotReady = false
                        end    
                elseif enemy.health < EnemyTable[i].q then
                                EnemyTable[i].IndicatorText = "Q Kill"
                                EnemyTable[i].IndicatorPos = 0
                        if not QREADY then
                                        EnemyTable[i].NotReady = true
                                else
                                        EnemyTable[i].NotReady = false
                        end    
                elseif enemy.health < EnemyTable[i].q2 then
                                EnemyTable[i].IndicatorText = "W+Q Kill"
                                EnemyTable[i].IndicatorPos = 0
                        if QMana + WMana > MyMana or not QREADY or not WREADY then
                                        EnemyTable[i].NotReady = true
                                else
                                        EnemyTable[i].NotReady = false
                        end            
                elseif enemy.health < EnemyTable[i].q2 + EnemyTable[i].e then
                                EnemyTable[i].IndicatorText = "W+E+Q Kill"
                                EnemyTable[i].IndicatorPos = 0
                        if QMana + WMana + EMana > MyMana or not QREADY or not WREADY or not EREADY then
                                        EnemyTable[i].NotReady = true
                                else
                                        EnemyTable[i].NotReady = false
                        end
                --elseif enemy.health < EnemyTable[i].q2 + EnemyTable[i].e + EnemyTable[i].p + caaDmg then
                                --EnemyTable[i].IndicatorText = "W+E+Q+AA Kill"
                                --EnemyTable[i].IndicatorPos = 0
                        --if QMana + WMana + EMana > MyMana or not QREADY or not WREADY or not EREADY then
                                        --EnemyTable[i].NotReady = true
                                --else
                                        --EnemyTable[i].NotReady = false
                        --end
                elseif (not RREADY) and enemy.health < EnemyTable[i].q2 + EnemyTable[i].e + EnemyTable[i].p + caaDmg + ciDmg + cItemDmg then
                                EnemyTable[i].IndicatorText = "All In Kill"
                                EnemyTable[i].IndicatorPos = 0
                        if QMana + WMana + EMana > MyMana or not QREADY or not WREADY or not EREADY then
                                        EnemyTable[i].NotReady = true
                                else
                                        EnemyTable[i].NotReady = false
                        end    
                elseif (not WREADY) and enemy.health < EnemyTable[i].q + EnemyTable[i].e + EnemyTable[i].p + EnemyTable[i].r + caaDmg + ciDmg + cItemDmg then
                                EnemyTable[i].IndicatorText = "All In Kill"
                                EnemyTable[i].IndicatorPos = 0
                        if QMana + EMana + RMana > MyMana or not QREADY or not EREADY or not RREADY then
                                        EnemyTable[i].NotReady = true
                                else
                                        EnemyTable[i].NotReady = false
                        end
                elseif enemy.health < EnemyTable[i].q2 + EnemyTable[i].e + EnemyTable[i].p + EnemyTable[i].r + caaDmg + ciDmg + cItemDmg then
                                EnemyTable[i].IndicatorText = "All In Kill"
                                EnemyTable[i].IndicatorPos = 0
                        if QMana + WMana + EMana + RMana > MyMana or not QREADY or not WREADY or not EREADY or not RREADY then
                                        EnemyTable[i].NotReady = true
                                else
                                        EnemyTable[i].NotReady = false
                        end
                else
                        cTotal = cTotal + EnemyTable[i].q2 + EnemyTable[i].e + EnemyTable[i].p + EnemyTable[i].r + caaDmg
                               
                                HealthLeft = math.round(enemy.health - cTotal)
                                PctLeft = math.round(HealthLeft / enemy.maxHealth * 100)
                                BarPct = PctLeft / 103 * 100
                                EnemyTable[i].Pct = PctLeft
                                EnemyTable[i].IndicatorPos = BarPct
                                EnemyTable[i].IndicatorText = PctLeft .. "% Harass"
                                if not qReady or not wReady or not eReady then
                                        EnemyTable[i].NotReady =  true
                                else
                                        EnemyTable[i].NotReady = false
                                end
                end
                end    
        end
end
--CallBacks--

function OnCreateObj(obj)
        if obj.valid and obj.name:find("Zed_Clone_idle.troy") then
                if wUsed and wClone == nil then
                        wClone = obj
                elseif rClone == nil then
                        rClone = obj
                end
        end
end
 
function OnDeleteObj(obj)
        if obj.valid and wClone and obj == wClone then
                wUsed = false
                wClone = nil   
        elseif obj.valid and rClone and obj == rClone then
                rClone = nil
        end
end
 
function OnProcessSpell(unit, spell)
        if unit.isMe and spell.name == "ZedShadowDash" then
                wUsed = true
                lastW = GetTickCount()
        end
        if unit.isMe then
                if spell.name:lower():find("attack") then
                        lastAttack = GetTickCount() - GetLatency()/2
                        lastWindUpTime = spell.windUpTime*1000
                        lastAttackCD = spell.animationTime*1000
                end
        end
end
 
 
function OnAnimation(unit, animationName)
        if unit.isMe and lastAnimation ~= animationName then lastAnimation = animationName end
end