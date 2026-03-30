--Cloudian - Cumulus Titan
local s,id=GetID()
function s.initial_effect(c)
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_CLOUDIAN),4,2,nil,nil,Xyz.InfiniteMats)
	--battle indestructable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--selfdes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(s.sdcon)
	c:RegisterEffect(e2)
	--Add 1 "Cloudian" Spell/Trap from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsXyzSummoned() end)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Place Fog Counters on face-up monsters on the field
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_COUNTER)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,3})
	e4:SetCost(Cost.DetachFromSelf(2,2,nil))
	e4:SetTarget(s.countertg)
	e4:SetOperation(s.counterop)
	c:RegisterEffect(e4)
	--Attach Cloudian card
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_LEAVE_GRAVE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(function() return Duel.IsMainPhase() end)
	e5:SetCountLimit(1,{id,2})
	e5:SetTarget(s.xyztg)
	e5:SetOperation(s.xyzop)
	c:RegisterEffect(e5)
end
function s.thfilter(c)
	return c:IsSetCard(SET_CLOUDIAN) and (c:IsSpell() or c:IsTrap()) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--
function s.sdcon(e)
	return e:GetHandler():IsPosition(POS_FACEUP_DEFENSE)
end
--
function s.countertg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_ONFIELD,nil)>0
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
function s.counterop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==0 then return end
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	for i=1,ct do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
		tc=g:Select(tp,1,1,nil):GetFirst()
		tc:AddCounter(0x1019,1)
	end
end
--
function s.xyzfilter(c,tp,xyzc)
	return c:IsSetCard(SET_CLOUDIAN) and c:IsCanBeXyzMaterial(xyzc,tp,REASON_EFFECT)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.xyzfilter(chkc,tp,c) end
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_GRAVE,0,1,nil,tp,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
	local g=Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp,c)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,tp,0)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		then Duel.Overlay(c,tc)
		if c:GetOverlayGroup():IsContains(tc) then 
		--Gains 300 ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		end
	end
end