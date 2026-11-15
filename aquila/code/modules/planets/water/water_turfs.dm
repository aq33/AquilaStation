// AQUILA - woda na planetach: port /turf/open/water z Shiptesta (code/game/turfs/open/water.dm i
// floor/plating/waterplanet.dm, AGPLv3). Każda woda planety gasi i moczy (watery_tile), zanurza moby i przedmioty
// (immerse, dodawane leniwie przy pierwszym wejściu, jak w Shiptest) i jest łowiskiem (lazy_fishing_spot). Głęboka
// woda (is_swimming_tile) dokłada pływanie i jest niebezpieczna dla lądowania (planet_landing_hazard).
// Zmiany względem Shiptesta: wspólny rodzic /turf/open/water/planet zamiast przerabiania /turf/open/water (nasza zwykła
// woda na mapach okrętów zostaje jak była), sztormowe morze planety wodnej jest głębokie (w Shiptest było płytkie,
// a cała planeta to morze: bez pływania nie byłoby po co tam lądować), bez światła z pól (planety świecą obszarem),
// atmosfera stała jak przy lawie (typ planety może podmienić podtypem).

/turf/open
	/// Na tym polu nie da się bezpiecznie wylądować ani zrzucić kapsuły (is_planet_hazard_turf)
	var/planet_landing_hazard = FALSE

/turf/open/water/planet
	name = "woda"
	desc = "Płytka woda."
	icon = 'aquila/icons/planets/water/water.dmi'
	icon_state = "water"
	color = "#41a3ff"
	baseturfs = /turf/open/water/planet
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = TRUE
	slowdown = 1
	/// Przezroczystość i stan maski zanurzenia
	var/immerse_overlay_alpha = 180
	var/immerse_overlay = "immerse"
	/// Łowisko (klucz z GLOB.preset_fish_sources albo null)
	var/fishing_preset
	/// Głęboka woda z pływaniem i jej parametry (swimming_tile)
	var/is_swimming_tile = FALSE
	var/stamina_entry_cost = 7
	var/ticking_oxy_damage = 2
	var/exhaust_swimmer_prob = 30
	/// Czy element zanurzenia już doszedł
	var/immerse_added = FALSE
	/// Co da się zaczerpnąć naczyniem
	var/datum/reagent/reagent_to_extract = /datum/reagent/water

/turf/open/water/planet/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/watery_tile)
	if(fishing_preset)
		AddElement(/datum/element/lazy_fishing_spot, fishing_preset)
	if(is_swimming_tile)
		planet_landing_hazard = TRUE

/turf/open/water/planet/Entered(atom/movable/arrived, atom/old_loc)
	. = ..()
	make_immersed(arrived)

/// Dokłada zanurzenie i pływanie przy pierwszym wejściu czegoś na pole (tysiące pól morza nie trzymają elementów na zapas)
/turf/open/water/planet/proc/make_immersed(atom/movable/triggering_atom)
	if(immerse_added || (!isliving(triggering_atom) && !isitem(triggering_atom)))
		return FALSE
	immerse_added = TRUE
	AddElement(/datum/element/immerse, immerse_overlay, immerse_overlay_alpha)
	if(is_swimming_tile)
		AddElement(/datum/element/swimming_tile, stamina_entry_cost, ticking_oxy_damage, exhaust_swimmer_prob)
	return TRUE

/turf/open/water/planet/examine(mob/user)
	. = ..()
	if(reagent_to_extract)
		. += span_notice("Naczyniem dałoby się stąd zaczerpnąć trochę płynu.")
	if(is_swimming_tile)
		. += span_warning("Tu jest głęboko: trzeba płynąć, a pływanie męczy.")

/turf/open/water/planet/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/stack/rods))
		var/obj/item/stack/rods/rods = attacking_item
		if(locate(/obj/structure/lattice) in src)
			to_chat(user, span_warning("Tu już jest kratownica!"))
			return
		if(rods.use(2))
			to_chat(user, span_notice("Budujesz pomost."))
			playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
			new /obj/structure/lattice/catwalk(src)
		else
			to_chat(user, span_warning("Na pomost potrzeba dwóch prętów."))
		return
	if(istype(attacking_item, /obj/item/fish))
		to_chat(user, span_notice("Wrzucasz [attacking_item.name] do wody."))
		playsound(src, 'aquila/sound/effects/fishing/bigsplash.ogg', 70, TRUE)
		qdel(attacking_item)
		return
	if(istype(attacking_item, /obj/item/reagent_containers/glass) && reagent_to_extract && extract_reagents(attacking_item, user))
		return
	return ..()

/turf/open/water/planet/proc/extract_reagents(obj/item/reagent_containers/glass/container, mob/user)
	if(!container.is_refillable())
		to_chat(user, span_warning("[container] jest zamknięty!"))
		return TRUE
	if(container.reagents.total_volume >= container.volume)
		to_chat(user, span_warning("[container] jest pełny."))
		return TRUE
	container.reagents.add_reagent(reagent_to_extract, rand(5, 10))
	user.visible_message(span_notice("[user] czerpie [container] płyn z [src]."), span_notice("Czerpiesz [container] płyn z [src]."))
	return TRUE

/turf/open/water/planet/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/// Płytka woda morska przy plaży (łowisko morskie)
/turf/open/water/planet/beach
	name = "płycizna"
	desc = "Ciepła, płytka woda morska. Widać dno i przemykające ryby."
	fishing_preset = FISHING_SPOT_PRESET_BEACH

/// Głębia za płycizną: trzeba płynąć
/turf/open/water/planet/beach/deep
	name = "głęboka woda"
	desc = "Ciemna, głęboka woda morska. Dna nie widać."
	color = "#4566ad"
	immerse_overlay = "immerse_deep"
	is_swimming_tile = TRUE
	slowdown = 2

/// Woda w jaskiniach planet morskich (bez nieba nad głową)
/turf/open/water/planet/beach/underground
	name = "podziemna woda"
	desc = "Chłodna woda zalewająca jaskinię."

/// Sztormowe morze planety wodnej: głębokie, zimne i niespokojne
/turf/open/water/planet/stormy
	name = "wzburzone morze"
	desc = "Lodowata, wzburzona woda bez dna. Fale biją bez przerwy."
	color = "#1b364d"
	initial_gas_mix = "o2=22;n2=82;TEMP=255.37"
	baseturfs = /turf/open/water/planet/stormy
	immerse_overlay = "immerse_deep"
	immerse_overlay_alpha = 210
	is_swimming_tile = TRUE
	stamina_entry_cost = 12
	slowdown = 2
	fishing_preset = FISHING_SPOT_PRESET_STORMY

/turf/open/water/planet/stormy/underground
	name = "zalana jaskinia"
	desc = "Lodowata woda zalewa jaskinię aż po sklepienie korytarzy."
	baseturfs = /turf/open/water/planet/stormy/underground

/// Mętna woda dżungli
/turf/open/water/planet/jungle
	name = "mętna woda"
	desc = "Ciepła, mętna woda pełna mułu i życia."
	color = "#617B64"
	initial_gas_mix = "o2=22;n2=82;TEMP=308.15"
	baseturfs = /turf/open/water/planet/jungle
	fishing_preset = FISHING_SPOT_PRESET_JUNGLE

/// Słodka woda oazy na pustyni
/turf/open/water/planet/oasis
	name = "słodka woda"
	desc = "Czysta, ciepła słodka woda. Na pustyni cenniejsza niż złoto."
	color = "#8ac7e6"
	initial_gas_mix = "o2=20;n2=80;TEMP=313.15"
	baseturfs = /turf/open/water/planet/oasis
	fishing_preset = FISHING_SPOT_PRESET_OASIS
