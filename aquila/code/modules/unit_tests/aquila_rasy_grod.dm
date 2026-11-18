// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b][message ? ": [message]" : ""]") }

/// Czy na warstwie moba jest nakładka o tym stanie ikony
/proc/aquila_grod_has_overlay(mob/living/carbon/human/H, layer, state)
	var/list/standing = H.overlays_standing[layer]
	if(!islist(standing))
		standing = list(standing)
	for(var/mutable_appearance/overlay in standing)
		if(overlay.icon_state == state)
			return TRUE
	return FALSE

/// Sprite'y Groda: ciało, wszystkie korony, wzory, ogony i pająk-korona
/datum/unit_test/aquila_rasy_grod_sprites

/datum/unit_test/aquila_rasy_grod_sprites/Run()
	for(var/zone in list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND))
		TEST_ASSERT(icon_exists(GROD_ICON_BODY, "grod_[zone]"), "Missing grod body sprite grod_[zone]")
	for(var/name in GLOB.grod_crowns_list)
		var/datum/sprite_accessory/crown = GLOB.grod_crowns_list[name]
		TEST_ASSERT(icon_exists(crown.icon, "m_grod_crown_[crown.icon_state]_FRONT"), "Missing front sprite of crown [name]")
		TEST_ASSERT(icon_exists(crown.icon, "m_grod_crown_[crown.icon_state]_BEHIND"), "Missing back sprite of crown [name]")
		TEST_ASSERT(GLOB.grod_accessory_names[name], "Crown [name] has no Polish name")
	for(var/name in GLOB.grod_marks_list)
		var/datum/sprite_accessory/marks = GLOB.grod_marks_list[name]
		if(marks?.icon_state) // „Brak” jest na liście bez obiektu
			TEST_ASSERT(icon_exists(marks.icon, "m_grod_marks_[marks.icon_state]_ADJ"), "Missing sprite of marks [name]")
	for(var/name in GLOB.grod_tails_list)
		var/datum/sprite_accessory/tail = GLOB.grod_tails_list[name]
		TEST_ASSERT(icon_exists(tail.icon, "m_grod_tail_[tail.icon_state]_ADJ"), "Missing sprite of tail [name]")
	for(var/state in list("crown_spider", "crown_spider_dead"))
		TEST_ASSERT(icon_exists(GROD_ICON_CROWN_SPIDER, state), "Missing crown spider sprite [state]")
	TEST_ASSERT(GLOB.species_list[SPECIES_GROD], "The grod species is not registered")
	TEST_ASSERT_EQUAL(length(GLOB.grod_first), 24, "The grod name letters did not load")

/// Grod: korona na głowie, cechy, imię, język, ubrania tylko z jego sprite'ami, górne dłonie, odłączenie korony i przejęcie ciała
/datum/unit_test/aquila_rasy_grod

/datum/unit_test/aquila_rasy_grod/Run()
	var/mob/living/carbon/human/H = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	H.set_species(/datum/species/grod)
	TEST_ASSERT(isgrod(H), "set_species did not make a grod")
	TEST_ASSERT(istype(H.getorganslot(ORGAN_SLOT_BRAIN), /obj/item/organ/brain/grod), "A grod has no crown for a brain")
	TEST_ASSERT_EQUAL(H.dna.features["grod_crown"], "Crown", "A grod without saved features got no crown")
	TEST_ASSERT(aquila_grod_has_overlay(H, BODY_FRONT_LAYER, "m_grod_crown_crown_FRONT"), "The crown is not drawn on the head")
	TEST_ASSERT(aquila_grod_has_overlay(H, BODY_ADJ_LAYER, "m_grod_tail_regular_ADJ"), "The tail is not drawn")
	TEST_ASSERT(findtext(H.dna.species.random_name(), "'"), "A grod name does not follow the letter'syllable scheme")
	TEST_ASSERT(H.has_language(/datum/language/pohlan), "A grod does not know Poh'lan")

	// Ubrania: kombinezon to kamizelka Groda, czapka bez jego sprite'u i strój wierzchni nie wchodzą, cylinder tak
	var/obj/item/clothing/under/color/grey/jumpsuit = allocate(/obj/item/clothing/under/color/grey)
	TEST_ASSERT(H.equip_to_slot_if_possible(jumpsuit, ITEM_SLOT_ICLOTHING, disable_warning = TRUE), "A grod cannot wear a jumpsuit")
	var/list/sprite = grod_worn_sprite(jumpsuit, "uniform", H.dna.species)
	TEST_ASSERT(sprite && sprite[1] == 'aquila/icons/mob/species/grod/onmob_grod_under.dmi', "The jumpsuit is not drawn with the grod sprite")
	var/obj/item/clothing/suit/space/eva/suit = allocate(/obj/item/clothing/suit/space/eva)
	TEST_ASSERT(!H.equip_to_slot_if_possible(suit, ITEM_SLOT_OCLOTHING, disable_warning = TRUE), "A grod put on a space suit")
	var/obj/item/clothing/head/hardhat/hardhat = allocate(/obj/item/clothing/head/hardhat)
	TEST_ASSERT(!H.equip_to_slot_if_possible(hardhat, ITEM_SLOT_HEAD, disable_warning = TRUE), "A grod put on a hat without a grod sprite")
	var/obj/item/clothing/head/grodhat/tophat = allocate(/obj/item/clothing/head/grodhat)
	TEST_ASSERT(H.equip_to_slot_if_possible(tophat, ITEM_SLOT_HEAD, disable_warning = TRUE), "A grod cannot wear a grod top hat")
	TEST_ASSERT(!aquila_grod_has_overlay(H, BODY_FRONT_LAYER, "m_grod_crown_crown_FRONT"), "The crown shows through the top hat")

	// Górne dłonie: mała rzecz wchodzi, duża nie, po śmierci wszystko spada
	var/datum/component/grod_pockets/pockets = H.GetComponent(/datum/component/grod_pockets)
	TEST_ASSERT(pockets, "A grod has no upper hands")
	var/obj/item/pen/pen = allocate(/obj/item/pen)
	H.put_in_active_hand(pen)
	pockets.use_pocket(1, pen)
	TEST_ASSERT_EQUAL(pockets.item_slots[1], pen, "A pen did not go into the upper hand")
	TEST_ASSERT_EQUAL(pen.loc, H, "The pen in the upper hand is not carried")
	var/obj/item/storage/toolbox/toolbox = allocate(/obj/item/storage/toolbox)
	H.put_in_active_hand(toolbox)
	pockets.use_pocket(2, toolbox)
	TEST_ASSERT(isnull(pockets.item_slots[2]), "A toolbox fit into the upper hand")

	// Odłączenie korony: gracz w pająku, ciało bez mózgu, potem przejęcie ciała człowieka, które staje się Grodem
	var/mob/living/simple_animal/hostile/grod_crown/spider = grod_leave_body(H)
	TEST_ASSERT(spider?.crown, "The crown did not leave the body as a spider")
	TEST_ASSERT(!H.getorganslot(ORGAN_SLOT_BRAIN), "The crown is still in the body")
	TEST_ASSERT(isnull(pockets.item_slots[1]), "The upper hands did not let go after the body died")
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	TEST_ASSERT(spider.try_infest(host), "The spider did not react to a body with a brain")
	TEST_ASSERT(!QDELETED(spider), "The spider entered a body that still has a brain")
	var/obj/item/organ/brain/old_brain = host.getorganslot(ORGAN_SLOT_BRAIN)
	old_brain.Remove(host, TRUE, TRUE)
	qdel(old_brain)
	spider.infest(host)
	TEST_ASSERT(isgrod(host), "The infested human did not become a grod")
	var/obj/item/organ/brain/grod/crown = host.getorganslot(ORGAN_SLOT_BRAIN)
	TEST_ASSERT(istype(crown), "The crown is not in the new body")
	TEST_ASSERT(crown.damage >= GROD_CROWN_INFEST_DAMAGE, "Taking a body did not hurt the crown")
	TEST_ASSERT(QDELETED(spider), "The spider stayed after taking a body")

	// Śmierć pająka jest ostateczna: zostaje martwa korona
	var/mob/living/simple_animal/hostile/grod_crown/second = grod_leave_body(host)
	var/obj/item/organ/brain/grod/dropped = second.crown
	second.death()
	TEST_ASSERT(dropped.organ_flags & ORGAN_FAILING, "A dead crown spider left a working crown")
	qdel(dropped)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
