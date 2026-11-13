// Statek złomiarzy (u Goona baza „Magpie”): przerobiona kopia statku pirackiego (aquila/_maps/shuttles/salvager/salvager_default.dmm)
// z terminalem S.R.O.K.A., konsolą kapsuł desantowych i punktem powrotu teleportera ręcznego.
// FTL: z-level okrętu przy skoku się nie zmienia, więc statek złomiarzy „podczepia się” pod ślad FTL i zostaje w pobliżu.
// Na czas skoku prom złomiarzy nie może startować ani dokować.

// Osobny obszar (nie podtyp pirackiego), żeby cel piratów nie znalazł terminalu złomiarzy
/area/shuttle/salvager
	name = "Statek Złomiarzy"
	requires_power = TRUE
	canSmoothWithAreas = /area/shuttle/salvager

/datum/map_template/shuttle/pirate/salvager
	suffix = "salvager"
	name = "statek złomiarzy"
	/// Plik szablonu wkompilowany w .rsc (deploy.sh nie kopiuje aquila/_maps na serwer)
	var/salvager_map = 'aquila/_maps/shuttles/salvager/salvager_default.dmm'

/datum/map_template/shuttle/pirate/salvager/New(path = null, rename = null, cache = FALSE, admin_load = null)
	return ..(path || salvager_map, rename, cache, admin_load)

/obj/docking_port/mobile/pirate/salvager
	name = "statek złomiarzy"
	id = "salvagership"

/obj/machinery/computer/shuttle_flight/pirate/salvager
	name = "konsola statku złomiarzy"
	shuttleId = "salvagership"
	possible_destinations = "salvagership_home;syndicate_n;syndicate_ne;syndicate_nw;syndicate_s;syndicate_se;syndicate_sw;syndicatecutter_n;syndicatecutter_ne;syndicatecutter_nw;syndicatecutter_s;syndicatecutter_se;syndicatecutter_sw"

/obj/machinery/computer/shuttle_flight/pirate/salvager/ui_act(action, params)
	if((action in list("move", "launch", "dock", "gotoPort", "setTarget", "setTargetCoords")) && salvager_main_ship_jumping())
		say("Okręt jest w skoku FTL. Trzymamy się jego śladu, start dopiero po wyjściu ze skoku.")
		return TRUE
	return ..()

/proc/salvager_main_ship_jumping()
	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	return main?.ftl_drive?.ftl_state == FTL_STATE_JUMPING
