--JellyBeans Kingdom
local s,id=GetID()
function s.initial_effect(c)
	--pendulum set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,1})
	e1:SetOperation(s.pcop)
	c:RegisterEffect(e1)
	-- No LP Cost
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_LPCOST_CHANGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(1,0)
	e2:SetValue(s.lpcostval)
	c:RegisterEffect(e2)
	--cannot be target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTargetRange(LOCATION_PZONE,0)
	e3:SetTarget(s.tgtg)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end
s.listed_series={0xf25}
function s.pcfilter(c)
	return c:IsSetCard(0xf25) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,2),nil)
	if not Duel.CheckPendulumZones(tp) then return end
	local g=Duel.GetMatchingGroup(s.pcfilter,tp,LOCATION_DECK,0,nil,tp)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=g:Select(tp,1,1,nil):GetFirst()
		if not tc then return end
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function s.aclimit(e,re,tp)
	return not re:GetHandler():IsSetCard(0xf25) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
--
function s.lpcostval(e,re,rp,val)
	if not re then return val end
	local rc=re:GetHandler()
	if re:IsActiveType(TYPE_MONSTER) and rc:IsSetCard(0xf25) then return 0 end
	return val
end
--
function s.tgtg(e,c)
	return c:IsSetCard(0xf25)
end