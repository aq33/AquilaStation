// AQUILA - limit kudzu na powierzchni planet (wg voidcrew/Voidcrew#461).
// Na okręcie pnącza zatrzymują ściany i próżnia za kadłubem, a powierzchnia planety (127×127 albo 191×191) to otwarty
// teren: jedna paczka nasion rośnie tam do końca rundy w tysiące przetwarzanych, zasłaniających światło pnączy.
// Na planecie kępa przestaje się rozrastać po PLANET_SPACEVINE_CLUSTER_CAP pnączach, a wszystkie kępy razem po
// PLANET_SPACEVINE_GLOBAL_CAP, więc sadzenie na wielu planetach nie obchodzi limitu. Przy pełnym limicie nowe nasiona
// na planecie się nie przyjmują. Kępa z limitem dalej rośnie, oplata i mutuje w miejscu, a po przycięciu znowu się
// rozrasta. Różnica względem Voidcrew: tam limit działa wszędzie, u nas tylko na planetach, żeby event kudzu na
// okręcie działał po staremu.

/// Wszystkie żywe kontrolery kudzu (do limitu wspólnego)
GLOBAL_LIST_EMPTY(spacevine_controllers)
/// Zapamiętana suma pnączy na powierzchniach planet, patrz spacevine_total()
GLOBAL_VAR_INIT(spacevine_total, 0)
/// world.time ostatniego przeliczenia sumy
GLOBAL_VAR_INIT(spacevine_total_counted, -1)

/// Czy pole leży na wczytanej powierzchni planety (razem z jaskiniami i ruinami)
/proc/is_planet_surface_turf(turf/T)
	return T && istype(SSmapping.used_turfs[T], /datum/turf_reservation/planet)

/// Suma pnączy na powierzchniach planet (pnącza na okręcie nie wchodzą do limitu planetarnego). Przeliczana raz na tick,
/// więc pnącze usunięte z pominięciem VineDestroyed() nie zostaje w sumie. Rozrost w tym samym ticku podbija ją od razu,
/// żeby wiele kęp naraz nie przeskoczyło limitu.
/proc/spacevine_total()
	if(GLOB.spacevine_total_counted != world.time)
		var/total = 0
		for(var/datum/spacevine_controller/controller as anything in GLOB.spacevine_controllers)
			for(var/obj/structure/spacevine/vine as anything in controller.vines)
				if(is_planet_surface_turf(vine.loc))
					total++
		GLOB.spacevine_total = total
		GLOB.spacevine_total_counted = world.time
	return GLOB.spacevine_total

/datum/spacevine_controller/New(turf/location, list/muts, potency, production, datum/round_event/event = null)
	GLOB.spacevine_controllers += src
	return ..()

/datum/spacevine_controller/Destroy()
	GLOB.spacevine_controllers -= src
	return ..()

/datum/spacevine_controller/spawn_spacevine_piece(turf/location, obj/structure/spacevine/parent, list/muts)
	var/before = length(vines)
	. = ..()
	if(is_planet_surface_turf(location))
		GLOB.spacevine_total += length(vines) - before

/// Czy kępa może się rozrastać dalej na tym polu
/datum/spacevine_controller/proc/can_spread_from(turf/T)
	if(!is_planet_surface_turf(T))
		return TRUE
	return length(vines) < PLANET_SPACEVINE_CLUSTER_CAP && spacevine_total() < PLANET_SPACEVINE_GLOBAL_CAP

// Sprawdzane przed rodzicem, żeby on_spread() mutacji (przebijanie ścian i podobne) też stawało na limicie
/obj/structure/spacevine/spread()
	if(master && !master.can_spread_from(get_turf(src)))
		return
	return ..()

/obj/item/plant_seeds/preset/kudzu/start_kudzu(mob/user)
	if(is_planet_surface_turf(get_turf(user)) && spacevine_total() >= PLANET_SPACEVINE_GLOBAL_CAP)
		to_chat(user, span_warning("[src] nie chce się przyjąć."))
		return
	return ..()
