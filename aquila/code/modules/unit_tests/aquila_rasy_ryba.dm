// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b][message ? ": [message]" : ""]") }

/// Czy na warstwie włosów (klosz) jest nakładka o tym stanie ikony
/proc/aquila_rasy_ryba_has_dome_overlay(mob/living/carbon/human/H, state)
	var/list/standing = H.overlays_standing[HAIR_LAYER]
	if(!islist(standing))
		standing = list(standing)
	for(var/image/overlay in standing)
		if(overlay.icon_state == state)
			return TRUE
	return FALSE

/// Sprite'y pancerza, klosza i wszystkich ryb istnieją, a podglądy w oknie postaci da się wygenerować
/datum/unit_test/aquila_rasy_ryba_sprites

/datum/unit_test/aquila_rasy_ryba_sprites/Run()
	for(var/state in list("aquarian_head_m", "aquarian_head_f", "aquarian_chest_m", "aquarian_chest_f", "aquarian_l_arm", "aquarian_r_arm", \
		"aquarian_l_hand", "aquarian_r_hand", "aquarian_l_leg", "aquarian_r_leg", "aquarian_chest_m_paint", "aquarian_l_leg_paint", \
		"dome_back", "dome_front", "dome_item", "dome_item_front"))
		TEST_ASSERT(icon_exists(AQUARIAN_ICON, state), "Missing aquarian sprite [state]")
	for(var/fish in GLOB.aquarian_fish)
		TEST_ASSERT(icon_exists(AQUARIAN_ICON, "fish_[fish]"), "Missing fish sprite fish_[fish]")
		TEST_ASSERT(icon_exists(AQUARIAN_ICON, "fish_flop_[fish]"), "Missing flopping fish sprite fish_flop_[fish]")
		TEST_ASSERT(icon_exists(AQUARIAN_ICON, "fish_dead_[fish]"), "Missing dead fish sprite fish_dead_[fish]")
	var/datum/preference/choiced/fish_entry = GLOB.preference_entries_by_key["feature_aquarian_fish"]
	TEST_ASSERT(istype(fish_entry), "No preference entry for the fish")
	TEST_ASSERT_EQUAL(length(fish_entry.get_choices()), 10, "There should be ten fish to choose from")
	for(var/value in fish_entry.get_choices())
		TEST_ASSERT(isicon(fish_entry.icon_for(value)), "No preview icon for fish [value]")
	for(var/db_key in list("feature_aquarian_water", "feature_aquarian_armor"))
		TEST_ASSERT(istype(GLOB.preference_entries_by_key[db_key], /datum/preference/color), "No colour preference [db_key]")
	TEST_ASSERT(GLOB.goon_speech_voices["blub"], "The blub voice has no recordings")

/// Akwarianin: klosz z rybką na kołnierzu, oddychanie wodą, dolewanie, wycieki, chemia przez wodę, ekwipunek, kolor pancerza, zmiana rasy
/datum/unit_test/aquila_rasy_ryba

/datum/unit_test/aquila_rasy_ryba/Run()
	var/mob/living/carbon/human/H = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	H.set_species(/datum/species/aquarian)
	TEST_ASSERT(isaquarian(H), "set_species did not make an aquarian")
	TEST_ASSERT_EQUAL(H.get_species_goon_voice(), "blub", "An aquarian does not speak with the blub voice")
	var/obj/item/organ/brain/aquarian/dome = H.getorganslot(ORGAN_SLOT_BRAIN)
	TEST_ASSERT(istype(dome), "An aquarian has no dome instead of a brain")
	TEST_ASSERT_EQUAL(dome.water_amount(), AQUARIAN_DOME_VOLUME, "A fresh dome is not full of water")
	TEST_ASSERT_EQUAL(dome.fish_type, "goldfish", "A character without a saved fish did not get the goldfish")
	TEST_ASSERT(!H.getorganslot(ORGAN_SLOT_LUNGS), "An aquarian has lungs")
	TEST_ASSERT(aquila_rasy_ryba_has_dome_overlay(H, "fish_goldfish"), "The fish is not drawn in the dome")
	TEST_ASSERT(aquila_rasy_ryba_has_dome_overlay(H, "dome_front"), "The front of the dome is not drawn")

	// Inna ryba z wyglądu postaci po ponownym nadaniu rasy
	H.dna.features[FEATURE_AQUARIAN_FISH] = "clownfish"
	H.set_species(/datum/species/human)
	TEST_ASSERT(!aquila_rasy_ryba_has_dome_overlay(H, "fish_goldfish"), "The dome is still drawn on a human")
	TEST_ASSERT(!istype(H.getorganslot(ORGAN_SLOT_BRAIN), /obj/item/organ/brain/aquarian), "A human kept the dome as a brain")
	H.set_species(/datum/species/aquarian)
	dome = H.getorganslot(ORGAN_SLOT_BRAIN)
	TEST_ASSERT(istype(dome), "The dome did not come back after becoming an aquarian again")
	TEST_ASSERT(aquila_rasy_ryba_has_dome_overlay(H, "fish_clownfish"), "The chosen clownfish is not drawn")

	// Ekwipunek: hełm i maska nie, czapka tak
	var/obj/item/clothing/head/helmet/helmet = allocate(/obj/item/clothing/head/helmet)
	var/obj/item/clothing/head/hardhat/hat = allocate(/obj/item/clothing/head/hardhat)
	var/obj/item/clothing/mask/breath/mask = allocate(/obj/item/clothing/mask/breath)
	TEST_ASSERT(!H.dna.species.can_equip(helmet, ITEM_SLOT_HEAD, TRUE, H, TRUE), "An aquarian can wear a helmet over the dome")
	TEST_ASSERT(H.dna.species.can_equip(hat, ITEM_SLOT_HEAD, TRUE, H, TRUE), "An aquarian cannot wear a hat")
	TEST_ASSERT(!H.dna.species.can_equip(mask, ITEM_SLOT_MASK, TRUE, H, TRUE), "An aquarian can wear a mask")

	// Kolor pancerza: nakładka farby na częściach ciała
	H.dna.features[FEATURE_AQUARIAN_ARMOR] = "3366ff"
	H.update_body_parts(TRUE)
	var/obj/item/bodypart/chest/chest = H.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT_EQUAL(chest.aquarian_paint, "3366ff", "The armour colour did not reach the chest")
	var/painted = FALSE
	for(var/image/part in chest.get_limb_icon())
		if(findtext(part.icon_state, "_paint"))
			painted = TRUE
	TEST_ASSERT(painted, "The painted armour overlay is not drawn")

	// Brak wody: ryba się dusi, ciało dostaje oxyloss mimo braku oddychania powietrzem
	dome.reagents.remove_reagent(/datum/reagent/water, AQUARIAN_DOME_VOLUME)
	dome.on_life()
	H.dna.species.spec_life(H)
	TEST_ASSERT(dome.fish_oxyloss > 0, "An empty dome did not suffocate the fish")
	TEST_ASSERT(H.getOxyLoss() > 0, "The fish suffocating did not show up as oxygen damage")
	TEST_ASSERT(H.alerts["aquarian_water"], "No low water alert for an empty dome")

	// Dolewanie: kubek z wodą kliknięty we własną głowę wlewa się do klosza
	var/obj/item/reagent_containers/glass/beaker/beaker = allocate(/obj/item/reagent_containers/glass/beaker)
	beaker.reagents.add_reagent(/datum/reagent/water, 50)
	beaker.amount_per_transfer_from_this = 50
	H.zone_selected = BODY_ZONE_HEAD
	H.set_combat_mode(FALSE)
	H.attackby(beaker, H)
	TEST_ASSERT_EQUAL(dome.water_amount(), 50, "Pouring a beaker at the own head did not refill the dome")
	TEST_ASSERT_EQUAL(beaker.reagents.total_volume, 0, "The beaker was not emptied into the dome")
	var/oxyloss_before = dome.fish_oxyloss
	dome.on_life()
	TEST_ASSERT(dome.fish_oxyloss < oxyloss_before, "The fish does not recover with water in the dome")
	TEST_ASSERT(!H.alerts["aquarian_water"], "The low water alert stayed after refilling")

	// Reagenty w wodzie przechodzą do organizmu
	dome.reagents.add_reagent(/datum/reagent/medicine/epinephrine, 10)
	dome.on_life()
	TEST_ASSERT(H.reagents.has_reagent(/datum/reagent/medicine/epinephrine), "Chemicals poured into the dome did not reach the fish")

	// Zmielone jedzenie w wodzie: rybka je zjada i się najada, do ciała nic nie trafia
	H.set_nutrition(NUTRITION_LEVEL_HUNGRY)
	dome.reagents.add_reagent(/datum/reagent/consumable/nutriment/protein, 4)
	dome.on_life()
	TEST_ASSERT(H.nutrition > NUTRITION_LEVEL_HUNGRY, "Ground food poured into the dome did not feed the fish")
	TEST_ASSERT(!H.reagents.has_reagent(/datum/reagent/consumable/nutriment/protein), "Food from the dome went into the armour instead of the fish")

	// Pęknięty klosz cieknie
	var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
	head.receive_damage(brute = 45)
	var/water_before = dome.water_amount()
	dome.on_life()
	TEST_ASSERT(dome.cracked, "A badly dented head did not crack the dome")
	TEST_ASSERT(dome.water_amount() < water_before, "A cracked dome does not leak")
	TEST_ASSERT(H.alerts["aquarian_leak"], "A leaking dome shows no leak alert (no blood, so the bleeding alert never shows)")
	head.heal_damage(brute = 45)
	dome.on_life()
	TEST_ASSERT(!dome.cracked, "Repairing the head did not seal the dome")
	TEST_ASSERT(!H.alerts["aquarian_leak"], "The leak alert stayed after the dome was sealed")

	// Wgnieciony pancerz „krwawi” wodą, a po naprawie przestaje
	var/obj/item/bodypart/chest/body = H.get_bodypart(BODY_ZONE_CHEST)
	body.receive_damage(brute = 40)
	water_before = dome.water_amount()
	dome.on_life()
	TEST_ASSERT(dome.body_leaking, "A dented armour did not start leaking")
	TEST_ASSERT(dome.water_amount() < water_before, "A dented armour does not leak water from the dome")
	TEST_ASSERT(H.alerts["aquarian_leak"], "Leaking armour shows no leak alert")
	body.heal_damage(brute = 40)
	dome.on_life()
	TEST_ASSERT(!dome.body_leaking, "Repairing the armour did not stop the leak")
	TEST_ASSERT(!H.alerts["aquarian_leak"], "The leak alert stayed after the armour was repaired")

	// Gorąca woda paruje i parzy rybę
	dome.reagents.chem_temp = AQUARIAN_WATER_BOIL + 10
	H.bodytemperature = AQUARIAN_WATER_BOIL + 10
	water_before = dome.water_amount()
	dome.on_life()
	TEST_ASSERT(dome.water_amount() < water_before, "Boiling water did not evaporate")
	TEST_ASSERT(dome.damage > 0, "Boiling water did not hurt the fish")

	// Pełne leczenie dolewa wody
	H.fully_heal(TRUE)
	TEST_ASSERT_EQUAL(dome.water_amount(), AQUARIAN_DOME_VOLUME, "A full heal did not refill the dome")
	TEST_ASSERT_EQUAL(dome.fish_oxyloss, 0, "A full heal did not stop the fish suffocating")

	// Zniszczony pancerz: żywa ryba odpada razem z kloszem, a klosz pasuje do pustego pancerza
	H.death()
	aquarian_eject_dome(H)
	TEST_ASSERT(!H.getorganslot(ORGAN_SLOT_BRAIN), "The dome stayed on a destroyed armour")
	TEST_ASSERT_EQUAL(dome.loc, H.drop_location(), "The dome did not drop on the floor")
	var/mob/living/carbon/human/shell = aquarian_create_shell(run_loc_floor_bottom_left)
	TEST_ASSERT(isaquarian(shell) && !shell.getorganslot(ORGAN_SLOT_BRAIN), "A new armour should be an aquarian without a dome")
	dome.Insert(shell)
	TEST_ASSERT_EQUAL(aquarian_dome(shell), dome, "The dome did not fit the new armour")
	TEST_ASSERT_EQUAL(shell.dna.features[FEATURE_AQUARIAN_FISH], "clownfish", "The fish did not move with its dome")
	qdel(shell)

/// Rozbity klosz: rybka wypada, przeżyje w naczyniu z wodą, wraca do nowego klosza i pancerza, a w trybie walki da się ją dobić
/datum/unit_test/aquila_rasy_ryba_rozbity_klosz

/datum/unit_test/aquila_rasy_ryba_rozbity_klosz/Run()
	var/mob/living/carbon/human/H = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	H.set_species(/datum/species/aquarian)
	var/mob/living/carbon/human/helper = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/organ/brain/aquarian/dome = aquarian_dome(H)
	TEST_ASSERT(dome, "The aquarian has no dome")

	// Mocno rozbita głowa rozpryskuje klosz: rybka na podłodze, bez wody, pancerz bez klosza
	var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
	head.receive_damage(brute = AQUARIAN_SHATTER_DAMAGE)
	dome.on_life()
	TEST_ASSERT(dome.shattered, "A smashed head did not shatter the dome")
	TEST_ASSERT(!H.getorganslot(ORGAN_SLOT_BRAIN), "The fish stayed in the armour after the dome shattered")
	TEST_ASSERT_EQUAL(dome.loc, get_turf(H), "The fish did not fall on the floor")
	TEST_ASSERT_EQUAL(dome.water_amount(), 0, "A shattered dome still holds water")
	TEST_ASSERT(locate(/obj/item/shard) in get_turf(H), "A shattered dome left no glass shards")
	TEST_ASSERT_EQUAL(dome.icon_state, "fish_flop_goldfish", "A fish out of water is not flopping")
	TEST_ASSERT_EQUAL(H.stat, DEAD, "The armour kept working without its dome")
	dome.on_death()
	TEST_ASSERT(dome.fish_oxyloss > 0, "A fish out of water does not suffocate")

	// Do naczynia: za mało wody nie wystarczy, pełna zlewka tak
	var/obj/item/reagent_containers/glass/beaker/large/beaker = allocate(/obj/item/reagent_containers/glass/beaker/large)
	beaker.reagents.add_reagent(/datum/reagent/water, 5)
	dome.enter_vessel(beaker, helper)
	TEST_ASSERT(!dome.vessel, "The fish went into a beaker with almost no water")
	beaker.reagents.add_reagent(/datum/reagent/water, 75)
	dome.enter_vessel(beaker, helper)
	TEST_ASSERT_EQUAL(dome.vessel, beaker, "The fish did not go into a beaker of water")
	TEST_ASSERT_EQUAL(beaker.loc, dome, "The beaker is not carried with the fish")
	TEST_ASSERT_EQUAL(dome.water_amount(), 80, "The water did not come with the beaker")
	var/oxyloss_before = dome.fish_oxyloss
	dome.on_death()
	TEST_ASSERT(dome.fish_oxyloss < oxyloss_before, "The fish does not recover in a beaker of water")

	// Wylanie z naczynia: rybka znów na podłodze, zlewka w ręce
	dome.attack_self(helper)
	TEST_ASSERT(!dome.vessel, "Pouring the fish out left it in the beaker")
	TEST_ASSERT(beaker in helper.held_items, "The beaker did not stay in the hand")
	TEST_ASSERT_EQUAL(dome.water_amount(), 0, "The water stayed with the poured out fish")
	beaker.reagents.add_reagent(/datum/reagent/water, 50)
	dome.enter_vessel(beaker, helper)
	TEST_ASSERT_EQUAL(dome.vessel, beaker, "The fish did not go back into the beaker")

	// Do nowego klosza (z naczyniem): znów zwykły klosz z wodą, naczynie zostaje
	var/obj/item/reagent_containers/glass/aquarian_dome/new_dome = allocate(/obj/item/reagent_containers/glass/aquarian_dome)
	new_dome.reagents.add_reagent(/datum/reagent/water, 40)
	dome.enter_vessel(new_dome, helper)
	TEST_ASSERT(!dome.shattered, "The fish in a new dome is still treated as out of its dome")
	TEST_ASSERT(!dome.vessel, "The beaker stayed with the fish after moving it to a new dome")
	TEST_ASSERT(QDELETED(new_dome), "The empty dome was not used up")
	TEST_ASSERT_EQUAL(dome.water_amount(), 90, "The new dome did not get the water of the beaker and its own")
	TEST_ASSERT(!QDELETED(beaker) && beaker.loc != dome, "The beaker disappeared with the fish")
	TEST_ASSERT_EQUAL(dome.icon_state, "dome_item", "The restored dome is not drawn as a dome")
	var/mob/living/carbon/human/shell = aquarian_create_shell(run_loc_floor_bottom_left)
	dome.Insert(shell)
	TEST_ASSERT_EQUAL(aquarian_dome(shell), dome, "The restored dome did not fit a new armour")
	qdel(shell)

	// Leżący klosz rozbity skrzynką w trybie walki, potem rybka dobita
	var/mob/living/carbon/human/H2 = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	H2.set_species(/datum/species/aquarian)
	var/obj/item/organ/brain/aquarian/dome2 = aquarian_dome(H2)
	dome2.Remove(H2)
	dome2.forceMove(run_loc_floor_bottom_left)
	var/obj/item/storage/toolbox/toolbox = allocate(/obj/item/storage/toolbox)
	helper.combat_mode = TRUE
	for(var/i in 1 to 10)
		if(dome2.shattered)
			break
		dome2.attackby(toolbox, helper)
	TEST_ASSERT(dome2.shattered, "Hitting a loose dome with a toolbox in combat mode did not break it")
	dome2.attack_hand(helper)
	TEST_ASSERT(dome2.brain_death, "Squashing the fish in combat mode did not kill it")
	TEST_ASSERT_EQUAL(dome2.icon_state, "fish_dead_goldfish", "A dead fish is still flopping")
	helper.combat_mode = FALSE
	qdel(dome2)

	// Rybka na podłodze pokrojona nożem poza trybem walki to dwa kawałki sushi
	var/mob/living/carbon/human/H3 = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	H3.set_species(/datum/species/aquarian)
	var/obj/item/organ/brain/aquarian/dome3 = aquarian_dome(H3)
	dome3.shatter()
	var/obj/item/kitchen/knife/knife = allocate(/obj/item/kitchen/knife)
	knife.toolspeed = 0.01
	dome3.attackby(knife, helper)
	TEST_ASSERT(QDELETED(dome3), "Cutting the fish with a knife did not use it up")
	var/sushi = 0
	for(var/obj/item/food/nigiri_sushi/aquarian/piece in run_loc_floor_bottom_left)
		sushi++
		qdel(piece)
	TEST_ASSERT_EQUAL(sushi, AQUARIAN_SUSHI_PIECES, "Cutting the fish did not make sushi")
	for(var/obj/item/shard/shard in run_loc_floor_bottom_left)
		qdel(shard)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
