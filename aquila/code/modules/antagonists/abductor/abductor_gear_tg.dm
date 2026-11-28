// AQUILA: sprzęt porywaczy z tgstation (code/modules/antagonists/abductor/equipment/gear/abductor_items.dm,
// orderable_gear.dm, projectile/beams.dm; AGPL-3.0): promień zmniejszający i obce omninarzędzie.
// Grafiki z tgstation (CC-BY-SA 3.0): aquila/icons/obj/antags/abductor_tg.dmi (omnitool, shrink_ray),
// aquila/icons/mob/inhands/antag/abductor_tg_lefthand.dmi / _righthand.dmi; dźwięk aquila/sound/items/shrink_hit.ogg (tg).

/datum/abductor_gear/shrink_ray
	name = "Promień zmniejszający"
	description = "Przerażająca obca technologia, która na chwilę wzmacnia przyciąganie atomów w małej przestrzeni i zmniejsza trafiony obiekt. Albo to po prostu kosmiczna magia. Tak czy inaczej, zmniejsza rzeczy."
	id = "shrink_ray"
	cost = 2
	build_path = /obj/item/gun/energy/shrink_ray
	category = "Sprzęt zaawansowany"

/datum/abductor_gear/omnitool
	name = "Obce omninarzędzie"
	description = "Ręczne urządzenie z absurdalną liczbą wbudowanych narzędzi. Zastępuje narzędzia każdej z ról. Użycie w ręce wybiera narzędzie, a użycie prawym przyciskiem albo na intencji rozbrajania przełącza zestaw medyczny i techniczny."
	id = "omnitool"
	cost = 2
	build_path = /obj/item/abductor/alien_omnitool
	category = "Sprzęt zaawansowany"

/// tg: /obj/item/gun/energy/recharge/shrink_ray. U nas nie ma broni typu recharge, więc to broń z samoładującą się baterią na trzy strzały.
/obj/item/gun/energy/shrink_ray
	name = "promień zmniejszający"
	desc = "Przerażająca obca technologia, która na chwilę wzmacnia przyciąganie atomów w małej przestrzeni i zmniejsza trafiony obiekt. Albo to po prostu kosmiczna magia. Tak czy inaczej, zmniejsza rzeczy."
	icon = 'aquila/icons/obj/antags/abductor_tg.dmi'
	icon_state = "shrink_ray"
	item_state = "shrink_ray"
	lefthand_file = 'aquila/icons/mob/inhands/antag/abductor_tg_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/antag/abductor_tg_righthand.dmi'
	ammo_type = list(/obj/item/ammo_casing/energy/shrink)
	pin = /obj/item/firing_pin/abductor
	automatic_charge_overlays = FALSE
	gun_charge = 300
	selfcharge = 1
	charge_delay = 2
	can_charge = FALSE
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL // obcy mają nietypowe palce

/obj/item/ammo_casing/energy/shrink
	projectile_type = /obj/item/projectile/energy/shrink
	select_name = "zmniejszanie"
	e_cost = 100

/obj/item/projectile/energy/shrink
	name = "promień zmniejszający"
	icon_state = "blue_laser"
	hitsound = 'aquila/sound/items/shrink_hit.ogg'
	damage = 0
	damage_type = STAMINA
	light_color = LIGHT_COLOR_BLUE
	/// Jak długo trafiony obiekt zostaje mały; ujemny czas to zmniejszenie na stałe
	var/shrink_time = 9 SECONDS

/obj/item/projectile/energy/shrink/on_hit(atom/target, blocked = FALSE, pierce_hit)
	. = ..()
	if(isturf(target)) // tg zmniejsza też ściany; na okręcie nie przepuszczamy przez kadłub
		return
	target.AddComponent(/datum/component/shrink, shrink_time)

/// tg: quizzandric interfacer. Wybór narzędzia z menu kołowego, drugi przycisk przełącza zestaw medyczny i techniczny.
/obj/item/abductor/alien_omnitool
	name = "obce omninarzędzie"
	desc = "W praktyce kosmiczny scyzoryk z mnóstwem wbudowanych narzędzi. Użyj go prawym przyciskiem albo na intencji rozbrajania, żeby przełączyć zestaw narzędzi."
	icon = 'aquila/icons/obj/antags/abductor_tg.dmi'
	icon_state = "omnitool"
	item_state = "silencer"
	toolspeed = 0.25
	tool_behaviour = null
	usesound = 'sound/items/pshoom.ogg'
	/// Narzędzia aktywnego zestawu: nazwa w menu = obrazek
	var/list/tool_list = list()
	/// Aktywny zestaw ("medical" albo "hacking")
	var/active_toolset = "medical"

/obj/item/abductor/alien_omnitool/Initialize(mapload)
	. = ..()
	set_toolset() // wypełnia listę i ustawia zestaw techniczny, jak w tg

/obj/item/abductor/alien_omnitool/examine(mob/user)
	. = ..()
	var/tool_name = aquila_omnitool_name(tool_behaviour) || "brak"
	. += span_notice("Aktywne narzędzie: [tool_name].")

/obj/item/abductor/alien_omnitool/attack_self(mob/user)
	if(!user)
		return
	var/tool_result = show_radial_menu(user, src, tool_list, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!tool_result || !check_menu(user))
		return
	var/list/behaviours = aquila_omnitool_behaviours()
	tool_behaviour = behaviours[tool_result]
	playsound(loc, 'sound/machines/click.ogg', 50, TRUE)

/obj/item/abductor/alien_omnitool/attack_self_secondary(mob/user, modifiers)
	if(!user)
		return
	set_toolset(user)
	playsound(loc, 'sound/machines/click.ogg', 50, TRUE)

/obj/item/abductor/alien_omnitool/proc/check_menu(mob/user)
	if(!istype(user) || user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/abductor/alien_omnitool/proc/set_toolset(mob/user)
	tool_behaviour = null
	if(active_toolset == "medical")
		tool_list = list(
			"Łom" = image(icon = 'icons/obj/abductor.dmi', icon_state = "crowbar"),
			"Multitool" = image(icon = 'icons/obj/abductor.dmi', icon_state = "multitool"),
			"Śrubokręt" = image(icon = 'icons/obj/abductor.dmi', icon_state = "screwdriver_a"),
			"Przecinak" = image(icon = 'icons/obj/abductor.dmi', icon_state = "cutters"),
			"Klucz" = image(icon = 'icons/obj/abductor.dmi', icon_state = "wrench"),
			"Spawarka" = image(icon = 'icons/obj/abductor.dmi', icon_state = "welder"),
		)
		active_toolset = "hacking"
		if(user)
			balloon_alert(user, "zestaw techniczny")
	else
		tool_list = list(
			"Retraktor" = image(icon = 'icons/obj/abductor.dmi', icon_state = "retractor"),
			"Hemostat" = image(icon = 'icons/obj/abductor.dmi', icon_state = "hemostat"),
			"Kauter" = image(icon = 'icons/obj/abductor.dmi', icon_state = "cautery"),
			"Wiertło chirurgiczne" = image(icon = 'icons/obj/abductor.dmi', icon_state = "drill"),
			"Skalpel" = image(icon = 'icons/obj/abductor.dmi', icon_state = "scalpel"),
			"Piła tarczowa" = image(icon = 'icons/obj/abductor.dmi', icon_state = "saw"),
			"Filtr krwi" = image(icon = 'icons/obj/surgery.dmi', icon_state = "bloodfilter"),
		)
		active_toolset = "medical"
		if(user)
			balloon_alert(user, "zestaw medyczny")

/// Nazwa narzędzia w menu omninarzędzia = zachowanie narzędzia (bez nastawiacza kości z tg: nie mamy TOOL_BONESET)
/proc/aquila_omnitool_behaviours()
	var/static/list/behaviours = list(
		"Łom" = TOOL_CROWBAR,
		"Multitool" = TOOL_MULTITOOL,
		"Śrubokręt" = TOOL_SCREWDRIVER,
		"Przecinak" = TOOL_WIRECUTTER,
		"Klucz" = TOOL_WRENCH,
		"Spawarka" = TOOL_WELDER,
		"Retraktor" = TOOL_RETRACTOR,
		"Hemostat" = TOOL_HEMOSTAT,
		"Kauter" = TOOL_CAUTERY,
		"Wiertło chirurgiczne" = TOOL_DRILL,
		"Skalpel" = TOOL_SCALPEL,
		"Piła tarczowa" = TOOL_SAW,
		"Filtr krwi" = TOOL_BLOODFILTER,
	)
	return behaviours

/proc/aquila_omnitool_name(behaviour)
	var/list/behaviours = aquila_omnitool_behaviours()
	for(var/tool_name in behaviours)
		if(behaviours[tool_name] == behaviour)
			return tool_name
	return null
