--AZTECA huitzilopotchtli
local s,id=GetID()
function s.initial_effect(c)
--Synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xF15),1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--Op cannot be target
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1f15))
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Disable attack
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCost(s.spcost)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.natg)
	e2:SetOperation(s.naop)
	c:RegisterEffect(e2)
end
function s.costfilter(c,e)
	return c:IsType(TYPE_MONSTER) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.costfilter,1,false,nil,e:GetHandler()) end
	local sg=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,nil,e:GetHandler())
	Duel.Release(sg,REASON_COST)
end
function s.natg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tg=Duel.GetAttacker()
	Duel.SetTargetCard(tg)
	local dam=tg:GetAttack()
end
function s.naop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if Duel.NegateAttack() and tc:IsFaceup()
		and c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end