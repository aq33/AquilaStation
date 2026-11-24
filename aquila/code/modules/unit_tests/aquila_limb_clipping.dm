/// Ręce mięsoczłowieka pod kombinezonem i skafandrem przycinają się do ludzkiego kształtu, a bez ubrania zostają pełne
/datum/unit_test/aquila_limb_clipping

/datum/unit_test/aquila_limb_clipping/Run()
	var/mob/living/carbon/human/H = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	H.set_species(/datum/species/beefman)
	var/obj/item/bodypart/l_arm/arm = H.get_bodypart(BODY_ZONE_L_ARM)
	if(arm.aq_covered_by_clothes())
		return Fail("A naked beefman arm counts as covered")
	var/obj/item/clothing/under/color/grey/jumpsuit = allocate(/obj/item/clothing/under/color/grey)
	H.equip_to_slot_if_possible(jumpsuit, ITEM_SLOT_ICLOTHING, disable_warning = TRUE)
	if(!(jumpsuit.body_parts_covered & ARM_LEFT))
		return // kombinezon bez rękawów: nie ma czego sprawdzać
	if(!arm.aq_covered_by_clothes())
		return Fail("A beefman arm under a jumpsuit does not count as covered")
	var/list/images = arm.get_limb_icon(FALSE)
	var/clipped = FALSE
	for(var/image/part in images)
		if(isicon(part.icon))
			clipped = TRUE
	if(!clipped)
		return Fail("A covered beefman arm was not clipped to the human shape")
	if(!findtext(H.generate_icon_key(arm), "-clip"))
		return Fail("The clipped arm shares the icon cache key with the bare one")
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/clothing/under/color/grey/human_suit = allocate(/obj/item/clothing/under/color/grey)
	human.equip_to_slot_if_possible(human_suit, ITEM_SLOT_ICLOTHING, disable_warning = TRUE)
	var/obj/item/bodypart/l_arm/human_arm = human.get_bodypart(BODY_ZONE_L_ARM)
	if(human_arm.aq_covered_by_clothes())
		return Fail("A human arm is clipped under clothes")
