--Royal Impish Albino King
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xf19),1,3)
	c:EnableReviveLimit()
	--material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.descond)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--negate attack
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_RECOVER)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.nacon)
	e4:SetCost(s.nacost)
	e4:SetTarget(s.natg)
	e4:SetOperation(s.naop)
	c:RegisterEffect(e4,false,REGISTER_FLAG_DETACH_XMAT)
end
s.listed_series={0x231}
--absorb
function s.desfilter(c,tp)
	return c:IsFaceup() and c:IsLevel(1) and c:IsRace(RACE_FIEND) and c:IsControler(tp)
end
function s.descond(e,tp,eg,ep,ev,re,r,rp,chk)
	return eg:IsExists(s.desfilter,1,e:GetHandler(),tp)
end
function s.filter(c,tp)
	return c:IsFaceup() and c:IsLevel(1) and c:IsRace(RACE_FIEND) and not c:IsType(TYPE_TOKEN) 
		and (c:IsControler(tp) or c:IsAbleToChangeControler())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,tp) and chkc~=e:GetHandler() end
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler(),tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler(),tp)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(c,tc,true)
	end
end
--negate attack
function s.atkfilter(c)
	return c:IsFaceup()
end
function s.nacon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
	local lowestAtk=g:GetMinGroup(Card.GetAttack)
	local attacked=Duel.GetAttackTarget()
	return attacked and Group.IsContains(lowestAtk,attacked) and Duel.GetAttackTarget():IsType(TYPE_MONSTER) and attacked:IsControler(tp)
		and not Duel.GetAttacker():IsControler(tp)
end
function s.nacost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.natg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetAttacker():IsOnField() end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,Duel.GetAttacker():GetAttack())
end
function s.naop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateAttack() then
		Duel.Damage(1-tp,Duel.GetAttacker():GetAttack(),REASON_EFFECT)
	end
end
