--Valkyrion the Unity Warrior 
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,99785935,39256679,11549357)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,false,nil,1)
	c:AddMustBeFusionSummoned()
	--You can only Fusion Summon or Special Summon by its alternate procedure once per turn
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.regcon)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	--Cannot be destroyed by opponent's card effects
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,4740489),0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--Return 3 banished cards to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE|PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	--Name becomes
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_CHANGE_CODE)
	e4:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
	e4:SetValue(75347539)
	c:RegisterEffect(e4)
end
s.listed_names={99785935,39256679,11549357}
--
function s.regcon(e)
	local c=e:GetHandler()
	return c:IsFusionSummoned() or c:IsSummonType(SUMMON_TYPE_SPECIAL+1)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	--Prevent another Fusion Summon or Special Summon by its alternate procedure that turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype) return c:IsOriginalCode(id) and (sumtype&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION or sumtype&SUMMON_TYPE_SPECIAL+1==SUMMON_TYPE_SPECIAL+1) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
--
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
function s.matfil(c,tp)
	return c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_SZONE) or aux.SpElimFilter(c,false,true))
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(s.matfil,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,nil,tp)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST|REASON_MATERIAL)
end
--
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if #sg>0 then
		Duel.SendtoGrave(sg,REASON_EFFECT|REASON_RETURN)
	end
end