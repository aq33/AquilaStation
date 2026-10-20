// AQUILA - tgstation#94761 "Medical larp: Adds the SDSM-35".
// tg keeps the symptoms in a var on every trauma, quirk and addiction. Our trauma descriptions are English
// and we have no addictions, so the whole guide lives in one Polish table below instead of thirty edited files.
// A trauma, quirk or phobia missing from the table is simply not in the book.

/// Base type for a book that opens a bespoke TGUI
/// Does not inherit from /obj/item/book because the only similarities between the two are the concept of "being a book"
/// When designing a UI book you can send a "play_flip_sound" act to play the page turn sound
/obj/item/tgui_book
	name = "książka"
	desc = "Pewnie jedna z tych nowomodnych książek elektronicznych."
	icon = 'icons/obj/library.dmi'
	icon_state = "book"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("grzmoci", "wali", "edukuje")
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/items/handling/book_drop.ogg'
	pickup_sound = 'sound/items/handling/book_pickup.ogg'
	/// The name of the UI to open
	var/ui_name

/obj/item/tgui_book/attack_self(mob/user)
	if(!user.can_read(src))
		return
	ui_interact(user)

/obj/item/tgui_book/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, ui_name)
		ui.open()
		playsound(src, "pageturn", 30, TRUE)

/obj/item/tgui_book/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(action == "play_flip_sound")
		playsound(src, "pageturn", 30, TRUE)
		return TRUE

/obj/item/tgui_book/ui_state(mob/user)
	return GLOB.book_state

/obj/item/tgui_book/manual/dsm
	name = "SDSM-35"
	desc = "Kosmiczny Podręcznik Diagnostyczny i Statystyczny Zaburzeń Psychicznych - kompendium wszystkich znanych zaburzeń psychicznych. \
		To już 35. wydanie, choć przydałaby mu się aktualizacja..."
	icon_state = "book8"
	ui_name = "DSMBook"

/obj/item/tgui_book/manual/dsm/ui_static_data(mob/user)
	var/list/data = list()
	var/static/list/trauma_info
	if(!trauma_info)
		trauma_info = build_dsm_entries()
	data["traumas"] = trauma_info
	return data

/// Builds the book entries: traumas and trauma-like quirks from the tables, then every phobia
/obj/item/tgui_book/manual/dsm/proc/build_dsm_entries()
	. = list()
	var/list/trauma_texts = dsm_trauma_texts()
	for(var/datum/brain_trauma/trauma_type as anything in trauma_texts)
		var/list/texts = trauma_texts[trauma_type]
		. += list(list(
			"full_name" = texts[1],
			"scan_name" = length(texts) >= 4 ? texts[4] : initial(trauma_type.scan_desc),
			"desc" = texts[2],
			"symptoms" = texts[3],
			"id" = "[trauma_type]",
		))
	var/list/quirk_texts = dsm_quirk_texts()
	for(var/datum/quirk/quirk_type as anything in quirk_texts)
		var/list/texts = quirk_texts[quirk_type]
		. += list(list(
			"full_name" = texts[1],
			"scan_name" = lowertext(initial(quirk_type.name)),
			"desc" = initial(quirk_type.medical_record_text),
			"symptoms" = texts[2],
			"id" = "[quirk_type]",
		))
	var/list/phobia_texts = dsm_phobia_texts()
	for(var/phobia_type in phobia_texts)
		var/list/texts = phobia_texts[phobia_type]
		. += list(list(
			"full_name" = texts[1],
			"scan_name" = "fobia: [texts[2]]",
			"desc" = "Pacjent irracjonalnie boi się [texts[3]].",
			"symptoms" = "W kontakcie z bodźcem pojawia się natychmiastowy lęk znacznie silniejszy niż zwykle, \
				prowadzący do ataków paniki, drżenia i omdleń oraz utrudniający pracę i kontakty z ludźmi. \
				Przytulenie albo leki uspokajające mogą złagodzić reakcję.",
			"id" = "[/datum/brain_trauma/mild/phobia]/[phobia_type]",
		))

/// Trauma type = list(full name, description, symptoms, optional scan name when its scan_desc is still English)
/obj/item/tgui_book/manual/dsm/proc/dsm_trauma_texts()
	return list(
		/datum/brain_trauma/special/obsessed = list("Schizofrenia psychotyczna",
			"Podtyp zaburzenia urojeniowego - pacjent irracjonalnie przywiązuje się do jednej osoby.",
			"Obsesyjne zachowania wobec konkretnej osoby: wpatrywanie się, natrętne myśli i przemożna potrzeba przebywania blisko niej. \
				Obsesja prowadzi do wycofania z życia społecznego, lęku i trudności w codziennym funkcjonowaniu."),
		/datum/brain_trauma/hypnosis = list("Hipnoza",
			"Nieświadomość pacjenta jest całkowicie zniewolona przez jedno słowo lub zdanie, na którym skupiają się jego myśli i działania.",
			"Fiksacja na konkretnym słowie lub frazie. Pacjent przedkłada działania z nią związane nad inne zadania, \
				zaniedbując pracę, potrzeby i kontakty z ludźmi. Leczenie wymaga operacji mózgu."),
		/datum/brain_trauma/special/imaginary_friend = list("Wyimaginowany przyjaciel",
			"Pacjent widzi i słyszy osobę, której nie ma.",
			"Oznaki rozmowy z niewidzialną osobą: mówienie do siebie, reagowanie na niesłyszalne bodźce i zachowanie sugerujące obecność towarzysza. \
				\"Przyjaciel\" może wpływać na działania i nastrój pacjenta, prowadząc do wycofania, zaburzonego odbioru rzeczywistości albo dziwnych zajęć."),
		/datum/brain_trauma/magic/lumiphobia = list("Lumifobia",
			"Pacjent ma niewytłumaczalną, niepożądaną reakcję na światło.",
			"Skrajny dyskomfort i niepożądane reakcje na jasne światło - pacjent zrobi wiele, żeby unikać oświetlonych miejsc. \
				Nadwrażliwość może podrażniać skórę jak ciężkie oparzenie słoneczne."),
		/datum/brain_trauma/magic/poltergeist = list("Poltergeist",
			"Pacjent wydaje się celem agresywnej, niewidzialnej istoty.",
			"Częste i niesprowokowane zakłócenia w otoczeniu pacjenta, na przykład przedmioty rzucane lub przesuwane bez widocznej przyczyny."),
		/datum/brain_trauma/magic/antimagic = list("Atałmazja",
			"Pacjent jest całkowicie odporny na siły magiczne.",
			"Pełna odporność na zjawiska, których nie tłumaczy nauka, takie jak zdolności członków Federacji Czarodziejów."),
		/datum/brain_trauma/magic/stalker = list("Prześladujący fantom",
			"Pacjenta śledzi fantom, którego widzi tylko on sam.",
			"Nieustępliwe poczucie bycia obserwowanym lub ściganym przez niewidzialną istotę, wzmożony lęk, paranoja i omamy upiornej postaci w pobliżu. \
				W skrajnych przypadkach pacjent odnosi obrażenia zadane przez pozornie niewidzialną siłę."),
		/datum/brain_trauma/mild/hallucinations = list("Halucynacje",
			"Pacjent ma ciągłe halucynacje.",
			"Częste halucynacje wzrokowe lub słuchowe albo urojenia, które ustępują po podaniu Mindbreaker Toxin.",
			"schizofrenia"),
		/datum/brain_trauma/mild/stuttering = list("Jąkanie",
			"Pacjent nie potrafi mówić poprawnie.",
			"Trudności z płynnym mówieniem, częste powtarzanie lub przeciąganie głosek i sylab."),
		/datum/brain_trauma/mild/dumbness = list("Otępienie",
			"Pacjent ma obniżoną aktywność mózgu, co czyni go mniej inteligentnym.",
			"Wyraźny spadek funkcji poznawczych, w tym mowy, pamięci, motoryki i rozwiązywania problemów."),
		/datum/brain_trauma/mild/speech_impediment = list("Zaburzenie mowy",
			"Pacjent nie potrafi składać spójnych zdań.",
			"Trudność w przekładaniu myśli na spójną wypowiedź - zdania wychodzą poplątane albo bez sensu."),
		/datum/brain_trauma/mild/concussion = list("Wstrząśnienie mózgu",
			"Mózg pacjenta doznał wstrząśnienia.",
			"Bóle i zawroty głowy, nudności, dezorientacja i okresowa utrata przytomności.",
			"wstrząśnienie mózgu"),
		/datum/brain_trauma/mild/healthy = list("Anozognozja",
			"Pacjent zawsze czuje się zdrowy, niezależnie od swojego stanu.",
			"Brak świadomości lub zaprzeczanie własnym chorobom - pacjent upiera się, że jest zupełnie zdrowy mimo wyraźnych dowodów."),
		/datum/brain_trauma/mild/muscle_weakness = list("Osłabienie mięśni",
			"Pacjent miewa napady osłabienia mięśni.",
			"Nagłe epizody osłabienia mięśni: słaby chwyt, trudności z poruszaniem się i okresowe upadki."),
		/datum/brain_trauma/mild/muscle_spasms = list("Skurcze mięśni",
			"Pacjent miewa skurcze mięśni, przez które porusza się mimowolnie.",
			"Mimowolne skurcze mięśni powodujące nagłe, krótkie ruchy lub drgawki, które utrudniają normalne funkcje ruchowe."),
		/datum/brain_trauma/mild/nervous_cough = list("Kaszel nerwowy",
			"Pacjent czuje ciągłą potrzebę kaszlu.",
			"Uporczywa, niekontrolowana potrzeba kaszlu, która może przeszkadzać w codziennych czynnościach i kontaktach z ludźmi."),
		/datum/brain_trauma/mild/expressive_aphasia = list("Afazja ekspresyjna",
			"Częściowa utrata mowy prowadząca do ubogiego słownictwa.",
			"Trudności z wyrażaniem myśli słowami - złożone wyrazy pacjent zastępuje prostszymi albo bezsensownymi dźwiękami."),
		/datum/brain_trauma/severe/mute = list("Mutyzm",
			"Pacjent całkowicie nie potrafi mówić.",
			"Całkowita niezdolność do wydawania dźwięków i mowy."),
		/datum/brain_trauma/severe/aphasia = list("Afazja",
			"Pacjent nie potrafi mówić ani rozumieć żadnego języka.",
			"Utrata zdolności rozumienia i używania języka - mowa pacjenta i do pacjenta jest dla niego bełkotem."),
		/datum/brain_trauma/severe/blindness = list("Ślepota korowa",
			"Mózg pacjenta nie jest już połączony z oczami.",
			"Całkowita utrata wzroku mimo zdrowych oczu - uszkodzony jest płat potyliczny, więc wymiana oczu nie pomoże."),
		/datum/brain_trauma/severe/paralysis = list("Paraliż",
			"Mózg pacjenta nie kontroluje już części funkcji ruchowych.",
			"Brak czucia i ruchu w części kończyn, mimo że same kończyny są zdrowe."),
		/datum/brain_trauma/severe/narcolepsy = list("Narkolepsja",
			"Pacjent może mimowolnie zasypiać w trakcie zwykłych czynności.",
			"Nagłe napady senności i zasypianie w trakcie zwykłych czynności, często poprzedzone ziewaniem i otępieniem."),
		/datum/brain_trauma/severe/monophobia = list("Monofobia",
			"Pacjent czuje się chory i zestresowany, gdy nie ma przy nim innych ludzi, co może prowadzić do śmiertelnego poziomu stresu.",
			"Narastający lęk i objawy fizyczne w samotności: nudności, drżenie, a w ciężkich przypadkach zawał serca. \
				Obecność innych ludzi szybko przynosi ulgę.",
			"monofobia"),
		/datum/brain_trauma/severe/discoordination = list("Dyskoordynacja",
			"Pacjent nie potrafi używać złożonych narzędzi ani maszyn.",
			"Niezdolność do obsługi złożonych narzędzi, broni i maszyn przy zachowanej prostej motoryce."),
		/datum/brain_trauma/severe/pacifism = list("Urazowy brak przemocy",
			"Pacjent skrajnie nie chce krzywdzić innych w brutalny sposób.",
			"Całkowita niezdolność do zadawania obrażeń innym istotom - pacjent nie uderzy nawet w obronie własnej."),
		/datum/brain_trauma/severe/hypnotic_stupor = list("Stupor hipnotyczny",
			"Pacjent miewa napady głębokiego otępienia, w których jest skrajnie podatny na sugestie.",
			"Okresy nieobecności i otępienia, w trakcie których pacjent przyjmuje do wiadomości i wykonuje usłyszane polecenia."),
		/datum/brain_trauma/severe/split_personality = list("Rozszczepienie osobowości",
			"Mózg pacjenta dzieli się między dwie osobowości, które losowo przejmują kontrolę nad ciałem.",
			"Nagłe zmiany zachowania, sposobu mówienia i wspomnień, jakby ciałem kierowała inna osoba, której pacjent potem nie pamięta."),
		/datum/brain_trauma/special/godwoken = list("Syndrom przebudzenia bożego",
			"Pacjent od czasu do czasu mimowolnie przemawia głosem pradawnego boga.",
			"Okresowe wybuchy mowy o nadnaturalnej sile, które ogłuszają, odrzucają lub ranią słuchaczy."),
		/datum/brain_trauma/special/ghost_control = list("Duchowa więź",
			"Pacjent twierdzi, że dostaje od istot nadprzyrodzonych impulsy, którym musi być posłuszny.",
			"Mimowolne ruchy całego ciała, jakby ktoś inny decydował, w którą stronę pacjent ma iść."),
		/datum/brain_trauma/special/bluespace_prophet = list("Proroctwo bluespace",
			"Pacjent wyczuwa falowanie bluespace wokół siebie i widzi przejścia, których nie widzi nikt inny.",
			"Pacjent wskazuje niewidzialne dla innych przejścia i potrafi znikać w jednym miejscu, by pojawić się w innym."),
		/datum/brain_trauma/special/tenacity = list("Nieustępliwość",
			"Pacjent psychicznie nie odczuwa bólu ani obrażeń i może ustać na nogach znacznie dłużej niż zwykły człowiek.",
			"Brak reakcji na ból i rany - pacjent chodzi i walczy w stanie, w którym inni dawno by upadli, przez co łatwo przeoczyć ciężkie obrażenia."),
		/datum/brain_trauma/special/death_whispers = list("Czynnościowa martwica mózgu",
			"Mózg pacjenta utknął w stanie bliskim śmierci, co powoduje chwile świadomych halucynacji, często branych za głosy zmarłych.",
			"Okresowe stany przypominające śmierć kliniczną, w trakcie których pacjent słyszy i rozumie zmarłych."),
		/datum/brain_trauma/special/beepsky = list("Przestępczość",
			"Pacjent wydaje się przestępcą.",
			"Uporczywe poczucie bycia ściganym przez ochronę i omamy funkcjonariusza, który nadchodzi z wyrokiem."),
	)

/// Quirk type = list(full name, symptoms). The description comes from the quirk's medical record text.
/obj/item/tgui_book/manual/dsm/proc/dsm_quirk_texts()
	return list(
		/datum/quirk/depression = list("Depresja",
			"Uporczywy smutek, poczucie beznadziei i brak motywacji."),
		/datum/quirk/hypersensitive = list("Nadwrażliwość emocjonalna",
			"Wzmożone reakcje emocjonalne na bodźce, przez które pacjent jest bardzo czuły i drażliwy w kontaktach z ludźmi."),
		/datum/quirk/nyctophobia = list("Nyktofobia",
			"Ataki paniki i duszność w ciemnych miejscach. Leki uspokajające mogą złagodzić reakcję."),
		/datum/quirk/prosopagnosia = list("Prozopagnozja",
			"Niezdolność do rozpoznawania znajomych twarzy - pacjent rozpoznaje ludzi po głosie, ubraniu, identyfikatorze albo sytuacji."),
		/datum/quirk/social_anxiety = list("Fobia społeczna",
			"Silny lęk i dyskomfort w sytuacjach społecznych, unikanie kontaktów z ludźmi i trudności w rozmowie."),
		/datum/quirk/unstable = list("Niestabilność psychiczna",
			"Silne wahania nastroju i niezdolność do otrząśnięcia się po stresujących wydarzeniach."),
		/datum/quirk/insanity = list("Zaburzenia dysocjacyjne",
			"Omamy i poczucie oderwania od rzeczywistości, które ustępują po podaniu Mindbreaker Toxin."),
		/datum/quirk/junkie = list("Uzależnienie od narkotyków",
			"Głód twardych narkotyków, a w odstawieniu drżenie, poty, wymioty i rozdrażnienie."),
		/datum/quirk/junkie/smoker = list("Uzależnienie od nikotyny",
			"Głód nikotyny, a w odstawieniu rozdrażnienie, kaszel i trudności z koncentracją."),
		/datum/quirk/alcoholic = list("Uzależnienie od alkoholu",
			"Głód alkoholu, a w odstawieniu drżenie, halucynacje i w ciężkich przypadkach drgawki."),
	)

/// Phobia key in SStraumas.phobia_types = list(medical name, short name, what the patient fears)
/obj/item/tgui_book/manual/dsm/proc/dsm_phobia_texts()
	return list(
		"aliens" = list("Astroksenofobia", "obcy", "obcych form życia"),
		"anime" = list("Nihongofobia", "anime", "anime"),
		"authority" = list("Autorytofobia", "władza", "przełożonych i władzy"),
		"birds" = list("Ornitofobia", "ptaki", "ptaków"),
		"clowns" = list("Koulrofobia", "klauni", "klaunów"),
		"doctors" = list("Jatrofobia", "lekarze", "lekarzy"),
		"falling" = list("Bazyfobia", "upadek", "upadku"),
		"greytide" = list("Glaukofobia", "asystenci", "asystentów w szarych kombinezonach"),
		"lizards" = list("Herpetofobia", "jaszczury", "jaszczurów"),
		"robots" = list("Automatonofobia", "roboty", "robotów"),
		"security" = list("Skopofobia", "ochrona", "ochrony"),
		"skeletons" = list("Osteofobia", "szkielety", "szkieletów"),
		"snakes" = list("Ofidiofobia", "węże", "węży"),
		"space" = list("Astrofobia", "kosmos", "kosmosu"),
		"spiders" = list("Arachnofobia", "pająki", "pająków"),
		"strangers" = list("Ksenofobia", "obcy ludzie", "obcych ludzi"),
		"the supernatural" = list("Fasmofobia", "zjawiska nadprzyrodzone", "zjawisk nadprzyrodzonych"),
	)
