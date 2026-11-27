// AQUILA: brakujące gruczoły porywaczy z tgstation (code/modules/antagonists/abductor/equipment/glands/access.dm, blood.dm,
// quantum.dm, transform.dm; AGPL-3.0). Gruczoł przemiany z tg to nasz /obj/item/organ/heart/gland/pop (ta sama mechanika),
// więc nie ma tu duplikatu: pop losuje tylko nasze grywalne rasy przez aquila_gland_transform_species().
// Magazyn organów bierze subtypesof(/obj/item/organ/heart/gland), więc nowe gruczoły trafiają do niego same.

/// Gruczoł dostępu: po aktywacji porwany otwiera wszystko, co wymaga dostępu okrętu (tg: simple_access z REGION_ALL_GLOBAL).
/// U nas nie ma komponentu simple_access, więc gruczoł sam odpowiada na COMSIG_MOB_ALLOWED, jak implant dostępu.
/obj/item/organ/heart/gland/access
	true_name = "anagraficzny elektroszyfrator"
	cooldown_low = 600
	cooldown_high = 1200
	uses = 1
	icon_state = "mindshock"
	mind_control_uses = 3
	mind_control_duration = 900
	/// Czy gruczoł już się aktywował i nasłuchuje sprawdzeń dostępu właściciela
	var/access_granted = FALSE

/obj/item/organ/heart/gland/access/activate()
	to_chat(owner, span_notice("Z jakiegoś powodu czujesz się jak VIP."))
	access_granted = TRUE
	RegisterSignal(owner, COMSIG_MOB_ALLOWED, PROC_REF(check_access_for), override = TRUE)

/obj/item/organ/heart/gland/access/Remove(mob/living/carbon/M, special = 0)
	if(owner && access_granted)
		UnregisterSignal(owner, COMSIG_MOB_ALLOWED)
	access_granted = FALSE
	return ..()

/obj/item/organ/heart/gland/access/proc/check_access_for(mob/living/source, obj/locked)
	SIGNAL_HANDLER
	var/static/list/all_access
	if(!all_access)
		all_access = get_all_accesses()
	return locked.check_access_list(all_access)

/// Gruczoł krwi: co jakiś czas krew porwanego staje się losowym odczynnikiem. tg zmienia typ krwi (nowy system typów krwi),
/// u nas krew rasy to exotic_blood w danych gatunku właściciela (tak krwawią np. ślimakoludzie), więc podmieniamy właśnie ją.
/obj/item/organ/heart/gland/blood
	true_name = "pseudojądrowy destabilizator krwi"
	cooldown_low = 1200
	cooldown_high = 1800
	uses = -1
	icon_state = "egg"
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	mind_control_uses = 3
	mind_control_duration = 1500
	/// Odczynnik, który gruczoł ostatnio ustawił jako krew; po wyjęciu gruczołu wraca krew rasy
	var/datum/reagent/blood_reagent

/obj/item/organ/heart/gland/blood/activate()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/owner_mob = owner
	var/datum/species/species = owner_mob.dna?.species
	if(!species || (NOBLOOD in species.species_traits))
		return
	to_chat(owner_mob, span_warning("Przez chwilę czujesz, jak krew ci się rozgrzewa."))
	blood_reagent = get_random_reagent_id(CHEMICAL_RNG_GENERAL)
	species.exotic_blood = blood_reagent

/obj/item/organ/heart/gland/blood/Remove(mob/living/carbon/M, special = 0)
	if(ishuman(owner) && blood_reagent)
		var/mob/living/carbon/human/owner_mob = owner
		var/datum/species/species = owner_mob.dna?.species
		// po zmianie rasy gatunek ma już własną krew, więc przywracamy tylko tę, którą sami podmieniliśmy
		if(species && species.exotic_blood == blood_reagent)
			species.exotic_blood = initial(species.exotic_blood)
	blood_reagent = null
	return ..()

/// Gruczoł kwantowy: wiąże się z kimś, kogo porwany widzi, i po 1–4 minutach zamienia ich miejscami.
/obj/item/organ/heart/gland/quantum
	true_name = "kwantowa matryca deobserwacji"
	cooldown_low = 150
	cooldown_high = 150
	uses = -1
	icon_state = "emp"
	mind_control_uses = 2
	mind_control_duration = 1200
	/// Splątana osoba, z którą porwany zamieni się miejscami
	var/mob/living/carbon/entangled_mob

/obj/item/organ/heart/gland/quantum/Destroy()
	clear_entangled()
	return ..()

/obj/item/organ/heart/gland/quantum/activate()
	if(entangled_mob)
		return
	for(var/mob/living/carbon/target in oview(owner, 7))
		entangled_mob = target
		RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(clear_entangled))
		addtimer(CALLBACK(src, PROC_REF(quantum_swap)), rand(1 MINUTES, 4 MINUTES))
		return

/obj/item/organ/heart/gland/quantum/proc/clear_entangled()
	SIGNAL_HANDLER
	if(entangled_mob)
		UnregisterSignal(entangled_mob, COMSIG_PARENT_QDELETING)
	entangled_mob = null

/obj/item/organ/heart/gland/quantum/proc/quantum_swap()
	if(QDELETED(entangled_mob))
		clear_entangled()
		return
	if(!owner)
		return
	var/turf/owner_turf = get_turf(owner)
	do_teleport(owner, get_turf(entangled_mob), null, channel = TELEPORT_CHANNEL_QUANTUM)
	do_teleport(entangled_mob, owner_turf, null, channel = TELEPORT_CHANNEL_QUANTUM)
	to_chat(owner, span_warning("Nagle jesteś zupełnie gdzie indziej!"))
	to_chat(entangled_mob, span_warning("Nagle jesteś zupełnie gdzie indziej!"))
	if(!active_mind_control) // splątanie trwa, póki działa rozkaz, żeby trafiał też do drugiej osoby
		clear_entangled()

/obj/item/organ/heart/gland/quantum/mind_control(command, mob/living/user)
	var/was_active = active_mind_control
	..()
	if(was_active || !active_mind_control)
		return
	if(!ishuman(entangled_mob) || entangled_mob.stat == DEAD)
		return
	to_chat(entangled_mob, "<span class='userdanger'>Nagle czujesz nieodpartą potrzebę wykonania rozkazu...</span>")
	to_chat(entangled_mob, "<span class='mind_control'>[command]</span>")
	var/atom/movable/screen/alert/mind_control/mind_alert = entangled_mob.throw_alert("mind_control", /atom/movable/screen/alert/mind_control)
	mind_alert.command = command
	log_admin("[key_name(user)] mirrored an abductor mind control message to [key_name(entangled_mob)]: [command]")

/obj/item/organ/heart/gland/quantum/clear_mind_control()
	if(active_mind_control && entangled_mob)
		to_chat(entangled_mob, "<span class='userdanger'>Czujesz, że przymus słabnie, a ty <i>całkowicie zapominasz</i> o wcześniejszych rozkazach.</span>")
		entangled_mob.clear_alert("mind_control")
	return ..()

/// Gatunek dla gruczołu przemiany (/obj/item/organ/heart/gland/pop): tylko nasze rasy grywalne od startu rundy,
/// najlepiej inna niż obecna, żeby przemiana była widoczna
/proc/aquila_gland_transform_species(mob/living/carbon/human/target)
	var/list/candidates = list()
	for(var/species_id in GLOB.roundstart_races)
		var/species_type = GLOB.species_list[species_id]
		if(species_type)
			candidates |= species_type
	if(length(candidates) > 1 && target?.dna?.species)
		candidates -= target.dna.species.type
	if(!length(candidates))
		return /datum/species/human
	return pick(candidates)

/// Zmienia rasę właściciela gruczołu tak, żeby gruczoł nie zginął: set_species() wymienia serce na serce nowej rasy
/// (regenerate_organs z replace_current), więc wcześniej gruczoł przemiany kasował się przy pierwszej aktywacji
/proc/aquila_gland_set_species(obj/item/organ/heart/gland/gland, species)
	var/mob/living/carbon/human/target = gland.owner
	if(!ishuman(target))
		return
	gland.Remove(target, TRUE)
	target.set_species(species)
	if(!QDELETED(gland) && !QDELETED(target))
		gland.Insert(target, TRUE, FALSE)
