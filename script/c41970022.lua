--RPG Heal Bard
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	c:EnableReviveLimit()
	--Discard and add Ritual Spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetCountLimit(1,{id,1})
	e1:SetCost(s.atcost)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTarget(s.thtg1)
	e1:SetOperation(s.thop1)
	c:RegisterEffect(e1)
	--Banish itself from GY and search spell
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,{id,2})
	e2:SetCondition(s.grcondition)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)
	--Lvl Change
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_LVCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,3})
	e3:SetTarget(s.lvtg)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
	--Return to hand if you Gain LP 
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_RECOVER)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1,{id,4})
	e4:SetTarget(s.sthtg)
	e4:SetOperation(s.sthop)
	c:RegisterEffect(e4)
	--Gain LP equal to opponent's monster's ATK
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,7))
	e5:SetCategory(CATEGORY_RECOVER)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,5})
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetTarget(s.rctg)
	e5:SetOperation(s.rcop)
	c:RegisterEffect(e5)
	--discarded, destroy
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,4))
	e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_TO_GRAVE)
	e7:SetCondition(s.spcon2)
	e7:SetCountLimit(1,{id,0})
	e7:SetTarget(s.sptg2)
	e7:SetOperation(s.spop2)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e8)
	local e9=Effect.CreateEffect(c)
	e9:SetProperty(EFFECT_FLAG_DELAY)
	e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e9:SetCountLimit(1,{id,0})
	e9:SetCode(EVENT_RELEASE)
	e9:SetTarget(s.sptg2)
	e9:SetOperation(s.spop2)
	c:RegisterEffect(e9)
end
s.listed_series={0xf14}

--destroy
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetPreviousLocation()==LOCATION_HAND and (r&REASON_DISCARD)~=0
end
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) 
	end
end
--SEARCH
function s.thfilter(c)
	return c:IsSetCard(0xf14) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function s.grcondition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--Return to the hand if you gain LP
function s.sthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.sthop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
--change level
function s.lvfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf14) and c:HasLevel()
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local op=0
		if tc:GetLevel()<=2 then
			op=Duel.SelectOption(tp,aux.Stringid(id,5))
		else
			op=Duel.SelectOption(tp,aux.Stringid(id,5),aux.Stringid(id,6))
		end
		local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if op==0 then
			e1:SetValue(2)
		else
			e1:SetValue(-2)
		end
		tc:RegisterEffect(e1)
		Duel.BreakEffect()
		if tc:IsFaceup() and not tc:IsType(TYPE_TUNER) and Duel.SelectYesNo(tp,aux.Stringid(id,7)) then
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_ADD_TYPE)
			e2:SetValue(TYPE_TUNER)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)	
		end
	end
end
--Gain LP
function s.rcfilter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
function s.rctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.rcfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.rcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetAttack())
end
function s.rcop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) and
		Duel.Recover(tp,tc:GetAttack(),REASON_EFFECT)~=0 and c:IsFaceup() and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.BreakEffect()
		local op=0
		if c:GetLevel()<=2 then
			op=Duel.SelectOption(tp,aux.Stringid(id,5))
		else
			op=Duel.SelectOption(tp,aux.Stringid(id,5),aux.Stringid(id,6))
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		if op==0 then
			e1:SetValue(2)
		else
			e1:SetValue(-2)
		end
		c:RegisterEffect(e1)
	end
end
--Add ritual spell
function s.thfilter2(c)
	return c:IsRitualSpell() and c:IsAbleToHand() and c:IsSetCard(0xf14)
end
function s.disfilter(c)
	return c:IsDiscardable()
end
function s.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.disfilter,1,1,REASON_COST+REASON_DISCARD)
end
function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--Gain LP
function s.filter(c,sp)
	if c:IsLocation(LOCATION_MZONE) then
		return c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
	else
		return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE)
	end
end
function s.reccon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,tp) 
end
function s.sum(c)
	if c:IsLocation(LOCATION_MZONE) then
		return c:GetAttack()
	else
		return c:GetPreviousAttackOnField()
	end
end
function s.recop1(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.filter,nil,tp)
	if #g>0 then
		local sum=g:GetSum(s.sum)
		Duel.Recover(tp,sum,REASON_EFFECT)
	end
end
