--I´m Having Trouble with My Fields Being Destroyed!
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.effcost)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_names={26260101,26260102}
function s.deckmatfilter(c)
	return c:IsSetCard(0xf27) and c:IsMonster() and c:IsReleasableByEffect()
end
function s.extragroup(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.deckmatfilter,tp,LOCATION_DECK,0,nil)
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_DECK)
	mat:Sub(mat2)
	Duel.ReleaseRitualMaterial(mat)
	Duel.SendtoGrave(mat2,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL|REASON_RELEASE)
end
function s.tributelimit(e,tp,g,sc)
	return #g<=2,#g>2
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	local params1={lvtype=RITPROC_EQUAL,filter=s.deckmatfilter,location=LOCATION_DECK,matfilter=s.deckmatfilter}
	local params2={lvtype=RITPROC_EQUAL,filter=s.deckmatfilter,matfilter=s.deckmatfilter,extrafil=s.extragroup,extraop=s.extraop}
	local b1=not Duel.HasFlagEffect(tp,id) and Ritual.Target(params1)(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=not Duel.HasFlagEffect(tp,id+1) and Ritual.Target(params2)(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local cost_skip=e:GetLabel()~=-100
	local params1={lvtype=RITPROC_EQUAL,filter=s.deckmatfilter,location=LOCATION_DECK,matfilter=s.deckmatfilter}
	local params2={lvtype=RITPROC_EQUAL,filter=s.deckmatfilter,matfilter=s.deckmatfilter,extrafil=s.extragroup,extraop=s.extraop}
	local b1=(cost_skip or not Duel.HasFlagEffect(tp,id))
		and Ritual.Target(params1)(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=(cost_skip or not Duel.HasFlagEffect(tp,id+1))
		and Ritual.Target(params2)(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then e:SetLabel(0) return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		if not cost_skip then Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
		Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
	elseif op==2 then
		if not cost_skip then Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
		Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_DECK)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		local params1={lvtype=RITPROC_EQUAL,filter=s.deckmatfilter,location=LOCATION_DECK,matfilter=s.deckmatfilter}
		Ritual.Operation(params1)(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		local params2={lvtype=RITPROC_EQUAL,filter=s.deckmatfilter,matfilter=s.deckmatfilter,extrafil=s.extragroup,extraop=s.extraop}
		Ritual.Operation(params2)(e,tp,eg,ep,ev,re,r,rp)
	end
	--"Passion Girl and Passion" monsters cannot be destroyed by battle
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(3000)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetTarget(s.indtg)
	e1:SetValue(aux.indoval)
	Duel.RegisterEffect(e1,tp)
end
function s.indtg(e,c)
	return c:IsCode(26260101) or c:IsCode(26260102)
end
function s.stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	--Cannot be destroyed by battle
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3000)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		Duel.RegisterEffect(e1,tp)
end
function s.stage2aux(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	--Cannot be destroyed by battle
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3002)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetValue(aux.tgoval)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		Duel.RegisterEffect(e1,tp)
end