// Upstreamowe makra są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc test modularny ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Miękkie światło i poświata: poziomy poświaty, emisyjne lampy i pocisków energetycznych, geometria cieni latarek
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
	// add_overlay kolejkuje nakładki dla SSoverlays, więc sprawdzamy kolejkę, nie gotowe overlays
	var/obj/item/projectile/beam/laser/laser = allocate(/obj/item/projectile/beam/laser)
	TEST_ASSERT(count_emissive(laser.add_overlays), "Laser nie ma emisyjnej nakładki")
	var/obj/item/projectile/bullet/bullet = allocate(/obj/item/projectile/bullet)
	TEST_ASSERT(!count_emissive(bullet.add_overlays), "Kula ma emisyjną nakładkę")

	// Cienie latarek: kafel obok światła ma trzy tylne ściany (po dwa trójkąty), ściana przy sąsiedniej ścianie nie rzuca cienia
	TEST_ASSERT(!length(aq_light_shadow_matrices(0, 0)), "Kafel światła rzuca cień")
	TEST_ASSERT(length(aq_light_shadow_matrices(1, 0)) == 6, "Kafel na wschód od światła powinien mieć 6 trójkątów cienia")
	TEST_ASSERT(length(aq_light_shadow_matrices(1, 0, 4)) == 4, "Ściana stykająca się z sąsiednią ścianą rzuca cień")
	TEST_ASSERT(length(aq_light_shadow_matrices(2, 2)) == 4, "Kafel po przekątnej powinien mieć 2 tylne ściany")
	// Koniec cienia nie dalej niż podany zasięg (kotwice maski liczą się z zasięgu)
	var/reach = 4 * world.icon_size
	var/center_offset = AQ_SHADOW_TRI_SIZE / 2 + AQ_SHADOW_TRI_MARGIN - world.icon_size / 2
	var/half_tri = AQ_SHADOW_TRI_SIZE / 2
	for(var/matrix/triangle as anything in aq_light_shadow_matrices(1, 0, 0, reach))
		// wierzchołki trójkąta z ikony po przekształceniu, względem środka kafla światła
		for(var/list/corner in list(list(-half_tri, -half_tri), list(half_tri, -half_tri), list(-half_tri, half_tri)))
			var/px = triangle.a * corner[1] + triangle.b * corner[2] + triangle.c + center_offset
			var/py = triangle.d * corner[1] + triangle.e * corner[2] + triangle.f + center_offset
			TEST_ASSERT(sqrt(px * px + py * py) <= reach + 1, "Trójkąt cienia sięga dalej niż zasięg plamy ([round(px)], [round(py)])")

/datum/unit_test/aquila_soft_lighting/proc/count_emissive(list/appearances)
	. = 0
	for(var/mutable_appearance/appearance as anything in appearances)
		// update_overlays() bywa z null z kodu bazowego. Blokada emisji przedmiotów (emissive_blocker) też leży na EMISSIVE_PLANE,
		// ale ma inną macierz koloru niż świecenie
		if(appearance?.plane == EMISSIVE_PLANE && appearance.color ~= GLOB.emissive_color)
			.++

#undef TEST_ASSERT
