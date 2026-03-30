--WildRuin Raichel
--Scripted by EP Custom Cards
local s,id=GetID()
function s.initial_effect(c)
	--Tuner
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.tncon)
	e1:SetOperation(s.tnop)
	c:RegisterEffect(e1)
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.spcost)
	e2:SetCountLimit(1,{id,2})
	e2:SetTarget(s.regtg)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
end
s.listed_series={0x759}
--non-tuner
function s.tncon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	return re:GetHandler():IsSetCard(0x759)
end
function s.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
--Special Summon
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,400) end
	Duel.PayLPCost(tp,400)
end
function s.cfilter(c,e,tp)
	return c:IsMonster() and c:IsSetCard(0x759)
end
function s.regtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and not e:GetHandler():IsLocation(LOCATION_DECK)
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,3,nil) end
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_DECK,0,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_DECK,0,nil)
	if #g>=3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,3,3,nil)
		Duel.ConfirmCards(1-tp,sg)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(1-tp,1,1,nil)
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	end
end