--Alfil Diablillo/ Impish Bishop
--Scripted by EP Custom Cards
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon procedure
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetValue(s.hspval)
	c:RegisterEffect(e1)
	--Move itself to another monster zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(s.seqtg)
	e3:SetOperation(s.seqop)
	c:RegisterEffect(e3)
end
function s.filter(c,e,tp)
	return c:IsRace(RACE_FIEND) and (c:IsLevel(5) or c:IsLevel(6))
end
function s.hspval(e,c)
	local zone=0
	local left_right=0
	local tp=c:GetControler()
	local lg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	for tc in lg:Iter() do
		left_right=tc:IsInMainMZone() and 1 or 0
		zone=(zone|tc:GetColumnZone(LOCATION_MZONE,left_right,left_right,tp))
	end
	return 0,zone&0x1f
end
function s.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
end
--Move itself to 1 of your unused MMZ at random
function s.seqop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local numMonsterZones=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local randomZone=math.random(1,numMonsterZones)
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) or not Duel.CheckLocation(tp,LOCATION_MZONE,randomZone) then return end
	if Duel.NegateAttack() then
		Duel.MoveSequence(c,randomZone)
	end
end