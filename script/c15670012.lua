--Alebrije Transform
local s,id=GetID()
function s.initial_effect(c)
	-- Activate "The Sanctuary in the Sky" or search a monster that lists it
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tdcon)
	e1:SetTarget(s.acthtg)
	e1:SetOperation(s.acthop)
	c:RegisterEffect(e1)
	--Shuffle this card and 1 other card from the GY to the Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
	end
s.listed_series={0xf16}
s.listed_names={CARD_POLYMERIZATION}
function s.acfilter(c,tp)
	return c:IsCode(15670000) and c:GetActivateEffect()
		and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.thfilter(c)
	return c:IsMonster() and c:ListsCode(CARD_POLYMERIZATION) and c:IsAbleToHand()
end
function s.acthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.acfilter,tp,LOCATION_DECK,0,1,nil,tp)
			or Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
end
function s.acthop(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.IsExistingMatchingCard(s.acfilter,tp,LOCATION_DECK,0,1,nil,tp)
	local th=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	-- Choose effect to apply
	local op
	if ac and th then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif ac then 
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	elseif th then
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1 
	end
	-- Apply chosen effect
	local gainlp=nil
	if op==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=Duel.SelectMatchingCard(tp,s.acfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		if tc then gainlp=Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp) end
	elseif op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			gainlp=Duel.SendtoHand(g,nil,REASON_EFFECT)>0
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
--to Deck
function s.spfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(0xf16)
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end
function s.tdfilter(c)
	return  c:IsAbleToDeck() and (c:IsCode(CARD_POLYMERIZATION) or c:IsCode(15670000))
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() and chkc~=c end
	if chk==0 then return c:IsAbleToDeck()
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		local g=Group.CreateGroup(c,tc)
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>1 then
		Duel.ShuffleDeck(tp)
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	end
end