// Port BeeStation/NSV13#2677: chłodnice i magazyny ciepła dla broni energetycznych (energy_weapon_heat.dm).
// Łączy się je multitoolem z bronią w tym samym obszarze (multitool z bronią w buforze). Postawione na mapie łączą się same
// z najbliższą bronią energetyczną w tym samym obszarze. Liczy się tylko włączone, zasilone i sprawne urządzenie.

/obj/machinery/cooling
	name = "urządzenie podprzestrzenne"
	desc = "Urządzenie podprzestrzenne."
	icon = 'aquila/icons/obj/munitions/subspace_cooling.dmi'
	icon_state = "cooler"
	density = TRUE
	idle_power_usage = 2000
	var/obj/machinery/ship_weapon/energy/parent
	var/on = TRUE

/obj/machinery/cooling/cooler
	name = "chłodnica podprzestrzenna"
	desc = "Wyrzuca do podprzestrzeni ogromne ilości ciepła, które wytwarza broń energetyczna."
	circuit = /obj/item/circuitboard/machine/cooling

/obj/machinery/cooling/storage
	name = "podprzestrzenny magazyn ciepła"
	desc = "Przechowuje w podprzestrzeni ciepło broni energetycznej, więc broń wytrzymuje więcej strzałów przed przegrzaniem."
	icon_state = "storage"
	circuit = /obj/item/circuitboard/machine/cooling/storage

/obj/machinery/cooling/Initialize(mapload)
	. = ..()
	if(mapload)
		return INITIALIZE_HINT_LATELOAD

/obj/machinery/cooling/LateInitialize()
	. = ..()
	auto_link()

/// Łączy się z bronią energetyczną w tym samym obszarze: najpierw z tą, która ma najmniej podłączonych urządzeń,
/// potem z najbliższą. Kilka chłodnic z mapy rozkłada się więc po kolei na wszystkie działa w pomieszczeniu.
/obj/machinery/cooling/proc/auto_link()
	if(parent)
		return
	var/area/our_area = get_area(src)
	var/obj/machinery/ship_weapon/energy/best
	var/best_links
	var/best_dist
	for(var/obj/machinery/ship_weapon/energy/weapon in range(7, src))
		if(!weapon.maintainable || get_area(weapon) != our_area || length(weapon.cooling) >= ENERGY_MAX_COOLING_LINKS)
			continue
		var/links = length(weapon.cooling)
		var/dist = sqrt((weapon.x - x) ** 2 + (weapon.y - y) ** 2)
		if(!best || links < best_links || (links == best_links && dist < best_dist))
			best = weapon
			best_links = links
			best_dist = dist
	if(best)
		link_to(best)

/obj/machinery/cooling/proc/link_to(obj/machinery/ship_weapon/energy/weapon)
	unlink()
	parent = weapon
	weapon.cooling |= src

/obj/machinery/cooling/proc/unlink()
	if(parent)
		parent.cooling -= src
	parent = null

/// Czy urządzenie teraz chłodzi (włączone, zasilone, sprawne, przykręcone i w strefie zasilania broni)
/obj/machinery/cooling/proc/is_working()
	if(parent && get_area(parent) != get_area(src))
		return FALSE
	return on && anchored && !(machine_stat & (BROKEN|NOPOWER|MAINT))

/obj/machinery/cooling/Destroy()
	unlink()
	return ..()

/obj/machinery/cooling/on_deconstruction()
	unlink()
	return ..()

/obj/machinery/cooling/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(panel_open)
		to_chat(user, "<span class='notice'>Zamknij panel [src], zanim go włączysz.</span>")
		return
	on = !on
	to_chat(user, "<span class='notice'>Wciskasz włącznik [src]. [on ? "Urządzenie rusza." : "Urządzenie gaśnie."]</span>")
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	update_icon()

/obj/machinery/cooling/examine(mob/user)
	. = ..()
	. += "Jest [on ? "włączony" : "wyłączony"]."
	if(parent)
		. += "Przekaźnik termiczny jest połączony z [parent]."
	else
		. += "Przekaźnik termiczny czeka na połączenie. Zapisz broń energetyczną w multitoolu i użyj go na urządzeniu."

/obj/machinery/cooling/multitool_act(mob/living/user, obj/item/I)
	if(!multitool_check_buffer(user, I))
		return TRUE
	var/obj/item/multitool/tool = I
	if(!istype(tool.buffer, /obj/machinery/ship_weapon/energy))
		to_chat(user, "<span class='warning'>W buforze multitoola nie ma broni energetycznej.</span>")
		return TRUE
	var/obj/machinery/ship_weapon/energy/weapon = tool.buffer
	if(get_area(weapon) != get_area(src))
		to_chat(user, "<font color = #666633>-% Nie można łączyć urządzeń między strefami zasilania. %-</font color>")
		return TRUE
	link_to(weapon)
	to_chat(user, "<font color = #666633>-% Połączono [weapon] z [src] %-</font color>")
	if(length(weapon.cooling) > ENERGY_MAX_COOLING_LINKS)
		// przeciążony przekaźnik termiczny, jak w oryginale
		explosion(get_turf(pick(weapon.cooling)), 0, 1, 3, 5, flame_range = 4)
	return TRUE

/obj/machinery/cooling/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	I.play_tool_sound(src, 100)
	panel_open = !panel_open
	to_chat(user, "<span class='notice'>[panel_open ? "Otwierasz panel i odsłaniasz okablowanie" : "Zamykasz panel"] [src].</span>")

/obj/machinery/cooling/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!anchored && isspaceturf(get_turf(src)))
		return
	I.play_tool_sound(src, 100)
	setAnchored(!anchored)
	to_chat(user, "<span class='notice'>[anchored ? "Przykręcasz" : "Odkręcasz"] [src] [anchored ? "do" : "od"] podłogi.</span>")

/obj/machinery/cooling/crowbar_act(mob/living/user, obj/item/I)
	if(default_deconstruction_crowbar(I))
		return TRUE
	return ..()

/obj/machinery/cooling/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/cable_coil) && (machine_stat & BROKEN) && panel_open)
		var/obj/item/stack/cable_coil/coil = W
		to_chat(user, "<span class='notice'>Zaczynasz wymieniać przewody...</span>")
		if(!do_after(user, 3 SECONDS, target = src) || !coil.use(1))
			return TRUE
		obj_integrity = max_integrity
		set_machine_stat(machine_stat & ~BROKEN)
		to_chat(user, "<span class='notice'>Naprawiasz [src].</span>")
		update_icon()
		return TRUE
	return ..()

/obj/item/stock_parts/heatsink
	name = "radiator podprzestrzenny"
	desc = "Wytrzymały radiator używany w niektórych urządzeniach."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "matter_bin"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/circuitboard/machine/cooling
	name = "płytka chłodnicy podprzestrzennej"
	build_path = /obj/machinery/cooling/cooler
	req_components = list(
		/obj/item/stack/cable_coil = 15,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/heatsink = 1)

/obj/item/circuitboard/machine/cooling/storage
	name = "płytka podprzestrzennego magazynu ciepła"
	build_path = /obj/machinery/cooling/storage
	req_components = list(
		/obj/item/stack/cable_coil = 15,
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/heatsink = 1)

/datum/design/board/subspace_cooler
	name = "Projekt maszyny (eksperymentalna chłodnica podprzestrzenna)"
	desc = "Pozwala zbudować chłodnicę podprzestrzenną."
	id = "subspace_cooler"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/gold = 1000)
	build_path = /obj/item/circuitboard/machine/cooling
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/subspace_storage
	name = "Projekt maszyny (eksperymentalny podprzestrzenny magazyn ciepła)"
	desc = "Pozwala zbudować podprzestrzenny magazyn ciepła."
	id = "subspace_storage"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/gold = 1000)
	build_path = /obj/item/circuitboard/machine/cooling/storage
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/heatsink
	name = "Radiator podprzestrzenny"
	desc = "Pozwala wytworzyć radiator do urządzeń podprzestrzennych."
	id = "heatsink"
	build_type = PROTOLATHE
	materials = list(/datum/material/bluespace = 2000, /datum/material/copper = 30000, /datum/material/iron = 1000)
	build_path = /obj/item/stock_parts/heatsink
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/techweb_node/weapon_cooling
	id = "weapon_cooling"
	tech_tier = 4
	display_name = "Manipulacja podprzestrzenią"
	description = "Doświadczalne użycie podprzestrzeni do czegoś więcej niż łączność: odprowadzanie ciepła broni energetycznych."
	prereq_ids = list("comptech", "adv_engi", "adv_power")
	design_ids = list("subspace_storage", "subspace_cooler", "heatsink")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 3000)
	export_price = 5000

#undef ENERGY_MAX_COOLING_LINKS
