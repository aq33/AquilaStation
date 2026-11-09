// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - sprzątacz widzi odchody jako cel (wcześniej przejeżdżał obok nich)
/datum/unit_test/aquila_cleanbot_feces

/datum/unit_test/aquila_cleanbot_feces/Run()
	var/mob/living/simple_animal/bot/cleanbot/bot = allocate(/mob/living/simple_animal/bot/cleanbot)
	var/obj/effect/decal/cleanable/feces/poop = allocate(/obj/effect/decal/cleanable/feces)
	TEST_ASSERT(bot.process_scan(poop) == poop, "The cleanbot doesn't target feces")
	// Przełączenie opcji przebudowuje listę celów od nowa, odchody mają w niej zostać
	bot.blood = !bot.blood
	bot.get_targets()
	TEST_ASSERT(bot.process_scan(poop) == poop, "The cleanbot forgets feces after its settings change")

/// AQUILA - minimapa skalowana o ułamek ma się skalować po pikselach razem z nakładkami (wcześniej rozmyta)
/datum/unit_test/aquila_holomap_pixel_scale

/datum/unit_test/aquila_holomap_pixel_scale/Run()
	var/datum/station_holomap/holomap = new
	var/turf/spot = run_loc_floor_bottom_left
	holomap.initialize_holomap(spot.x, spot.y, spot.z, reinit_base_map = TRUE)
	TEST_ASSERT(holomap.base_map.appearance_flags & PIXEL_SCALE, "The holomap image is scaled with smoothing")
	TEST_ASSERT(holomap.base_map.appearance_flags & KEEP_TOGETHER, "The holomap overlays are scaled apart from the map")
	qdel(holomap)

/// AQUILA - każda latarka ma własną maskę cienia (wcześniej wspólna maska płaszczyzny: cień jednej latarki
/// wycinał światło drugiej i robił czarne kliny w oświetlonych miejscach)
/datum/unit_test/aquila_light_shadow_own_mask

/datum/unit_test/aquila_light_shadow_own_mask/Run()
	var/obj/effect/abstract/aq_light_shadow/first = allocate(/obj/effect/abstract/aq_light_shadow)
	var/obj/effect/abstract/aq_light_shadow/second = allocate(/obj/effect/abstract/aq_light_shadow)
	TEST_ASSERT(first.render_target && first.render_target != second.render_target, "Two lights share one shadow mask")
	TEST_ASSERT(copytext(first.render_target, 1, 2) == "*", "The shadow mask is drawn on the map")
	TEST_ASSERT(first.appearance_flags & KEEP_TOGETHER, "Without KEEP_TOGETHER BYOND 516 gives no mask for an object with overlays only")

	// Latarka obok nieprzezroczystego pola dostaje maskę z WŁASNEGO obiektu cienia, wyśrodkowaną na swoim kaflu
	var/turf/light_turf = run_loc_floor_bottom_left
	allocate(/obj/machinery/door/airlock, locate(light_turf.x + 1, light_turf.y, light_turf.z))
	var/obj/item/flashlight/torch = allocate(/obj/item/flashlight, light_turf)
	torch.on = TRUE
	torch.update_brightness()
	var/datum/component/overlay_lighting/light = torch.GetComponent(/datum/component/overlay_lighting)
	TEST_ASSERT(light?.aq_shadow?.loc == light_turf, "The flashlight next to a closed airlock casts no shadow")
	var/list/mask_filters = light.visible_mask.filters
	TEST_ASSERT(length(mask_filters) == 1, "The light spot has no shadow mask filter")
	var/mask = mask_filters[1]
	TEST_ASSERT(mask:render_source == light.aq_shadow.render_target, "The light spot is masked by another light's shadows")
	var/expected_x = -(torch.pixel_x + torch.pixel_w + light.directional_offset_x + (light.range - 1) * world.icon_size)
	TEST_ASSERT(mask:x == expected_x, "The shadow mask is not centred on the light's turf ([mask:x] instead of [expected_x])")

/// AQUILA - Alt+klik na pustej kieszeni nie wkłada do niej przedmiotu z ręki przeszukującego
/datum/unit_test/aquila_strip_search_empty_pocket

/// Zastępstwo okna TGUI: ui_act potrzebuje tylko statusu
/datum/aquila_fake_strip_ui
	var/status = UI_INTERACTIVE

/datum/unit_test/aquila_strip_search_empty_pocket/Run()
	var/mob/living/carbon/human/owner = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/searcher = allocate(/mob/living/carbon/human)
	owner.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(owner), ITEM_SLOT_ICLOTHING)
	var/obj/item/pen/pen = allocate(/obj/item/pen)
	searcher.put_in_active_hand(pen)
	var/datum/element/strippable/strippable = new
	strippable.items = GLOB.strippable_human_items
	var/datum/strip_menu/menu = new(owner, strippable)
	var/datum/aquila_fake_strip_ui/ui = new
	usr = searcher
	menu.ui_act("search", list("key" = STRIPPABLE_ITEM_LPOCKET), ui)
	TEST_ASSERT(pen.loc == searcher, "Alt+click on an empty pocket took the searcher's held item")
	TEST_ASSERT(isnull(owner.l_store), "Alt+click on an empty pocket put an item into it")
	qdel(menu)
	qdel(ui)

#undef TEST_ASSERT
