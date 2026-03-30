--Sparkhearts Passion Girl
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
--Add 1 "Sparks" from your Deck to your hand, or, if you have "Sparks" in your GY...
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfDiscard)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Destroy 1 card your opponent controls
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,2})
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_series={0xf27}
function s.thfilter(c,hasbox)
	return c:IsAbleToHand() and (c:IsCode(76103675) or (hasbox and c:IsSetCard(0xf27)))
end
function s.filter(c)
	return c:IsCode(76103675)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local hasbox=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil) 
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,hasbox) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
		local hasbox=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,hasbox)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_REMOVE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--30459350 chk
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(30459350)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,1,aux.Stringid(id,2),nil)
	Duel.RegisterFlagEffect(0,id,RESET_PHASE|PHASE_END,0,1)
end
--
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD|LOCATION_HAND,0,1,e:GetHandler()) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsNotMaximumModeSide,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD|LOCATION_HAND,0,1,1,c)
	if Duel.SendtoGrave(g,REASON_COST)==0 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=Duel.SelectMatchingCard(tp,Card.IsNotMaximumModeSide,tp,0,LOCATION_ONFIELD,1,1,nil)
	local dg2=dg:AddMaximumCheck()
	Duel.HintSelection(dg2)
	Duel.Destroy(dg,REASON_EFFECT)
	if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,76103675) then
		Duel.BreakEffect()
		Duel.Damage(1-tp,700,REASON_EFFECT)
	end
end