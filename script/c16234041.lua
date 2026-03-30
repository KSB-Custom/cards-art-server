--Diablillo Melódico
--Scripted by EP Custom Cards
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_MONSTER),8,2,nil,nil,99)
	c:EnableReviveLimit()
	--Add
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(aux.dxmcostgen(1,1,s.slwc))
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
end
function s.tdfilter(c)
	return c:IsType(TYPE_FUSION)
end
function s.recfilter(c)
	return c:HasLevel() and c:IsAbleToHand()
end
function s.addfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end
function s.matfilter(c)
	return (c:GetReason()&0x40008)==0x40008 and c:IsMonster() and c:IsAbleToHand()
end
function s.slwc(e,og)
	e:SetLabel(og:GetFirst():IsType(TYPE_FUSION) and 1 or 0)
	e:SetLabelObject(og:GetFirst())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil)
	and Duel.IsExistingMatchingCard(s.recfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp,chk,og)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local recg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.recfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local addg=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,1,nil)
	recg:Merge(addg)
	if #recg>0 then
		Duel.SendtoHand(recg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,recg)
	end
	--check the material for additional effect
	if e:GetLabel()==1 and Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		--return fusion monster to extra deck
		local gg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		if Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil) 
		and Duel.GetMatchingGroupCount(s.tdfilter,tp,LOCATION_GRAVE,0,nil)>1 then
			local sg=gg:Select(tp,2,2,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		else
			local sg=gg:Select(tp,1,1,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		end
		--recover materials
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local mat=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.matfilter),tp,LOCATION_GRAVE,0,1,99,nil)
		Duel.SendtoHand(mat,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,mat)
	end
end