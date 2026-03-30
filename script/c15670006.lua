--Alebrije Toon Beast
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--fusion from the pendulum zone
	local params = {aux.FilterBoolFunction(Card.IsSetCard,0xf16)}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e1:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e1)
	--Gain 500 LP each time you activate a "Fusion" Spell or effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_PZONE)
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCondition(function(e) return e:GetHandler():HasFlagEffect(1) end)
	e3:SetOperation(s.lpop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_POLYMERIZATION}
s.listed_series={0xf16}
--Gain LP
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsSpellEffect() and rp==tp and re:GetHandler():IsSetCard(0x46) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.Recover(tp,500,REASON_EFFECT)
	end
end