--Musician Impish Fanfare
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf19),1,1,Synchro.NonTuner(nil),1,99)
	--Toss 3 coins and apply the appropriate effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.con)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
s.listed_series={0x231}
s.toss_coin=true
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.filter(c,e,tp)
	return c:IsRace(RACE_FIEND) and (c:IsLevel(7) or c:IsLevel(9) or c:IsLevel(11)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.filter1(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsLevel(11) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.filter2(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsLevel(9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.filter3(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsLevel(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,3)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c1,c2,c3=Duel.TossCoin(tp,3)
	local total_heads=Duel.CountHeads(c1,c2,c3)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if total_heads==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) then
		--Negate its effects
		tc:NegateEffects(e:GetHandler())
		end
	elseif total_heads==2 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) then
		--Negate its effects
		tc:NegateEffects(e:GetHandler())
		end
	elseif total_heads==1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,s.filter3,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) then
		--Negate its effects
		tc:NegateEffects(e:GetHandler())
		end
	end
end