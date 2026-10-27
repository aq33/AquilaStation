
/datum/rune_spell/tearreality
	secret = TRUE
	name = "Rozdarcie Rzeczywistości"
	desc = "Sprowadź 8 kultystów albo więźniów, by rozpocząć rytuał przywołania Nar-Sie."
	desc_talisman = "Użyj, by rozpocząć rytuał przywołania Nar-Sie tam, gdzie stoisz."
	invocation = "Tok-lyr rqa'nap g'lt-ulotf!"
	word1 = /datum/rune_word/hell
	word2 = /datum/rune_word/join
	word3 = /datum/rune_word/self
	page = ""
	var/atom/blocker
	var/list/dance_platforms = list()
	var/dance_count = 0
	var/dance_target = 240
	var/obj/effect/cult_ritual/dance/dance_manager
	var/image/crystals
	var/image/top_crystal
	var/image/narsie_glint

	var/spawners_sent = FALSE
	var/list/pillar_spawners = list()
	var/list/gateway_spawners = list()

/// Czy wokół runy jest dość miejsca na taniec (pole 3x3). Zwraca FALSE, gdy coś blokuje.
/datum/rune_spell/tearreality/proc/check_dance_area(turf/T)
	var/obj/structure/dance_check/checker = new(T, src)
	var/list/moves_to_do = list(SOUTH, WEST, NORTH, NORTH, EAST, EAST, SOUTH, SOUTH, WEST)
	. = TRUE
	for (var/direction in moves_to_do)
		if (!checker.Move(get_step(checker, direction)))//The checker passes through mobs and non-dense objects, but bumps against dense objects and turfs
			. = FALSE
			break
	qdel(checker)

/datum/rune_spell/tearreality/cast()
	var/obj/effect/new_rune/R = spell_holder
	R.one_pulse()
	var/turf/T = get_turf(R)

	//The most fickle rune there ever was
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	if (!istype(cult))
		to_chat(activator, span_warning("Nie udało się znaleźć frakcji kultu. Coś jest zepsute, zgłoś to adminowi albo przyciskiem zgłaszania błędów."))
		abort()
		return

	switch(cult.stage)
		if (BLOODCULT_STAGE_NORMAL)
			to_chat(activator, span_cult("Runa pulsuje, ale żadne energie nie odpowiadają na jej sygnał."))
			to_chat(activator, span_cult("Zaćmienie nadchodzi, ale do tego czasu ta runa jest bezużyteczna."))
			if (!is_station_level(R.z))
				to_chat(activator, span_cult("Kiedy nadejdzie, spróbuj ponownie <font color='red'>na pokładzie stacji</font>."))
			if (!check_dance_area(T))
				to_chat(activator, span_cult("i <font color='red'>w bardziej otwartym miejscu</font>."))
			abort()
			return

		if (BLOODCULT_STAGE_MISSED)
			to_chat(activator, span_cult("Runa pulsuje, ale żadne energie nie odpowiadają na jej sygnał."))
			to_chat(activator, span_cult("Okazja minęła razem z Zaćmieniem. Opuść tę stację, by spróbować innego dnia."))
			abort()
			return

		if (BLOODCULT_STAGE_ECLIPSE)
			to_chat(activator, span_cult("Krwawy Kamień został już wzniesiony! To nie czas na tę runę."))
			abort()
			return

		if (BLOODCULT_STAGE_DEFEATED)
			to_chat(activator, span_cult("Runa pulsuje, ale żadne energie nie odpowiadają na jej sygnał."))
			to_chat(activator, span_cult("Po upadku Krwawego Kamienia zasłona w tym rejonie kosmosu całkiem się zrosła. Inny kult spróbuje kiedyś na innej stacji."))
			abort()
			return

		if (BLOODCULT_STAGE_NARSIE)
			to_chat(activator, span_cult("Rozdarcie już zostało otwarte. Chwała Geometrze w ten najbardziej przeklęty dzień!"))
			abort()
			return

	if (cult.stage != BLOODCULT_STAGE_READY)
		to_chat(activator, span_warning("Frakcja kultu jest w nieustalonym etapie. Coś jest zepsute, zgłoś to adminowi albo przyciskiem zgłaszania błędów."))
		abort()
		return

	if (!is_station_level(R.z))
		to_chat(activator, span_cult("Runa pulsuje, ale żadne energie nie odpowiadają na jej sygnał."))
		to_chat(activator, span_cult("Spróbuj ponownie <font color='red'>na pokładzie stacji</font>."))
		abort()
		return

	if (cult.tear_ritual)
		var/obj/effect/new_rune/U = cult.tear_ritual.spell_holder
		to_chat(activator, span_cult("Runa pulsuje, ale żadne energie nie odpowiadają na jej sygnał."))
		to_chat(activator, span_cult("Wygląda na to, że gdzieś otwiera się już inne rozdarcie... <font color='red'>w kierunku: [dir2text(get_dir(R, U))]</font>."))
		abort()
		return

	if (!check_dance_area(T))
		if (blocker)
			to_chat(activator, span_cult("Pobliski obiekt ([blocker]) przeszkodzi w rytuale."))
		to_chat(activator, span_cult("Spróbuj ponownie <font color='red'>w bardziej otwartym miejscu</font>."))
		abort()
		return

	//Alright now we can get down to business
	cult.tear_ritual = src
	R.overlays.len = 0
	R.icon = 'aquila/icons/bloodcult/cult_96x96.dmi'
	R.pixel_x = -32
	R.pixel_y = -32
	R.layer = SIGIL_LAYER
	R.plane = GAME_PLANE
	R.set_light(1, 2, COLOR_RED)

	// AQUILA - bez znacznika holomapy

	anim(target = R.loc, a_icon = 'aquila/icons/bloodcult/cult_96x96.dmi', flick_anim = "rune_tearreality_activate", lay = SIGIL_LAYER, offX = -32, offY = -32, plane = GAME_PLANE)

	var/list/platforms_to_spawn = list(NORTH, NORTHEAST, EAST, SOUTHEAST, SOUTH, SOUTHWEST, WEST, NORTHWEST)
	for (var/direction in platforms_to_spawn)
		if (!destroying_self)
			var/turf/U = get_step(R, direction)
			shadow(U, R.loc)
			var/obj/effect/cult_ritual/dance_platform/platform = new(U, src)
			dance_platforms += platform
			sleep(1)

	if (!destroying_self)
		message_admins("[key_name(activator)] is preparing the Tear Reality ritual at [T.loc] ([T.x], [T.y], [T.z]) [ADMIN_JMP(T)].")
		for (var/datum/mind/mind in cult.members)
			var/mob/living/M = mind.current
			if (!M)
				continue
			to_chat(M, span_cult("Rytuał rozdarcia rzeczywistości i wciągnięcia stacji do królestwa Nar-Sie odbywa się teraz w miejscu: <font color='red'>[T.loc]</font>."))
			to_chat(M, span_cult("Do rozpoczęcia rytuału potrzeba łącznie 8 osób, kultystów albo więźniów. Udaj się tam, by pomóc go zacząć, a potem go chronić."))

		var/image/I_circle = image('aquila/icons/bloodcult/cult_96x96.dmi', "rune_tearreality")
		SET_PLANE_EXPLICIT(I_circle, GAME_PLANE, spell_holder)
		I_circle.layer = SIGIL_LAYER
		I_circle.appearance_flags |= RESET_COLOR
		var/image/I_crystals = image('aquila/icons/bloodcult/cult_96x96.dmi', "tear_stones")
		SET_PLANE_EXPLICIT(I_crystals, GAME_PLANE, spell_holder)
		I_crystals.layer = SIGIL_LAYER
		I_crystals.appearance_flags |= RESET_COLOR
		R.overlays += I_circle
		R.overlays += I_crystals
		custom_rune = TRUE

		crystals = image('aquila/icons/bloodcult/cult_96x96.dmi', "tear_stones_[min(8, 1+(dance_count/30))]")
		SET_PLANE_EXPLICIT(crystals, GAME_PLANE, spell_holder)

		top_crystal = image('aquila/icons/bloodcult/cult_96x96.dmi', "tear_stones_top")
		SET_PLANE_EXPLICIT(top_crystal, GAME_PLANE, spell_holder)
		top_crystal.layer = SIGIL_LAYER + 0.1
		top_crystal.appearance_flags |= RESET_COLOR
		R.overlays += top_crystal

		narsie_glint = image('aquila/icons/bloodcult/cult.dmi', "narsie_glint")
		SET_PLANE_EXPLICIT(narsie_glint, ABOVE_LIGHTING_PLANE, spell_holder)
		narsie_glint.alpha = 0
		narsie_glint.pixel_x = 32
		narsie_glint.pixel_y = 32
		R.overlays += narsie_glint


/datum/rune_spell/tearreality/cast_talisman() //Tear Reality talismans create an invisible summoning rune beneath the caster's feet.
	var/obj/effect/new_rune/R = new(get_turf(activator))
	R.icon_state = "temp"
	R.active_spell = new type(activator, R)
	qdel(src)

/datum/rune_spell/tearreality/midcast(mob/add_cultist)
	to_chat(add_cultist, span_cult("Stańcie w okolicznych kręgach razem z innymi kultystami i schwytanymi więźniami, aż każde miejsce zostanie zajęte."))

/datum/rune_spell/tearreality/abort(cause)
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	if (cult && (cult.tear_ritual == src))
		cult.tear_ritual = null
	if (dance_manager)
		QDEL_NULL(dance_manager)

	var/obj/effect/new_rune/R = spell_holder
	if (R)
		R.set_light(0)
		R.icon = 'aquila/icons/bloodcult/deityrunes.dmi'
		R.pixel_x = 0
		R.pixel_y = 0
		R.layer = initial(R.layer)
		R.plane = GAME_PLANE

	for(var/obj/effect/cult_ritual/dance_platform/platform in dance_platforms)
		qdel(platform)

	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(cancel_tear_pillars), pillar_spawners.Copy())

	for(var/obj/effect/cult_ritual/CR in gateway_spawners)
		qdel(CR)

	..()

/// Wygasza kolejno filary rozdarcia (w drafcie spawn() z sleep(1))
/proc/cancel_tear_pillars(list/pillars)
	for(var/obj/effect/cult_ritual/tear_spawners/pillar_spawner/CR in pillars)
		CR.cancel()
		sleep(1)

/datum/rune_spell/tearreality/proc/dancer_check(mob/living/C)
	var/obj/effect/new_rune/R = spell_holder
	if (dance_platforms.len <= 0)
		return
	if (!isturf(R.loc))//moved inside the blood stone
		return
	if (dance_manager && C)
		dance_manager.dancers |= C
		if(IS_CULTIST(C))
			C.say("Tok-lyr rqa'nap g'lt-ulotf!")
		else
			to_chat(C, span_cult("Macki przesuwają się i zmuszają twoje ciało, by poruszało się razem z nimi, w jakimś tańcu."))
		return
	for(var/obj/effect/cult_ritual/dance_platform/platform in dance_platforms)
		if (!platform.dancer)
			return

	//full dancers!
	var/turf/T = get_turf(R)

	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	cult.twister = TRUE

	if (!spawners_sent)
		spawners_sent = TRUE
		new /obj/effect/cult_ritual/tear_spawners/vertical_spawner(T, src)
		new /obj/effect/cult_ritual/tear_spawners/vertical_spawner/up(T, src)
		new /obj/effect/cult_ritual/tear_spawners/horizontal_spawner/left(T, src)
		new /obj/effect/cult_ritual/tear_spawners/horizontal_spawner/right(T, src)

	dance_manager = new(T)

	for(var/obj/effect/cult_ritual/dance_platform/platform in dance_platforms)
		dance_manager.extras += platform
		platform.dance_manager = dance_manager
		if (platform.dancer)
			dance_manager.dancers += platform.dancer
			if(IS_CULTIST(platform.dancer))
				platform.dancer.say("Tok-lyr rqa'nap g'lt-ulotf!")
			else
				to_chat(platform.dancer, span_cult("Macki przesuwają się i zmuszają twoje ciało, by poruszało się razem z nimi, w jakimś tańcu."))

	dance_manager.tear = src
	dance_manager.we_can_dance()

/datum/rune_spell/tearreality/proc/update_crystals()
	var/obj/effect/new_rune/R = spell_holder
	R.overlays -= crystals
	R.overlays -= top_crystal
	R.overlays -= narsie_glint
	crystals.icon_state = "tear_stones_[min(8, 1+round(dance_count/30))]"
	top_crystal.icon_state = "tear_stones_1"
	narsie_glint.alpha = max(0, (dance_count-105)*2)//Nar-Sie's eyes become about visible half-way through the dance
	top_crystal.appearance_flags &= ~RESET_COLOR
	R.overlays += crystals
	R.overlays += top_crystal
	if (isturf(R.loc))
		if (dance_count >= dance_target)// DANCE IS OVER!!
			var/datum/team/cult/cult = locate_team(/datum/team/cult)
			if (cult && !cult.bloodstone)
				var/obj/structure/cult/bloodstone/blood_stone = new(R.loc)
				cult.bloodstone = blood_stone
				cult.stage(BLOODCULT_STAGE_ECLIPSE)
				R.mouse_opacity = 0
				R.forceMove(blood_stone)//keeping the rune safe inside the bloodstone
				QDEL_NULL(dance_manager)
				blood_stone.flashy_entrance(src)
		else
			R.overlays += narsie_glint

/datum/rune_spell/tearreality/proc/pillar_update(update_level)
	for (var/obj/effect/cult_ritual/tear_spawners/pillar_spawner/PS in pillar_spawners)
		PS.execute(update_level)

	for (var/obj/effect/cult_ritual/tear_spawners/gateway_spawner/GS in gateway_spawners)
		GS.execute(update_level)

/datum/rune_spell/tearreality/proc/lost_dancer()
	for(var/obj/effect/cult_ritual/dance_platform/platform in dance_platforms)
		if (platform.dancer)
			return
	dance_count = 0
	QDEL_NULL(dance_manager)
	var/obj/effect/new_rune/R = spell_holder
	R.overlays -= crystals
	R.overlays -= top_crystal
	top_crystal.icon_state = "tear_stones_top"
	top_crystal.appearance_flags |= RESET_COLOR
	R.overlays += top_crystal

/datum/rune_spell/tearreality/proc/dance_increment(mob/living/L)
	if (dance_manager)
		var/increment = 0.5
		if (iscarbon(L))
			var/mob/living/carbon/C = L
			if (istype(C.handcuffed, /obj/item/restraints/handcuffs/cult))
				increment += 0.5
			increment += (C.get_cult_power()) / 100

			var/obj/item/candle/blood/candle
			if (istype(C.get_active_held_item(), /obj/item/candle/blood))
				candle = C.get_active_held_item()
			else if (istype(C.get_inactive_held_item(), /obj/item/candle/blood))
				candle = C.get_inactive_held_item()
			if (candle && candle.lit)
				increment += 0.5
		dance_count += increment
