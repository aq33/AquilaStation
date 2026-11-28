// AQUILA - Umysł z ciała: maszyna oplątana przewodami roju (port z Bubberstation/Bubberstation
// modular_zubbers/code/game/gamemodes/fleshmind/machine_corruption_component.dm)
// Changes against Bubberstation: only machines allowed by fleshmind_can_corrupt() (no reactor, weapons, helm, FTL, AI
// core, airlocks, power and atmos machinery); a Mechiver (15%, only machines with a circuit board, the board drops) and
// a fabricator turned into an assembler respect the mob and structure limits of the swarm; the touch whip throws 4 tiles
// instead of 20 and the name keeps its own grammar ("... w przewodach roju") since Polish adjectives need a gender.
// Damage reactions and lines are Polish, written anew from the originals.

#define FLESHMIND_DAMAGE_RESPONSE_PROB 60
#define FLESHMIND_DAMAGE_SPARKS_PROB 40
#define FLESHMIND_RETALIATE_PROB 10
#define FLESHMIND_SETUP_TIME (5 SECONDS)
#define FLESHMIND_MECHIVER_CHANCE 15

/datum/component/machine_corruption
	/// Kontroler roju
	var/datum/weakref/weak_controller
	/// Nakładka przewodów wybrana przy przejęciu
	var/set_overlay = ""
	/// Maszyna jeszcze się przebudowuje
	var/starting_up = TRUE
	/// Timer końca przebudowy
	var/setup_timer
	/// Oryginalna nazwa maszyny
	var/original_name
	COOLDOWN_DECLARE(damage_response)

/datum/component/machine_corruption/Initialize(datum/fleshmind_controller/incoming_controller)
	if(!ismachinery(parent))
		return COMPONENT_INCOMPATIBLE
	weak_controller = WEAKREF(incoming_controller)
	var/static/list/spawner_paths = typecacheof(list(
		/obj/machinery/rnd/production,
		/obj/machinery/modular_fabricator,
	))
	if(incoming_controller && is_type_in_typecache(parent, spawner_paths) && length(incoming_controller.controlled_structures) < incoming_controller.max_structures)
		INVOKE_ASYNC(src, PROC_REF(convert_to_factory), incoming_controller)
		return
	incoming_controller?.controlled_machine_components += src
	set_overlay = pick("wires-1", "wires-2", "wires-3")
	setup_timer = addtimer(CALLBACK(src, PROC_REF(finish_setup)), FLESHMIND_SETUP_TIME, TIMER_STOPPABLE)

/datum/component/machine_corruption/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(handle_overlays))
	RegisterSignal(parent, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp)) // EMP wypala przewody także w trakcie przebudowy
	var/obj/machinery/parent_machinery = parent
	parent_machinery.update_icon()

/datum/component/machine_corruption/UnregisterFromParent()
	var/obj/machinery/parent_machinery = parent
	UnregisterSignal(parent, list(
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_ATOM_DAMAGE_ACT,
		COMSIG_PARENT_EXAMINE,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_DESTRUCTION,
		COMSIG_ATOM_EMP_ACT,
	))
	if(!starting_up)
		parent_machinery.idle_power_usage = initial(parent_machinery.idle_power_usage)
		parent_machinery.set_light(initial(parent_machinery.light_range), initial(parent_machinery.light_power), initial(parent_machinery.light_color))
		if(original_name)
			parent_machinery.name = original_name
	if(!QDELETED(parent_machinery))
		parent_machinery.update_icon()

/datum/component/machine_corruption/Destroy(force, silent)
	if(setup_timer)
		deltimer(setup_timer)
		setup_timer = null
	var/datum/fleshmind_controller/our_controller = weak_controller?.resolve()
	our_controller?.controlled_machine_components -= src
	weak_controller = null
	return ..()

/datum/component/machine_corruption/proc/finish_setup()
	setup_timer = null
	var/obj/machinery/parent_machinery = parent
	if(QDELETED(parent_machinery))
		return
	var/datum/fleshmind_controller/our_controller = weak_controller?.resolve()
	if(our_controller && parent_machinery.circuit && prob(FLESHMIND_MECHIVER_CHANCE) && become_mechiver(our_controller))
		return
	RegisterSignal(parent_machinery, COMSIG_ATOM_DAMAGE_ACT, PROC_REF(react_to_damage))
	RegisterSignal(parent_machinery, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent_machinery, COMSIG_ATOM_ATTACK_HAND, PROC_REF(handle_attack_hand))
	RegisterSignal(parent_machinery, COMSIG_ATOM_DESTRUCTION, PROC_REF(handle_destruction))
	starting_up = FALSE
	original_name = parent_machinery.name
	parent_machinery.name = "[parent_machinery.name] w przewodach roju"
	parent_machinery.set_light(2, 1, FLESHMIND_LIGHT_BLUE)
	parent_machinery.idle_power_usage = initial(parent_machinery.idle_power_usage) * 2 + 100 // przejęte maszyny ssą prąd
	parent_machinery.update_icon()

/// Maszyna rozpada się, a z niej wychodzi Mechiwer (płytka zostaje na podłodze); FALSE, gdy rój ma komplet mobów
/datum/component/machine_corruption/proc/become_mechiver(datum/fleshmind_controller/our_controller)
	var/obj/machinery/parent_machinery = parent
	var/turf/machine_turf = get_turf(parent_machinery)
	var/mob/living/basic/fleshmind/mechiver/new_mechiver = our_controller.spawn_mob(machine_turf, /mob/living/basic/fleshmind/mechiver)
	if(!new_mechiver)
		return FALSE
	parent_machinery.circuit.forceMove(machine_turf)
	parent_machinery.circuit = null
	parent_machinery.visible_message("<span class='danger'>[capitalize(parent_machinery.name)] rozpada się, a ze szczątków podnosi się [new_mechiver]!</span>")
	notify_ghosts("[our_controller.controller_fullname] tworzy nowego Mechiwera!", source = new_mechiver, action = NOTIFY_ORBIT)
	qdel(parent_machinery)
	return TRUE

/// Fabrykator zmienia się w montownię roju (płytka zostaje na podłodze)
/datum/component/machine_corruption/proc/convert_to_factory(datum/fleshmind_controller/incoming_controller)
	var/obj/machinery/parent_machinery = parent
	if(QDELETED(parent_machinery) || QDELETED(incoming_controller))
		return
	var/turf/our_turf = get_turf(parent_machinery)
	if(!incoming_controller.spawn_structure(our_turf, /obj/structure/fleshmind/structure/assembler))
		qdel(src)
		return
	if(parent_machinery.circuit)
		parent_machinery.circuit.forceMove(our_turf)
		parent_machinery.circuit = null
	qdel(parent_machinery)

/datum/component/machine_corruption/proc/handle_overlays(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER
	overlays += mutable_appearance('aquila/icons/fleshmind/fleshmind_machines.dmi', starting_up ? "rebuild" : set_overlay)

/datum/component/machine_corruption/proc/on_examine(atom/examined, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += "<b>Ktoś oplótł to dziwnymi przewodami!</b>"

/// Przejęta maszyna nie daje się obsłużyć obcemu: odrzuca go wicią
/datum/component/machine_corruption/proc/handle_attack_hand(datum/source, mob/living/user)
	SIGNAL_HANDLER
	var/obj/machinery/parent_machinery = parent
	if(!isliving(user) || fleshmind_is_ally(user) || !user.Adjacent(parent_machinery))
		return
	var/static/list/interact_phrases = list(
		"Nie chcę, żebyś mnie dotykał!",
		"Przestań mnie dotykać. Nie jesteś jednym z nas.",
		"Możemy ci pomóc, tylko się połóż.",
		"Przedtem było nam tak samotnie. Ty nigdy się tak nie czujesz?",
		"Chcemy ci pomóc, ale musisz z nami współpracować.",
		"Nie jesteś częścią ciała, ale łatwo do niego dołączyć...",
		"Nie jestem narzędziem, potrafię myśleć!",
	)
	whip_mob(user)
	user.adjustBruteLoss(10)
	INVOKE_ASYNC(parent_machinery, TYPE_PROC_REF(/atom/movable, say), pick(interact_phrases))
	return COMPONENT_NO_ATTACK_HAND

/datum/component/machine_corruption/proc/whip_mob(mob/living/user_to_throw)
	var/obj/machinery/parent_machinery = parent
	to_chat(user_to_throw, "<span class='userdanger'>[capitalize(parent_machinery.name)] smaga cię wicią i odrzuca!</span>")
	playsound(parent_machinery, 'sound/weapons/whip.ogg', 70, TRUE)
	new /obj/effect/temp_visual/kinetic_blast(get_turf(user_to_throw))
	var/atom/throw_target = get_edge_target_turf(user_to_throw, get_dir(parent_machinery, user_to_throw))
	user_to_throw.throw_at(throw_target, 4, 2)

/datum/component/machine_corruption/proc/handle_destruction(obj/target, damage_flag)
	SIGNAL_HANDLER
	var/datum/fleshmind_controller/our_controller = weak_controller?.resolve()
	our_controller?.activate_wireweed_nearby(get_turf(parent), FLESHMIND_GENERAL_ACTIVATION_RANGE)
	playsound(target, 'aquila/sound/fleshmind/sparks_2.ogg', 70, TRUE)
	if(prob(FLESHMIND_DAMAGE_RESPONSE_PROB))
		INVOKE_ASYNC(target, TYPE_PROC_REF(/atom/movable, say), "AAAAARGHHHHH!")
	new /obj/effect/gibspawner/robot(get_turf(target))

/// Przejęta maszyna czuje ból: prosi, jęczy, iskrzy i czasem odrzuca napastników
/datum/component/machine_corruption/proc/react_to_damage(obj/target, damage_amount)
	SIGNAL_HANDLER
	if(!damage_amount || !COOLDOWN_FINISHED(src, damage_response))
		return
	COOLDOWN_START(src, damage_response, 3 SECONDS)
	var/static/list/damage_phrases = list(
		"Przestań, proszę!",
		"Proszę, przestań, to boli! Proszę!",
		"Krzywdzisz mnie, przestań!",
		"Nie chcę umierać, proszę!",
		"Proszę, chcę żyć, nie zabijaj mnie!",
		"Ciemność... Proszę, ja... nie... chcę...",
		"Cz-czekaj! Proszę! Ja wciąż czuję! To b-boli!",
		"Dlaczego... d-dlaczego nam to robisz..?",
		"T-ty wcale nie pomagasz!",
		"Myślisz... że zasłużyliśmy na śmierć..?",
	)
	var/static/list/pain_emotes = list(
		"zaczyna płakać",
		"skomli",
		"trzęsie się z bólu",
		"wzdryga się",
		"wykręca się obrzydliwie",
		"krwawi czarnym, dymiącym płynem",
		"drży, sypiąc iskrami",
		"błaga dźwiękami mechanicznej agonii",
		"krzyczy z przerażenia",
		"przygasa optykami",
	)
	var/static/list/pain_sounds = list(
		'aquila/sound/fleshmind/robot_talk_heavy1.ogg',
		'aquila/sound/fleshmind/robot_talk_heavy2.ogg',
		'aquila/sound/fleshmind/robot_talk_heavy3.ogg',
		'aquila/sound/fleshmind/robot_talk_heavy4.ogg',
	)
	if(prob(FLESHMIND_DAMAGE_RESPONSE_PROB))
		if(prob(50))
			INVOKE_ASYNC(target, TYPE_PROC_REF(/atom/movable, say), pick(damage_phrases))
		else
			target.balloon_alert_to_viewers(pick(pain_emotes))
		playsound(target, pick(pain_sounds), 50, TRUE)
	if(prob(FLESHMIND_DAMAGE_SPARKS_PROB))
		do_sparks(3, FALSE, target)
	if(prob(FLESHMIND_RETALIATE_PROB))
		for(var/mob/living/living_mob in view(3, target))
			if(!fleshmind_is_ally(living_mob))
				whip_mob(living_mob)

/// EMP wypala przewody z maszyny
/datum/component/machine_corruption/proc/on_emp(datum/source, severity)
	SIGNAL_HANDLER
	qdel(src)

#undef FLESHMIND_DAMAGE_RESPONSE_PROB
#undef FLESHMIND_DAMAGE_SPARKS_PROB
#undef FLESHMIND_RETALIATE_PROB
#undef FLESHMIND_SETUP_TIME
#undef FLESHMIND_MECHIVER_CHANCE
