--Libromancer Guy
local s,id=GetID()
function s.initial_effect(c)
	--Negate an opponent's effect activated in response in response to the activation of your "Libromancer" card or effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetCost(Cost.SelfDiscard)
	e1:SetTarget(s.distg)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.NegateEffect(ev) end)
	c:RegisterEffect(e1)
	--Set 1
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SET+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(function(e) return not e:GetHandler():IsReason(REASON_DRAW) end)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_LIBROMANCER}
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local chainlink=Duel.GetCurrentChain(true)-1
	if not (chainlink>0 and Duel.IsChainDisablable(ev) and ep==1-tp) then return false end
	local trig_p,setcodes=Duel.GetChainInfo(chainlink,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_SETCODES)
	if not trig_p==tp then return false end
	for _,set in ipairs(setcodes) do
		if (SET_LIBROMANCER&0xfff)==(set&0xfff) and (SET_LIBROMANCER&set)==SET_LIBROMANCER then return true end
	end
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
--
function s.setfilter(c)
	return c:IsSetCard(SET_LIBROMANCER) and c:IsSpellTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spfilter1(c,e,tp)
	return c:IsSetCard(SET_LIBROMANCER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #sg>0 and Duel.SSet(tp,sg)>0 then
		Duel.ShuffleDeck(tp)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter1),tp,LOCATION_HAND|LOCATION_GRAVE,0,nil,e,tp)
		if #g1>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g2=g1:Select(tp,1,1,nil)
			Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end