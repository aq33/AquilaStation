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

/// Czy Grod może założyć tę rzecz w tym slocie (sprawdzenie bez zakładania)
/proc/grod_can_wear_check(mob/living/carbon/human/H, obj/item/I, slot)
	var/datum/species/grod/grod = H.dna.species
	return grod.grod_can_wear(I, slot)

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
	for(var/state in list("uniformblood", "helmetblood", "maskblood", "shoeblood", "bloodyhands", "handcuff1", "cocoon", "growth1", "growth2", "growth3"))
		TEST_ASSERT(icon_exists(GROD_ICON_EXTRAS, state), "Missing grod extra sprite [state]")
	TEST_ASSERT(GLOB.species_list[SPECIES_GROD], "The grod species is not registered")
	TEST_ASSERT_EQUAL(length(GLOB.grod_first), 24, "The grod name letters did not load")

/// Grod: korona na głowie, cechy, imię, język, ubrania tylko z jego sprite'ami, postawy, odłączenie korony i przejęcie ciała
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
	var/obj/item/clothing/head/cone/hardhat = allocate(/obj/item/clothing/head/cone)
	TEST_ASSERT(!H.equip_to_slot_if_possible(hardhat, ITEM_SLOT_HEAD, disable_warning = TRUE), "A grod put on a hat without a grod sprite")
	var/obj/item/clothing/head/grodhat/tophat = allocate(/obj/item/clothing/head/grodhat)
	TEST_ASSERT(H.equip_to_slot_if_possible(tophat, ITEM_SLOT_HEAD, disable_warning = TRUE), "A grod cannot wear a grod top hat")
	TEST_ASSERT(!aquila_grod_has_overlay(H, BODY_FRONT_LAYER, "m_grod_crown_crown_FRONT"), "The crown shows through the top hat")
	var/obj/item/clothing/head/hardhat/yellow_hat = allocate(/obj/item/clothing/head/hardhat)
	TEST_ASSERT(grod_can_wear_check(H, yellow_hat, ITEM_SLOT_HEAD), "A grod cannot wear a hard hat drawn for grods")

	// Kajdanki i krew rysowane dla ciała Groda
	var/obj/item/restraints/handcuffs/cuffs = allocate(/obj/item/restraints/handcuffs)
	cuffs.forceMove(H)
	H.handcuffed = cuffs
	H.update_handcuffed()
	var/mutable_appearance/cuff_overlay = H.overlays_standing[HANDCUFF_LAYER]
	TEST_ASSERT(istype(cuff_overlay) && cuff_overlay.icon == GROD_ICON_EXTRAS, "Handcuffs are not drawn with the grod sprite")
	H.handcuffed = null
	H.update_handcuffed()
	qdel(cuffs)
	jumpsuit.add_blood_DNA(list("Z" = "O+"))
	H.update_inv_w_uniform()
	var/mutable_appearance/uniform_overlay = H.overlays_standing[UNIFORM_LAYER]
	var/grod_blood = FALSE
	for(var/overlay in uniform_overlay.overlays)
		var/mutable_appearance/blood = new(overlay)
		if(blood.icon == GROD_ICON_EXTRAS && blood.icon_state == "uniformblood")
			grod_blood = TRUE
	TEST_ASSERT(grod_blood, "Blood on a grod jumpsuit is not drawn with the grod sprite")

	// Postawa ruchu (domyślna): dwie ręce i szybszy chód
	var/datum/species/grod/grod = H.dna.species
	TEST_ASSERT_EQUAL(grod.stance, GROD_STANCE_MOBILE, "A grod does not start in the mobile stance")
	TEST_ASSERT_EQUAL(length(H.held_items), 2, "A grod in the mobile stance does not have two hands")
	TEST_ASSERT(grod.speedmod < 0 && H.has_movespeed_modifier(MOVESPEED_ID_SPECIES), "A grod in the mobile stance is not faster than a human")
	TEST_ASSERT(!H.dna.species.walk_animation_legs, "A grod without legs swings its legs when walking")

	// Postawa pracy: cztery ręce (dłonie 3 i 4 na odnóżach), wolniej, bez blokowania, kosztuje trochę głodu
	H.set_nutrition(NUTRITION_LEVEL_FED)
	grod.stance_action.Activate()
	TEST_ASSERT_EQUAL(grod.stance, GROD_STANCE_INTERACT, "The stance action did not switch to the interact stance")
	TEST_ASSERT_EQUAL(length(H.held_items), GROD_HANDS, "A grod in the interact stance does not have four hands")
	TEST_ASSERT(H.has_movespeed_modifier(MOVESPEED_ID_GROD_INTERACT), "The interact stance does not slow the grod down")
	TEST_ASSERT(HAS_TRAIT(H, TRAIT_NOBLOCK), "A grod in the interact stance can still block")
	TEST_ASSERT(H.nutrition < NUTRITION_LEVEL_FED, "Switching to the interact stance cost no nutrition")
	TEST_ASSERT(istype(H.hand_bodyparts[3], /obj/item/bodypart/l_leg/grod), "The third hand is not on the grod's legs")
	var/obj/item/pen/pen = allocate(/obj/item/pen)
	TEST_ASSERT(H.put_in_hand(pen, 3), "A grod cannot hold a pen in the third hand")
	TEST_ASSERT_EQUAL(H.get_item_for_held_index(3), pen, "The pen is not in the third hand")
	var/obj/item/storage/toolbox/toolbox = allocate(/obj/item/storage/toolbox)
	TEST_ASSERT(H.put_in_hand(toolbox, 4), "A grod cannot hold a toolbox in the fourth hand")

	// Rzeczy w dłoniach przesunięte osobno dla każdego kierunku, a przy patrzeniu w górę schowane za ciałem
	H.setDir(SOUTH)
	var/list/offsets = pen.get_held_offsets()
	TEST_ASSERT(offsets["x"] == -2 && offsets["y"] == 1, "The third hand item is drawn in the wrong place facing south")
	H.setDir(NORTH)
	offsets = pen.get_held_offsets()
	TEST_ASSERT(offsets["x"] == 3 && offsets["y"] == 5, "The third hand item is drawn in the wrong place facing north")
	var/behind = FALSE
	for(var/mutable_appearance/hand_overlay in H.overlays_standing[HANDS_LAYER])
		if(hand_overlay.layer == -BODY_BEHIND_LAYER)
			behind = TRUE
	TEST_ASSERT(behind, "Turning north did not redraw the held items behind the body")
	H.setDir(SOUTH)

	// Powrót do postawy ruchu: rzeczy z odnóży spadają
	grod.stance_action.Activate()
	TEST_ASSERT_EQUAL(length(H.held_items), 2, "Going back to the mobile stance left four hands")
	TEST_ASSERT(pen.loc != H && toolbox.loc != H, "Items in the leg hands stayed held in the mobile stance")
	TEST_ASSERT(!HAS_TRAIT(H, TRAIT_NOBLOCK), "The mobile stance did not bring back blocking")

	// Odłączenie korony: gracz w pająku, ciało bez mózgu, potem przejęcie ciała człowieka, które choruje i w kokonie staje się Grodem
	var/mob/living/simple_animal/hostile/grod_crown/spider = grod_leave_body(H)
	TEST_ASSERT(spider?.crown, "The crown did not leave the body as a spider")
	TEST_ASSERT(!H.getorganslot(ORGAN_SLOT_BRAIN), "The crown is still in the body")
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	TEST_ASSERT(spider.try_infest(host), "The spider did not react to a body with a brain")
	TEST_ASSERT(!QDELETED(spider), "The spider entered a body that still has a brain")
	var/obj/item/organ/brain/old_brain = host.getorganslot(ORGAN_SLOT_BRAIN)
	old_brain.Remove(host, TRUE, TRUE)
	qdel(old_brain)
	spider.infest(host)
	TEST_ASSERT(!isgrod(host), "The infested human became a grod at once instead of through the cocoon")
	var/obj/item/organ/brain/grod/crown = host.getorganslot(ORGAN_SLOT_BRAIN)
	TEST_ASSERT(istype(crown), "The crown is not in the new body")
	TEST_ASSERT(crown.damage >= GROD_CROWN_INFEST_DAMAGE, "Taking a body did not hurt the crown")
	TEST_ASSERT(QDELETED(spider), "The spider stayed after taking a body")
	var/datum/disease/transformation/grod/mutation = locate() in host.diseases
	TEST_ASSERT(mutation, "The infested human did not catch the grod transformation")
	mutation.do_disease_transformation(host)
	TEST_ASSERT(isgrod(host), "The transformation did not make a grod")
	TEST_ASSERT_EQUAL(host.getorganslot(ORGAN_SLOT_BRAIN), crown, "The transformation replaced the crown with a new brain")
	var/obj/structure/grod_cocoon/cocoon = host.loc
	TEST_ASSERT(istype(cocoon), "The transformed grod is not in a cocoon")
	TEST_ASSERT(!(locate(/datum/disease/transformation/grod) in host.diseases), "The transformation stayed after the cocoon")
	qdel(cocoon)
	TEST_ASSERT(isturf(host.loc), "Breaking the cocoon did not let the grod out")

	// Śmierć pająka jest ostateczna: zostaje martwa korona
	var/mob/living/simple_animal/hostile/grod_crown/second = grod_leave_body(host)
	var/obj/item/organ/brain/grod/dropped = second.crown
	second.death()
	TEST_ASSERT(dropped.organ_flags & ORGAN_FAILING, "A dead crown spider left a working crown")
	qdel(dropped)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL

/// Zmiana rasy z Groda na inną zabiera drugą parę rąk, a rzecz z trzeciej ręki spada
/datum/unit_test/aquila_rasy_grod_hands_loss

/datum/unit_test/aquila_rasy_grod_hands_loss/Run()
	var/mob/living/carbon/human/H = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	H.set_species(/datum/species/grod)
	var/datum/species/grod/grod = H.dna.species
	grod.grod_set_stance(H, GROD_STANCE_INTERACT)
	var/obj/item/pen/pen = allocate(/obj/item/pen)
	H.put_in_hand(pen, 3)
	H.set_species(/datum/species/human)
	if(length(H.held_items) != 2)
		return Fail("A human kept [length(H.held_items)] hands after being a grod")
	if(pen.loc == H)
		return Fail("The item in the third hand stayed with a body that has no third hand")
	if(HAS_TRAIT(H, TRAIT_NOBLOCK) || H.has_movespeed_modifier(MOVESPEED_ID_GROD_INTERACT))
		return Fail("A human kept the grod interact stance penalties")

/// Korona posadzona w tacy z podłożem wyrasta w kokonie w nowe ciało Groda z tym samym graczem
/datum/unit_test/aquila_rasy_grod_replant

/datum/unit_test/aquila_rasy_grod_replant/Run()
	var/mob/living/carbon/human/H = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	H.set_species(/datum/species/grod)
	H.mind_initialize()
	var/datum/mind/mind = H.mind
	var/obj/item/organ/brain/grod/crown = H.getorganslot(ORGAN_SLOT_BRAIN)
	crown.Remove(H)
	crown.forceMove(run_loc_floor_bottom_left)
	if(!crown.brainmob || crown.brainmob.mind != mind)
		return Fail("A removed crown did not keep the player")
	var/mob/living/carbon/human/gardener = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, get_step(run_loc_floor_bottom_left, EAST))
	gardener.put_in_active_hand(crown)
	tray.attackby(crown, gardener)
	if(locate(/obj/structure/grod_cocoon) in tray.loc)
		return Fail("A crown was planted in a tray without substrate")
	var/datum/component/planter/planter = tray.GetComponent(/datum/component/planter)
	planter.set_substrate(/datum/plant_subtrate/dirt)
	tray.attackby(crown, gardener)
	var/obj/structure/grod_cocoon/cocoon = locate() in tray.loc
	if(!cocoon || crown.loc != cocoon)
		return Fail("Planting a crown in a tray with substrate did not grow a cocoon")
	cocoon.finish_growth()
	var/mob/living/carbon/human/body = mind.current
	if(!istype(body) || !isgrod(body))
		return Fail("The planted crown did not grow into a grod with the same player")
	if(body.getorganslot(ORGAN_SLOT_BRAIN) != crown)
		return Fail("The new body has a different crown")
	if(!QDELETED(cocoon) || !isturf(body.loc))
		return Fail("The grown grod did not leave the cocoon")
	qdel(body)
