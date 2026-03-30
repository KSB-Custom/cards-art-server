--FNO Heal Cleric
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	c:EnableReviveLimit()
	--recover
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_PZONE)
	e3:SetProperty(EFFECT_FLAG_NO_TURN_RESET+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTarget(s.tg)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
	--Give eff
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_EVENT_PLAYER+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(s.mtcon)
	e1:SetOperation(s.mtop)
	c:RegisterEffect(e1)
	--gain 100 lp
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_RECOVER)
	e4:SetType(EFFECT_TYPE_QUICK_F)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.rectg)
	e4:SetCondition(s.gcon)
	e4:SetOperation(s.gop)
	c:RegisterEffect(e4)
	--discarded place in Pzone
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,2))
	e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_TO_GRAVE)
	e7:SetCountLimit(1,{id,2})
	e7:SetCondition(s.spcon2)
	e7:SetTarget(s.sptg2)
	e7:SetOperation(s.spop2)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e8)
	local e9=Effect.CreateEffect(c)
	e9:SetProperty(EFFECT_FLAG_DELAY)
	e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e9:SetCountLimit(1,{id,2})
	e9:SetCode(EVENT_RELEASE)
	e9:SetTarget(s.sptg2)
	e9:SetOperation(s.spop2)
	c:RegisterEffect(e9)
	--Search 1 Ritual Spell from your Deck
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,3))
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e0:SetCode(EVENT_PHASE+PHASE_END)
	e0:SetRange(LOCATION_PZONE)
	e0:SetCountLimit(1,id)
	e0:SetTarget(s.thtg)
	e0:SetOperation(s.thop)
	c:RegisterEffect(e0)

end
s.listed_series={0xf14}
--gain Effect cannot be targeted
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return (r==REASON_XYZ or r==REASON_SYNCHRO or r==REASON_FUSION or r==REASON_RITUAL or r==REASON_LINK) 
	and e:GetHandler():GetReasonCard():IsSetCard(0xf14)
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	--Cannot be targeted by oonent's card effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3061)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetValue(s.indval)
	e1:SetOwnerPlayer(ep)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end
function s.indval(e,re,rp)
	return rp==1-e:GetOwnerPlayer()
end
--once per chain Gain 100 lp
function s.gcon(e,tp,eg,ep,ev,re,r,rp)
	local c=re:GetHandler()
	return ((re:IsHasType(EFFECT_TYPE_ACTIVATE) or Duel.IsChainNegatable(ev)))
		and c:IsSetCard(0xf14)
		end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(100)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,100)
end
function s.gop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
	local c=e:GetHandler()
	if c:HasLevel() and c:IsRelateToEffect(e) and c:IsFaceup() and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.BreakEffect()
		-- Increase its Level by 2
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_UPDATE_LEVEL)
		e3:SetValue(2)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e3)
	end
end
	--Gain 1500 LP
	function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1500)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1500)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end
--Discarded, place in PZone
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetPreviousLocation()==LOCATION_HAND and (r&REASON_DISCARD)~=0
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
	if e:GetHandler():IsLocation(LOCATION_GRAVE+LOCATION_EXTRA) then
	end
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return false end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
--Add ritual spell and return to hand
function s.thfilter(c)
	return c:IsRitualSpell() and c:IsAbleToHand() and c:IsSetCard(0xf14)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,2,tp,LOCATION_DECK|LOCATION_PZONE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		Duel.BreakEffect()
		if Duel.SendtoHand(c,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,c)
		end
	end
end