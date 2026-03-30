--FNO Heal Shaman
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	c:EnableReviveLimit()
	--Apply the effects of a "FNO" Ritual spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.rcon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--CANNOT ACTIVATE
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
	local e7=e2:Clone()
	e7:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	c:RegisterEffect(e7)
	--Change Type or Attribute
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(2)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_END_PHASE)
	e3:SetTarget(s.artg1)
	e3:SetOperation(s.arop1)
	c:RegisterEffect(e3)
	--Draw and gain LP
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,{id,4})
	e4:SetCondition(s.spcon2)
	e4:SetTarget(s.retg)
	e4:SetOperation(s.reop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e5)
	local e9=Effect.CreateEffect(c)
	e9:SetProperty(EFFECT_FLAG_DELAY)
	e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e9:SetCountLimit(1,{id,4})
	e9:SetCode(EVENT_RELEASE)
	e9:SetTarget(s.retg)
	e9:SetOperation(s.reop)
	c:RegisterEffect(e9)
	--heal
	local e12=Effect.CreateEffect(c)
	e12:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e12:SetCode(EVENT_SPSUMMON_SUCCESS)
	e12:SetProperty(EFFECT_FLAG_DELAY)
	e12:SetRange(LOCATION_PZONE)
	e12:SetCondition(s.hcondition)
	e12:SetOperation(s.hoperation)
	c:RegisterEffect(e12)
	local e13=e12:Clone()
	e13:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e13)
	local e14=e12:Clone()
	e14:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e14)
end
s.listed_series={0xf14}
--draw and recover
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetPreviousLocation()==LOCATION_HAND and (r&REASON_DISCARD)~=0
end
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,500)
end
function s.reop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.Recover(tp,500,REASON_EFFECT)
	end
end
--
function s.rcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
	or Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
end
function s.copfilter(c)
	return c:IsAbleToGraveAsCost() and c:IsSetCard(0xf14) and c:GetType()==TYPE_SPELL+TYPE_RITUAL and c:CheckActivateEffect(true,true,false)~=nil 
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then return Duel.IsExistingMatchingCard(s.copfilter,tp,LOCATION_DECK,0,1,nil) end
	local g=Duel.SelectMatchingCard(tp,s.copfilter,tp,LOCATION_DECK,0,1,1,nil)
	if not Duel.SendtoGrave(g,REASON_COST) then return end
	local te=g:GetFirst():CheckActivateEffect(true,true,false)
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	local tg=te:GetTarget()
	if tg then
		tg(e,tp,eg,ep,ev,re,r,rp,1)
	end
	te:SetLabel(e:GetLabel())
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if te then
		e:SetLabel(te:GetLabel())
		e:SetLabelObject(te:GetLabelObject())
		local op=te:GetOperation()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
		te:SetLabel(e:GetLabel())
		te:SetLabelObject(e:GetLabelObject())
	end
end
--prevent
function s.value(e,re,rp)
local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsRace(e:GetHandler():GetRace()) and rc:IsAttribute(e:GetHandler():GetAttribute())
end
function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local exc=(e:GetHandler():IsLocation(LOCATION_HAND) and not e:GetHandler():IsAbleToGraveAsCost()) and e:GetHandler() or nil
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,exc) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,exc)
end
--Change type or Attribute
function s.artg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	if Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))==0 then
		local rc=e:GetHandler():AnnounceAnotherRace(tp)
		e:SetLabel(0,rc)
	else
		local aat=e:GetHandler():AnnounceAnotherAttribute(tp)
		e:SetLabel(1,aat)
	end
end
function s.arop1(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
local op,dec=e:GetLabel()
	if op==0 and c:IsDifferentRace(dec) then
		-- Change monster type
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(dec)
		c:RegisterEffect(e1)
	elseif op==1 and c:IsAttributeExcept(dec) then
		-- Change attribute
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(dec)
		c:RegisterEffect(e1)
	end
end
--Heal
function s.hcondition(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
function s.hcondition2(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(Card.IsControler,1,nil,1-tp)
end
function s.hoperation(e,tp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Recover(tp,500,REASON_EFFECT)
end