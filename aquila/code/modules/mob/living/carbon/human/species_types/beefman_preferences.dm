// Okno postaci mięsoczłowieka: wysmażenie (kolor), oczy i usta z przypraw, opis, historia i cechy.
// Wpisy to /datum/preference z aquila/code/modules/client/preferences_menu/ (kategoria features: guziki z ikonami, bez TSX).

/// Głowa i tułów mięsoczłowieka do ikon w oknie postaci
/proc/beefman_pref_base_icon(color, eyes_state = "olives", mouth_state = "smile")
	var/icon/base = icon(BEEFMAN_BODYPARTS_ICON, "beefman_chest", SOUTH)
	base.Blend(icon(BEEFMAN_BODYPARTS_ICON, "beefman_head", SOUTH), ICON_OVERLAY)
	base.Blend("#[color]", ICON_MULTIPLY)
	if(eyes_state)
		base.Blend(icon(BEEFMAN_BODYPARTS_ICON, "[eyes_state]_head", SOUTH), ICON_OVERLAY)
	if(mouth_state)
		base.Blend(icon(BEEFMAN_BODYPARTS_ICON, "[mouth_state]_head", SOUTH), ICON_OVERLAY)
	return aq_pref_head_crop(base)

/datum/preference/choiced/beefman_color
	db_key = "feature_beef_color"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	feature_key = FEATURE_BEEF_COLOR
	relevant_mutant_bodypart = FEATURE_BEEF_COLOR
	main_feature_name = "Wysmażenie"
	should_generate_icons = TRUE
	can_randomize = TRUE

/datum/preference/choiced/beefman_color/init_possible_values()
	var/list/values = list()
	for(var/name in GLOB.beefman_colors)
		values += name
	return values

/datum/preference/choiced/beefman_color/icon_for(value)
	return beefman_pref_base_icon(GLOB.beefman_colors[value])

/datum/preference/choiced/beefman_eyes
	db_key = "feature_beef_eyes"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	feature_key = FEATURE_BEEF_EYES
	relevant_mutant_bodypart = FEATURE_BEEF_EYES
	main_feature_name = "Oczy"
	should_generate_icons = TRUE
	can_randomize = TRUE

/datum/preference/choiced/beefman_eyes/init_possible_values()
	var/list/values = list()
	for(var/name in GLOB.beefman_eyes)
		values += name
	return values

/datum/preference/choiced/beefman_eyes/icon_for(value)
	return beefman_pref_base_icon(GLOB.beefman_colors["Bardzo krwisty"], GLOB.beefman_eyes[value], null)

/datum/preference/choiced/beefman_mouth
	db_key = "feature_beef_mouth"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	feature_key = FEATURE_BEEF_MOUTH
	relevant_mutant_bodypart = FEATURE_BEEF_MOUTH
	main_feature_name = "Usta"
	should_generate_icons = TRUE
	can_randomize = TRUE

/datum/preference/choiced/beefman_mouth/init_possible_values()
	var/list/values = list()
	for(var/name in GLOB.beefman_mouths)
		values += name
	return values

/datum/preference/choiced/beefman_mouth/icon_for(value)
	return beefman_pref_base_icon(GLOB.beefman_colors["Bardzo krwisty"], null, GLOB.beefman_mouths[value])

// --- Opis w oknie wyboru gatunku ---

/datum/species/beefman/get_species_description()
	return "Mięsoludzie są w całości zrobieni z wołowiny, więc ich mózgi mają poważne wady: \
		cierpią na ciągłe omamy i widzą „rozdarcia rzeczywistości”."

/datum/species/beefman/get_species_lore()
	return list(
		"W 2437 roku postneosowiecka restauracja „Skrzypek” serwowała jedzenie na pokładzie wycieczkowca Mustai Karim. Krótko po rozpoczęciu obiadu \
			w kuchni skończyło się mięso na burgery. Losowano zapałki i młody kucharz, nieświadomy tego, co zaraz nastąpi, poszedł po mięso do kostnicy. \
			„Przecież robimy to cały czas, prawda? Zmarłym ciała już niepotrzebne, to tylko zaradność…” – pomyślał. \
			Chwycił pierwsze ciało, jakie wpadło mu w ręce, i pospieszył się, żeby to niewdzięczne zadanie nie zapadło mu w pamięć. \
			Nie zauważył, że wskaźnik możliwości ożywienia na tej tacy świecił na zielono. Ciało miało duszę, i to zdecydowaną nie dać się zmielić.",

		"Młody kucharz wrócił do chłodni i wepchnął zwłoki do maszynki do mięsa. Maszyna z trudem mieliła na nieulepszonych częściach. \
			Gdy całe ciało było już w środku, ostrza nagle stanęły i z okropnym zgrzytem zaczęły kręcić się w drugą stronę. \
			Kucharz odruchowo spojrzał, a ku jego przerażeniu z płata mięsa patrzyły na niego żywe, a zarazem lunatyczne oczy.",

		"Mniej więcej wtedy Mustai Karim zniknął z systemu śledzenia statków. Zorganizowano poszukiwania, ale przerwano je, gdy zaginiony statek \
			dotarł do celu z trzydniowym opóźnieniem. Większość załogi poza niezbędną zniknęła, a Trzecia Sowiecka Straż Przybrzeżna po krótkim śledztwie \
			ogłosiła zawiłe wyjaśnienie o piractwie, nieporozumieniach i bezprecedensowym pechu.",

		"Trzy lata później w postneosowieckiej przestrzeni pojawiły się doniesienia o włóczęgach bez skóry. W centrum zagadki leżał mało znany \
			wojskowy ośrodek badawczy, który przypadkiem wybuchł tuż przed początkiem „Аномальные появления”. Trzeci Rząd Sowiecki zamilkł zupełnie, \
			więc ludzie musieli sami szukać wyjaśnień. Większość uznała to za makabryczną modę, niektórzy wymyślali naukowe teorie o wpływie \
			kosmicznego promieniowania na ludzkie geny, a jeszcze inni rozpuszczali plotki o tajnych, rządowych „eksperymentach ze snem”. \
			Niezależnie od pochodzenia „mięsoludzie” szybko wtopili się w galaktyczne społeczeństwo. Żaden z nich nie wiódł całkiem normalnego życia: \
			w ogóle nie potrafili zasnąć i najwyraźniej umieli przemierzać niewytłumaczalną podprzestrzenną sieć tego, co nazywali „rozdarciami Fobetora”. \
			Dzięki odkryciu sieci Fobetora spotyka się ich dziś na niemal każdej stacji badawczej.",
	)

/datum/species/beefman/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "handshake",
			SPECIES_PERK_NAME = "Mięsiste kończyny",
			SPECIES_PERK_DESC = "Mięsoludzie odrywają i przyczepiają sobie kończyny, kiedy chcą. Wskaż rękę, nogę albo usta i kliknij siebie pustą ręką \
				prawym przyciskiem (na intencji rozbrajania). Płat mięsa wciśnięty w kikut wyrasta w nową kończynę.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "running",
			SPECIES_PERK_NAME = "Biegacze",
			SPECIES_PERK_DESC = "Mięsoludzie są szybsi od większości humanoidów.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "temperature-low",
			SPECIES_PERK_NAME = "Miłośnicy chłodu",
			SPECIES_PERK_DESC = "Mięsoludzie są całkowicie odporni na zimno. Niska temperatura nawet powstrzymuje ich krwawienie.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "link",
			SPECIES_PERK_NAME = "Rozdarcia Fobetora",
			SPECIES_PERK_DESC = "Mięsoludzie widzą rozdarcia Fobetora: małe szczeliny w rzeczywistości, które na chwilę łączą przypadkowe miejsca. \
				Wiedzą, dokąd prowadzi każde rozdarcie, ale przejdą tylko wtedy, gdy nikt nie patrzy na żadną ze stron.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "bed",
			SPECIES_PERK_NAME = "Bezsenni",
			SPECIES_PERK_DESC = "Mięsoludzie w ogóle nie zasypiają, więc nic ich nie uśpi.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "shield-alt",
			SPECIES_PERK_NAME = "Mięso bez skóry",
			SPECIES_PERK_DESC = "Mięsoludzie są z samego mięsa i nie mają skóry, więc odnoszą o 20% większe obrażenia. Kończyny łatwo im odpadają.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "tint",
			SPECIES_PERK_NAME = "Krwawienie sokiem",
			SPECIES_PERK_DESC = "Mięsoludzie zaczynają puszczać sok ze wszystkich kończyn, gdy ich ciało ma ponad [BEEFMAN_BLEEDOUT_LEVEL - T0C]°C. \
				Oparzenia przypiekają mięso i zmniejszają krwawienie, a sól je nasila. Opatrunek zatrzymuje sok z kończyny na chwilę, a opaska uciskowa na stałe.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "briefcase-medical",
			SPECIES_PERK_NAME = "Niezdrowy umysł",
			SPECIES_PERK_DESC = "Mięsoludzie mają trwały uraz mózgu. Przejście przez rozdarcie przy złym samopoczuciu sprowadza omamy.",
		),
	)

	return to_add
