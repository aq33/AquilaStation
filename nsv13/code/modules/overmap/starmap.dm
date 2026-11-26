#define SHIPINFO 0
#define STARMAP 1

/**
	Starmap code largely copied from FTL13's starmap, so credit to them! (And monster860...again)
*/

/datum/asset/simple/starmap
	assets = list(
		"space.png" = 'nsv13/icons/assets/space.png')

/obj/machinery/computer/ship/navigation
	name = "\improper konsola nawigacji FTL"
	desc = "Komputer, który łączy się z napędem Thirringa i pozwala okrętowi pokonywać ogromne odległości w kosmosie."
	icon_screen = "ftl"
	var/datum/star_system/selected_system = null
	var/screen = STARMAP
	var/can_control_ship = TRUE
	var/current_sector = SECTOR_NEUTRAL
	circuit = /obj/item/circuitboard/computer/ship/navigation

/obj/machinery/computer/ship/navigation/LateInitialize()
	addtimer(CALLBACK(src, PROC_REF(has_overmap)), 15 SECONDS)


/obj/machinery/computer/ship/navigation/can_interact(mob/user) //Override this code to allow people to use consoles when flying the ship.
	if(user in linked?.operators)
		return TRUE
	return ..()

/obj/machinery/computer/ship/navigation/public
	name = "konsola mapy gwiezdnej"
	desc = "Komputer, który pokazuje obecne położenie okrętu we wszechświecie."
	can_control_ship = FALSE

/obj/machinery/computer/ship/navigation/attack_hand(mob/user)
	ui_interact(user)

// AQ EDIT - okno starej mapy gwiazd z liniami (Starmap) usunięte: nawigacja, astrometria i menedżer układów używają mapy hex (aquila/code/modules/overmap/hexmap/hex_console.dm)

/obj/machinery/computer/ship/navigation/proc/is_in_range(datum/star_system/current_system, datum/star_system/system)
	return LAZYFIND(current_system?.adjacency_list, system?.name)

/obj/machinery/computer/ship/navigation/proc/is_visited(datum/star_system/system)
	return system.visited

/obj/machinery/computer/ship/navigation/proc/return_jump_check(datum/star_system/system)
	return ((SSovermap_mode.already_ended || SSovermap_mode.round_extended) && istype(system, /datum/star_system/outpost))

#undef SHIPINFO
#undef STARMAP
