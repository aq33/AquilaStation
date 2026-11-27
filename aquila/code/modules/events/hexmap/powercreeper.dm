// AQUILA - Żywy kabel: w tunelach technicznych wyrasta obce pnącze, które rozrasta się po podłodze, wysysa prąd z APC i razi każdego, kto go dotknie bez izolowanych rękawic (port z vgstation-coders/vgstation13 code/modules/events/powercreeper.dm i code/game/gamemodes/events/powercreeper.dm)
// vg's powercreeper is a cable subtype that joins the powernet, turns room heat into power, spreads at 15-40% a tick
// with no limit, zaps mobs next to it and shocks whoever cuts it. Ours is not a cable: it grows from one root on our shared
// spreader (plague_helpers.dm), at most 30 pieces up to 7 tiles from the root, never through walls, windows, closed doors,
// onto mobs or into dangerous areas. Instead of making power every piece drains the APC cell of its room (never below 30%
// of the cell, never in dangerous or closed areas). It shocks
// whoever touches it or cuts it with a sharp tool or wirecutters and now and then whoever stands in it; insulated gloves
// protect from both. Fire, a lit welder and an EMP burn a piece away without a shock. Killing the root stops the growth
// and the rest withers in under half a minute. The crew is warned two minutes after it sprouts, if the root still lives.

/datum/round_event_control/aquila_hex_powercreeper
	name = "Żywy kabel"
	typepath = /datum/round_event/aquila_hex_powercreeper
	weight = 10
	min_players = 6
	max_occurrences = 1
	earliest_start = 20 MINUTES

/datum/round_event/aquila_hex_powercreeper
	fakeable = FALSE
	startWhen = 1
	announceWhen = 60
	/// Korzeń pnącza
	var/datum/weakref/root_ref

/datum/round_event/aquila_hex_powercreeper/start()
	var/obj/structure/aquila_hex_spreader/powercreeper/root = plant(aquila_hex_maint_turf())
	if(!root)
		log_game("Powercreeper: no free maintenance turf found, cancelling the event.")
		return kill()
	root_ref = WEAKREF(root)
	announce_to_ghosts(root)

/datum/round_event/aquila_hex_powercreeper/announce(fake)
	var/obj/structure/aquila_hex_spreader/powercreeper/root = root_ref?.resolve()
	if(QDELETED(root))
		return
	var/area/root_area = get_area(root)
	priority_announce("W tunelach technicznych ([root_area.name]) wykryto obcą roślinę, która wrasta w instalację elektryczną i wysysa z niej prąd. Usuwać tylko w izolowanych rękawicach: przecinakiem, nożem albo palnikiem. Zniszczenie korzenia zatrzyma rozrost.", "Alarm biologiczny", ANNOUNCER_ALIENS)

/// Sadzi korzeń żywego kabla na polu; zwraca korzeń albo null
/datum/round_event/aquila_hex_powercreeper/proc/plant(turf/spot)
	if(!isturf(spot))
		return null
	var/obj/structure/aquila_hex_spreader/powercreeper/root = new(spot)
	message_admins("Żywy kabel wyrasta w [ADMIN_VERBOSEJMP(spot)].")
	log_game("Powercreeper: a powercreeper root sprouted at [AREACOORD(spot)].")
	return root

/**
 * Żywy kabel: kawałek pnącza. Pierwszy (korzeń) rozrasta się, wysysa prąd i razi tych, którzy w nim stoją.
 */
/obj/structure/aquila_hex_spreader/powercreeper
	name = "żywy kabel"
	desc = "Pulsujące, iskrzące pnącze z obcej planety, które wrasta w instalację i żywi się prądem. Lepiej nie dotykać go gołymi rękami."
	icon = 'aquila/icons/obj/plagues/powercreeper.dmi'
	icon_state = "neutral_bare"
	layer = SPACEVINE_LAYER
	max_integrity = 25
	max_pieces = 30
	max_radius = 7
	spread_chance = 20
	light_range = 1.5
	light_power = 0.6
	light_color = LIGHT_COLOR_RED
	/// Obrażenia od porażenia przy dotyku
	var/shock_damage = 15
	/// Ile energii każdy kawałek wysysa co przetworzenie korzenia
	var/drain_per_piece = 5
	/// Szansa (%), że kawałek porazi kogoś, kto w nim stoi (przy każdym przetworzeniu korzenia)
	var/zap_chance = 25

/obj/structure/aquila_hex_spreader/powercreeper/Initialize(mapload, obj/structure/aquila_hex_spreader/new_root)
	. = ..()
	if(root == src)
		name = "korzeń żywego kabla"
		desc += " Z tego splotu wyrasta całe pnącze."
		icon_state = "neutral"
		set_light(2.5, 1, LIGHT_COLOR_RED)
		flick("creation", src)
	else
		icon_state = prob(20) ? "neutral" : "neutral_bare"
		flick(icon_state == "neutral" ? "growing" : "growing_bare", src)

/obj/structure/aquila_hex_spreader/powercreeper/on_grown(obj/structure/aquila_hex_spreader/from)
	dir = get_dir(from, src)

/obj/structure/aquila_hex_spreader/powercreeper/process(delta_time)
	. = ..()
	if(root != src)
		return
	for(var/obj/structure/aquila_hex_spreader/powercreeper/piece as anything in pieces)
		aquila_hex_drain_area_power(piece, drain_per_piece)
		if(prob(zap_chance))
			piece.zap_standing()

/// Razi kogoś, kto stoi w kawałku pnącza; zwraca TRUE, gdy kogoś poraził
/obj/structure/aquila_hex_spreader/powercreeper/proc/zap_standing()
	for(var/mob/living/carbon/victim in loc)
		if(victim.stat == DEAD)
			continue
		flick(icon_state == "neutral" ? "attacking" : "attacking_bare", src)
		return shock(victim, round(shock_damage * 0.6), FALSE)
	return FALSE

/// Poraża kogoś (izolowane rękawice chronią); zwraca TRUE, gdy poraziło
/obj/structure/aquila_hex_spreader/powercreeper/proc/shock(mob/living/victim, damage = shock_damage, stun = TRUE)
	if(!iscarbon(victim) || victim.stat == DEAD)
		return FALSE
	var/mob/living/carbon/carbon_victim = victim
	do_sparks(2, TRUE, src)
	playsound(src, 'sound/magic/lightningshock.ogg', 40, TRUE)
	return carbon_victim.electrocute_act(damage, src, 1, stun = stun) > 0

/// Wyrwanie gołą ręką: bez izolowanych rękawic kończy się porażeniem
/obj/structure/aquila_hex_spreader/powercreeper/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(. || !isliving(user))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	if(shock(user))
		return TRUE
	user.visible_message("<span class='notice'>[user] wyrywa [src] gołymi rękami.</span>", "<span class='notice'>Wyrywasz [src]. Rękawice chronią cię przed prądem.</span>")
	cut_away()
	return TRUE

/obj/structure/aquila_hex_spreader/powercreeper/attacked_by(obj/item/I, mob/living/user)
	if(I.is_hot() || (I.tool_behaviour == TOOL_WELDER && I.tool_use_check(user, 0)))
		user.visible_message("<span class='notice'>[user] wypala [src].</span>", "<span class='notice'>Wypalasz [src].</span>")
		cut_away()
		return
	if(I.tool_behaviour == TOOL_WIRECUTTER || I.is_sharp())
		if(shock(user))
			return
		user.visible_message("<span class='notice'>[user] odcina [src].</span>", "<span class='notice'>Odcinasz [src].</span>")
		cut_away()
		return
	if(I.flags_1 & CONDUCT_1)
		shock(user)
	return ..()

/obj/structure/aquila_hex_spreader/powercreeper/emp_act(severity)
	. = ..()
	if(!(. & EMP_PROTECT_SELF))
		cut_away()

/obj/structure/aquila_hex_spreader/powercreeper/fire_act(exposed_temperature, exposed_volume)
	cut_away()

/// Kawałek ginie (wycięty, wypalony, spalony)
/obj/structure/aquila_hex_spreader/powercreeper/proc/cut_away()
	if(QDELETED(src))
		return
	playsound(src, 'sound/effects/sparks2.ogg', 40, TRUE)
	qdel(src)
