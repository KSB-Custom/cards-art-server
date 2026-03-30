--Curtain of the Sparks
local s,id=GetID()
function s.initial_effect(c)
	--You can activate this card the turn it was Set, by revealing 1 "Red Dragon Archfiend" in your Extra Deck
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e0:SetCondition(function(e) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,76103675),e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil) end)
	c:RegisterEffect(e0)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(aux.StatChangeDamageStepCondition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Shuffle this card and 1 other card from the GY to the Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		for tc in g:Iter() do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			e1:SetValue(-500)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e2)
		end
		--Destroy all Spells/Traps the opponent controls
			local sg=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
			if Duel.IsBattlePhase() and #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.BreakEffect()
				Duel.Destroy(sg,REASON_EFFECT)
			end
	end
end
function s.extracostfilter(c)
	return c:IsCode(76103675) and not c:IsPublic()
end
--
function s.tdfilter(c)
	return  c:IsAbleToDeck() and c:IsCode(76103675)
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