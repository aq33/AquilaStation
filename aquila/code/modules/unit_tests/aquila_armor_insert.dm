// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Wkładka z kuźni: ochrona z materiału w kamizelce, zużycie od trafień w tułów, pęknięcie i spowolnienie od ciężkiego metalu
/datum/unit_test/aquila_armor_insert

/datum/unit_test/aquila_armor_insert/proc/make_insert(insert_type, material_type)
	var/obj/item/munition_part/body/armor_insert/insert = allocate(insert_type, run_loc_floor_bottom_left)
	insert.set_material(get_munition_material(material_type))
	insert.forging_finished(get_munition_quality(/datum/munition_quality), 1)
	return insert

/datum/unit_test/aquila_armor_insert/Run()
	var/obj/item/munition_part/body/armor_insert/heavy/titanium = make_insert(/obj/item/munition_part/body/armor_insert/heavy, /datum/material/titanium)
	TEST_ASSERT(titanium.is_finished(), "Wykuta wkładka nie jest gotowa")
	TEST_ASSERT(titanium.insert_max_integrity == 150, "Ciężka tytanowa wkładka ma [titanium.insert_max_integrity] wytrzymałości zamiast 150")
	TEST_ASSERT(!titanium.insert_slowdown(), "Tytan spowalnia")

	var/mob/living/carbon/human/wearer = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/clothing/suit/armor/vest/vest = allocate(/obj/item/clothing/suit/armor/vest, run_loc_floor_bottom_left)
	var/base_bullet = vest.armor.getRating("bullet")
	TEST_ASSERT(vest.aq_insert_slot, "Kamizelka nie ma slotu na wkładkę")
	titanium.forceMove(vest)
	vest.aq_insert = titanium
	vest.aq_apply_insert_effects()
	TEST_ASSERT(vest.armor.getRating("bullet") == base_bullet + 20, "Tytanowa wkładka dała [vest.armor.getRating("bullet") - base_bullet] ochrony przed pociskami zamiast 20")
	TEST_ASSERT(wearer.equip_to_slot_if_possible(vest, ITEM_SLOT_OCLOTHING), "Nie udało się założyć kamizelki")

	// Trafienie w tułów: 80 z 150 zostawia połowę ochrony
	wearer.apply_damage(80, BRUTE, BODY_ZONE_CHEST)
	TEST_ASSERT(titanium.insert_integrity == 70, "Po trafieniu za 80 wkładka ma [titanium.insert_integrity] wytrzymałości")
	TEST_ASSERT(vest.armor.getRating("bullet") == base_bullet + 10, "Zużyta wkładka daje [vest.armor.getRating("bullet") - base_bullet] ochrony zamiast 10")
	// Trafienie w głowę (poza kamizelką) jej nie zużywa
	wearer.apply_damage(30, BRUTE, BODY_ZONE_HEAD)
	TEST_ASSERT(titanium.insert_integrity == 70, "Trafienie w głowę zużyło wkładkę w kamizelce")
	// Kolejne trafienie ją rozbija, a kamizelka wraca do swojej ochrony
	wearer.apply_damage(80, BRUTE, BODY_ZONE_CHEST)
	TEST_ASSERT(QDELETED(titanium) && !vest.aq_insert, "Wkładka nie pękła po wyczerpaniu wytrzymałości")
	TEST_ASSERT(vest.armor.getRating("bullet") == base_bullet, "Po pęknięciu wkładki kamizelka ma [vest.armor.getRating("bullet")] zamiast [base_bullet]")

	// Złoto: ciężka wkładka spowalnia, lekka o mniej, a wyjęcie zdejmuje spowolnienie
	var/obj/item/munition_part/body/armor_insert/heavy/gold_heavy = make_insert(/obj/item/munition_part/body/armor_insert/heavy, /datum/material/gold)
	var/obj/item/munition_part/body/armor_insert/light/gold_light = make_insert(/obj/item/munition_part/body/armor_insert/light, /datum/material/gold)
	TEST_ASSERT(gold_heavy.insert_slowdown() > gold_light.insert_slowdown() && gold_light.insert_slowdown() > 0, "Spowolnienie złotych wkładek: ciężka [gold_heavy.insert_slowdown()], lekka [gold_light.insert_slowdown()]")
	var/base_slowdown = vest.slowdown
	gold_heavy.forceMove(vest)
	vest.aq_insert = gold_heavy
	vest.aq_apply_insert_effects()
	TEST_ASSERT(vest.slowdown == base_slowdown + gold_heavy.insert_slowdown(), "Złota wkładka nie spowolniła kamizelki")
	gold_heavy.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT(!vest.aq_insert && vest.slowdown == base_slowdown, "Wyjęcie wkładki nie zdjęło spowolnienia")

	// Hardsuit Syndykatu: zmiana trybu ustawia slowdown na stałą, a spowolnienie wkładki ma zostać (i zejść po wyjęciu)
	var/obj/item/clothing/suit/space/hardsuit/syndi/syndi_suit = allocate(/obj/item/clothing/suit/space/hardsuit/syndi, run_loc_floor_bottom_left)
	syndi_suit.activate_space_mode()
	var/space_slowdown = syndi_suit.slowdown
	gold_heavy.forceMove(syndi_suit)
	syndi_suit.aq_insert = gold_heavy
	syndi_suit.aq_apply_insert_effects()
	syndi_suit.activate_combat_mode()
	syndi_suit.activate_space_mode()
	TEST_ASSERT(syndi_suit.slowdown == space_slowdown + gold_heavy.insert_slowdown(), "Zmiana trybu hardsuitu skasowała spowolnienie wkładki ([syndi_suit.slowdown])")
	gold_heavy.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT(syndi_suit.slowdown == space_slowdown, "Po wyjęciu wkładki hardsuit ma [syndi_suit.slowdown] spowolnienia zamiast [space_slowdown]")

	// Rdzeń w powłoce: średnia profili ważona udziałem (powłoka ćwierć, rdzeń trzy czwarte); okno pieca oferuje wkładki
	var/datum/munition_material/layered = get_munition_layered(get_munition_material(/datum/material/iron), get_munition_material(/datum/material/diamond))
	TEST_ASSERT(layered.insert_profile()["bullet"] == 26.25, "Profil diamentu w powłoce z żelaza: [layered.insert_profile()["bullet"]] zamiast 26.25")
	var/list/inserts = GLOB.aq_forge_products["Wkładki do pancerza"]
	TEST_ASSERT((/obj/item/munition_part/body/armor_insert/heavy in inserts) && (/obj/item/munition_part/body/armor_insert/light in inserts), "Okno pieca nie oferuje obu wkładek")

#undef TEST_ASSERT
