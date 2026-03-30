--Sparkhearts Girl
local s,id=GetID()
function s.initial_effect(c)
	--Shuffle 1 monster from your hand or face-up field into the Deck, and if you do, Special Summon this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE+LOCATION_HAND)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	--Special Summon itself from the hand (Quick if the opponent controls monsters)
	local e4=e1:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e4:SetCondition(s.spquickcon)
	c:RegisterEffect(e4)
	--Set 1 "Sparks" and 1 "Sparkhearts" Spell/Trap directly from your Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,2})
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
--
function s.spquickcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>1 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
--
function s.tdfilter(c,tp)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
		and c:IsAbleToDeck() and Duel.GetMZoneCount(tp,c)>0
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,c,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sc=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp):GetFirst()
	if not sc then return end
	if sc:IsLocation(LOCATION_HAND) then Duel.ConfirmCards(1-tp,sc)
	else Duel.HintSelection(sc) end
	local c=e:GetHandler()
	if Duel.SendtoDeck(sc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
		and sc:IsLocation(LOCATION_DECK|LOCATION_EXTRA)
		and c:IsRelateToEffect(e)
		then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
--
function s.setfilter(c)
	return (c:IsSetCard(0xf27) or c:IsCode(76103675)) and c:IsSpellTrap() and c:IsSSetable()
end
function s.rescon(stzone_chk)
	return function(sg,e,tp,mg)
		return #sg==2 and (stzone_chk or sg:IsExists(Card.IsFieldSpell,1,nil)) and sg:IsExists(Card.IsSpell,1,nil) and sg:IsExists(Card.IsTrap,1,nil)
	end
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local stzone_chk=Duel.GetLocationCount(tp,LOCATION_SZONE)>=2
		local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
		return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon(stzone_chk),0)
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local stzone_chk=Duel.GetLocationCount(tp,LOCATION_SZONE)>=2
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon(stzone_chk),1,tp,HINTMSG_SET)
	if #sg==2 then
		Duel.SSet(tp,sg)
	end
end