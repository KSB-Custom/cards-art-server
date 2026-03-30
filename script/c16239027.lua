--Sonata Diablillo
--Scripted by EP Custom Cards
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x231)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--add counter
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.ctcon)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
	--add 2 counters
	local e5=e2:Clone()
	e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e5:SetCondition(s.ctcon2)
	e5:SetOperation(s.ctop2)
	c:RegisterEffect(e5)
	local e6=e2:Clone()
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetCondition(s.ctcon2)
	e6:SetOperation(s.ctop2)
	c:RegisterEffect(e6)
	--spsummon
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,0))
	e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetCountLimit(1)
	e7:SetRange(LOCATION_SZONE)
	e7:SetTarget(s.sptg)
	e7:SetOperation(s.spop)
	c:RegisterEffect(e7)
	--Can be activated the turn it was Set by discarding 1 Impish card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetValue(function(e,c) e:SetLabel(1) end)
	e2:SetCondition(function(e) return Duel.IsExistingMatchingCard(s.selfspcostfilter,e:GetHandlerPlayer(),LOCATION_HAND,0,1,nil) end)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
s.listed_card_types={TYPE_SYNCHRO}
s.counter_place_list={0x231}
--
function s.selfspcostfilter(c)
	return c:IsSetCard(0xf19) and c:IsDiscardable()
end
--place 1 counter
function s.ctfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_TUNER) and c:IsControler(tp)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.ctfilter,1,nil,tp)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x231,1)
end
--place 2 counters
function s.ctfilter2(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsControler(tp)
end
function s.ctcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.ctfilter2,1,nil,tp)
end
function s.ctop2(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x231,2)
end
--sp summon
function s.filter(c,cc,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:HasLevel() and cc:IsCanRemoveCounter(tp,0x231,c:GetLevel(),REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler(),e,tp) end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil,e:GetHandler(),e,tp)
	local lvt={}
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local tlv=tc:GetLevel()
		lvt[tlv]=tlv
	end
	local pc=1
	for i=1,12 do
		if lvt[i] then lvt[i]=nil lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	e:GetHandler():RemoveCounter(tp,0x231,lv,REASON_COST)
	e:SetLabel(lv)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.sfilter(c,lv,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:GetLevel()==lv
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.sfilter),tp,LOCATION_GRAVE,0,1,1,nil,lv,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
