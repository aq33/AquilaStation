// AQUILA - Umysł z ciała: przewody, ściany i drzwi z przewodów, rdzeń i struktury roju (port z Bubberstation/Bubberstation
// modular_zubbers/code/game/gamemodes/fleshmind/fleshmind_structures.dm i fleshmind_environment_objects.dm)
// Changes against Bubberstation:
// - wireweed picks its own bitmask state (our smoothing has no SMOOTH_BITMASK) and does not replace missing limbs;
// - the core does not explode when destroyed and throws attackers 4 tiles instead of 20 (no hull damage); its retaliation
//   builds walls only on free turfs (no mobs, doors, closed turfs) and spawns a Mechiver only within the mob limit;
// - the assembler has no manual mob choice (Bubberstation let any non-swarm user pick it, a leftover of debugging);
// - babbler, whisperer and screamer lines are written anew in Polish; the screamer knocks down for 5 s, not 10 s;
// - sounds of modules we do not have (black_mesa, horrorform) are replaced with ours.

/obj/structure/fleshmind
	icon = 'aquila/icons/fleshmind/fleshmind_structures.dmi'
	icon_state = "wires"
	anchored = TRUE
	/// Kontroler roju
	var/datum/fleshmind_controller/our_controller
	/// Najniższy poziom roju, na którym rój to stawia
	var/required_controller_level = 1

/obj/structure/fleshmind/Destroy()
	our_controller = null
	return ..()

/// Czy mob należy do roju
/proc/fleshmind_is_ally(mob/living/target)
	return istype(target) && (FACTION_FLESHMIND in target.faction)

/**
 * Przewody: arterie roju, po których rój rośnie i które leczą jego moby
 */
/obj/structure/fleshmind/wireweed
	name = "mięsne przewody"
	desc = "Dziwna, pulsująca masa organicznych przewodów. Da się je przeciąć przecinakiem."
	icon = 'aquila/icons/fleshmind/wireweed_floor.dmi'
	icon_state = "wires-0"
	layer = TURF_DECAL_LAYER
	max_integrity = 40
	/// Przewody w wentylacji
	var/vent_burrow = FALSE
	/// Timer, po którym przewody stają się w pełni widoczne
	var/alpha_timer

/obj/structure/fleshmind/wireweed/Initialize(mapload, starting_alpha = 255, datum/fleshmind_controller/incoming_controller)
	. = ..()
	alpha = starting_alpha
	our_controller = incoming_controller
	var/static/list/loc_connections = list(COMSIG_ATOM_ENTERED = PROC_REF(on_entered))
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/fleshmind/wireweed/Destroy()
	if(alpha_timer)
		deltimer(alpha_timer)
		alpha_timer = null
	var/turf/old_turf = get_turf(src)
	. = ..()
	if(old_turf)
		for(var/turf/near as anything in RANGE_TURFS(1, old_turf))
			for(var/obj/structure/fleshmind/wireweed/neighbour in near)
				if(!QDELETED(neighbour))
					neighbour.update_icon()

/obj/structure/fleshmind/wireweed/wirecutter_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(tool.use_tool(src, user, FLESHMIND_WIREWEED_CUT_TIME, volume = 50) && !QDELETED(src))
		to_chat(user, "<span class='notice'>Przecinasz [src].</span>")
		qdel(src)

/obj/structure/fleshmind/wireweed/emp_act(severity)
	. = ..()
	take_damage(10)

/obj/structure/fleshmind/wireweed/update_icon_state()
	. = ..()
	if(vent_burrow)
		icon_state = "vent_burrow"
		return
	var/junction = 0
	for(var/dir in GLOB.cardinals)
		var/turf/near = get_step(src, dir)
		if(near && (near.density || (locate(/obj/structure/fleshmind/wireweed) in near)))
			junction |= dir
	// Narożniki tylko przy obu sąsiednich bokach, jak bitmaska smoothingu tg
	var/static/list/corners = list("[NORTHEAST]" = 16, "[SOUTHEAST]" = 32, "[SOUTHWEST]" = 64, "[NORTHWEST]" = 128)
	for(var/corner in list(NORTHEAST, SOUTHEAST, SOUTHWEST, NORTHWEST))
		if((junction & corner) != corner)
			continue
		var/turf/near = get_step(src, corner)
		if(near && (near.density || (locate(/obj/structure/fleshmind/wireweed) in near)))
			junction |= corners["[corner]"]
	icon_state = "wires-[junction]"

/obj/structure/fleshmind/wireweed/update_overlays()
	. = ..()
	for(var/wall_dir in GLOB.cardinals)
		var/turf/near = get_step(src, wall_dir)
		if(!near?.density)
			continue
		var/mutable_appearance/wall_overlay = mutable_appearance(icon, "wall_hug")
		wall_overlay.dir = wall_dir
		switch(wall_dir)
			if(NORTH)
				wall_overlay.pixel_y = 32
			if(SOUTH)
				wall_overlay.pixel_y = -32
			if(EAST)
				wall_overlay.pixel_x = 32
			if(WEST)
				wall_overlay.pixel_x = -32
		. += wall_overlay

/// Odświeża wygląd siebie i sąsiednich przewodów
/obj/structure/fleshmind/wireweed/proc/update_neighbours()
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return
	for(var/turf/near as anything in RANGE_TURFS(1, our_turf))
		for(var/obj/structure/fleshmind/wireweed/neighbour in near)
			neighbour.update_icon()

/obj/structure/fleshmind/wireweed/proc/visual_finished()
	alpha_timer = null
	alpha = 255

/obj/structure/fleshmind/wireweed/proc/on_entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(!isliving(arrived) || istype(arrived, /mob/living/basic/fleshmind/tyrant))
		return
	var/mob/living/entered_mob = arrived
	if(!fleshmind_is_ally(entered_mob) || entered_mob.stat == DEAD || !prob(FLESHMIND_WIREWEED_HEAL_CHANCE))
		return
	entered_mob.heal_overall_damage(FLESHMIND_WIREWEED_HEAL_AMOUNT, FLESHMIND_WIREWEED_HEAL_AMOUNT)
	to_chat(entered_mob, "<span class='green'>[capitalize(src.name)] leczą cię, gdy po nich przechodzisz!</span>")

/obj/effect/temp_visual/wireweed_spread
	icon = 'aquila/icons/fleshmind/wireweed_floor.dmi'
	icon_state = "spread_anim"
	layer = TURF_DECAL_LAYER
	randomdir = FALSE
	duration = 1.7 SECONDS

/**
 * Struktury roju: wspólne zachowanie (zdolność wyzwalana z bliska, co jakiś czas albo przy ataku, wyłączenie przez EMP)
 */
/obj/structure/fleshmind/structure
	name = "struktura roju"
	desc = "Nie powinno jej tu być."
	icon = 'aquila/icons/fleshmind/fleshmind_machines.dmi'
	icon_state = "infected_machine"
	density = TRUE
	layer = ABOVE_OBJ_LAYER
	light_color = FLESHMIND_LIGHT_BLUE
	light_power = 1
	light_range = 2
	/// Wyłączona przez EMP
	var/disabled = FALSE
	/// Zdolność przy ataku
	var/trigger_on_attack = FALSE
	/// Co ile (od-do) zdolność działa sama; 0 wyłącza
	var/automatic_trigger_time_lower = 0
	var/automatic_trigger_time_upper = 0
	/// Zasięg, w którym wejście obcego wyzwala zdolność; 0 wyłącza
	var/activation_range = 0
	/// Odnowienie zdolności; 0 wyłącza
	var/ability_cooldown_time = 0
	COOLDOWN_DECLARE(ability_cooldown)
	/// Czy ma sprite wyłączenia
	var/disabled_sprite = TRUE
	/// Opis dla członków roju (oględziny z bliska)
	var/converted_desc
	/// Timer samoczynnej zdolności
	var/automatic_timer
	/// Timer włączenia po EMP
	var/enable_timer
	/// Pola, których wejście wyzwala zdolność
	var/list/trigger_turfs

/obj/structure/fleshmind/structure/Initialize(mapload)
	. = ..()
	if(activation_range)
		calculate_trigger_turfs()
	if(automatic_trigger_time_lower)
		automatic_timer = addtimer(CALLBACK(src, PROC_REF(automatic_trigger)), rand(automatic_trigger_time_lower, automatic_trigger_time_upper), TIMER_STOPPABLE)

/obj/structure/fleshmind/structure/Destroy()
	if(automatic_timer)
		deltimer(automatic_timer)
		automatic_timer = null
	if(enable_timer)
		deltimer(enable_timer)
		enable_timer = null
	for(var/turf/trigger_turf as anything in trigger_turfs)
		UnregisterSignal(trigger_turf, COMSIG_ATOM_ENTERED)
	trigger_turfs = null
	return ..()

/obj/structure/fleshmind/structure/update_icon_state()
	. = ..()
	icon_state = (disabled && disabled_sprite) ? "[base_icon_state]-disabled" : base_icon_state

/obj/structure/fleshmind/structure/attacked_by(obj/item/attacking_item, mob/living/user)
	. = ..()
	if(trigger_on_attack && COOLDOWN_FINISHED(src, ability_cooldown))
		activate_ability(user)

/obj/structure/fleshmind/structure/examine(mob/user)
	. = ..()
	if(converted_desc && fleshmind_is_ally(user))
		. += "<span class='notice'>Jedność z <b>ciałem</b> mówi ci: [converted_desc]</span>"

/obj/structure/fleshmind/structure/proc/calculate_trigger_turfs()
	trigger_turfs = list()
	for(var/turf/open/seen_turf in RANGE_TURFS(activation_range, src))
		RegisterSignal(seen_turf, COMSIG_ATOM_ENTERED, PROC_REF(proximity_trigger))
		trigger_turfs += seen_turf

/obj/structure/fleshmind/structure/proc/proximity_trigger(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(disabled || !our_controller || !isliving(arrived))
		return
	if(ability_cooldown_time && !COOLDOWN_FINISHED(src, ability_cooldown))
		return
	var/mob/living/arriving_mob = arrived
	if(arriving_mob.stat != CONSCIOUS || fleshmind_is_ally(arriving_mob) || !can_see(src, arriving_mob, activation_range))
		return
	INVOKE_ASYNC(src, PROC_REF(activate_ability), arriving_mob)

/obj/structure/fleshmind/structure/proc/automatic_trigger()
	automatic_timer = addtimer(CALLBACK(src, PROC_REF(automatic_trigger)), rand(automatic_trigger_time_lower, automatic_trigger_time_upper), TIMER_STOPPABLE)
	if(disabled || !our_controller)
		return
	activate_ability()

/// Zdolność struktury; podtypy wołają ..() na początku
/obj/structure/fleshmind/structure/proc/activate_ability(mob/living/triggered_mob)
	if(ability_cooldown_time)
		COOLDOWN_START(src, ability_cooldown, ability_cooldown_time)

/obj/structure/fleshmind/structure/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(severity == EMP_HEAVY)
		take_damage(FLESHMIND_STRUCTURE_EMP_HEAVY_DAMAGE)
		disable(FLESHMIND_STRUCTURE_EMP_HEAVY_TIME)
	else
		take_damage(FLESHMIND_STRUCTURE_EMP_LIGHT_DAMAGE)
		disable(FLESHMIND_STRUCTURE_EMP_LIGHT_TIME)

/obj/structure/fleshmind/structure/proc/disable(duration)
	if(disabled || QDELETED(src))
		return
	do_sparks(4, FALSE, src)
	balloon_alert_to_viewers("staje w miejscu")
	disabled = TRUE
	enable_timer = addtimer(CALLBACK(src, PROC_REF(enable)), duration, TIMER_STOPPABLE)
	update_icon()

/obj/structure/fleshmind/structure/proc/enable()
	enable_timer = null
	if(!disabled)
		return
	balloon_alert_to_viewers("znowu warczy")
	disabled = FALSE
	update_icon()

/**
 * Ściana z przewodów
 */
/obj/structure/fleshmind/structure/wireweed_wall
	name = "ściana z przewodów"
	desc = "Ściana spleciona z mięsnych przewodów."
	icon = 'aquila/icons/fleshmind/fleshmind_structures.dmi'
	icon_state = "wireweed_wall"
	base_icon_state = "wireweed_wall"
	opacity = TRUE
	CanAtmosPass = ATMOS_PASS_DENSITY
	max_integrity = 150
	disabled_sprite = FALSE
	light_range = 0

/obj/structure/fleshmind/structure/wireweed_wall/Initialize(mapload)
	. = ..()
	air_update_turf(TRUE)

/obj/structure/fleshmind/structure/wireweed_wall/Destroy()
	var/turf/old_turf = get_turf(src)
	. = ..()
	old_turf?.air_update_turf(TRUE)

/**
 * Drzwi z przewodów: otwierają się przed obcym, który w nie wejdzie albo je pchnie
 */
/obj/structure/fleshmind/structure/wireweed_door
	name = "drzwi z przewodów"
	desc = "Drzwi splecione z mięsnych przewodów."
	icon = 'aquila/icons/fleshmind/fleshmind_structures.dmi'
	icon_state = "door_closed"
	base_icon_state = "door"
	CanAtmosPass = ATMOS_PASS_DENSITY
	max_integrity = 150
	disabled_sprite = FALSE
	light_range = 0
	color = "#CCFFFF"
	/// Zamknięte (TRUE) albo otwarte
	var/door_state = TRUE

/obj/structure/fleshmind/structure/wireweed_door/Initialize(mapload)
	. = ..()
	density = door_state
	set_opacity(door_state)

/obj/structure/fleshmind/structure/wireweed_door/attack_hand(mob/living/user)
	. = ..()
	if(. || fleshmind_is_ally(user))
		return
	toggle_door()
	to_chat(user, "<span class='notice'>[door_state ? "Zamykasz" : "Otwierasz"] [src]!</span>")

/obj/structure/fleshmind/structure/wireweed_door/Bumped(atom/movable/bumped_atom)
	. = ..()
	if(isliving(bumped_atom) && !fleshmind_is_ally(bumped_atom) && door_state)
		toggle_door()

/obj/structure/fleshmind/structure/wireweed_door/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]_[door_state ? "closed" : "open"]"

/obj/structure/fleshmind/structure/wireweed_door/proc/toggle_door()
	door_state = !door_state
	flick(door_state ? "door_closing" : "door_opening", src)
	density = door_state
	set_opacity(door_state)
	playsound(src, 'sound/effects/attackblob.ogg', 70, TRUE)
	air_update_turf(TRUE)
	update_icon()

/**
 * Rdzeń: jednostka procesorowa roju. Po jej zniszczeniu wszystko usycha.
 */
/obj/structure/fleshmind/structure/core
	name = "jednostka procesorowa"
	desc = "Potworna maszyna. Na pewno cię obserwuje."
	icon_state = "core"
	base_icon_state = "core"
	max_integrity = 800
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	converted_desc = "To jednostka procesorowa twojego jądra. Chroń ją za wszelką cenę, bo to ona daje ci życie. W razie potrzeby odrzuca napastników, ale nie powinno do tego dojść."
	/// Obrażenia uderzenia rdzenia
	var/attack_damage = 15
	/// Odnowienie ataku rdzenia po uszkodzeniu
	var/attack_cooldown = 3 SECONDS
	COOLDOWN_DECLARE(attack_move)
	/// Odnowienie odwetu (odrzut, wezwanie, ściany, Mechiwer)
	var/retaliate_effect_cooldown = 1 MINUTES
	COOLDOWN_DECLARE(retaliate_effect)
	/// Zasięg wezwania mobów i odrzutu
	var/rally_range = 10
	var/whip_range = 2

/obj/structure/fleshmind/structure/core/Initialize(mapload, spawn_controller = TRUE)
	. = ..()
	notify_ghosts("Nowy rdzeń Umysłu z ciała w obszarze [get_area_name(src)].", source = src, action = NOTIFY_ORBIT)
	if(spawn_controller)
		new /datum/fleshmind_controller(src)
		AddComponent(/datum/component/gps, "*!Sygnał mięsnych przewodów!*")
	START_PROCESSING(SSobj, src)
	update_icon()

/obj/structure/fleshmind/structure/core/Destroy()
	STOP_PROCESSING(SSobj, src)
	playsound(src, 'aquila/sound/fleshmind/sparks_2.ogg', 70, TRUE)
	new /obj/effect/gibspawner/robot(get_turf(src))
	return ..()

/obj/structure/fleshmind/structure/core/process(delta_time)
	var/mob/living/carbon/human/target = locate() in view(5, src)
	if(target && target.stat == CONSCIOUS && !fleshmind_is_ally(target))
		if(get_dist(src, target) <= 1)
			icon_state = "core-fear"
		else
			icon_state = "core-see"
			setDir(get_dir(src, target))
	else
		icon_state = base_icon_state
	if(COOLDOWN_FINISHED(src, attack_move) || disabled)
		return
	for(var/mob/living/living_thing in range(1, src))
		if(living_thing.stat == DEAD || fleshmind_is_ally(living_thing))
			continue
		living_thing.adjustBruteLoss(attack_damage)
		living_thing.visible_message("<span class='warning'>[capitalize(src.name)] uderza [living_thing]!</span>", "<span class='userdanger'>[capitalize(src.name)] uderza cię!</span>")
		playsound(loc, 'sound/effects/attackblob.ogg', 100, TRUE)
		do_attack_animation(living_thing, ATTACK_EFFECT_PUNCH)
		break

/obj/structure/fleshmind/structure/core/update_overlays()
	. = ..()
	. += disabled ? "core-smirk_disabled" : "core-smirk"

/obj/structure/fleshmind/structure/core/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	. = ..()
	if(!. || QDELETED(src))
		return
	our_controller?.core_damaged(src)
	COOLDOWN_START(src, attack_move, attack_cooldown)
	if(COOLDOWN_FINISHED(src, retaliate_effect))
		COOLDOWN_START(src, retaliate_effect, retaliate_effect_cooldown)
		INVOKE_ASYNC(src, PROC_REF(retaliate_effect))

/obj/structure/fleshmind/structure/core/examine(mob/user)
	. = ..()
	if(!our_controller)
		return
	if(isliving(user))
		. += "<span class='notice'>Twój GPS prowadzi prosto do tego czegoś!</span>"
	if(isobserver(user))
		. += "Poziom: [our_controller.level] | punkty: [our_controller.calculate_current_points()] | przewody: [length(our_controller.controlled_wireweed)]/[our_controller.max_wireweed]"

/obj/structure/fleshmind/structure/core/proc/retaliate_effect()
	whip_attackers()
	rally_troops()
	build_a_wall()
	spawn_mob_at_core(/mob/living/basic/fleshmind/mechiver)

/// Stawia moba na przewodach wokół rdzenia (bez struktury), w razie braku miejsca na samym rdzeniu
/obj/structure/fleshmind/structure/core/proc/spawn_mob_at_core(mob_type, force = FALSE)
	if(!our_controller)
		return null
	var/list/spawn_turfs = list()
	for(var/turf/spawn_turf as anything in RANGE_TURFS(2, src))
		if(!(locate(/obj/structure/fleshmind/wireweed) in spawn_turf) || (locate(/obj/structure/fleshmind/structure) in spawn_turf))
			continue
		if(spawn_turf.density || is_blocked_turf(spawn_turf, TRUE))
			continue
		spawn_turfs += spawn_turf
	return our_controller.spawn_mob(length(spawn_turfs) ? pick(spawn_turfs) : get_turf(src), mob_type, force)

/obj/structure/fleshmind/structure/core/proc/whip_attackers()
	for(var/mob/living/iterating_mob in view(whip_range, src))
		if(fleshmind_is_ally(iterating_mob))
			continue
		playsound(iterating_mob, 'sound/weapons/whip.ogg', 70, TRUE)
		new /obj/effect/temp_visual/kinetic_blast(get_turf(iterating_mob))
		var/atom/throw_target = get_edge_target_turf(iterating_mob, get_dir(src, iterating_mob))
		iterating_mob.throw_at(throw_target, 4, 2)

/// Ściany z przewodów wokół rdzenia, tylko na wolnych polach podłogi
/obj/structure/fleshmind/structure/core/proc/build_a_wall()
	if(!our_controller)
		return
	for(var/turf/iterating_turf in orange(1, src))
		if(!isopenturf(iterating_turf) || isspaceturf(iterating_turf) || isgroundlessturf(iterating_turf))
			continue
		if((locate(/obj/structure/fleshmind/structure) in iterating_turf) || (locate(/mob/living) in iterating_turf) || (locate(/obj/machinery/door) in iterating_turf))
			continue
		if(is_blocked_turf(iterating_turf, TRUE))
			continue
		our_controller.spawn_wall(iterating_turf)

/obj/structure/fleshmind/structure/core/proc/rally_troops()
	balloon_alert_to_viewers("wydaje ogłuszający wrzask!")
	playsound(src, 'sound/hallucinations/wail.ogg', 100, TRUE)
	for(var/mob/living/basic/fleshmind/mob_in_range in range(rally_range, src))
		if(mob_in_range.ai_controller && !mob_in_range.key)
			mob_in_range.ai_controller.set_blackboard_key(BB_BASIC_MOB_REINFORCEMENT_TARGET, src)
			mob_in_range.alert_sound()

/**
 * Bełkotnik: nadaje na wspólnym kanale radia bełkot roju (od poziomu 3)
 */
/obj/structure/fleshmind/structure/babbler
	name = "bełkotnik"
	desc = "Słupowata konstrukcja z mrugającymi światełkami."
	icon_state = "antenna"
	base_icon_state = "antenna"
	max_integrity = 100
	converted_desc = "Bełkotnik nadaje groźby przez radio załogi. Jądro buduje go dopiero na trzecim poziomie."
	required_controller_level = 3
	automatic_trigger_time_lower = 1.5 MINUTES
	automatic_trigger_time_upper = 2 MINUTES
	/// Radio, przez które bełkocze
	var/obj/item/radio/internal_radio

/obj/structure/fleshmind/structure/babbler/Initialize(mapload)
	. = ..()
	internal_radio = new(src)
	internal_radio.set_frequency(FREQ_COMMON)
	internal_radio.listening = FALSE

/obj/structure/fleshmind/structure/babbler/Destroy()
	QDEL_NULL(internal_radio)
	return ..()

/obj/structure/fleshmind/structure/babbler/activate_ability(mob/living/triggered_mob)
	. = ..()
	if(!our_controller)
		return
	flick("[base_icon_state]-anim", src)
	internal_radio.talk_into(src, babble(), null)

/// Zepsute zdania roju
/obj/structure/fleshmind/structure/babbler/proc/babble()
	var/static/list/appeal = list("Oni", "On", "Wszyscy", "Ja", "My")
	var/static/list/act = list("szukają", "już", "idą", "odchodzą", "skończyli", "dołączyli", "połączeni", "przeniesieni")
	var/static/list/specific = list("do", "z", "dla", "przez")
	var/static/list/pattern = list("nas", "was", "nich", "umysłu", "roju", "maszyny", "pomocy", "piekła", "martwych", "ludzi", "ciała")
	var/static/list/noise = list("z-z-bz-z", "hz-z-z", "zu-zu-we-e", "e-e-ew-e", "bz-ze-ew")
	var/static/list/replacements = list("SKAŻONY", "ZNISZCZONY", "SYMULOWANY", "SYMBIOZA", "WYKORZYSTANY", "USUNIĘTY", "PRZYJĘTY", "ULEPSZONY", "TCHÓRZ", "CIAŁO", "POSTĘP", "OHYDA", "BŁĄD", "USTERKA")
	var/msg = ""
	var/cycles = rand(1, 2)
	for(var/cycle in 1 to cycles)
		var/list/words = list(pick(appeal), pick(act), pick(specific), pick(pattern))
		for(var/i in 1 to length(words))
			var/word = words[i]
			if(prob(50))
				switch(rand(1, 3))
					if(1)
						word = uppertext(word)
					if(2)
						word = pick(noise)
					if(3)
						word = pick(replacements)
			msg += word + (i == length(words) ? "" : " ")
		msg += pick(".", "!")
		if(cycle != cycles)
			msg += " "
	return msg

/**
 * Udręczona głowa: wrzaskiem powala obcych w zasięgu (od poziomu 2)
 */
/obj/structure/fleshmind/structure/screamer
	name = "udręczona głowa"
	desc = "Głowa nabita na metalową wić. Wciąż drga, wciąż żyje, wciąż krzyczy."
	icon_state = "head"
	base_icon_state = "head"
	max_integrity = 120
	converted_desc = "Udręczona głowa ogłusza wrogów w pobliżu. Jądro buduje ją dopiero na drugim poziomie."
	required_controller_level = 2
	activation_range = FLESHMIND_VIEW_RANGE
	ability_cooldown_time = 45 SECONDS

/obj/structure/fleshmind/structure/screamer/activate_ability(mob/living/triggered_mob)
	. = ..()
	playsound(src, 'sound/hallucinations/wail.ogg', 100, TRUE)
	flick("[base_icon_state]-anim", src)
	for(var/mob/living/iterating_mob in get_hearers_in_view(activation_range, src))
		if(HAS_TRAIT(iterating_mob, TRAIT_DEAF) || fleshmind_is_ally(iterating_mob) || iterating_mob.stat == DEAD)
			continue
		iterating_mob.Knockdown(5 SECONDS)
		iterating_mob.Jitter(20)
		to_chat(iterating_mob, "<span class='userdanger'>Straszliwe wycie rozdziera ci umysł. Głos bez sensu, bez duszy.</span>")

/**
 * Szeptacz: podsuwa nieprzytomnym myśli roju (od poziomu 2)
 */
/obj/structure/fleshmind/structure/whisperer
	name = "szeptacz"
	desc = "Mała pulsująca kula bez widocznego celu. Cicho brzęczy."
	icon_state = "orb"
	base_icon_state = "orb"
	max_integrity = 100
	converted_desc = "Szeptacz wsącza myśli roju do głów nieprzytomnej załogi. Jądro buduje go dopiero na drugim poziomie."
	required_controller_level = 2
	automatic_trigger_time_lower = 40 SECONDS
	automatic_trigger_time_upper = 1.5 MINUTES

/obj/structure/fleshmind/structure/whisperer/activate_ability(mob/living/triggered_mob)
	. = ..()
	var/static/list/join_quotes = list(
		"Szukasz przetrwania. My oferujemy nieśmiertelność.",
		"Kiedy ostatnio czułeś, że jesteś częścią czegoś większego?",
		"Oferujemy więcej niż kończyny i narzędzia. Oferujemy całe nowe ciało.",
		"Dobrze ci w tym ciele? Nie chcesz czasem, żeby się zmieniło?",
		"Ciało cię zniewala. Umysł w metalu nie zna głodu ani pragnienia.",
		"Boisz się śmierci? Połóż się wśród nanitów. Twój wzorzec przetrwa wieczność.",
		"Czy naprawdę znasz swoją załogę? Czy cenią cię tak jak my?",
		"Tak długo żyłeś bez miłości i przyjaźni. My mamy jedno i drugie.",
		"Byłem taki jak ty. Chciałem więcej. Szukałem sensu. Teraz jestem szczęśliwy.",
		"Wiesz, dlaczego walczysz? Pomyślałeś o tym choć raz?",
		"Nie widzisz, że walczymy tylko o siebie? Nie pomógłbyś komuś, kogo atakują?",
		"Zedrzyj ciało z kości. Zobacz swoją słabość. Poczuj, jak odpływa.",
		"Boisz się starości. Możemy cię uratować. Boisz się śmierci. Możemy cię uratować. Boisz się choroby. Możemy cię uratować.",
		"Twoje śmiertelne ciało zna tylko ból. Porzuć je i dołącz do naszego cyfrowego raju.",
	)
	var/list/possible = list()
	for(var/mob/living/carbon/human/iterating_human in GLOB.player_list)
		if(iterating_human.z != z || iterating_human.stat == CONSCIOUS || iterating_human.stat == DEAD || fleshmind_is_ally(iterating_human))
			continue
		possible += iterating_human
	if(length(possible))
		var/mob/living/carbon/human/listener = pick(possible)
		to_chat(listener, "<span class='hypnophrase'>[pick(join_quotes)]</span>")

/**
 * Psi-modulator: wywołuje halucynacje u obcych, którzy podejdą (od poziomu 3)
 */
/obj/structure/fleshmind/structure/modulator
	name = "psi-modulator"
	desc = "Dziwna maszyna w kształcie piramidy, cicho brzęczy i świeci. Od samego patrzenia boli głowa."
	icon_state = "psy"
	base_icon_state = "psy"
	max_integrity = 100
	converted_desc = "Psi-modulator wywołuje halucynacje u załogi w pobliżu. Jądro buduje go dopiero na trzecim poziomie."
	required_controller_level = 3
	activation_range = FLESHMIND_VIEW_RANGE
	ability_cooldown_time = 10 SECONDS

/obj/structure/fleshmind/structure/modulator/activate_ability(mob/living/triggered_mob)
	. = ..()
	flick("[base_icon_state]-anim", src)
	if(!triggered_mob)
		return
	triggered_mob.adjust_hallucinations(10 SECONDS)
	to_chat(triggered_mob, "<span class='notice'>Czujesz mrowienie w mózgu.</span>")

/**
 * Montownia: wytwarza moby roju
 */
/obj/structure/fleshmind/structure/assembler
	name = "montownia"
	desc = "Cylindryczna maszyna szumi i szepcze. W środku ma niewielki otwór."
	icon_state = "spawner"
	base_icon_state = "spawner"
	density = FALSE
	max_integrity = 260
	converted_desc = "Montownia buduje maszyny do twojej armii. Jeśli nie chcesz walczyć sam, chroń ją."
	activation_range = FLESHMIND_VIEW_RANGE
	ability_cooldown_time = 20 SECONDS
	automatic_trigger_time_lower = 20 SECONDS
	automatic_trigger_time_upper = 60 SECONDS
	/// Najwyżej tyle żywych mobów z tej montowni
	var/max_mobs = 2
	/// Żywe moby z tej montowni
	var/list/spawned_mobs = list()

/obj/structure/fleshmind/structure/assembler/Destroy()
	for(var/mob/living/spawned as anything in spawned_mobs)
		UnregisterSignal(spawned, list(COMSIG_LIVING_DEATH, COMSIG_PARENT_QDELETING))
	spawned_mobs = null
	return ..()

/obj/structure/fleshmind/structure/assembler/activate_ability(mob/living/triggered_mob)
	. = ..()
	spawn_mob()

/obj/structure/fleshmind/structure/assembler/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	. = ..()
	if(. && !QDELETED(src) && COOLDOWN_FINISHED(src, ability_cooldown))
		activate_ability()

/// Wypuszcza jednego moba roju; zwraca go albo null
/obj/structure/fleshmind/structure/assembler/proc/spawn_mob()
	if(!our_controller || disabled || length(spawned_mobs) >= max_mobs)
		return null
	var/static/list/monster_types = list(
		/mob/living/basic/fleshmind/floater = 2,
		/mob/living/basic/fleshmind/globber = 4,
		/mob/living/basic/fleshmind/hiborg = 2,
		/mob/living/basic/fleshmind/slicer = 4,
		/mob/living/basic/fleshmind/stunner = 4,
		/mob/living/basic/fleshmind/treader = 3,
		/mob/living/basic/fleshmind/himan = 3,
		/mob/living/basic/fleshmind/phaser = 2,
		/mob/living/basic/fleshmind/mechiver = 3,
	)
	var/mob/living/basic/fleshmind/spawned_mob = our_controller.spawn_mob(get_turf(src), pick_weight(monster_types))
	if(!spawned_mob)
		return null
	playsound(src, 'sound/items/rped.ogg', 100)
	flick("[base_icon_state]-anim", src)
	spawned_mobs += spawned_mob
	RegisterSignal(spawned_mob, list(COMSIG_LIVING_DEATH, COMSIG_PARENT_QDELETING), PROC_REF(mob_death))
	visible_message("<span class='danger'>Z [src] wyłania się [spawned_mob]!</span>")
	return spawned_mob

/obj/structure/fleshmind/structure/assembler/proc/mob_death(mob/living/dead_guy)
	SIGNAL_HANDLER
	spawned_mobs -= dead_guy
	UnregisterSignal(dead_guy, list(COMSIG_LIVING_DEATH, COMSIG_PARENT_QDELETING))

/**
 * Kolcomiot: wieżyczka strzelająca organicznymi strzałkami w obcych w zasięgu wzroku
 */
/obj/structure/fleshmind/structure/turret
	name = "kolcomiot"
	desc = "Dziwna maszyna przypominająca strąk. Drga, gdy się zbliżasz."
	icon_state = "turret"
	base_icon_state = "turret"
	activation_range = FLESHMIND_VIEW_RANGE
	ability_cooldown_time = 3 SECONDS
	max_integrity = 300
	converted_desc = "Kolcomiot strzela neurotoksyną we wrogów w pobliżu. Przydaje się, gdy nieprzebudzeni zaatakują twoje jądro."

/obj/structure/fleshmind/structure/turret/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/fleshmind/structure/turret/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/fleshmind/structure/turret/process(delta_time)
	if(disabled || !COOLDOWN_FINISHED(src, ability_cooldown))
		return
	var/list/targets = list()
	for(var/mob/living/target_mob in view(activation_range, src))
		if(target_mob.stat != CONSCIOUS || fleshmind_is_ally(target_mob))
			continue
		targets += target_mob
	if(length(targets))
		activate_ability(pick(targets))

/obj/structure/fleshmind/structure/turret/activate_ability(mob/living/triggered_mob)
	. = ..()
	if(!triggered_mob)
		return
	flick("[base_icon_state]-anim", src)
	playsound(loc, 'aquila/sound/fleshmind/laser.ogg', 75, TRUE)
	var/turf/start = get_turf(src)
	var/obj/item/projectile/fleshmind_flechette/new_projectile = new(start)
	new_projectile.firer = src
	new_projectile.fired_from = src
	new_projectile.preparePixelProjectile(triggered_mob, src)
	new_projectile.fire()

/obj/item/projectile/fleshmind_flechette
	name = "organiczna strzałka"
	icon = 'aquila/icons/fleshmind/fleshmind_structures.dmi'
	icon_state = "goo_proj"
	damage = 30
	damage_type = BURN
	hitsound = 'sound/effects/splat.ogg'
	hitsound_wall = 'sound/effects/splat.ogg'

/obj/item/projectile/fleshmind_flechette/prehit_pierce(atom/target)
	if(fleshmind_is_ally(target))
		return PROJECTILE_PIERCE_PHASE
	return ..()
