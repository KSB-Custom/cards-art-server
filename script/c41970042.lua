--RPG Magic Illusionist
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	c:EnableReviveLimit()
	Pendulum.AddProcedure(c,false)
	Fusion.AddProcMixN(c,true,true,s.ffilter,2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	--Special summon 1 monster from pendulum zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--disable activation field spell
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_FZONE)
	e2:SetTarget(s.distg)
	c:RegisterEffect(e2)
	--disable effect field spell
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_FZONE)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	--disable activation continuous spell/trap
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_PZONE)
	e4:SetTargetRange(0,LOCATION_SZONE)
	e4:SetTarget(s.distg2)
	c:RegisterEffect(e4)
	--disable effect continuous spell/trap
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAIN_SOLVING)
	e5:SetRange(LOCATION_PZONE)
	e5:SetTargetRange(0,LOCATION_SZONE)
	e5:SetOperation(s.disop2)
	c:RegisterEffect(e5)
	--maintain
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e6:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCountLimit(1)
	e6:SetOperation(s.mtop)
	c:RegisterEffect(e6)
end
s.listed_series={0xf14}
s.material_setcode=0xf14
--Special Summon card in the PZone
function s.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0xf14)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_PZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
--
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_ONFIELD,0,nil)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST+REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION or (e:GetHandler():GetLocation()~=LOCATION_EXTRA or e:GetHandler():IsFaceup())
end
--
function s.ffilter(c,fc,sumtype,tp)
	return c:IsSetCard(0xf14) and c:IsType(TYPE_PENDULUM)
	end
function s.distg(e,c)
	return c:IsSpell()
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if (tl&LOCATION_FZONE)~=0 and rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_FIELD) then
		Duel.NegateEffect(ev)
	end
	end
--negate continuous spell/trap
function s.distg2(e,c)
	return c:IsSpellTrap() and c:IsType(TYPE_CONTINUOUS)
end
function s.disop2(e,tp,eg,ep,ev,re,r,rp)
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if (tl&LOCATION_SZONE)~=0 and rp==1-tp and (re:IsActiveType(TYPE_SPELL+TYPE_CONTINUOUS) or re:IsActiveType(TYPE_SPELL+TYPE_CONTINUOUS)) then
		Duel.NegateEffect(ev)
	end
	end
--unaffected
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local flag=e:GetLabel()
	if (flag&0x4)~=0 then
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_IMMUNE_EFFECT)
		e4:SetValue(s.efilter)
		e4:SetOwnerPlayer(tp)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e4)
	end
end
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
--MANTEN
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CheckLPCost(tp,500) then
		Duel.PayLPCost(tp,500)
	else
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
