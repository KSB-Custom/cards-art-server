--AZTECA Tlaloc
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,2,s.matcheck)
	--cannot link material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetCondition(s.lkcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Increase its own ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.tkcost)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
end
	function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,0xF15,lc,sumtype,tp) and g:CheckDifferentPropertyBinary(Card.GetAttribute,lc,sumtype,tp)
end
function s.lkcon(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_LINK)
end
function s.atkfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,e:GetHandlerPlayer(),LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,nil)*200
end
s.listed_series={0xF15}
function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tkcostfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.tkcostfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	Duel.ConfirmCards(1-tp,g)
	e:SetLabel(g:GetFirst():GetCode())
end
function s.tkcostfilter(c,e,tp)
	return c:IsSetCard(0xF15) and c:IsType(TYPE_MONSTER) and 
	Duel.IsExistingMatchingCard(s.hspfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode()) and not c:IsPublic()
end
function s.hspfilter(c,e,tp,code)
	return c:IsSetCard(0xF15) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and not c:IsCode(code)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=Duel.IsExistingMatchingCard(s.hspfilter,tp,LOCATION_DECK,0,1,nil,e,tp,e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,tp,LOCATION_DECK)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.hspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	local c=e:GetHandler()
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_FIELD)
	ge1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	ge1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	ge1:SetDescription(aux.Stringid(id,2))
	ge1:SetTargetRange(1,0)
	ge1:SetTarget(s.splimit)
	ge1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ge1,tp)
	end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0xF15)
end