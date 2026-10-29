GLOBAL_LIST_INIT(bloodcult_exitportals, list())

/datum/rune_spell/portalexit
	name = "Wyjście ze Ścieżki"
	desc = "Dziękujemy za lot liniami Air Nar-Sie."//might change it later or not.
	desc_talisman = "Użyj, by od razu przeskoczyć przez Ścieżkę."
	invocation = "Sas'so c'arta forbici!"
	word1 = /datum/rune_word/travel
	word2 = /datum/rune_word/other
	word3 = /datum/rune_word/self
	talisman_absorb = RUNE_CAN_IMBUE
	can_conceal = 1
	page = "Razem z runą Wejścia na Ścieżkę ta runa pozwala na swobodne teleportacje między dowolnymi dwoma polami w świecie. \
		Przy pierwszym użyciu runa poprosi o wybór ścieżki, do której się dostroi. Jest 10 ścieżek, każda odpowiada jednemu słowu kultu.\
		<br><br>W przeciwieństwie do wejść, dla każdej ścieżki może istnieć tylko jedno wyjście.\
		<br><br>Użycie talizmanu na dostrojonej runie sprawi, że talizman od razu przeniesie cię do tej runy.\
		<br><br>Użycie talizmanu na niedostrojonej runie wchłonie ją, a ty będziesz mógł ustawić na talizmanie ścieżkę docelową i sprawdzić, jakie wyjścia teraz istnieją.\
		<br><br>Wyjście możesz wyłączyć, ścierając z niego jedno słowo zaklęciem Wymazania Słowa, a potem dopisując z powrotem Jaźń.\
		<br><br>Jeśli nad runą z złowieszczym dźwiękiem pęknie pusty bąbel skoku, znaczy to, że zniszczono odpowiadające jej wejście i położenie tej runy może zostać odkryte."
	var/network = ""

/datum/rune_spell/portalexit/New()
	..()
	GLOB.bloodcult_exitportals.Add(src)

/datum/rune_spell/portalexit/Destroy()
	GLOB.bloodcult_exitportals.Remove(src)
	return ..()

/datum/rune_spell/portalexit/cast()
	var/obj/effect/new_rune/R = spell_holder
	R.one_pulse()

	var/list/available_networks = GLOB.rune_words_english.Copy()
	for (var/datum/rune_spell/portalexit/P in GLOB.bloodcult_exitportals)
		if (P.network)
			available_networks -= P.network

	if (available_networks.len <= 0)
		to_chat(activator, span_warning("Za zasłoną nie ma już miejsca na kolejne Ścieżki.") )
		qdel(src)
		return

	var/list/choices = rune_word_display_list(available_networks)
	var/choice = tgui_input_list(activator, "Wybierz dostępną Ścieżkę. Możesz ją później zwolnić, ścierając runę.", "Wyjście ze Ścieżki", choices)
	var/chosen = choices[choice]
	if (!chosen || QDELETED(src))
		qdel(src)
		return
	for (var/datum/rune_spell/portalexit/P in GLOB.bloodcult_exitportals)
		if (P.network == chosen)//someone took it while we were choosing
			to_chat(activator, span_warning("Ktoś właśnie zajął tę Ścieżkę.") )
			qdel(src)
			return
	network = chosen

	// AQUILA - bez znacznika holomapy

	var/datum/rune_word/W = GLOB.rune_words[network]

	invoke(activator, "[W.rune]")
	var/image/I_crystals = image('aquila/icons/bloodcult/cult.dmi', "path_crystals")
	SET_PLANE_EXPLICIT(I_crystals, GAME_PLANE, spell_holder)
	var/image/I_stone = image('aquila/icons/bloodcult/cult.dmi', "path_stone")
	SET_PLANE_EXPLICIT(I_stone, GAME_PLANE, spell_holder)
	I_stone.appearance_flags |= RESET_COLOR//we don't want the stone to pulse

	var/image/I_network
	var/lookup = "[W.english]-0-[COLOR_BLOOD]"//0 because the rune will pulse anyway, and make this overlay pulse along
	if (lookup in GLOB.rune_appearances_cache)
		I_network = image(GLOB.rune_appearances_cache[lookup])
	else
		I_network = image('aquila/icons/bloodcult/deityrunes.dmi', icon_state = W.english)
		I_network.color = COLOR_BLOOD
	SET_PLANE_EXPLICIT(I_network, GAME_PLANE, spell_holder)
	I_network.transform /= 1.5
	I_network.pixel_x = round(W.offset_x*0.75)
	I_network.pixel_y = -3 + round(W.offset_y*0.75)

	spell_holder.overlays.len = 0
	spell_holder.overlays += I_crystals
	spell_holder.overlays += I_stone
	spell_holder.overlays += I_network
	custom_rune = TRUE

	to_chat(activator, span_notice("Ta runa będzie teraz celem Ścieżki \"[choice]\".") )

	var/datum/antagonist/cult/cult_datum = IS_CULTIST(activator)
	cult_datum?.gain_devotion(30, DEVOTION_TIER_1, "new_path_exit", R)

	talisman_absorb = RUNE_CAN_ATTUNE//once the network has been set, talismans will attune instead of imbue

/datum/rune_spell/portalexit/midcast(mob/add_cultist)
	to_chat(add_cultist, span_notice("Możesz przenieść się do tej runy przez Wejście na Ścieżkę albo dostrojony do niej talizman.") )

/datum/rune_spell/portalexit/midcast_talisman(mob/add_cultist)
	var/turf/T = get_turf(add_cultist)
	invoke(add_cultist, invocation, 1)
	anim(target = T, a_icon = 'aquila/icons/bloodcult/effects.dmi', flick_anim = "rune_teleport")
	new /obj/effect/bloodcult_jaunt (T, add_cultist, get_turf(spell_holder))

/datum/rune_spell/portalexit/cast_talisman()
	var/obj/item/talisman/T = spell_holder
	T.uses++//so the talisman isn't deleted when setting the network
	var/list/valid_choices = list()
	for (var/datum/rune_spell/portalexit/P in GLOB.bloodcult_exitportals)
		if (P.network)
			valid_choices[rune_word_display_name(P.network)] = P
	if (valid_choices.len <= 0)
		to_chat(activator, span_warning("Za zasłoną nie ma teraz żadnych Ścieżek.") )
		qdel(src)
		return
	var/choice = tgui_input_list(activator, "Wybierz dostępną Ścieżkę.", "Talizman Ścieżki", valid_choices)
	var/datum/rune_spell/portalexit/PE = valid_choices[choice]
	if (!PE || QDELETED(PE) || QDELETED(T))
		qdel(src)
		return

	var/datum/rune_word/W = GLOB.rune_words[PE.network]
	invoke(activator, "[W.rune]!", 1)

	to_chat(activator, span_notice("Ten talizman będzie teraz kluczem do Ścieżki \"[choice]\".") )

	T.attuned_rune = PE.spell_holder
	T.word_pulse(W)
	qdel(src)

/datum/rune_spell/portalexit/salt_act(turf/T)
	// AQUILA - w drafcie i vg pętla po wyjściach, której celem i tak było to wyjście
	if (T != spell_holder.loc)
		new /obj/effect/bloodcult_jaunt/traitor(T, null, get_turf(spell_holder), null)
