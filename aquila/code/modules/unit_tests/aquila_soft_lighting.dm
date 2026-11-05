// Upstreamowe makra są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc test modularny ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Miękkie światło i poświata: poziomy poświaty, emisyjne lampy i pocisków energetycznych
/datum/unit_test/aquila_soft_lighting

/datum/unit_test/aquila_soft_lighting/Run()
	TEST_ASSERT(isnull(aq_glow_settings(AQ_GLOW_OFF)), "Wyłączona poświata nie powinna mieć ustawień filtra")
	for(var/level in list(AQ_GLOW_LOW, AQ_GLOW_MEDIUM, AQ_GLOW_HIGH))
		var/list/settings = aq_glow_settings(level)
		TEST_ASSERT(length(settings) == 3, "Poziom poświaty [level] nie ma trzech ustawień bloomu")

	// Świecąca lampa ma emisyjną nakładkę, zgaszona nie
	var/obj/machinery/light/lamp = allocate(/obj/machinery/light)
	lamp.status = LIGHT_OK
	lamp.on = TRUE
	TEST_ASSERT(count_emissive(lamp.update_overlays()), "Włączona lampa nie ma emisyjnej nakładki")
	lamp.on = FALSE
	TEST_ASSERT(!count_emissive(lamp.update_overlays()), "Zgaszona lampa ma emisyjną nakładkę")

	// Laser świeci, kula nie
	var/obj/item/projectile/beam/laser/laser = allocate(/obj/item/projectile/beam/laser)
	TEST_ASSERT(count_emissive(laser.overlays), "Laser nie ma emisyjnej nakładki")
	var/obj/item/projectile/bullet/bullet = allocate(/obj/item/projectile/bullet)
	TEST_ASSERT(!count_emissive(bullet.overlays), "Kula ma emisyjną nakładkę")

/datum/unit_test/aquila_soft_lighting/proc/count_emissive(list/appearances)
	. = 0
	for(var/mutable_appearance/appearance as anything in appearances)
		if(appearance.plane == EMISSIVE_PLANE)
			.++

#undef TEST_ASSERT
