--Sparkhearts Studio
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Indestructable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Increase ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.filter)
	e2:SetValue(400)
	c:RegisterEffect(e2)
	--Can activate Spells/Traps the turn they're Set
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetTarget(s.filterquick)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
	c:RegisterEffect(e4)
	--wut
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e5:SetCode(EFFECT_BECOME_QUICK)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(0x3f,0)
	e5:SetTarget(s.filterquick)
	c:RegisterEffect(e5)
	
end
function s.indtg(e,c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.filter(e,c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.filterquick(e,c)
	return c:IsCode(76103675) or c:IsCode(26260106) or c:IsCode(26260107)
end