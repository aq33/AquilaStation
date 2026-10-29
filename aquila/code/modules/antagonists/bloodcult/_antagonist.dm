/datum/antagonist/cult
	name = "Kultysta"
	roundend_category = "kultyści"
	antagpanel_category = "Cult"
	antag_moodlet = /datum/mood_event/cult
	banning_key = ROLE_CULTIST
	required_living_playtime = 4
	var/ignore_implant = FALSE
	var/give_equipment = FALSE
	var/datum/team/cult/cult_team

	///NEW VARS HERE
	var/list/tattoos = list()
	var/holywarning_cooldown = 0
	var/list/conversion = list()
	var/second_chance = 1
	var/datum/deconversion_ritual/deconversion = null

	//writing runes
	var/rune_blood_cost = 1	// How much blood spent per rune word written
	var/verbose = FALSE	// Used by the rune writing UI to avoid message spam

	var/cultist_role = CULTIST_ROLE_NONE // Because the role might change on the fly and we don't want to set everything again each time, better not start dealing with subtypes
	var/arch_cultist = FALSE	// same as above

	var/time_role_changed_last = 0

	var/datum/antagonist/cult/mentor = null
	var/list/acolytes = list()

	var/devotion = 0
	var/rank = DEVOTION_TIER_0

	var/blood_pool = FALSE

	var/initial_rituals = FALSE
	var/list/possible_rituals = list()
	var/list/rituals = list(RITUAL_CULTIST_1, RITUAL_CULTIST_2)
	var/logo_state = "cult-logo"

/datum/antagonist/cult/get_team()
	return cult_team

/datum/antagonist/cult/create_team(datum/team/cult/new_team)
	if(!new_team)
		//todo remove this and allow admin buttons to create more than one cult
		for(var/datum/antagonist/cult/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.cult_team)
				cult_team = H.cult_team
				return
		cult_team = new /datum/team/cult
		cult_team.setup_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	cult_team = new_team

/datum/antagonist/cult/proc/add_objectives()
	objectives |= cult_team.objectives

/datum/antagonist/cult/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(. && !ignore_implant)
		. = is_convertable_to_cult(new_owner.current, cult_team)

/datum/antagonist/cult/greet()
	to_chat(owner, span_userdanger("Jesteś członkiem kultu Nar'Sie!"))
	owner.current.playsound_local(get_turf(owner.current), 'aquila/sound/bloodcult/monke/ambience/antag/bloodcult/bloodcult_gain.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)//subject to change
	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Kult krwi",
		"Pisz runy krwią, zdobywaj oddanie rytuałami i przybliżaj Zaćmienie. Gdy nadejdzie, rozedrzyj rzeczywistość i sprowadź Nar'Sie!")

/datum/antagonist/cult/on_gain()
	add_objectives()
	START_PROCESSING(SSobj, src)
	for (var/ritual_type in GLOB.bloodcult_personal_rituals)
		possible_rituals += new ritual_type()
	. = ..()
	var/mob/living/current = owner.current
	current.DisplayUI("Cultist")
	if(give_equipment)
		equip_cultist(TRUE)
	current.log_message("has been converted to the cult of Nar'Sie!", LOG_ATTACK, color = "#960000")

	if(cult_team.blood_target && cult_team.blood_target_image && current.client)
		current.client.images += cult_team.blood_target_image

/datum/antagonist/cult/on_removal()
	STOP_PROCESSING(SSobj, src)
	GLOB.blood_communion -= src
	blood_pool = FALSE
	DropMentorship()
	if (cultist_role == CULTIST_ROLE_MENTOR && cult_team)
		cult_team.mentor_count--
	if (cult_team)
		cult_team.deconverted[owner.name] = devotion
	var/mob/living/current = owner.current
	if(current)
		current.remove_particles(PS_CULT_SMOKE)
		current.remove_particles(PS_CULT_SMOKE2)
		current.remove_particles(PS_CULT_HALO)
		current.HideUI("Cultist")
		if(!silent)
			current.visible_message(span_deconversion_message("[current] wygląda, jakby właśnie powrócił do dawnej wiary!"), ignored_mobs = current)
			to_chat(current, span_userdanger("Przez twój umysł przebiega nieznane białe światło, oczyszczając cię ze skazy Geometry i wszystkich wspomnień z czasów, gdy jej służyłeś."))
			current.log_message("has renounced the cult of Nar'Sie!", LOG_ATTACK, color = "#960000")
		if(cult_team?.blood_target_image && current.client)
			current.client.images -= cult_team.blood_target_image
	. = ..()
	cult_team?.check_destroy()

/datum/antagonist/cult/proc/equip_cultist(metal = TRUE)
	var/mob/living/carbon/H = owner.current
	if(!istype(H))
		return
	. += cult_give_item(/obj/item/melee/cultblade/dagger, H)
	if(metal)
		. += cult_give_item(/obj/item/stack/sheet/runed_metal/ten, H)
	to_chat(owner, "To pomoże ci założyć kult na tym statku. Użyj tego dobrze i pamiętaj - nie jesteś sam.")

///Attempts to make a new item and put it in a potential inventory slot in the provided mob.
/datum/antagonist/cult/proc/cult_give_item(obj/item/item_path, mob/living/carbon/human/mob)
	var/list/slots = list(
		"plecaku" = ITEM_SLOT_BACKPACK,
		"lewej kieszeni" = ITEM_SLOT_LPOCKET,
		"prawej kieszeni" = ITEM_SLOT_RPOCKET
	)

	var/obj/item/item = new item_path(mob)
	var/where = mob.equip_in_one_of_slots(item, slots, qdel_on_fail = FALSE)
	if(!where)
		//Our last attempt, we force the item into the backpack
		if(istype(mob.back, /obj/item/storage/backpack))
			SEND_SIGNAL(mob.back, COMSIG_TRY_STORAGE_INSERT, item, null, TRUE, TRUE)
			to_chat(mob, span_danger("W plecaku masz: [item.name]."))
			return TRUE
		item.forceMove(get_turf(mob))
		message_admins("[ADMIN_FULLMONTY(mob)] – nie udało się wyposażyć kultysty.")
		to_chat(mob, span_userdanger("Nie udało się dać ci: [item.name]. Przedmiot leży pod twoimi stopami."))
		return FALSE
	to_chat(mob, span_danger("Masz [item.name] w [where]."))
	if(where == "plecaku")
		SEND_SIGNAL(mob.back, COMSIG_TRY_STORAGE_SHOW, mob)
	return TRUE

/datum/antagonist/cult/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	handle_clown_mutation(current, mob_override ? null : "Dzięki szkoleniu przezwyciężasz swoją klaunią naturę i możesz używać broni, nie raniąc samego siebie.")
	current.faction |= FACTION_CULT
	current.grant_language(/datum/language/narsie, TRUE, TRUE, LANGUAGE_CULTIST)
	add_antag_hud(ANTAG_HUD_CULT, "cult", current)
	ADD_TRAIT(current, TRAIT_HEALS_FROM_CULT_PYLONS, CULT_TRAIT)
	if(cult_team?.stage == BLOODCULT_STAGE_ECLIPSE || cult_team?.stage == BLOODCULT_STAGE_NARSIE)
		give_cult_eyes()

/datum/antagonist/cult/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	if(!current)
		return
	handle_clown_mutation(current, removing = FALSE)
	current.faction -= FACTION_CULT
	current.remove_language(/datum/language/narsie, TRUE, TRUE, LANGUAGE_CULTIST)
	remove_antag_hud(ANTAG_HUD_CULT, current)
	REMOVE_TRAIT(current, TRAIT_HEALS_FROM_CULT_PYLONS, CULT_TRAIT)
	current.clear_alert("bloodsense")
	remove_cult_eyes(current)

/datum/antagonist/cult/admin_add(datum/mind/new_owner, mob/admin)
	give_equipment = FALSE
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] czyni [key_name_admin(new_owner)] kultystą.")
	log_admin("[key_name(admin)] has cult-ed [key_name(new_owner)].")

/datum/antagonist/cult/admin_remove(mob/user)
	message_admins("[key_name_admin(user)] odbiera [key_name_admin(owner)] status kultysty.")
	log_admin("[key_name(user)] has decult-ed [key_name(owner)].")
	silent = TRUE
	return ..()

/datum/antagonist/cult/get_admin_commands()
	. = ..()
	.["Sztylet"] = CALLBACK(src, PROC_REF(admin_give_dagger))
	.["Sztylet i metal"] = CALLBACK(src, PROC_REF(admin_give_metal))
	.["Zabierz sztylet i metal"] = CALLBACK(src, PROC_REF(admin_take_all))
	.["Daj oddanie"] = CALLBACK(src, PROC_REF(admin_give_devotion))

/datum/antagonist/cult/proc/admin_give_dagger(mob/admin)
	if(!equip_cultist(metal = FALSE))
		to_chat(admin, span_danger("Nie udało się zespawnować sztyletu!"))

/datum/antagonist/cult/proc/admin_give_metal(mob/admin)
	if (!equip_cultist(metal = TRUE))
		to_chat(admin, span_danger("Nie udało się zespawnować runicznego metalu!"))

/datum/antagonist/cult/proc/admin_take_all(mob/admin)
	var/mob/living/current = owner.current
	if(!current)
		return
	for(var/o in current.GetAllContents())
		if(istype(o, /obj/item/melee/cultblade/dagger) || istype(o, /obj/item/stack/sheet/runed_metal))
			qdel(o)

/datum/antagonist/cult/proc/admin_give_devotion(mob/admin)
	var/amount = input(admin, "Ile oddania chcesz dać?", "Dawanie oddania") as null|num
	if (!amount)
		return
	gain_devotion(amount, DEVOTION_TIER_4)
	message_admins("[key_name_admin(admin)] daje [key_name_admin(owner)] oddanie: [amount].")

/datum/antagonist/cult/proc/erase_rune()
	var/mob/living/user = owner.current
	if (!istype(user))
		return

	if (user.incapacitated())
		return

	var/turf/T = get_turf(user)
	var/obj/effect/new_rune/rune = locate() in T

	if (rune && rune.invisibility == INVISIBILITY_OBSERVER)
		to_chat(user, span_warning("Wyczuwasz tu obecność ukrytej runy. Musisz ją odsłonić, zanim zetrzesz z niej słowa."))
		return

	var/removed_word = erase_rune_word(get_turf(user))
	if (removed_word)
		to_chat(user, span_notice("Cofasz się po własnych śladach, ostrożnie zacierając linie runy [removed_word]."))
	else
		to_chat(user, span_warning("Nie ma tu już żadnych słów runy do starcia."))

/datum/antagonist/cult/proc/gain_devotion(acquired_devotion = 0, tier = DEVOTION_TIER_0, key, extra)
	if (cult_team)
		switch(cult_team.stage)
			if (BLOODCULT_STAGE_DEFEATED)//no more devotion gains if the bloodstone has been destroyed
				return
			if (BLOODCULT_STAGE_NARSIE)//or narsie has risen
				return

	if (key && (!cult_team || (cult_team.stage != BLOODCULT_STAGE_ECLIPSE)))
		for (var/ritual_slot in rituals)
			if (rituals[ritual_slot])
				var/datum/bloodcult_ritual/my_ritual = rituals[ritual_slot]
				if (key in my_ritual.keys)
					if (my_ritual.key_found(extra))
						my_ritual.complete()
						if (!my_ritual.only_once)
							possible_rituals += my_ritual
						rituals[ritual_slot] = null
						var/mob/M = owner.current
						if (M)
							to_chat(M, span_cult("Ukończyłeś rytuał i zostałeś nagrodzony za swoje oddanie... wkrótce jego miejsce zajmie kolejny."))
						addtimer(CALLBACK(src, PROC_REF(refill_ritual_slot), ritual_slot), 5 MINUTES)
	if (key && cult_team)
		cult_team.check_ritual(key, extra, src)

	//The more devotion the cultist has acquired, the less devotion they obtain from lesser rituals
	switch (get_devotion_rank() - tier)
		if (3 to INFINITY)
			return//until they just don't get any devotion anymore
		if (2)
			acquired_devotion /= 10
		if (1)
			acquired_devotion /= 2
	devotion += acquired_devotion
	check_rank_upgrade()

	if (cult_team)
		cult_team.total_devotion += acquired_devotion

/// Uzupełnia pusty slot osobistego rytuału (po odczekaniu).
/datum/antagonist/cult/proc/refill_ritual_slot(ritual_slot)
	if (QDELETED(src) || rituals[ritual_slot])
		return
	replace_rituals(ritual_slot)

/datum/antagonist/cult/proc/check_rank_upgrade()
	var/new_rank = get_devotion_rank()
	while (new_rank > rank)
		rank++
		if (iscarbon(owner.current))//constructs and shades cannot make use of those powers so no point informing them.
			to_chat(owner.current, span_cultlarge("Wraz ze wzrostem twojego oddania dla kultu budzi się w tobie nowa moc."))
			switch(rank)
				if (DEVOTION_TIER_1)
					to_chat(owner.current, span_danger("Wspólnota krwi"))
					to_chat(owner.current, "<b>Każdy koszt krwi wymagany przez runę lub rytuał kultu będzie teraz mniejszy i dzielony z innymi kultystami, którzy osiągnęli tę moc. Wspólnotę krwi możesz w razie potrzeby wyłączać.</b>")
					GiveTattoo(/datum/cult_tattoo/bloodpool)
				if (DEVOTION_TIER_2)
					to_chat(owner.current, span_danger("Krwawy sztylet"))
					to_chat(owner.current, "<b>Możesz teraz uformować sztylet z własnej krwi (albo z krwi wspólnej, z każdej krwi, jaką masz pod ręką). Trafiając kogoś, sztylet kradnie mu trochę krwi, a schowanie go oddaje ci całą skradzioną krew. Rzucony sztylet zadaje obrażenia zależne od ilości niesionej krwi i przybija ofiarę do ziemi, zmuszając ją do wyciągnięcia go, zanim odejdzie.</b>")
					GiveTattoo(/datum/cult_tattoo/dagger)
				if (DEVOTION_TIER_3)
					to_chat(owner.current, span_danger("Runiczna skóra"))
					to_chat(owner.current, "<b>Możesz teraz wtopić w skórę talizman z nasyconą lub dostrojoną runą, by rzucać go bez użycia rąk, dopóki jesteś przytomny i nie działa na ciebie woda święcona.</b>")
					GiveTattoo(/datum/cult_tattoo/rune_store)
				if (DEVOTION_TIER_4)
					to_chat(owner.current, span_danger("Sigil skrótu"))
					to_chat(owner.current, "<b>Przyłóż dłonie do ściany, by narysować na niej sigil, przez który ty i każdy sojusznik możecie przejść.</b>")
					GiveTattoo(/datum/cult_tattoo/shortcut)

/datum/antagonist/cult/proc/get_devotion_rank()
	switch(devotion)
		if (2000 to INFINITY)
			return DEVOTION_TIER_4
		if (1000 to 2000)
			return DEVOTION_TIER_3
		if (500 to 1000)
			return DEVOTION_TIER_2
		if (100 to 500)
			return DEVOTION_TIER_1
	return DEVOTION_TIER_0

/datum/antagonist/cult/proc/FindMentor()
	var/datum/team/cult/cult = cult_team
	if (!cult || !cult.mentor_count)
		return
	var/datum/antagonist/cult/potential_mentor
	var/min_acolytes = 10000
	for (var/datum/mind/mind in cult.members)
		var/datum/antagonist/cult/cult_datum = mind.has_antag_datum(/datum/antagonist/cult)
		if (!cult_datum || !mind.current || mind.current.stat == DEAD)
			continue
		if (cult_datum.cultist_role == CULTIST_ROLE_MENTOR)
			if (cult_datum.acolytes.len < min_acolytes || (cult_datum.acolytes.len == min_acolytes && prob(50)))
				min_acolytes = cult_datum.acolytes.len
				potential_mentor = cult_datum

	if (potential_mentor)
		mentor = potential_mentor
		potential_mentor.acolytes |= src
		to_chat(owner.current, span_cult("Jesteś teraz pod opieką mentora: <span class = 'danger'>[mentor.owner.name] ([mentor.owner.assigned_role == "MODE" ? (mentor.owner.special_role) : (mentor.owner.assigned_role)])</span>. Poproś go o pomoc w poznawaniu ścieżek naszego kultu."))
		to_chat(mentor.owner.current, span_cult("Jesteś teraz mentorem: <span class = 'danger'>[owner.name] ([owner.assigned_role == "MODE" ? (owner.special_role) : (owner.assigned_role)])</span>."))
		message_admins("[mentor.owner.key]/([mentor.owner.name]) zostaje mentorem: [owner.name]")
		log_admin("[mentor.owner.key]/([mentor.owner.name]) is now mentoring [owner.name]")

/datum/antagonist/cult/proc/GiveTattoo(type)
	for(var/tattoo_name in tattoos)
		if(istype(tattoos[tattoo_name], type))
			return
	var/datum/cult_tattoo/T = new type
	tattoos[T.name] = T
	update_cult_hud()
	T.getTattoo(owner.current)
	//anim(target = owner.current, a_icon = 'aquila/icons/bloodcult/monke/effects/32x96.dmi', flick_anim = "tattoo_receive", lay = NARSIE_GLOW, plane = ABOVE_LIGHTING_PLANE)
	//a bit too visible now that those may be unlocked at any time and no longer just in front of a spire
	//var/atom/movable/overlay/tattoo_markings = anim(target = owner.current, a_icon = 'aquila/icons/bloodcult/vg/mob/cult_tattoos.dmi', flick_anim = "[T.icon_state]_mark", sleeptime = 30, lay = NARSIE_GLOW, plane = ABOVE_LIGHTING_PLANE)
	//animate(tattoo_markings, alpha = 0, time = 30)

/datum/antagonist/cult/proc/update_cult_hud()
	var/mob/M = owner?.current
	if(M)
		if (M.client && M.hud_used)
			if (isshade(M))
				if (istype(M.loc, /obj/item/melee/soulblade))
					M.DisplayUI("Soulblade")
			else
				M.DisplayUI("Cultist")

/// Odświeża panel kultu, jeśli jest otwarty.
/datum/antagonist/cult/proc/refresh_cult_panel()
	var/datum/mind/M = owner
	if (M && ("Cult Panel" in M.active_uis))
		var/datum/mind_ui/m_ui = M.active_uis["Cult Panel"]
		if (m_ui.active)
			m_ui.Display()

/datum/antagonist/cult/proc/replace_rituals(slot)
	if (!slot)
		return

	var/list/valid_rituals = list()

	for (var/datum/bloodcult_ritual/R in possible_rituals)
		if (R.pre_conditions(src))
			valid_rituals += R

	if (valid_rituals.len < 1)
		return

	var/datum/bloodcult_ritual/BR = pick(valid_rituals)
	rituals[slot] = BR
	possible_rituals -= BR
	BR.init_ritual()

	var/mob/O = owner.current
	if (O)
		to_chat(O, span_cult("Dostępny jest nowy rytuał..."))
	refresh_cult_panel()

/datum/antagonist/cult/proc/ChangeCultistRole(new_role)
	if (!new_role)
		return
	var/datum/team/cult/cult = cult_team
	if ((cultist_role == CULTIST_ROLE_MENTOR) && cult)
		cult.mentor_count--

	cultist_role = new_role

	DropMentorship()

	switch(cultist_role)
		if (CULTIST_ROLE_ACOLYTE)
			message_admins("BLOODCULT: [owner.key]/([owner.name]) zostaje akolitą kultu.")
			log_admin("BLOODCULT: [owner.key]/([owner.name]) has become a cultist acolyte.")
			logo_state = "cult-apprentice-logo"
			FindMentor()
			if (!mentor)
				message_admins("BLOODCULT: [owner.key]/([owner.name]) nie znajduje mentora.")
				log_admin("BLOODCULT: [owner.key]/([owner.name]) couldn't find a mentor.")
		if (CULTIST_ROLE_HERALD)
			message_admins("BLOODCULT: [owner.key]/([owner.name]) zostaje heroldem kultu.")
			log_admin("BLOODCULT: [owner.key]/([owner.name]) has become a cultist herald.")
			logo_state = "cult-logo"
		if (CULTIST_ROLE_MENTOR)
			message_admins("BLOODCULT: [owner.key]/([owner.name]) zostaje mentorem kultu.")
			log_admin("BLOODCULT: [owner.key]/([owner.name]) has become a cultist mentor.")
			logo_state = "cult-master-logo"
			if (cult)
				cult.mentor_count++
		else
			logo_state = "cult-logo"
			cultist_role = CULTIST_ROLE_NONE
	if (owner.current)//refreshing the UI so the current role icon appears on the cult panel button and role change button.
		owner.current.DisplayUI("Cultist Left Panel")
		owner.current.DisplayUI("Cult Panel")
	time_role_changed_last = world.time

/datum/antagonist/cult/proc/DropMentorship()
	if (mentor)
		to_chat(owner.current, span_warning("Kończysz naukę pod okiem: [mentor.owner?.name]."))
		to_chat(mentor.owner?.current, span_warning("[owner.name] kończy u ciebie naukę."))
		message_admins("[owner.key]/([owner.name]) kończy naukę u mentora: [mentor.owner?.name]")
		log_admin("[owner.key]/([owner.name]) has ended their mentorship under [mentor.owner?.name]")
		mentor.acolytes -= src
		mentor = null
	if (acolytes.len > 0)
		for (var/datum/antagonist/cult/acolyte in acolytes)
			to_chat(owner.current, span_warning("Kończysz opiekę nad: [acolyte.owner?.name]."))
			to_chat(acolyte.owner?.current, span_warning("[owner.name] kończy opiekę nad tobą."))
			message_admins("[owner.key]/([owner.name]) kończy opiekę nad akolitą: [acolyte.owner?.name]")
			log_admin("[owner.key]/([owner.name]) has ended their mentorship of [acolyte.owner?.name]")
			acolyte.mentor = null
		acolytes = list()

/datum/antagonist/cult/proc/write_rune(word_to_draw)
	var/mob/living/user = owner.current
	if (!istype(user))
		return

	if (user.incapacitated())
		return

	var/muted = user.occult_muted()
	if (muted)
		to_chat(user, span_danger("Nie potrafisz skupić myśli na słowach Nar'Sie."))
		return

	if(!istype(user.loc, /turf))
		to_chat(user, span_warning("Nie masz tu dość miejsca, by narysować porządną runę."))
		return

	if(istype(user.loc, /turf/open/space))
		to_chat(user, span_warning("Najpierw stań na czymś stabilnym!"))
		return

	var/turf/T = get_turf(user)
	var/obj/effect/new_rune/rune = locate() in T

	if(rune)
		if (rune.invisibility == INVISIBILITY_OBSERVER)
			to_chat(user, span_warning("Wyczuwasz tu obecność ukrytej runy. Musisz ją odsłonić, zanim dopiszesz do niej słowa."))
			return
		else if (rune.word1 && rune.word2 && rune.word3)
			to_chat(user, span_warning("Runa nie może mieć więcej niż 3 słowa."))
			return

	var/datum/rune_word/word = GLOB.rune_words[word_to_draw]
	var/list/rune_blood_data = use_available_blood(user, rune_blood_cost, feedback = verbose)
	if (rune_blood_data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)
		return

	if (verbose)
		if(rune)
			user.visible_message(span_warning("[user] intonuje coś i maluje na podłodze kolejne symbole."), \
					span_warning("Dopisujesz do runy kolejne słowo."), \
					span_warning("Słyszysz intonowanie."))
		else
			user.visible_message(span_warning("[user] zaczyna intonować i malować symbole na podłodze."), \
					span_warning("Zaczynasz rysować runę na podłodze."), \
					span_warning("Słyszysz jakieś intonowanie."))

	if(!user.checkTattoo(TATTOO_SILENT))
		user.whisper("...[word.rune]...")

	if(rune)
		if(rune.word1 && rune.word2 && rune.word3)
			to_chat(user, span_warning("Runa nie może mieć więcej niż 3 słowa."))
			return
	gain_devotion(10, DEVOTION_TIER_0, "write_rune", word.english)
	write_rune_word(get_turf(user), word, rune_blood_data["blood"], caster = user)
	verbose = FALSE


/datum/antagonist/cult/proc/assign_rituals()
	initial_rituals = TRUE
	var/list/valid_rituals = list()

	for (var/datum/bloodcult_ritual/R in possible_rituals)
		if (R.pre_conditions(src))
			valid_rituals += R

	if (valid_rituals.len < 2)
		return

	var/datum/bloodcult_ritual/previous_ritual
	for (var/ritual_slot in rituals)
		if (!valid_rituals.len)
			break
		var/datum/bloodcult_ritual/BR = pick(valid_rituals)
		if ((previous_ritual) && (previous_ritual.ritual_type == BR.ritual_type))
			BR = pick(valid_rituals)//slightly reducing chances of having several rituals of the same type
		else
			previous_ritual = BR
		rituals[ritual_slot] = BR
		possible_rituals -= BR
		valid_rituals -= BR
		BR.init_ritual()

	refresh_cult_panel()

/datum/antagonist/cult/process()
	if (holywarning_cooldown > 0)
		holywarning_cooldown--
	if ((cultist_role == CULTIST_ROLE_ACOLYTE) && !mentor)
		FindMentor()

	if (!cult_team)
		return
	var/datum/team/cult/cult = cult_team
	if (!initial_rituals && cult.countdown_to_first_rituals <= 0)
		assign_rituals()
		var/mob/M = owner.current
		if (M)
			to_chat(M, span_cult("Choć oddanie zdobywasz większością działań kultu, masz teraz do odprawienia także kilka rytuałów. Zajrzyj do panelu kultu."))
	var/mob/living/current = owner.current
	if (!current)
		return
	switch(cult.stage)
		if (BLOODCULT_STAGE_READY)
			current.add_particles(PS_CULT_SMOKE)
			current.add_particles(PS_CULT_SMOKE2)
			if (cult.tear_ritual && cult.tear_ritual.dance_count)
				var/count = clamp(cult.tear_ritual.dance_count / 400, 0.01, 0.6)
				current.adjust_particles(PVAR_SPAWNING, count, PS_CULT_SMOKE)
				current.adjust_particles(PVAR_SPAWNING, count, PS_CULT_SMOKE2)
			else
				if (prob(1))
					current.adjust_particles(PVAR_SPAWNING, 0.05, PS_CULT_SMOKE)
					current.adjust_particles(PVAR_SPAWNING, 0.05, PS_CULT_SMOKE2)
				else
					current.adjust_particles(PVAR_SPAWNING, 0, PS_CULT_SMOKE)
					current.adjust_particles(PVAR_SPAWNING, 0, PS_CULT_SMOKE2)
		if (BLOODCULT_STAGE_MISSED)
			current.remove_particles(PS_CULT_SMOKE)
			current.remove_particles(PS_CULT_SMOKE2)
		if (BLOODCULT_STAGE_ECLIPSE)
			give_cult_eyes()
			current.add_particles(PS_CULT_SMOKE)
			current.add_particles(PS_CULT_SMOKE2)
			current.adjust_particles(PVAR_SPAWNING, 0.6, PS_CULT_SMOKE)
			current.adjust_particles(PVAR_SPAWNING, 0.6, PS_CULT_SMOKE2)
			current.add_particles(PS_CULT_HALO)
			current.adjust_particles(PVAR_ICON_STATE, "cult_halo[get_devotion_rank()]", PS_CULT_HALO)
		if (BLOODCULT_STAGE_DEFEATED)
			current.add_particles(PS_CULT_SMOKE)
			current.add_particles(PS_CULT_SMOKE2)
			current.adjust_particles(PVAR_SPAWNING, 0.19, PS_CULT_SMOKE)
			current.adjust_particles(PVAR_SPAWNING, 0.21, PS_CULT_SMOKE2)
			current.add_particles(PS_CULT_HALO)
			current.adjust_particles(PVAR_COLOR, "#00000066", PS_CULT_HALO)
			current.adjust_particles(PVAR_ICON_STATE, "cult_halo[get_devotion_rank()]", PS_CULT_HALO)
		if (BLOODCULT_STAGE_NARSIE)
			give_cult_eyes()
			current.add_particles(PS_CULT_SMOKE)
			current.add_particles(PS_CULT_SMOKE2)
			current.adjust_particles(PVAR_SPAWNING, 0.6, PS_CULT_SMOKE)
			current.adjust_particles(PVAR_SPAWNING, 0.6, PS_CULT_SMOKE2)
			current.add_particles(PS_CULT_HALO)
			current.adjust_particles(PVAR_ICON_STATE, "cult_halo[get_devotion_rank()]", PS_CULT_HALO)

/datum/antagonist/cult/proc/get_eclipse_increment()
	if(isshade(owner.current) || isobserver(owner.current))
		return -0.05
	switch(get_devotion_rank())
		if (DEVOTION_TIER_0)
			return 0.10
		if (DEVOTION_TIER_1)
			return 0.10 + (devotion-100)*0.000375
		if (DEVOTION_TIER_2)
			return 0.25 + (devotion-500)*0.0003
		if (DEVOTION_TIER_3)
			return 0.40 + (devotion-1000)*0.0001
		if (DEVOTION_TIER_4)
			return 0.50 + (devotion-2000)*0.00005

/// Linijka kultysty w raporcie końca rundy (jak GetScoreboard z vg).
/datum/antagonist/cult/proc/get_scoreboard_line()
	var/mob/M = owner.current
	var/status
	if(!M)
		status = "ciało przepadło"
	else if(M.stat == DEAD)
		status = "nie żyje"
	else
		status = "przeżył"
	var/role_text = ""
	switch(cultist_role)
		if (CULTIST_ROLE_MENTOR)
			role_text = ", mentor"
		if (CULTIST_ROLE_ACOLYTE)
			role_text = ", akolita"
		if (CULTIST_ROLE_HERALD)
			role_text = ", herold"
	var/devotion_color = "#FF0000"
	switch(devotion)
		if (2000 to INFINITY)
			devotion_color = "#00FF00"
		if (1000 to 2000)
			devotion_color = "#88FF00"
		if (500 to 1000)
			devotion_color = "#FFFF00"
		if (100 to 500)
			devotion_color = "#FF8800"
	return "<b>[owner.key]</b> jako <b>[owner.name]</b> ([status][role_text][M && M.real_name != owner.name ? ", jako <b>[M.real_name]</b>" : ""]) - oddanie: <font color='[devotion_color]'>[round(devotion)]</font>"
