--Fountain of Immortality
--Scripted by EP Custom Cards
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--halve battle damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x759))
	e2:SetValue(aux.ChangeBattleDamage(0,HALF_DAMAGE))
	c:RegisterEffect(e2)
	--indes
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.indtg)
	e4:SetValue(s.indval)
	c:RegisterEffect(e4)
end
function s.indtg(e,c)
	e:SetLabel(c:GetAttribute()) 
	return c:IsSetCard(0x759)
end
function s.indval(e,c)
	return  not c:IsAttribute(e:GetLabel())
end
s.listed_series={0x759}