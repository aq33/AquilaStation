// AQUILA - Napromieniowana mysz: z wentylacji wybiega zielono świecąca mysz, która co kilka sekund promieniuje na otoczenie, dopóki ktoś jej nie złapie albo nie zabije (pomysł z ParadiseSS13/Paradise code/modules/events/event_container.dm, spawn_irradiated_mouse)
// Paradise registers the event in its event container; its mouse (code/game/gamemodes/miniantags/irradiated_mouse/) is
// a ghost role mini-antagonist that irradiates whoever it bites and buys upgrades. Ours is written from scratch as a
// plain NPC: a small variant of our basic mouse (glowing green, immune to radiation, a bit sturdier) that sends out a weak
// radiation pulse every 5 s, also when held, so it can be caught in hand, put in a box or killed. No ghost, no upgrades.

/datum/round_event_control/aquila_hex_irradiated_mouse
	name = "Napromieniowana mysz"
	typepath = /datum/round_event/aquila_hex_irradiated_mouse
	weight = 10
	min_players = 5
	max_occurrences = 2
	earliest_start = 15 MINUTES

/datum/round_event/aquila_hex_irradiated_mouse
	fakeable = FALSE
	startWhen = 1

/datum/round_event/aquila_hex_irradiated_mouse/start()
	var/list/vents = aquila_hex_vent_turfs()
	var/turf/spot = length(vents) ? pick(vents) : aquila_hex_maint_turf()
	var/mob/living/basic/mouse/aquila_hex_irradiated/mouse = spawn_mouse(spot)
	if(!mouse)
		log_game("Irradiated Mouse: no vent or free maintenance turf found, cancelling the event.")
		return kill()
	announce_to_ghosts(mouse)

/datum/round_event/aquila_hex_irradiated_mouse/proc/spawn_mouse(turf/spot)
	if(!isturf(spot))
		return null
	var/mob/living/basic/mouse/aquila_hex_irradiated/mouse = new(spot)
	mouse.visible_message("<span class='warning'>Z kratki wentylacyjnej wybiega świecąca na zielono mysz!</span>")
	message_admins("Napromieniowana mysz pojawia się w [ADMIN_VERBOSEJMP(spot)].")
	log_game("Irradiated Mouse: a glowing mouse spawned at [AREACOORD(spot)].")
	return mouse

/// Mysz, która świeci i promieniuje
/mob/living/basic/mouse/aquila_hex_irradiated
	name = "napromieniowana mysz"
	desc = "Mała, roznosząca choroby mysz, która w dodatku świeci na zielono. Licznik Geigera trzeszczy na jej widok."
	body_color = "white"
	maxHealth = 15
	health = 15
	gold_core_spawnable = NO_SPAWN
	light_range = 2
	light_power = 0.8
	light_color = LIGHT_COLOR_GREEN
	/// Co ile promieniuje
	var/pulse_delay = 5 SECONDS
	COOLDOWN_DECLARE(pulse_cooldown)

/mob/living/basic/mouse/aquila_hex_irradiated/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_RADIMMUNE, INNATE_TRAIT)
	add_atom_colour("#7dff6a", FIXED_COLOUR_PRIORITY)

/mob/living/basic/mouse/aquila_hex_irradiated/Life(seconds, times_fired)
	. = ..()
	if(stat == DEAD || QDELETED(src) || !COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	irradiate()

/// Słaby impuls promieniowania wokół myszy (także z ręki albo pudełka); zwraca TRUE, gdy wysłał
/mob/living/basic/mouse/aquila_hex_irradiated/proc/irradiate()
	if(stat == DEAD || !get_turf(src))
		return FALSE
	COOLDOWN_START(src, pulse_cooldown, pulse_delay)
	radiation_pulse(src, max_range = 2, threshold = RAD_LIGHT_INSULATION)
	return TRUE
