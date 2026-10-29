GLOBAL_LIST_INIT(converted_minds, list())

/datum/rune_spell/conversion
	name = "Konwersja"
	desc = "Nieoświeceni ujrzą chwałę Nar-Sie i dostaną szansę dołączenia do kultu, albo zostaną twoimi więźniami."
	desc_talisman = "Użyj, by zdalnie uruchomić runę i obezwładnić kogoś, kto na niej stoi."
	invocation = "Mah'weyh pleggh at e'ntrath!"
	word1 = /datum/rune_word/join
	word2 = /datum/rune_word/blood
	word3 = /datum/rune_word/self
	talisman_absorb = RUNE_CAN_ATTUNE
	page = "Dotykając tej runy, gdy stoi na niej ktoś spoza kultu, powalisz go i nie pozwolisz mu się ruszyć ani mówić, póki słowa Nar-Sie do niego docierają. \
		Rytuał trwa dłużej na wyszkolonej ochronie i niektórych urzędnikach Nanotrasen, ale można go przyspieszyć, nosząc szaty albo zbroję kultu.\
		<br><br>Jeśli cel się zgodzi, a kultystów jest niewielu, zostanie nawrócony i stanie się honorowym kultystą.\
		<br><br>Jeśli jednak cel ma implant lojalności albo kult ma już 9 ludzkich członków, zostanie zamiast tego skrępowany upiornymi więzami. \
		Więcej niż jeden konstrukt danego rodzaju również zmniejsza dozwoloną liczbę ludzkich kultystów.\
		<br><br>Nie próbuj nawracać wszystkich. Najpierw użyj run Jasnowidzenia albo Podróży Astralnej, żeby znaleźć najciekawszych kandydatów.\
		<br><br>Dotknięcie runy ponownie we wczesnej fazie rytuału przełącza go między \"konwersją\" a \"pochwyceniem\", gdybyś chciał kogoś tylko skrępować.\
		<br><br>Dostrajając talizman do tej runy, możesz uruchomić ją zdalnie, ale potem musisz podejść bliżej, inaczej rytuał się przerwie.\
		<br><br>Ta runa zostaje po użyciu, można jej używać wielokrotnie."
	var/remaining = 100
	var/mob/living/carbon/victim = null
	var/flavor_text = 0
	var/success = CONVERSION_NOCHOICE
	var/list/impede_medium = list(
		JOB_NAME_SECURITYOFFICER,
		JOB_NAME_WARDEN,
		JOB_NAME_DETECTIVE,
		JOB_NAME_HEADOFSECURITY,
		JOB_NAME_MASTERATARMS,
		JOB_NAME_HEADOFPERSONNEL,
		)
	var/list/impede_hard = list(
		JOB_NAME_CHAPLAIN,
		JOB_NAME_CAPTAIN,
		)
	var/obj/effect/cult_ritual/conversion/conversion = null

	var/phase = 1
	var/entrapment = FALSE


/datum/rune_spell/conversion/Destroy()
	if(conversion)
		conversion.Die()
		conversion = null
	return ..()

/datum/rune_spell/conversion/update_progbar()//progbar tracks conversion progress instead of paid blood
	if (!progbar)
		progbar = image("icon" = 'aquila/icons/bloodcult/doafter_icon.dmi', "loc" = spell_holder, "icon_state" = "prog_bar_0")
		progbar.pixel_z = 32
		progbar.plane = HUD_PLANE
		progbar.appearance_flags = RESET_COLOR
	progbar.icon_state = "prog_bar_[min(100, round((100-remaining), 10))]"
	return

/datum/rune_spell/conversion/cast()
	var/obj/effect/new_rune/R = spell_holder
	var/mob/converter = activator//trying to fix logs showing the converter as *null*

	R.one_pulse()
	var/turf/T = R.loc
	var/list/targets = list()


	for (var/mob/living/carbon/carbon in T)//all carbons can be converted...but only carbons. no cult silicons. (unless it's April 1st)
		if (!IS_CULTIST(carbon) && carbon.stat != DEAD)//no more corpse conversions!
			targets.Add(carbon)
	if (targets.len > 0)
		victim = pick(targets)
	else
		to_chat(activator, span_warning("Na runie musi stać albo leżeć ktoś, kogo można nawrócić.") )
		qdel(src)
		return

	var/mob/convertee = victim//trying to fix logs showing the victim as *null*

	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	if (!cult)
		message_admins("Kult krwi: odbył się rytuał konwersji... ale nie da się znaleźć frakcji kultu...")//failsafe in case of admin varedit fuckery
		qdel(src)
		return

	update_progbar()
	if (activator.client)
		activator.client.images |= progbar

	//secondly, let's stun our victim and begin the ritual
	to_chat(victim, span_danger("Tajemne energie wzbierają spod twoich [issilicon(victim) ? "siłowników" : "stóp"] i wsiąkają w twoje [issilicon(victim) ? "podwozie" : "ciało"].") )
	victim.Knockdown(5 SECONDS)
	victim.Stun(5 SECONDS)
	if (isalien(victim))
		victim.Paralyze(5 SECONDS)
	victim.overlay_fullscreen("conversionborder", /atom/movable/screen/fullscreen/conversion_border)
	victim.update_fullscreen_alpha("conversionborder", 255, 5)
	conversion = new(T)
	flick("rune_convert_start", conversion)
	for(var/mob/living/M in dview(world.view, T, INVISIBILITY_MAXIMUM))
		if (M.client)
			M.playsound_local(T, 'aquila/sound/bloodcult/convert_start.ogg', 50, 0, -4)


	if (!cult.CanConvert())
		to_chat(activator, span_warning("Kultystów jest już zbyt wielu. [victim] zostanie więźniem.") )

	if (victim.mind)
		if (victim.mind.assigned_role in impede_medium)
			to_chat(victim, span_warning("Twoje oddanie Nanotrasen spowalnia rytuał.") )
			to_chat(activator, span_warning("Ich oddanie Nanotrasen jest silne, rytuał potrwa dłużej.") )

		if (victim.mind.assigned_role in impede_hard)
			var/higher_cause = "Kosmicznemu Jezusowi"
			switch(victim.mind.assigned_role)
				if (JOB_NAME_CAPTAIN)
					higher_cause = "Nanotrasen"
				if (JOB_NAME_CHAPLAIN)
					higher_cause = "wyższemu Bogu"
			to_chat(victim, span_warning("Twoje oddanie [higher_cause] spowalnia rytuał.") )
			to_chat(activator, span_warning("Ich oddanie [higher_cause] jest niezwykłe, rytuał będzie długi.") )

	INVOKE_ASYNC(src, PROC_REF(conversion_ritual), T, cult, converter, convertee)

/// Pętla rytuału (w drafcie spawn())
/datum/rune_spell/conversion/proc/conversion_ritual(turf/T, datum/team/cult/cult, mob/converter, mob/convertee)
	while (remaining > 0)
		if (destroying_self || !spell_holder || !activator || !victim)
			return
		//first let's make sure they're on the rune
		if (victim.loc != T)//Removed() should take care of it, but just in case
			victim.clear_fullscreen("conversionborder", 10)
			for(var/mob/living/M in dview(world.view, T, INVISIBILITY_MAXIMUM))
				if (M.client)
					M.playsound_local(T, 'aquila/sound/bloodcult/convert_abort.ogg', 50, 0, -4)
			conversion.icon_state = ""
			flick("rune_convert_abort", conversion)
			abort(RITUALABORT_REMOVED)
			return

		//and that we're next to them
		if (!spell_holder.Adjacent(activator))
			cancelling--
			if (cancelling <= 0)
				victim.clear_fullscreen("conversionborder", 10)
				for(var/mob/living/M in dview(world.view, T, INVISIBILITY_MAXIMUM))
					if (M.client)
						M.playsound_local(T, 'aquila/sound/bloodcult/convert_abort.ogg', 50, 0, -4)
				conversion.icon_state = ""
				flick("rune_convert_abort", conversion)
				abort(RITUALABORT_GONE)
				return

		else
			for(var/mob/living/M in dview(world.view, T, INVISIBILITY_MAXIMUM))
				if (M.client)
					M.playsound_local(T, 'aquila/sound/bloodcult/convert_process.ogg', 10, 0, -4)
			//then progress through the ritual
			victim.Knockdown(5 SECONDS)
			victim.Stun(5 SECONDS)
			if (isalien(victim))
				victim.Paralyze(5 SECONDS)
			var/progress = 10//10 seconds to reach second phase for a naked cultist
			progress += activator.get_cult_power()//down to 1-2 seconds when wearing cult gear
			var/delay = 0
			if (victim.mind)
				if (victim.mind.assigned_role in impede_medium)
					delay = 1
					progress = progress/2

				if (victim.mind.assigned_role in impede_hard)
					delay = 1
					progress = progress/4

			if (delay)
				progress = clamp(progress, 1, 10)
			remaining -= progress
			update_progbar()

			//spawning some messages
			var/threshold = min(100, round((100-remaining), 10))
			if (flavor_text < 3)
				if (flavor_text == 0 && threshold > 10)//it's ugly but gotta account for the possibility of several messages appearing at once
					to_chat(victim, span_cult("JESTEŚMY KRWIĄ, KTÓRA PULSUJE W TKANCE KOSMOSU") )
					flavor_text++
				if (flavor_text == 1 && threshold > 40)
					to_chat(victim, span_cult("GEOMETRA WZYWA NA KOLEJNĄ UCZTĘ") )
					flavor_text++
				if (flavor_text == 2 && threshold > 70)
					to_chat(victim, span_cult("PRZYJACIELU CZY WROGU, TY TEŻ DOŁĄCZYSZ DO UROCZYSTOŚCI") )
					flavor_text++
		sleep(10)

	if (activator && activator.client)
		activator.client.images -= progbar

	//alright, now the second phase, which always lasts an additional 10 seconds, but no longer requires the proximity of the activator.
	phase = 2
	var/acceptance = "Never"
	victim.Knockdown(15 SECONDS)
	victim.Stun(15 SECONDS)
	if (isalien(victim))
		victim.Paralyze(15 SECONDS)

	if (victim.client)
		if(victim.mind?.assigned_role == JOB_NAME_CHAPLAIN)
			acceptance = "Chaplain"
		else
			// AQUILA - jak w vg: z włączonym kultem w preferencjach zgoda od razu, bez niego gracz wybiera
			acceptance = victim.client.role_preference_enabled(/datum/role_preference/antagonist/blood_cultist) ? "Yes" : "No"

			for(var/obj/item/implant/mindshield/I in victim.implants)
				acceptance = "Implanted"

	if(IS_HERETIC(victim) || is_servant_of_ratvar(victim) || HAS_MIND_TRAIT(victim, TRAIT_UNCONVERTABLE))
		acceptance = "Another God"

	else if (!victim.mind)
		acceptance = "Mindless"

	if (is_banned_from(victim.ckey, ROLE_CULTIST))
		acceptance = "Banned"


	if (!cult.CanConvert())
		acceptance = "Overcrowded"

	if (entrapment)
		acceptance = "Overcrowded"

	//Players with cult enabled in their preferences will always get converted. TBAfor
	//Others get a choice, unless they're cult-banned or have their preferences set to Never (or disconnected), in which case they always die.
	var/conversion_delay = 100
	switch (acceptance)
		if ("Always", "Yes")
			conversion.icon_state = "rune_convert_good"
			to_chat(activator, span_cult("Rytuał od razu się stabilizuje, [victim] wydaje się chętnie pomagać w przygotowaniach do uroczystości.") )
			cult.send_flavour_text_accept(victim, activator)
			success = CONVERSION_ACCEPT
			conversion_delay = 30
		if ("No", "???", "Never")
			if (victim.client)
				to_chat(activator, span_cult("Rytuał wchodzi w ostatnią fazę. Jego koniec zależy teraz od [victim]. Nie musisz już stać obok.") )
				INVOKE_ASYNC(src, PROC_REF(ask_victim))
			else//converting a braindead carbon will always lead to them being captured
				to_chat(activator, span_cult("[victim] nie wydaje się w pełni przytomny. Dokończenie rytuału pozwoli go skrępować.") )
		if ("Implanted")
			if (victim.client)
				to_chat(activator, span_cult("Implant lojalności zakłóca rytuał. Cel nie będzie mógł przyjąć konwersji.") )
				to_chat(victim, span_danger("Twój implant lojalności nie pozwala ci usłyszeć niczego więcej z tego, co mają do powiedzenia.") )
				success = CONVERSION_REFUSE
			else//converting a braindead carbon will always lead to them being captured
				to_chat(activator, span_cult("[victim] nie wydaje się w pełni przytomny. Dokończenie rytuału pozwoli go skrępować.") )
		if ("Chaplain")//Chaplains can never be converted
			if (victim.client)
				to_chat(activator, span_cult("Kapłani nigdy nie pozwolą się nawrócić. Zostanie skrępowany.") )
				to_chat(victim, span_danger("Twoje oddanie Kosmicznemu Jezusowi chroni cię przed pokusami Nar-Sie.") )
				success = CONVERSION_REFUSE
			else//converting a braindead carbon will always lead to them being captured
				to_chat(activator, span_cult("[victim] nie wydaje się w pełni przytomny. Dokończenie rytuału pozwoli go skrępować.") )
		if ("Banned")
			conversion.icon_state = "rune_convert_bad"
			to_chat(activator, span_cult("Rytuał staje się tak niestabilny, że z pewnością całkiem pochłonie [victim]. Nie był nam pisany.") )
			to_chat(victim, span_danger("Tyle że twoje dawne czyny nas rozgniewały. Będziesz przekąską przed ucztą. \[Masz bana na tę rolę\]") )
			success = CONVERSION_BANNED
		if ("Mindless")
			conversion.icon_state = "rune_convert_bad"
			to_chat(activator, span_cult("To bezmyślne stworzenie zostanie złożone w ofierze.") )
			success = CONVERSION_MINDLESS
		if ("Overcrowded")
			to_chat(victim, span_cult("TYLKO ŻE... NIE MA JUŻ WOLNYCH MIEJSC!") )
			success = CONVERSION_OVERCROWDED
			conversion_delay = 30
		if ("Another God")
			to_chat(victim, span_cult("TYLKO ŻE... ON SŁUŻY... INNEMU!") )
			success = CONVERSION_REFUSE

	//since we're no longer checking for the cultist's adjacency, let's finish this ritual without a loop
	sleep(conversion_delay)

	if (destroying_self || !spell_holder || !activator || !victim)
		return

	if (victim.loc != T)//Removed() should take care of it, but just in case
		victim.clear_fullscreen("conversionborder", 10)
		for(var/mob/living/M in dview(world.view, T, INVISIBILITY_MAXIMUM))
			if (M.client)
				M.playsound_local(T, 'aquila/sound/bloodcult/convert_abort.ogg', 50, 0, -4)
		conversion.icon_state = ""
		flick("rune_convert_abort", conversion)
		abort(RITUALABORT_REMOVED)
		return

	if (victim.mind && !(victim.mind in GLOB.converted_minds))
		GLOB.converted_minds += victim.mind
		// AQUILA - bez streamera Spess.TV z Monke

	switch (success)
		if (CONVERSION_ACCEPT)
			conversion.layer = BELOW_OBJ_LAYER
			conversion.plane = GAME_PLANE_UPPER
			victim.clear_fullscreen("conversionborder", 10)
			for(var/mob/living/M in dview(world.view, T, INVISIBILITY_MAXIMUM))
				if (M.client)
					M.playsound_local(T, 'aquila/sound/bloodcult/convert_success.ogg', 75, 0, -4)
			//new cultists get purged of the debuffs
			victim.SetKnockdown(0)
			victim.SetStun(0)
			if (isalien(victim))
				victim.SetParalyzed(0)
			//let's also remove cult cuffs if they have them
			if (istype(victim.handcuffed, /obj/item/restraints/handcuffs/cult))
				victim.dropItemToGround(victim.handcuffed)

			convert(convertee, converter)
			conversion.icon_state = ""

			flick("rune_convert_success", conversion)
			message_admins("BLOODCULT: [key_name(converter)] nawraca [key_name(convertee)].")
			log_admin("BLOODCULT: [key_name(convertee)] has been converted by [key_name(converter)].")
			abort(RITUALABORT_CONVERT)
			return
		if (CONVERSION_NOCHOICE, CONVERSION_REFUSE, CONVERSION_OVERCROWDED)
			conversion.icon_state = ""
			flick("rune_convert_refused", conversion)
			for(var/mob/living/M in dview(world.view, T, INVISIBILITY_MAXIMUM))
				if (M.client)
					M.playsound_local(T, 'aquila/sound/bloodcult/convert_abort.ogg', 75, 0, -4)

			victim.Knockdown(7)
			victim.Stun(6)
			if (isalien(victim))
				victim.Paralyze(8)

			if (victim.mind)
				if (!(victim.mind in cult.previously_made_prisoner))
					cult.previously_made_prisoner |= victim.mind
					var/datum/antagonist/cult/cult_datum = IS_CULTIST(activator)
					cult_datum?.gain_devotion(250, DEVOTION_TIER_3, "made_prisoner", victim)

			//let's start by removing any cuffs they might already have
			if (victim.handcuffed)
				var/obj/item/restraints/handcuffs/cuffs = victim.handcuffed
				victim.dropItemToGround(cuffs)

			var/obj/item/restraints/handcuffs/cult/restraints = new(victim)
			victim.handcuffed = restraints
			restraints.gaoler = IS_CULTIST(converter)
			victim.update_handcuffed()

			if (success == CONVERSION_NOCHOICE)
				if (convertee.mind)//no need to generate logs when capturing mindless monkeys
					to_chat(victim, span_danger("Nie udzieliłeś odpowiedzi na czas, więc automatycznie zostałeś więźniem.") )
					message_admins("BLOODCULT: [key_name(convertee)] nie odpowiada na czas podczas konwersji przez [key_name(converter)].")
					log_admin("BLOODCULT: [key_name(convertee)] has timed-out during conversion by [key_name(converter)].")

				abort(RITUALABORT_NOCHOICE)
			else if (success == CONVERSION_REFUSE)
				message_admins("BLOODCULT: [key_name(convertee)] odrzuca konwersję przez [key_name(converter)].")
				log_admin("BLOODCULT: [key_name(convertee)] has refused conversion by [key_name(converter)].")

				abort(RITUALABORT_REFUSED)
			else
				message_admins("BLOODCULT: [key_name(converter)] bierze [key_name(convertee)] do niewoli, bo kult jest przepełniony.")
				log_admin("BLOODCULT: [key_name(convertee)] was made prisoner by [key_name(converter)] because the cult is overcrowded.")

				abort(RITUALABORT_REFUSED)

		if (CONVERSION_BANNED)

			message_admins("BLOODCULT: [key_name(convertee)] ginie, bo [key_name(converter)] nawraca tę osobę mimo bana na kult.")
			log_admin("BLOODCULT: [key_name(convertee)] died because they were converted by [key_name(converter)] while cult-banned.")
			conversion.icon_state = ""
			flick("rune_convert_failure", conversion)

			//sacrificed victims have all their stuff stored in a coffer that also contains their skull and a cup of their blood, should they have either
			victim.boxify(TRUE, FALSE, "cult")
			abort(RITUALABORT_SACRIFICE)

		if (CONVERSION_MINDLESS)

			conversion.icon_state = ""
			flick("rune_convert_failure", conversion)

			victim.boxify(TRUE, FALSE, "cult")
			abort(RITUALABORT_SACRIFICE)
	victim?.clear_fullscreen("conversionborder", 10)

/// Wybór ofiary: dołączyć do kultu czy zostać więźniem (10 sekund)
/datum/rune_spell/conversion/proc/ask_victim()
	var/mob/living/carbon/asked = victim
	var/answer = tgui_alert(asked, "Kult Nar-Sie ma wobec ciebie wielkie plany, ale jakie dokładnie?", "Masz 10 sekund na decyzję", list("Dołącz do kultu", "Zostań więźniem"), 10 SECONDS)
	if (destroying_self || victim != asked || !answer)
		return
	if (answer == "Dołącz do kultu")
		conversion?.icon_state = "rune_convert_good"
		success = CONVERSION_ACCEPT
		to_chat(asked, span_cult("TO DOBRZE. PODEJDŹ BLIŻEJ. WIELE MUSISZ SIĘ NAUCZYĆ") )
	else
		to_chat(asked, span_danger("TO TEŻ DOBRZE, BO BĘDZIESZ NAS ZABAWIAĆ") )
		success = CONVERSION_REFUSE

/datum/rune_spell/conversion/proc/convert(mob/M, mob/converter)
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	// AQUILA - sprawdzamy przed HandleRecruitedRole, bo ono dopisuje umysł do previously_converted
	var/already_converted = (M.mind in cult?.previously_converted)
	var/datum/antagonist/cult/newCultist = new
	M.mind.add_antag_datum(newCultist)
	if (!cult)
		cult = newCultist.cult_team
	cult?.HandleRecruitedRole(newCultist)
	if (!already_converted)
		var/was_prisoner = (M.mind in cult?.previously_made_prisoner)
		cult?.previously_made_prisoner |= M.mind
		var/datum/antagonist/cult/cult_datum = IS_CULTIST(converter)
		if (was_prisoner)
			cult_datum?.gain_devotion(250, DEVOTION_TIER_4, "converted_prisoner", M)//making someone prisoner already grants 250 devotion on top.
		else
			cult_datum?.gain_devotion(500, DEVOTION_TIER_4, "conversion", M)
	newCultist.conversion["converted"] = activator
	newCultist.update_cult_hud()

/datum/rune_spell/conversion/midcast(mob/add_cultist)
	if (add_cultist != activator)
		return
	if (phase == 1)
		if (entrapment)
			to_chat(add_cultist, span_notice("Wykonujesz znak konwersji, pozwalając ofierze zostać kultystą, jeśli się nadaje.") )
			entrapment = FALSE
		else
			to_chat(add_cultist, span_warning("Wykonujesz znak pochwycenia, który zapewni skrępowanie ofiary.") )
			entrapment = TRUE

/datum/rune_spell/conversion/Removed(mob/M)
	if (victim == M)
		for(var/mob/living/L in dview(world.view, spell_holder.loc, INVISIBILITY_MAXIMUM))
			if (L.client)
				L.playsound_local(spell_holder.loc, 'aquila/sound/bloodcult/convert_abort.ogg', 50, 0, -4)
		conversion.icon_state = ""
		flick("rune_convert_abort", conversion)
		abort(RITUALABORT_REMOVED)

/datum/rune_spell/conversion/cast_talisman()//handled by /obj/item/talisman/proc/trigger instead
	return

/datum/rune_spell/conversion/abort(cause)
	if (victim)
		victim.clear_fullscreen("conversionborder", 10)
		victim = null
	..()

/obj/effect/cult_ritual/conversion
	anchored = 1
	icon = 'aquila/icons/bloodcult/64x64.dmi'
	icon_state = "rune_convert_process"
	pixel_x = -32/2
	pixel_y = -32/2
	plane = ABOVE_LIGHTING_PLANE
	mouse_opacity = 0

/obj/effect/cult_ritual/conversion/proc/Die()
	QDEL_IN(src, 1 SECONDS)
