--Revenge of the Exiled
--Scripted by EP Custom Cards
local s,id=GetID()
function s.initial_effect(c)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0x759}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		g:RemoveCard(e:GetHandler())
		return #g>1 and g:FilterCount(Card.IsAbleToDeck,nil)==#g
	end
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	Duel.SendtoDeck(g,nil,0,REASON_COST)
end
function s.filter2(c)
	return c:IsCode(15579021) or c:IsCode(15579022)
end
function s.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_ONFIELD,0,1,nil) then
		Duel.SetChainLimit(function(e,ep,tp) return ep==tp or not (e:IsActiveType(TYPE_MONSTER)) end)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 then
		Duel.Draw(tp,ct,REASON_EFFECT)
	end
end