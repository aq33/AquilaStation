// Imiona obcokrajowców: gracz z angielskim w preferencjach losuje imię z oryginalnej puli NSV13 (angielskie imiona
// i nazwiska), a nie z polskiej. Dotyczy losowania w preferencjach (nowa postać, kostka, „zawsze losowe imię”).
// Tylko ludzie: inne gatunki (jaszczury, ćmy, IPC itd.) mają własne pule imion.

GLOBAL_LIST_INIT(aq_english_first_names_male, world.file2list("strings/names/en_first_male.txt"))
GLOBAL_LIST_INIT(aq_english_first_names_female, world.file2list("strings/names/en_first_female.txt"))
GLOBAL_LIST_INIT(aq_english_last_names, world.file2list("strings/names/last.txt"))

/// Angielskie imię i nazwisko jak w random_name() gatunku. unique: szuka imienia, którego nikt jeszcze nie nosi.
/proc/aq_english_random_name(gender, unique, lastname)
	for(var/attempt in 1 to 10)
		. = pick(gender == MALE ? GLOB.aq_english_first_names_male : GLOB.aq_english_first_names_female)
		. += " [lastname || pick(GLOB.aq_english_last_names)]"
		if(!unique || !findname(.))
			return

// Losowanie w oknie preferencji (kostka, nowa postać, domyślne imię) zna właściciela postaci.
// Tylko ludzie, bo inne gatunki mają własne pule imion.
/datum/character_save/aq_random_real_name(client/owner)
	if(owner?.wants_english() && istype(pref_species, /datum/species/human))
		return aq_english_random_name(gender, TRUE)
	return ..()

// „Zawsze losowe imię” losuje przy starcie rundy, gdy nie ma już usr z lobby: sprawdzamy właściciela postaci.
// Tylko ludzie, bo inne gatunki mają własne pule imion.
/datum/character_save/copy_to(mob/living/carbon/human/character, icon_updates = 1, roundstart_checks = TRUE)
	if(!be_random_name || !istype(pref_species, /datum/species/human) || !aq_owner_wants_english())
		return ..()
	real_name = aq_english_random_name(gender)
	// na czas ..() bez losowania w core; przywrócone także po runtime, żeby zapis postaci nie wyłączył graczowi opcji
	be_random_name = FALSE
	try
		. = ..()
	catch(var/exception/error)
		be_random_name = TRUE
		throw error
	be_random_name = TRUE

/datum/character_save/proc/aq_owner_wants_english()
	for(var/client/C as anything in GLOB.clients)
		if(C?.prefs?.active_character == src)
			return C.wants_english()
	return FALSE
