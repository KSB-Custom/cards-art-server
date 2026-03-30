--Alpha the Eternal Magnet Warrior 
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure
	Link.AddProcedure(c,s.matfilter,1,1)
	--Set 1 Spell/Trap from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(aux.NOT(s.spquickcon))
	e2:SetCountLimit(1,{id,2})
	e2:SetCost(Cost.SelfTribute)
	e2:SetTarget(s.sptg1)
	e2:SetOperation(s.spop1)
	c:RegisterEffect(e2)
	--(Quick if the opponent controls monsters)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.spquickcon)
	c:RegisterEffect(e3)
	--Name becomes
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_CHANGE_CODE)
	e4:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
	e4:SetValue(99785935)
	c:RegisterEffect(e4)
end
function s.matfilter(c,scard,sumtype,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_ROCK,scard,sumtype,tp) and c:IsAttribute(ATTRIBUTE_EARTH,lc,sumtype,tp)
end
--
function s.sfilter(c)
	return c:IsFaceup() and c:IsCode(4740489)
end
function s.spquickcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
--
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	return g:IsExists(Card.IsSummonCode,1,nil,c,SUMMON_TYPE_LINK,tp,99785935) and c:IsLinkSummoned()
end
function s.setfilter(c)
	return c:IsSSetable() and c:IsSetCard(SET_MAGNET) and c:IsSpellTrap()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end
--
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_MAGNET_WARRIOR) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if e:GetHandler():GetSequence()<5 then ft=ft+1 end
	if chk==0 then return ft>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end