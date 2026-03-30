--Sparkhearts Hat
local s,id=GetID()
function s.initial_effect(c)
--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(s.condition2)
	e1:SetCost(Cost.SelfToGrave)
	e1:SetOperation(s.operation2)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND|LOCATION_ONFIELD)
end
function s.thfilter(c)
	return c:IsMonster() and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_FIRE) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,c)
	if Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end
	if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsCode(id)
end
--
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	local phase=Duel.GetCurrentPhase()
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return d~=nil and d:IsFaceup() and ((a:IsControler(tp) and a:IsSetCard(0xf27) and a:IsRelateToBattle())
		or (d:IsControler(tp) and d:IsSetCard(0xf27) and d:IsRelateToBattle()))
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not a:IsRelateToBattle() or not d:IsRelateToBattle() then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetOwnerPlayer(tp)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	if a:IsControler(tp) then
		e1:SetValue(d:GetAttack())
		a:RegisterEffect(e1)
	else
		e1:SetValue(a:GetAttack())
		d:RegisterEffect(e1)
	end
end