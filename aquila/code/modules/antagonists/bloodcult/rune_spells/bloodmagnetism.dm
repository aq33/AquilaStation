
/datum/rune_spell/bloodmagnetism
	name = "Magnetyzm Krwi"
	desc = "Przyzwij jednego ze współwyznawców, bez względu na to, jak daleko jest, dopóki bije jego serce."
	desc_talisman = "Użyj, by rozpocząć rytuał Magnetyzmu Krwi tam, gdzie stoisz."
	invocation = "N'ath reth sh'yro eth d'rekkathnor!"
	word1 = /datum/rune_word/join
	word2 = /datum/rune_word/other
	word3 = /datum/rune_word/self
	page = "Ta runa ma w sobie dwa różne rytuały:\
		<br><br>Pierwszy, Przyzwanie Kultysty, ściąga kultystę z dowolnego miejsca w świecie, żywego albo martwego, kosztem 50u krwi, które można podzielić, jeśli inni kultyści dołączą do rytuału. \
		Rytuał się jednak nie uda, jeśli cel jest przytwierdzony do miejsca albo ma święty implant.\
		<br><br>Drugi, Dołączenie do Kultysty, przenosi ciebie obok wybranego kultysty kosztem 15u krwi. \
		Inni kultyści mogą dołączyć, by ci towarzyszyć, ale każdy uczestnik płaci te 15u. \
		I tu rytuał się nie uda, jeśli cel ma święty implant.\
		<br><br>Ta runa zostaje po użyciu, można jej używać wielokrotnie."
	remaining_cost = 10
	cost_upkeep = 1
	var/rejoin = 0
	var/mob/target = null
	var/list/feet_portals = list()
	var/cost_summon = 50//you probably don't want to pay that up alone
	var/cost_rejoin = 15//static cost for every contributor

/datum/rune_spell/bloodmagnetism/Destroy()
	target = null
	for (var/guy in feet_portals)
		var/obj/object = feet_portals[guy]
		qdel(object)
	feet_portals = list()
	spell_holder?.overlays -= image('aquila/icons/bloodcult/cult.dmi', "runetrigger-build")
	spell_holder?.overlays -= image('aquila/icons/bloodcult/effects.dmi', "rune_summon")
	return ..()


/datum/rune_spell/bloodmagnetism/abort()
	spell_holder?.overlays -= image('aquila/icons/bloodcult/cult.dmi', "runetrigger-build")
	spell_holder?.overlays -= image('aquila/icons/bloodcult/effects.dmi', "rune_summon")
	for (var/guy in feet_portals)
		var/obj/object = feet_portals[guy]
		qdel(object)
	..()

/datum/rune_spell/bloodmagnetism/cast()
	var/obj/effect/new_rune/R = spell_holder
	R.one_pulse()

	var/answer = tgui_alert(activator, "Przyciągniesz ich do siebie czy siebie do nich?", "Magnetyzm Krwi", list("Przyzwij kultystę", "Dołącz do kultysty"))
	if (!answer || QDELETED(src))
		qdel(src)
		return
	rejoin = (answer == "Dołącz do kultysty")

	var/list/possible_targets = list()
	var/list/prisoners = list()
	var/datum/antagonist/cult/cultist = IS_CULTIST(activator)
	var/datum/team/cult/bloodcult = cultist?.cult_team
	if (!bloodcult)
		qdel(src)
		return
	for (var/datum/mind/mind in bloodcult.members)
		if (mind.current)
			if (mind.current.occult_muted())
				continue
			possible_targets.Add(mind.current)

	//Prisoners are valid Blood Magnetism targets!
	for(var/obj/item/restraints/handcuffs/cult/cuffs in bloodcult.bindings)
		if (iscarbon(cuffs.loc))
			var/mob/living/carbon/carbon = cuffs.loc
			if (carbon.handcuffed == cuffs)
				prisoners.Add(carbon)

	var/list/annotated_targets = list()
	var/list/visible_mobs = viewers(activator)
	var/i = 1
	for(var/mob/mob in possible_targets)
		var/status = ""
		if(mob == activator)
			status = " (Ty)"
		else if(mob in visible_mobs)
			status = " (Widoczny)"
		else if(mob.stat == DEAD)
			status = " (Martwy)"
		annotated_targets["\Roman[i]-[mob.real_name][status]"] = mob
		i++

	for(var/mob/prisoner in prisoners)
		annotated_targets["\Roman[i]-[prisoner.real_name] (Więzień)"] = prisoner
		i++

	var/choice = tgui_input_list(activator, "Wybierz, do kogo chcesz [rejoin ? "dołączyć" : "przyzwać"]", "Magnetyzm Krwi", annotated_targets)
	if (!choice || QDELETED(src))
		qdel(src)
		return
	target = annotated_targets[choice]
	if (!target)
		qdel(src)
		return

	contributors.Add(activator)
	update_progbar()
	if (activator.client)
		activator.client.images |= progbar
	spell_holder.overlays += image('aquila/icons/bloodcult/cult.dmi', "runetrigger-build")
	if (!rejoin)
		spell_holder.overlays += image('aquila/icons/bloodcult/effects.dmi', "rune_summon")
	else
		feet_portals.Add(activator)
		var/obj/effect/cult_ritual/feet_portal/P = new (activator.loc, activator, src)
		feet_portals[activator] = P
	to_chat(activator, span_rose("Krwawą opłatę za ten rytuał można znacznie zmniejszyć, jeśli dołączą do niego inni kultyści.") )
	INVOKE_ASYNC(src, PROC_REF(payment))

/datum/rune_spell/bloodmagnetism/cast_talisman()//we spawn an invisible rune under our feet that works like the regular one
	var/obj/effect/new_rune/R = new(get_turf(activator))
	R.icon_state = "temp"
	R.active_spell = new type(activator, R)
	qdel(src)

/datum/rune_spell/bloodmagnetism/midcast(mob/add_cultist)
	if (add_cultist in contributors)
		return
	invoke(add_cultist, invocation)
	contributors.Add(add_cultist)
	if (add_cultist.client)
		add_cultist.client.images |= progbar
	if (rejoin)
		feet_portals.Add(add_cultist)
		var/obj/effect/cult_ritual/feet_portal/P = new (add_cultist.loc, add_cultist, src)
		feet_portals[add_cultist] = P

/datum/rune_spell/bloodmagnetism/proc/payment()//an extra payment is spent at the end of the channeling, and shared between contributors
	var/failsafe = 0
	while(failsafe < 1000)
		failsafe++
		if (destroying_self || !spell_holder)
			return
		//are our payers still here and about?
		for(var/mob/living/contributor in contributors)
			if (!IS_CULTIST(contributor) || !(contributor in range(spell_holder, 1)) || (contributor.stat != CONSCIOUS))
				if (contributor.client)
					contributor.client.images -= progbar
				var/obj/effect/cult_ritual/feet_portal/P = feet_portals[contributor]
				qdel(P)
				feet_portals.Remove(contributor)
				contributors.Remove(contributor)
		//alright then, time to pay in blood
		var/amount_paid = 0
		for(var/mob/living/contributor in contributors)
			var/data = use_available_blood(contributor, cost_upkeep/contributors.len, contributors[contributor])//always 1u total per payment
			if (data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)//out of blood are we?
				contributors.Remove(contributor)
				var/obj/effect/cult_ritual/feet_portal/P = feet_portals[contributor]
				qdel(P)
				feet_portals.Remove(contributor)
			else
				amount_paid += data[BLOODCOST_TOTAL]
				contributors[contributor] = data[BLOODCOST_RESULT]
				make_tracker_effects(contributor.loc, spell_holder, 1, "soul", 3, /obj/effect/tracker/drain, 1)//visual feedback

		accumulated_blood += amount_paid

		//if there's no blood for over 3 seconds, the channeling fails
		if (amount_paid)
			cancelling = 3
		else
			cancelling--
			if (cancelling <= 0)
				if(accumulated_blood && !(locate(/obj/effect/decal/cleanable/blood/splatter) in spell_holder.loc))
					new /obj/effect/decal/cleanable/blood/splatter(spell_holder.loc)//splash
				abort(RITUALABORT_BLOOD)
				return

		if (accumulated_blood >= remaining_cost)
			success()
			return

		update_progbar()

		sleep(10)
	message_admins("A rune ritual has iterated for over 1000 blood payment procs. Something's wrong there.")

/datum/rune_spell/bloodmagnetism/proc/success()
	if (QDELETED(target) || target.occult_muted())
		for(var/mob/living/contributor in contributors)
			to_chat(contributor, span_warning("Rytuał się nie udał. Cel jest chyba pod wpływem klątwy, która nie pozwala nam sięgnąć go przez zasłonę.") )
	else
		if (rejoin)
			var/list/valid_turfs = list()
			for(var/turf/T in orange(target, 1))
				if(!is_blocked_turf(T, TRUE))
					valid_turfs.Add(T)
			if (valid_turfs.len)
				for(var/mob/living/contributor in contributors)
					use_available_blood(contributor, cost_rejoin, contributors[contributor])
					var/datum/antagonist/cult/cult_datum = IS_CULTIST(contributor)
					cult_datum?.gain_devotion(100, DEVOTION_TIER_2, "bloodmagnetism_rejoin", contributor)
					make_tracker_effects(contributor.loc, spell_holder, 1, "soul", 3, /obj/effect/tracker/drain, 3)
					var/obj/effect/abstract/landing_animation = anim(target = contributor, a_icon = 'aquila/icons/bloodcult/effects.dmi', flick_anim = "cult_jaunt_prepare", plane = GAME_PLANE_UPPER)
					playsound(contributor, 'aquila/sound/bloodcult/cultjaunt_prepare.ogg', 75, 0, -3)
					addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(bloodmagnetism_jaunt), contributor, pick(valid_turfs), landing_animation), 1 SECONDS)
		else
			if(target.buckled || !isturf(target.loc))
				to_chat(target, span_warning("Czujesz, że jakaś siła chce przeciągnąć cię przez zasłonę, ale nie może, póki jesteś przypięty albo w czymś siedzisz.") )
				for(var/mob/living/contributor in contributors)
					to_chat(contributor, span_warning("Rytuał się nie udał. Cel jest chyba przykuty do swojego miejsca.") )
			else
				for(var/mob/living/contributor in contributors)
					use_available_blood(contributor, cost_summon/contributors.len, contributors[contributor])
					make_tracker_effects(contributor.loc, spell_holder, 1, "soul", 3, /obj/effect/tracker/drain, 3)
					var/datum/antagonist/cult/cult_datum = IS_CULTIST(contributor)
					cult_datum?.gain_devotion(100, DEVOTION_TIER_2, "bloodmagnetism_summon", contributor)
				var/obj/effect/abstract/landing_animation = anim(target = src.target, a_icon = 'aquila/icons/bloodcult/effects.dmi', flick_anim = "cult_jaunt_prepare", lay = ABOVE_MOB_LAYER, plane = GAME_PLANE_UPPER)
				var/mob/mob_target = target//so we keep track of them after the datum is ded until we jaunt
				var/turf/T = get_turf(spell_holder)
				playsound(mob_target, 'aquila/sound/bloodcult/cultjaunt_prepare.ogg', 75, 0, -3)
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(bloodmagnetism_jaunt), mob_target, T, landing_animation), 1 SECONDS)

	for(var/mob/living/contributor in contributors)
		if (contributor.client)
			contributor.client.images -= progbar
		contributors.Remove(contributor)

	if (activator && activator.client)
		activator.client.images -= progbar

	if (progbar)
		progbar.loc = null

	if (spell_holder.icon_state == "temp")
		qdel(spell_holder)
	else
		qdel(src)

/// Skok przez zasłonę po sekundzie przygotowań (w drafcie spawn(10))
/proc/bloodmagnetism_jaunt(mob/jaunter, turf/destination, obj/effect/abstract/landing_animation)
	if (QDELETED(jaunter))
		return
	playsound(jaunter, 'aquila/sound/bloodcult/cultjaunt_land.ogg', 30, 0, -3)
	new /obj/effect/bloodcult_jaunt(get_turf(jaunter), jaunter, destination)
	if (landing_animation)
		flick("cult_jaunt_land", landing_animation)

/obj/effect/cult_ritual/feet_portal
	anchored = 1
	icon_state = "rune_rejoin"
	pixel_y = -10
	layer = ABOVE_OBJ_LAYER
	plane = GAME_PLANE
	var/mob/living/caster = null
	var/turf/source = null

/obj/effect/cult_ritual/feet_portal/New(turf/loc, mob/living/user, datum/rune_spell/runespell)
	..()
	caster = user
	source = get_turf(runespell?.spell_holder)
	if (!caster)
		qdel(src)
		return
	// AQUILA - w vg flaga PROXMOVE (portal idzie za stopami), u nas sygnał ruchu rzucającego
	RegisterSignal(caster, COMSIG_MOVABLE_MOVED, PROC_REF(follow_caster))

/obj/effect/cult_ritual/feet_portal/Destroy()
	if (caster)
		UnregisterSignal(caster, COMSIG_MOVABLE_MOVED)
	caster = null
	source = null
	return ..()

/obj/effect/cult_ritual/feet_portal/proc/follow_caster()
	SIGNAL_HANDLER
	if (caster && caster.loc != loc)
		forceMove(get_turf(caster))
