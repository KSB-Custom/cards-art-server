--RPG Alpaca Force
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--FNO Xyz monsters you control are unaffected by your opponent's activated effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_XMATERIAL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e) return e:GetHandler():IsSetCard(0xf14) end)
	e2:SetValue(s.immval)
	c:RegisterEffect(e2)
	-- Special Summon Xyz
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.xsptg)
	e3:SetOperation(s.xspop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_BE_BATTLE_TARGET)
	e5:SetCondition(s.thcon2)
	c:RegisterEffect(e5)
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e1b:SetRange(LOCATION_SZONE)
	e1b:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1b:SetTarget(function(e,c) return e:GetHandler():GetEquipTarget()==c and c:IsSetCard(0xf14) end)
	e1b:SetLabelObject(e3)
	c:RegisterEffect(e1b)
	local e2b=e1b:Clone()
	e2b:SetLabelObject(e4)
	c:RegisterEffect(e2b)
	local e3b=e1b:Clone()
	e3b:SetLabelObject(e5)
	c:RegisterEffect(e3b)
	--Any Xyz Monster this card is equipped to becomes an Effect Monster
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_ADD_TYPE)
	e6:SetRange(LOCATION_SZONE)
	e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e6:SetTarget(function(e,c) return e:GetHandler():GetEquipTarget()==c end)
	e6:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e6)
end
s.listed_series={0xf14}
function s.immval(e,te)
	return te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and te:IsActivated()
end
function s.eqlimit(e,c)
	return e:GetLabelObject()==c
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xf14) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.Equip(tp,c,tc)
		--Add Equip limit
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		e1:SetLabelObject(tc)
		c:RegisterEffect(e1)
	end
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():GetBattleTarget():IsControler(tp)
end

function s.xspfilter(c,e,tp,mc)
	return c:IsType(TYPE_XYZ,c,SUMMON_TYPE_XYZ,tp) and c:IsSetCard(0xf14) and mc:IsCanBeXyzMaterial(c,tp)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.xsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		local c=e:GetHandler()
		local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
		return (#pg<=0 or (#pg==1 and pg:IsContains(c))) and Duel.IsExistingMatchingCard(s.xspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:IsImmuneToEffect(e) then return end
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	if #pg>1 or (#pg==1 and not pg:IsContains(c)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.xspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c):GetFirst()
	if sc then
		local mg=Group.FromCards(c)
		sc:SetMaterial(mg)
		Duel.Overlay(sc,mg)
		if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
			sc:CompleteProcedure()
		end
	end
end