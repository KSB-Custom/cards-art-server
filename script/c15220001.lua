local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 
	Fusion.AddProcMix(c,true,true,15220015,15220025,15220035)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,function(e) return not e:GetHandler():IsLocation(LOCATION_EXTRA) end,nil,1)
	--neos return
	aux.EnableNeosReturn(c,CATEGORY_SPECIAL_SUMMON,s.sptg,s.spop)
	--Negate the effects of all other your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--immune
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	--Cannot be Tributed
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_UNRELEASABLE_SUM)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e6)
	--Cannot be used as material for a Fusion/Synchro/Xyz Summon
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e7:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ))
	c:RegisterEffect(e7)
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.spfilter(c,e,tp)
	return c:IsCode(15220015) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(aux.AND(Card.IsMonster,Card.IsAbleToDeckOrExtraAsCost),tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
end
function s.contactop(g,tp)
	local fdg=g:Filter(Card.IsFacedown,nil)
	local gyg=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #fdg>0 then Duel.ConfirmCards(1-tp,fdg) end
	if #gyg>0 then Duel.HintSelection(gyg) end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST|REASON_MATERIAL)
end
--Negate
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if #g==0 then return end
	local c=e:GetHandler()
	for tc in g:Iter() do
		--Negate its effects
		tc:NegateEffects(c)
	end
end