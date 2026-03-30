--JellyBeans Equipment
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--atkup
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(1000)
	c:RegisterEffect(e3)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetCondition(s.negcon)
	c:RegisterEffect(e1)
	--Atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(s.con)
	e2:SetValue(-1000)
	c:RegisterEffect(e2)
	--Normal summon 1 "JellyBeans" monster
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.nstg)
	e4:SetOperation(s.nsop)
	c:RegisterEffect(e4)
	--Direct Attack
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e5)
end
function s.negcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and not ec:IsSetCard(0xf25)
end
function s.con(e)
	local ph=Duel.GetCurrentPhase()
	local tp=Duel.GetTurnPlayer()
	return tp==e:GetHandlerPlayer() and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
function s.nsfilter(c)
	return c:IsSetCard(0xf25) and c:IsSummonable(true,nil)
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end