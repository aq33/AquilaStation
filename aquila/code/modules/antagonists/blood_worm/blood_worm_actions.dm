// AQUILA - zdolności krwawego robaka (port z tgstation#93787)
// W tg to /datum/action/cooldown/mob_cooldown, tu nasz /datum/action/cooldown/spell.
// target akcji to zawsze robak, owner to ten, kto ma przycisk (robak albo przejęty nosiciel).

/datum/action/cooldown/spell/blood_worm
	name = "Zdolność krwawego robaka"
	button_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_demon"
	icon_icon = 'aquila/icons/mob/actions/actions_blood_worm.dmi'
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = NONE
	antimagic_flags = NONE
	ranged_mousepointer = 'aquila/icons/effects/mouse_pointers/visor_reticule.dmi'

/datum/action/cooldown/spell/blood_worm/proc/get_worm()
	RETURN_TYPE(/mob/living/simple_animal/hostile/blood_worm)
	return target

/**
 * Czekanie jak do_after, ale bez przerywania przy ruchu robaka i celu (robak ciągnie ofiarę, nosiciela przenoszą).
 * Przerywa je śmierć, utrata przytomności i extra_checks.
 */
/proc/blood_worm_do_after(mob/living/user, delay, atom/progress_target, datum/callback/extra_checks)
	if(!user)
		return FALSE
	var/datum/progressbar/progbar = new(user, delay, progress_target || user)
	var/starttime = world.time
	var/endtime = world.time + delay
	. = TRUE
	while(world.time < endtime)
		stoplag(1)
		progbar.update(world.time - starttime)
		if(QDELETED(user) || user.stat != CONSCIOUS || (extra_checks && !extra_checks.Invoke()))
			. = FALSE
			break
	qdel(progbar)

// Wysysanie krwi

/datum/action/cooldown/spell/blood_worm/leech
	name = "Wysysanie krwi"
	desc = "Złap cel zębami i wysysaj jego krew. Działa też na pojemniki z krwią, np. worki. Każda inna czynność przerywa wysysanie."
	button_icon_state = "leech_blood"
	cooldown_time = 5 SECONDS
	click_to_activate = TRUE
	unset_after_click = FALSE
	click_cd_override = 0

	var/leech_rate = 0
	var/oxyloss_rate = 0
	var/leech_grab_delay = 1 SECONDS
	/// Czy właśnie wysysamy
	var/leeching = FALSE

	/// Odczynniki, które można wysysać z pojemników
	var/static/list/compatible_container_reagent_types = list(
		/datum/reagent/blood = TRUE,
		/datum/reagent/consumable/liquidelectricity = TRUE,
	)

/datum/action/cooldown/spell/blood_worm/leech/can_cast_spell(feedback = TRUE)
	if(!isbloodworm(owner) || leeching)
		return FALSE
	return ..()

/datum/action/cooldown/spell/blood_worm/leech/set_click_ability(mob/on_who)
	. = ..()
	to_chat(on_who, "<span class='notice'>Szykujesz zęby. <b>Kliknij lewym ofiarę albo pojemnik z krwią obok siebie!</b></span>")

/datum/action/cooldown/spell/blood_worm/leech/InterceptClickOn(mob/living/clicker, params, atom/click_target)
	var/list/modifiers = params2list(params)
	// Nie blokujemy oglądania, ciągnięcia itp.
	if(modifiers?[SHIFT_CLICK] || modifiers?[ALT_CLICK] || modifiers?[CTRL_CLICK])
		return FALSE
	if(!IsAvailable(TRUE))
		return FALSE
	owner.face_atom(click_target)
	if(!ismovable(click_target))
		return FALSE
	if(!owner.Adjacent(click_target))
		click_target.balloon_alert(owner, "za daleko!")
		return TRUE
	unset_click_ability(owner, refund_cooldown = FALSE)
	if(isliving(click_target))
		INVOKE_ASYNC(src, PROC_REF(leech_living), owner, click_target)
	else if(istype(click_target, /obj/item/reagent_containers) || istype(click_target, /obj/machinery/iv_drip))
		INVOKE_ASYNC(src, PROC_REF(leech_container), owner, click_target)
	else
		click_target.balloon_alert(owner, "z tego nie wyssiesz!")
	return TRUE

/datum/action/cooldown/spell/blood_worm/leech/proc/leech_living(mob/living/simple_animal/hostile/blood_worm/leech, mob/living/victim)
	if(!leech_living_start_check(leech, victim))
		return
	leeching = TRUE
	leech.visible_message("<span class='danger'>[leech] próbuje wgryźć się w [victim]!</span>", \
		"<span class='danger'>Próbujesz wgryźć się w [victim]!</span>", ignored_mobs = list(victim))
	to_chat(victim, "<span class='userdanger'>[leech] próbuje się w ciebie wgryźć!</span>")
	leech.changeNext_move(CLICK_CD_CLICK_ABILITY)

	if(!do_after(leech, leech_grab_delay, FALSE, victim, TRUE, CALLBACK(src, PROC_REF(leech_living_start_check), leech, victim)))
		leeching = FALSE
		return

	if(leech.pulling != victim)
		leech.start_pulling(victim, GRAB_AGGRESSIVE, supress_message = TRUE)
	if(leech.pulling != victim)
		victim.balloon_alert(leech, "nie da się złapać!")
		leeching = FALSE
		return
	if(leech.grab_state < GRAB_AGGRESSIVE)
		leech.setGrabState(GRAB_AGGRESSIVE)
	victim.Knockdown(2 SECONDS)

	leech.visible_message("<span class='danger'>[leech] wgryza się w [victim]!</span>", \
		"<span class='danger'>Wgryzasz się w [victim]!</span>", \
		"<span class='italics'>Słyszysz ugryzienie i obrzydliwe chrupnięcie!</span>", ignored_mobs = list(victim))
	to_chat(victim, "<span class='userdanger'>[leech] wgryza się w ciebie!</span>")
	playsound(victim, 'sound/weapons/bite.ogg', 80, TRUE)
	playsound(victim, 'aquila/sound/blood_worm/pierce3.ogg', 100, TRUE)
	log_combat(leech, victim, "started leeching blood from")

	var/synth_content = victim.get_blood_synth_content()
	if(synth_content >= 1)
		victim.balloon_alert(leech, "całkiem syntetyczna")
	else if(synth_content > 0)
		victim.balloon_alert(leech, "[CEILING(synth_content * 100, 1)]% syntetyczna")

	// Każde kliknięcie ustawia next_move i przerywa wysysanie
	leech.next_move = 0
	while(blood_worm_do_after(leech, 1 SECONDS, victim, CALLBACK(src, PROC_REF(leech_living_active_check), leech, victim)))
		var/taken = min(leech_rate, victim.blood_volume)
		victim.blood_volume -= taken
		leech.consume_blood(taken, victim.get_blood_synth_content())
		if(victim.stat != DEAD)
			victim.adjustOxyLoss(oxyloss_rate)
			victim.Knockdown(2 SECONDS)
		playsound(victim, 'aquila/sound/blood_worm/splatter.ogg', 80, TRUE)

	if(leech.pulling == victim && leech.grab_state >= GRAB_AGGRESSIVE)
		leech.setGrabState(GRAB_PASSIVE)
	leeching = FALSE
	StartCooldown()

/datum/action/cooldown/spell/blood_worm/leech/proc/leech_living_start_check(mob/living/simple_animal/hostile/blood_worm/leech, mob/living/victim)
	if(victim.blood_volume <= 0 || !victim.get_blood_id())
		victim.balloon_alert(leech, "brak krwi!")
		return FALSE
	if(HAS_TRAIT(victim, TRAIT_BLOOD_WORM_HOST))
		victim.balloon_alert(leech, "zajęty przez pobratymca!")
		return FALSE
	return TRUE

/datum/action/cooldown/spell/blood_worm/leech/proc/leech_living_active_check(mob/living/simple_animal/hostile/blood_worm/leech, mob/living/victim)
	if(QDELETED(victim) || victim.blood_volume <= 0)
		victim?.balloon_alert(leech, "nie ma już krwi!")
		return FALSE
	if(HAS_TRAIT(victim, TRAIT_BLOOD_WORM_HOST))
		victim.balloon_alert(leech, "zajęty przez pobratymca!")
		return FALSE
	if(!leech.Adjacent(victim) || leech.pulling != victim || leech.grab_state < GRAB_AGGRESSIVE)
		victim.balloon_alert(leech, "chwyt puścił!")
		return FALSE
	if(world.time < leech.next_move)
		return FALSE
	return TRUE

/datum/action/cooldown/spell/blood_worm/leech/proc/leech_container(mob/living/simple_animal/hostile/blood_worm/leech, obj/container)
	if(!leech_container_start_check(leech, container, feedback = TRUE))
		return
	leeching = TRUE
	leech.visible_message("<span class='danger'>[leech] próbuje wgryźć się w [container]!</span>", \
		"<span class='danger'>Próbujesz wgryźć się w [container]!</span>")
	leech.changeNext_move(CLICK_CD_CLICK_ABILITY)
	if(!do_after(leech, leech_grab_delay, FALSE, container, TRUE, CALLBACK(src, PROC_REF(leech_container_start_check), leech, container)))
		leeching = FALSE
		return
	leech.visible_message("<span class='danger'>[leech] wgryza się w [container]!</span>", \
		"<span class='danger'>Wgryzasz się w [container]!</span>", "<span class='italics'>Słyszysz ugryzienie!</span>")
	playsound(container, 'sound/weapons/bite.ogg', 80, TRUE)

	var/list/blood = get_blood_in_container(container)
	var/total_volume = 0
	var/synth_volume = 0
	for(var/datum/reagent/reagent as anything in blood)
		total_volume += reagent.volume
		synth_volume += (reagent.data?[BLOOD_DATA_SYNTH_CONTENT] || 0) * reagent.volume
	if(total_volume)
		var/synth_content = synth_volume / total_volume
		if(synth_content >= 1)
			container.balloon_alert(leech, "całkiem syntetyczna")
		else if(synth_content > 0)
			container.balloon_alert(leech, "[CEILING(synth_content * 100, 1)]% syntetyczna")

	leech.next_move = 0
	while(blood_worm_do_after(leech, 1 SECONDS, container, CALLBACK(src, PROC_REF(leech_container_active_check), leech, container)))
		var/datum/reagents/holder = get_container_holder(container)
		if(!holder)
			break
		blood = get_blood_in_container(container)
		total_volume = 0
		for(var/datum/reagent/reagent as anything in blood)
			total_volume += reagent.volume
		for(var/datum/reagent/reagent as anything in blood)
			var/reagent_synth = reagent.data?[BLOOD_DATA_SYNTH_CONTENT] || 0
			// Krew zwierząt w workach (np. z małp) zawsze jest syntetyczna
			if(reagent.type != /datum/reagent/blood)
				reagent_synth = 1
			var/amount = min(reagent.volume, leech_rate * (reagent.volume / total_volume))
			holder.remove_reagent(reagent.type, amount)
			leech.consume_blood(amount, reagent_synth)
		playsound(container, 'aquila/sound/blood_worm/splatter.ogg', 80, TRUE)

	leeching = FALSE
	StartCooldown()

/datum/action/cooldown/spell/blood_worm/leech/proc/leech_container_start_check(mob/living/simple_animal/hostile/blood_worm/leech, obj/container, feedback = FALSE)
	if(!length(get_blood_in_container(container)))
		if(feedback)
			container.balloon_alert(leech, "brak krwi!")
		return FALSE
	return TRUE

/datum/action/cooldown/spell/blood_worm/leech/proc/leech_container_active_check(mob/living/simple_animal/hostile/blood_worm/leech, obj/container)
	if(QDELETED(container) || !leech.Adjacent(container))
		return FALSE
	if(!length(get_blood_in_container(container)))
		container.balloon_alert(leech, "nie ma już krwi!")
		return FALSE
	if(world.time < leech.next_move)
		return FALSE
	return TRUE

/// Cała krew w pojemniku
/// Odczynniki pojemnika, a w kroplówce odczynniki podłączonej zlewki
/datum/action/cooldown/spell/blood_worm/leech/proc/get_container_holder(obj/container)
	if(istype(container, /obj/machinery/iv_drip))
		var/obj/machinery/iv_drip/drip = container
		return drip.beaker?.reagents
	return container.reagents

/datum/action/cooldown/spell/blood_worm/leech/proc/get_blood_in_container(obj/container)
	. = list()
	var/datum/reagents/holder = get_container_holder(container)
	if(!holder || holder.total_volume <= 0)
		return
	for(var/datum/reagent/reagent as anything in holder.reagent_list)
		if(reagent.volume <= 0 || !compatible_container_reagent_types[reagent.type])
			continue
		. += reagent

/datum/action/cooldown/spell/blood_worm/leech/hatchling
	leech_rate = BLOOD_VOLUME_NORMAL * 0.05 // 28 j. krwi, 5 pkt zdrowia
	oxyloss_rate = 11

/datum/action/cooldown/spell/blood_worm/leech/juvenile
	leech_rate = BLOOD_VOLUME_NORMAL * 0.075 // 42 j. krwi, 7,5 pkt zdrowia
	oxyloss_rate = 15

/datum/action/cooldown/spell/blood_worm/leech/adult
	leech_rate = BLOOD_VOLUME_NORMAL * 0.1 // 56 j. krwi, 10 pkt zdrowia
	oxyloss_rate = 20

// Plucie krwią

/datum/action/cooldown/spell/blood_worm/spit
	name = "Plucie krwią"
	desc = "Pluj żrącą krwią w cel kosztem własnego zdrowia. Prawy klik w nosicielu rozpuszcza więzy."
	button_icon_state = "spit_blood"
	cooldown_time = 0
	click_to_activate = TRUE
	unset_after_click = FALSE
	check_flags = NONE

	var/health_cost = 0
	var/minimum_health = 10
	var/projectile_type = null
	var/burst_projectile_type = null
	var/burst_count = 5

/datum/action/cooldown/spell/blood_worm/spit/can_cast_spell(feedback = TRUE)
	if(!ishuman(owner) && !isbloodworm(owner))
		return FALSE
	if(owner.stat != CONSCIOUS)
		return FALSE
	var/mob/living/simple_animal/hostile/blood_worm/worm = get_worm()
	if(worm.host?.is_mouth_covered())
		if(feedback)
			owner.balloon_alert(owner, "usta zasłonięte!")
		return FALSE
	if(worm.get_worm_health() - health_cost < minimum_health)
		if(feedback)
			owner.balloon_alert(owner, "brak krwi!")
		return FALSE
	return ..()

/datum/action/cooldown/spell/blood_worm/spit/set_click_ability(mob/on_who)
	. = ..()
	var/right_click_message = ishuman(owner) ? ", [owner.secondary_click_text()] rozpuszczasz więzy" : (burst_projectile_type ? ", [owner.secondary_click_text()] plujesz serią" : "")
	to_chat(owner, "<span class='notice'>Napełniasz [ishuman(owner) ? "usta" : "paszczę"] krwią. <b>Lewym klikiem plujesz żrącą krwią[right_click_message]!</b></span>")

/datum/action/cooldown/spell/blood_worm/spit/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(refund_cooldown)
		to_chat(owner, "<span class='notice'>Wypluwasz krew z [ishuman(owner) ? "ust" : "paszczy"].</span>")

/datum/action/cooldown/spell/blood_worm/spit/InterceptClickOn(mob/living/clicker, params, atom/click_target)
	var/list/modifiers = params2list(params)
	if(modifiers?[SHIFT_CLICK] || modifiers?[ALT_CLICK] || modifiers?[CTRL_CLICK])
		return FALSE
	if(!IsAvailable(TRUE))
		unset_click_ability(owner, refund_cooldown = FALSE)
		return FALSE
	owner.face_atom(click_target)
	var/mob/living/simple_animal/hostile/blood_worm/worm = get_worm()
	if(modifiers?[RIGHT_CLICK] && worm.host)
		melt_restraints()
	else if(modifiers?[RIGHT_CLICK] && burst_projectile_type)
		fire_burst(click_target, params)
	else
		fire_normal(click_target, params)
	if(!IsAvailable(FALSE))
		unset_click_ability(owner, refund_cooldown = FALSE)
	return TRUE

/datum/action/cooldown/spell/blood_worm/spit/proc/fire_normal(atom/click_target, params)
	if(click_target == owner || !projectile_type)
		return
	owner.visible_message("<span class='danger'>[owner] pluje żrącą krwią!</span>", \
		"<span class='danger'>Plujesz żrącą krwią!</span>", "<span class='italics'>Słyszysz plucie.</span>")
	spit(click_target, params, projectile_type)
	playsound(owner, pick('aquila/sound/blood_worm/alien_spitacid.ogg', 'aquila/sound/blood_worm/alien_spitacid2.ogg'), 25, TRUE)
	owner.changeNext_move(CLICK_CD_RANGE)

/datum/action/cooldown/spell/blood_worm/spit/proc/fire_burst(atom/click_target, params)
	if(click_target == owner)
		return
	var/mob/living/simple_animal/hostile/blood_worm/worm = get_worm()
	if(worm.get_worm_health() - health_cost * burst_count < minimum_health)
		owner.balloon_alert(owner, "brak krwi!")
		return
	owner.visible_message("<span class='danger'>[owner] pluje serią żrącej krwi!</span>", \
		"<span class='danger'>Plujesz serią żrącej krwi!</span>", "<span class='italics'>Słyszysz plucie.</span>")
	spit(click_target, params, burst_projectile_type, burst_count, 10)
	playsound(owner, pick('aquila/sound/blood_worm/alien_spitacid.ogg', 'aquila/sound/blood_worm/alien_spitacid2.ogg'), 40, TRUE)
	playsound(owner, 'aquila/sound/blood_worm/bileworm_spit.ogg', 40, TRUE)
	owner.changeNext_move(CLICK_CD_RANGE)
	StartCooldown(10 SECONDS)

/datum/action/cooldown/spell/blood_worm/spit/proc/spit(atom/click_target, params, spit_type, count = 1, spread = 0)
	var/turf/start = get_turf(owner)
	if(!start)
		return
	for(var/i in 1 to count)
		var/obj/item/projectile/blood_worm_spit/projectile = new spit_type(start)
		projectile.firer = owner
		var/deviation = count == 1 ? 0 : -spread + (2 * spread) * ((i - 1) / (count - 1))
		projectile.preparePixelProjectile(click_target, owner, params, deviation)
		projectile.fire()
	owner.newtonian_move(get_dir(click_target, owner))
	var/mob/living/simple_animal/hostile/blood_worm/worm = get_worm()
	worm.adjust_worm_health(-health_cost * count)

/// Rozpuszcza kajdanki, kaftan, sznurówki, szafkę albo kokon pająka wokół nosiciela
/datum/action/cooldown/spell/blood_worm/spit/proc/melt_restraints()
	var/mob/living/carbon/human/host = owner
	if(!istype(host))
		return
	var/melted_something = FALSE
	var/something_to_melt = FALSE
	if(host.handcuffed)
		something_to_melt = TRUE
		melted_something |= melt_item(host, host.handcuffed)
	if(host.legcuffed)
		something_to_melt = TRUE
		melted_something |= melt_item(host, host.legcuffed)
	var/obj/item/clothing/suit/suit = host.wear_suit
	if(istype(suit) && suit.breakouttime)
		something_to_melt = TRUE
		melted_something |= melt_item(host, suit)
	if(istype(host.loc, /obj/structure/closet))
		something_to_melt = TRUE
		melted_something |= melt_closet(host, host.loc)
	if(istype(host.loc, /obj/structure/spider/cocoon))
		something_to_melt = TRUE
		melted_something |= melt_item(host, host.loc)
	if(melted_something)
		playsound(host, 'aquila/sound/blood_worm/sizzle1.ogg', 80, TRUE)
		StartCooldown(20 SECONDS)
	if(!something_to_melt)
		host.balloon_alert(host, "nic cię nie krępuje!")

/datum/action/cooldown/spell/blood_worm/spit/proc/melt_item(mob/living/carbon/human/host, obj/restraints)
	if(!istype(restraints))
		return FALSE
	if(restraints.resistance_flags & (INDESTRUCTIBLE | UNACIDABLE | ACID_PROOF))
		host.balloon_alert(host, "[restraints] jest za twarde!")
		return FALSE
	host.visible_message("<span class='danger'>[host] opluwa [restraints] żrącą krwią!</span>", \
		"<span class='danger'>Opluwasz [restraints] żrącą krwią!</span>", "<span class='italics'>Słyszysz skwierczenie.</span>")
	log_combat(host, restraints, "melted", addition = "(Plucie krwią)")
	addtimer(CALLBACK(src, PROC_REF(finish_melting), restraints), 5 SECONDS)
	return TRUE

/datum/action/cooldown/spell/blood_worm/spit/proc/finish_melting(obj/restraints)
	if(QDELETED(restraints))
		return
	restraints.visible_message("<span class='danger'>[restraints] rozpuszcza się w kałużę krwawej mazi!</span>")
	new /obj/effect/decal/cleanable/blood/old(get_turf(restraints))
	qdel(restraints)

/datum/action/cooldown/spell/blood_worm/spit/proc/melt_closet(mob/living/carbon/human/host, obj/structure/closet/closet)
	if(closet.resistance_flags & (INDESTRUCTIBLE | UNACIDABLE | ACID_PROOF))
		host.balloon_alert(host, "[closet] jest za twarda!")
		return FALSE
	closet.visible_message("<span class='danger'>Zawiasy [closet] zalewa żrąca krew i zaczynają się topić!</span>", \
		blind_message = "<span class='italics'>Słyszysz skwierczenie.</span>", ignored_mobs = list(host))
	to_chat(host, "<span class='danger'>Opluwasz żrącą krwią zawiasy [closet] od środka!</span>")
	log_combat(host, closet, "melted", addition = "(Plucie krwią)")
	addtimer(CALLBACK(src, PROC_REF(finish_melting_closet), closet), 5 SECONDS)
	return TRUE

/datum/action/cooldown/spell/blood_worm/spit/proc/finish_melting_closet(obj/structure/closet/closet)
	if(QDELETED(closet))
		return
	closet.visible_message("<span class='danger'>Zawiasy [closet] rozpuszczają się w krwawą maź!</span>")
	new /obj/effect/decal/cleanable/blood/old(get_turf(closet))
	closet.welded = FALSE
	closet.locked = FALSE
	closet.broken = TRUE
	closet.open()

/obj/item/projectile/blood_worm_spit
	name = "żrąca ślina krwi"
	icon = 'aquila/icons/obj/blood_worm.dmi'
	icon_state = "blood_spit"
	damage_type = BURN
	flag = "bullet" // Pancerz kwasoodporny nie miałby tu sensu
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/sear.ogg'
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blood_worm_spit

/obj/effect/temp_visual/impact_effect/blood_worm_spit
	color = "#ff1313"

/datum/action/cooldown/spell/blood_worm/spit/juvenile
	health_cost = 5.5 // 20 strzałów z rzędu przy pełnym zdrowiu
	projectile_type = /obj/item/projectile/blood_worm_spit/juvenile

/obj/item/projectile/blood_worm_spit/juvenile
	damage = 20
	armour_penetration = 30

/datum/action/cooldown/spell/blood_worm/spit/adult
	desc = "Pluj żrącą krwią w cel kosztem własnego zdrowia. Prawy klik w nosicielu rozpuszcza więzy, a poza nim pluje serią."
	health_cost = 6.5
	projectile_type = /obj/item/projectile/blood_worm_spit/adult
	burst_projectile_type = /obj/item/projectile/blood_worm_spit/adult_burst

/obj/item/projectile/blood_worm_spit/adult
	damage = 25
	armour_penetration = 50

/obj/item/projectile/blood_worm_spit/adult_burst
	damage = 15
	armour_penetration = 50

// Wnikanie w zwłoki

/datum/action/cooldown/spell/blood_worm/invade
	name = "Wniknięcie w zwłoki"
	desc = "Wnikaj w zwłoki człowieka i zrób z nich swojego nosiciela. Możesz też przeciągnąć siebie na zwłoki."
	button_icon_state = "invade_corpse"
	cooldown_time = 0
	click_to_activate = TRUE
	unset_after_click = FALSE

/datum/action/cooldown/spell/blood_worm/invade/Grant(mob/grant_to)
	. = ..()
	if(owner)
		RegisterSignal(owner, COMSIG_MOUSEDROP_ONTO, PROC_REF(on_dragged_onto), override = TRUE)

/datum/action/cooldown/spell/blood_worm/invade/Remove(mob/remove_from)
	if(remove_from)
		UnregisterSignal(remove_from, COMSIG_MOUSEDROP_ONTO)
	return ..()

/datum/action/cooldown/spell/blood_worm/invade/can_cast_spell(feedback = TRUE)
	if(!isbloodworm(owner))
		return FALSE
	return ..()

/// Przeciągnięcie siebie na zwłoki (tgstation#95528)
/datum/action/cooldown/spell/blood_worm/invade/proc/on_dragged_onto(atom/movable/source, atom/over, mob/user)
	SIGNAL_HANDLER
	if(user != owner || !ishuman(over))
		return
	INVOKE_ASYNC(src, PROC_REF(try_invade), over)
	return COMPONENT_NO_MOUSEDROP

/datum/action/cooldown/spell/blood_worm/invade/InterceptClickOn(mob/living/clicker, params, atom/click_target)
	var/list/modifiers = params2list(params)
	if(modifiers?[SHIFT_CLICK] || modifiers?[ALT_CLICK] || modifiers?[CTRL_CLICK])
		return FALSE
	if(isturf(click_target))
		click_target = locate(/mob/living/carbon/human) in click_target
	if(!ishuman(click_target))
		return FALSE
	INVOKE_ASYNC(src, PROC_REF(try_invade), click_target)
	return TRUE

/datum/action/cooldown/spell/blood_worm/invade/proc/try_invade(mob/living/carbon/human/victim)
	var/mob/living/simple_animal/hostile/blood_worm/worm = owner
	if(!istype(worm) || !IsAvailable(TRUE))
		return FALSE
	if(!worm.Adjacent(victim))
		victim.balloon_alert(worm, "za daleko!")
		return FALSE
	unset_click_ability(worm, refund_cooldown = FALSE)
	if(!invade_check(worm, victim, feedback = TRUE))
		return FALSE
	worm.visible_message("<span class='danger'>[worm] zaczyna wnikać w [victim]!</span>", \
		"<span class='notice'>Zaczynasz wnikać w [victim].</span>", "<span class='italics'>Słyszysz przeciskanie się.</span>")
	if(!do_after(worm, 5 SECONDS, FALSE, victim, TRUE, CALLBACK(src, PROC_REF(invade_check), worm, victim)))
		return FALSE
	worm.enter_host(victim)
	return TRUE

/datum/action/cooldown/spell/blood_worm/invade/proc/invade_check(mob/living/simple_animal/hostile/blood_worm/worm, mob/living/carbon/human/victim, feedback = FALSE)
	if(HAS_TRAIT(victim, TRAIT_BLOOD_WORM_HOST))
		if(feedback)
			victim.balloon_alert(worm, "już ma robaka!")
		return FALSE
	if(victim.stat != DEAD)
		if(feedback)
			victim.balloon_alert(worm, "jeszcze żyje!")
		return FALSE
	if(!victim.get_blood_id() || (NOBLOOD in victim.dna?.species?.species_traits) || HAS_TRAIT(victim, TRAIT_NO_BLOOD))
		if(feedback)
			victim.balloon_alert(worm, "nie ma krwi!")
		return FALSE
	if(victim.blood_volume + worm.health * BLOOD_WORM_HEALTH_TO_BLOOD <= worm.get_eject_volume_threshold())
		if(feedback)
			victim.balloon_alert(worm, "za mało krwi do sterowania!")
		return FALSE
	return TRUE

// Opuszczenie nosiciela

/datum/action/cooldown/spell/blood_worm/eject
	name = "Opuszczenie nosiciela"
	desc = "Wyjdź z nosiciela i zabierz ze sobą jego krew."
	button_icon_state = "leave_host"
	cooldown_time = 0
	check_flags = NONE
	var/leaving = FALSE

/datum/action/cooldown/spell/blood_worm/eject/can_cast_spell(feedback = TRUE)
	if(leaving)
		return FALSE
	var/mob/living/simple_animal/hostile/blood_worm/worm = get_worm()
	if(!worm?.host)
		return FALSE
	return ..()

/datum/action/cooldown/spell/blood_worm/eject/cast(atom/cast_on)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(do_eject))

/datum/action/cooldown/spell/blood_worm/eject/proc/do_eject()
	var/mob/living/simple_animal/hostile/blood_worm/worm = get_worm()
	var/mob/living/carbon/human/host = worm.host
	if(!host)
		return
	leaving = TRUE
	host.visible_message("<span class='danger'>[host] pada i zaczyna gwałtownie się trząść!</span>", ignored_mobs = list(owner))
	to_chat(owner, "<span class='danger'>Zaczynasz opuszczać nosiciela...</span>")
	ADD_TRAIT(host, TRAIT_IMMOBILIZED, REF(src))
	host.Knockdown(3 SECONDS)
	for(var/i in 0 to 2)
		addtimer(CALLBACK(src, PROC_REF(do_jitter_effect), worm), i SECONDS)
	var/success = blood_worm_do_after(worm, 3 SECONDS, host, CALLBACK(src, PROC_REF(still_in_host), worm, host))
	REMOVE_TRAIT(host, TRAIT_IMMOBILIZED, REF(src))
	leaving = FALSE
	if(success && worm.host == host)
		worm.leave_host()

/datum/action/cooldown/spell/blood_worm/eject/proc/still_in_host(mob/living/simple_animal/hostile/blood_worm/worm, mob/living/carbon/human/host)
	return worm.host == host

/datum/action/cooldown/spell/blood_worm/eject/proc/do_jitter_effect(mob/living/simple_animal/hostile/blood_worm/worm)
	worm.host?.do_jitter_animation(100)

// Wskrzeszenie nosiciela

/datum/action/cooldown/spell/blood_worm/revive
	name = "Wskrzeszenie nosiciela"
	desc = "Pobudź krążenie krwi nosiciela i przywróć go do życia."
	button_icon_state = "revive_host"
	cooldown_time = 30 SECONDS
	check_flags = NONE
	var/reviving = FALSE

/datum/action/cooldown/spell/blood_worm/revive/can_cast_spell(feedback = TRUE)
	if(reviving)
		return FALSE
	var/mob/living/simple_animal/hostile/blood_worm/worm = get_worm()
	if(!run_checks(worm, worm?.host, feedback))
		return FALSE
	return ..()

/datum/action/cooldown/spell/blood_worm/revive/before_cast(atom/cast_on)
	return ..() | SPELL_NO_IMMEDIATE_COOLDOWN

/datum/action/cooldown/spell/blood_worm/revive/cast(atom/cast_on)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(do_revive))

/datum/action/cooldown/spell/blood_worm/revive/proc/do_revive()
	var/mob/living/simple_animal/hostile/blood_worm/worm = get_worm()
	var/mob/living/carbon/human/host = worm.host
	reviving = TRUE
	to_chat(owner, "<span class='notice'>Zaczynasz pobudzać krążenie krwi w ciele [host]...</span>")
	for(var/i in 1 to 3)
		if(!blood_worm_do_after(worm, 2 SECONDS, host, CALLBACK(src, PROC_REF(run_checks), worm, host)))
			reviving = FALSE
			return
		playsound(host, 'sound/effects/singlebeat.ogg', 50, TRUE)
		var/matrix/original_transform = host.transform
		animate(host, transform = matrix(host.transform).Translate(0, 3), time = 0.2 SECONDS, easing = CUBIC_EASING | EASE_OUT)
		animate(transform = original_transform, time = 0.2 SECONDS, easing = CUBIC_EASING | EASE_IN)
		host.visible_message("<span class='danger'>[host] gwałtownie się trzęsie!</span>", ignored_mobs = list(owner))
	reviving = FALSE
	if(!run_checks(worm, host, TRUE) || !host.revive())
		host.balloon_alert(owner, "nie udało się!")
		return
	host.visible_message("<span class='danger'>[host] powstaje z martwych!</span>", ignored_mobs = list(owner, worm))
	worm.to_chat_self("<span class='green'>Udaje ci się wskrzesić [host]!</span>")
	StartCooldown()

/datum/action/cooldown/spell/blood_worm/revive/proc/run_checks(mob/living/simple_animal/hostile/blood_worm/worm, mob/living/carbon/human/host, feedback = FALSE)
	if(!worm?.host || worm.host != host)
		return FALSE
	if(host.stat != DEAD)
		if(feedback)
			host.balloon_alert(owner, "nie jest martwy!")
		return FALSE
	if(HAS_TRAIT(host, TRAIT_HUSK))
		if(feedback)
			host.balloon_alert(owner, "wysuszone zwłoki!")
		return FALSE
	if(!host.getorganslot(ORGAN_SLOT_BRAIN))
		if(feedback)
			host.balloon_alert(owner, "brak mózgu!")
		return FALSE
	if(host.getOrganLoss(ORGAN_SLOT_BRAIN) >= BRAIN_DAMAGE_DEATH)
		if(feedback)
			host.balloon_alert(owner, "mózg zbyt uszkodzony!")
		return FALSE
	if(host.health <= HEALTH_THRESHOLD_DEAD)
		if(feedback)
			host.balloon_alert(owner, "ciało zbyt zniszczone!")
		return FALSE
	if(!host.can_be_revived())
		if(feedback)
			host.balloon_alert(owner, "nie da się wskrzesić!")
		return FALSE
	return TRUE

// Wstrzyknięcie krwi (leczenie nosiciela)

/datum/action/cooldown/spell/blood_worm/inject
	name = "Wstrzyknięcie krwi"
	desc = "Wstrzyknij swoją krew w uszkodzone tkanki nosiciela. Leczy go kosztem twojego zdrowia."
	button_icon_state = "inject_blood"
	cooldown_time = 30 SECONDS
	check_flags = NONE
	var/health_cost = 0
	var/minimum_health = 10
	var/status_effect_type = null

/datum/action/cooldown/spell/blood_worm/inject/can_cast_spell(feedback = TRUE)
	var/mob/living/simple_animal/hostile/blood_worm/worm = get_worm()
	if(!worm?.host)
		return FALSE
	if(worm.get_worm_health() - health_cost < minimum_health)
		if(feedback)
			owner.balloon_alert(owner, "brak krwi!")
		return FALSE
	return ..()

/datum/action/cooldown/spell/blood_worm/inject/cast(atom/cast_on)
	. = ..()
	var/mob/living/simple_animal/hostile/blood_worm/worm = get_worm()
	var/mob/living/carbon/human/host = worm.host
	host.apply_status_effect(status_effect_type)
	host.visible_message("<span class='danger'>Rany [host] zaczynają się nienaturalnie szybko goić!</span>", ignored_mobs = list(owner))
	to_chat(owner, "<span class='notice'>Wstrzykujesz krew w uszkodzone tkanki nosiciela.</span>")
	worm.adjust_worm_health(-health_cost)

/datum/status_effect/blood_worm_transfuse
	id = "blood_worm_transfuse"
	duration = 20 SECONDS
	tick_interval = 1 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /atom/movable/screen/alert/status_effect/blood_worm_transfuse
	var/damage_regen_rate = 0
	var/bleed_regen_rate = 0
	var/organ_regen_rate = 0
	var/trauma_regen_rate = 0
	var/trauma_regen_accumulation = 0

/datum/status_effect/blood_worm_transfuse/tick()
	var/mob/living/carbon/human/host = owner
	if(!istype(host))
		return
	var/healing_left = damage_regen_rate
	for(var/damage_type in list(BRUTE, BURN, TOX))
		if(healing_left <= 0)
			break
		var/current
		switch(damage_type)
			if(BRUTE)
				current = host.getBruteLoss()
			if(BURN)
				current = host.getFireLoss()
			if(TOX)
				current = host.getToxLoss()
		if(current <= 0)
			continue
		var/amount = min(current, healing_left)
		switch(damage_type)
			if(BRUTE)
				host.adjustBruteLoss(-amount, FALSE)
			if(BURN)
				host.adjustFireLoss(-amount, FALSE)
			if(TOX)
				host.adjustToxLoss(-amount, FALSE, TRUE)
		healing_left -= amount
	// U nas nie ma ran z tg, więc krew zasklepia krwawienie
	if(bleed_regen_rate && host.is_bleeding())
		host.cauterise_wounds(bleed_regen_rate)
	for(var/obj/item/organ/organ as anything in host.internal_organs)
		organ.applyOrganDamage(-organ_regen_rate)
	if(host.has_trauma_type(resilience = TRAUMA_RESILIENCE_SURGERY))
		trauma_regen_accumulation += trauma_regen_rate
		while(trauma_regen_accumulation >= 1 && host.has_trauma_type(resilience = TRAUMA_RESILIENCE_SURGERY))
			host.cure_trauma_type(resilience = TRAUMA_RESILIENCE_SURGERY)
			trauma_regen_accumulation -= 1
	else
		trauma_regen_accumulation = 0
	host.updatehealth()

/atom/movable/screen/alert/status_effect/blood_worm_transfuse
	name = "Wstrzyknięta krew"
	desc = "Wstrzyknięta krew szybko leczy nosiciela."
	icon = 'aquila/icons/mob/actions/actions_blood_worm.dmi'
	icon_state = "inject_blood"

/datum/action/cooldown/spell/blood_worm/inject/hatchling
	health_cost = 20
	cooldown_time = 30 SECONDS
	status_effect_type = /datum/status_effect/blood_worm_transfuse/hatchling

/datum/status_effect/blood_worm_transfuse/hatchling
	damage_regen_rate = 6 // 20 s * 6 = 120 pkt
	bleed_regen_rate = 0.2
	organ_regen_rate = 2.5
	trauma_regen_rate = 1 / 6

/datum/action/cooldown/spell/blood_worm/inject/juvenile
	health_cost = 35
	cooldown_time = 40 SECONDS
	status_effect_type = /datum/status_effect/blood_worm_transfuse/juvenile

/datum/status_effect/blood_worm_transfuse/juvenile
	damage_regen_rate = 8
	bleed_regen_rate = 0.25
	organ_regen_rate = 4
	trauma_regen_rate = 1 / 5

/datum/action/cooldown/spell/blood_worm/inject/adult
	health_cost = 50
	cooldown_time = 50 SECONDS
	status_effect_type = /datum/status_effect/blood_worm_transfuse/adult

/datum/status_effect/blood_worm_transfuse/adult
	damage_regen_rate = 10
	bleed_regen_rate = 0.3
	organ_regen_rate = 5
	trauma_regen_rate = 1 / 4
