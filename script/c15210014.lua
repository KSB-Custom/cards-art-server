--AZTECA Eagle warrior
local s,id=GetID()
function s.initial_effect(c)
	--spsummon tokens
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.ttg)
	e1:SetOperation(s.top)
	c:RegisterEffect(e1)
end
function s.costfilter(c,ft,tp)
	return c:IsFaceup() and c:IsSetCard(0xF15)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroupCost(tp,s.costfilter,1,false,nil,nil,ft,tp) end
	local g=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,nil,nil,ft,tp)
	Duel.Release(g,REASON_COST)
end
function s.ttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id-4,0xF15,TYPES_TOKEN,100,100,3,RACE_PLANT,ATTRIBUTE_EARTH,POS_FACEUP) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
function s.top(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id-4,0xF15,TYPES_TOKEN,100,100,3,RACE_PLANT,ATTRIBUTE_EARTH,POS_FACEUP) then return end
	local t1=Duel.CreateToken(tp,id-4)
	local t2=Duel.CreateToken(tp,id-4)
	local token=t1,t2
		Duel.SpecialSummonStep(t1,0xF15,tp,tp,false,false,POS_FACEUP)
		Duel.SpecialSummonStep(t2,0xF15,tp,tp,false,false,POS_FACEUP)
	local e1=Effect.CreateEffect(t1)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(s.synlimit)
	t1:RegisterEffect(e1,true)
	local e2=Effect.CreateEffect(t2)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(s.synlimit)
	t2:RegisterEffect(e2,true)
		Duel.SpecialSummonComplete()
end
function s.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0xF15)
end