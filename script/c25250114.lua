--Magnet Twin Saber
local s,id=GetID()
function s.initial_effect(c)
	--Equip only to a EARTH Rock monster
	aux.AddEquipProcedure(c,nil,s.eqfilter)
	--Equipped monster gains 300 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(300)
	c:RegisterEffect(e1)
	--Piercing
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetCondition(s.pcon)
	c:RegisterEffect(e2)
	--ATK twice
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetCondition(s.atkcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--Negate traps
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e4:SetTarget(s.distarget)
	c:RegisterEffect(e4)
	--Negate trap effects
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAIN_SOLVING)
	e5:SetRange(LOCATION_SZONE)
	e5:SetOperation(s.disop)
	c:RegisterEffect(e5)
end
function s.eqfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_ROCK)
end
function s.pcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsSetCard(SET_MAGNET_WARRIOR)
end
function s.atkcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and (ec:IsType(TYPE_NORMAL) or ec:IsType(TYPE_FUSION) or ec:IsSetCard(SET_MAGNA_WARRIOR))
end
function s.distarget(e,c)
	return c~=e:GetHandler() and c:IsSpell() and c:IsType(TYPE_EQUIP)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	local tpe=re:GetActiveType()
	if (tl&LOCATION_SZONE)~=0 and (tpe&TYPE_SPELL)~=0 and re:GetHandler()~=e:GetHandler() and tpe&TYPE_EQUIP~=0 then
		Duel.NegateEffect(ev)
	end
	end