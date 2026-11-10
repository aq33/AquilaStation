// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - sprite'y z tg dla narzędzi: pilot do drzwi zmienia wygląd z trybem, przedmioty mają grafikę w ręku i na pasku
/datum/unit_test/aquila_narzedzia_tg_sprites

/datum/unit_test/aquila_narzedzia_tg_sprites/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)

	// Pilot do drzwi: każdy tryb ma własny stan z tg, a stany gangtool-* zostają dla przedmiotów gangów
	var/list/device_states = icon_states('icons/obj/device.dmi')
	TEST_ASSERT("gangtool-white" in device_states, "Zniknął wspólny stan gangtool-white")
	for(var/remote_type in subtypesof(/obj/item/door_remote))
		var/obj/item/door_remote/remote = allocate(remote_type)
		if(!remote.remote_department)
			continue
		var/list/seen = list()
		for(var/i in 1 to 3)
			TEST_ASSERT(remote.icon_state in device_states, "[remote_type] ma stan bez grafiki: [remote.icon_state]")
			seen |= remote.icon_state
			remote.attack_self(user)
		TEST_ASSERT(length(seen) == 3, "[remote_type] nie zmienia wyglądu z trybem: [jointext(seen, ", ")]")

	// Szminka: stan w ręku nadąża za otwarciem
	var/list/lefthand = icon_states('icons/mob/inhands/items_lefthand.dmi')
	var/obj/item/lipstick/lipstick = allocate(/obj/item/lipstick)
	lipstick.attack_self(user)
	TEST_ASSERT(lipstick.item_state == "lipstickopen" && (lipstick.item_state in lefthand), "Otwarta szminka nie ma grafiki w ręku: [lipstick.item_state]")

	// W ręku i na pasku
	var/list/belt_states = icon_states('icons/mob/clothing/belt.dmi')
	var/list/mining_hands = icon_states('icons/mob/inhands/equipment/mining_lefthand.dmi')
	for(var/drill_type in list(/obj/item/pickaxe/drill, /obj/item/pickaxe/drill/diamonddrill, /obj/item/pickaxe/drill/jackhammer))
		var/obj/item/pickaxe/drill/drill = drill_type
		TEST_ASSERT(initial(drill.item_state) in mining_hands, "[drill_type] nie ma grafiki w ręku: [initial(drill.item_state)]")
		TEST_ASSERT(initial(drill.worn_icon_state) in belt_states, "[drill_type] nie ma grafiki na pasku: [initial(drill.worn_icon_state)]")
	for(var/pinpointer_type in list(/obj/item/pinpointer, /obj/item/pinpointer/crew, /obj/item/pinpointer/shuttle, /obj/item/pinpointer/nuke/syndicate))
		var/obj/item/pinpointer/pinpointer = pinpointer_type
		TEST_ASSERT(initial(pinpointer.worn_icon_state) in belt_states, "[pinpointer_type] nie ma grafiki na pasku: [initial(pinpointer.worn_icon_state)]")
	var/obj/item/radio/radio = allocate(/obj/item/radio)
	TEST_ASSERT(radio.item_state in lefthand, "Radio przenośne nie ma grafiki w ręku: [radio.item_state]")
	TEST_ASSERT(radio.icon_state in belt_states, "Radio przenośne nie ma grafiki na pasku: [radio.icon_state]")
	var/obj/item/sensor_device/monitor = allocate(/obj/item/sensor_device)
	TEST_ASSERT(monitor.item_state in icon_states(monitor.lefthand_file), "Monitor załogi nie ma grafiki w ręku: [monitor.item_state]")
	TEST_ASSERT(monitor.worn_icon_state in belt_states, "Monitor załogi nie ma grafiki na pasku: [monitor.worn_icon_state]")
	var/list/suit_storage = icon_states('icons/mob/clothing/belt_mirror.dmi')
	for(var/extinguisher_type in list(/obj/item/extinguisher, /obj/item/extinguisher/mini, /obj/item/extinguisher/advanced))
		var/obj/item/extinguisher/extinguisher = extinguisher_type
		TEST_ASSERT(initial(extinguisher.item_state) in suit_storage, "[extinguisher_type] nie ma grafiki w schowku skafandra: [initial(extinguisher.item_state)]")

#undef TEST_ASSERT
