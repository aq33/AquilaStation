// AQUILA - georadarowy skaner górniczy: port z Shiptesta (AGPLv3) code/modules/mining/equipment/mineral_scanner.dm
// (/obj/item/pinpointer/mineral). Sprite'y z Shiptesta icons/obj/mining.dmi (CC BY-SA 3.0), tylko stany skanera,
// w aquila/icons/planets/vein_scanner.dmi.
// Dwa tryby (Alt-klik): powierzchnia (co 5 s podświetla rudy w ścianach w promieniu 4, jak ręczny skaner górniczy) i
// podziemie (wskazuje najbliższą żyłę rudy). Przyłożony do żyły pokazuje jej klasę, ładunki, zagrożenie i rudy;
// w trybie walki (Shiptest: intencja harm) oznacza ją jako bez znaczenia, żeby skaner jej nie wskazywał.
// Zmiany względem Shiptesta: szuka żył tylko na tej samej planecie (planety dzielą poziom z w rezerwacji turfów,
// Shiptest porównywał virtual_z); dostępny z protolatu w węźle „Technologia górnicza” (Shiptest: automaty).

#define VEIN_SCANMODE_SURFACE 0
#define VEIN_SCANMODE_SUBSURFACE 1

/obj/item/pinpointer/mineral
	name = "georadarowy skaner górniczy"
	desc = "Ręczny skaner do szukania złóż głęboko pod powierzchnią i na niej. Alt-klik zmienia tryb."
	icon = 'aquila/icons/planets/vein_scanner.dmi'
	icon_state = "mining"
	custom_price = 300
	custom_premium_price = 300
	icon_suffix = "_mining"
	var/scanning_surface = FALSE
	var/cooldown = 5 SECONDS
	var/current_cooldown = 0
	var/range = 4
	var/scanmode = VEIN_SCANMODE_SURFACE

/obj/item/pinpointer/mineral/examine(mob/user)
	. = ..()
	var/mode_text = scanmode ? "skan podziemia" : "skan powierzchni"
	. += span_notice("Tryb: [mode_text].")
	. += span_notice("Przyłożony do żyły rudy pokazuje jej zawartość, a w trybie walki oznacza ją jako bez znaczenia, żeby skaner przestał ją wskazywać.")

/obj/item/pinpointer/mineral/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(scanning_surface || active)
		to_chat(user, span_warning("Najpierw wyłącz skaner!"))
		return
	scanmode = !scanmode
	var/mode_text = scanmode ? "skan podziemia" : "skan powierzchni"
	to_chat(user, span_notice("Przełączasz skaner na [mode_text]."))

/obj/item/pinpointer/mineral/attack_self(mob/living/user)
	switch(scanmode)
		if(VEIN_SCANMODE_SUBSURFACE)
			if(active)
				toggle_on()
				user.visible_message(span_notice("[user] wyłącza swój skaner."), span_notice("Wyłączasz skaner."))
				return
			if(!scan_for_target())
				user.visible_message(span_notice("Skaner [user] nie wykrywa żadnych złóż."), span_notice("Skaner nie wykrywa żadnych złóż."))
				return
			toggle_on()
			user.visible_message(span_notice("[user] włącza swój skaner."), span_notice("Włączasz skaner."))
		if(VEIN_SCANMODE_SURFACE)
			scanning_surface = !scanning_surface
			if(scanning_surface)
				START_PROCESSING(SSobj, src)
				user.visible_message(span_notice("[user] włącza swój skaner."), span_notice("Włączasz skaner."))
			else
				STOP_PROCESSING(SSobj, src)
				user.visible_message(span_notice("[user] wyłącza swój skaner."), span_notice("Wyłączasz skaner."))
			playsound(src, 'sound/items/screwdriver2.ogg', 50, TRUE)
			update_icon()

/obj/item/pinpointer/mineral/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/pinpointer/mineral/process(delta_time)
	switch(scanmode)
		if(VEIN_SCANMODE_SUBSURFACE)
			if(active && target && QDELETED(target))
				target = null
				toggle_on()
				return PROCESS_KILL
			return ..()
		if(VEIN_SCANMODE_SURFACE)
			if(!scanning_surface)
				return PROCESS_KILL
			if(current_cooldown <= world.time)
				current_cooldown = world.time + cooldown
				mineral_scan_pulse(get_turf(src), range)
				playsound(src, 'sound/effects/ping.ogg', 20)

/obj/item/pinpointer/mineral/update_icon()
	. = ..()
	if(scanmode == VEIN_SCANMODE_SURFACE && scanning_surface)
		add_overlay("on_overlay")
	else if(scanmode == VEIN_SCANMODE_SUBSURFACE && active)
		add_overlay("pinpointing_overlay")

/// Najbliższa wykrywalna żyła na tej samej planecie
/obj/item/pinpointer/mineral/scan_for_target()
	target = null
	var/turf/here = get_turf(src)
	if(!here)
		return
	var/datum/turf_reservation/here_reservation = SSmapping.used_turfs[here]
	var/located_dist
	for(var/obj/structure/vein/vein as anything in GLOB.ore_veins)
		if(!vein.detectable)
			continue
		var/turf/there = get_turf(vein)
		if(!there || there.z != here.z || SSmapping.used_turfs[there] != here_reservation)
			continue
		var/dist = get_dist(here, there)
		if(!target || dist < located_dist)
			located_dist = dist
			target = vein
	return target

/// Przyłożony do żyły: odczyt zawartości albo (w trybie walki) oznaczenie jej jako bez znaczenia
/obj/item/pinpointer/mineral/afterattack(atom/target_atom, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !istype(target_atom, /obj/structure/vein))
		return
	var/obj/structure/vein/our_vein = target_atom
	playsound(src, 'sound/effects/fastbeep.ogg', 10)
	var/mob/living/living_user = user
	if(istype(living_user) && living_user.combat_mode)
		our_vein.detectable = !our_vein.detectable
		if(our_vein.detectable)
			to_chat(user, span_notice("Przywracasz żyłę do telemetrii skanera: znów będzie ją wskazywał w skanie podziemia."))
		else
			to_chat(user, span_notice("Usuwasz żyłę z telemetrii skanera: nie będzie już jej wskazywał jako miejsca wartego uwagi."))
		return
	if(istype(our_vein, /obj/structure/vein/gas))
		var/obj/structure/vein/gas/gas_vein = our_vein
		gas_vein.scan_report(user)
		return
	if(!length(our_vein.vein_contents))
		to_chat(user, span_notice("W tej żyle nie ma wartych uwagi złóż."))
		return
	to_chat(user, span_notice("Żyła rudy klasy <b>[our_vein.vein_class]</b>, ładunków rudy: <b>[our_vein.mining_charges]</b>."))
	to_chat(user, span_danger("Spodziewane wzburzenie fauny: <b>[our_vein.threat_text()]</b>."))
	var/list/ore_names = list()
	for(var/obj/item/stack/ore/ore_type as anything in our_vein.vein_contents)
		ore_names |= initial(ore_type.name)
	to_chat(user, span_notice("Wykryto wydobywalne ilości rud: [english_list(ore_names)]."))

/datum/design/vein_scanner
	name = "Georadarowy skaner górniczy"
	desc = "Skaner, który wskazuje żyły rud pod powierzchnią planety i pokazuje ich zawartość."
	id = "aquila_vein_scanner"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000, /datum/material/silver = 500)
	build_path = /obj/item/pinpointer/mineral
	category = list("Mining Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

#undef VEIN_SCANMODE_SURFACE
#undef VEIN_SCANMODE_SUBSURFACE
