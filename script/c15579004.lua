--Wild Ruin Erika
--scripted by EP Custom Cards
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon from hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_series={0x759}
--sp Summon
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() and c:GetFlagEffect(id)==0 and Duel.CheckLPCost(tp,400) end
	Duel.PayLPCost(tp,400)
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and  Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	e:SetLabel(att)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if (not c:IsRelateToEffect(e)) or Duel.GetLocationCount(1-tp,LOCATION_MZONE)<1 then return end
	Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEUP)
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.filter(c,e,tp)
local att=e:GetLabel()
	return c:IsSetCard(0x759) and (c:IsAttribute(att)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end