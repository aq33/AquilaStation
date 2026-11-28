// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Bronie z przeglądu kodów: pełne magazynki, awarie karabinu antycząstkowego w atmosferze, wyposażenie KNPC i ERT
/datum/unit_test/aquila_bronie_wybrane

/datum/unit_test/aquila_bronie_wybrane/Run()
	// broń => liczba naboi w magazynku startowym
	var/list/magazines = list(
		/obj/item/gun/ballistic/automatic/akms = 30,
		/obj/item/gun/ballistic/automatic/xl8 = 30,
		/obj/item/gun/ballistic/automatic/karabin_bojowy = 18,
		/obj/item/gun/ballistic/automatic/p90 = 50,
		/obj/item/gun/ballistic/automatic/atreides = 35,
		/obj/item/gun/ballistic/automatic/m44a = 99,
		/obj/item/gun/ballistic/automatic/m90/xm29 = 30,
	)
	for(var/gun_type in magazines)
		var/obj/item/gun/ballistic/gun = allocate(gun_type, run_loc_floor_bottom_left)
		TEST_ASSERT(gun.magazine, "[gun_type] nie ma magazynka")
		// jeden nabój siedzi w komorze
		TEST_ASSERT(gun.get_ammo() == magazines[gun_type], "[gun_type] ma [gun.get_ammo()] naboi zamiast [magazines[gun_type]]")

	var/obj/item/gun/ballistic/automatic/m90/xm29/xm29 = allocate(/obj/item/gun/ballistic/automatic/m90/xm29, run_loc_floor_bottom_left)
	TEST_ASSERT(istype(xm29.underbarrel, /obj/item/gun/ballistic/revolver/grenadelauncher/xm29), "XM29 nie ma swojego granatnika")
	TEST_ASSERT(xm29.underbarrel.magazine.max_ammo == 5, "Bęben XM29 mieści [xm29.underbarrel.magazine.max_ammo] granatów zamiast 5")

	// Karabin antycząstkowy: zacięcie nie zużywa ładunku, przepalony strzał zużywa jeden, zwarcie rozładowuje ogniwo
	var/obj/item/gun/energy/antyczastkowy/particle = allocate(/obj/item/gun/energy/antyczastkowy, run_loc_floor_bottom_left)
	var/obj/item/ammo_casing/energy/shot = particle.ammo_type[1]
	var/full = particle.cell.charge
	TEST_ASSERT(full == 1200, "Karabin antycząstkowy ma [full] ładunku zamiast 1200")
	TEST_ASSERT(particle.aq_antyczastka_awaria(5, null), "Zacięcie nie zatrzymało strzału")
	TEST_ASSERT(particle.cell.charge == full, "Zacięcie zużyło ładunek")
	TEST_ASSERT(particle.aq_antyczastka_awaria(30, null), "Przepalony strzał nie zatrzymał strzału")
	TEST_ASSERT(particle.cell.charge == full - shot.e_cost, "Przepalony strzał zużył [full - particle.cell.charge] zamiast [shot.e_cost]")
	TEST_ASSERT(particle.aq_antyczastka_awaria(70, null), "Zwarcie nie zatrzymało strzału")
	TEST_ASSERT(particle.cell.charge == 0, "Zwarcie zostawiło [particle.cell.charge] ładunku")

	// Abordażyści i ERT dostają nowe bronie
	var/list/expected = list(
		/mob/living/carbon/human/ai_boarder/syndicate/rifle = /obj/item/gun/ballistic/automatic/karabin_bojowy,
		/mob/living/carbon/human/ai_boarder/space_pirate/rifle = /obj/item/gun/ballistic/automatic/akms,
		/mob/living/carbon/human/ai_boarder/syndicate/commander = /obj/item/gun/ballistic/automatic/m90/xm29,
	)
	for(var/knpc_type in expected)
		var/mob/living/carbon/human/ai_boarder/knpc = allocate(knpc_type, run_loc_floor_bottom_left)
		TEST_ASSERT(locate(expected[knpc_type]) in knpc.GetAllContents(), "[knpc_type] nie ma przy sobie [expected[knpc_type]]")
		TEST_ASSERT(knpc.aq_knpc_main_gun(), "[knpc_type] nie ma broni z magazynkiem")
		qdel(knpc)

	var/mob/living/carbon/human/ai_boarder/smg = allocate(/mob/living/carbon/human/ai_boarder/syndicate/smg, run_loc_floor_bottom_left)
	var/list/smg_stuff = smg.GetAllContents()
	TEST_ASSERT((locate(/obj/item/gun/ballistic/automatic/p90) in smg_stuff) || (locate(/obj/item/gun/ballistic/automatic/c20r) in smg_stuff), "Abordażysta z PM-em nie ma ani P90, ani C-20r")
	qdel(smg)

	var/mob/living/carbon/human/ert = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	ert.equipOutfit(/datum/outfit/ert/security)
	TEST_ASSERT(istype(ert.s_store, /obj/item/gun/energy/laser/m19c4), "ERT ochrony nie nosi M19C4 (ma [ert.s_store])")
	TEST_ASSERT(istype(ert.back, /obj/item/storage/backpack) && (locate(/obj/item/gun/energy/disabler) in ert.back.contents), "Disabler ERT ochrony nie trafił do plecaka")

#undef TEST_ASSERT
