--Valkyrion the Magna Wings
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,99785935,39256679,11549357)
	--Shuffle cards from the GY into the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	--Banish 1 "Magna Warrior" monster from your GY and banish
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.rmcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	--(Quick if the opponent controls monsters)
	local e6=e2:Clone()
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e6:SetCountLimit(1,{id,1})
	e6:SetCondition(s.spquickcon)
	c:RegisterEffect(e6)
	--Cannot be targeted
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetTarget(function(e,c) return c==e:GetHandler() or c:IsCode(4740489) end)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	--Cannot be destroyed
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetTargetRange(LOCATION_ONFIELD,0)
	e4:SetTarget(function(e,c) return c==e:GetHandler() or c:IsCode(4740489) end)
	e4:SetValue(aux.indoval)
	c:RegisterEffect(e4)
	--"Magna Warrior" monsters you control can attack directly this turn
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCost(s.dcost)
	e5:SetOperation(s.dop)
	c:RegisterEffect(e5)
end
s.listed_series={SET_MAGNET_WARRIOR,SET_MAGNA_WARRIOR}
s.listed_names={99785935,39256679,11549357}
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,5,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetTargetCards(e)
	if #sg==0 then return end
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
--Direct attack
function s.dcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Each of your "Valkyrion" and "Bersekion" can attack directly this turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsSetCard(SET_MAGNA_WARRIOR) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
--Banish
function s.rmcfilter(c,attr)
	return c:IsSetCard(SET_MAGNET_WARRIOR) and c:IsMonster() and c:IsAbleToRemoveAsCost() 
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmcfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sc=Duel.SelectMatchingCard(tp,s.rmcfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
	Duel.Remove(sc,POS_FACEUP,REASON_COST)
	local tn_chk=sc:IsType(TYPE_NORMAL) and 1 or 0
	e:SetLabel(tn_chk)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_EITHER,LOCATION_ONFIELD)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local tn_chk=e:GetLabel()
	if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	then 
	Duel.BreakEffect()
	if tn_chk==0 then return end
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=g:Select(tp,1,1,nil)
			Duel.HintSelection(sg)
			Duel.BreakEffect()
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
--Quick condition
function s.sfilter(c)
	return c:IsFaceup() and c:IsCode(4740489)
end
function s.spquickcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end