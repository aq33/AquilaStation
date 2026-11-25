// Wspomnienia zdarzeń z tg (code/datums/memory/general_memories.dm), po polsku.
// Postacie stoją w mianowniku, bo to nazwy zawodów bez odmiany („kuchmistrz”, „klaun”).
// Pominięte, bo nie mamy mechaniki: piątka, podanie ręki, celowanie z broni, atrament kałamarnicy,
// gra w karty, gniew boga za spalenie biblii, posłany całus (u nas tylko emotka), werbunek do braterstwa krwi.
// Pominięte też revolution_heads_defeated, którego tg nigdzie nie daje.

/// A doctor successfuly completed a surgery on someone.
/datum/memory/surgery
	story_value = STORY_VALUE_OKAY
	// Protagonist - The surgeon, completing the surgery
	// Deuteragonist - The mob being operated on
	/// What type of surgery it was
	var/surgery_type

/datum/memory/surgery/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	surgery_type,
)
	src.surgery_type = surgery_type
	return ..()

/datum/memory/surgery/get_names()
	return list("Operacja „[surgery_type]” – chirurg: [protagonist_name], pacjent: [deuteragonist_name].")

/datum/memory/surgery/get_starts()
	return list(
		"[protagonist_name] starannie przeprowadza operację „[surgery_type]”, a na stole leży [deuteragonist_name]",
		"[protagonist_name] sięga po piłę do kości, a pacjentem jest [deuteragonist_name]",
		"[deuteragonist_name] leży na stole operacyjnym, nad nim pochyla się [protagonist_name]",
	)

/datum/memory/surgery/get_moods()
	return list(
		"Po zakończeniu operacji [protagonist_name] [mood_verb].",
		"Krew pryska na twarz, a [protagonist_name] [mood_verb].",
		"Operacja trwa, a [protagonist_name] [mood_verb].",
		"[protagonist_name] [mood_verb], grzebiąc w pacjencie.",
		"[protagonist_name] [mood_verb], tnąc coraz głębiej.",
	)

/// Planted a bomb.
/datum/memory/bomb_planted
	story_value = STORY_VALUE_MEH
	// Protagonist - Whoever armed the bomb
	// Antaognist - The bomb that was armed

/datum/memory/bomb_planted/get_names()
	return list("Uzbrojenie ładunku ([antagonist_name]) – sprawca: [protagonist_name].")

/datum/memory/bomb_planted/get_starts()
	return list(
		"[protagonist_name] wciska złowieszczy przycisk, a [antagonist_name] zaczyna piszczeć",
		"[protagonist_name] z rozmachem kładzie na ziemi ładunek ([antagonist_name])",
		"[antagonist_name] budzi się do życia, uzbrojony przez postać, którą jest [protagonist_name]",
	)

/datum/memory/bomb_planted/get_moods()
	return list(
		"[protagonist_name] [mood_verb] i powoli odchodzi.",
		"Zaczyna się odliczanie, a [protagonist_name] [mood_verb].",
		"Licznik spada, a [protagonist_name] [mood_verb].",
		"Pip... pip... [protagonist_name] [mood_verb].",
	)

/datum/memory/bomb_planted/get_happy_moods()
	return list("jest zbyt fajny, żeby oglądać się za siebie")

/// Planted a SYNDICATE bomb.
/datum/memory/bomb_planted/syndicate
	story_value = STORY_VALUE_AMAZING

/// Planted a NUKE!
/datum/memory/bomb_planted/nuke
	story_value = STORY_VALUE_LEGENDARY

/// Was cyborgized.
/datum/memory/was_cyborged
	story_value = STORY_VALUE_OKAY
	memory_flags = MEMORY_FLAG_NOMOOD|MEMORY_SKIP_UNCONSCIOUS
	// Protagonist - The mind of who was just cyborgized

/datum/memory/was_cyborged/get_names()
	return list("Przemiana w cyborga – ofiara: [protagonist_name].")

/datum/memory/was_cyborged/get_starts()
	return list(
		"mózg, który kiedyś należał do postaci [protagonist_name], ląduje w metalowym korpusie",
		"[protagonist_name] zmienia się w kupę śrubek i blachy",
	)

/// Witnessed someone die nearby.
/datum/memory/witnessed_death
	story_value = STORY_VALUE_MEH // this is pretty common on this hellhole
	memory_flags = MEMORY_CHECK_BLINDNESS|MEMORY_CHECK_DEAFNESS|MEMORY_FLAG_NOMOOD
	// Protagonist - Who died

/datum/memory/witnessed_death/get_names()
	return list("Śmierć: [protagonist_name].")

/datum/memory/witnessed_death/get_starts()
	return list(
		"[protagonist_name] umiera",
		"[protagonist_name] sztywnieje i osuwa się bezwładnie, a oczy gasną",
		"serce, które biło w piersi postaci [protagonist_name], staje",
		"ostatnie chwile, jakie zostały postaci [protagonist_name]",
	)

/// Witnessed someone get creampied nearby.
/datum/memory/witnessed_creampie
	story_value = STORY_VALUE_OKAY
	memory_flags = MEMORY_CHECK_BLINDNESS
	// Protagonist - The mob that got pied

/datum/memory/witnessed_creampie/get_names()
	return list("Tort w twarz – ofiara: [protagonist_name].")

/datum/memory/witnessed_creampie/get_starts()
	return list(
		"[protagonist_name] dostaje tortem prosto w twarz",
		"twarz, którą ma [protagonist_name], znika pod warstwą kremu",
	)

/datum/memory/witnessed_creampie/get_moods()
	return list(
		"Krem kapie z twarzy, a [protagonist_name] [mood_verb].",
		"Czeka go dodatkowe pranie, więc [protagonist_name] [mood_verb].",
		"[protagonist_name] [mood_verb], zlizując resztki kremu.",
	)

/// Got slipped by something.
/datum/memory/was_slipped
	story_value = STORY_VALUE_MEH
	// Protagonist - The mob that got slipped
	// Antagonist - The thing that did the slipping (banana peel, etc)

/datum/memory/was_slipped/get_names()
	return list("Poślizgnięcie – ofiara: [protagonist_name].")

/datum/memory/was_slipped/get_starts()
	return list(
		"[protagonist_name] nie utrzymuje równowagi, bo pod nogami jest [antagonist_name]",
		"[protagonist_name] przewraca się jak długi, a winowajcą jest [antagonist_name]",
		"[antagonist_name] sprowadza na ziemię postać, którą jest [protagonist_name]",
	)

/datum/memory/was_slipped/get_moods()
	return list(
		"[protagonist_name] [mood_verb], gramoląc się z podłogi.",
		"Leżąc na ziemi, [protagonist_name] [mood_verb].",
	)

/datum/memory/was_slipped/get_sad_moods()
	return list("nie chce nawet wstawać i wygląda na przybitego")

/datum/memory/was_slipped/build_story_character(character)
	// We can slip on turfs, so we should account for it
	if(isturf(character))
		var/turf/place = character
		return "[prob(50) ? "zdradliwa, " : ""][pick("mokra", "nasmarowana", "śliska", "lodowata")] powierzchnia ([place.name])"

	return ..()

/// Had spaghetti fall from their pockets.
/datum/memory/lost_spaghetti
	story_value = STORY_VALUE_AMAZING // This doesn't happen very often
	memory_flags = MEMORY_CHECK_BLINDNESS
	// Protagonist - The mob losing their spaghet

/datum/memory/lost_spaghetti/get_names()
	return list("Spaghettiowa wpadka – sprawca: [protagonist_name].")

/datum/memory/lost_spaghetti/get_starts()
	return list(
		"z kieszeni, które ma [protagonist_name], wysypuje się spaghetti",
		"kieszenie nie mieszczą już spaghetti, które nosi [protagonist_name]",
	)

/datum/memory/lost_spaghetti/get_moods()
	return list(
		"Makaron sypie się na podłogę, a [protagonist_name] [mood_verb].",
		"[protagonist_name] [mood_verb], zbierając resztki z podłogi.",
	)

/// Had some good food.
/datum/memory/good_food
	story_value = STORY_VALUE_MEH
	// Protagonist - The mob consuming the food
	/// The name of the food item being consumed
	var/food

/datum/memory/good_food/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	obj/item/food,
)
	src.food = food.name
	return ..()

/datum/memory/good_food/get_names()
	return list("Pyszne danie ([food]) – zjada je [protagonist_name].")

/datum/memory/good_food/get_starts()
	return list(
		"[food] zmienia to, co [protagonist_name] myśli o jedzeniu",
		"po daniu ([food]) [protagonist_name] jest okrąglutki i syty",
		"[food] zostawia w pamięci postaci [protagonist_name] trwały ślad",
		"[protagonist_name] zajada się wyśmienitym daniem ([food])",
		"[protagonist_name] reaguje na danie ([food]) jak bohater anime o gotowaniu",
	)

/datum/memory/good_food/get_moods()
	return list("[protagonist_name] [mood_verb] i bierze kolejny kęs.")

/// Had a good drink.
/datum/memory/good_drink
	story_value = STORY_VALUE_MEH
	// Protagonist - The mob consuming the drink
	/// The name of the nice drink reagent
	var/drink

/datum/memory/good_drink/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	datum/reagent/drink,
)
	src.drink = drink.name
	return ..()

/datum/memory/good_drink/get_names()
	return list("Wyborny napój ([drink]) – pije go [protagonist_name].")

/datum/memory/good_drink/get_starts()
	return list(
		"[drink] zmienia to, co [protagonist_name] sądzi o eleganckim piciu",
		"[drink] zostawia w pamięci postaci [protagonist_name] trwały ślad",
		"[protagonist_name] delektuje się wybornym napojem ([drink])",
		"[protagonist_name] siorbie pyszny napój ([drink])",
	)

/datum/memory/good_drink/get_moods()
	return list("[protagonist_name] [mood_verb] i bierze kolejny łyk.")

/// Was set on fire and started to burn.
/datum/memory/was_burning
	story_value = STORY_VALUE_MEH
	// Protagonist - The mob burning

/datum/memory/was_burning/get_names()
	return list("Podpalenie – ofiara: [protagonist_name].")

/datum/memory/was_burning/get_starts()
	return list(
		"[protagonist_name] staje w płomieniach",
		"[protagonist_name] zmienia się w żywą pochodnię",
		"ogień ogarnia postać, którą jest [protagonist_name]",
	)

/datum/memory/was_burning/get_moods()
	return list("Skóra się topi, a [protagonist_name] [mood_verb].")

/// Got a limb removed by force.
/datum/memory/was_dismembered
	story_value = STORY_VALUE_AMAZING
	// Protagonist - The mob who lost a limb
	/// The limb (in plaintext) that got lost (ends up being "lewa ręka" or "prawa noga")
	var/lost_limb

/datum/memory/was_dismembered/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	obj/item/bodypart/lost_limb,
)
	src.lost_limb = lost_limb.name
	return ..()

/datum/memory/was_dismembered/get_names()
	return list("Utrata kończyny ([lost_limb]) – ofiara: [protagonist_name].")

/datum/memory/was_dismembered/get_starts()
	return list(
		"[protagonist_name] zyskuje prawo do miejsca parkingowego dla niepełnosprawnych",
		"[lost_limb] odlatuje w otchłań, a [protagonist_name] patrzy za nią",
		"[lost_limb] odpada z hukiem, a [protagonist_name] zostaje bez niej",
	)

/datum/memory/was_dismembered/get_moods()
	return list(
		"Bez tej kończyny ([lost_limb]) [protagonist_name] [mood_verb].",
		"[protagonist_name] [mood_verb] po utracie kończyny ([lost_limb]).",
	)

/// Our pet died...
/datum/memory/pet_died
	story_value = STORY_VALUE_AMAZING
	memory_flags = MEMORY_CHECK_BLINDNESS|MEMORY_CHECK_DEAFNESS
	// Protagonist - The mob who saw the pet die
	// Deuteragonist - The pet which died

/datum/memory/pet_died/get_names()
	return list("Śmierć pupila: [deuteragonist_name].")

/datum/memory/pet_died/get_starts()
	return list(
		"załoga oddaje hołd pupilowi statku ([deuteragonist_name])",
		"na pogrzeb pupila ([deuteragonist_name]) przychodzi garstka załogi",
		"płytki dołek, a w nim [deuteragonist_name]",
	)

/datum/memory/pet_died/get_moods()
	return list(
		"Bez pupila ([deuteragonist_name]) [protagonist_name] [mood_verb].",
		"[protagonist_name] [mood_verb], bo nie ma już pupila ([deuteragonist_name]).",
	)

/// The revolution was triumphant!
/// Given to head revs and those nearby when the revs win a revolution.
/datum/memory/revolution_rev_victory
	story_value = STORY_VALUE_LEGENDARY
	memory_flags = MEMORY_FLAG_NOSTATIONNAME|MEMORY_CHECK_BLINDNESS|MEMORY_CHECK_DEAFNESS
	// Protagonist - The head revolutionary that won the revolution

/datum/memory/revolution_rev_victory/get_names()
	return list("Rewolucja na [station_name()] – przywódca: [protagonist_name].")

/datum/memory/revolution_rev_victory/get_starts()
	return list(
		"[protagonist_name] wznosi sztandar rewolucji nad ciałami dawnych dyktatorów",
		"nad stosem ciał powiewa flaga, a obok stoi [protagonist_name]",
		"plakat z przekreślonym napisem „[station_name()]” ogłasza nową erę",
		"pomnik dawnego kapitana leży obalony, a obok stoi [protagonist_name]",
	)

/datum/memory/revolution_rev_victory/get_moods()
	return list(
		"Na widok upadku [station_name()] [protagonist_name] [mood_verb].",
		"Na myśl o nowej erze [protagonist_name] [mood_verb].",
	)

/// Given to head revs for failing the revolution!
/datum/memory/revolution_rev_defeat
	story_value = STORY_VALUE_NONE
	memory_flags = MEMORY_FLAG_NOSTATIONNAME|MEMORY_SKIP_UNCONSCIOUS
	// Protagonist - The head revolutionary that lost the revolution

/datum/memory/revolution_rev_defeat/get_names()
	return list(
		"Klęska z rąk Nanotrasen – pokonany: [protagonist_name].",
		"Koniec chwalebnej rewolucji – przywódca: [protagonist_name].",
	)

/datum/memory/revolution_rev_defeat/get_starts()
	return list("[protagonist_name] w hańbie ucieka z [station_name()], bo rewolucja upadła")

/datum/memory/revolution_rev_defeat/get_moods()
	return list("Po tej klęsce [protagonist_name] [mood_verb].")

/// Given to heads of staff, and those around them, upon defeating the revolutionaries.
/datum/memory/revolution_heads_victory
	story_value = STORY_VALUE_AMAZING // Not as cool as a rev victory. Everyone loves underdog stories
	memory_flags = MEMORY_FLAG_NOSTATIONNAME|MEMORY_SKIP_UNCONSCIOUS
	// Protagonist - The head of staff that won the revolution

/datum/memory/revolution_heads_victory/get_names()
	return list("Zwycięstwo Nanotrasen nad nienawistną rewolucją – obrońca: [protagonist_name].")

/datum/memory/revolution_heads_victory/get_starts()
	return list(
		"[protagonist_name] otrzepuje ręce po zwycięstwie nad rewolucją",
		"na mostku [station_name()] powiewa sztandar Nanotrasen, a obok dumnie stoi [protagonist_name]",
	)

// AQUILA: w tg ta procka przez pomyłkę nadpisywała revolution_rev_defeat, więc wspomnienie zwycięstwa nie miało zdań nastroju
/datum/memory/revolution_heads_victory/get_moods()
	return list("Rewolucja pokonana przez Nanotrasen, a [protagonist_name] [mood_verb].")

/// Watched someone receive a commendation medal
/datum/memory/received_medal
	story_value = STORY_VALUE_AMAZING
	memory_flags = MEMORY_FLAG_NOSTATIONNAME|MEMORY_CHECK_BLINDNESS|MEMORY_CHECK_DEAFNESS
	// Protagonist - The person being given a medal
	// Deuteragonist - The mob awarding a medal
	/// The name of the medal being rewarded
	var/medal_type
	/// The text on the medal / the commendation / the input
	var/medal_text

/datum/memory/received_medal/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	obj/item/medal_type,
	medal_text,
)
	src.medal_type = medal_type.name
	src.medal_text = medal_text
	return ..()

/datum/memory/received_medal/get_names()
	return list("Wręczenie odznaczenia ([medal_type]) – odznaczony: [protagonist_name].")

/datum/memory/received_medal/get_starts()
	return list(
		"[protagonist_name] przyjmuje odznaczenie ([medal_type]) z napisem „[medal_text]”, a wręcza je [deuteragonist_name]",
		"[protagonist_name] dostaje odznaczenie ([medal_type]) z inskrypcją „[medal_text]”",
		"[deuteragonist_name] wręcza odznaczenie ([medal_type]) z napisem „[medal_text]”, a odbiera je [protagonist_name]",
	)

/datum/memory/received_medal/get_moods()
	return list(
		"[protagonist_name] [mood_verb], odbierając medal.",
		"Z nowym odznaczeniem na piersi [protagonist_name] [mood_verb].",
	)

/// Killed a Megafauna
/datum/memory/megafauna_slayer
	story_value = STORY_VALUE_LEGENDARY
	// Protagonist - The person who killed the megafauna
	// Antagonist - The megafauna

/datum/memory/megafauna_slayer/get_names()
	return list("Rzeź potwora: [antagonist_name].")

/datum/memory/megafauna_slayer/get_starts()
	return list(
		"[protagonist_name] zadaje ostatni cios, a [antagonist_name] pada",
		"[protagonist_name] trzyma w dłoni głowę potwora ([antagonist_name])",
		"[antagonist_name], groźna megafauna, ginie, a nad truchłem stoi [protagonist_name]",
	)

/datum/memory/megafauna_slayer/get_moods()
	return list(
		"Żądza krwi gaśnie w oczach, a [protagonist_name] [mood_verb].",
		"[protagonist_name] [mood_verb], przeszukując truchło w poszukiwaniu łupów.",
	)

/// Won the jackpot on a slot machine
/datum/memory/won_jackpot
	story_value = STORY_VALUE_AMAZING

/datum/memory/won_jackpot/get_names()
	return list("Wielka wygrana – szczęściarz: [protagonist_name].")

/datum/memory/won_jackpot/get_starts()
	return list(
		"[protagonist_name] pociąga za dźwignię ([deuteragonist_name]), a w oczach ma symbole pieniędzy",
		"[deuteragonist_name] gra radosną melodyjkę, gdy [protagonist_name] pociąga za dźwignię",
	)

/datum/memory/won_jackpot/get_moods()
	return list(
		"[protagonist_name] [mood_verb], zgarniając pieniądze z maszyny.",
		"Maszyna z hukiem wypluwa pieniądze, a [protagonist_name] [mood_verb].",
	)

/// Saw someone get gibbed.
/datum/memory/witness_gib
	story_value = STORY_VALUE_OKAY
	memory_flags = MEMORY_CHECK_BLINDNESS|MEMORY_FLAG_NOMOOD
	// Protagonist - Who got gibbed

/datum/memory/witness_gib/get_names()
	return list("Rozerwanie na strzępy – ofiara: [protagonist_name].")

/datum/memory/witness_gib/get_starts()
	return list(
		"[protagonist_name] wybucha na drobne, mięsiste kawałki",
		"[protagonist_name] w mgnieniu oka zmienia się w mięsną pastę",
	)

/// Saw someone get crushed by a vending machine.
/datum/memory/witness_vendor_crush
	story_value = STORY_VALUE_OKAY
	memory_flags = MEMORY_CHECK_BLINDNESS|MEMORY_SKIP_UNCONSCIOUS
	// Protagonist - Who got crushed
	// Antagonist - The vendor that crushed them

/datum/memory/witness_vendor_crush/get_names()
	return list("Zgniecenie przez automat ([antagonist_name]) – ofiara: [protagonist_name].")

/datum/memory/witness_vendor_crush/get_starts()
	return list(
		"[antagonist_name] przygniata postać, którą jest [protagonist_name]",
		"[antagonist_name] przewraca się z hukiem, a pod spodem ląduje [protagonist_name]",
		"[protagonist_name] znika pod automatem ([antagonist_name])",
	)

/datum/memory/witness_vendor_crush/get_moods()
	return list(
		"[protagonist_name] [mood_verb], leżąc pod maszyną.",
		"Z automatu wypada smakołyk, a [protagonist_name] [mood_verb].",
	)

/// Saw someone get dusted by the supermatter.
/datum/memory/witness_supermatter_dusting
	story_value = STORY_VALUE_AMAZING
	memory_flags = MEMORY_CHECK_BLINDNESS
	// Protagonist - Who got dusted
	// Antagonist - The supermatter

/datum/memory/witness_supermatter_dusting/get_names()
	return list("Obrócenie w pył ([antagonist_name]) – ofiara: [protagonist_name].")

/datum/memory/witness_supermatter_dusting/get_starts()
	return list(
		"[protagonist_name] dotyka kryształu ([antagonist_name]) i zmienia się w kupkę kości",
		"[antagonist_name] obraca w popiół postać, którą jest [protagonist_name]",
		"[protagonist_name] podchodzi za blisko do kryształu ([antagonist_name]) i obraca się w pył",
	)

/datum/memory/witness_supermatter_dusting/get_moods()
	return list(
		"[protagonist_name] [mood_verb], rozpływając się w powietrzu.",
		"[protagonist_name] [mood_verb], rozpadając się na atomy.",
	)

/// Saw someone play Russian Roulette.
/datum/memory/witnessed_russian_roulette
	memory_flags = MEMORY_CHECK_BLINDNESS
	// Protagonist = The guy who played roulette
	// Antagonist = The revolver
	/// The bodypart the protagonist was aiming at
	var/aimed_at
	/// How many rounds were loaded in the revolver
	var/rounds_loaded
	/// The result of the game ("won"(survived) or "lost"(shot themselves))
	var/result

/datum/memory/witnessed_russian_roulette/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	aimed_at,
	rounds_loaded = 0,
	result,
)
	src.aimed_at = aimed_at
	src.rounds_loaded = rounds_loaded
	src.result = result

	if(result == "won")
		// The more bullets, the better the story.
		story_value = max(STORY_VALUE_NONE, rounds_loaded)
	else
		story_value = STORY_VALUE_SHIT

	return ..()

/datum/memory/witnessed_russian_roulette/get_names()
	return list("Rosyjska ruletka – gracz: [protagonist_name].")

/datum/memory/witnessed_russian_roulette/get_starts()
	return list(
		"[protagonist_name] celuje w siebie (cel: [aimed_at]) i zaraz pociągnie za spust",
		"w bębenku rewolweru siedzi nabojów: [rounds_loaded]",
		"[protagonist_name] stawia życie na jedną kartę i kręci bębenkiem",
	)

/datum/memory/witnessed_russian_roulette/get_moods()
	return list("[protagonist_name] [mood_verb], bo śmiertelna gra kończy się [result == "won" ? "wygraną" : "przegraną"].")

/// When a heretic finishes their ritual of knowledge
/datum/memory/heretic_knowledge_ritual
	story_value = STORY_VALUE_AMAZING
	// Protagonist = heretic

/datum/memory/heretic_knowledge_ritual/get_names()
	return list("Bezkresna wiedza z prastarych badań – poszukiwacz: [protagonist_name].")

/datum/memory/heretic_knowledge_ritual/get_starts()
	return list(
		"[protagonist_name] układa krąg ze świec i zielonej smoły",
		"wokół postaci [protagonist_name] same otwierają się księgi",
		"zielona i fioletowa energia otacza postać, którą jest [protagonist_name]",
		"[protagonist_name] z szeroko otwartymi, nieruchomymi oczami czyta dziwną księgę",
		"stos wnętrzności leży na skomplikowanej runie",
		"[protagonist_name] szkicuje szeroki, dziwny krąg",
	)

/datum/memory/heretic_knowledge_ritual/get_moods()
	return list("Dłoń jarzy się mocą, a [protagonist_name] [mood_verb].")

/datum/memory/heretic_knowledge_ritual/get_happy_moods()
	return list("rechocze jak szaleniec")

/datum/memory/heretic_knowledge_ritual/get_neutral_moods()
	return list("patrzy pustym wzrokiem z szerokim uśmiechem")

/datum/memory/heretic_knowledge_ritual/get_sad_moods()
	return list("śmieje się obłąkańczo")

/// Failed to defuse a bomb, by triggering it early.
/datum/memory/bomb_defuse_failure
	story_value = STORY_VALUE_NONE // Anyone who gets this is probably dead
	memory_flags = MEMORY_CHECK_BLINDNESS|MEMORY_CHECK_DEAFNESS
	// Protagonist = (failed) defuser
	// Antagonist = bomb

/datum/memory/bomb_defuse_failure/get_names()
	return list("Nieudane rozbrojenie ładunku ([antagonist_name]) – saper: [protagonist_name].")

/datum/memory/bomb_defuse_failure/get_starts()
	return list(
		"[protagonist_name] przecina zły przewód w ładunku ([antagonist_name])",
		"[protagonist_name] poci się nerwowo i zasłania twarz, gdy [antagonist_name] głośno huczy",
		"zegar na ładunku ([antagonist_name]) nagle skacze na zero",
	)

/datum/memory/bomb_defuse_failure/get_moods()
	return list("[protagonist_name] [mood_verb], przecinając przewód.")

/// Succeeded in defusing a bomb!
/datum/memory/bomb_defuse_success
	story_value = STORY_VALUE_LEGENDARY // Very sick, and can't be gotten from training bombs
	memory_flags = MEMORY_CHECK_BLINDNESS|MEMORY_CHECK_DEAFNESS
	// Protagonist = defuser
	// Antagonist = bomb
	/// This is the time left (in seconds) of the bomb at defusal
	var/bomb_time_left

/datum/memory/bomb_defuse_success/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	bomb_time_left = -1,
)
	src.bomb_time_left = bomb_time_left
	return ..()

/datum/memory/bomb_defuse_success/get_names()
	return list("Udane rozbrojenie ładunku ([antagonist_name]) – saper: [protagonist_name].")

/datum/memory/bomb_defuse_success/get_starts()
	return list(
		"[protagonist_name] przecina właściwy przewód w ładunku ([antagonist_name])",
		"[protagonist_name] poci się nerwowo i zasłania twarz, gdy [antagonist_name] wydaje przenikliwy pisk",
		"zegar na ładunku ([antagonist_name]) zatrzymuje się na [bomb_time_left] s",
	)

/datum/memory/bomb_defuse_success/get_moods()
	return list("[protagonist_name] [mood_verb], przecinając przewód.")

/// Catching a fish
/datum/memory/caught_fish
	story_value = STORY_VALUE_OKAY

/datum/memory/caught_fish/get_names()
	return list(
		"Złowienie prawdziwego okazu – wędkarz: [protagonist_name].",
		"Udany połów ([deuteragonist_name]) – wędkarz: [protagonist_name].",
	)

/datum/memory/caught_fish/get_starts()
	return list(
		"[protagonist_name] zwija żyłkę",
		"oczy postaci [protagonist_name] błyszczą, a kołowrotek zaczyna się kręcić",
		"w wędkarskim transie [protagonist_name] coś łowi",
		"[protagonist_name] toczy bój z rybą",
		"trwa wielkie wędkowanie",
	)

/datum/memory/caught_fish/get_moods()
	return list(
		"Z wody wyskakuje zdobycz ([deuteragonist_name]), a [protagonist_name] [mood_verb]!",
		"[protagonist_name] [mood_verb], łowiąc rybę ([deuteragonist_name])!",
		"[protagonist_name] [mood_verb] i pozuje ze zdobyczą ([deuteragonist_name])!",
	)

/datum/memory/caught_fish/get_sad_moods()
	return list("łowi ryby w ramach terapii")

/// Becoming a mutant via infusion
/datum/memory/dna_infusion
	story_value = STORY_VALUE_MEH
	///describing what they turn into, "skittish", "nomadic", etc
	var/mutantlike

/datum/memory/dna_infusion/New(
	datum/mind/memorizer_mind,
	atom/protagonist,
	atom/deuteragonist,
	atom/antagonist,
	mutantlike,
)
	src.mutantlike = mutantlike
	return ..()

/datum/memory/dna_infusion/get_names()
	return list(
		"Wszczepienie DNA ([deuteragonist_name]) – pacjent: [protagonist_name].",
		"Łączenie z DNA ([deuteragonist_name]) – śmiałek: [protagonist_name].",
	)

/datum/memory/dna_infusion/get_starts()
	return list(
		"[protagonist_name] wchodzi do upiornej maszyny do DNA",
		"[protagonist_name] bierze udział w szalonym eksperymencie",
		"infuzer DNA zamyka się, a w środku jest [protagonist_name]",
		"w komorze infuzera leży [deuteragonist_name]",
	)

/datum/memory/dna_infusion/get_moods()
	return list(
		"DNA miesza się z próbką ([deuteragonist_name]), a [protagonist_name] [mood_verb]!",
		"[protagonist_name] [mood_verb], stając się jednością z próbką ([deuteragonist_name]).",
		"[protagonist_name] [mood_verb], gdy w DNA wplata się [deuteragonist_name].",
	)

/datum/memory/dna_infusion/get_happy_moods()
	return list(
		"znosi ból dla nauki",
		"z pewną miną krzywi się z bólu",
	)

/datum/memory/dna_infusion/get_neutral_moods()
	return list(
		"wrzeszczy z bólu",
		"zaczyna mieć wątpliwości",
	)

/datum/memory/dna_infusion/get_sad_moods()
	return list("z goryczą wyrzeka się człowieczeństwa")

/// Who rev'd me, so if a mindreader reads a rev, they have a clue on who to hunt down
/datum/memory/recruited_by_headrev

/datum/memory/recruited_by_headrev/get_names()
	return list("Werbunek do rewolucji – zwerbowany: [protagonist_name], werbownik: [antagonist_name].")

/datum/memory/recruited_by_headrev/get_starts()
	return list(
		"[antagonist_name] błyska fleszem, a umysł, który ma [protagonist_name], skupia się na jednym krwawym celu: zabić szefów",
		"[antagonist_name] podnosi dziwne urządzenie do oczu postaci [protagonist_name] i wypala w nich mordercze rozkazy",
	)
