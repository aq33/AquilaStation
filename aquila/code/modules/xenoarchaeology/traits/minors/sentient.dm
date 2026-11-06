/*
	Sentient
	Allows ghosts to control the artifact
*/
/datum/xenoartifact_trait/minor/sentient
	label_name = "Sentient"
	label_desc = "Sentient: konstrukcja artefaktu zdaje się zawierać świadome elementy. Przez nie artefakt ma własny umysł."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 30
	incompatabilities = TRAIT_INCOMPATIBLE_MOB
	can_pearl = FALSE
	///Mob who lives inside the artifact, and who we give actions to
	var/mob/living/simple_animal/shade/sentience/sentience
	///Mob spawner for ghosts
	var/obj/effect/mob_spawn/sentient_artifact/mob_spawner
	///Ref to our landmark
	var/obj/effect/landmark/landmark

/datum/xenoartifact_trait/minor/sentient/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	//Register a signal to KILL!
	RegisterSignal(component_parent, COMSIG_XENOA_CALCIFIED, PROC_REF(suicide))
	//Setup ghost canidates and mob spawners
	if(SSticker.HasRoundStarted())
		INVOKE_ASYNC(src, PROC_REF(get_canidate))
	else
		mob_spawner = new(component_parent.parent, src)
	//Landmarking
	landmark = new(component_parent?.parent)

/datum/xenoartifact_trait/minor/sentient/Destroy(force)
	QDEL_NULL(sentience)
	QDEL_NULL(mob_spawner)
	QDEL_NULL(landmark)
	return ..()

/datum/xenoartifact_trait/minor/sentient/proc/handle_ghost(datum/source, mob/M, list/examine_text)
	if(isobserver(M) && !sentience?.key && (alert(M, "Czy na pewno chcesz przejąć kontrolę nad: [sentience]?", "Przejmij kontrolę: [sentience]", "Tak", "Nie") == "Tak"))
		sentience.key = M.ckey

/datum/xenoartifact_trait/minor/sentient/proc/get_canidate()
	var/datum/poll_config/config = new(
		question = "Czy chcesz zagrać jako złowroga siła zamknięta w artefakcie [component_parent?.parent]?",
		check_jobban = ROLE_SENTIENT_XENOARTIFACT,
		poll_time = 10 SECONDS,
		jump_target = component_parent?.parent,
		role_name_text = "[component_parent?.parent]",
		alert_pic = component_parent?.parent,
		amount_to_pick = 1,
	)
	var/mob/dead/observer/candidate = SSpolling.poll_ghosts_for_target(config, checked_target = component_parent?.parent)
	if(candidate && component_parent?.parent)
		if(istype(candidate) && candidate.ckey)
			setup_sentience(candidate.ckey)
			return
	mob_spawner = new(component_parent?.parent, src)

/datum/xenoartifact_trait/minor/sentient/proc/setup_sentience(ckey)
	var/atom/atom_parent = component_parent?.parent
	if(!atom_parent?.loc)
		QDEL_NULL(mob_spawner)
		mob_spawner = new(component_parent?.parent, src)
	if(!component_parent?.parent || !ckey || !atom_parent?.loc)
		return
	//Sentience
	sentience = new(component_parent?.parent)
	sentience.name = pick(SSxenoarchaeology.xenoa_artifact_names)
	sentience.real_name = "[sentience.name] - [component_parent?.parent]"
	sentience.key = ckey
	sentience.status_flags |= GODMODE
	ADD_TRAIT(sentience, TRAIT_ARTIFACT_IGNORE, TRAIT_GENERIC)
	//Stop them from wriggling away
	var/atom/movable/movable = component_parent.parent
	movable.buckle_mob(movable, TRUE)
	//Action
	var/obj/effect/proc_holder/spell/pointed/artifact_senitent_action/P = new(null, component_parent)
	sentience.AddSpell(P)
	//Display traits to sentience
	to_chat(sentience, span_notice("Twoje cechy: \n"))
	var/trait_dialogue = ""
	for(var/index in component_parent.traits_catagories)
		for(var/datum/xenoartifact_trait/T as anything in component_parent.traits_catagories[index])
			to_chat(sentience, span_notice("[T.label_name]\n"))
			var/trait_name = T.label_name
			trait_name = replacetext(trait_name, "Δ", "delta")
			trait_name = replacetext(trait_name, "Σ", "sigma")
			trait_name = replacetext(trait_name, "Ω", "omega")
			trait_dialogue = "[trait_dialogue]\n[trait_name]"
	sentience.add_memory(trait_dialogue)
	playsound(get_turf(component_parent?.parent), 'sound/items/haunted/ghostitemattack.ogg', 50, TRUE)
	//Cleanup
	QDEL_NULL(mob_spawner)

//Throw calcification logic here
/datum/xenoartifact_trait/minor/sentient/proc/suicide(datum/source)
	SIGNAL_HANDLER

	QDEL_NULL(sentience)
	QDEL_NULL(mob_spawner)

//Spawner for sentience
/obj/effect/mob_spawn/sentient_artifact
	death = FALSE
	name = "Świadomy ksenoartefakt"
	mob_name = "świadomy ksenoartefakt"
	short_desc = "Jesteś złowrogą świadomością, która opętała starożytny obcy artefakt."
	flavour_text = "Wróć do swego pana..."
	use_cooldown = TRUE
	ghost_usable = TRUE
	instant = FALSE
	roundstart = FALSE
	banType = ROLE_SENTIENT_XENOARTIFACT
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = 101
	///Ref to the trait we're handling
	var/datum/xenoartifact_trait/minor/sentient/trait

/obj/effect/mob_spawn/sentient_artifact/Initialize(mapload, datum/xenoartifact_trait/minor/sentient/new_trait)
	trait = new_trait
	return ..()

/obj/effect/mob_spawn/sentient_artifact/create(ckey)
	trait?.setup_sentience(ckey)

//Action for sentience
/obj/effect/proc_holder/spell/pointed/artifact_senitent_action
	name = "Aktywuj artefakt"
	desc = "Wybierz cel, na którym aktywujesz swój artefakt."
	range = 1
	selection_type = "range"
	charge_max = 0
	clothes_req = FALSE
	antimagic_allowed = TRUE
	action_icon = 'icons/mob/actions/actions_revenant.dmi'
	action_icon_state = "r_transmit"
	action_background_icon_state = "bg_ecult"
	///Ref to the artifact we're handling
	var/datum/component/xenoartifact/sentient_artifact

/obj/effect/proc_holder/spell/pointed/artifact_senitent_action/Initialize(mapload, datum/component/xenoartifact/artifact)
	. = ..()
	sentient_artifact = artifact
	range = sentient_artifact?.target_range || range

//aquila: pointed spell sam nie sprawdza zasięgu
/obj/effect/proc_holder/spell/pointed/artifact_senitent_action/intercept_check(mob/user, atom/target)
	var/datum/component/xenoartifact/artifact = sentient_artifact
	if(!artifact?.parent || get_dist(get_turf(artifact.parent), get_turf(target)) > range)
		to_chat(user, "<span class='warning'>Cel jest poza zasięgiem artefaktu!</span>")
		return FALSE
	return TRUE

//aquila: bazowe update_icon ustawia stany projectile0/1, których nie ma w ikonie revenanta
/obj/effect/proc_holder/spell/pointed/artifact_senitent_action/update_icon()
	return

/obj/effect/proc_holder/spell/pointed/artifact_senitent_action/cast(list/targets, mob/user)
	. = ..()
	var/atom/target = targets[1]
	if(!sentient_artifact || sentient_artifact.use_cooldown_timer)
		if(sentient_artifact?.use_cooldown_timer)
			to_chat(user, "<span class='warning'>Artefakt wciąż się regeneruje, poczekaj jeszcze [timeleft(sentient_artifact.use_cooldown_timer)/10] s!</span>")
		return
	sentient_artifact.register_target(target)
	sentient_artifact.trigger()

/mob/living/simple_animal/shade/sentience
	desc = "Chwila, co do kurwy?"
