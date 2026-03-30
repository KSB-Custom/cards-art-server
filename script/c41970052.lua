--FNO Ranged Engineer
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Pendulum.AddProcedure(c,false)
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf14),1,1,Synchro.NonTunerEx(Card.IsSetCard,0xf14),1,99)
	--pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	--change position and decrease ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	--pendulum set/spsummon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.rptg)
	e4:SetOperation(s.rpop)
	c:RegisterEffect(e4)

	--PLACE IN PZONE IF LEAVE MZONE
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,4))
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_LEAVE_FIELD)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e6:SetCondition(s.pencon)
	e6:SetTarget(s.pentg)
	e6:SetOperation(s.penop)
	c:RegisterEffect(e6)
	--atk down
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetRange(LOCATION_PZONE)
	e7:SetCode(EFFECT_UPDATE_ATTACK)
	e7:SetTargetRange(0,LOCATION_MZONE)
	e7:SetValue(-600)
	c:RegisterEffect(e7)
	--splimit
	local e20=Effect.CreateEffect(c)
	e20:SetType(EFFECT_TYPE_FIELD)
	e20:SetRange(LOCATION_PZONE)
	e20:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e20:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e20:SetTargetRange(1,0)
	e20:SetTarget(s.splimit6)
	c:RegisterEffect(e20)
end
s.listed_series={0xf14}
function s.splimit6(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0xf14) and (sumtp&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end

--PLACE IT IN THE PZONE
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
	e:GetHandler():IsLocation(LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED+LOCATION_HAND)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return false end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
--change to Defense
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NOT(aux.FaceupFilter(Card.IsStatus,STATUS_BATTLE_DESTROYED)),tp,0,LOCATION_MZONE,1,nil) end
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		local tc=g:GetFirst()
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(-1000)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e2)
		end
	if #g>0 then
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	end
end
--Place or special summon
function s.rpfilter(c,e,tp)
	return c:IsSetCard(0xf14) and c:IsType(TYPE_PENDULUM) and (not c:IsForbidden()
		or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.rptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rpfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED+LOCATION_GRAVE)
end
function s.rpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,6))
		local g=Duel.SelectMatchingCard(tp,s.rpfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		local op=0
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
		else
			op=Duel.SelectOption(tp,aux.Stringid(id,1))
		end
		if op==0 then
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		else
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end