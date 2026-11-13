// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
// treat_message() dokleja kropkę na końcu zdania, stąd kropki w oczekiwanych tekstach
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Obcokrajowiec: bez tłumacza mówi po angielsku, z tłumaczem załoga słyszy polski we Wspólnym (z pamięci tłumaczeń, bez sieci)
/datum/unit_test/aquila_foreigner
	var/heard_language
	var/heard_raw
	var/list/heard_mods

/datum/unit_test/aquila_foreigner/proc/on_hear(datum/source, list/hearing_args)
	SIGNAL_HANDLER
	heard_language = hearing_args[3]
	heard_raw = hearing_args[HEARING_RAW_MESSAGE]
	heard_mods = hearing_args[7]

/datum/unit_test/aquila_foreigner/Run()
	var/mob/living/carbon/human/foreigner = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/crew = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	foreigner.mind_initialize()
	foreigner.aq_make_foreigner()
	TEST_ASSERT(foreigner.mind.aq_foreigner, "Foreigner flag was not set on the mind")
	TEST_ASSERT(!foreigner.has_language(/datum/language/common), "Foreigner still understands Common")
	TEST_ASSERT(foreigner.has_language(/datum/language/english, TRUE), "Foreigner cannot speak English")
	TEST_ASSERT(foreigner.get_selected_language() == /datum/language/english, "Foreigner does not speak English by default (tongue list?)")
	TEST_ASSERT(!crew.has_language(/datum/language/english), "Crew should not understand English")

	RegisterSignal(crew, COMSIG_MOVABLE_HEAR, PROC_REF(on_hear))

	// Bez tłumacza: angielski, którego załoga nie rozumie
	foreigner.say("Hello there")
	TEST_ASSERT(heard_language == /datum/language/english, "Speech without translator was not English: [heard_language]")
	TEST_ASSERT(heard_raw == "Hello there.", "Speech without translator changed: [heard_raw]")

	// Z tłumaczem i zdaniem w pamięci: polski we Wspólnym, przedrostek szeptu zostaje
	var/obj/item/aquila_translator/translator = allocate(/obj/item/aquila_translator, run_loc_floor_bottom_left)
	TEST_ASSERT(foreigner.put_in_hands(translator), "Could not pick up the translator")
	TEST_ASSERT(HAS_TRAIT(foreigner, TRAIT_AQ_TRANSLATOR), "Translator in hand gives no trait")
	SStranslation.cache_set(DEEPL_LANG_EN, DEEPL_LANG_PL, "Hello there", "Cześć")
	heard_raw = null
	foreigner.say("Hello there")
	TEST_ASSERT(heard_language == /datum/language/common, "Translated speech was not Common: [heard_language]")
	TEST_ASSERT(heard_raw == "Cześć.", "Crew did not hear the translation: [heard_raw]")
	heard_raw = null
	foreigner.say("#Hello there")
	TEST_ASSERT(heard_raw == "Cześć.", "Whispered translation lost: [heard_raw]")
	TEST_ASSERT(heard_mods?[WHISPER_MODE], "Whisper prefix was lost after translation")
	TEST_ASSERT(!foreigner.aq_translated_say, "Translated say flag stayed on")
	TEST_ASSERT(!HAS_TRAIT(foreigner, TRAIT_AQ_TRANSLATED_SPEECH), "Filter bypass trait stayed on after the translated say")

	// Własny czasownik: przetłumaczony trafia do message_mods, a nie do treści
	SStranslation.cache_set(DEEPL_LANG_EN, DEEPL_LANG_PL, "shouts", "krzyczy")
	heard_raw = null
	foreigner.say("shouts*Hello there")
	TEST_ASSERT(heard_raw == "Cześć.", "Custom verb leaked into the translated speech: [heard_raw]")
	TEST_ASSERT(heard_mods?[MODE_CUSTOM_SAY_EMOTE] == "krzyczy", "Translated custom verb was lost: [heard_mods?[MODE_CUSTOM_SAY_EMOTE]]")
	// Gwiazdka w tłumaczeniu zostaje w treści i nie robi z niej czasownika
	SStranslation.cache_set(DEEPL_LANG_EN, DEEPL_LANG_PL, "Star please", "Gwiazdka * proszę")
	heard_raw = null
	foreigner.say("Star please")
	TEST_ASSERT(heard_raw == "Gwiazdka * proszę.", "Asterisk in the translation was changed: [heard_raw]")
	TEST_ASSERT(!heard_mods?[MODE_CUSTOM_SAY_EMOTE], "Asterisk in the translation became a custom verb")
	// Tłumaczenie zaczynające się od gwiazdki zostaje mową, a nie emotką
	SStranslation.cache_set(DEEPL_LANG_EN, DEEPL_LANG_PL, "Star first", "*macha*")
	heard_raw = null
	foreigner.say("Star first")
	TEST_ASSERT(findtext("[heard_raw]", "macha"), "Translation starting with an asterisk became an emote: [heard_raw]")

	// Bez klucza API i bez pamięci: tekst przechodzi bez tłumaczenia, ale we Wspólnym
	if(!CONFIG_GET(string/deepl_api_key))
		heard_raw = null
		foreigner.say("Sentence nobody translated")
		TEST_ASSERT(heard_language == /datum/language/common, "Untranslated fallback was not Common: [heard_language]")
		TEST_ASSERT(heard_raw == "Sentence nobody translated.", "Untranslated fallback changed the text: [heard_raw]")

	// Słuchanie: z tłumaczem polska mowa idzie do tłumacza, bez niego zostaje bełkot
	TEST_ASSERT(foreigner.aq_hears_via_translator(/datum/language/common), "Foreigner with translator does not get Polish speech translated")
	TEST_ASSERT(!crew.aq_hears_via_translator(/datum/language/common), "Crew without foreigner flag would get speech translated")
	foreigner.dropItemToGround(translator)
	TEST_ASSERT(!HAS_TRAIT(foreigner, TRAIT_AQ_TRANSLATOR), "Dropped translator still works")
	TEST_ASSERT(!foreigner.aq_hears_via_translator(/datum/language/common), "Foreigner without translator still gets translations")

	// Spóźnione tłumaczenie po śmierci nie wychodzi (say() puściłby je na czat duchów)
	heard_raw = null
	foreigner.death()
	foreigner.aq_translator_say("", FALSE, FALSE, list("Too late"), null, list(), /datum/language/english, list("Za późno"))
	TEST_ASSERT(isnull(heard_raw), "Dead foreigner still spoke the late translation: [heard_raw]")

	UnregisterSignal(crew, COMSIG_MOVABLE_HEAR)
	SSticker.minds -= foreigner.mind
	SStranslation.cache = list()

/// Języki antagonistów tłumaczą się bez tłumacza, a wbudowany tłumacz idzie z umysłem na nowe ciało (kult: konstrukt)
/datum/unit_test/aquila_foreigner_antag_language
	var/heard_language
	var/heard_raw
	var/list/heard_mods

/datum/unit_test/aquila_foreigner_antag_language/proc/on_hear(datum/source, list/hearing_args)
	SIGNAL_HANDLER
	heard_language = hearing_args[3]
	heard_raw = hearing_args[HEARING_RAW_MESSAGE]
	heard_mods = hearing_args[7]

/datum/unit_test/aquila_foreigner_antag_language/Run()
	var/mob/living/carbon/human/foreigner = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/cultist = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	foreigner.mind_initialize()
	cultist.mind_initialize()
	foreigner.aq_make_foreigner()
	foreigner.grant_language(/datum/language/narsie)
	cultist.grant_language(/datum/language/narsie)
	TEST_ASSERT(!HAS_TRAIT(foreigner, TRAIT_AQ_TRANSLATOR), "Foreigner already has a translator")

	// Obcokrajowiec-kultysta bez słuchawek: Polak słyszy tłumaczenie, dalej po Nar'Siańsku
	RegisterSignal(cultist, COMSIG_MOVABLE_HEAR, PROC_REF(on_hear))
	SStranslation.cache_set(DEEPL_LANG_EN, DEEPL_LANG_PL, "Blood for the Geometer", "Krew dla Geometry")
	foreigner.say(",nBlood for the Geometer")
	TEST_ASSERT(heard_language == /datum/language/narsie, "Translated cult speech changed language: [heard_language]")
	TEST_ASSERT(heard_raw == "Krew dla Geometry.", "Cultist did not hear the translation: [heard_raw]")
	TEST_ASSERT(!foreigner.aq_translated_say && !foreigner.aq_translated_say_mods, "Translated say state stayed on")
	if(!CONFIG_GET(string/deepl_api_key))
		heard_raw = null
		foreigner.say(",nNobody translated this")
		TEST_ASSERT(heard_language == /datum/language/narsie, "Untranslated cult speech changed language: [heard_language]")
		TEST_ASSERT(heard_raw == "Nobody translated this.", "Untranslated cult speech changed: [heard_raw]")
	// Angielski bez tłumacza dalej idzie bez tłumaczenia
	heard_raw = null
	foreigner.say("Blood for the Geometer")
	TEST_ASSERT(heard_language == /datum/language/english && heard_raw == "Blood for the Geometer.", "English without a translator was translated: [heard_language] [heard_raw]")
	UnregisterSignal(cultist, COMSIG_MOVABLE_HEAR)

	// Polak-kultysta mówi po Nar'Siańsku: obcokrajowiec, który zna język, dostaje tłumaczenie bez tłumacza
	TEST_ASSERT(foreigner.aq_hears_via_translator(/datum/language/narsie), "Foreigner does not get Nar'Sian translated")
	TEST_ASSERT(!foreigner.aq_hears_via_translator(/datum/language/common), "Foreigner without a translator gets Common translated")
	TEST_ASSERT(!foreigner.aq_hears_via_translator(/datum/language/draconic), "Foreigner gets a language he does not know translated")
	TEST_ASSERT(!cultist.aq_hears_via_translator(/datum/language/narsie), "Polish cultist would get Nar'Sian translated")
	RegisterSignal(foreigner, COMSIG_MOVABLE_HEAR, PROC_REF(on_hear))
	SStranslation.cache_set(DEEPL_LANG_PL, DEEPL_LANG_EN, "Krew dla Geometry.", "Blood for the Geometer.")
	heard_raw = null
	foreigner.aq_translate_heard("", cultist, /datum/language/narsie, "Krew dla Geometry.", null, list(), list())
	TEST_ASSERT(heard_language == /datum/language/narsie, "Translated Nar'Sian was not kept in Nar'Sian: [heard_language]")
	TEST_ASSERT(heard_raw == "Blood for the Geometer.", "Foreigner did not get the translation: [heard_raw]")
	TEST_ASSERT(heard_mods?[MODE_AQ_TRANSLATED], "Translated speech is not marked, it would loop back to the translator")
	UnregisterSignal(foreigner, COMSIG_MOVABLE_HEAR)

	// Wbudowany tłumacz siedzi w umyśle: konstrukt dostaje go razem z umysłem, a stare ciało go traci
	foreigner.aq_give_builtin_translator(foreigner)
	TEST_ASSERT(HAS_TRAIT(foreigner, TRAIT_AQ_TRANSLATOR), "Built-in translator gives no trait")
	var/datum/mind/mind = foreigner.mind
	var/mob/living/simple_animal/hostile/construct/armored/construct = allocate(/mob/living/simple_animal/hostile/construct/armored, run_loc_floor_bottom_left)
	mind.transfer_to(construct)
	TEST_ASSERT(construct.mind == mind && mind.aq_foreigner, "Construct did not get the foreign mind")
	TEST_ASSERT(HAS_TRAIT(construct, TRAIT_AQ_TRANSLATOR), "Built-in translator did not move to the construct")
	TEST_ASSERT(!HAS_TRAIT(foreigner, TRAIT_AQ_TRANSLATOR), "Old body kept the built-in translator")
	TEST_ASSERT(!construct.has_language(/datum/language/common), "Construct with a foreign mind understands Common")
	TEST_ASSERT(construct.aq_hears_via_translator(/datum/language/common), "Construct with a foreign mind does not get Common translated")

	SSticker.minds -= mind
	SSticker.minds -= cultist.mind
	SStranslation.cache = list()

/// Formatowanie mowy (+b+ _u_ |i|) idzie do DeepL jako znaczniki HTML i wraca jako te same znaczniki (bez sieci)
/datum/unit_test/aquila_translation_emphasis/Run()
	var/original = "Hej +ty+, _patrz_ |tu| <3 & \"co\""
	var/masked = aq_mask_emphasis(original)
	TEST_ASSERT(findtext(masked, "<b>ty</b>") && findtext(masked, "<u>patrz</u>") && findtext(masked, "<i>tu</i>"), "Emphasis was not masked as HTML: [masked]")
	TEST_ASSERT(!findtext(masked, "<3"), "Plain text was not HTML-encoded: [masked]")
	TEST_ASSERT(aq_unmask_emphasis(masked) == original, "Masking is not reversible: [aq_unmask_emphasis(masked)]")
	// Tak wraca odpowiedź DeepL: środek znaczników przetłumaczony, znaczniki zostają
	var/answer = aq_unmask_emphasis("Hi <b>you</b>, <u>look</u> <i>here</i> &lt;3 &amp; &quot;co&quot;")
	TEST_ASSERT(answer == "Hi +you+, _look_ |here| <3 & \"co\"", "DeepL answer was not unmasked: [answer]")
	TEST_ASSERT(aq_has_emphasis(original), "Emphasis was not detected")
	TEST_ASSERT(!aq_has_emphasis("Zwykłe zdanie, 2 + 2 i a_b"), "Plain sentence counted as emphasis")

/// Czip tłumacza: własne gniazdo w słuchawkach (klucze zostają wolne), działa tylko na uszach, wychodzi multitoolem
/datum/unit_test/aquila_translator_chip/Run()
	var/mob/living/carbon/human/wearer = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/radio/headset/headset = allocate(/obj/item/radio/headset, run_loc_floor_bottom_left)
	var/obj/item/aquila_translator/chip/chip = allocate(/obj/item/aquila_translator/chip, run_loc_floor_bottom_left)

	TEST_ASSERT(wearer.put_in_hands(chip), "Could not pick up the chip")
	headset.attackby(chip, wearer)
	TEST_ASSERT(headset.aq_translator_chip == chip && chip.loc == headset, "Chip did not go into the headset slot")
	TEST_ASSERT(!headset.keyslot && !headset.keyslot2, "Chip took an encryption key slot")

	// Oba gniazda na klucze dalej przyjmują klucze
	for(var/i in 1 to 2)
		var/obj/item/encryptionkey/key = allocate(/obj/item/encryptionkey/headset_sec, run_loc_floor_bottom_left)
		TEST_ASSERT(wearer.put_in_hands(key), "Could not pick up key [i]")
		headset.attackby(key, wearer)
	TEST_ASSERT(headset.keyslot && headset.keyslot2, "Encryption keys did not fit next to the chip")

	TEST_ASSERT(wearer.put_in_hands(headset), "Could not pick up the headset")
	TEST_ASSERT(!HAS_TRAIT(wearer, TRAIT_AQ_TRANSLATOR), "Headset in hand already translates")
	TEST_ASSERT(wearer.equip_to_slot_if_possible(headset, ITEM_SLOT_EARS), "Could not wear the headset")
	TEST_ASSERT(HAS_TRAIT(wearer, TRAIT_AQ_TRANSLATOR), "Worn headset with chip does not translate")
	TEST_ASSERT(wearer.has_language(/datum/language/english), "Worn chip gives no English understanding")

	// Śrubokręt wyjmuje klucze, czip zostaje
	var/obj/item/screwdriver/screwdriver = allocate(/obj/item/screwdriver, run_loc_floor_bottom_left)
	headset.attackby(screwdriver, wearer)
	TEST_ASSERT(!headset.keyslot && !headset.keyslot2, "Screwdriver did not remove the keys")
	TEST_ASSERT(headset.aq_translator_chip == chip && HAS_TRAIT(wearer, TRAIT_AQ_TRANSLATOR), "Screwdriver removed the chip")

	// EMP przez słuchawki: czip milknie do restartu i potem znowu tłumaczy
	headset.emp_act(EMP_LIGHT)
	TEST_ASSERT(chip.rebooting, "EMP on the headset did not reach the chip")
	TEST_ASSERT(!HAS_TRAIT(wearer, TRAIT_AQ_TRANSLATOR), "Chip still translates right after an EMP")
	chip.aq_reboot()
	TEST_ASSERT(HAS_TRAIT(wearer, TRAIT_AQ_TRANSLATOR), "Chip does not translate after rebooting")

	// Multitool wyjmuje czip i wyłącza tłumacza
	var/obj/item/multitool/multitool = allocate(/obj/item/multitool, run_loc_floor_bottom_left)
	wearer.drop_all_held_items()
	TEST_ASSERT(headset.multitool_act(wearer, multitool), "Multitool did not act on the chip")
	TEST_ASSERT(!headset.aq_translator_chip && chip.loc != headset, "Chip still in the headset after the multitool")
	TEST_ASSERT(!HAS_TRAIT(wearer, TRAIT_AQ_TRANSLATOR), "Translator stayed on after removing the chip")

	// Obcokrajowiec ze słuchawkami dostaje czip w nich, a zdjęte słuchawki przestają tłumaczyć
	wearer.aq_give_translator(wearer)
	TEST_ASSERT(istype(headset.aq_translator_chip), "Spawn translator did not go into the worn headset")
	TEST_ASSERT(HAS_TRAIT(wearer, TRAIT_AQ_TRANSLATOR), "Spawn chip does not translate")
	wearer.dropItemToGround(headset)
	TEST_ASSERT(!HAS_TRAIT(wearer, TRAIT_AQ_TRANSLATOR), "Dropped headset still translates")
	TEST_ASSERT(!headset.aq_translator_wearer, "Dropped headset still remembers its wearer")
	SStranslation.cache = list()

/// EMP: spalony czip i tłumacz kieszonkowy już nie tłumaczą (restart ich nie wskrzesza), a HoP ma zapasowe czipy
/datum/unit_test/aquila_translator_emp/Run()
	var/mob/living/carbon/human/wearer = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/aquila_translator/translator = allocate(/obj/item/aquila_translator, run_loc_floor_bottom_left)
	TEST_ASSERT(wearer.put_in_hands(translator), "Could not pick up the pocket translator")
	translator.emp_act(EMP_LIGHT)
	TEST_ASSERT(!HAS_TRAIT(wearer, TRAIT_AQ_TRANSLATOR), "Pocket translator still works right after an EMP")
	translator.aq_reboot()
	TEST_ASSERT(HAS_TRAIT(wearer, TRAIT_AQ_TRANSLATOR), "Pocket translator does not work after rebooting")
	translator.aq_burn()
	TEST_ASSERT(!HAS_TRAIT(wearer, TRAIT_AQ_TRANSLATOR), "Burnt pocket translator still works")
	translator.aq_reboot()
	TEST_ASSERT(!HAS_TRAIT(wearer, TRAIT_AQ_TRANSLATOR), "Burnt pocket translator came back after a reboot")
	translator.emp_act(EMP_HEAVY)
	TEST_ASSERT(translator.burnt && !translator.rebooting, "EMP on a burnt translator changed it")

	var/obj/item/radio/headset/headset = allocate(/obj/item/radio/headset, run_loc_floor_bottom_left)
	var/obj/item/aquila_translator/chip/chip = allocate(/obj/item/aquila_translator/chip, run_loc_floor_bottom_left)
	wearer.drop_all_held_items()
	TEST_ASSERT(wearer.put_in_hands(chip), "Could not pick up the chip")
	headset.attackby(chip, wearer)
	TEST_ASSERT(wearer.equip_to_slot_if_possible(headset, ITEM_SLOT_EARS), "Could not wear the headset")
	TEST_ASSERT(HAS_TRAIT(wearer, TRAIT_AQ_TRANSLATOR), "Worn chip does not translate")
	chip.aq_burn()
	TEST_ASSERT(!HAS_TRAIT(wearer, TRAIT_AQ_TRANSLATOR), "Burnt chip still translates")
	TEST_ASSERT(chip.icon_state == "translator_chip_burnt", "Burnt chip kept its normal sprite")
	TEST_ASSERT(findtext(chip.name, "spalony") == 1, "Burnt chip is not named as burnt: [chip.name]")

	// Regresja: kasowany mob z tłumaczem w ręce nie może dostać nowego language_holdera.
	// Błąd to runtime w language_holder.dm, a każdy runtime w trakcie testów oblewa przebieg (run_all_tests)
	var/mob/living/carbon/human/doomed = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/aquila_translator/held = allocate(/obj/item/aquila_translator, run_loc_floor_bottom_left)
	TEST_ASSERT(doomed.put_in_hands(held), "Could not pick up the translator before deleting the mob")
	qdel(doomed)
	TEST_ASSERT(QDELETED(doomed), "Mob holding a translator was not deleted")

	// Zapas w szafce HoP-a, także w wersji z NSV, która nie woła ..()
	for(var/closet_type in list(/obj/structure/closet/secure_closet/hop, /obj/structure/closet/secure_closet/hop/solgov))
		var/obj/structure/closet/closet = allocate(closet_type, run_loc_floor_bottom_left)
		var/obj/item/storage/box/aquila_translator_chips/box = locate() in closet
		TEST_ASSERT(box, "[closet_type] has no spare translator chips")
		var/chips = 0
		for(var/obj/item/aquila_translator/chip/spare in box)
			chips++
		TEST_ASSERT(chips == 4, "[closet_type] box has [chips] chips instead of 4")

/// Czat (OOC, PW): tłumaczenie z czekaniem bierze wynik z pamięci, a bez klucza szybko zwraca null
/datum/unit_test/aquila_chat_translation/Run()
	SStranslation.cache_set(DEEPL_LANG_PL, DEEPL_LANG_EN, "Pomocy, admin", "Help, admin")
	TEST_ASSERT(aq_translate_wait("Pomocy, admin", DEEPL_LANG_PL, DEEPL_LANG_EN) == "Help, admin", "Cached chat translation was not returned")
	if(!CONFIG_GET(string/deepl_api_key))
		var/started = world.time
		TEST_ASSERT(isnull(aq_translate_wait("Nikt tego nie tłumaczył", DEEPL_LANG_PL, DEEPL_LANG_EN)), "Chat translation without a key returned text")
		TEST_ASSERT(world.time - started < 1 SECONDS, "Chat translation without a key waited")
	// Świeża porażka: kolejny odbiorca nie czeka; stara wygasa, a tłumaczenie, które już jest w pamięci, wygrywa z porażką
	var/key = "[DEEPL_LANG_PL]>[DEEPL_LANG_EN]|Spróbuj jeszcze raz"
	GLOB.aq_chat_translation_failures[key] = world.time
	var/started_fresh = world.time
	TEST_ASSERT(isnull(aq_translate_wait("Spróbuj jeszcze raz", DEEPL_LANG_PL, DEEPL_LANG_EN)), "Fresh failure did not short-circuit")
	TEST_ASSERT(world.time - started_fresh < 1 SECONDS, "Fresh failure still waited for the API")
	SStranslation.cache_set(DEEPL_LANG_PL, DEEPL_LANG_EN, "Spróbuj jeszcze raz", "Try again")
	TEST_ASSERT(aq_translate_wait("Spróbuj jeszcze raz", DEEPL_LANG_PL, DEEPL_LANG_EN) == "Try again", "Remembered failure hid a translation that is now cached")
	SStranslation.cache = list()
	GLOB.aq_chat_translation_failures[key] = world.time - 31 SECONDS
	if(!CONFIG_GET(string/deepl_api_key))
		aq_translate_wait("Spróbuj jeszcze raz", DEEPL_LANG_PL, DEEPL_LANG_EN)
		TEST_ASSERT(GLOB.aq_chat_translation_failures[key] > world.time - 1 SECONDS, "Expired failure was not retried")
	SStranslation.cache = list()
	GLOB.aq_chat_translation_failures = list()

	// Dopisek z tłumaczeniem: w HTML etykieta w osobnym węźle (słownik EN), tłumaczenie sanityzowane
	var/html_text = aq_admin_translation_text("Hi", "Cześć <b>", TRUE)
	TEST_ASSERT(findtext(html_text, "<span class='aq_translation_label'>Tłumaczenie:</span>"), "Translation label is not its own node: [html_text]")
	TEST_ASSERT(!findtext(html_text, "<b>"), "Translation was not sanitized in the HTML note")
	// Nowy adminhelp: całość mieści się w limicie, więc /datum/admin_help/New nie utnie tłumaczenia
	var/long_ahelp = aq_admin_translation_text(jointext(new /list(MAX_MESSAGE_LEN), "a"), "Pełne tłumaczenie", FALSE)
	TEST_ASSERT(length_char(long_ahelp) < MAX_MESSAGE_LEN, "Adminhelp with translation is longer than the ticket limit: [length_char(long_ahelp)]")
	TEST_ASSERT(findtext(long_ahelp, "(Tłumaczenie: Pełne tłumaczenie)"), "Long adminhelp lost its translation")

	// Forma po treat_message_min(): tak słuchacz dostaje zdanie, więc pod nią też jest odwrotny wpis
	TEST_ASSERT(aq_spoken_form("cześć") == "Cześć.", "Spoken form differs from treat_message_min: [aq_spoken_form("cześć")]")
	TEST_ASSERT(aq_spoken_form("Hej?") == "Hej?", "Spoken form changed a finished sentence")

/// Obcokrajowiec losuje imiona z oryginalnej puli NSV13, a bez gracza z angielskim w lobby zostaje polska pula
/datum/unit_test/aquila_foreigner_names/Run()
	TEST_ASSERT(length(GLOB.aq_english_first_names_male) && length(GLOB.aq_english_first_names_female) && length(GLOB.aq_english_last_names), "English name pools are empty")
	for(var/gender in list(MALE, FEMALE))
		var/list/parts = splittext(aq_english_random_name(gender, TRUE), " ")
		TEST_ASSERT(length(parts) == 2, "English name is not first + last: [jointext(parts, " ")]")
		TEST_ASSERT(parts[1] in (gender == MALE ? GLOB.aq_english_first_names_male : GLOB.aq_english_first_names_female), "First name [parts[1]] is not from the English pool")
		TEST_ASSERT(parts[2] in GLOB.aq_english_last_names, "Last name [parts[2]] is not from the English pool")
	var/datum/species/human/species = new
	var/list/polish = splittext(species.random_name(MALE), " ")
	TEST_ASSERT(polish[1] in GLOB.first_names_male, "Species name without an English player left the Polish pool: [polish[1]]")
	qdel(species)
	var/datum/character_save/character = new
	character.pref_species = new /datum/species/human
	character.gender = FEMALE
	var/list/owned = splittext(character.aq_random_real_name(null), " ")
	TEST_ASSERT(owned[1] in GLOB.first_names_female, "Character without an English owner left the Polish pool: [owned[1]]")
	qdel(character.pref_species)
	qdel(character)

#undef TEST_ASSERT
