// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - sprite'y z tg: wiadro z zawartością, spryskiwacz na pasku, RPD w ręku, wyglądy księgi kapelana i roślin doniczkowych mają grafikę
/datum/unit_test/aquila_service_tg_sprites

/datum/unit_test/aquila_service_tg_sprites/Run()
	// Wiadro: nakładka zawartości dla połowy i pełnego wiadra
	var/list/fillings = icon_states('icons/obj/reagentfillings.dmi')
	var/obj/item/reagent_containers/glass/bucket/bucket = allocate(/obj/item/reagent_containers/glass/bucket)
	for(var/amount in list(bucket.volume * 0.6, bucket.volume))
		bucket.reagents.clear_reagents()
		bucket.reagents.add_reagent(/datum/reagent/water, amount)
		COMPILE_OVERLAYS(bucket) // nakładki czekają w kolejce SSoverlays, który nie działa w trakcie testu
		TEST_ASSERT(length(bucket.overlays), "Wiadro z [amount] j. wody nie ma nakładki zawartości")
	for(var/threshold in bucket.fill_icon_thresholds)
		TEST_ASSERT("bucket[threshold]" in fillings, "Brak stanu bucket[threshold] w reagentfillings.dmi")

	// Spryskiwacz na pasku i RPD w ręku / na pasku
	var/list/belt_states = icon_states('icons/mob/clothing/belt.dmi')
	var/obj/item/reagent_containers/spray/cleaner/cleaner = allocate(/obj/item/reagent_containers/spray/cleaner)
	TEST_ASSERT(cleaner.worn_icon_state in belt_states, "Spryskiwacz nie ma grafiki na pasku: [cleaner.worn_icon_state]")
	var/list/lefthand = icon_states('icons/mob/inhands/items_lefthand.dmi')
	var/list/righthand = icon_states('icons/mob/inhands/items_righthand.dmi')
	for(var/rpd_type in list(/obj/item/pipe_dispenser, /obj/item/pipe_dispenser/plumbing))
		var/obj/item/pipe_dispenser/rpd = allocate(rpd_type)
		TEST_ASSERT((rpd.icon_state in lefthand) && (rpd.icon_state in righthand), "[rpd_type] nie ma grafiki w ręku: [rpd.icon_state]")
		TEST_ASSERT(rpd.icon_state in belt_states, "[rpd_type] nie ma grafiki na pasku: [rpd.icon_state]")
	var/list/plant_hands = icon_states('icons/mob/inhands/weapons/plants_lefthand.dmi')
	var/obj/item/reagent_containers/spray/waterflower/flower = allocate(/obj/item/reagent_containers/spray/waterflower)
	TEST_ASSERT(flower.item_state in plant_hands, "Słonecznik-spryskiwacz nie ma grafiki w ręku: [flower.item_state]")

	// Księga kapelana: każdy wygląd z menu ma ikonę, a stan w ręku istnieje
	TEST_ASSERT(length(GLOB.biblenames) == length(GLOB.biblestates) && length(GLOB.biblestates) == length(GLOB.bibleitemstates), "Listy wyglądów księgi mają różne długości")
	TEST_ASSERT("Kojiki" in GLOB.biblenames, "Brak nowego wyglądu księgi z tg")
	var/list/bible_icons = icon_states('icons/obj/storage.dmi')
	var/list/bible_hands = icon_states('icons/mob/inhands/misc/books_lefthand.dmi')
	for(var/i in 1 to length(GLOB.biblestates))
		TEST_ASSERT(GLOB.biblestates[i] in bible_icons, "Wygląd księgi [GLOB.biblenames[i]] nie ma ikony [GLOB.biblestates[i]]")
	for(var/new_item_state in list("bible", "kojiki"))
		TEST_ASSERT(new_item_state in bible_hands, "Brak stanu księgi w ręku [new_item_state]")

	// Rośliny doniczkowe: każdy losowany wygląd ma grafikę
	var/list/plant_icons = icon_states('icons/obj/flora/plants.dmi')
	var/obj/item/kirbyplants/random/plant = allocate(/obj/item/kirbyplants/random)
	TEST_ASSERT(plant.icon_state in plant_icons, "Losowa roślina ma stan bez grafiki: [plant.icon_state]")
	for(var/plant_state in plant.states)
		TEST_ASSERT(plant_state in plant_icons, "Brak wyglądu rośliny [plant_state] w plants.dmi")
	TEST_ASSERT("plant-38" in plant.states, "Stare wyglądy roślin wypadły z puli losowania")

#undef TEST_ASSERT
