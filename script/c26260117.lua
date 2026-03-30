--Sparkhearts Makma
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon itself from GY 
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Change targeted monster's battle position
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={76103675}
function s.cfilter(c)
	return c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local cg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(cg,e,tp,2,4,s.rescon,0) end
end
function s.excludefilter(c)
	return not c:IsRace(RACE_SPELLCASTER) or not c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.rescon(sg,e,tp,mg)
	return (#sg==2 and not sg:IsExists(s.excludefilter,1,nil)) or sg:IsExists(Card.IsMonster,4,nil)
end
function s.filter(c,tp)
	return (c:IsFaceup() or c:IsControler(1-tp)) and c:IsCanChangePositionRush()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
end
function s.thfilter(c)
	return (c:IsCode(76103675) or c:IsSetCard(0xf27)) and c:IsAbleToHand()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local cg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	local g=aux.SelectUnselectGroup(cg,e,tp,2,4,s.rescon,1,tp,HINTMSG_TODECK,s.rescon)
	Duel.HintSelection(g)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)<1 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,2,nil,tp)
	Duel.HintSelection(g)
	if #g>0 and Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)>0
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=10 and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,4,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
--
function s.spcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf27) and c:IsLevelBelow(4) and c:IsAbleToHandAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_MZONE,0,nil)
	local eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
	for _,te in ipairs(eff) do
		local op=te:GetOperation()
		if not op or op(e,c) then return false end
	end
	local tp=c:GetControler()
	return aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local rg=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_MZONE,0,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_RTOHAND,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoHand(g,nil,REASON_COST)
	g:DeleteGroup()
end