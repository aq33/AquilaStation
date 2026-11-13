// AQUILA - Skala bristolska: typ stolca zależy od diety, ruchu, nawodnienia i nastroju.
// Typ liczy się na bieżąco z tego, co postać zjadła i zrobiła od ostatniego wypróżnienia.
// - typ 1-2 (zaparcie): potrzeba rośnie wolniej, wypróżnienie trwa dłużej, minus do nastroju
// - typ 3-4: plus do nastroju
// - typ 6-7 (biegunka): potrzeba rośnie szybciej, popuszczenie przychodzi wcześniej, minus do nastroju
// Po wypróżnieniu postać dostaje w czacie typ i możliwe przyczyny, a typ widać przy oględzinach kupy.

/// Ile minut od ostatniego wypróżnienia musi minąć, żeby oceniać ruch
#define BRISTOL_ACTIVITY_MIN_MINUTES 5
/// Poniżej tylu kroków na minutę postać siedzi w miejscu
#define BRISTOL_SEDENTARY_STEPS_PER_MINUTE 10
/// Od ilu zjedzonych jednostek oceniamy dietę
#define BRISTOL_DIET_MIN_UNITS 5
/// Ile jednostek środków pobudzających jelita (kawa, ostre) przesuwa o jeden typ
#define BRISTOL_LAXATIVE_STEP 20

/mob/living
	/// Zjedzone warzywa i owoce (witaminy) od ostatniego wypróżnienia
	var/bowel_fiber = 0
	/// Zjedzone mięso, tłuszcz i cukier od ostatniego wypróżnienia
	var/bowel_junk = 0
	/// Wypita kawa i zjedzone ostre od ostatniego wypróżnienia
	var/bowel_laxative = 0
	/// Kroki od ostatniego wypróżnienia
	var/bowel_steps = 0
	/// Kiedy było ostatnie wypróżnienie (albo pojawienie się postaci)
	var/bowel_since = 0

/mob/living/Initialize(mapload)
	. = ..()
	bowel_since = world.time

/mob/living/carbon/human/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	// Własne kroki: bez ciągnięcia za kimś, wózka, pojazdu i dryfu w nieważkości
	if(!Forced && !buckled && !pulledby && isturf(loc) && isturf(OldLoc) && has_gravity())
		bowel_steps++

/datum/reagent/consumable
	/// Wpływ na stolec: dodatni to błonnik (warzywa, owoce), ujemny to mięso, tłuszcz i cukier
	var/stool_diet = 0

/datum/reagent/consumable/nutriment/vitamin
	stool_diet = 1

/datum/reagent/consumable/nutriment/protein
	stool_diet = -1

/datum/reagent/consumable/nutriment/fat
	stool_diet = -1

/datum/reagent/consumable/sugar
	stool_diet = -1

/**
 * Typ stolca (1-7) w tej chwili.
 * reasons - lista, do której trafiają opisy przyczyn odchylenia od normy
 */
/mob/living/proc/stool_type(list/reasons)
	if(reagents?.has_reagent(/datum/reagent/consumable/castor_oil))
		reasons?.Add("olej rycynowy")
		return 7
	var/result = 4

	var/diet_total = bowel_fiber + bowel_junk
	if(diet_total >= BRISTOL_DIET_MIN_UNITS)
		var/fiber_ratio = bowel_fiber / diet_total
		if(fiber_ratio < 0.1)
			result -= 2
			reasons?.Add("prawie same mięso, tłuszcz i słodycze")
		else if(fiber_ratio < 0.25)
			result -= 1
			reasons?.Add("za mało warzyw i owoców")

	var/minutes = (world.time - bowel_since) / (1 MINUTES)
	if(minutes >= BRISTOL_ACTIVITY_MIN_MINUTES && bowel_steps / minutes < BRISTOL_SEDENTARY_STEPS_PER_MINUTE)
		result -= 1
		reasons?.Add("za mało ruchu")

	if(!HAS_TRAIT(src, TRAIT_NOTHIRST))
		if(hydration < HYDRATION_LEVEL_PARCHED)
			result -= 2
			reasons?.Add("mocne odwodnienie")
		else if(hydration < HYDRATION_LEVEL_THIRSTY)
			result -= 1
			reasons?.Add("za mało picia")

	if(bowel_laxative >= BRISTOL_LAXATIVE_STEP)
		result += min(2, round(bowel_laxative / BRISTOL_LAXATIVE_STEP))
		reasons?.Add("kawa albo ostre jedzenie")

	if(has_status_effect(/datum/status_effect/stoperan))
		result -= 2
		reasons?.Add("stoperan")

	if(iscarbon(src))
		var/mob/living/carbon/C = src
		if(C.disgust >= DISGUST_LEVEL_GROSS)
			result += 1
			reasons?.Add("zatrucie albo obrzydzenie")

	var/datum/component/mood/mood = GetComponent(/datum/component/mood)
	if(mood)
		if(mood.mood_level <= 3) // stres spycha na skraje skali
			result += (result < 4) ? -1 : 1
			reasons?.Add("stres")
		else if(mood.mood_level >= 7 && result != 4) // dobry humor trochę wyrównuje
			result += (result < 4) ? 1 : -1

	return clamp(result, 1, 7)

/// Mnożnik przyrostu potrzeby od jedzenia: przy zaparciu wolniej, przy biegunce szybciej
/mob/living/proc/stool_rate_mod()
	switch(stool_type())
		if(1)
			return 0.6
		if(2)
			return 0.8
		if(6)
			return 1.25
		if(7)
			return 1.5
	return 1

/// Próg popuszczenia: przy biegunce niższy
/mob/living/proc/accident_threshold()
	if(defecation <= DEFECATION_ACTUALLY_SHIT_YOURSELF - 20) // niżej żaden typ nie zmienia wyniku porównania, nie liczymy typu co tick
		return DEFECATION_ACTUALLY_SHIT_YOURSELF
	switch(stool_type())
		if(6)
			return DEFECATION_ACTUALLY_SHIT_YOURSELF - 10
		if(7)
			return DEFECATION_ACTUALLY_SHIT_YOURSELF - 20
	return DEFECATION_ACTUALLY_SHIT_YOURSELF

/// Ile trwa wypróżnienie: przy zaparciu dłużej
/mob/living/proc/bowel_movement_time()
	switch(stool_type())
		if(1)
			return 8 SECONDS
		if(2)
			return 5 SECONDS
	return 3 SECONDS

/// Opis typu w skali bristolskiej
/proc/bristol_description(stool_type)
	switch(stool_type)
		if(1)
			return "osobne twarde grudki jak orzechy. Ciężkie zaparcie."
		if(2)
			return "zbity, grudkowaty wałek. Zaparcie."
		if(3)
			return "wałek z pęknięciami na powierzchni. W normie."
		if(4)
			return "gładki, miękki wałek. Podręcznikowo!"
		if(5)
			return "miękkie kawałki o wyraźnych brzegach. Trochę za luźno."
		if(6)
			return "postrzępiona papka. Biegunka."
		if(7)
			return "sama woda, bez stałych kawałków. Ostra biegunka."

/// Podpowiedź na alercie potrzeby, gdy zanosi się na zaparcie albo biegunkę
/mob/living/proc/bowel_hint()
	var/current = stool_type()
	if(current <= 2)
		return " Brzuch jest ciężki i twardy, zanosi się na zaparcie."
	if(current >= 6)
		return " Burczy ci w brzuchu, zanosi się na biegunkę."
	return ""

/**
 * Wspólny koniec wypróżnienia (ubikacja, na miejscu, popuszczenie, toaleta myśliwca).
 * had_feces - czy wyszedł kał (sam mocz nie daje typu)
 * stool - kupa na podłodze, jeśli została
 * Olej rycynowy oczyszcza organizm jak dotąd, ale dopiero po odczytaniu typu.
 */
/mob/living/proc/finish_bowel_movement(had_feces, obj/effect/decal/cleanable/feces/stool)
	if(had_feces)
		var/list/reasons = list()
		var/current = stool_type(reasons)
		if(stool)
			stool.stool_type = current
		report_stool(current, reasons)
		bowel_fiber = 0
		bowel_junk = 0
		bowel_laxative = 0
		bowel_steps = 0
		bowel_since = world.time
	var/datum/reagent/consumable/castor_oil/oil = reagents?.get_reagent(/datum/reagent/consumable/castor_oil)
	oil?.purge(src)

/// Komunikat o typie i nastrój po wypróżnieniu
/mob/living/proc/report_stool(current, list/reasons)
	switch(current)
		if(1, 2)
			SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "bowel", /datum/mood_event/bowel/constipated)
		if(3, 4)
			SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "bowel", /datum/mood_event/bowel/regular)
		if(6, 7)
			SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "bowel", /datum/mood_event/bowel/diarrhea)
		else
			SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "bowel")
	if(censors_bodily_functions())
		return
	to_chat(src, "<span class='notice'>Typ [current] w skali bristolskiej: [bristol_description(current)]</span>")
	if(current != 4 && length(reasons))
		to_chat(src, "<span class='notice'>Możliwe przyczyny: [jointext(reasons, ", ")].</span>")

/// Moodlety po wypróżnieniu: przy cenzurze funkcji fizjologicznych działają jak zwykle (także na ikonę nastroju),
/// ale bez opisu w podglądzie nastroju. Opis przelicza się przy zmianie cenzury i przy wejściu do ciała.
/// Nie używamy `hidden`: print_mood() go nie sprawdza, a update_mood() odejmuje takie moodlety od ikony.
/datum/mood_event/bowel

/datum/mood_event/bowel/add_effects(param)
	var/datum/component/mood = owner // owner to w praktyce komponent nastroju (jak w /datum/mood_event/table)
	update_censored_description(mood?.parent)

/// Pusty opis przy cenzurze, oryginalny bez niej
/datum/mood_event/bowel/proc/update_censored_description(mob/viewer)
	description = viewer?.censors_bodily_functions() ? "" : initial(description)

/// Przelicza opis aktualnego moodletu wypróżnienia (po zmianie cenzury albo wejściu do ciała)
/mob/living/proc/update_bowel_moodlet()
	var/datum/component/mood/mood = GetComponent(/datum/component/mood)
	var/datum/mood_event/bowel/event = mood?.mood_events["bowel"]
	if(istype(event))
		event.update_censored_description(src)

/mob/living/refresh_bodily_censor()
	. = ..()
	update_bowel_moodlet()

/mob/living/Login()
	. = ..()
	update_bowel_moodlet()

/datum/mood_event/bowel/constipated
	description = "<span class='warning'>Wypróżnienie było męczarnią.</span>\n"
	mood_change = -2
	timeout = 3 MINUTES

/datum/mood_event/bowel/regular
	description = "<span class='nicegreen'>Wypróżnienie jak w zegarku.</span>\n"
	mood_change = 2
	timeout = 4 MINUTES

/datum/mood_event/bowel/diarrhea
	description = "<span class='warning'>Biegunka mnie wykańcza.</span>\n"
	mood_change = -2
	timeout = 3 MINUTES

/obj/effect/decal/cleanable/feces
	/// Typ w skali bristolskiej (0 = nieznany, np. kupa z mapy albo z zatkanej toalety)
	var/stool_type = 0

/obj/effect/decal/cleanable/feces/examine(mob/user)
	. = ..()
	if(stool_type && !user?.censors_bodily_functions())
		. += "<span class='notice'>Na oko typ [stool_type] w skali bristolskiej.</span>"

/atom/movable/screen/alert/need_to_shit/MouseEntered(location, control, params)
	var/mob/living/L = owner
	desc = initial(desc) + (istype(L) ? L.bowel_hint() : "")
	return ..()

/atom/movable/screen/alert/about_to_shit_myself/MouseEntered(location, control, params)
	var/mob/living/L = owner
	desc = initial(desc) + (istype(L) ? L.bowel_hint() : "")
	return ..()

#undef BRISTOL_ACTIVITY_MIN_MINUTES
#undef BRISTOL_SEDENTARY_STEPS_PER_MINUTE
#undef BRISTOL_DIET_MIN_UNITS
#undef BRISTOL_LAXATIVE_STEP
