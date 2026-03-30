--FNO Heal Sage
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	c:EnableReviveLimit()
	--Negate attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.nacond)
	e1:SetCost(s.nacost)
	e1:SetOperation(s.naop)
	c:RegisterEffect(e1)
	--Discard and place in Pzone from deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,{id,1})
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.condition)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.pztg)
	e2:SetOperation(s.pzop)
	c:RegisterEffect(e2)
	--UNAFFECTED
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	--recover
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCategory(CATEGORY_RECOVER)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.rectg)
	e4:SetOperation(s.recop)
	c:RegisterEffect(e4)
	--damage conversion
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_REVERSE_DAMAGE)
	e5:SetRange(LOCATION_PZONE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCondition(s.dmcon)
	e5:SetTargetRange(1,0)
	e5:SetValue(s.rev)
	c:RegisterEffect(e5)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.listed_series={0xf14}
function s.counterfilter(c)
	return not c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
--Place 2 FNO cards in Pendulum zones
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.GetFieldCard(tp,LOCATION_PZONE,0) and not Duel.GetFieldCard(tp,LOCATION_PZONE,1)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 and e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,2),nil)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function s.filter(c)
	return c:IsSetCard(0xf14) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,2,2,nil) end
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,2,2,nil)
	if #g>=2 then
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		Duel.MoveToField(g:GetNext(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
--UNAFFECTED
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chck:IsSetCard(0xf14) and chkc:IsOnField() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
--Recover
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Recover(p,d,REASON_EFFECT)
end
--negate attack
function s.cfilter(c)
	return c:IsSetCard(0xf14) and c:IsDiscardable()
end
function s.nacond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.nacost(e,tp,eg,ep,ev,re,r,rp,chk)
	local exc=(e:GetHandler():IsLocation(LOCATION_HAND) and not e:GetHandler():IsAbleToGraveAsCost()) and e:GetHandler() or nil
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,exc) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,exc)
end
function s.naop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) and Duel.NegateAttack() then
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
--dmg conversion
function s.rev(e,re,r,rp,rc)
	return (r&REASON_EFFECT)~=0
end
function s.dmfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f14) and c:IsType(TYPE_MONSTER)
end
function s.dmcon(e)
	return Duel.IsExistingMatchingCard(s.dmfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end