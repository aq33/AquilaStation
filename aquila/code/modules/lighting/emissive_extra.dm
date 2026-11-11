// Więcej świecących (emisyjnych) rzeczy: lampy, pociski energetyczne, światełka śluz.
// Emisyjna nakładka przebija ciemność i daje poświatę (soft_lighting.dm), jak ekrany komputerów.

/// Biała maska emisyjna, która obraca się i skaluje razem z właścicielem (bez RESET_TRANSFORM),
/// dla pocisków i smug obracanych przez transform. Wspólna dla wszystkich obiektów z tym samym stanem ikony.
/proc/aq_rotating_emissive(icon, icon_state)
	var/static/list/cache = list()
	var/key = "[icon]|[icon_state]"
	. = cache[key]
	if(!.)
		var/mutable_appearance/appearance = mutable_appearance(icon, icon_state, FLOAT_LAYER, EMISSIVE_PLANE, 255, KEEP_APART | KEEP_TOGETHER | RESET_COLOR)
		appearance.color = GLOB.emissive_color
		. = cache[key] = appearance

// Lampy: świecąca świetlówka lub żarówka. Bierzemy nakładkę, którą dodał core (zwykła, awaryjna, nocna),
// zamiast powtarzać tu jego warunki.
/obj/machinery/light/update_overlays()
	. = ..()
	for(var/mutable_appearance/overlay as anything in .)
		if(overlay?.icon == overlayicon)
			. += emissive_appearance(overlayicon, overlay.icon_state, alpha = src.alpha)
			return

// Pociski energetyczne (lasery, paralizatory, plazma, jony, termiczne). Kule się nie świecą.
/obj/item/projectile/Initialize(mapload)
	. = ..()
	if(icon_state && (light_range || istype(src, /obj/item/projectile/beam) || istype(src, /obj/item/projectile/energy) || istype(src, /obj/item/projectile/plasma) || istype(src, /obj/item/projectile/ion) || istype(src, /obj/item/projectile/temp)))
		add_overlay(aq_rotating_emissive(icon, icon_state))

// Smugi, błyski u wylotu i trafienia pocisków hitscan
/obj/effect/projectile/Initialize(mapload)
	. = ..()
	if(icon_state && icon_state != "nothing" && !istype(src, /obj/effect/projectile/tracer/tracer/aiming))
		add_overlay(aq_rotating_emissive(icon, icon_state))

// Śluzy: światełka blokady, awarii, odmowy i otwierania (całe drzwi, bez ruchomych skrzydeł)
#define AQ_AIRLOCK_CLOSED 1
#define AQ_AIRLOCK_CLOSING 2
#define AQ_AIRLOCK_OPENING 4
#define AQ_AIRLOCK_DENY 5

/// Stan ikony światełek śluzy dla danego stanu drzwi, tak jak w set_airlock_overlays()
/obj/machinery/door/airlock/proc/aq_lights_state(state)
	if(!hasPower())
		return null
	switch(state)
		if(AQ_AIRLOCK_CLOSED)
			if(!lights)
				return null
			if(locked)
				return "lights_bolts"
			if(emergency)
				return "lights_emergency"
		if(AQ_AIRLOCK_DENY)
			return "lights_denied"
		if(AQ_AIRLOCK_CLOSING)
			return lights ? "lights_closing" : null
		if(AQ_AIRLOCK_OPENING)
			return lights ? "lights_opening" : null
	return null

/obj/machinery/door/airlock/set_airlock_overlays(state)
	. = ..()
	var/lights_state = aq_lights_state(state)
	if(!lights_state)
		return
	// Nakładki vis są wspólne dla kluczy z tym samym planem, więc kolor emisyjny ustawiamy raz na kopii z cache
	var/key = SSvis_overlays.add_vis_overlay(src, overlays_file, lights_state, FLOAT_LAYER, EMISSIVE_PLANE, dir, 255, EMISSIVE_APPEARANCE_FLAGS)
	var/obj/effect/overlay/vis/glow = SSvis_overlays.vis_overlay_cache[key]
	glow?.color = GLOB.emissive_color

/obj/machinery/door/airlock/legacy_set_airlock_overlays(state)
	. = ..()
	var/lights_state = aq_lights_state(state)
	if(lights_state)
		add_overlay(emissive_appearance(overlays_file, lights_state))

#undef AQ_AIRLOCK_CLOSED
#undef AQ_AIRLOCK_CLOSING
#undef AQ_AIRLOCK_OPENING
#undef AQ_AIRLOCK_DENY
