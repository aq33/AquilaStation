
/datum/rune_spell/portalentrance
	name = "Wejście na Ścieżkę"
	desc = "Skrót przez zasłonę między tym światem a tamtym."
	desc_talisman = "Użyj, by zdalnie uruchomić runę i przepchnąć przez Ścieżkę wszystko, co na niej stoi."
	invocation = "Sas'so c'arta forbici!"
	word1 = /datum/rune_word/travel
	word2 = /datum/rune_word/self
	word3 = /datum/rune_word/other
	talisman_absorb = RUNE_CAN_ATTUNE
	can_conceal = 1
	page = "Razem z runą Wyjścia ze Ścieżki ta runa pozwala tworzyć sieci teleportacyjne między dowolnymi dwoma polami w świecie. \
		Przy pierwszym użyciu runa poprosi o wybór ścieżki, do której się dostroi. Jest 10 ścieżek, każda odpowiada jednemu słowu kultu.\
		<br><br>Przy kolejnych użyciach runa po sekundzie przenosi wszystko, co nie jest przytwierdzone, do Wyjścia ze Ścieżki dostrojonego do tego samego słowa (jeśli go nie ma, teleportacja nie nastąpi).\
		<br><br>Talizmany zdalnie uruchamiają tę runę.\
		<br><br>Wejście możesz wyłączyć, ścierając z niego jedno słowo zaklęciem Wymazania Słowa, a potem dopisując z powrotem Inny.\
		<br><br>Jeśli załoga zniszczy tę runę solą albo świętą solą, pozna kierunek do odpowiadającego jej Wyjścia, o ile jest na tym samym poziomie."
	var/network = ""

/datum/rune_spell/portalentrance/cast()
	var/obj/effect/new_rune/R = spell_holder
	R.one_pulse()

	var/list/available_networks = rune_word_display_list(GLOB.rune_words_english)

	var/choice = tgui_input_list(activator, "Wybierz dostępną Ścieżkę. Możesz ją później zmienić, ścierając runę.", "Wejście na Ścieżkę", available_networks)
	network = available_networks[choice]
	if (!network || QDELETED(src))
		qdel(src)
		return

	var/datum/rune_word/W = GLOB.rune_words[network]

	invoke(activator, "[W.rune]")
	var/image/I_crystals = image('aquila/icons/bloodcult/cult.dmi', "path_pad")
	SET_PLANE_EXPLICIT(I_crystals, GAME_PLANE, R)
	var/image/I_stone = image('aquila/icons/bloodcult/cult.dmi', "path_entrance")
	SET_PLANE_EXPLICIT(I_stone, GAME_PLANE_UPPER, R)
	I_stone.appearance_flags |= RESET_COLOR//we don't want the stone to pulse

	var/image/I_network
	var/lookup = "[W.english]-0-[COLOR_BLOOD]"//0 because the rune will pulse anyway, and make this overlay pulse along
	if (lookup in GLOB.rune_appearances_cache)
		I_network = image(GLOB.rune_appearances_cache[lookup])
	else
		I_network = image('aquila/icons/bloodcult/deityrunes.dmi', icon_state = W.english)
		I_network.color = COLOR_BLOOD
	SET_PLANE_EXPLICIT(I_network, GAME_PLANE, R)
	I_network.transform /= 1.5
	I_network.pixel_x = round(W.offset_x*0.75)
	I_network.pixel_y = -3 + round(W.offset_y*0.75)

	spell_holder.overlays.len = 0
	spell_holder.overlays += I_crystals
	spell_holder.overlays += I_stone
	spell_holder.overlays += I_network
	custom_rune = TRUE

	// AQUILA - bez znacznika holomapy

	to_chat(activator, span_notice("Ta runa pozwoli ci teraz podróżować Ścieżką \"[choice]\".") )

	var/datum/antagonist/cult/cult_datum = IS_CULTIST(activator)
	cult_datum?.gain_devotion(30, DEVOTION_TIER_1, "new_path_entrance", R)

	talisman_absorb = RUNE_CAN_ATTUNE//once the network has been set, talismans will attune instead of imbue

/datum/rune_spell/portalentrance/midcast(mob/add_cultist, turf/cast_from)
	if (istype(spell_holder, /obj/item/talisman))
		invoke(add_cultist, invocation, 1)
	else
		invoke(add_cultist, invocation)

	var/turf/destination = null
	for (var/datum/rune_spell/portalexit/P in GLOB.bloodcult_exitportals)
		if (P.network == network)
			destination = get_turf(P.spell_holder)
			break

	if (!destination)
		to_chat(add_cultist, span_warning("Ścieżka \"[rune_word_display_name(network)]\" jest zamknięta. Postaw runę Wyjścia ze Ścieżki, by ją otworzyć.") )
		return

	var/datum/antagonist/cult/cult_datum = IS_CULTIST(add_cultist)

	var/turf/T = get_turf(spell_holder)
	if(cast_from)
		T = cast_from
	var/obj/effect/abstract/landing_animation = anim(target = T, a_icon = 'aquila/icons/bloodcult/effects.dmi', flick_anim = "cult_jaunt_prepare", plane = GAME_PLANE_UPPER)
	playsound(T, 'aquila/sound/bloodcult/cultjaunt_prepare.ogg', 75, 0, -3)
	addtimer(CALLBACK(src, PROC_REF(send_through), T, destination, add_cultist, cult_datum, landing_animation), 1 SECONDS)

/// Właściwy skok przez Ścieżkę po sekundzie (w drafcie spawn(10))
/datum/rune_spell/portalentrance/proc/send_through(turf/T, turf/destination, mob/add_cultist, datum/antagonist/cult/cult_datum, obj/effect/abstract/landing_animation)
	playsound(T, 'aquila/sound/bloodcult/cultjaunt_land.ogg', 30, 0, -3)
	var/obj/effect/bloodcult_jaunt/new_jaunt = new /obj/effect/bloodcult_jaunt(T, null, destination, T, activator)
	cult_datum?.gain_devotion(10, DEVOTION_TIER_0, "path_entrance", new_jaunt)
	if (landing_animation)
		flick("cult_jaunt_land", landing_animation)

/datum/rune_spell/portalentrance/midcast_talisman(mob/add_cultist)
	midcast(add_cultist, get_turf(add_cultist))

/datum/rune_spell/portalentrance/salt_act(turf/T)
	var/turf/destination = null
	for (var/datum/rune_spell/portalexit/P in GLOB.bloodcult_exitportals)
		if (P.network == network)
			destination = get_turf(P.spell_holder)
			new /obj/effect/bloodcult_jaunt/traitor(T, null, destination, null)
			break
