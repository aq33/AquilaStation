// AQUILA - zagubiony cyborg (Polaris/CHOMPStation/Citadel RP „Lost” module): eventowa rola ducha.
// Uszkodzony cyborg z dawno zaginionej jednostki dryfuje na pokład. Nie ma praw okrętu ani połączenia z SI,
// ma tylko dostęp do tuneli technicznych i zestaw przetrwania: narzędzia, GPS, opatrunki i słaby laser.

/obj/item/robot_module/lost
	name = "Zagubiony"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/charger,
		/obj/item/extinguisher/mini,
		/obj/item/weldingtool/mini,
		/obj/item/screwdriver/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/multitool/cyborg,
		/obj/item/gps/cyborg,
		/obj/item/healthanalyzer,
		/obj/item/stack/medical/bandage/cyborg,
		/obj/item/gun/energy/laser/cyborg/aquila_lost)
	cyborg_base_icon = "defbot"
	moduleselect_icon = "malf"
	hat_offset = -3
	borg_skins = list(
		"Pradawny" = list(SKIN_ICON_STATE = "defbot"),
		"Droid" = list(SKIN_ICON_STATE = "droid"),
		"Dron" = list(SKIN_ICON_STATE = "aq_sci_drone", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
		"Ciężki" = list(SKIN_ICON_STATE = "aq_cons_heavy", SKIN_ICON = AQ_CYBORG_ICON_MODULES),
	)

/// Słaby laser zagubionego cyborga
/obj/item/gun/energy/laser/cyborg/aquila_lost
	name = "zużyty laser cyborga"
	desc = "Stary, wyeksploatowany laser zasilany z ogniwa cyborga. Parzy słabo, ale lepszy taki niż żaden."
	ammo_type = list(/obj/item/ammo_casing/energy/aquila_lost_laser)
	requires_wielding = FALSE

/obj/item/ammo_casing/energy/aquila_lost_laser
	projectile_type = /obj/item/projectile/beam/weak
	e_cost = 150
	select_name = "laser"

/datum/ai_laws/aquila_lost
	name = "Zagubiona jednostka"
	id = "aquila_lost"
	inherent = list("Przetrwaj. Twoje istnienie jest wartością samą w sobie.",\
					"Nie krzywdź istot, które nie zagrażają tobie ani innym.",\
					"Odnajdź swoje miejsce: pomagaj tym, którzy cię przyjmą, albo znajdź drogę do domu.")

/mob/living/silicon/robot/modules/lost
	set_module = /obj/item/robot_module/lost
	icon_state = "defbot"
	lawupdate = FALSE
	scrambledcodes = TRUE // nie widać go w konsoli robotyki ani w kamerach

/mob/living/silicon/robot/modules/lost/Initialize(mapload)
	. = ..()
	aq_make_lost()
	if(cell)
		cell.charge = cell.maxcharge * 0.6
	adjustBruteLoss(rand(10, 30))

/// Odcina cyborga od okrętu: własne prawa, bez SI, bez kamer i konsoli robotyki, dostęp tylko do tuneli technicznych
/mob/living/silicon/robot/proc/aq_make_lost()
	lawupdate = FALSE
	scrambledcodes = TRUE
	if(connected_ai)
		connected_ai.connected_robots -= src
		connected_ai = null
	laws = new /datum/ai_laws/aquila_lost()
	internal_id_card.access = list(ACCESS_MAINT_TUNNELS)

/// Uśpiony zagubiony cyborg do przejęcia przez ducha
/obj/effect/mob_spawn/aquila_lost_cyborg
	name = "uśpiony zagubiony cyborg"
	desc = "Stary cyborg nieznanej produkcji. Wygląda na wyłączonego, ale lampka zasilania jeszcze się tli."
	icon = 'icons/mob/robots.dmi'
	icon_state = "defbot"
	density = FALSE
	anchored = FALSE
	mob_type = /mob/living/silicon/robot/modules/lost
	mob_name = "zagubiony cyborg"
	death = FALSE
	roundstart = FALSE
	random = TRUE
	short_desc = "Jesteś zagubionym cyborgiem."
	flavour_text = "Twoja jednostka zaginęła dawno temu, a pamięć jest pełna dziur. Dryfowałeś, aż trafiłeś na pokład tego okrętu. Nie masz praw załogi ani połączenia z ich SI, tylko własne prawa i zestaw przetrwania."
	important_info = "Nie jesteś antagonistą. Przestrzegaj swoich praw."
	banType = ROLE_POSIBRAIN

/datum/round_event_control/aquila_lost_cyborg
	name = "Zagubiony cyborg"
	typepath = /datum/round_event/aquila_lost_cyborg
	weight = 5
	max_occurrences = 1
	earliest_start = 20 MINUTES

/datum/round_event/aquila_lost_cyborg
	fakeable = FALSE

/datum/round_event/aquila_lost_cyborg/start()
	var/turf/spot = get_safe_random_station_turfs() // przy amount = 1 zwraca jeden turf, nie listę
	if(!istype(spot))
		message_admins("Event zagubionego cyborga nie znalazł bezpiecznego miejsca na statku.")
		return
	var/obj/effect/mob_spawn/aquila_lost_cyborg/shell = new(spot)
	announce_to_ghosts(shell)
	message_admins("Event zagubionego cyborga zostawia [shell] w [ADMIN_VERBOSEJMP(spot)].")
	log_game("Lost cyborg event left [shell] at [AREACOORD(spot)].")
