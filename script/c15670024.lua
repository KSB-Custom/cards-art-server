--Alebrije King Mystic Creature
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf16),1,s.ffilter,2)
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.eqcon)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	aux.AddEREquipLimit(c,s.eqcon,s.eqval,s.equipop,e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--cannot be fusion material
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	--spsummon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.spcon)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)

	end
function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
	return c:GetAttribute(fc,sumtype,tp)~=0 and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetAttribute(fc,sumtype,tp),fc,sumtype,tp))
end
function s.fusfilter(c,attr,fc,sumtype,tp)
	return c:IsAttribute(attr,fc,sumtype,tp) and not c:IsHasEffect(511002961)
end
--Destroy
function s.valcheck(e,c)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	local lg=g:Filter(Card.IsSetCard,nil,0xf16)
	if #g==#lg then
		e:GetLabelObject():SetLabel(1)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel()==1
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
--equip
function s.eqval(ec,c,tp)
	return ec:IsControler(1-tp) and ec:IsPosition(POS_FACEUP_DEFENSE)
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup():Filter(s.eqfilter,nil)
	return #g==0
end
function s.eqfilter(c)
	return c:GetFlagEffect(id)~=0 
end
function s.filter(c)
	return c:IsAbleToChangeControler()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.GetFieldGroup(tp,LOCATION_HAND,0)~=0
		and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.equipop(c,e,tp,tc)
	local atk=tc:GetTextAttack()
	if atk<0 then atk=0 end
	if not c:EquipByEffectAndLimitRegister(e,tp,tc,id) then return end
	if atk>0 then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_SET_AVAILABLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
	end
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFieldGroup(tp,LOCATION_HAND,0)==0 then return end
	Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		s.equipop(c,e,tp,tc)
	end
end
--Sp SUMMON
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup():Filter(s.eqfilter,nil)
	return #g==1
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetHandler():GetEquipGroup():Filter(s.eqfilter,nil):GetFirst()
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummon(tp) then
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end