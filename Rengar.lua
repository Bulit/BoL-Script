if myHero.charName ~= "Rengar" then return end

local ts
local enemyMinions
local haveQ = false
local timer = 0
local aarange = 130
local range = 1500
local wrange = 495
local erange = 575
local rrange = 700

local DmgCalcItems = {

Sheen = { id = 3057, slot = nil },
Iceborn = { id = 3025, slot = nil },
Liandrys = { id = 3151, slot = nil},
LichBane = { id = 3100, slot = nil},
Blackfire = { id = 3188, slot = nil}

}

local Items = {

DFG = { id = 3128, range = 750, reqTarget = true, slot = nil },
HXG = { id = 3146, range = 700, reqTarget = true, slot = nil },
BWC = { id = 3144, range = 500, reqTarget = true, slot = nil },
BRK = { id = 3153, range = 500, reqTarget = true, slot = nil },
SOD = { id = 3131, range = 500, reqTarget = false, slot = nil}

}

function OnLoad()
	RengarConfig = scriptConfig("Rengar Power", "RengarCombo")
	RengarConfig:addParam("Nuke", "Nuke Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	RengarConfig:addParam("FarmE", "Farm with E", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("X"))
	RengarConfig:addParam("Harass", "Harass enemy with E", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("Z"))
	RengarConfig:addParam("Ignite", "Use Ignite", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("I"))
	RengarConfig:addParam("KillText", "Print Text on Target", SCRIPT_PARAM_ONOFF, true)
	RengarConfig:addParam("Movement", "Move to Mouse", SCRIPT_PARAM_ONOFF, true)
	RengarConfig:addParam("DrawCircles", "Draw Circles", SCRIPT_PARAM_ONOFF, true)
	RengarConfig:permaShow("Nuke")
	RengarConfig:permaShow("FarmE")
	RengarConfig:permaShow("Harass")
	RengarConfig:permaShow("Ignite")
	
	ts = TargetSelector(TARGET_LOW_HP_PRIORITY, range, DAMAGE_PHYSICAL, false)
	ts.name = "Rengar"
	RengarConfig:addTS(ts)
	enemyMinions = minionManager(MINION_ENEMY, erange, player, MINION_SORT_HEALTH_ASC)
	PrintChat("Rengar Power v0.1 Loaded!")
	
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ign = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ign = SUMMONER_2
		else ign = nil
	end
end

function CanCast(Spell)
	return (player:CanUseSpell(Spell) == READY)
end

function IReady()
	return (player:CanUseSpell(ign) == READY)
end

function AutoIgnite()
	local iDmg = 0		
	if ign ~= nil and IReady and not myHero.dead then
		for i = 1, heroManager.iCount, 1 do
			local target = heroManager:getHero(i)
			if ValidTarget(target) then
				iDmg = 50 + 20 * myHero.level
				if target ~= nil and target.team ~= myHero.team and not target.dead and target.visible and GetDistance(target) < 600 and target.health < iDmg then
						CastSpell(ign, target)
				end
			end
		end
	end
end

function UseItems(target)
	if target == nil then return end
		for _,item in pairs(Items) do
			item.slot = GetInventorySlotItem(item.id)
		if item.slot ~= nil then
			if item.reqTarget and GetDistance(target) <= item.range then
				CastSpell(item.slot, target)
			end
			if item.reqTarget == false and GetDistance(target) <= item.range then
				CastSpell(item.slot)
			end
		end
	end
end

function Harass(target)
	if RengarConfig.Harass and not RengarConfig.Nuke then
		if ValidTarget(target, erange) and CanCast(_E) and myHero.mana < 5 then
			CastSpell(_E, target)
		end
	end
end

function FarmE()	
	if RengarConfig.FarmE and not RengarConfig.Nuke then
		enemyMinions:update()
		for index, minion in pairs(enemyMinions.objects) do
			local eDmg = getDmg("E", minion, myHero)
			if CanCast(_E) and GetDistance(minion) ~= nil and GetDistance(minion) <= erange and minion.health <= eDmg and minion.visible ~= nil and minion.visible == true and myHero.mana < 5 then
				CastSpell(_E, minion)
			end
		end
	end
end

function tripleQ(target)
	if CanCast(_Q) and myHero.mana == 4 then
		if CanCast(_R) and CanCast(_Q) and haveQ == false then
			CastSpell(_Q)
			CastSpell(_R)
			haveQ = true
			timer = os.clock()
			--PrintChat("haveQ")
		end
	end
	if haveQ == true and ValidTarget(ts.target, rrange) and os.clock() - timer > 3.50 then
		UseItems(ts.target)
		myHero:Attack(ts.target)
		if GetDistance(ts.target) < aarange then
			haveQ = false
			--PrintChat("dont haveQ")
		end
		if haveQ == true and os.clock() - timer > 4.0 then
			haveQ = false
			--PrintChat("dont haveQ auto")
		end
	end
	if myHero.mana == 5 and haveQ == false and ValidTarget(ts.target) then
		CastSpell(_Q)
		myHero:Attack(ts.target)
	end
	if not CanCast(_R) and CanCast(_Q) and haveQ == false and ValidTarget(ts.target) then
		CastSpell(_Q)
		UseItems(ts.target)
		myHero:Attack(ts.target)
	end
end

function OnTick()
	ts:update()
	if TargetHaveBuff("Savagery", player) then PrintChat("HAVE") end
	
	if RengarConfig.Ignite and AutoIgnite() then end
	if RengarConfig.Harass then Harass(ts.target) end
	if RengarConfig.FarmE then FarmE() end
	if RengarConfig.Nuke and ts.target ~= nil then
		tripleQ(ts.target)
		--if CanCast(_Q) and ValidTarget(ts.target) then
			--CastSpell(_Q)
			--UseItems(ts.target)
			--myHero:Attack(ts.target)
		--end
		if CanCast(_W) and ValidTarget(ts.target, wrange) and myHero.mana < 4 then
			CastSpell(_W)
		end
		if CanCast(_E) and ValidTarget(ts.target, erange) and myHero.mana < 4 then
			CastSpell(_E, ts.target)
		end
	end
	
	if RengarConfig.Movement and RengarConfig.Nuke and ts.target == nil then
		myHero:MoveTo(mousePos.x, mousePos.z)
	end
end

function RengarDamageCalc(enemy)
	for i=1, heroManager.iCount do
		local enemy = heroManager:GetHero(i)
		if ValidTarget(enemy) then
			local dfgDmg, hxgDmg, ignDmg, SheenDmg, LichBaneDmg, bwcDmg, brkDmg  = 0, 0, 0, 0, 0, 0, 0
			local qDmg = getDmg("Q", enemy, player)
			local wDmg = getDmg("W", enemy, player)
			local eDmg = getDmg("E", enemy, player)
			local hitDmg = getDmg("AD", enemy, player)
			local dfgDmg = (Items.DFG.slot and getDmg("DFG", enemy, player) or 0)
			local hxgDmg = (Items.HXG.slot and getDmg("HXG", enemy, player) or 0)
			local bwcDmg = (Items.BWC.slot and getDmg("BWC", enemy, player) or 0)
			local brkDmg = (Items.BRK.slot and getDmg("RUINEDKING", enemy, player) or 0)
			local ignDmg = (ign and getDmg("IGNITE", enemy, player) or 0)
			local onhitDmg = (DmgCalcItems.Sheen.slot and getDmg("SHEEN", enemy, player) or 0)+(DmgCalcItems.LichBane.slot and getDmg("LICHBANE", enemy, myHero) or 0)+(DmgCalcItems.Iceborn.slot and getDmg("ICEBORN", enemy, player) or 0)
			local onspellDmg = (DmgCalcItems.Liandrys.slot and getDmg("LIANDRYS", enemy, player) or 0)+(DmgCalcItems.Blackfire.slot and getDmg("BLACKFIRE", enemy, player) or 0)
			local myDamage = 0
			local maxDamage = qDmg + wDmg + eDmg + onspellDmg + onhitDmg + dfgDmg + hxgDmg + bwcDmg + brkDmg + ignDmg
			if CanCast(_Q) then myDamage = myDamage + qDmg end
			if CanCast(_W) then myDamage = myDamage + wDmg end
			if CanCast(_E) then myDamage = myDamage + eDmg end
			if Items.DFG.slot ~= nil then myDamage = myDamage + dfgDmg end
			if Items.HXG.slot ~= nil then myDamage = myDamage + hxgDmg end
			if Items.BWC.slot ~= nil then myDamage = myDamage + bwcDmg end
			if Items.BRK.slot ~= nil then myDamage = myDamage + brkDmg end
			if ign ~= nil and IReady() and RengarConfig.Ignite then myDamage = myDamage + ignDmg end
			myDamage = myDamage + onspellDmg
			myDamage = myDamage + onhitDmg
			myDamage = myDamage + hitDmg
			if RengarConfig.KillText then
				if ts.target.health <= myDamage then
					PrintFloatText(ts.target, 0, "Nuke Him")
				elseif ts.target.health <= maxDamage then
					PrintFloatText(ts.target, 0, "Wait for cds, dont rush")
				else
					PrintFloatText(ts.target, 0, "You need more POWER")
				end
			end
		end
	end
end

function OnDraw()
	if RengarConfig.DrawCircles and not myHero.dead then
		DrawCircle(myHero.x,myHero.y,myHero.z,erange,0xFFFF0000)
		DrawCircle(myHero.x,myHero.y,myHero.z,wrange,0xFFFF0000)
	end
	if ts.target ~= nil then
		RengarDamageCalc(ts.target)
        for j=0, 15 do
            DrawCircle(ts.target.x, ts.target.y, ts.target.z, 40 + j*1.5, 0x00FF00)
        end
    end
end