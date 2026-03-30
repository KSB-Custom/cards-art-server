--Impferno
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	--Def
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--Atk down
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetValue(s.val2)
	c:RegisterEffect(e4)
	--Def
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
	--atk boost in gy
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetRange(LOCATION_FZONE)
	e6:SetTargetRange(LOCATION_MZONE,0)
	e6:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xf19|0xf18))
	e6:SetValue(s.atkval)
	c:RegisterEffect(e6)
	--inactivatable
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_CANNOT_INACTIVATE)
	e7:SetCondition(s.cond)
	e7:SetRange(LOCATION_FZONE)
	e7:SetTargetRange(LOCATION_MZONE,0)
	e7:SetValue(s.effectfilter)
	c:RegisterEffect(e7)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetCode(EFFECT_CANNOT_DISEFFECT)
	e8:SetCondition(s.cond)
	e8:SetRange(LOCATION_FZONE)
	e8:SetTargetRange(LOCATION_MZONE,0)
	e8:SetValue(s.effectfilter)
	c:RegisterEffect(e8)
end
s.listed_series={0xf19,0xf18}
function s.cond(e)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer() and Duel.IsMainPhase()
end
function s.val(e,c)
	local r=c:GetRace()
	local att=c:GetAttribute()
	if (r&RACE_FIEND)>0 or (att&ATTRIBUTE_FIRE>0) then return 200 end
end
function s.val2(e,c)
	local r=c:GetRace()
	local att=c:GetAttribute()
	if (r&RACE_FAIRY)>0 or (att&ATTRIBUTE_WIND)>0 then return -300 end
end
function s.cfilter(c)
	return c:IsSetCard(0xf19) and c:IsMonster()
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsMonster,0,LOCATION_GRAVE,LOCATION_GRAVE,nil)*100
end
--
function s.effectfilter(e,ct)
	local p=e:GetHandler():GetControler()
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	return p==tp and te:GetHandler():IsSetCard(0xf19|0xf18) and loc&LOCATION_ONFIELD~=0
end