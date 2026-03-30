--JellyBean Treasure
local s,id=GetID()
function s.initial_effect(c)
--to grave
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.selfspcost)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--Can be activated the turn it was Set by discarding 1 Normal Trap
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetValue(function(e,c) e:SetLabel(1) end)
	e2:SetCondition(function(e) return Duel.IsExistingMatchingCard(s.selfspcostfilter,e:GetHandlerPlayer(),LOCATION_HAND,0,1,nil) end)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
	--banish this card and cannot be destroyed by battle
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCost(aux.bfgcost)
	e3:SetOperation(s.activate)
	c:RegisterEffect(e3)
end
	function s.selfspcostfilter(c)
	return c:IsSetCard(0xf25) and c:IsDiscardable()
end
function s.selfspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local label_obj=e:GetLabelObject()
	if chk==0 then label_obj:SetLabel(0) return true end
	if label_obj:GetLabel()>0 then
		label_obj:SetLabel(0)
		Duel.DiscardHand(tp,s.selfspcostfilter,1,1,REASON_COST|REASON_DISCARD)
	end
end
--Cannot be destroyed
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xf25))
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetValue(1)
	Duel.RegisterEffect(e2,tp)
end
--
function s.tgfilter(c)
	return c:IsSetCard(0xf25) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,3,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end