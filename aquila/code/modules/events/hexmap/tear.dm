// AQUILA - Rozdarcie wymiarów: w losowym bezpiecznym pomieszczeniu migają światła, po kilku sekundach otwiera się rozdarcie, z którego wychodzi do 10 piekielnych stworów z przewodnikiem sfory piekielnych ogarów, a potem rozdarcie się zamyka (port z BlueMoon-Labs/BlueMoon-Station code/modules/events/anomaly/tear.dm i ParadiseSS13/Paradise code/modules/events/tear.dm)
// Paradise flickers the machines and lights within 8 tiles, tells the ghosts, opens the tear 4 s later, breaks the
// consoles, mirrors and lights around it and lets out 4-9 random hell mobs (hellhounds, skeletons, netherworld mobs,
// faithless) plus a hellhound leader, one every 2 s; BlueMoon lets out five random hostile mobs. Ours keeps Paradise's
// flow without breaking anything: only the lights flicker, the tear stands on a free safe floor of a safe room and lets
// its 4-9 creatures and the leader out one by one onto free floor next to it (never onto a mob or a door), then closes;
// it also closes on its own after 90 s and when the event ends. We had no hellhound, so there is a small new basic mob
// drawn with the existing hound sprite (aquila/icons/planets/ruins/ramzi_hound.dmi, from Shiptest, CC BY-SA 3.0) in
// red; it does not come from gold slime cores and is not playable. Every creature from a tear shares one faction and
// gets a hunting AI that never attacks obstacles, so none of them breaks windows or walls. The tear sprite is the
// existing bag of holding tear (icons/effects/96x96.dmi). The crew is warned once the tear is about to open.

/// Frakcja stworów z rozdarć i portali zaświatów (nie walczą ze sobą)
#define AQUILA_HEX_RIFT_FACTION "aquila_hex_rift"

/datum/round_event_control/aquila_hex_tear
	name = "Rozdarcie wymiarów"
	typepath = /datum/round_event/aquila_hex_tear
	weight = 5
	min_players = 15
	max_occurrences = 1
	earliest_start = 25 MINUTES

/datum/round_event/aquila_hex_tear
	fakeable = FALSE
	startWhen = 1
	announceWhen = 3
	endWhen = 60 // 2 min: rozdarcie i tak zamyka się samo wcześniej
	/// Pole, na którym otworzy się rozdarcie
	var/turf/tear_turf
	/// Typ rozdarcia
	var/obj/effect/aquila_hex_tear/tear_type = /obj/effect/aquila_hex_tear
	/// Otwarte rozdarcie (weakref)
	var/datum/weakref/tear_ref
	/// Tytuł ogłoszenia
	var/announce_title = "Alarm anomalii"

/datum/round_event/aquila_hex_tear/setup()
	var/list/room = aquila_hex_room_turfs(1)
	if(length(room))
		tear_turf = room[1]

/datum/round_event/aquila_hex_tear/start()
	if(!tear_turf || !aquila_hex_free_safe_turf(tear_turf))
		log_game("[type]: no free safe floor for the tear, cancelling the event.")
		tear_turf = null
		return kill()
	for(var/obj/machinery/light/light in range(8, tear_turf))
		INVOKE_ASYNC(light, TYPE_PROC_REF(/obj/machinery/light, flicker))
	notify_ghosts("W [get_area_name(tear_turf, TRUE)] zaraz otworzy się [initial(tear_type.name)].", source = tear_turf, action = NOTIFY_JUMP, flashwindow = FALSE, header = initial(tear_type.name))
	addtimer(CALLBACK(src, PROC_REF(open_tear)), 4 SECONDS)

/datum/round_event/aquila_hex_tear/announce(fake)
	if(!tear_turf)
		return
	priority_announce(announce_text(get_area_name(tear_turf, TRUE)), announce_title)

/// Treść ogłoszenia
/datum/round_event/aquila_hex_tear/proc/announce_text(area_name)
	return "Czujniki wykryły rozdarcie w tkance czasoprzestrzeni na pokładzie. Przewidywane miejsce: [area_name]. Coś próbuje przez nie przejść. Ochrona do wskazanego pomieszczenia, reszta załogi z dala."

/datum/round_event/aquila_hex_tear/end()
	var/obj/effect/aquila_hex_tear/tear = tear_ref?.resolve()
	if(!QDELETED(tear))
		tear.close()

/// Otwiera rozdarcie na wybranym polu (jeśli dalej jest wolne); zwraca rozdarcie
/datum/round_event/aquila_hex_tear/proc/open_tear()
	if(!tear_turf || !aquila_hex_free_safe_turf(tear_turf))
		log_game("[type]: the tear turf got blocked before the tear opened.")
		return null
	var/obj/effect/aquila_hex_tear/tear = new tear_type(tear_turf)
	tear_ref = WEAKREF(tear)
	message_admins("[tear.name] otwiera się w [ADMIN_VERBOSEJMP(tear_turf)] i wypuści [tear.spawn_max] stworów.")
	log_game("[type]: [tear] opened at [AREACOORD(tear_turf)], [tear.spawn_max] creatures.")
	return tear

/**
 * Rozdarcie: wypuszcza spawn_max stworów (ostatni to przewodnik, jeśli jest) po jednym co spawn_delay na wolne pola
 * obok siebie, potem się zamyka; zamyka się też samo po lifespan.
 */
/obj/effect/aquila_hex_tear
	name = "rozdarcie wymiarów"
	desc = "Rozdarcie w tkance przestrzeni i czasu. Po drugiej stronie coś warczy."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "boh_tear"
	pixel_x = -32
	pixel_y = -32
	anchored = TRUE
	density = FALSE
	layer = ABOVE_MOB_LAYER
	light_range = 3
	light_power = 2
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	/// Zwykłe stwory, które wychodzą z rozdarcia
	var/list/possible_mobs = list(
		/mob/living/basic/aquila_hellhound,
		/mob/living/basic/aquila_hellhound,
		/mob/living/basic/skeleton,
		/mob/living/basic/creature,
		/mob/living/basic/migo,
		/mob/living/basic/faithless,
	)
	/// Przewodnik wychodzący na końcu (null - bez przewodnika)
	var/leader_type = /mob/living/basic/aquila_hellhound/alpha
	/// Najmniej i najwięcej stworów (z przewodnikiem)
	var/min_mobs = 5
	var/max_mobs = 10
	/// Ile stworów wyjdzie (z przewodnikiem)
	var/spawn_max = 5
	/// Ile już wyszło
	var/spawned = 0
	/// Czas między stworami
	var/spawn_delay = 2 SECONDS
	/// Po jakim czasie rozdarcie zamyka się samo
	var/lifespan = 90 SECONDS
	/// Dźwięk otwarcia
	var/open_sound = 'sound/magic/enter_blood.ogg'
	/// Wypuszczone stwory (weakrefy)
	var/list/datum/weakref/spawned_refs = list()

/obj/effect/aquila_hex_tear/Initialize(mapload)
	. = ..()
	spawn_max = rand(min_mobs, max_mobs)
	playsound(src, open_sound, 100, TRUE)
	visible_message("<span class='danger'>Przestrzeń pęka z trzaskiem i otwiera się [name]!</span>")
	addtimer(CALLBACK(src, PROC_REF(spawn_next)), spawn_delay)
	addtimer(CALLBACK(src, PROC_REF(close)), lifespan)

/obj/effect/aquila_hex_tear/Destroy()
	spawned_refs.Cut()
	return ..()

/// Wypuszcza kolejnego stwora; po ostatnim rozdarcie po chwili się zamyka
/obj/effect/aquila_hex_tear/proc/spawn_next()
	if(QDELETED(src))
		return
	if(spawned >= spawn_max)
		addtimer(CALLBACK(src, PROC_REF(close)), 5 SECONDS)
		return
	var/is_leader = leader_type && spawned == spawn_max - 1
	var/mob/living/creature = aquila_hex_rift_spawn(get_turf(src), is_leader ? leader_type : pick(possible_mobs), rift_faction())
	spawned++ // zajęte pola też zużywają kolejkę, żeby rozdarcie się zamknęło
	if(creature)
		spawned_refs += WEAKREF(creature)
		if(is_leader)
			creature.visible_message("<span class='danger'>Z [src] z potwornym warkotem wychodzi [creature]!</span>")
		else if(prob(30))
			creature.visible_message("<span class='danger'>Z [src] wychodzi [creature]!</span>")
	addtimer(CALLBACK(src, PROC_REF(spawn_next)), spawn_delay)

/// Frakcja wypuszczanych stworów
/obj/effect/aquila_hex_tear/proc/rift_faction()
	return AQUILA_HEX_RIFT_FACTION

/// Zamyka rozdarcie
/obj/effect/aquila_hex_tear/proc/close()
	if(QDELETED(src))
		return
	visible_message("<span class='notice'>[capitalize(name)] zasklepia się i znika.</span>")
	qdel(src)

/**
 * Stawia stwora z rozdarcia albo portalu na wolnym bezpiecznym polu przy center (najbliższe pierwsze, w zasięgu 2 pól,
 * bez mobów i drzwi), ustawia mu frakcję i, jeśli trzeba, AI, które nie atakuje przeszkód; null, gdy nie ma miejsca.
 */
/proc/aquila_hex_rift_spawn(turf/center, mob_type, faction = AQUILA_HEX_RIFT_FACTION)
	if(!isturf(center) || !ispath(mob_type, /mob/living))
		return null
	var/list/spots = list()
	for(var/turf/T as anything in aquila_hex_free_turfs_near(center, 9, 2))
		if(aquila_hex_free_safe_turf(T))
			spots += T
	if(!length(spots))
		return null
	var/mob/living/creature = new mob_type(pick(spots))
	creature.faction = list(faction)
	aquila_hex_rift_tame_ai(creature)
	return creature

/// Stwór z rozdarcia nie rozbija przeszkód: AI z atakiem przeszkód zastępuje zwykłe polowanie, a wręcz bije tylko cele
/proc/aquila_hex_rift_tame_ai(mob/living/creature)
	if(!isbasicmob(creature))
		return
	var/mob/living/basic/basic_creature = creature
	basic_creature.environment_smash = ENVIRONMENT_SMASH_NONE
	var/datum/ai_controller/controller = basic_creature.ai_controller
	if(!controller || controller.type == /datum/ai_controller/basic_controller/simple_hostile || istype(controller, /datum/ai_controller/basic_controller/clown))
		return
	QDEL_NULL(basic_creature.ai_controller)
	basic_creature.ai_controller = new /datum/ai_controller/basic_controller/simple_hostile(basic_creature)

/// Piekielny ogar: szybki pies z zaświatów, który poluje na wszystko, co żyje
/mob/living/basic/aquila_hellhound
	name = "piekielny ogar"
	desc = "Ogromny pies o sierści dymiącej jak żarzący się węgiel. Z pyska bucha mu siarką, a oczy świecą jak żar."
	icon = 'aquila/icons/planets/ruins/ramzi_hound.dmi'
	icon_state = "hound"
	icon_living = "hound"
	icon_dead = "hound_dead"
	color = "#ff5a3c"
	pixel_x = -4
	base_pixel_x = -4
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	mob_size = MOB_SIZE_HUMAN
	maxHealth = 80
	health = 80
	speed = 0.5
	obj_damage = 0
	melee_damage = 12
	sharpness = SHARP_EDGED
	attack_verb_continuous = "gryzie"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	speak_emote = list("warczy", "wyje")
	friendly_verb_continuous = "obwąchuje"
	combat_mode = TRUE
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500
	faction = list(AQUILA_HEX_RIFT_FACTION)
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/simple_hostile

/// Przewodnik sfory: większy, ciemniejszy i silniejszy ogar, który wychodzi z rozdarcia ostatni
/mob/living/basic/aquila_hellhound/alpha
	name = "przewodnik sfory piekielnych ogarów"
	desc = "Największy z piekielnych ogarów. Reszta sfory schodzi mu z drogi."
	color = "#c0281e"
	maxHealth = 150
	health = 150
	melee_damage = 18

/mob/living/basic/aquila_hellhound/alpha/Initialize(mapload)
	. = ..()
	var/matrix/bigger = matrix(transform)
	bigger.Scale(1.2)
	transform = bigger
