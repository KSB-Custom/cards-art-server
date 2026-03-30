--FINDING NEVERLAND ONLINE
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Can be activated from the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
	--Add itself to the hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DISCARD)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(2,{id,1})
	e3:SetCost(s.cost)
	e3:SetCondition(s.drwcond)
	e3:SetTarget(s.drwtg)
	e3:SetOperation(s.drwop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetRange(LOCATION_REMOVED)
	c:RegisterEffect(e4)
end
s.listed_series={0xf14}
--Special summon
function s.spfilter(c,e,tp,mc)
	if c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,mc,c)==0 then return false end
	return (c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0xf14) 
	and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_EXTRA
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if e:GetHandler():GetSequence()<5 then ft=ft+1 end
	if ft>0 then loc=loc+LOCATION_HAND+LOCATION_GRAVE end
	if chk==0 then return loc~=0 and Duel.IsExistingMatchingCard(s.spfilter,tp,loc,0,1,nil,e,tp,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_EXTRA
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND+LOCATION_GRAVE end
	if loc==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,loc,0,1,1,nil,e,tp,e:GetHandler())
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
--Condition activation in hand
function s.handcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD,0)==0
		and Duel.GetFieldGroupCount(1-e:GetHandlerPlayer(),LOCATION_ONFIELD,0)>1
end
--Add itself to the hand
function s.dfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousControler(tp) and c:IsSetCard(0xf14) 
end
function s.drwcond(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.dfilter,1,e:GetHandler(),tp) 
end
function s.drwtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.drwop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
--cannot summon
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,2),nil)
	--lizard check
	aux.addTempLizardCheck(e:GetHandler(),tp,s.lizfilter)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0xf14) and c:IsLocation(LOCATION_EXTRA)
end
function s.lizfilter(e,c)
	return not c:IsSetCard(0xf14)
end