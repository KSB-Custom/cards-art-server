--FNO Ranged Inquisitor
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Pendulum.AddProcedure(c,false)
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x1065),1,1,Synchro.NonTunerEx(Card.IsSetCard,0xf14),1,99)
	--remove instead send to gy
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCondition(function(e)return e:GetHandler():IsFaceup()end)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)
	--Discard and change monsters to face-down
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCost(s.defcost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.activate)
	c:RegisterEffect(e3)
	--During End Phase, place in PZone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.pentg)
	e2:SetOperation(s.penop)
	c:RegisterEffect(e2)
	--special summon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetRange(LOCATION_PZONE)
	e5:SetCountLimit(1,{id,3})
	e5:SetCondition(s.spcon)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
--splimit
	local e20=Effect.CreateEffect(c)
	e20:SetType(EFFECT_TYPE_FIELD)
	e20:SetRange(LOCATION_PZONE)
	e20:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e20:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e20:SetTargetRange(1,0)
	e20:SetTarget(s.splimit6)
	c:RegisterEffect(e20)
end
s.listed_series={0xf14}
function s.splimit6(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0xf14) and (sumtp&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
	--change to face-down
function s.disfilter(c)
	return c:IsDiscardable()
end
function s.defcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.disfilter,1,1,REASON_COST+REASON_DISCARD)
end
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
	local tg=Duel.GetMatchingGroup(aux.NOT(Card.IsCanTurnSet),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #tg>0 then
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tg,#tg,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 and Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)>0 then
		local turn_p=Duel.GetTurnPlayer()
		local g1=Duel.GetMatchingGroup(Card.IsFaceup,turn_p,LOCATION_MZONE,0,nil)
		local g2=Duel.GetMatchingGroup(Card.IsFaceup,turn_p,0,LOCATION_MZONE,nil)
		if #g1==0 and #g2==0 then return end
		Duel.BreakEffect()
		if #g1>0 then
			Duel.SendtoGrave(g1,REASON_RULE)
		end
		if #g2>0 then
			Duel.SendtoGrave(g2,REASON_RULE)
		end
	end
end
--PLACE IN PZONE
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
	e:GetHandler():IsLocation(LOCATION_REMOVED)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return false end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
--special summon
function s.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousSetCard(0xf14)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end