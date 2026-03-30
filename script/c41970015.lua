--FNO Eternal Guardians
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	c:RegisterEffect(e1)
	--Synchro Summon using a "FNO" monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sctg)
	e2:SetOperation(s.scop)
	c:RegisterEffect(e2)
	--fusion
	local params = {nil,aux.FilterBoolFunction(Card.IsSetCard,0xf14)}
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.spcon)
	e3:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e3:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e3)
	--Discarded: set
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))
	e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_TO_GRAVE)
	e7:SetCountLimit(1,{id,3})
	e7:SetCondition(s.spcon2)
	e7:SetOperation(s.setop)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e8)
	--spsummon limit
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,9))
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetRange(LOCATION_SZONE)
	e9:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e9:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e9:SetTargetRange(1,0)
	e9:SetTarget(s.sumlimit)
	c:RegisterEffect(e9)
	aux.addContinuousLizardCheck(c,LOCATION_MZONE,s.lizfilter)
	end

--Synchro summon
function s.checkaddition(tp,sg,sc)
	return sg:IsExists(Card.IsSetCard,1,nil,0xf14)
end
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		Synchro.CheckAdditional=s.checkaddition
		local res=Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil)
		Synchro.CheckAdditional=nil
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	Synchro.CheckAdditional=s.checkaddition
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SynchroSummon(tp,sg:GetFirst())
	else
		Synchro.CheckAdditional=nil
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
--cannot sum
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0xf14) 
end
function s.lizfilter(e,c)
	return not c:IsSetCard(0xf14)
end
	--DISCARDED, set
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetPreviousLocation()==LOCATION_HAND and (r&REASON_DISCARD)~=0
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
	end
end