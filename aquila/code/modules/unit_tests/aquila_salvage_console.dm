/// AQUILA - wspólne okno zakłócacza EWAR i magnesu (aquila/code/modules/overmap/consoles/salvage_console.dm):
/// obie konsole dają dane obu zakładek, a akcja magnesu bez dostępu górnika nie przechodzi z żadnej z nich.
/datum/unit_test/aquila_salvage_console

/datum/unit_test/aquila_salvage_console/Run()
	var/obj/structure/overmap/small_craft/ship = allocate(/obj/structure/overmap/small_craft/combat/light)
	var/obj/machinery/computer/ship/salvage/salvage = allocate(/obj/machinery/computer/ship/salvage, get_step(run_loc_floor_bottom_left, EAST))
	var/obj/machinery/computer/ship/mineral_magnet/magnet = allocate(/obj/machinery/computer/ship/mineral_magnet, get_step(run_loc_floor_bottom_left, NORTH))
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	// Konsole w pokoju testowym nie leżą na żadnym okręcie, więc podpinamy je pod jeden okręt ręcznie
	salvage.linked = ship
	magnet.linked = ship
	magnet.target_location = get_step(run_loc_floor_bottom_left, WEST)

	var/list/from_salvage = salvage.ui_data(user)
	var/list/from_magnet = magnet.ui_data(user)
	if(from_salvage["default_tab"] != "boarding" || from_magnet["default_tab"] != "magnet")
		return Fail("Zła domyślna zakładka: zakłócacz [from_salvage["default_tab"]], magnes [from_magnet["default_tab"]]")
	for(var/list/data in list(from_salvage, from_magnet))
		if(!data["boarding_present"] || !islist(data["boarding"]) || !("ships" in data["boarding"]))
			return Fail("Okno z konsoli [data["default_tab"]] nie ma danych zakładki „Cele abordażu”")
		if(!data["magnet_present"] || !islist(data["magnet"]) || !("asteroids" in data["magnet"]))
			return Fail("Okno z konsoli [data["default_tab"]] nie ma danych zakładki „Magnes”")
	if(from_magnet["magnet_access"] || from_salvage["magnet_access"])
		return Fail("Człowiek bez karty ma dostęp do zakładki „Magnes”")

	// Akcja magnesu bez dostępu: odrzucona z obu konsol. Ref bez celu, więc z dostępem akcja nic nie przyciąga, tylko zwraca TRUE.
	var/datum/tgui/magnet_ui = new(user, magnet, "SalvageConsole")
	var/datum/tgui/salvage_ui = new(user, salvage, "SalvageConsole")
	usr = user
	var/blocked_magnet = magnet.ui_act("pull", list("ref" = "brak"), magnet_ui)
	var/blocked_salvage = salvage.ui_act("pull", list("ref" = "brak"), salvage_ui)
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.access = list(ACCESS_MINING)
	user.put_in_active_hand(card)
	var/allowed_magnet = magnet.ui_act("pull", list("ref" = "brak"), magnet_ui)
	var/allowed_salvage = salvage.ui_act("pull", list("ref" = "brak"), salvage_ui)
	var/list/with_card = salvage.ui_data(user)
	usr = null
	qdel(magnet_ui)
	qdel(salvage_ui)
	if(blocked_magnet || blocked_salvage)
		return Fail("Akcja magnesu przeszła bez dostępu górnika (z magnesu: [blocked_magnet], z zakłócacza: [blocked_salvage])")
	if(!allowed_magnet || !allowed_salvage)
		return Fail("Akcja magnesu nie przeszła z kartą górnika (z magnesu: [allowed_magnet], z zakłócacza: [allowed_salvage])")
	if(!with_card["magnet_access"])
		return Fail("Karta górnika nie daje dostępu do zakładki „Magnes”")
