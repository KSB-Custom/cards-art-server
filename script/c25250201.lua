--Cloudian Castle
local s,id=GetID()
function s.initial_effect(c)
	c:SetCounterLimit(0x1019,10)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--counter
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.ctcon)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--Pendulum Monsters on the field gain 100 ATK for each counter on this card
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_CLOUDIAN))
	e4:SetValue(function(e,c) return e:GetHandler():GetCounter(COUNTER_FOG)*100 end)
	c:RegisterEffect(e4)
	--Add counter2
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetCode(EVENT_LEAVE_FIELD_P)
	e5:SetRange(LOCATION_FZONE)
	e5:SetOperation(s.addop2)
	c:RegisterEffect(e5)
	--Destroy replace
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_DESTROY_REPLACE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_FZONE)
	e6:SetTarget(s.desreptg)
	e6:SetOperation(s.desrepop)
	c:RegisterEffect(e6)
	--counter
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,0))
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetRange(LOCATION_FZONE)
	e7:SetCost(s.ctcost)
	e7:SetTarget(s.cttg2)
	e7:SetOperation(s.ctop2)
	c:RegisterEffect(e7)
end
s.listed_series={SET_CLOUDIAN}
s.counter_place_list={COUNTER_FOG}
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(aux.FaceupFilter(Card.IsSetCard,0x18),1,nil)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x1019,1)
end
--
function s.addop2(e,tp,eg,ep,ev,re,r,rp)
	local count=0
	for c in aux.Next(eg) do
		if not c:IsCode(id) and c:IsLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) then
			count=count+c:GetCounter(0x1019)
		end
	end
	if count>0 then
		e:GetHandler():AddCounter(0x1019,count)
	end
end
--
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsReason(REASON_REPLACE+REASON_RULE)
		and e:GetHandler():GetCounter(0x1019)>=3 end
	return true
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(ep,0x1019,3,REASON_EFFECT)
end
--
function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,COUNTER_FOG,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,COUNTER_FOG,1,REASON_COST)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_CLOUDIAN)
end
function s.cttg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,300)
end
function s.ctop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(COUNTER_FOG,1)
		Duel.BreakEffect()
		Duel.Recover(1-tp,300,REASON_EFFECT)
	end
end