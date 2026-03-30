--Libromancer Girl
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Libromancer" monster from your hand or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetCondition(aux.NOT(s.spquickcon))
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Special Summon 1 "Libromancer" monster from your hand or GY (Quick if the opponent is the only controls monsters)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCondition(s.spquickcon)
	c:RegisterEffect(e2)
	--Return 1 Libromancer Card you control and 1 card your opponent controls to the hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return re:IsMonsterEffect() and rp==1-tp end)
	e3:SetTarget(s.rthtg)
	e3:SetOperation(s.rthop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_LIBROMANCER}
function s.spquickcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
function s.cfilter(c,e,tp)
	return c:IsSetCard(SET_LIBROMANCER) and not c:IsPublic()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,c,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,c):GetFirst()
	Duel.ConfirmCards(1-tp,Group.FromCards(c,rc))
	Duel.ShuffleHand(tp)
end
function s.spfilter(c,e,tp,opp_chk)
	return c:IsSetCard(SET_LIBROMANCER) and c:IsCanBeSpecialSummoned(e,100,tp,false,false)
		and (c:IsLocation(LOCATION_HAND|LOCATION_GRAVE)
		or (opp_chk and c:IsLocation(LOCATION_DECK)))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK,0,1,nil,e,tp,Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK,0,1,1,nil,e,tp,Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0):GetFirst()
		if sc and Duel.SpecialSummon(sc,100,tp,tp,false,false,POS_FACEUP)>0 then
			sc:RegisterFlagEffect(sc:GetOriginalCode(),RESET_EVENT|RESETS_STANDARD_DISABLE,0,1)
		end
	end
end
--
function s.rthfilter(c,e,tp)
	return ((c:IsSetCard(SET_LIBROMANCER) and c:IsFaceup() and c:IsControler(tp)) or c:IsControler(1-tp))
		and c:IsCanBeEffectTarget(e) and c:IsAbleToHand()
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.rthfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e,tp)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetControler),0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetControler),1,tp,HINTMSG_RTOHAND)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,2,tp,0)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end