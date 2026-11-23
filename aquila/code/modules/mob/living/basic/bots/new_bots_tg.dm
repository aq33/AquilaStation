// Nowe boty z tgstation (tgstation/tgstation@5ee81d6): Vibebot i dron eksenteracyjny Donk (Donk Exenteration Drone, D.E.D.bot).
// Sprite'y w aquila/icons/mob/bots/tg_bots.dmi (tgstation, CC BY-SA 3.0).

/// Vibebot: gra muzykę, zmienia kolor światła i poprawia nastrój osób obok. Po zhakowaniu przygnębia.
/mob/living/basic/bot/vibebot
	name = "\improper Vibebot"
	desc = "Mały robot. Po prostu sobie wajbuje."
	icon = 'aquila/icons/mob/bots/tg_bots.dmi'
	icon_state = "vibebot1"
	base_icon_state = "vibebot"
	light_range = 6
	light_power = 2
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE
	model = "Vibebot"
	hackables = "skanery wajbu"
	work_reach = 1
	work_scan_range = 6
	work_interval = 4 SECONDS
	work_target_types = list(/mob/living/carbon/human)
	possessed_message = "Jesteś vibebotem! Dbaj o klimat na okręcie, jak tylko potrafisz."
	emagged_message = "Jesteś zepsutym vibebotem! Psuj wszystkim imprezę."
	idle_phrases = list("Czujecie ten wajb?", "Impreza trwa!", "Rytm się nie zatrzymuje!")
	/// Wbudowany syntezator
	var/obj/item/instrument/piano_synth/piano
	/// Kto ostatnio dostał imprezę (żeby nie zamęczać jednej osoby)
	var/list/partied = list()

/mob/living/basic/bot/vibebot/Initialize(mapload)
	. = ..()
	piano = new(src)

/mob/living/basic/bot/vibebot/Destroy()
	QDEL_NULL(piano)
	partied = null
	return ..()

/mob/living/basic/bot/vibebot/update_overlays()
	. = ..()
	if(bot_mode_flags & BOT_MODE_ON)
		. += mutable_appearance(icon, "vibebot_head_1")
	else
		. += mutable_appearance(icon, "vibebot_head_0")

/mob/living/basic/bot/vibebot/is_valid_work_target(atom/target)
	var/mob/living/carbon/human/guest = target
	if(guest.stat || !guest.client)
		return FALSE
	return world.time > partied[WEAKREF(guest)]

/mob/living/basic/bot/vibebot/work_on_target(atom/target)
	var/mob/living/carbon/human/guest = target
	if(!istype(guest))
		return BOT_WORK_DONE
	if(get_dist(src, guest) > 1)
		return BOT_WORK_OUT_OF_REACH
	partied[WEAKREF(guest)] = world.time + 3 MINUTES
	vibe()
	return BOT_WORK_DONE

/// Nowy kolor światła i impreza dla osób obok
/mob/living/basic/bot/vibebot/proc/vibe()
	var/final_color = is_emagged() ? COLOR_GRAY : "#[random_color()]"
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	add_atom_colour(final_color, TEMPORARY_COLOUR_PRIORITY)
	set_light_color(final_color)
	playsound(src, is_emagged() ? 'sound/machines/buzz-sigh.ogg' : pick('sound/items/bikehorn.ogg', 'sound/machines/ping.ogg'), 30, TRUE)
	for(var/mob/living/carbon/human/guest in oview(1, src))
		SEND_SIGNAL(guest, COMSIG_ADD_MOOD_EVENT, "vibebot_party", is_emagged() ? /datum/mood_event/vibebot_grim : /datum/mood_event/vibebot_party)
	visible_message(span_notice("[src] [is_emagged() ? "ponuro brzęczy, a światło gaśnie w szarości" : "rozkręca imprezę i mieni się kolorami"]!"))

/mob/living/basic/bot/vibebot/bot_reset(bypass_ai_reset)
	. = ..()
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	set_light_color(initial(light_color))

/mob/living/basic/bot/vibebot/emag_effects(mob/user)
	if(user)
		to_chat(user, span_danger("Psujesz skanery wajbu [src]."))
	vibe()

/mob/living/basic/bot/vibebot/explode()
	var/atom/drop_spot = drop_location()
	new /obj/item/assembly/prox_sensor(drop_spot)
	new /obj/item/light/bulb(drop_spot)
	return ..()

/datum/mood_event/vibebot_party
	description = "<span class='nicegreen'>To była świetna impreza!</span>\n"
	mood_change = 2
	timeout = 30 SECONDS

/datum/mood_event/vibebot_grim
	description = "<span class='warning'>To była naprawdę ponura impreza...</span>\n"
	mood_change = -1
	timeout = 30 SECONDS

/datum/crafting_recipe/vibebot
	name = "Vibebot"
	result = /mob/living/basic/bot/vibebot
	reqs = list(
		/obj/item/light/bulb = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/assembly/prox_sensor = 1,
		/obj/item/bodypart/r_arm/robot = 1,
	)
	time = 4 SECONDS
	category = CAT_ROBOT

/**
 * Dron eksenteracyjny Donk (Donk Exenteration Drone): wrogi dron obronny Donk Co. z ruin. Patroluje i tnie każdego bez implantu
 * Syndykatu (frakcja „Syndicate”). W tg budowy nie ma; u nas jest tylko gotowy dron w uplinku (cięcie R29).
 */
/mob/living/basic/bot/dedbot
	name = "\improper dron eksenteracyjny Donk"
	desc = "Uzbrojony w ostrza komercyjny dron obronny, zwany „Ex-Dronem” albo D.E.D.botem. Chodzi po prostej trasie i tnie każdego, kto nie ma implantu identyfikacyjnego."
	icon = 'aquila/icons/mob/bots/tg_bots.dmi'
	icon_state = "ded_drone0"
	base_icon_state = "ded_drone"
	maxHealth = 50
	health = 50
	light_range = 1
	light_power = 0.3
	light_color = "#eb1809"
	faction = list(FACTION_SYNDICATE)
	model = "Ex-Dron"
	hackables = "rozpoznawanie implantów"
	bot_mode_flags = BOT_MODE_ON | BOT_MODE_AUTOPATROL
	possessed_message = "Jesteś dronem eksenteracyjnym. Wypruwaj."
	emagged_message = "Jesteś zepsutym dronem eksenteracyjnym. Tniesz wszystkich."
	work_reach = 1
	work_scan_range = 2
	work_interval = 0.5 SECONDS
	work_mode = BBOT_HUNT
	robot_arm = /obj/item/hatchet
	maximum_survivable_temperature = 360
	/// Obrażenia jednego obrotu ostrzy
	var/damage_dealt = 18

/mob/living/basic/bot/dedbot/is_valid_work_target(atom/target)
	if(!isliving(target))
		return FALSE
	var/mob/living/victim = target
	if(victim.stat == DEAD || victim == src)
		return FALSE
	return is_emagged() || !faction_check_mob(victim)

/mob/living/basic/bot/dedbot/work_on_target(atom/target)
	var/mob/living/victim = target
	if(!istype(victim) || victim.stat == DEAD)
		return BOT_WORK_DONE
	if(get_dist(src, victim) > 1)
		return BOT_WORK_OUT_OF_REACH
	exenterate()
	return BOT_WORK_CONTINUE

/// Obrót ostrzami: tnie wszystkich obok poza swoją frakcją
/mob/living/basic/bot/dedbot/proc/exenterate()
	Shake(1.4, 0.8, 0.3 SECONDS)
	visible_message(span_danger("[src] gwałtownie się trzęsie!"))
	playsound(src, 'sound/weapons/drill.ogg', 80, TRUE)
	for(var/mob/living/victim in range(1, src))
		if(victim == src || (!is_emagged() && faction_check_mob(victim)))
			continue
		to_chat(victim, span_warning("Ostrza [src] cię tną!"))
		victim.apply_damage(damage_dealt, BRUTE, pick(BODY_ZONE_CHEST, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))

/mob/living/basic/bot/dedbot/explode()
	new /obj/effect/gibspawner/robot(drop_location())
	return ..()

/// Gotowy dron z uplinka (w tg budowy ani pozycji w uplinku nie ma). Zostaje w frakcji Syndykatu,
/// a kupujący dostaje wspólną frakcję z dronem, więc ten go nie tnie.
/datum/uplink_item/dangerous/aq_dedbot
	name = "Dron eksenteracyjny Donk"
	desc = "Dron obronny Donk Co. z obracającymi się ostrzami. Pojawia się pod tobą włączony, chodzi po prostej trasie i tnie każdego, kto nie ma implantu znacznika Syndykatu. Ciebie zna i oszczędza."
	item = /mob/living/basic/bot/dedbot
	cost = 8
	surplus = 0

/datum/uplink_item/dangerous/aq_dedbot/spawn_item(spawn_path, mob/user, datum/component/uplink/U)
	var/mob/living/basic/bot/dedbot/drone = ..()
	if(istype(drone) && user)
		var/owner_faction = "dedbot_[REF(user)]"
		drone.faction |= owner_faction
		user.faction |= owner_faction
	return drone
