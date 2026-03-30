--Beta the Eternal Magnet Warrior 
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
	--Draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,2})
	e2:SetCost(s.drcost)
	e2:SetCondition(aux.NOT(s.spquickcon))
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	--(Quick if you control "Magnetic Field")
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,{id,2})
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetCondition(s.spquickcon)
	c:RegisterEffect(e3)
	--Name becomes
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_CHANGE_CODE)
	e4:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
	e4:SetValue(39256679)
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
--Set
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	return g:IsExists(Card.IsSummonCode,1,nil,c,SUMMON_TYPE_LINK,tp,39256679) and c:IsLinkSummoned()
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
--Draw
function s.cffilter(c)
	return c:IsSetCard(SET_MAGNA_WARRIOR) and not c:IsPublic()
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cffilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cffilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end