GLOBAL_LIST_INIT(blood_communion, list())
////////////////////////////////////////////////////////////////////
//																  //
//					BLOODCULT - CULTIST							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_cultist
	uniqueID = "Cultist"
	sub_uis_to_spawn = list(
		/datum/mind_ui/bloodcult_cultist_panel,
		/datum/mind_ui/bloodcult_left_panel,
		/datum/mind_ui/bloodcult_right_panel,
		)
	display_with_parent = TRUE
	y = "BOTTOM"

/datum/mind_ui/bloodcult_cultist/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(IS_CULTIST(M))
		return TRUE
	return FALSE


////////////////////////////////////////////////////////////////////
//																  //
//					BLOODCULT - RUNEDRAW						  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_cultist_panel
	uniqueID = "Cultist Panel"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/hoverable/draw_runes_manual,
		/obj/abstract/mind_ui_element/hoverable/draw_runes_guided,
		/obj/abstract/mind_ui_element/hoverable/erase_runes,
		/obj/abstract/mind_ui_element/hoverable/movable/cultist,
		)
	sub_uis_to_spawn = list(
		/datum/mind_ui/bloodcult_runes,
		)
	display_with_parent = TRUE
	offset_layer = MIND_UI_GROUP_C
	y = "BOTTOM"

/datum/mind_ui/bloodcult_cultist_panel/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(IS_CULTIST(M) && iscarbon(M))
		return TRUE
	return FALSE


//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/draw_runes_manual
	name = "Kreśl runy ręcznie"
	desc = "(1 KREW ZA SŁOWO) Użyj dostępnej krwi, by zapisać słowa. Trzy słowa tworzą runę."
	icon = 'aquila/icons/bloodcult/bloodcult/32x32.dmi'
	icon_state = "rune_manual"
	layer = MIND_UI_BUTTON
	offset_x = 111
	offset_y = 39
	mouse_opacity = 1

/obj/abstract/mind_ui_element/hoverable/draw_runes_manual/Click()
	flick("rune_manual-click", src)
	var/mob/M = GetUser()
	if (M)
		var/datum/antagonist/cult/cult_datum = M.mind?.has_antag_datum(/datum/antagonist/cult)
		if (cult_datum)
			cult_datum.verbose = TRUE
		M.DisplayUI("Bloodcult Runes")

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/draw_runes_guided
	name = "Kreśl runę z przewodnikiem"
	desc = "(1 KREW ZA SŁOWO) Użyj dostępnej krwi, by zapisać słowa. Trzy słowa tworzą runę. Daje dostęp do listy znanych run."
	icon = 'aquila/icons/bloodcult/bloodcult/32x32.dmi'
	icon_state = "rune_guide"
	layer = MIND_UI_BUTTON
	offset_x = 111
	offset_y = 39
	mouse_opacity = 1


/obj/abstract/mind_ui_element/hoverable/draw_runes_guided/Appear()
	..()
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	if (cult.stage == BLOODCULT_STAGE_DEFEATED)
		icon_state = "rune_guide-broken"
		hover_state = FALSE


/obj/abstract/mind_ui_element/hoverable/draw_runes_guided/Click()
	if (!hover_state)
		return
	flick("rune_guide-click", src)
	var/mob/M = GetUser()
	if (M)

		var/list/available_runes = list()
		var/i = 1
		for(var/blood_spell in subtypesof(/datum/rune_spell))
			var/datum/rune_spell/instance = blood_spell
			if (initial(instance.secret))
				continue
			available_runes.Add("[initial(instance.name)] - \Roman[i]")
			available_runes["[initial(instance.name)] - \Roman[i]"] = instance
			i++
		var/spell_name = input(M, "Przypomnij sobie, jak nakreślić wybraną runę.", "Kreśl runę z przewodnikiem", null) as null|anything in available_runes

		if (spell_name)
			for(var/datum/mind_ui/bloodcult_runes/BR in parent.subUIs)
				BR.queued_rune = available_runes[spell_name]

				var/datum/antagonist/cult/cult_datum = M.mind?.has_antag_datum(/datum/antagonist/cult)
				if (cult_datum)
					cult_datum.verbose = TRUE
				M.DisplayUI("Bloodcult Runes")
				break

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/erase_runes
	name = "Zetrzyj runę"
	desc = "Usuwa ostatnie zapisane słowo runy, na której stoisz."
	icon = 'aquila/icons/bloodcult/bloodcult/16x32.dmi'
	icon_state = "rune_erase"
	layer = MIND_UI_BUTTON
	offset_x = 95
	offset_y = 39
	mouse_opacity = 1

/obj/abstract/mind_ui_element/hoverable/erase_runes/Click()
	flick("rune_erase-click", src)
	var/mob/M = GetUser()
	if (M)
		var/datum/antagonist/cult/cult_datum = M.mind?.has_antag_datum(/datum/antagonist/cult)
		if (cult_datum)
			cult_datum.erase_rune()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/movable/cultist
	name = "Przesuń interfejs (kliknij i przeciągnij)"
	icon = 'aquila/icons/bloodcult/bloodcult/16x32.dmi'
	icon_state = "rune_move"
	layer = MIND_UI_BUTTON
	offset_x = 143
	offset_y = 39
	mouse_opacity = 1

	move_whole_ui = TRUE

	const_offset_y = -32
	const_offset_x = -16


//////////////////////////////////////////////////Valid//////////////////
//																  //
//					BLOODCULT - RIGHT PANEL						  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_right_panel
	uniqueID = "Cultist Right Panel"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/bloodcult_spells_background,
		/obj/abstract/mind_ui_element/bloodcult_spells_background_artificer,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_devotion_counter,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_devotion_counter/solo,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/pool,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/dagger,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/talisman,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/sigil,
		/obj/abstract/mind_ui_element/hoverable/movable/cult_spells,
		)

	sub_uis_to_spawn = list(
		/datum/mind_ui/hex_controller/first,
		/datum/mind_ui/hex_controller/second,
		)


	display_with_parent = TRUE
	offset_layer = MIND_UI_GROUP_C

/datum/mind_ui/bloodcult_right_panel/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(IS_CULTIST(M))
		return TRUE
	return FALSE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/bloodcult_spells_background
	name = "Moce kultu"
	icon = 'aquila/icons/bloodcult/bloodcult/32x121.dmi'
	icon_state = "powers_bg"
	offset_x = 192
	offset_y = -96
	layer = MIND_UI_BACK

/obj/abstract/mind_ui_element/bloodcult_spells_background/CanAppear()
	var/mob/living/M = GetUser()
	return iscarbon(M)

/obj/abstract/mind_ui_element/bloodcult_spells_background/Appear()
	if(!CanAppear())
		invisibility = 101
		return
	..()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/bloodcult_spells_background_artificer
	name = "Panel sterowania Hexami"
	icon = 'aquila/icons/bloodcult/bloodcult/32x121.dmi'
	icon_state = "artificer_bg"
	offset_x = 192
	offset_y = -96
	layer = MIND_UI_BACK

/obj/abstract/mind_ui_element/bloodcult_spells_background_artificer/CanAppear()
	var/mob/living/M = GetUser()
	return istype(M, /mob/living/simple_animal/hostile/construct/builder/perfect)

/obj/abstract/mind_ui_element/bloodcult_spells_background_artificer/Appear()
	if(!CanAppear())
		invisibility = 101
		return
	..()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_devotion_counter
	name = "Oddanie"
	icon = 'aquila/icons/bloodcult/bloodcult/32x32.dmi'
	icon_state = "devotion_counter"
	offset_x = 192
	offset_y = -110
	layer = MIND_UI_BACK+0.5

	hover_state = FALSE
	element_flags = MINDUI_FLAG_TOOLTIP|MINDUI_FLAG_PROCESSING
	tooltip_title = "Oddanie"
	tooltip_content = "Działania kultu generują oddanie, które przyspiesza nadejście Zaćmienia i nagradza cię nowymi mocami.<br><br>Działania kultu to m.in. używanie większości run i ranienie żywych istot bronią kultu.<br><br>Niektóre działania dają mniej oddania po przekroczeniu pewnego progu. Eksperymentuj i przekonaj się sam."
	tooltip_theme = "radial-cult"

/obj/abstract/mind_ui_element/hoverable/bloodcult_devotion_counter/CanAppear()
	var/mob/living/M = GetUser()
	if (iscarbon(M))
		return TRUE
	else if (istype(M, /mob/living/simple_animal/hostile/construct/builder/perfect))
		return TRUE
	return FALSE

/obj/abstract/mind_ui_element/hoverable/bloodcult_devotion_counter/Appear()
	if(!CanAppear())
		invisibility = 101
		return
	..()

/obj/abstract/mind_ui_element/hoverable/bloodcult_devotion_counter/process()
	if (invisibility == 101)
		return
	UpdateIcon()

/obj/abstract/mind_ui_element/hoverable/bloodcult_devotion_counter/UpdateIcon()
	overlays.len = 0
	var/datum/antagonist/cult/cult_datum = parent.mind?.has_antag_datum(/datum/antagonist/cult)
	var/devotion = min(9999, cult_datum.devotion)
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	if ((cult.stage == BLOODCULT_STAGE_DEFEATED) || (cult.stage == BLOODCULT_STAGE_NARSIE))
		overlays += String2Image("[add_zero(devotion, 4)]", _color = "#FF0000", _pixel_x = 4, _pixel_y = 9)
	else
		overlays += String2Image("[add_zero(devotion, 4)]", _color = "#FFFFFF", _pixel_x = 4, _pixel_y = 9)


//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_devotion_counter/solo
	icon_state = "devotion_counter_solo"
	offset_y = -92

/obj/abstract/mind_ui_element/hoverable/bloodcult_devotion_counter/solo/CanAppear()
	return !(..())//cultists get that one if they're neither carbon type nor artificers

//////////////////////

/obj/abstract/mind_ui_element/hoverable/bloodcult_spell
	icon = 'aquila/icons/bloodcult/bloodcult/24x24.dmi'
	icon_state = "blank"
	offset_x = 196
	invisibility = 101 	// Invisible by default
	layer = MIND_UI_BUTTON

	var/required_tattoo
	var/image/spell_overlay

/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/CanAppear()
	if(!required_tattoo)
		return TRUE
	var/mob/living/M = GetUser()
	if(M.checkTattoo(required_tattoo))
		return iscarbon(M)
	return FALSE

/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/Appear()
	if(!CanAppear())
		invisibility = 101
		return
	..()

/////////////////////////////////////////

/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/pool
	name = "Wspólna pula krwi"
	offset_y = -87
	required_tattoo = TATTOO_POOL
	icon_state = "power_pool"


/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/pool/UpdateIcon(appear = FALSE)
	var/mob/living/M = GetUser()
	var/datum/antagonist/cult/cult_datum = M.mind?.has_antag_datum(/datum/antagonist/cult)
	icon_state = "power_pool[cult_datum.blood_pool ? "" : "_off"]"
	base_icon_state = icon_state

	var/pool_current = 0
	for (var/datum/antagonist/cult/listed_datum in GLOB.blood_communion)
		if (listed_datum.blood_pool && listed_datum.owner && listed_datum.owner.current && iscarbon(listed_datum.owner.current) && !listed_datum.owner.current.stat == DEAD)
			pool_current++
	overlays.len = 0
	overlays += String2Image("[pool_current]", _pixel_x = 2, _pixel_y = 1)

/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/pool/Click()
	var/mob/living/M = GetUser()
	var/datum/antagonist/cult/cult_datum = M.mind?.has_antag_datum(/datum/antagonist/cult)

	cult_datum.blood_pool = !cult_datum.blood_pool

	for (var/datum/antagonist/cult/listed_cult in GLOB.blood_communion)
		listed_cult.owner.DisplayUI("Cultist Right Panel")


	if (cult_datum.blood_pool)
		to_chat(M, span_warning("Wracasz do wspólnej puli krwi. Koszty krwi są nieco mniejsze i dzielą się między ciebie a innych kultystów.") )
	else
		to_chat(M, span_warning("Opuszczasz wspólną pulę krwi. Od teraz sam płacisz koszty krwi.") )
	UpdateIcon()

/////////////////////////////////////////

/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/talisman
	name = "Runiczna skóra"
	offset_y = -31
	required_tattoo = TATTOO_RUNESTORE
	icon_state = "power_runic"

	var/obj/item/talisman/talisman

/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/talisman/UpdateIcon(appear = FALSE)
	overlays.len = 0

	if(talisman)
		var/image/I = image('aquila/icons/bloodcult/bloodcult/32x32.dmi', src, "blank")
		I.appearance = talisman.appearance
		I.layer = FLOAT_LAYER
		I.plane = FLOAT_PLANE
		I.pixel_x = -2
		I.pixel_y = -5
		overlays += I
		overlays += "power_runic-over"

/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/talisman/Click()
	var/mob/living/M = GetUser()

	if(talisman)
		talisman.trigger(M)
	else if(istype(M.get_active_held_item(), /obj/item/talisman))
		var/obj/item/talisman/T = M.get_active_held_item()
		if(T.spell_type)
			M.dropItemToGround(T)
			T.linked_ui = src
			T.forceMove(M)
			talisman = T
	else
		to_chat(M, span_warning("Trzymaj nasycony talizman w aktywnej ręce, by stopić go ze skórą.") )
	UpdateIcon()


/////////////////////////////////////////



/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/dagger
	name = "Krwawy sztylet"
	offset_y = -59
	required_tattoo = TATTOO_DAGGER
	icon_state = "power_dagger"

	var/obj/item/melee/blood_dagger/dagger

/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/dagger/Click()

	var/mob/living/carbon/user = GetUser()

	if(!dagger)  // dagger not pulled out

		if (user.occult_muted())
			to_chat(user, span_warning("Próbujesz uchwycić swoją krew, ale nie potrafisz nadać jej kształtu sztyletu.") )
			return
		var/list/data = use_available_blood(user, 5)
		if (data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)
			return 0
		var/dagger_color = user.get_blood_color() // AQUILA - u nas kolor krwi bierzemy z get_blood_color()

		var/good_hand
		if(ishuman(user))
			var/mob/living/carbon/human/H = user


			if(user.has_active_hand())
				good_hand = H.active_hand_index

		if(good_hand)
			user.dropItemToGround(user.get_active_held_item())
			var/obj/item/melee/blood_dagger/BD = new (user)
			BD.originator = user
			BD.linked_ui = src
			dagger = BD
			if (dagger_color != COLOR_BLOOD)
				BD.icon_state += "-color"
				BD.color = dagger_color
			if(user.put_in_hand(BD, good_hand))
				user.visible_message(span_warning("[user] ściska krew w dłoni, a ta przybiera kształt sztyletu!") ,
					span_warning("Ściskasz krew w dłoni, a ta przybiera kształt sztyletu.") )
				playsound(user, 'aquila/sound/bloodcult/bloodyslice.ogg', 30, 0, -2)

	else
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if (!cult_has_no_blood(H)) // AQUILA - draft miał tu odwrócony warunek, w vg: !(H.species.flags & NO_BLOOD)
				to_chat(user, span_notice("Chowasz [dagger] z powrotem do ciała[dagger.stacks ? " razem ze skradzioną krwią" : ""].") )
				H.blood_volume += 5 + dagger.stacks * 5
			else
				to_chat(user, span_notice("Chowasz [dagger] do ciała, ale krew nie znajduje naczyń, które mogłaby wypełnić.") )
		else
			to_chat(user, span_notice("Chowasz [dagger] do ciała.") )
		dagger.absorbed = 1
		playsound(user, 'aquila/sound/bloodcult/bloodyslice.ogg', 30, 0, -2)
		qdel(dagger)

	UpdateIcon()

/////////////////////////////////////////

/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/sigil
	name = "Pieczęć skrótu"
	offset_y = -3
	icon_state = "power_sigil"
	required_tattoo = TATTOO_SHORTCUT

/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/sigil/Click()
	var/mob/living/M = GetUser()

	to_chat(M, span_notice("Kliknij sąsiednią ścianę, by wyrysować na niej pieczęć.") )

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/movable/cult_spells
	name = "Przesuń interfejs (kliknij i przeciągnij)"
	icon = 'aquila/icons/bloodcult/bloodcult/16x32.dmi'
	icon_state = "rune_move"
	layer = MIND_UI_BUTTON
	offset_x = 224
	offset_y = -96
	mouse_opacity = 1

	move_whole_ui = TRUE

	const_offset_y = -18
	const_offset_x = -16

////////////////////////////////////////////////////////////////////
//																  //
//					BLOODCULT - LEFT PANEL						  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_left_panel
	uniqueID = "Cultist Left Panel"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/hoverable/bloodcult_panel,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_help,
		)
	sub_uis_to_spawn = list(
		/datum/mind_ui/bloodcult_panel,
		/datum/mind_ui/bloodcult_help,
		)
	display_with_parent = TRUE
	x = "LEFT"

/datum/mind_ui/bloodcult_left_panel/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(IS_CULTIST(M))
		return TRUE
	return FALSE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_panel
	name = "Panel kultu"
	icon = 'aquila/icons/bloodcult/bloodcult/32x32.dmi'
	icon_state = "role"
	offset_x = 6
	offset_y = -92

	var/image/click_me

/obj/abstract/mind_ui_element/hoverable/bloodcult_panel/New()
	..()
	click_me = image(icon, src, "click")
	click_me.layer = MIND_UI_FRONT
	animate(click_me, pixel_y = 16 , time = 7, loop = -1, easing = SINE_EASING)
	animate(pixel_y = 8, time = 7, loop = -1, easing = SINE_EASING)

/obj/abstract/mind_ui_element/hoverable/bloodcult_panel/Click()
	flick("role-click", src)

	var/datum/mind_ui/bloodcult_panel/cult_panel = locate() in parent.subUIs
	if(cult_panel)
		cult_panel.Display()

/obj/abstract/mind_ui_element/hoverable/bloodcult_panel/UpdateIcon()
	var/mob/M = GetUser()
	if (M)
		if (M.client)
			M.client.images -= click_me
		var/datum/antagonist/cult/cult_datum = M.mind?.has_antag_datum(/datum/antagonist/cult)
		if (cult_datum)
			overlays.len = 0
			switch(cult_datum.cultist_role)
				if (CULTIST_ROLE_NONE)
					if (M.client)
						M.client.images += click_me
				if (CULTIST_ROLE_ACOLYTE)
					overlays += "role_acolyte"
				if (CULTIST_ROLE_HERALD)
					overlays += "role_herald"
				if (CULTIST_ROLE_MENTOR)
					overlays += "role_mentor"

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_help
	name = "Jak być kultystą?"
	icon = 'aquila/icons/bloodcult/bloodcult/32x32.dmi'
	icon_state = "help"
	offset_x = 6
	offset_y = -119
	var/clicked = FALSE

	var/image/click_me

/obj/abstract/mind_ui_element/hoverable/bloodcult_help/New()
	..()
	click_me = image(icon, src, "click")
	animate(click_me, pixel_y = 16 , time = 7, loop = -1, easing = SINE_EASING)
	animate(pixel_y = 8, time = 7, loop = -1, easing = SINE_EASING)

/obj/abstract/mind_ui_element/hoverable/bloodcult_help/Appear()
	var/mob/M = GetUser()
	if (M)
		var/datum/antagonist/cult/cult_datum = M.mind?.has_antag_datum(/datum/antagonist/cult)
		if (M.client)
			M.client.images -= click_me
		if (cult_datum)
			if (cult_datum.cultist_role != CULTIST_ROLE_ACOLYTE)
				invisibility = 101	// We only appear to Acolytes
			else
				..()
				if (!cult_datum.mentor && !clicked && M.client)
					M.client.images += click_me

/obj/abstract/mind_ui_element/hoverable/bloodcult_help/Click()
	flick("help-click", src)
	if (!clicked)
		clicked = TRUE
		var/mob/M = GetUser()
		if (M)
			if (M.client)
				M.client.images -= click_me
	var/datum/mind_ui/bloodcult_help/tooltip = locate() in parent.subUIs
	if(tooltip)
		tooltip.Display()


////////////////////////////////////////////////////////////////////
//																  //
//					BLOODCULT - MAIN PANEL						  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_panel
	uniqueID = "Cult Panel"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/bloodcult_panel_background,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_panel_close,
		/obj/abstract/mind_ui_element/hoverable/movable/bloodcult_panel_move,

		/obj/abstract/mind_ui_element/bloodcult_eclipse_timer_count,
		/obj/abstract/mind_ui_element/bloodcult_eclipse_gauge,
		/obj/abstract/mind_ui_element/bloodcult_eclipse_timer_front,

		/obj/abstract/mind_ui_element/hoverable/bloodcult_eclipse_rate,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_total_devotion,

		/obj/abstract/mind_ui_element/bloodcult_cultist_slot_manager,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_cap,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/artificer,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/wraith,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/juggernaut,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_soulblades,
		/obj/abstract/mind_ui_element/bloodcult_soulblades_count,

		/obj/abstract/mind_ui_element/hoverable/bloodcult_role,
		/obj/abstract/mind_ui_element/bloodcult_your_role,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_help_other,
		)
	sub_uis_to_spawn = list(
		/datum/mind_ui/bloodcult_role,
		/datum/mind_ui/bloodcult_rituals,
		/datum/mind_ui/bloodcult_ritual_narsie,
		)
	display_with_parent = FALSE

	var/list/cultist_slots = list()

/datum/mind_ui/bloodcult_panel/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(IS_CULTIST(M))
		return TRUE
	return FALSE

/datum/mind_ui/bloodcult_panel/SpawnElements()
	..()
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	if (istype(cult))
		for (var/i = 1 to MINDUI_MAX_CULT_SLOTS)
			var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/new_slot = new(null, src)
			elements += new_slot
			cultist_slots += new_slot

/datum/mind_ui/bloodcult_panel/Display()
	..()
	if (active)
		var/obj/abstract/mind_ui_element/bloodcult_cultist_slot_manager/slot_manager = locate() in elements
		slot_manager.UpdateIcon()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/bloodcult_panel_background
	name = "Panel kultu"
	icon = 'aquila/icons/bloodcult/bloodcult/362x229.dmi'
	icon_state = "background2"
	offset_x = -165
	offset_y = -93
	alpha = 240
	layer = MIND_UI_BACK

/obj/abstract/mind_ui_element/bloodcult_panel_background/Click()
	parent.Hide()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_panel_close
	name = "Zamknij"
	icon = 'aquila/icons/bloodcult/bloodcult/16x16.dmi'
	icon_state = "close"
	offset_x = 181
	offset_y = 120
	layer = MIND_UI_BUTTON

/obj/abstract/mind_ui_element/hoverable/bloodcult_panel_close/Click()
	parent.Hide()


//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/movable/bloodcult_panel_move
	name = "Przesuń interfejs (kliknij i przeciągnij)"
	icon = 'aquila/icons/bloodcult/bloodcult/16x16.dmi'
	icon_state = "move"
	layer = MIND_UI_BUTTON
	offset_x = -165
	offset_y = 120
	mouse_opacity = 1

	move_whole_ui = TRUE
	const_offset_y = -16
	const_offset_x = -16

//------------------------------------------------------------

/obj/abstract/mind_ui_element/bloodcult_eclipse_timer_count
	name = "Licznik Zaćmienia"
	icon = 'aquila/icons/bloodcult/bloodcult/16x16.dmi'
	icon_state = "blank"
	offset_x = -13
	offset_y = 88
	layer = MIND_UI_FRONT
	element_flags = MINDUI_FLAG_PROCESSING
	mouse_opacity = 0
	var/red_blink = FALSE

/obj/abstract/mind_ui_element/bloodcult_eclipse_timer_count/process()
	if (invisibility == 101)
		return
	UpdateIcon()

/obj/abstract/mind_ui_element/bloodcult_eclipse_timer_count/UpdateIcon()
	overlays.len = 0
	offset_x = -13

	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	if (istype(cult))
		switch(cult.stage)
			if (BLOODCULT_STAGE_NORMAL)
				var/eclipse_remaining = cult.eclipse_target - cult.eclipse_progress
				var/eclipse_ticks_to_go_at_current_rate = 999999
				if (cult.eclipse_increments > 0)
					eclipse_ticks_to_go_at_current_rate = eclipse_remaining / max(0.1, cult.eclipse_increments)
					if(SSticker.initialized)
						eclipse_ticks_to_go_at_current_rate *= (SSticker.wait/10)

				var/hours_to_go = round(eclipse_ticks_to_go_at_current_rate/3600)
				var/minutes_to_go = add_zero(num2text(round(eclipse_ticks_to_go_at_current_rate/60) % 60), 2)
				var/seconds_to_go = add_zero(num2text(round(eclipse_ticks_to_go_at_current_rate) % 60), 2)
				if (eclipse_ticks_to_go_at_current_rate <= 60)
					if (!cult.soon_announcement)
						cult.soon_announcement = TRUE
						for (var/datum/mind/mind in cult.members)
							var/mob/M = mind.current
							to_chat(M, span_cult("Zaćmienie jest tuż-tuż...") )

					red_blink = !red_blink
					var/image/I = String2Image("[hours_to_go]:[minutes_to_go]:[seconds_to_go]", 10, 'aquila/icons/bloodcult/font_16x16.dmi', "#FFFFFF")
					if (red_blink)
						I.color = "red"
					else
						I.color = null
					overlays += I
				else
					overlays += String2Image("[hours_to_go]:[minutes_to_go]:[seconds_to_go]", 10, 'aquila/icons/bloodcult/font_16x16.dmi', "#FFFFFF")

			if (BLOODCULT_STAGE_READY)
				var/eclipse_ticks_before_end_at_current_rate = max(0, (GLOB.eclipse.eclipse_end_time - world.time)/10)
				var/hours_to_go = round(eclipse_ticks_before_end_at_current_rate/3600)
				var/minutes_to_go = add_zero(num2text(round(eclipse_ticks_before_end_at_current_rate/60) % 60), 2)
				var/seconds_to_go = add_zero(num2text(round(eclipse_ticks_before_end_at_current_rate) % 60), 2)
				if (eclipse_ticks_before_end_at_current_rate == 0)
					red_blink = !red_blink
					var/image/I = String2Image("0:00:00", 10, 'aquila/icons/bloodcult/font_16x16.dmi', "#FFFFFF")
					if (red_blink)
						I.color = "red"
					else
						I.color = null
					overlays += I
				else
					overlays += String2Image("[hours_to_go]:[minutes_to_go]:[seconds_to_go]", 10, 'aquila/icons/bloodcult/font_16x16.dmi', "#FFFFFF")

			if (BLOODCULT_STAGE_ECLIPSE)
				offset_x = -24
				var/time_before_narsie = max(0, (cult.bloodstone_target_time - world.time)/10)
				var/minutes_to_go = num2text(round(time_before_narsie/60))
				var/seconds_to_go
				if (minutes_to_go == "7")//6:66 lmao
					minutes_to_go = "6"
					seconds_to_go = add_zero(num2text((min(6, round(time_before_narsie) % 60))+60), 2)
				else
					seconds_to_go = add_zero(num2text(round(time_before_narsie) % 60), 2)
				overlays += String2Image("  [minutes_to_go]:[seconds_to_go]", 10, 'aquila/icons/bloodcult/font_16x16.dmi', "#FFFFFF")

			if (BLOODCULT_STAGE_NARSIE)
				overlays += String2Image("0:00:00", 10, 'aquila/icons/bloodcult/font_16x16.dmi', "#FF0000")
			else
				overlays += String2Image("0:00:00", 10, 'aquila/icons/bloodcult/font_16x16.dmi', "#999999")
	UpdateUIScreenLoc()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/bloodcult_eclipse_gauge
	name = "Krew"
	icon = 'aquila/icons/bloodcult/bloodcult/288x16.dmi'
	icon_state = "eclipse_gauge"
	layer = MIND_UI_BUTTON
	offset_x = -128
	offset_y = 86
	element_flags = MINDUI_FLAG_PROCESSING

	var/image/mask

/obj/abstract/mind_ui_element/bloodcult_eclipse_gauge/New()
	..()
	appearance_flags |= KEEP_TOGETHER
	mask = image(icon, src, "eclipse_gauge_bg")
	mask.blend_mode = BLEND_INSET_OVERLAY
	add_particles(PS_CULT_GAUGE)

/obj/abstract/mind_ui_element/bloodcult_eclipse_gauge/process()
	if (invisibility == 101)
		return
	UpdateIcon()

/obj/abstract/mind_ui_element/bloodcult_eclipse_gauge/UpdateIcon()
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	if (istype(cult))
		switch(cult.stage)
			if (BLOODCULT_STAGE_NORMAL)
				name = "Czas do Zaćmienia"
				mask.pixel_x = 288*(cult.eclipse_progress/cult.eclipse_target)
				adjust_particles(PVAR_POSITION, generator("box", list(mask.pixel_x-16, -1), list(mask.pixel_x-16, -14)))
				adjust_particles(PVAR_VELOCITY, list(-1*(mask.pixel_x)/40, 0))
				overlays.len = 0
				overlays += mask

			if (BLOODCULT_STAGE_READY)
				name = "Czas do końca Zaćmienia"
				mask.pixel_x = max(0, 288 - 288*((world.time - GLOB.eclipse.eclipse_start_time)/(GLOB.eclipse.eclipse_end_time - GLOB.eclipse.eclipse_start_time)))
				if (GLOB.eclipse.eclipse_end_time <= world.time)
					adjust_particles(PVAR_SPAWNING, 0)
				else
					adjust_particles(PVAR_POSITION, generator("box", list(mask.pixel_x-16, -1), list(mask.pixel_x-16, -14)))
					adjust_particles(PVAR_VELOCITY, list((288-mask.pixel_x)/40, 0))
				overlays.len = 0
				overlays += mask

			if (BLOODCULT_STAGE_ECLIPSE)
				name = "Czas do przebudzenia Nar'Sie"
				mask.pixel_x = max(0, 288*((world.time - cult.bloodstone_rising_time)/(cult.bloodstone_target_time - cult.bloodstone_rising_time)))
				adjust_particles(PVAR_POSITION, generator("box", list(mask.pixel_x-16, -1), list(mask.pixel_x-16, -14)))
				adjust_particles(PVAR_VELOCITY, list(-1*(mask.pixel_x)/40, 0))
				overlays.len = 0
				overlays += mask
			else
				adjust_particles(PVAR_SPAWNING, 0)
				mask.pixel_x = 0
				overlays.len = 0
				overlays += mask

//------------------------------------------------------------

/obj/abstract/mind_ui_element/bloodcult_eclipse_timer_front
	name = "Licznik Zaćmienia"
	icon = 'aquila/icons/bloodcult/bloodcult/362x229.dmi'
	icon_state = "foreground"
	offset_x = -165
	offset_y = -93
	alpha = 255
	layer = MIND_UI_FRONT
	mouse_opacity = 0

/obj/abstract/mind_ui_element/bloodcult_eclipse_timer_front/Click()
	parent.Hide()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_eclipse_rate
	name = "Tempo Zaćmienia"
	icon = 'aquila/icons/bloodcult/bloodcult/104x40.dmi'
	icon_state = "eclipse_rate"
	offset_x = -9
	offset_y = 103
	layer = MIND_UI_FRONT+0.5

	hover_state = FALSE
	element_flags = MINDUI_FLAG_PROCESSING|MINDUI_FLAG_TOOLTIP
	tooltip_title = "Tempo Zaćmienia"
	tooltip_content = "Tempo, w jakim nadchodzi Zaćmienie.<br>Zwiększa je zarówno generowanie oddania, jak i wzrost liczebności kultu.<br>Martwi kultyści nie przyczyniają się do tempa, dopóki nie zostaną wskrzeszeni."
	tooltip_theme = "radial-cult"

/obj/abstract/mind_ui_element/hoverable/bloodcult_eclipse_rate/Appear()
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	if(cult.stage != BLOODCULT_STAGE_NORMAL)
		invisibility = 101
		return
	..()

/obj/abstract/mind_ui_element/hoverable/bloodcult_eclipse_rate/process()
	if (invisibility == 101)
		return
	UpdateIcon()

/obj/abstract/mind_ui_element/hoverable/bloodcult_eclipse_rate/UpdateIcon()
	overlays.len = 0
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	var/eclipse_rate = min(99.999, cult.eclipse_increments)
	overlays += String2Image("[add_zero_before_and_after(round(eclipse_rate, 0.001), 2, 3)]", _pixel_x = 10, _pixel_y = 2)


//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_total_devotion
	name = "Całkowite oddanie"
	icon = 'aquila/icons/bloodcult/bloodcult/104x40.dmi'
	icon_state = "total_devotion"
	offset_x = -9
	offset_y = 69
	layer = MIND_UI_FRONT+0.5

	hover_state = FALSE
	element_flags = MINDUI_FLAG_PROCESSING|MINDUI_FLAG_TOOLTIP
	tooltip_title = "Całkowite oddanie"
	tooltip_content = "Całe oddanie zgromadzone przez wszystkich kultystów na pokładzie."
	tooltip_theme = "radial-cult"

/obj/abstract/mind_ui_element/hoverable/bloodcult_total_devotion/process()
	if (invisibility == 101)
		return
	UpdateIcon()

/obj/abstract/mind_ui_element/hoverable/bloodcult_total_devotion/UpdateIcon()
	overlays.len = 0
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	var/total_devotion = min(9999999, cult.total_devotion)
	if ((cult.stage == BLOODCULT_STAGE_DEFEATED) || (cult.stage == BLOODCULT_STAGE_NARSIE))
		overlays += String2Image("[add_zero(total_devotion, 7)]", _color = "#FF0000", _pixel_x = 4, _pixel_y = 4)
	else
		overlays += String2Image("[add_zero(total_devotion, 7)]", _color = "#FFFFFF", _pixel_x = 4, _pixel_y = 4)


//------------------------------------------------------------

/obj/abstract/mind_ui_element/bloodcult_cultist_slot_manager
	name = "Miejsca kultystów"
	icon = 'aquila/icons/bloodcult/bloodcult/16x16.dmi'
	icon_state = "blank"
	element_flags = MINDUI_FLAG_PROCESSING

/obj/abstract/mind_ui_element/bloodcult_cultist_slot_manager/process()
	if (invisibility == 101)
		return
	UpdateIcon()

/obj/abstract/mind_ui_element/bloodcult_cultist_slot_manager/UpdateIcon()
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	if (istype(cult))
		var/mob/M = GetUser()
		if (M)
			var/datum/antagonist/cult/cult_datum = M.mind?.has_antag_datum(/datum/antagonist/cult)
			if(cult_datum)
				var/i = 1
				var/cap_placed = 0
				var/list/ritualized_soulblades = list()//lists minds that undertook a soulblade ritual, saving their cult slot for others
				var/accumulated_offset = -12 * max(0, cult.members.len - cult.max_cultist_cap) //in case of suspiciously large overflow, we shift the slots to the left so they remain centered
				var/list/free_construct_slots = list()
				var/list/construct_types = list("Artificer", "Wraith", "Juggernaut")
				var/datum/mind_ui/bloodcult_panel/BP = parent
				if (cult.cultist_cap == 0)//blood stone destroyed
					var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_cap/cultist_cap = locate() in BP.elements
					accumulated_offset -= 4
					cultist_cap.offset_x = -98 + accumulated_offset
					cultist_cap.UpdateUIScreenLoc()
					accumulated_offset += 7
					cap_placed = 1
				for (var/datum/mind/mind in cult.members)
					var/datum/antagonist/cult/R = mind.has_antag_datum(/datum/antagonist/cult)
					if (!R) // AQUILA - umysł mógł stracić antaga (dekonwersja) przed odświeżeniem listy
						continue
					var/mob/O = R.owner.current
					if (!O || O.stat == DEAD)
						continue
					if (isshade(O))
						var/mob/living/simple_animal/shade/S = O
						if (S.soulblade_ritual)//we track soulbladed shades elsewhere
							ritualized_soulblades += mind
							continue
					if (istype(O, /mob/living/simple_animal/hostile/construct))
						var/mob/living/simple_animal/hostile/construct/cons = O
						if (!(cons.construct_type in free_construct_slots))
							free_construct_slots += cons.construct_type
							var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/S
							switch(cons.construct_type)
								if ("Artificer")
									var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/artificer/artificer_slot = locate() in BP.elements
									artificer_slot.associated_role = R
									artificer_slot.icon_state = "slot_artificer[artificer_slot.hovering ? "-hover" : ""]"
									artificer_slot.base_icon_state = "slot_artificer"
									S = artificer_slot
								if ("Wraith")
									var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/wraith/wraith_slot = locate() in BP.elements
									wraith_slot.associated_role = R
									wraith_slot.icon_state = "slot_wraith[wraith_slot.hovering ? "-hover" : ""]"
									wraith_slot.base_icon_state = "slot_wraith"
									S = wraith_slot
								if ("Juggernaut")
									var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/juggernaut/juggernaut_slot = locate() in BP.elements
									juggernaut_slot.associated_role = R
									juggernaut_slot.icon_state = "slot_juggernaut[juggernaut_slot.hovering ? "-hover" : ""]"
									juggernaut_slot.base_icon_state = "slot_juggernaut"
									S = juggernaut_slot
							S.overlays.len = 0
							if (cons.occult_muted())
								S.overlays += "holy"
							if (cult_datum == R)
								S.overlays += "you"
							continue
					var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/slot = BP.cultist_slots[i]
					slot.associated_role = R
					switch(R.cultist_role)
						if (CULTIST_ROLE_NONE)
							slot.icon_state = "slot_herald[slot.hovering ? "-hover" : ""]"
							slot.base_icon_state = "slot_herald"
						if (CULTIST_ROLE_ACOLYTE)
							slot.icon_state = "slot_acolyte[slot.hovering ? "-hover" : ""]"
							slot.base_icon_state = "slot_acolyte"
						if (CULTIST_ROLE_HERALD)
							slot.icon_state = "slot_herald[slot.hovering ? "-hover" : ""]"
							slot.base_icon_state = "slot_herald"
						if (CULTIST_ROLE_MENTOR)
							slot.icon_state = "slot_mentor[slot.hovering ? "-hover" : ""]"
							slot.base_icon_state = "slot_mentor"
					slot.overlays.len = 0
					if (i > cult.cultist_cap)
						slot.overlays += "overflow"
					if (O.occult_muted())
						slot.overlays += "holy"
					if (cult_datum == R)
						slot.overlays += "you"
					if (isshade(O))
						if (!istype(O.loc, /obj/item/soulstone) && !istype(O.loc, /obj/item/melee/soulblade))
							slot.overlays += "shade"
					slot.offset_x = -98 + accumulated_offset
					accumulated_offset += 17
					slot.UpdateUIScreenLoc()
					slot.locked = FALSE
					slot.invisibility = 0
					slot.overflow = (i > cult.cultist_cap)
					if (i == cult.cultist_cap)
						var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_cap/cultist_cap = locate() in BP.elements
						accumulated_offset -= 4
						cultist_cap.offset_x = -98 + accumulated_offset
						cultist_cap.UpdateUIScreenLoc()
						accumulated_offset += 7
						cap_placed = 1
					i++
					if (i > MINDUI_MAX_CULT_SLOTS)//If the cult manages to overflow to over 5 cultists over the cap, we don't bother tracking them anymore.
						break
				while (i <= cult.cultist_cap)
					var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/slot = BP.cultist_slots[i]
					slot.overlays.len = 0
					slot.offset_x = -98 + accumulated_offset
					accumulated_offset += 17
					slot.UpdateUIScreenLoc()
					slot.associated_role = null
					slot.icon_state = "slot_empty[slot.hovering ? "-hover" : ""]"
					slot.base_icon_state = "slot_empty"
					slot.locked = FALSE
					i++
				if (!cap_placed)
					var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_cap/cultist_cap = locate() in BP.elements
					accumulated_offset -= 4
					cultist_cap.offset_x = -98 + accumulated_offset
					cultist_cap.UpdateUIScreenLoc()
					accumulated_offset += 7
				if (cult.stage != BLOODCULT_STAGE_DEFEATED)
					while (i <= cult.max_cultist_cap)
						var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/slot = BP.cultist_slots[i]
						slot.offset_x = -98 + accumulated_offset
						slot.UpdateUIScreenLoc()
						accumulated_offset += 17
						slot.overlays.len = 0
						slot.associated_role = null
						slot.icon_state = "slot_empty[slot.hovering ? "-hover" : ""]"
						slot.base_icon_state = "slot_empty"
						slot.locked = TRUE
						slot.overlays += "locked"
						i++
				while (i <= MINDUI_MAX_CULT_SLOTS)
					var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/slot = BP.cultist_slots[i]
					slot.invisibility = 101
					i++
				for (var/cons_type in construct_types)
					if (!(cons_type in free_construct_slots))
						switch(cons_type)
							if ("Artificer")
								var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/artificer/artificer_slot = locate() in BP.elements
								artificer_slot.icon_state = "slot_artificer_empty[artificer_slot.hovering ? "-hover" : ""]"
								artificer_slot.associated_role = null
								artificer_slot.base_icon_state = "slot_artificer_empty"
								artificer_slot.overlays.len = 0
							if ("Wraith")
								var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/wraith/wraith_slot = locate() in BP.elements
								wraith_slot.icon_state = "slot_wraith_empty[wraith_slot.hovering ? "-hover" : ""]"
								wraith_slot.associated_role = null
								wraith_slot.base_icon_state = "slot_wraith_empty"
								wraith_slot.overlays.len = 0
							if ("Juggernaut")
								var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/juggernaut/juggernaut_slot = locate() in BP.elements
								juggernaut_slot.icon_state = "slot_juggernaut_empty[juggernaut_slot.hovering ? "-hover" : ""]"
								juggernaut_slot.associated_role = null
								juggernaut_slot.base_icon_state = "slot_juggernaut_empty"
								juggernaut_slot.overlays.len = 0

				var/obj/abstract/mind_ui_element/bloodcult_soulblades_count/soulblades_count = locate() in BP.elements
				soulblades_count.overlays.len = 0
				var/obj/abstract/mind_ui_element/hoverable/bloodcult_soulblades/soulblades = locate() in BP.elements
				soulblades.tooltip_content = ""
				if (ritualized_soulblades.len > 0)
					for (var/datum/mind/blade_mind in ritualized_soulblades)
						soulblades.tooltip_content += "[blade_mind.name]<br>"
					soulblades_count.overlays += String2Image("[ritualized_soulblades.len]")
				else
					soulblades.tooltip_content = "Osoby (kultyści i nie tylko) złożone w ofierze pustym ostrzem dusz nie zajmują miejsca, dopóki ostrze i jego cień nie zostaną rozdzielone."


//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot
	name = "Miejsce kultysty"
	icon = 'aquila/icons/bloodcult/bloodcult/16x32.dmi'
	icon_state = "slot_empty"
	base_icon_state = "slot_empty"
	layer = MIND_UI_BUTTON
	offset_x = -98
	offset_y = -28
	tooltip_title = "Miejsce kultysty"
	tooltip_content = ""
	tooltip_theme = "radial-cult"
	element_flags = MINDUI_FLAG_TOOLTIP

	var/datum/antagonist/cult/associated_role
	var/locked = FALSE
	var/overflow = FALSE

/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/StartHovering(location, control, params)
	set_tooltip()
	..()

/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/StopHovering()
	..()
	remove_particles()

/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/proc/set_tooltip()
	if (associated_role)
		add_particles(PS_CULT_HALO)
		adjust_particles(PVAR_ICON_STATE, "cult_halo[associated_role.get_devotion_rank()]", PS_CULT_HALO)
		adjust_particles(PVAR_PLANE, HUD_PLANE, PS_CULT_HALO)
		adjust_particles(PVAR_LAYER, MIND_UI_BUTTON+0.5, PS_CULT_HALO)
		adjust_particles(PVAR_PIXEL_X, -8, PS_CULT_HALO)
		var/datum/mind/M = associated_role.owner
		tooltip_title = M.name
		tooltip_content = "" // AQUILA - draft wyciął portret z vg i zostawił samo +=, przez co opis rósł przy każdym najechaniu
		switch(associated_role.cultist_role)
			if (CULTIST_ROLE_NONE)
				tooltip_content += "Herold kultu"
			if (CULTIST_ROLE_ACOLYTE)
				tooltip_content += "Akolita kultu"
				if (associated_role.mentor)
					var/datum/mind/I = associated_role.mentor.owner
					tooltip_content += "<br>Mentor: [I.name]."
			if (CULTIST_ROLE_HERALD)
				tooltip_content += "Herold kultu"
			if (CULTIST_ROLE_MENTOR)
				tooltip_content += "Mentor kultu"
		if (overflow)
			tooltip_content += "<br><b>ponad limit!</b>"//with some know-how, cultists may attempt to bypass the cap.
		tooltip_content += "<br>"
	else if (!locked)
		tooltip_title = "Miejsce kultysty"
		tooltip_content = "Jeśli znajdziesz odpowiedniego kandydata, użyj runy Konwersji, by go przyjąć."
	else
		tooltip_title = "Zablokowane miejsce"
		tooltip_content = "To miejsce zwolni się, gdy żywa załoga na pokładzie jeszcze się powiększy."

/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/artificer
	name = "Miejsce Artificera"
	icon_state = "slot_artificer_empty"
	base_icon_state = "slot_artificer_empty"
	offset_x = 84

/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/artificer/set_tooltip()
	if (associated_role)
		..()
		tooltip_content = "<br>Jako pierwszy Artificer kultu nie wlicza się do limitu kultystów."
	else
		tooltip_title = "Miejsce Artificera"
		tooltip_content = "Pierwszy Artificer kultu nie wlicza się do limitu kultystów."

/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/wraith
	name = "Miejsce Wraitha"
	icon_state = "slot_wraith_empty"
	base_icon_state = "slot_wraith_empty"
	offset_x = 101

/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/wraith/set_tooltip()
	if (associated_role)
		..()
		tooltip_content = "<br>Jako pierwszy Wraith kultu nie wlicza się do limitu kultystów."
	else
		tooltip_title = "Miejsce Wraitha"
		tooltip_content = "Pierwszy Wraith kultu nie wlicza się do limitu kultystów."

/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/juggernaut
	name = "Miejsce Juggernauta"
	icon_state = "slot_juggernaut_empty"
	base_icon_state = "slot_juggernaut_empty"
	offset_x = 118

/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/juggernaut/set_tooltip()
	if (associated_role)
		..()
		tooltip_content = "<br>Jako pierwszy Juggernaut kultu nie wlicza się do limitu kultystów."
	else
		tooltip_title = "Miejsce Juggernauta"
		tooltip_content = "Pierwszy Juggernaut kultu nie wlicza się do limitu kultystów."

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_soulblades
	name = "Ostrza dusz"
	icon = 'aquila/icons/bloodcult/bloodcult/16x32.dmi'
	icon_state = "blade"
	layer = MIND_UI_BUTTON
	offset_x = 140
	offset_y = -32
	tooltip_title = "Ostrza dusz po rytuale"
	tooltip_content = ""
	tooltip_theme = "radial-cult"
	element_flags = MINDUI_FLAG_TOOLTIP

/obj/abstract/mind_ui_element/bloodcult_soulblades_count
	name = "Ostrza dusz"
	icon = 'aquila/icons/bloodcult/bloodcult/16x16.dmi'
	icon_state = "blank"
	layer = MIND_UI_FRONT
	mouse_opacity = 0
	offset_x = 150
	offset_y = -10

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_cap
	name = "Limit kultystów"
	icon = 'aquila/icons/bloodcult/bloodcult/16x32.dmi'
	icon_state = "cultist_cap"
	base_icon_state = "cultist_cap"
	layer = MIND_UI_BUTTON
	offset_x = 67
	offset_y = -32

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_role
	name = "Wybierz rolę"
	icon = 'aquila/icons/bloodcult/bloodcult/32x32.dmi'
	icon_state = "role"
	offset_x = -147
	offset_y = -76
	layer = MIND_UI_BUTTON

	var/image/click_me

/obj/abstract/mind_ui_element/hoverable/bloodcult_role/New()
	..()
	click_me = image(icon, src, "click")
	click_me.layer = MIND_UI_FRONT
	animate(click_me, pixel_y = 16 , time = 7, loop = -1, easing = SINE_EASING)
	animate(pixel_y = 8, time = 7, loop = -1, easing = SINE_EASING)

/obj/abstract/mind_ui_element/hoverable/bloodcult_role/Click()
	flick("role-click", src)

	var/mob/M = GetUser()
	if (M)
		if (M.client)
			M.client.images -= click_me
		var/datum/antagonist/cult/cult_datum = M.mind?.has_antag_datum(/datum/antagonist/cult)
		if (cult_datum)
			if (cult_datum.cultist_role != CULTIST_ROLE_NONE)
				if (cult_datum.mentor)
					to_chat(M, span_notice("Obecnie twoim mentorem jest [cult_datum.mentor.owner.name].") )
				var/dat = ""
				if (cult_datum.acolytes.len > 0)
					for (var/datum/antagonist/cult/U in cult_datum.acolytes)
						dat += "[U.owner.name], "
					to_chat(M, span_notice("Obecnie jesteś mentorem dla: [dat]") )
				/* Don't think that cooldown was necessary, keeping this here in case I'm wrong in the future
				if ((world.time - cult_datum.time_role_changed_last) < 5 MINUTES)
					if ((world.time - cult_datum.time_role_changed_last) > 4 MINUTES)
						to_chat(M, span_warning("Musisz odczekać jeszcze [round((5 MINUTES - (world.time - cult_datum.time_role_changed_last))/10) + 1] s, zanim zmienisz rolę.") )
					else
						to_chat(M, span_warning("Musisz odczekać jeszcze około [round((5 MINUTES - (world.time - cult_datum.time_role_changed_last))/600) + 1] min, zanim zmienisz rolę.") )
					return
				else
				*/
				if (cult_datum.mentor)
					if(alert(M, "Zmiana roli zakończy mentorat, który prowadzi dla ciebie [cult_datum.mentor.owner.name]. Czy chcesz kontynuować?", "Potwierdzenie", "Tak", "Nie") != "Tak")
						return
				if (cult_datum.acolytes.len > 0)
					if(alert(M, "Zmiana roli zakończy twój mentorat dla: [dat] czy chcesz kontynuować?", "Potwierdzenie", "Tak", "Nie") != "Tak")
						return

	var/datum/mind_ui/bloodcult_role/role_popup = locate() in parent.subUIs
	if(role_popup)
		role_popup.Display()


/obj/abstract/mind_ui_element/hoverable/bloodcult_role/UpdateIcon()
	var/mob/M = GetUser()
	if (M)
		if (M.client)
			M.client.images -= click_me
		var/datum/antagonist/cult/cult_datum = M.mind?.has_antag_datum(/datum/antagonist/cult)
		if (cult_datum)
			overlays.len = 0
			switch(cult_datum.cultist_role)
				if (CULTIST_ROLE_NONE)
					if (M.client)
						M.client.images += click_me
				if (CULTIST_ROLE_ACOLYTE)
					overlays += "role_acolyte"
				if (CULTIST_ROLE_HERALD)
					overlays += "role_herald"
				if (CULTIST_ROLE_MENTOR)
					overlays += "role_mentor"


//------------------------------------------------------------

/obj/abstract/mind_ui_element/bloodcult_your_role
	name = "twoja obecna rola"
	icon = 'aquila/icons/bloodcult/bloodcult/288x16.dmi'
	icon_state = "cultist_herald"
	offset_x = -128
	offset_y = -69
	layer = MIND_UI_FRONT

/obj/abstract/mind_ui_element/bloodcult_your_role/UpdateIcon()
	var/mob/M = GetUser()
	if (M)
		var/datum/antagonist/cult/cult_datum = M.mind?.has_antag_datum(/datum/antagonist/cult)
		if (cult_datum)
			overlays.len = 0
			switch(cult_datum.cultist_role)
				if (CULTIST_ROLE_NONE)
					icon_state = "cultist_herald"
					offset_y = -69
				if (CULTIST_ROLE_ACOLYTE)
					icon_state = "cultist_acolyte"
					if (cult_datum.mentor)
						offset_y = -55
						var/image/I = image('aquila/icons/bloodcult/bloodcult/288x16.dmi', src, "mentored_by")
						I.pixel_x = 18
						I.pixel_y = -15
						overlays += I
						String2Maptext(cult_datum.mentor.owner.name, _pixel_x = 90, _pixel_y = -11)
					else
						offset_y = -59
				if (CULTIST_ROLE_HERALD)
					icon_state = "cultist_herald"
					offset_y = -69
				if (CULTIST_ROLE_MENTOR)
					icon_state = "cultist_mentor"
					if (cult_datum.acolytes.len > 0)
						offset_y = -55
						var/image/I = image('aquila/icons/bloodcult/bloodcult/288x16.dmi', src, "mentoring")
						I.pixel_x = 18
						I.pixel_y = -15
						overlays += I
						var/ac = 0
						while (ac < cult_datum.acolytes.len)
							var/datum/antagonist/cult/U = cult_datum.acolytes[ac+1]
							String2Maptext(U.owner.name, _pixel_x = 80, _pixel_y = -11 + (-13 * ac))
							ac++
					else
						offset_y = -69
			UpdateUIScreenLoc()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_other
	name = "Porady dla nowych"
	icon = 'aquila/icons/bloodcult/bloodcult/32x32.dmi'
	icon_state = "help"
	offset_x = 147
	offset_y = -76
	layer = MIND_UI_BUTTON

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_other/Click()
	flick("help-click", src)
	parent.mind.DisplayUI("Cultist Help")


////////////////////////////////////////////////////////////////////
//																  //
//						BLOODCULT - RITUALS						  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_rituals
	uniqueID = "Cult Rituals"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/faction_ritual/first,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/faction_ritual/second,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/faction_ritual/third,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/personal_ritual/first,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/personal_ritual/second,
		)
	display_with_parent = TRUE


/datum/mind_ui/bloodcult_rituals/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(IS_CULTIST(M))
		var/datum/team/cult/cult = locate_team(/datum/team/cult)
		if ((cult.stage == BLOODCULT_STAGE_NORMAL) || (cult.stage == BLOODCULT_STAGE_MISSED) || (cult.stage == BLOODCULT_STAGE_DEFEATED))
			return TRUE
	return FALSE

/obj/abstract/mind_ui_element/ritual_holder
	icon = 'aquila/icons/bloodcult/bloodcult/32x32.dmi'
	icon_state = "blank"
	mouse_opacity = 0

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual
	name = "Rytuał kultu"
	icon = 'aquila/icons/bloodcult/bloodcult/32x32.dmi'
	icon_state = "ritual_multi"
	offset_y = 32
	layer = MIND_UI_BUTTON

	element_flags = MINDUI_FLAG_TOOLTIP
	tooltip_title = "Rytuał"
	tooltip_content = "Lorem Ipsum (tego nie powinieneś widzieć!)"
	tooltip_theme = "radial-cult"

	var/datum/team/cult/cult
	var/datum/antagonist/cult/cultist

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/New(turf/loc, datum/mind_ui/P)
	if (!istype(P))
		qdel(src)
		return
	..()
	cult = locate_team(/datum/team/cult)
	var/mob/M = GetUser()
	cultist = M.mind?.has_antag_datum(/datum/antagonist/cult)

	//This horseshit magically lets have screen objects use animate(). Maybe I should make it a default mindUI feature at some point. -Deity
	animate(src, pixel_y = 2 , time = 10, loop = -1, easing = SINE_EASING)
	animate(pixel_y = -2, time = 10, loop = -1, easing = SINE_EASING)
	var/obj/abstract/mind_ui_element/ritual_holder/my_holder = new(null, P)
	my_holder.offset_x = offset_x
	my_holder.offset_y = offset_y
	my_holder.layer = layer
	my_holder.UpdateUIScreenLoc()
	P.elements += my_holder
	my_holder.vis_contents += src

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/Appear()
	..()
	//we constantly remove ourself from client.screen, as the holder we spawned in New() takes care of displaying us in our animate()'d glory
	var/mob/M = GetUser()
	if (!M.client)
		return
	M.client.screen -= src

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/StartHovering(location, control, params)
	UpdateIcon()
	..()

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/faction_ritual
	name = "Rytuał kultu"
	icon_state = "ritual_multi"
	offset_y = 32

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/faction_ritual/first
	offset_x = -110

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/faction_ritual/first/UpdateIcon()
	overlays.len = 0
	icon_state = "ritual_cleared"
	tooltip_title = ""
	tooltip_content = "..."
	if (cultist && (cult.stage != BLOODCULT_STAGE_DEFEATED))
		var/datum/bloodcult_ritual/BR = cult.rituals[RITUAL_FACTION_1]
		if (BR)
			tooltip_title = BR.name
			BR.update_desc()
			tooltip_content = BR.desc
			icon_state = "ritual_multi"
			overlays += "category_[BR.ritual_type]"
			overlays += "ritual_[BR.difficulty]"
	overlays += "ritual_multi_shape"
	base_icon_state = icon_state

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/faction_ritual/second


/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/faction_ritual/second/UpdateIcon()
	overlays.len = 0
	icon_state = "ritual_cleared"
	tooltip_title = ""
	tooltip_content = "..."
	if (cultist && (cult.stage != BLOODCULT_STAGE_DEFEATED))
		var/datum/bloodcult_ritual/BR = cult.rituals[RITUAL_FACTION_2]
		if (BR)
			tooltip_title = BR.name
			BR.update_desc()
			tooltip_content = BR.desc
			icon_state = "ritual_multi"
			overlays += "category_[BR.ritual_type]"
			overlays += "ritual_[BR.difficulty]"
	overlays += "ritual_multi_shape"
	base_icon_state = icon_state

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/faction_ritual/third
	offset_x = 110

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/faction_ritual/third/UpdateIcon()
	overlays.len = 0
	icon_state = "ritual_cleared"
	tooltip_title = ""
	tooltip_content = "..."
	if (cultist && (cult.stage != BLOODCULT_STAGE_DEFEATED))
		var/datum/bloodcult_ritual/BR = cult.rituals[RITUAL_FACTION_3]
		if (BR)
			tooltip_title = BR.name
			BR.update_desc()
			tooltip_content = BR.desc
			icon_state = "ritual_multi"
			overlays += "category_[BR.ritual_type]"
			overlays += "ritual_[BR.difficulty]"
	overlays += "ritual_multi_shape"
	base_icon_state = icon_state

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/personal_ritual
	name = "Rytuał osobisty"
	icon_state = "ritual_solo"
	offset_y = 6

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/personal_ritual/first
	offset_x = -55

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/personal_ritual/first/UpdateIcon()
	overlays.len = 0
	icon_state = "ritual_cleared"
	tooltip_title = ""
	tooltip_content = "..."
	if (cultist && (cult.stage != BLOODCULT_STAGE_DEFEATED))
		var/datum/bloodcult_ritual/BR = cultist.rituals[RITUAL_CULTIST_1]
		if (BR)
			tooltip_title = BR.name
			BR.update_desc()
			tooltip_content = BR.desc
			icon_state = "ritual_solo"
			overlays += "category_[BR.ritual_type]"
			overlays += "ritual_[BR.difficulty]"
	overlays += "ritual_solo_shape"
	base_icon_state = icon_state

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/personal_ritual/second
	offset_x = 55

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/personal_ritual/second/UpdateIcon()
	overlays.len = 0
	icon_state = "ritual_cleared"
	tooltip_title = ""
	tooltip_content = "..."
	if (cultist && (cult.stage != BLOODCULT_STAGE_DEFEATED))
		var/datum/bloodcult_ritual/BR = cultist.rituals[RITUAL_CULTIST_2]
		if (BR)
			tooltip_title = BR.name
			BR.update_desc()
			tooltip_content = BR.desc
			icon_state = "ritual_solo"
			overlays += "category_[BR.ritual_type]"
			overlays += "ritual_[BR.difficulty]"
	overlays += "ritual_solo_shape"
	base_icon_state = icon_state

////////////////////////////////////////////////////////////////////
//																  //
//						BLOODCULT - RITUAL NARSIE				  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_ritual_narsie
	uniqueID = "Cult Last Ritual"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/hoverable/ritual_narsie,
		)
	display_with_parent = TRUE

/datum/mind_ui/bloodcult_ritual_narsie/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(IS_CULTIST(M))
		var/datum/team/cult/cult = locate_team(/datum/team/cult)
		if ((cult.stage == BLOODCULT_STAGE_READY) || (cult.stage == BLOODCULT_STAGE_ECLIPSE) || (cult.stage == BLOODCULT_STAGE_NARSIE))
			return TRUE
	return FALSE

/obj/abstract/mind_ui_element/hoverable/ritual_narsie
	name = "Rozdarcie rzeczywistości"
	icon = 'aquila/icons/bloodcult/bloodcult/40x40.dmi'
	icon_state = "ritual_narsie"
	offset_x = -4
	offset_y = 15
	layer = MIND_UI_BUTTON

	element_flags = MINDUI_FLAG_TOOLTIP
	tooltip_title = ""
	tooltip_content = "<span class = 'sinister'>Piekło...</span><br><span class = 'sinister'>Złączenie...</span><br><span class = 'sinister'>Ja...</span><br>"
	tooltip_theme = "radial-cult"

/obj/abstract/mind_ui_element/hoverable/ritual_narsie/New(turf/loc, datum/mind_ui/P)
	if (!istype(P))
		qdel(src)
		return
	..()

	//This horseshit magically lets have screen objects use animate(). Maybe I should make it a default mindUI feature at some point. -Deity
	animate(src, pixel_y = 1 * 1 , time = 10, loop = -1, easing = SINE_EASING)
	animate(pixel_y = -1 * 1, time = 10, loop = -1, easing = SINE_EASING)
	var/obj/abstract/mind_ui_element/ritual_holder/my_holder = new(null, P)
	my_holder.offset_x = offset_x
	my_holder.offset_y = offset_y
	my_holder.layer = layer
	my_holder.UpdateUIScreenLoc()
	P.elements += my_holder
	my_holder.vis_contents += src

/obj/abstract/mind_ui_element/hoverable/ritual_narsie/Appear()
	..()
	//we constantly remove ourself from client.screen, as the holder we spawned in New() takes care of displaying us in our animate()'d glory
	var/mob/M = GetUser()
	if (!M.client)
		return
	M.client.screen -= src

/obj/abstract/mind_ui_element/hoverable/ritual_narsie/StartHovering(location, control, params)
	UpdateIcon()
	..()

/obj/abstract/mind_ui_element/hoverable/ritual_narsie/UpdateIcon()
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	switch(cult.stage)
		if (BLOODCULT_STAGE_READY)
			if (!cult.tear_ritual)
				tooltip_content = "Piekło...<br>Złączenie...<br>Ja...<br>"
			else if (!cult.tear_ritual.dance_manager)
				tooltip_content = "Potrzeba ośmiorga...<br>Wyznawców lub więźniów...<br>"
			else
				tooltip_content = "Pokażcie mi, jak tańczycie...<br>"
		if (BLOODCULT_STAGE_ECLIPSE)
			tooltip_content = "Chrońcie Krwawy Kamień...<br>To wasza ostatnia próba...<br>"
		if (BLOODCULT_STAGE_NARSIE)
			tooltip_content = "Radujcie się...<br>Ucztujcie...<br>Zbierajcie żniwo...<br>"


////////////////////////////////////////////////////////////////////
//																  //
//					BLOODCULT - ROLE							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_role
	uniqueID = "Cultist Role"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/bloodcult_role_background,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_role_close,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/acolyte,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/herald,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/mentor,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_role_confirm,
		/obj/abstract/mind_ui_element/hoverable/movable/bloodcult_role_move,
		)
	display_with_parent = TRUE//displays instantly when the cult panel is opened for the first time

	offset_layer = MIND_UI_GROUP_B

	var/selected_role = CULTIST_ROLE_NONE

/datum/mind_ui/bloodcult_role/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(IS_CULTIST(M))
		return TRUE
	return FALSE

/datum/mind_ui/bloodcult_role/Display()
	..()
	if (active)
		display_with_parent = FALSE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/bloodcult_role_background
	name = "Wybierz rolę"
	icon = 'aquila/icons/bloodcult/bloodcult/362x229.dmi'
	icon_state = "background"
	offset_x = -165
	offset_y = -93
	alpha = 240
	layer = MIND_UI_BACK

/obj/abstract/mind_ui_element/bloodcult_role_background/UpdateIcon()
	overlays.len = 0
	var/datum/mind_ui/bloodcult_role/P = parent
	switch(P.selected_role)
		if (CULTIST_ROLE_ACOLYTE)
			overlays += "acolyte"
		if (CULTIST_ROLE_HERALD)
			overlays += "herald"
		if (CULTIST_ROLE_MENTOR)
			overlays += "mentor"
		else
			overlays += "none"

/obj/abstract/mind_ui_element/bloodcult_role_background/Click()
	parent.Hide()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_close
	name = "Zamknij"
	icon = 'aquila/icons/bloodcult/bloodcult/16x16.dmi'
	icon_state = "close"
	offset_x = 181
	offset_y = 120
	layer = MIND_UI_BUTTON

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_close/Click()
	parent.Hide()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select
	icon = 'aquila/icons/bloodcult/bloodcult/40x40.dmi'
	icon_state = "button"
	layer = MIND_UI_BUTTON
	// AQUILA - opisy ról są wpisane w obrazek tła po angielsku (362x229.dmi), więc dajemy ich polskie tłumaczenie w podpowiedzi
	element_flags = MINDUI_FLAG_TOOLTIP
	tooltip_theme = "radial-cult"
	var/role_small = ""
	var/role = null

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/New()
	..()
	overlays += "overlay_[role_small]"

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/UpdateIcon()
	var/datum/mind_ui/bloodcult_role/P = parent
	if (P.selected_role == role)
		icon_state = "button-down"
	else
		icon_state = "button"

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/StartHovering()
	var/datum/mind_ui/bloodcult_role/P = parent
	if (P.selected_role == role)
		return
	else
		..()

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/StopHovering()
	var/datum/mind_ui/bloodcult_role/P = parent
	if (P.selected_role == role)
		return
	else
		..()

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/Click()
	var/datum/mind_ui/bloodcult_role/P = parent
	P.selected_role = role
	P.Display()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/acolyte
	name = "Akolita"
	tooltip_title = "Akolita"
	tooltip_content = "* Polecany dla nowych kultystów<br>* Dostaniesz przydzielonego Mentora<br>* Skup się na poznawaniu swoich zdolności<br>* Będą się pojawiać podpowiedzi w interfejsie"
	offset_x = -99
	offset_y = 80
	role_small = "acolyte"
	role = CULTIST_ROLE_ACOLYTE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/herald
	name = "Herold"
	tooltip_title = "Herold"
	tooltip_content = "* Bez określonej specjalizacji<br>* Wspieraj kult najlepiej, jak potrafisz<br>* Zajmuj czymś załogę<br>* Zakładaj bazy kultu"
	offset_x = -3
	offset_y = 80
	role_small = "herald"
	role = CULTIST_ROLE_HERALD

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/mentor
	name = "Mentor"
	tooltip_title = "Mentor"
	tooltip_content = "* Polecany dla doświadczonych kultystów<br>* Będziesz uczyć Akolitów<br>* Skup się na prowadzeniu kultu i wyznaczaniu celów<br>* Współpracuj z innymi Mentorami"
	offset_x = 93
	offset_y = 80
	role_small = "mentor"
	role = CULTIST_ROLE_MENTOR

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_confirm
	name = "Potwierdź"
	icon = 'aquila/icons/bloodcult/bloodcult/104x40.dmi'
	icon_state = "confirm"
	offset_x = -36
	offset_y = -78
	layer = MIND_UI_BUTTON

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_confirm/UpdateIcon()
	var/datum/mind_ui/bloodcult_role/P = parent
	if (P.selected_role == CULTIST_ROLE_NONE)
		icon_state = "confirm-grey"
	else
		icon_state = "confirm"
	base_icon_state = icon_state

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_confirm/StartHovering()
	var/datum/mind_ui/bloodcult_role/P = parent
	if (P.selected_role == CULTIST_ROLE_NONE)
		return
	icon_state = "[base_icon_state]-hover"

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_confirm/StopHovering()
	var/datum/mind_ui/bloodcult_role/P = parent
	if (P.selected_role == CULTIST_ROLE_NONE)
		return
	icon_state = "[base_icon_state]"

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_confirm/Click()
	var/datum/mind_ui/bloodcult_role/P = parent
	if (P.selected_role == CULTIST_ROLE_NONE)
		return
	var/mob/M = GetUser()
	if (M)
		var/datum/antagonist/cult/cult_datum = M.mind?.has_antag_datum(/datum/antagonist/cult)
		if (cult_datum)
			cult_datum.ChangeCultistRole(P.selected_role)
			parent.Hide()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/movable/bloodcult_role_move
	name = "Przesuń interfejs (kliknij i przeciągnij)"
	icon = 'aquila/icons/bloodcult/bloodcult/16x16.dmi'
	icon_state = "move"
	layer = MIND_UI_BUTTON
	offset_x = -165
	offset_y = 120
	mouse_opacity = 1

	move_whole_ui = TRUE
	const_offset_y = -16
	const_offset_x = -16



////////////////////////////////////////////////////////////////////
//																  //
//					BLOODCULT - HELP							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_help
	uniqueID = "Cultist Help"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/hoverable/bloodcult_help_background,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_help_close,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_help_previous,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_help_next,
		/obj/abstract/mind_ui_element/hoverable/movable/bloodcult_help_move,
		)
	offset_layer = MIND_UI_GROUP_C
	display_with_parent = FALSE

/datum/mind_ui/bloodcult_help/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(IS_CULTIST(M))
		return TRUE
	return FALSE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_background
	name = "Jak być kultystą?"
	icon = 'aquila/icons/bloodcult/bloodcult/192x192.dmi'
	icon_state = "cult_help"
	offset_x = -80
	offset_y = -150
	layer = MIND_UI_BACK + 6
	tooltip_title = "Więcej szczegółów"
	element_flags = MINDUI_FLAG_TOOLTIP
	tooltip_theme = "radial-cult"
	var/current_page = 1
	var/max_page = 13

	// AQUILA - strony pomocy to obrazki z angielskim tekstem (192x192.dmi). Draft miał podpowiedzi tylko na 5 stronach,
	// my na każdej dajemy polskie tłumaczenie tekstu z obrazka (+ dodatki z draftu), żeby pomoc dało się przeczytać po polsku.
	var/static/list/help_info = list(
		"Runy kreślone krwią są źródłem twojej mocy. Pełna runa składa się z 3 „słów”.<br><br>Krew można pozyskać na wiele sposobów, m.in. z: worków z krwią, osób, które trzymasz w chwycie, zakrwawionych dłoni, plam krwi pod tobą, każdego pojemnika na odczynniki, o ile jest w nim krew, i z siebie samego.",
		"Tym przyciskiem sprawdzisz listę wszystkich znanych run i dostaniesz pomoc w ich nakreśleniu.",
		"Tym przyciskiem możesz kreślić runy bezpośrednio, kiedy już je zapamiętasz.",
		"Ten przycisk ściera słowa z runy, a ten można przytrzymać, by przesunąć interfejs.",
		"Po nakreśleniu runy dotknij jej dłonią na podłodze, by rzucić przypisane jej zaklęcie.<br>Niektóre runy wymagają, żebyś na nich stał.",
		"Runą Akcesoriów możesz przywołać Tajemną Księgę, która opisuje działanie każdej runy.",
		"Iglica (wznoszona runą Wzniesienia Budowli) pozwala kultystom na całym poziomie porozumiewać się przez :f.<br>Możesz też użyć runy Komunikacji, by rozmawiać z kultem.",
		"Talizmany można nakładać na runy, by nosić ich moc w kieszeni.<br>Talizmany ogłuszające to znak rozpoznawczy kultu, ale są też inne, równie zabawne.<br><br>Pusty talizman zdobędziesz z runy Akcesoriów.",
		"Szaty kultu nie tylko chronią przed obrażeniami, ale też pozwalają ukryć tożsamość. Tylko nie zapomnij zdjąć identyfikatora.",
		"Runy ścieżek pozwalają zbudować szybką i bezpieczną sieć teleportacji. Świetnie nadają się do ucieczki w potrzebie.",
		"Runy konwersji pozwalają zdobywać nowych sojuszników. Cel pozostaje ogłuszony przez cały rytuał.<br><br>Jeśli kogoś nie da się nawrócić, staje się więźniem kultu, dopóki ma na sobie więzy. Więźniów można użyć w ostatnim rytuale przywołania Nar'Sie zamiast kultystów.",
		"Konstrukty to potężni sojusznicy.<br><br>W skrócie: w ołtarzu tworzy się klejnot, którego używasz na duchu albo zwłokach, by go napełnić, a potem na skorupie konstruktu i wybierasz rodzaj konstruktu.",
		"Przy ołtarzu możesz porozumieć się z Nar'Sie. Śmiało proś o wskazówki albo dziel się uwagami.<br>A teraz idź robić okultystyczne rzeczy!<br><br>Na koniec: podczas Zaćmienia wykonuj słowa, które Nar'Sie przekazuje ci w głównym panelu kultu. To pomaga rozpocząć ostatni rytuał.",
	)

//copy paste ew
/obj/abstract/mind_ui_element/hoverable/bloodcult_help_background/StartHovering(location, control, params)
	if(isnull(help_info[current_page]))
		return
	var/mob/M = GetUser()
	if (M)
		//I hate this, I hate this, but somehow the tooltips won't appear in the right place unless I do this black magic
		//this only happens with mindUI elements, but the more offset from the center the elements are, tooltips become even more offset.
		//this code corrects this extra offset.
		var/list/param_list = params2list(params)
		var/screenloc = param_list["screen-loc"]
		var/x_index = findtext(screenloc, ":", 1, 0)
		var/comma_index = findtext(screenloc,",", x_index, 0)
		var/y_index = findtext(screenloc,":", comma_index, 0)
		var/x_loc = text2num(copytext(screenloc, 1, x_index))
		var/y_loc = text2num(copytext(screenloc, comma_index+1, y_index))
		openToolTip(M,src,mind_ui_tooltip_params(M, x_loc, y_loc),title = tooltip_title,content = help_info[current_page],theme = tooltip_theme)

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_background/UpdateIcon()
	overlays.len = 0
	overlays += "cult_help[current_page]"

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_background/Click()
	parent.Hide()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_close
	name = "Zamknij"
	icon = 'aquila/icons/bloodcult/bloodcult/16x16.dmi'
	icon_state = "close"
	offset_x = 96
	offset_y = -38
	layer = MIND_UI_BUTTON + 6

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_close/Click()
	parent.Hide()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_previous
	name = "Poprzednia strona"
	icon = 'aquila/icons/bloodcult/bloodcult/24x24.dmi'
	icon_state = "button_prev"
	offset_x = -80
	offset_y = -150
	layer = MIND_UI_BUTTON + 6

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_previous/Appear()
	var/obj/abstract/mind_ui_element/hoverable/bloodcult_help_background/help = locate() in parent.elements
	if(help)
		if (help.current_page <= 1)
			invisibility = 101
		else
			..()

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_previous/Click()
	flick("button_prev-click", src)
	var/obj/abstract/mind_ui_element/hoverable/bloodcult_help_background/help = locate() in parent.elements
	if(help)
		help.current_page = max(help.current_page-1, 1)
		parent.Display()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_next
	name = "Następna strona"
	icon = 'aquila/icons/bloodcult/bloodcult/24x24.dmi'
	icon_state = "button_next"
	offset_x = 88
	offset_y = -150
	layer = MIND_UI_BUTTON + 6

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_next/Appear()
	var/obj/abstract/mind_ui_element/hoverable/bloodcult_help_background/help = locate() in parent.elements
	if(help)
		if (help.current_page >= help.max_page)
			invisibility = 101
		else
			..()

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_next/Click()
	flick("button_next-click", src)
	var/obj/abstract/mind_ui_element/hoverable/bloodcult_help_background/help = locate() in parent.elements
	if(help)
		help.current_page = min(help.current_page+1, help.max_page)
		parent.Display()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/movable/bloodcult_help_move
	name = "Przesuń interfejs (kliknij i przeciągnij)"
	icon = 'aquila/icons/bloodcult/bloodcult/16x16.dmi'
	icon_state = "move"
	layer = MIND_UI_BUTTON + 6
	offset_x = -80
	offset_y = -38
	mouse_opacity = 1

	move_whole_ui = TRUE
	const_offset_x = -16
	const_offset_y = -16

//------------------------------------------------------------


////////////////////////////////////////////////////////////////////
//																  //
//					BLOODCULT - NAR-SIE HAS RISEN				  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_narsie_has_risen
	uniqueID = "Nar-Sie Has Risen"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/bloodcult_particle_holder/bloodcult_narsie,
		/obj/abstract/mind_ui_element/bloodcult_particle_holder/bloodcult_has,
		/obj/abstract/mind_ui_element/bloodcult_particle_holder/bloodcult_risen
		)
	offset_layer = MIND_UI_GROUP_D
	display_with_parent = FALSE

/datum/mind_ui/bloodcult_narsie_has_risen/Display()
	active = TRUE
	INVOKE_ASYNC(src, PROC_REF(show_narsie_has_risen))

/datum/mind_ui/bloodcult_narsie_has_risen/proc/show_narsie_has_risen()
	sleep(5)
	for (var/obj/abstract/mind_ui_element/bloodcult_particle_holder/element in elements)
		element.invisibility = 0
		element.add_particles(element.my_particle)
		sleep(10)

	for (var/obj/abstract/mind_ui_element/bloodcult_particle_holder/element in elements)
		element.adjust_particles(PVAR_SPAWNING, 0)

/obj/abstract/mind_ui_element/bloodcult_particle_holder
	mouse_opacity = 0
	icon = 'aquila/icons/bloodcult/bloodcult/32x32.dmi'
	icon_state = "blank"
	layer = MIND_UI_FRONT
	var/my_particle

/obj/abstract/mind_ui_element/bloodcult_particle_holder/bloodcult_narsie
	my_particle = PS_NARSIEHASRISEN1
	offset_y = 64
/obj/abstract/mind_ui_element/bloodcult_particle_holder/bloodcult_has
	my_particle = PS_NARSIEHASRISEN2
/obj/abstract/mind_ui_element/bloodcult_particle_holder/bloodcult_risen
	my_particle = PS_NARSIEHASRISEN3
	offset_y = -64

/datum/mind_ui/hex_controller
	uniqueID = "Hex Controller"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/hoverable/hex_controller/harm,
		/obj/abstract/mind_ui_element/hoverable/hex_controller/roam,
		/obj/abstract/mind_ui_element/hoverable/hex_controller/escort,
		/obj/abstract/mind_ui_element/hoverable/hex_controller/guard,
		)
	display_with_parent = TRUE

	offset_layer = MIND_UI_GROUP_D
	var/controller = 0

/datum/mind_ui/hex_controller/Valid()
	if (!controller)
		return
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(istype(M, /mob/living/simple_animal/hostile/construct/builder/perfect))
		var/mob/living/simple_animal/hostile/construct/builder/perfect/master = M
		if (master.minions.len >= controller)
			return TRUE
	return FALSE

/datum/mind_ui/hex_controller/first
	uniqueID = "Hex Controller 1" // AQUILA - w vg/drafcie oba miały to samo ID i drugi nadpisywał pierwszy w active_uis
	controller = 1

/datum/mind_ui/hex_controller/second
	uniqueID = "Hex Controller 2"
	controller = 2

/obj/abstract/mind_ui_element/hoverable/hex_controller
	icon = 'aquila/icons/bloodcult/bloodcult/24x24.dmi'
	offset_x = 196
	offset_y = -87
	layer = MIND_UI_BUTTON

/obj/abstract/mind_ui_element/hoverable/hex_controller/New(turf/loc, datum/mind_ui/hex_controller/P)
	if (!istype(P))
		qdel(src)
		return
	..()
	if (P.controller > 1)
		offset_y = -87 + (28*(P.controller-1))
	UpdateUIScreenLoc()

////////////////////////

/obj/abstract/mind_ui_element/hoverable/hex_controller/harm
	name = "Agresywny"
	icon_state = "hexcontrol_harm"
	tooltip_theme = "radial-cult"

/obj/abstract/mind_ui_element/hoverable/hex_controller/harm/Click()
	var/mob/living/simple_animal/hostile/construct/builder/perfect/M = GetUser()
	var/datum/mind_ui/hex_controller/P = parent
	if (M && P && P.controller)
		if (M.minions.len >= P.controller)
			var/mob/living/simple_animal/hostile/hex/H = M.minions[P.controller]
			H.passive = !H.passive
			H.update_harmglow()
			if (H.passive)
				name = "Pasywny"
				icon_state = "hexcontrol_passive"
				H.LoseTarget() // AQUILA - u nas hostile nie ma „stance”, bezczynność = brak celu
			else
				name = "Agresywny"
				icon_state = "hexcontrol_harm"
				var/list/possible_targets = H.ListTargets()
				var/new_target = H.FindTarget(possible_targets)
				H.GiveTarget(new_target)
				if (H.target)
					H.MoveToTarget()
			base_icon_state = icon_state

/obj/abstract/mind_ui_element/hoverable/hex_controller/harm/UpdateIcon()
	var/mob/living/simple_animal/hostile/construct/builder/perfect/M = GetUser()
	var/datum/mind_ui/hex_controller/P = parent
	if (M && P && P.controller)
		if (M.minions.len >= P.controller)
			var/mob/living/simple_animal/hostile/hex/H = M.minions[P.controller]
			if (H.passive)
				name = "Pasywny"
				icon_state = "hexcontrol_passive"
				tooltip_content = "Ten Hex jest pasywny i nie atakuje celów."
			else
				name = "Agresywny"
				icon_state = "hexcontrol_harm"
				tooltip_content = "Ten Hex jest agresywny i atakuje cele."
			base_icon_state = icon_state

////////////////////////

/obj/abstract/mind_ui_element/hoverable/hex_controller/roam
	name = "Wędrówka"
	icon_state = "hexcontrol_roam"
	tooltip_theme = "radial-cult"

/obj/abstract/mind_ui_element/hoverable/hex_controller/roam/Click()
	var/mob/living/simple_animal/hostile/construct/builder/perfect/M = GetUser()
	var/datum/mind_ui/hex_controller/P = parent
	if (M && P && P.controller)
		if (M.minions.len >= P.controller)
			var/mob/living/simple_animal/hostile/hex/H = M.minions[P.controller]
			H.mode = HEX_MODE_ROAMING
			H.stop_automated_movement = FALSE
			walk(H, 0)
			P.Display()

/obj/abstract/mind_ui_element/hoverable/hex_controller/roam/UpdateIcon()
	var/mob/living/simple_animal/hostile/construct/builder/perfect/M = GetUser()
	var/datum/mind_ui/hex_controller/P = parent
	if (M && P && P.controller)
		if (M.minions.len >= P.controller)
			var/mob/living/simple_animal/hostile/hex/H = M.minions[P.controller]
			switch (H.mode)
				if (HEX_MODE_ROAMING)
					icon_state = "hexcontrol_roam"
					tooltip_content = "Ten Hex wędruje swobodnie."
				else
					icon_state = "hexcontrol_roam-off"
					tooltip_content = ""
			base_icon_state = icon_state

////////////////////////

/obj/abstract/mind_ui_element/hoverable/hex_controller/escort
	name = "Eskorta"
	icon_state = "hexcontrol_escort-off"
	tooltip_theme = "radial-cult"

/obj/abstract/mind_ui_element/hoverable/hex_controller/escort/Click()
	var/mob/living/simple_animal/hostile/construct/builder/perfect/M = GetUser()
	var/datum/mind_ui/hex_controller/P = parent
	if (M && P && P.controller)
		if (M.minions.len >= P.controller)
			var/mob/living/simple_animal/hostile/hex/H = M.minions[P.controller]
			H.mode = HEX_MODE_ESCORT
			H.escort_routine()
			P.Display()

/obj/abstract/mind_ui_element/hoverable/hex_controller/escort/UpdateIcon()
	var/mob/living/simple_animal/hostile/construct/builder/perfect/M = GetUser()
	var/datum/mind_ui/hex_controller/P = parent
	if (M && P && P.controller)
		if (M.minions.len >= P.controller)
			var/mob/living/simple_animal/hostile/hex/H = M.minions[P.controller]
			switch (H.mode)
				if (HEX_MODE_ESCORT)
					icon_state = "hexcontrol_escort"
					tooltip_content = "Ten Hex cały czas za tobą podąża i odchodzi tylko, gdy zobaczy cel."
				else
					icon_state = "hexcontrol_escort-off"
					tooltip_content = ""
			base_icon_state = icon_state

////////////////////////

/obj/abstract/mind_ui_element/hoverable/hex_controller/guard
	name = "Straż"
	icon_state = "hexcontrol_guard-off"
	tooltip_theme = "radial-cult"

/obj/abstract/mind_ui_element/hoverable/hex_controller/guard/Click()
	var/mob/living/simple_animal/hostile/construct/builder/perfect/M = GetUser()
	var/datum/mind_ui/hex_controller/P = parent
	if (M && P && P.controller)
		if (M.minions.len >= P.controller)
			var/mob/living/simple_animal/hostile/hex/H = M.minions[P.controller]
			H.mode = HEX_MODE_GUARD
			H.guard_spot = get_turf(H)
			walk(H, 0)
			P.Display()

/obj/abstract/mind_ui_element/hoverable/hex_controller/guard/UpdateIcon()
	var/mob/living/simple_animal/hostile/construct/builder/perfect/M = GetUser()
	var/datum/mind_ui/hex_controller/P = parent
	if (M && P && P.controller)
		if (M.minions.len >= P.controller)
			var/mob/living/simple_animal/hostile/hex/H = M.minions[P.controller]
			switch (H.mode)
				if (HEX_MODE_GUARD)
					icon_state = "hexcontrol_guard"
					tooltip_content = "Ten Hex pilnuje swojego obecnego miejsca."
				else
					icon_state = "hexcontrol_guard-off"
					tooltip_content = ""
			base_icon_state = icon_state

//example: add_zero(217, 6) = "000217"
/proc/add_zero(_string, beforeZeroes)
	var/string = "[_string]"
	while (length(string) < beforeZeroes)
		string = "0[string]"
	return string

//example: add_zero_before_and_after(3.14, 3, 5) = "003.14000"
/proc/add_zero_before_and_after(_string, beforeZeroes, afterZeroes)
	var/string = "[_string]"
	var/dot_pos = findtext(string, ".")
	if (dot_pos)
		dot_pos--
		while (dot_pos < beforeZeroes)
			string = "0[string]"
			dot_pos++
		while (length(string) < (beforeZeroes+afterZeroes+1))
			string = "[string]0"
	else
		while (length(string) < beforeZeroes)
			string = "0[string]"
		string = "[string]."
		while (length(string) < (beforeZeroes+afterZeroes+1))
			string = "[string]0"
	return string

