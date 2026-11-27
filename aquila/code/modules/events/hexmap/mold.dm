// AQUILA - Pleśń: w tunelach technicznych wyrasta rdzeń żywej pleśni jednej z trzech odmian (radioaktywna, toksyczna, elektryczna), który porasta okolicę, stawia pękające bąble i wypuszcza kilka stworów, dopóki ktoś go nie zniszczy (port uproszczony z Bubberstation/Bubberstation modular_skyrat/modules/mold/code/mold_event.dm i reszty modułu mold)
// Skyrat's mold is a blob-like PvE module: a core (600 HP and growing) with a controller that spreads resin with no
// size limit, bashes through airlocks and firelocks, walls off space, breaks lights and builds bulbs, mob spawners and
// atmos conditioners; five types (fire, fungal with its own disease, EMP, toxic, radioactive) with their own mobs, foams
// and gases, a violet security level. Ours is cut down to a size that suits an event:
// - three types: radioactive (radiation pulse, our glowing mice of E4), toxic (a small cloud of toxin, the broodlings of
//   the larva plague) and electric (sparks and a light EMP from a bursting bulb, only sparks from the core, the solar
//   grubs of the grub plague); no fire (it could burn the ship) and no fungal disease;
// - the core grows at most 30 pieces up to 5 tiles from itself on our shared spreader (plague_helpers.dm): never through
//   walls, windows or closed doors, never onto mobs, doors or dangerous areas, never attacking doors or walls and never
//   walling off space; it breaks no lights;
// - up to four bulbs among the pieces burst when someone walks next to them or hits them (every 30 s at most); the core
//   bursts back now and then when hit hard; it lets out at most three creatures in total, one every 60-90 s;
// - our blob sprites tinted in the type's colour instead of Skyrat's mold sprites; no spawner or conditioner structures;
// - killing the core (300 HP) stops everything and the rest withers within half a minute.
// The crew is warned 2-4 minutes after the core appears, if it still lives.

/datum/round_event_control/aquila_hex_mold
	name = "Pleśń"
	typepath = /datum/round_event/aquila_hex_mold
	weight = 8
	min_players = 15
	max_occurrences = 1
	earliest_start = 30 MINUTES

/datum/round_event/aquila_hex_mold
	fakeable = FALSE
	startWhen = 1
	announceWhen = 60
	/// Rdzeń pleśni
	var/datum/weakref/core_ref

/datum/round_event/aquila_hex_mold/setup()
	announceWhen = rand(60, 120)

/datum/round_event/aquila_hex_mold/start()
	var/obj/structure/aquila_hex_spreader/mold/core = plant(find_spot(), pick(subtypesof(/datum/aquila_hex_mold_type)))
	if(!core)
		log_game("Mold: no free maintenance spot found, cancelling the event.")
		return kill()
	core_ref = WEAKREF(core)
	announce_to_ghosts(core)

/datum/round_event/aquila_hex_mold/announce(fake)
	var/obj/structure/aquila_hex_spreader/mold/core = core_ref?.resolve()
	if(QDELETED(core))
		return
	var/area/core_area = get_area(core)
	priority_announce("Potwierdzono ognisko zagrożenia biologicznego: [core.mold_type.name] pleśń w tunelach technicznych ([core_area.name]). Pleśń rozrasta się i wypuszcza groźne stwory. Zniszczenie jej rdzenia zatrzyma rozrost.", "Alarm biologiczny", ANNOUNCER_OUTBREAK5)

/// Wolne pole w tunelach technicznych, na którym gęsty rdzeń nie zatarasuje przejścia; null, gdy nie znalazł
/datum/round_event/aquila_hex_mold/proc/find_spot()
	for(var/attempt in 1 to 10)
		var/turf/spot = aquila_hex_maint_turf()
		if(spot && aquila_hex_dense_spot_ok(spot))
			return spot

/// Sadzi rdzeń pleśni danej odmiany na polu; zwraca rdzeń albo null
/datum/round_event/aquila_hex_mold/proc/plant(turf/spot, mold_type_path)
	if(!isturf(spot) || !ispath(mold_type_path, /datum/aquila_hex_mold_type))
		return null
	var/obj/structure/aquila_hex_spreader/mold/core = new(spot, null, mold_type_path)
	message_admins("Pleśń ([core.mold_type.name]) wyrasta w [ADMIN_VERBOSEJMP(spot)].")
	log_game("Mold: a [core.mold_type.type] mold core sprouted at [AREACOORD(spot)].")
	return core

/**
 * Odmiana pleśni: kolor, stwory i to, co robi pękający bąbel albo zaatakowany rdzeń.
 */
/datum/aquila_hex_mold_type
	/// Przymiotnik do nazw („radioaktywna” pleśń)
	var/name = "dziwna"
	/// Kolor rdzenia, pleśni i bąbli
	var/mold_color = "#ffffff"
	/// Kolor światła rdzenia i bąbli
	var/light_color = LIGHT_COLOR_WHITE
	/// Dopisek do opisu
	var/examine_text = ""
	/// Stwory, które wypuszcza rdzeń
	var/mob_type

/// Co się dzieje, gdy pęka bąbel
/datum/aquila_hex_mold_type/proc/burst(atom/source)
	return

/// Co się dzieje, gdy mocno uderzony rdzeń się broni (domyślnie to samo co pęknięcie bąbla)
/datum/aquila_hex_mold_type/proc/defend(atom/source)
	burst(source)

/datum/aquila_hex_mold_type/radioactive
	name = "radioaktywna"
	mold_color = "#80ff00"
	light_color = LIGHT_COLOR_GREEN
	examine_text = "Świeci miękkim, zielonym blaskiem, a licznik Geigera trzeszczy."
	mob_type = /mob/living/basic/mouse/aquila_hex_irradiated

/datum/aquila_hex_mold_type/radioactive/burst(atom/source)
	radiation_pulse(source, max_range = 3, threshold = RAD_LIGHT_INSULATION)

/datum/aquila_hex_mold_type/toxic
	name = "toksyczna"
	mold_color = "#cb37f5"
	light_color = LIGHT_COLOR_LAVENDER
	examine_text = "Jest wilgotna i cuchnie trutką na szczury."
	mob_type = /mob/living/basic/aquila_hex_broodling

/datum/aquila_hex_mold_type/toxic/burst(atom/source)
	var/turf/source_turf = get_turf(source)
	if(!source_turf)
		return
	var/datum/reagents/cloud = new(20)
	cloud.my_atom = source
	cloud.add_reagent(/datum/reagent/toxin, 10)
	var/datum/effect_system/smoke_spread/chem/smoke = new
	smoke.attach(source_turf)
	smoke.set_up(cloud, 2, source_turf, silent = TRUE)
	smoke.start()
	qdel(cloud)

/datum/aquila_hex_mold_type/electric
	name = "elektryczna"
	mold_color = "#00caa5"
	light_color = LIGHT_COLOR_CYAN
	examine_text = "Po jej żyłkach przebiegają drobne iskry."
	mob_type = /mob/living/basic/aquila_solargrub

/datum/aquila_hex_mold_type/electric/burst(atom/source)
	var/turf/source_turf = get_turf(source)
	if(!source_turf)
		return
	do_sparks(3, TRUE, source_turf)
	empulse(source_turf, 0, 2)

/// Rdzeń elektrycznej pleśni sypie tylko iskrami: impuls EMP przy każdym ciosie wyłączałby sprzęt broniących się
/datum/aquila_hex_mold_type/electric/defend(atom/source)
	var/turf/source_turf = get_turf(source)
	if(source_turf)
		do_sparks(3, TRUE, source_turf)

/**
 * Rdzeń pleśni: korzeń rozrostu. Wypuszcza stwory, broni się i trzyma przy życiu całą pleśń.
 */
/obj/structure/aquila_hex_spreader/mold
	name = "rdzeń pleśni"
	desc = "Pulsujący, żywy rdzeń pleśni. Bije w nim coś na kształt serca."
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_core"
	density = TRUE
	layer = TABLE_LAYER
	max_integrity = 300
	max_pieces = 30
	max_radius = 5
	spread_chance = 25
	piece_type = /obj/structure/aquila_hex_spreader/mold_resin
	light_range = 2
	light_power = 1
	/// Odmiana pleśni
	var/datum/aquila_hex_mold_type/mold_type
	/// Najwięcej bąbli wśród kawałków
	var/max_bulbs = 4
	/// Ile stworów rdzeń już wypuścił
	var/creatures_spawned = 0
	/// Najwięcej stworów, które wypuści
	var/max_creatures = 3
	COOLDOWN_DECLARE(creature_cooldown)
	COOLDOWN_DECLARE(defense_cooldown)

/obj/structure/aquila_hex_spreader/mold/Initialize(mapload, obj/structure/aquila_hex_spreader/new_root, mold_type_path)
	. = ..()
	if(!ispath(mold_type_path, /datum/aquila_hex_mold_type))
		mold_type_path = pick(subtypesof(/datum/aquila_hex_mold_type))
	mold_type = new mold_type_path
	color = mold_type.mold_color
	set_light_color(mold_type.light_color)
	name = "rdzeń pleśni ([mold_type.name])"
	add_overlay(mutable_appearance(icon, "blob_core_overlay", appearance_flags = RESET_COLOR))
	COOLDOWN_START(src, creature_cooldown, rand(60, 90) SECONDS)

/obj/structure/aquila_hex_spreader/mold/Destroy()
	QDEL_NULL(mold_type)
	return ..()

/obj/structure/aquila_hex_spreader/mold/examine(mob/user)
	. = ..()
	if(mold_type?.examine_text)
		. += "<span class='warning'>[mold_type.examine_text]</span>"

/obj/structure/aquila_hex_spreader/mold/process(delta_time)
	. = ..()
	if(COOLDOWN_FINISHED(src, creature_cooldown))
		COOLDOWN_START(src, creature_cooldown, rand(60, 90) SECONDS)
		spawn_creature()

/// Co któryś kawałek to bąbel, póki jest ich mniej niż max_bulbs
/obj/structure/aquila_hex_spreader/mold/spread()
	var/bulbs = 0
	for(var/obj/structure/aquila_hex_spreader/mold_resin/bulb/bulb in pieces)
		bulbs++
	piece_type = (bulbs < max_bulbs && prob(15)) ? /obj/structure/aquila_hex_spreader/mold_resin/bulb : /obj/structure/aquila_hex_spreader/mold_resin
	return ..()

/// Wypuszcza stwora swojej odmiany na wolne pole obok (najwyżej max_creatures w sumie); zwraca stwora albo null
/obj/structure/aquila_hex_spreader/mold/proc/spawn_creature()
	if(creatures_spawned >= max_creatures || !mold_type?.mob_type)
		return null
	var/list/spots = list()
	for(var/turf/T as anything in aquila_hex_free_turfs_near(get_turf(src), 9, 1))
		if(T != loc && aquila_hex_free_safe_turf(T))
			spots += T
	if(!length(spots))
		return null
	creatures_spawned++
	var/mob_path = mold_type.mob_type
	var/mob/living/creature = new mob_path(pick(spots))
	creature.visible_message("<span class='warning'>Z [src] wypełza [creature]!</span>")
	return creature

/// Mocno uderzony rdzeń czasem się broni
/obj/structure/aquila_hex_spreader/mold/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	. = ..()
	if(QDELETED(src) || damage_amount <= 10 || !COOLDOWN_FINISHED(src, defense_cooldown) || !prob(40))
		return
	COOLDOWN_START(src, defense_cooldown, 10 SECONDS)
	visible_message("<span class='danger'>[src] gwałtownie się kurczy i wyrzuca z siebie chmurę zarodników!</span>")
	mold_type?.defend(src)

/**
 * Pleśń na podłodze: kawałek rozrostu rdzenia.
 */
/obj/structure/aquila_hex_spreader/mold_resin
	name = "pleśń"
	desc = "Wygląda jak pleśń, ale wydaje się żywa."
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob"
	layer = LOW_OBJ_LAYER
	max_integrity = 25
	alpha = 200

/obj/structure/aquila_hex_spreader/mold_resin/Initialize(mapload, obj/structure/aquila_hex_spreader/new_root)
	. = ..()
	var/obj/structure/aquila_hex_spreader/mold/core = root
	if(istype(core) && core.mold_type)
		color = core.mold_type.mold_color
		name = "[core.mold_type.name] [name]"

/obj/structure/aquila_hex_spreader/mold_resin/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(src, damage_type == BURN ? 'sound/items/welder.ogg' : 'sound/effects/splat.ogg', 40, TRUE)

/**
 * Bąbel pleśni: pęka, gdy ktoś przejdzie obok albo go uderzy (najwyżej co 30 s).
 */
/obj/structure/aquila_hex_spreader/mold_resin/bulb
	name = "bąbel pleśni"
	desc = "Nabrzmiały pęcherz na pleśni. Lepiej go nie dotykać."
	icon_state = "blob_resource"
	alpha = 255
	max_integrity = 40
	light_range = 1.5
	light_power = 0.8
	var/datum/proximity_monitor/proximity_monitor
	COOLDOWN_DECLARE(burst_cooldown)

/obj/structure/aquila_hex_spreader/mold_resin/bulb/Initialize(mapload, obj/structure/aquila_hex_spreader/new_root)
	. = ..()
	name = "bąbel pleśni"
	var/obj/structure/aquila_hex_spreader/mold/core = root
	if(istype(core) && core.mold_type)
		set_light_color(core.mold_type.light_color)
	proximity_monitor = new(src, 1)

/obj/structure/aquila_hex_spreader/mold_resin/bulb/Destroy()
	QDEL_NULL(proximity_monitor)
	return ..()

/obj/structure/aquila_hex_spreader/mold_resin/bulb/HasProximity(atom/movable/AM)
	if(iscarbon(AM))
		burst()

/obj/structure/aquila_hex_spreader/mold_resin/bulb/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	. = ..()
	if(!QDELETED(src) && damage_amount > 0)
		burst()

/// Bąbel pęka z efektem odmiany pleśni; zwraca TRUE, gdy pękł
/obj/structure/aquila_hex_spreader/mold_resin/bulb/proc/burst()
	var/obj/structure/aquila_hex_spreader/mold/core = root
	if(withering || !istype(core) || !core.mold_type || !COOLDOWN_FINISHED(src, burst_cooldown))
		return FALSE
	COOLDOWN_START(src, burst_cooldown, 30 SECONDS)
	visible_message("<span class='warning'>[src] pęka!</span>")
	playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
	core.mold_type.burst(src)
	return TRUE
