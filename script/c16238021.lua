--Impfernal Mandala
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Fusion Summon 1 Fiend Fusion Monster
	local params={aux.FilterBoolFunction(Card.IsRace,RACE_FIEND)}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e2:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsRace(RACE_FIEND) and c:IsAbleToDeck() and not c:IsPublic()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	--Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
	local g=Duel.GetMatchingGroup(s.filter,p,LOCATION_HAND,0,nil)
	local cg=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	if #g>0 then
		Duel.ConfirmCards(1-p,cg)
		Duel.Draw(p,#g,REASON_EFFECT)
		Duel.ShuffleHand(p)
		Duel.BreakEffect()
		local shg=Duel.SelectMatchingCard(p,Card.IsAbleToDeck,p,LOCATION_HAND,0,#g,#g,nil)
		Duel.SendtoDeck(shg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		Duel.ShuffleDeck(p)
	end
end