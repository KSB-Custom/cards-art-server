--Sparkhearts Passion Makma
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--damage
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_CHAIN_SOLVED)
	e0:SetRange(LOCATION_MZONE)
	e0:SetOperation(s.damop)
	c:RegisterEffect(e0)
	--Set 1 "Sparks" Spell/Trap
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfDiscard)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	--Gain Atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsCode,26260111))
	e2:SetValue(1300)
	c:RegisterEffect(e2)
	--Lose Atk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsFaceup))
	e3:SetValue(s.val)
	c:RegisterEffect(e3)
	--Destroy all opponent's monsters
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.descon)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
end
s.listed_series={0xf27}
--damage
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetActiveType()==TYPE_SPELL and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(76103675) and rp==tp then
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
end
--Destroy
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:GetHandler():IsCode(76103675) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.Destroy(g,REASON_EFFECT)
end
--
function s.val(e,c)
	local g=Duel.GetMatchingGroup(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,76103675,26260105,26260106,26260107,26260110)
	local ct=g:GetClassCount(Card.GetCode)
	return ct*-400
end
--
function s.setfilter(c)
	return (c:IsSetCard(0xf27) or c:IsCode(76103675)) and c:IsSpellTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_REMOVE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--30459350 chk
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(30459350)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,1,aux.Stringid(id,2),nil)
	Duel.RegisterFlagEffect(0,id,RESET_PHASE|PHASE_END,0,1)
end