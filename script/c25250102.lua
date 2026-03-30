--Omega the Magnet Warrior 
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 EARTH Rock
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCost(Cost.SelfDiscard)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re) return ep==1-tp and re:IsMonsterEffect() end)
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)
	--Search 1 "Magnet Warrior" Normal
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.tdcon)
	e3:SetCost(Cost.SelfReveal)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.listed_names={id}
s.listed_series={SET_MAGNET_WARRIOR}
--
function s.thfilter2(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_ROCK) and c:IsAbleToHand()
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
--
function s.tdconfilter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsSummonLocation(LOCATION_DECK|LOCATION_EXTRA)
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.tdconfilter,1,nil,tp)
end
function s.thfilter(c)
	return c:IsSetCard(SET_MAGNET_WARRIOR) and c:IsAbleToHand() and c:IsType(TYPE_NORMAL)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end