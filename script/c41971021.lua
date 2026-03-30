--JellyBean Knight
local s,id=GetID()
function s.initial_effect(c)
c:EnableReviveLimit()
--pendulum summon
	Pendulum.AddProcedure(c)
--You take no battle damage from battles involving this cards
local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
--Discard it and pendulum place
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(aux.NOT(s.spquickcon))
	e2:SetCost(s.ppcost)
	e2:SetTarget(s.pctg)
	e2:SetOperation(s.pcop)
	c:RegisterEffect(e2)
--Quick if the opponent controls more monsters
	local e6=e2:Clone()
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetCountLimit(1,{id,1})
	e6:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e6:SetCondition(s.spquickcon)
	c:RegisterEffect(e6)
	--Equip 1 face-up monster on field to this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.eqcon)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
	aux.AddEREquipLimit(c,s.eqcon,function(ec,_,tp) return ec:IsControler(1-tp) end,s.equipop,e3)
	--Discard and add to hand
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_PZONE)
	e5:SetCountLimit(1,{id,3})
	e5:SetCost(s.thcost)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
end
function s.ppcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() and Duel.CheckLPCost(tp,500) end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
	Duel.PayLPCost(tp,500)
end
--
function s.spquickcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==0 then return false end
		local tg=g:GetMaxGroup(Card.GetAttack)
	return tg:IsExists(Card.IsControler,1,nil,1-tp)
end
--place in PZ
function s.pcfilter(c)
	return c:IsSetCard(0xf25) and c:IsType(TYPE_PENDULUM)
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp)
		and Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
--Equip
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup():Filter(Card.HasFlagEffect,nil,id)
	return Duel.GetAttacker()==e:GetHandler() and #g==0
end
function s.eqfilter(c,tp)
	return c:IsFaceup() and (c:IsControler(tp) or c:IsAbleToChangeControler()) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler(),tp)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,0,0)
end
function s.equipop(c,e,tp,tc)
	if not c:EquipByEffectAndLimitRegister(e,tp,tc,id) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	e1:SetValue(1000)
	tc:RegisterEffect(e1)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local tc=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,tp):GetFirst()
	if tc then
		s.equipop(c,e,tp,tc)
	end
end
--
--TO HAND
function s.thfilter(c)
	return c:IsSetCard(0xf25) and c:IsMonster() and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local exc=(e:GetHandler():IsLocation(LOCATION_HAND) and not e:GetHandler():IsAbleToGraveAsCost()) and e:GetHandler() or nil
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,exc) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,exc)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end