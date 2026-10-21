/*!
 * Tier 2 knowledge: Defensive tools and curses
 */

/**
 * Codex Morbus, an upgrade to the base codex
 * Functionally an upgraded version of the codex, but it also has the ability to cast curses by right clicking at a rune.
 * Requires you to have the blood of your victim in your off-hand
 */
/datum/heretic_knowledge/codex_morbus
	name = "Codex Morbus"
	desc = "Spisz Codex Morbus.<br>Rysuje runy i wysysa esencje nieco szybciej niż Codex Cicatrix.<br>\
		Kliknij prawym przyciskiem (w intencjach: na rozbrajaniu) na runę, by przeklinać członków załogi - do zadziałania klątwy potrzebujesz krwi celu w drugiej ręce \
		(najlepiej w połączeniu z Phylactery of Damnation)."
	transmute_text = "Transmutuj Codex Cicatrix i ciało w Codex Morbus."
	gain_text = "Grzbiet tego oprawnego w skórę tomu skrzypi z niesamowicie bolesnym westchnieniem. \
		Przewracanie stron wymaga sporego wysiłku i nie śmiem dłużej, niż to konieczne, rozważać tego, co podsuwa mi księga. \
		Mówi o nadchodzących zarazach, o czekających wyznawcach martwych i zapomnianych bogów i o zgubie śmiertelnego rodzaju. \
		Mówi o igłach, którymi zdziera się skórę świata, by zostawić go na zgniliznę. I mówi do mnie po imieniu."
	required_atoms = list(
		/obj/item/codex_cicatrix = 1,
		/mob/living/carbon/human = 1,
	)
	result_atoms = list(/obj/item/codex_cicatrix/morbus)
	cost = 2
	research_tree_icon_path = 'aquila/icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "book_morbus"
	drafting_tier = 2

// AQUILA - u nas nie ma ran (/datum/wound): zamiast krytycznych ran ciętych i złamań ciało dostaje ciężkie obrażenia i krwotok
/datum/heretic_knowledge/codex_morbus/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	var/mob/living/carbon/human/to_fuck_up = locate() in selected_atoms
	if(!to_fuck_up)
		return TRUE
	for(var/obj/item/bodypart/limb as anything in to_fuck_up.get_bodyparts())
		limb.receive_damage(brute = 15)
	to_fuck_up.add_bleeding(BLEED_CRITICAL)
	to_fuck_up.updatehealth()
	return TRUE

/datum/heretic_knowledge/greaves_of_the_prophet
	name = "Greaves of the Prophet"
	desc = "Wykuj parę Opancerzonych Nagolenników, które dają całkowitą odporność na poślizgnięcia."
	transmute_text = "Transmutuj parę butów i dwa arkusze tytanu albo srebra."
	gain_text = " \
		Chrząstka wkręca się w staw, trzask, i głupiec wyrywa sczerniałą stopę ze \
		szczęk drugiego. Od wieków toczą tę grę - to poszarpane drzewo kończyn wije się, \
		miotając sidłami wbitymi w warczące dziąsła, chcąc rozszarpać ciężar przeszczepionych \
		sąsiadów. Przygniecione pociętymi stopami, to korona zjełczałych idiotów wiecznie szuka \
		rozwiązania własnych więzów. Lękam się iść ich śladem, ale i tak \
		muszę iść dalej. Ich rytm podtrzymuje waśń, obojętny na \
		bariery i granice. Wciągają w swój zamęt kolejnych, gdy tańczą walca."
	required_atoms = list(
		/obj/item/clothing/shoes = 1,
		list(/obj/item/stack/sheet/mineral/titanium, /obj/item/stack/sheet/mineral/silver) = 2,
	)
	result_atoms = list(/obj/item/clothing/shoes/greaves_of_the_prophet)
	cost = 2
	research_tree_icon_path = 'icons/obj/clothing/shoes.dmi'
	research_tree_icon_state = "hereticgreaves"
	drafting_tier = 2

/datum/heretic_knowledge/spell/opening_blast
	name = "Wave Of Desperation"
	desc = "Daje Wave Of Desperation - zaklęcie, które można rzucić tylko, gdy jesteś skrępowany.<br>\
		Zrywa więzy, odrzuca i przewraca osoby obok, a na wszystko w pobliżu nakłada Uchwyt Mansusa."
	gain_text = "Moje kajdany puszczają w mrocznej furii, a ich wątłe więzy kruszą się przed moją mocą."
	required_atoms = list(
		/obj/item/clothing/suit/straight_jacket = 1,
	)
	action_to_add = /datum/action/cooldown/spell/aoe/wave_of_desperation
	cost = 2
	drafting_tier = 2
	max_charges = 1
	path_recharge_amount = 0.0
	transmute_text = "By odnowić ładunek, wykonaj rytuał z kaftanem bezpieczeństwa."

/datum/heretic_knowledge/rune_carver
	name = "Carving Knife"
	desc = "Stwórz Nóż Rytowniczy.<br>\
		Nóż Rytowniczy pozwala wyryć trudne do zauważenia pułapki, które działają na pogan, którzy na nie wejdą.<br>\
		Nadaje się też do rzucania."
	transmute_text = "Transmutuj nóż, odłamek szkła i kartkę papieru."
	gain_text = "Wyryte, wycięte... wieczne. We wszystkim kryje się moc. Mogę ją odsłonić! \
		Mogę wyrzeźbić monolit, by odsłonić łańcuchy!"
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/shard = 1,
		/obj/item/paper = 1,
	)
	result_atoms = list(/obj/item/melee/rune_carver)
	cost = 2
	research_tree_icon_path = 'aquila/icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "rune_carver"
	drafting_tier = 2

/datum/heretic_knowledge/ether
	name = "Ether of the Newborn"
	desc = "Uwarz jednorazową miksturę.<br>Wypicie jej przywraca pełnię zdrowia i \
		usuwa wszelkie nieprawidłowości z ciała (w tym choroby, traumy i implanty) - \
		ale na pełną minutę tracisz przytomność."
	transmute_text = "Transmutuj kałużę wymiocin i odłamek szkła."
	gain_text = "Wzrok i myśli mętnieją, gdy opary tej posoki unoszą się ku mnie. \
		Przez mgłę widzę, jak patrzy na mnie z ulgą coś, co ohydnie przypomina moją twarz. \
		To temu nędznemu tworowi oddaję swój los i to jego los wyrywam z mgły snów. Głupcy z nas obu."
	required_atoms = list(
		/obj/item/shard = 1,
		/obj/effect/decal/cleanable/vomit = 1,
	)
	result_atoms = list(/obj/item/ether)
	cost = 2
	research_tree_icon_path = 'aquila/icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "poison_flask"
	drafting_tier = 2

/datum/heretic_knowledge/painting
	name = "Unsealed Arts"
	desc = "Namaluj klątwę. \
		Każdy obraz ma własny efekt i przepis. \
		<br>&bull; The Sister and He Who Wept: oczyszcza twój umysł, a pogan przeklina halucynacjami. \
		<br>&bull; The Feast of Desire: daje ci losowe organy, a pogan przeklina głodem mięsa. \
		<br>&bull; Great Chaparral Over Rolling Hills: po zawieszeniu rozsiewa kudzu i daje ci maki i dzwonki. \
		<br>&bull; Lady of the Gate: usuwa twoje mutacje, a pogan mutuje i przeklina drapaniem się. \
		<br>&bull; Master of the Rusted Mountain: przeklina pogan, by rdzewiała podłoga, po której chodzą."
	transmute_text = "Transmutuj płótno i dodatkowy przedmiot, by stworzyć obraz. \
		<br>&bull; Parę oczu dla The Sister and He Who Wept \
		<br>&bull; Odciętą kończynę dla The Feast of Desire \
		<br>&bull; Dowolny plon roślinny dla Great Chaparral Over Rolling Hills \
		<br>&bull; Dowolną parę rękawic dla Lady of the Gate \
		<br>&bull; Kawałek śmiecia dla Master of the Rusted Mountain"
	gain_text = "Przenika mnie wiatr natchnienia. Za zasłoną i za bramą istnieją wielkie dzieła, jeszcze nienamalowane. \
		Tęsknią za śmiertelnymi oczami, więc dam im widownię."
	required_atoms = list(/obj/item/canvas = 1)
	result_atoms = list(/obj/item/canvas)
	cost = 2
	research_tree_icon_path = 'aquila/icons/obj/signs.dmi'
	research_tree_icon_state = "eldritch_painting_weeping"
	drafting_tier = 2

/datum/heretic_knowledge/painting/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	// AQUILA - dodatkowy składnik idzie prosto do selected_atoms; zmiana required_atoms działała dopiero przy następnym rytuale
	var/static/list/extra_ingredients = list(
		/obj/item/organ/eyes = /obj/item/wallframe/painting/eldritch/weeping,
		/obj/item/bodypart = /obj/item/wallframe/painting/eldritch/desire,
		/obj/item/food/grown = /obj/item/wallframe/painting/eldritch/vines,
		/obj/item/clothing/gloves = /obj/item/wallframe/painting/eldritch/beauty,
		/obj/item/trash = /obj/item/wallframe/painting/eldritch/rust,
	)
	for(var/ingredient_type in extra_ingredients)
		var/atom/movable/ingredient = locate(ingredient_type) in atoms
		if(!ingredient)
			continue
		src.result_atoms = list(extra_ingredients[ingredient_type])
		selected_atoms |= ingredient
		return TRUE

	user.balloon_alert(user, "brak dodatkowego składnika!")
	return FALSE

/datum/heretic_knowledge/hypnosis_ritual
	name = "Unwrap Minds"
	desc = "Wystawia poganina bezpośrednio na grozę Mansusa, hipnotyzując go."
	transmute_text = "Transmutuj skalpel, odłamek szkła, kartkę papieru i żywego poganina."
	notice = "Poganin zostanie zahipnotyzowany tym, co napiszesz na kartce.\
		<br>Jeśli poganin ma implant lojalności, implant pęknie - ale hipnoza może wtedy wyjść inna, niż się spodziewasz.\
		<br>Rytuał nie działa na innych heretyków."
	gain_text = "Moja wspinaczka była samotna, ale zrozumiałem, że nie musi taka być. \
		Mogę pokazać im prawdę. Ich słabe, śmiertelne umysły mogą nie wytrzymać objawienia, ale z ich popiołów powstanie feniks, wolny i prawdziwy."
	required_atoms = list(
		/obj/item/scalpel = 1,
		/obj/item/shard = 1,
		/obj/item/paper = 1,
		/mob/living/carbon/human = 1,
	)
	cost = 2
	research_tree_icon_path = 'aquila/icons/hud/screen_alert.dmi'
	research_tree_icon_state = "hypnosis"
	drafting_tier = 2
	/// tg: lista "hypnosis" z strings/antagonist_flavor/heretic_influences.json
	var/static/list/default_hypnosis = list(
		"OBSERWUJĄ MNIE. ZEWSZĄD. TRZEBA ICH OŚLEPIĆ.",
		"WIDZĘ WSZYSTKO. ZA DUŻO. MOJE OCZY SĄ ZBYT OTWARTE, ZBYT SŁABE.",
		"WIDZĘ PRZYSZŁOŚĆ. NADCHODZI GROZA. TRZEBA JĄ POWSTRZYMAĆ.",
		"JESTEŚMY TACY NIEISTOTNI. MUSZĘ BYĆ CZYMŚ WIĘKSZYM.",
		"BROŃ, NARZĘDZIA, UZBROJENIE - POTRZEBUJĘ WSZYSTKIEGO. MUSZĘ BYĆ GOTÓW.",
		"NADCHODZĄ. NADCHODZĄ PO MNIE. MUSZĘ BYĆ GOTÓW.",
	)

/datum/heretic_knowledge/hypnosis_ritual/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	for(var/mob/living/carbon/human/victim in atoms)
		if(victim.stat == DEAD || IS_HERETIC(victim) || victim.has_trauma_type(/datum/brain_trauma/hypnosis))
			atoms -= victim

	var/has_paper = FALSE
	var/has_written_text = FALSE
	for(var/obj/item/paper/paper in atoms)
		has_paper = TRUE
		if(length(paper.raw_text_inputs))
			has_written_text = TRUE

	if(!has_written_text && has_paper)
		loc.balloon_alert(user, "napisz hipnozę na kartce!")
		return FALSE

	return ..()

/datum/heretic_knowledge/hypnosis_ritual/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/hypnosis_text = ""
	for(var/obj/item/paper/paper in selected_atoms)
		for(var/datum/paper_input/text as anything in paper.raw_text_inputs)
			hypnosis_text += "[strip_html(text.raw_text, MAX_MESSAGE_LEN)] "
		paper.burn()
		selected_atoms -= paper

	hypnosis_text = trim(hypnosis_text, MAX_MESSAGE_LEN)
	for(var/mob/living/carbon/human/victim in selected_atoms)
		var/specific_hypnosis_text = (HAS_TRAIT(victim, TRAIT_MINDSHIELD) || !hypnosis_text) ? pick(default_hypnosis) : hypnosis_text
		for(var/obj/item/implant/mindshield/shield in victim.implants)
			shield.removed(victim, silent = FALSE)
			shield.forceMove(victim.drop_location())
			shield.burn()

		selected_atoms -= victim
		// lobotomy resistance because it might be a bit rough to make this permanent aye
		// future note: if people just spam hypnosis to make an army to rush ascension, make it so hypnosis is broken by witnessing sacrifices
		var/datum/brain_trauma/hypnosis/trauma = new(specific_hypnosis_text)
		victim.gain_trauma(trauma, TRAUMA_RESILIENCE_LOBOTOMY)

	return TRUE
