/datum/surgery/prosthetic_replacement
	name = "prosthetic replacement"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/add_prosthetic)
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_HEAD)
	requires_bodypart = FALSE //need a missing limb
	requires_bodypart_type = 0
	self_operable = TRUE

/datum/surgery/prosthetic_replacement/can_start(mob/user, mob/living/carbon/target)
	if(!iscarbon(target))
		return 0
	var/mob/living/carbon/C = target
	if(!isoozeling(target))
		if(!C.get_bodypart(user.zone_selected)) //can only start if limb is missing
			return 1


/datum/surgery_step/add_prosthetic
	name = "add prosthetic"
	implements = list(/obj/item/bodypart = 100, /obj/item/organ_storage = 100, /obj/item/chainsaw = 100, /obj/item/melee/synthetic_arm_blade = 100, /obj/item = 100) // AQUILA EDIT - any item (tgstation#91573)
	time = 32
	var/organ_rejection_dam = 0
	// AQUILA EDIT START - any item as a prosthetic arm (tgstation#91573)
	/// Items that are always allowed to be an arm replacement, even if they fail another requirement
	var/list/always_accepted_prosthetics = list(
		/obj/item/chainsaw, // the OG, too large otherwise
		/obj/item/melee/synthetic_arm_blade, // also too large otherwise
		/obj/item/food/pizzaslice, // he's turning her into a papa john's
	)

/datum/surgery_step/add_prosthetic/tool_check(mob/user, obj/item/tool)
	if(istype(tool, /obj/item/organ_storage))
		if(!length(tool.contents))
			return FALSE
		tool = tool.contents[1]
	if(tool.item_flags & (ABSTRACT|DROPDEL))
		return FALSE
	if(isbodypart(tool))
		return TRUE // auto pass - "intended" use case
	if(is_type_in_list(tool, always_accepted_prosthetics))
		return TRUE // auto pass - soulful prosthetics
	if(tool.w_class < WEIGHT_CLASS_NORMAL || tool.w_class > WEIGHT_CLASS_BULKY)
		return FALSE // too large or too small items don't make sense as a limb replacement
	var/datum/component/two_handed/two_handed = tool.GetComponent(/datum/component/two_handed)
	if(two_handed && (two_handed.wielded || two_handed.require_twohands))
		return FALSE // prevents exploits from weird edge cases - either unwield or get out
	return TRUE
	// AQUILA EDIT END

/datum/surgery_step/add_prosthetic/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(tool, /obj/item/organ_storage))
		if(!tool.contents.len)
			to_chat(user, "<span class='notice'>W [tool] nic nie ma!</span>")
			return -1
		var/obj/item/I = tool.contents[1]
		if(!isbodypart(I))
			to_chat(user, "<span class='notice'>[I] nie da się przymocować!</span>")
			return -1
		tool = I
	if(istype(tool, /obj/item/bodypart))
		var/obj/item/bodypart/BP = tool
		if(ismonkey(target))// monkey patient only accept organic monkey limbs
			if(!IS_ORGANIC_LIMB(BP) || BP.animal_origin != MONKEY_BODYPART)
				to_chat(user, "<span class='warning'>[BP] nie pasuje do morfologii pacjenta.</span>")
				return -1
		if(IS_ORGANIC_LIMB(BP))
			organ_rejection_dam = 10
			if(ishuman(target))
				if(BP.animal_origin)
					to_chat(user, "<span class='warning'>[BP] nie pasuje do morfologii pacjenta.</span>")
					return -1
				var/mob/living/carbon/human/H = target
				if(H.dna.species.id != BP.limb_id)
					organ_rejection_dam = 30

		if(target_zone == BP.body_zone) //so we can't replace a leg with an arm, or a human arm with a monkey arm.
			display_results(user, target, "<span class ='notice'>Zaczynasz wymieniać [strefa_pl(target_zone, TRUE)] [target] na [tool]...</span>",
				"[user] zaczyna wymieniać [strefa_pl(target_zone, TRUE)] [target] na [tool].",
				"[user] zaczyna wymieniać [strefa_pl(target_zone, TRUE)] [target].")
		else
			to_chat(user, "<span class='warning'>[tool] nie pasuje do tej części ciała ([strefa_pl(target_zone)]).</span>")
			return -1
	else if(target_zone == BODY_ZONE_L_ARM || target_zone == BODY_ZONE_R_ARM)
		display_results(user, target, "<span class='notice'>Zaczynasz mocować [tool] do [target]...</span>",
			"[user] zaczyna mocować [tool] do ciała [target] ([strefa_pl(target_zone)]).",
			"[user] zaczyna coś mocować do ciała [target] ([strefa_pl(target_zone)]).")
	else
		to_chat(user, "<span class='warning'>[tool] trzeba zamontować na ramieniu.</span>")
		return -1

/datum/surgery_step/add_prosthetic/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(tool, /obj/item/organ_storage))
		tool.icon_state = initial(tool.icon_state)
		tool.desc = initial(tool.desc)
		tool.cut_overlays()
		tool = tool.contents[1]
	if(istype(tool, /obj/item/bodypart) && user.temporarilyRemoveItemFromInventory(tool))
		var/obj/item/bodypart/L = tool
		L.attach_limb(target)
		if(organ_rejection_dam)
			target.adjustToxLoss(organ_rejection_dam)
		display_results(user, target, "<span class='notice'>Udaje ci się wymienić [strefa_pl(target_zone, TRUE)] [target].</span>",
			"[user] pomyślnie wymienia [strefa_pl(target_zone, TRUE)] [target] na [tool]!",
			"[user] pomyślnie wymienia [strefa_pl(target_zone, TRUE)] [target]!")
		target.cauterise_wounds()
		return 1
	else if(istype(tool, /obj/item/chainsaw) || istype(tool, /obj/item/melee/synthetic_arm_blade)) // AQUILA EDIT - chainsaws and arm blades keep their mounted versions
		var/obj/item/bodypart/L = target.newBodyPart(target_zone, FALSE, FALSE)
		L.is_pseudopart = TRUE
		L.attach_limb(target)
		user.visible_message("[user] kończy mocować [tool]!", "<span class='notice'>Mocujesz [tool].</span>")
		display_results(user, target, "<span class='notice'>Mocujesz [tool].</span>",
			"[user] kończy mocować [tool]!",
			"[user] kończy procedurę mocowania!")
		qdel(tool)
		if(istype(tool, /obj/item/chainsaw/energy/doom))
			var/obj/item/mounted_chainsaw/super/new_arm = new(target)
			target_zone == BODY_ZONE_R_ARM ? target.put_in_r_hand(new_arm) : target.put_in_l_hand(new_arm)
			target.cauterise_wounds()
			return 1
		else if(istype(tool, /obj/item/chainsaw/energy))
			var/obj/item/mounted_chainsaw/energy/new_arm = new(target)
			target_zone == BODY_ZONE_R_ARM ? target.put_in_r_hand(new_arm) : target.put_in_l_hand(new_arm)
			target.cauterise_wounds()
			return 1
		else if(istype(tool, /obj/item/chainsaw))
			var/obj/item/mounted_chainsaw/normal/new_arm = new(target)
			target_zone == BODY_ZONE_R_ARM ? target.put_in_r_hand(new_arm) : target.put_in_l_hand(new_arm)
			target.cauterise_wounds()
			return 1
		else if(istype(tool, /obj/item/melee/synthetic_arm_blade))
			var/obj/item/melee/arm_blade/new_arm = new(target,TRUE,TRUE)
			target_zone == BODY_ZONE_R_ARM ? target.put_in_r_hand(new_arm) : target.put_in_l_hand(new_arm)
			target.cauterise_wounds()
			return 1
		return 1
	// AQUILA EDIT START - any other item becomes the arm itself, loose until secured (tgstation#91573)
	if(!user.temporarilyRemoveItemFromInventory(tool))
		to_chat(user, "<span class='warning'>Nie potrafisz rozstać się z [tool]!</span>")
		return 0
	var/obj/item/bodypart/item_arm = target.make_item_prosthetic(tool, target_zone, PROSTHETIC_LOOSE_DROP_PROB)
	if(!item_arm)
		tool.forceMove(target.drop_location())
		return 0
	surgery.operated_bodypart = item_arm // so the surgery ends if the loose item falls off before it is secured
	target.cauterise_wounds()
	display_results(user, target, "<span class='notice'>Mocujesz [tool].</span>",
		"[user] kończy mocować [tool]!",
		"[user] kończy procedurę mocowania!")
	display_pain(target, "Czujesz coś bardzo dziwnego, gdy [tool] zajmuje miejsce ręki!", TRUE)
	surgery.steps += /datum/surgery_step/secure_arbitrary_prosthetic
	return 1

/// Optional last step after an item was attached as an arm: without it the item falls off on attacks
/datum/surgery_step/secure_arbitrary_prosthetic
	name = "secure prosthetic (suture/tape)"
	implements = list(
		/obj/item/stack/medical/suture = 100,
		/obj/item/stack/sticky_tape/super = 80,
		/obj/item/stack/sticky_tape = 50,
	)
	time = 48
	pain_message = "Coś przyszywa ci ciało do protezy (%ZONE%)!"

/datum/surgery_step/secure_arbitrary_prosthetic/tool_check(mob/user, obj/item/tool)
	var/obj/item/stack/stack = tool
	return istype(stack) && stack.amount >= 1

/datum/surgery_step/secure_arbitrary_prosthetic/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/bodypart/limb = target.get_bodypart(target_zone)
	if(!limb?.GetComponent(/datum/component/item_as_prosthetic_limb))
		to_chat(user, "<span class='warning'>Nie ma tu czego mocować.</span>")
		return -1
	display_results(user, target, "<span class='notice'>Zaczynasz mocować [limb] do ciała [target] przy pomocy [tool]...</span>",
		"[user] zaczyna mocować [limb] do ciała [target] przy pomocy [tool].",
		"[user] zaczyna coś mocować do ciała [target].")

/datum/surgery_step/secure_arbitrary_prosthetic/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/obj/item/bodypart/limb = target.get_bodypart(target_zone)
	var/datum/component/item_as_prosthetic_limb/prosthetic = limb?.GetComponent(/datum/component/item_as_prosthetic_limb)
	if(!prosthetic)
		return FALSE
	var/obj/item/stack/stack = tool
	stack.use(1)
	prosthetic.secure()
	display_results(user, target, "<span class='notice'>[limb] trzyma się teraz pewnie.</span>",
		"[user] pewnie mocuje [limb] do ciała [target]!",
		"[user] kończy mocowanie!")
	target.cauterise_wounds()
	return TRUE
	// AQUILA EDIT END
