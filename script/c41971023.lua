--JellyBeans Archer
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--You take no battle damage from battles involving this cards
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.atkcon)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--pierce
	local e2=Effect.CreateEffect(c) 
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	--tograve
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
	--Discard this card and add to hand
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_HAND)
	e6:SetCountLimit(1,id)
	e6:SetCondition(aux.NOT(s.spquickcon))
	e6:SetCost(s.thcost)
	e6:SetTarget(s.thtg)
	e6:SetOperation(s.thop)
	c:RegisterEffect(e6)
	--Quick if the opponent controls a monster
	local e8=e6:Clone()
	e8:SetType(EFFECT_TYPE_QUICK_O)
	e8:SetCode(EVENT_FREE_CHAIN)
	e8:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e8:SetCondition(s.spquickcon)
	c:RegisterEffect(e8)
	--Add itself
	local e7=Effect.CreateEffect(c)
	e7:SetCategory(CATEGORY_TOHAND)
	e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetCondition(s.thcon2)
	e7:SetCode(EVENT_REMOVE)
	e7:SetCountLimit(1,{id,3})
	e7:SetTarget(s.thtg2)
	e7:SetOperation(s.thop2)
	c:RegisterEffect(e7)
	local e9=Effect.CreateEffect(c)
	e9:SetProperty(EFFECT_FLAG_DELAY)
	e9:SetCategory(CATEGORY_TOHAND)
	e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e9:SetCountLimit(1,{id,3})
	e9:SetCode(EVENT_RELEASE)
	e9:SetCondition(s.thcon2)
	e9:SetTarget(s.thtg2)
	e9:SetOperation(s.thop2)
	c:RegisterEffect(e9)
end
function s.atkcon(e)
	local ph=Duel.GetCurrentPhase()
	if ph~=PHASE_DAMAGE and ph~=PHASE_DAMAGE_CAL then return false end
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return e:GetHandler()==a and d and d:IsDefensePos()
end
function s.spquickcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==0 then return false end
		local tg=g:GetMaxGroup(Card.GetAttack)
	return tg:IsExists(Card.IsControler,1,nil,1-tp)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() and Duel.CheckLPCost(tp,500) end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
	Duel.PayLPCost(tp,500)
end
function s.thfilter(c)
	return c:IsSetCard(0xf25) and not c:IsCode(id) and c:IsMonster() and c:IsAbleToHand()
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
--Add itself to hand
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
--
function s.atkfilter(c)
	return c:IsSpellTrap() and c:IsSetCard(0xf25)
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_GRAVE,0,nil)*300
end
--
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if #sg>0 then
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_RETURN)
	end
end