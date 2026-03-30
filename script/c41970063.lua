--FNO Party
local s,id=GetID()
function s.initial_effect(c)
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf14),8,2,s.xyzfilter,aux.Stringid(id,0),Xyz.InfiniteMats,s.xyzop)
	c:SetUniqueOnField(1,0,id)
	--Fusion Summon 1 "FNO" Fusion Monster 
	local params={fusfilter=s.fusionfilter,gc=Fusion.ForcedHandler}
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,0))
	e7:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetRange(LOCATION_MZONE)
	e7:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e7:SetCountLimit(1,id)
	e7:SetCondition(function() return Duel.IsMainPhase() end)
	e7:SetTarget(Fusion.SummonEffTG(params))
	e7:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e7)
	--PZone fusion material
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_PZONE,0)
	e3:SetTarget(s.mttg2)
	e3:SetValue(s.mtval)
	c:RegisterEffect(e3)
	--atkup
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(s.val)
	c:RegisterEffect(e5)
	--indestructable
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e6:SetCondition(s.incon)
	e6:SetValue(1)
	c:RegisterEffect(e6)
	--
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end)
	end
function s.fusionfilter(c)
	return c:IsSetCard(0xf14)
end
function s.xyzfilter(c,tp,xyzc)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	return #g>0 and g:GetMaxGroup(Card.GetAttack,nil):IsContains(c)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsMonsterEffect() or Duel.HasFlagEffect(rp,id) then return end
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if loc==LOCATION_HAND or loc==LOCATION_GRAVE then
		Duel.RegisterFlagEffect(rp,id,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.HasFlagEffect(1-tp,id) end
	return true
end
--Ritual
function s.effectfilter(e,c)
	local e=Duel.GetChainInfo(c,CHAININFO_TRIGGERING_EFFECT)
	return e:GetHandler():IsRitualSpell() and e:GetHandler():IsSetCard(0xf14)
end
--fusion
function s.mttg2(e,c)
	return e:GetHandler()
end
function s.mtval(e,c)
	if not c then return false end
	return c:IsSetCard(0xf14) and c:IsControler(e:GetHandlerPlayer())
end
--Sychro
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf14) and c:IsType(TYPE_PENDULUM)
end
--
function s.val(e,c)
	return (Duel.GetMatchingGroupCount(s.filter,c:GetControler(),LOCATION_ONFIELD,0,nil)+e:GetHandler():GetOverlayCount())*200
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xf14)
end
--
function s.incon(e)
	return e:GetHandler():GetOverlayCount()>0
end