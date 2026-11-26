// AQUILA - reagenty z przeglądu 246 kodów (raport/reagenty_02_plan_portu.md), grupa umysl.
// E. Umysł, ból i zabawki: Amnestyki klasy A (Foundation-19), Lokutogen (/vg/), Solipsizyna (Goon), Enzym bólu (Polaris),
// Sok bolących mózgów (Citadel), Lek hiperpsychotyczny (white), Randonium (Hippie), Rozłupująca trucizna (Vanderlin),
// Nanoboty energetyczne (/vg/), Syntetyczny czynnik wzrostu SDGF (Citadel).
// F. Pirotechnika: Trijodek azotu, Fotofosfid, Argina (Goon), Punktualit (/vg/).
// Działanie według planu, nie oryginału: zmiany względem oryginałów są opisane przy każdym reagencie.

/// Amnestyki: tyle minut wspomnień znika na każdą przyjętą jednostkę (Foundation-19: 5 j. = 10 minut)
#define AQ_AMNESTIC_MINUTES_PER_UNIT 2
/// Enzym bólu: ból bez obrażeń, stały i na jednostkę we krwi
#define AQ_PAIN_ENZYME_BASE 80
#define AQ_PAIN_ENZYME_PER_UNIT 2
#define AQ_PAIN_ENZYME_MAX 160
/// Enzym bólu: przeciwbólowy o takiej sile (GLOB.aq_painkillers) albo silniejszy rozkłada enzym
#define AQ_PAIN_ENZYME_STRONG_PAINKILLER 60
/// SDGF: najmniejsza dawka, z której wyrośnie kopia, i liczba cykli (po 2 s) do jej powstania
#define AQ_SDGF_MIN_DOSE 50
#define AQ_SDGF_GROW_CYCLES 90
/// SDGF bez kopii: pełne leczenie (15/15/5) dopiero od tylu wchłoniętych jednostek, mniej proporcjonalnie
#define AQ_SDGF_FULL_HEAL_UNITS 10
/// Fotofosfid na podłodze wybucha przy takim oświetleniu kafelka
#define AQ_PHOTOPHOSPHIDE_LUM 0.35
/// Lek hiperpsychotyczny: od tylu jednostek we krwi i tylu cykli daje rozdwojenie jaźni
#define AQ_HYPERPSY_MIN_UNITS 5
#define AQ_HYPERPSY_MIN_CYCLES 5

/// Ckey (albo umysł, gdy ciało nie ma gracza) -> imię kopii: SDGF daje jedną kopię na gracza na rundę
GLOBAL_LIST_EMPTY(aq_sdgf_cloned)

/// Wołane przez add_reagent() zaraz po utworzeniu reagentu w holderze (holder, dane i objętość już ustawione),
/// także dla produktu syntezy, który powstaje bez danych i nie dostaje on_new()
/datum/reagent/proc/aq_on_created()
	return

/// Wybuch reagentu w miejscu (siła jak w reagent_explosion: 1 = mały wybuch). Siła poniżej 1 daje tylko huk i przewrócenie
/proc/aq_reagent_blast(atom/where, power, reagent_name)
	var/turf/T = get_turf(where)
	if(!T)
		return
	log_game("Reagent [reagent_name] blast (power [power]) at [AREACOORD(T)].")
	if(power < 1)
		playsound(T, 'sound/effects/bang.ogg', 50, TRUE)
		T.visible_message("<span class='danger'>[reagent_name] trzaska z hukiem!</span>")
		for(var/mob/living/victim in range(1, T))
			victim.Knockdown(2 SECONDS)
			victim.adjustBruteLoss(3)
		return
	var/inside_msg = ""
	if(ismob(where))
		inside_msg = " (wewnątrz: [ADMIN_LOOKUPFLW(where)])"
	message_admins("Wybuch reagentu [reagent_name] w [ADMIN_VERBOSEJMP(T)][inside_msg].")
	var/datum/effect_system/reagents_explosion/blast = new()
	blast.set_up(power, T, 0, 0)
	blast.start()

// --- E1: Amnestyki klasy A ---

/// Foundation-19: po wypłukaniu z krwi ofiara nie pamięta ostatnich minut (tak jak przy klonowaniu w zasadach serwera)
/datum/reagent/aq_amnestics
	name = "Amnestyki klasy A"
	description = "Usuwają pamięć krótkotrwałą. Gdy lek zejdzie z krwi, ofiara nie pamięta ostatnich minut: około dwóch na każdą przyjętą jednostkę."
	reagent_state = LIQUID
	color = "#B8E8F0"
	taste_description = "pustka"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 30
	/// Ile leku zdążyło się wchłonąć
	var/aq_dose = 0

/datum/reagent/aq_amnestics/on_mob_life(mob/living/carbon/M)
	aq_dose += metabolization_rate * M.metabolism_efficiency
	if(prob(10))
		M.drowsyness = max(M.drowsyness, 3)
	if(prob(35))
		M.Dizzy(5)
	..()

/datum/reagent/aq_amnestics/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1)
	if(prob(10))
		M.Sleeping(4 SECONDS)
	..()
	return TRUE

/datum/reagent/aq_amnestics/on_mob_delete(mob/living/L)
	. = ..()
	if(QDELETED(L) || L.stat == DEAD || aq_dose < 0.5)
		return
	var/minutes = clamp(round(aq_dose * AQ_AMNESTIC_MINUTES_PER_UNIT), 1, 60)
	L.visible_message("<span class='warning'>Na twarzy [L] przez chwilę maluje się zagubienie.</span>")
	to_chat(L, "<span class='userdanger'><font size='4'>Wspomnienia się rozmywają... Nie pamiętasz niczego z ostatnich [minutes] min.</font></span>")
	L.drowsyness = max(L.drowsyness, 10)
	L.Dizzy(15)
	L.log_message("forgot the last [minutes] minutes from class-A amnestics", LOG_ATTACK)

/datum/chemical_reaction/aq_amnestics
	name = "Amnestyki klasy A"
	id = /datum/reagent/aq_amnestics
	results = list(/datum/reagent/aq_amnestics = 3)
	required_reagents = list(/datum/reagent/toxin/mindbreaker = 1, /datum/reagent/medicine/mannitol = 1, /datum/reagent/impedrezene = 1)

// --- E2: Lokutogen ---

/// /vg/: roztwór w pojemniku nagrywa pierwsze usłyszane zdanie, a po wypiciu odtwarza je w głowie pijącego
/datum/reagent/aq_locutogen
	name = "Lokutogen"
	description = "Roztwór czuły na dźwięk. W pojemniku zapisuje pierwsze usłyszane zdanie, a ten, kto go wypije, słyszy je w głowie."
	reagent_state = LIQUID
	color = "#F2D6A0"
	taste_description = "słodycz"
	data = list("phrase" = null)
	/// Pojemnik, w którym nasłuchujemy
	var/atom/movable/aq_ear

/datum/reagent/aq_locutogen/aq_on_created()
	. = ..()
	// trans_id_to() przekazuje tę samą listę data: własna kopia, żeby nagranie w jednym pojemniku nie trafiło do drugiego
	data = islist(data) ? data.Copy() : list("phrase" = null)
	aq_listen()

/datum/reagent/aq_locutogen/Destroy()
	aq_stop_listening()
	return ..()

/// Zaczyna nasłuch w pojemniku, jeśli zdanie nie jest jeszcze zapisane
/datum/reagent/aq_locutogen/proc/aq_listen()
	if(aq_ear || LAZYACCESS(data, "phrase"))
		return
	var/atom/movable/container = holder?.my_atom
	if(!istype(container) || ismob(container) || istype(container, /obj/item/organ)) // w żołądku nagrałby rozmowę po wypiciu
		return
	if(!islist(data))
		data = list("phrase" = null)
	aq_ear = container
	container.become_hearing_sensitive(REF(src))
	RegisterSignal(container, COMSIG_MOVABLE_HEAR, PROC_REF(aq_on_hear))
	RegisterSignal(container, COMSIG_PARENT_QDELETING, PROC_REF(aq_stop_listening))

/datum/reagent/aq_locutogen/proc/aq_stop_listening()
	SIGNAL_HANDLER
	if(!aq_ear)
		return
	UnregisterSignal(aq_ear, list(COMSIG_MOVABLE_HEAR, COMSIG_PARENT_QDELETING))
	REMOVE_TRAIT(aq_ear, TRAIT_HEARING_SENSITIVE, REF(src))
	aq_ear = null

/datum/reagent/aq_locutogen/proc/aq_on_hear(datum/source, list/hearing_args)
	SIGNAL_HANDLER
	var/phrase = hearing_args[HEARING_RAW_MESSAGE]
	if(!istext(phrase) || !length(phrase))
		return
	data["phrase"] = copytext_char(phrase, 1, 200)
	aq_stop_listening()

/datum/reagent/aq_locutogen/on_mob_life(mob/living/carbon/M)
	var/phrase = LAZYACCESS(data, "phrase")
	if(phrase && M.stat == CONSCIOUS)
		to_chat(M, "<span class='notice'>Słyszysz w głowie głos, który mówi: <b>„[phrase]”</b>.</span>")
		holder.del_reagent(type)
		return
	..()

/datum/chemical_reaction/aq_locutogen
	name = "Lokutogen"
	id = /datum/reagent/aq_locutogen
	results = list(/datum/reagent/aq_locutogen = 3)
	required_reagents = list(/datum/reagent/medicine/inacusiate = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/silicon = 1)


// --- E3: Solipsizyna ---

/// Goon: inni ludzie znikają z ekranu pijącego, a mowa cichnie (głuchota na czas działania)
/datum/reagent/aq_solipsizine
	name = "Solipsizyna"
	description = "Silny halucynogen. Po chwili wszyscy inni ludzie znikają pijącemu z oczu, a wokół robi się całkiem cicho."
	reagent_state = LIQUID
	color = "#C4C4D8"
	taste_description = "samotność"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	/// Ukryty człowiek -> obraz, który go zasłania
	var/list/aq_hidden
	/// Kto nie widzi innych
	var/mob/living/aq_viewer

/datum/reagent/aq_solipsizine/on_mob_life(mob/living/carbon/M)
	if(prob(3))
		to_chat(M, "<span class='notice'>[pick("Czujesz się dziwnie samotnie...", "Nagle wszystko ucichło.", "Słyszysz bicie własnego serca.", "Coś jest nie tak.")]</span>")
	if(current_cycle > 7)
		ADD_TRAIT(M, TRAIT_DEAF, type)
		if(!(current_cycle % 3) || !aq_hidden)
			aq_hide_others(M)
	..()

/// Zasłania pijącemu ludzi w zasięgu wzroku (obraz z override na każdym z nich, widoczny tylko dla niego)
/datum/reagent/aq_solipsizine/proc/aq_hide_others(mob/living/M)
	if(aq_viewer != M)
		aq_viewer = M
		// Login() czyści client.images: po ponownym zalogowaniu obrazy trzeba dodać od nowa
		RegisterSignal(M, COMSIG_MOB_CLIENT_LOGIN, PROC_REF(aq_on_login))
	LAZYINITLIST(aq_hidden)
	for(var/mob/living/carbon/human/other in view(M))
		if(other == M || aq_hidden[other])
			continue
		var/image/blank = image(loc = other)
		blank.override = TRUE
		aq_hidden[other] = blank
		M.client?.images += blank
		RegisterSignal(other, COMSIG_PARENT_QDELETING, PROC_REF(aq_unhide))

/datum/reagent/aq_solipsizine/proc/aq_on_login(mob/source, client/new_client)
	SIGNAL_HANDLER
	for(var/mob/living/other as anything in aq_hidden)
		new_client.images |= aq_hidden[other]

/datum/reagent/aq_solipsizine/proc/aq_unhide(mob/living/other)
	SIGNAL_HANDLER
	var/image/blank = LAZYACCESS(aq_hidden, other)
	UnregisterSignal(other, COMSIG_PARENT_QDELETING)
	aq_viewer?.client?.images -= blank
	LAZYREMOVE(aq_hidden, other)

/datum/reagent/aq_solipsizine/proc/aq_unhide_all()
	for(var/mob/living/other as anything in aq_hidden)
		aq_unhide(other)
	aq_hidden = null
	if(aq_viewer)
		UnregisterSignal(aq_viewer, COMSIG_MOB_CLIENT_LOGIN)
		REMOVE_TRAIT(aq_viewer, TRAIT_DEAF, type)
	aq_viewer = null

/datum/reagent/aq_solipsizine/on_mob_delete(mob/living/L)
	aq_unhide_all()
	REMOVE_TRAIT(L, TRAIT_DEAF, type)
	if(!QDELETED(L) && current_cycle > 7)
		to_chat(L, "<span class='notice'>Ludzie wokół ciebie znów się pojawiają.</span>")
		L.Jitter(10)
	return ..()

/datum/reagent/aq_solipsizine/Destroy()
	aq_unhide_all()
	return ..()

/datum/chemical_reaction/aq_solipsizine
	name = "Solipsizyna"
	id = /datum/reagent/aq_solipsizine
	results = list(/datum/reagent/aq_solipsizine = 3)
	required_reagents = list(/datum/reagent/toxin/mindbreaker = 1, /datum/reagent/medicine/haloperidol = 1, /datum/reagent/drug/space_drugs = 1)

// --- E4: Enzym bólu ---

/// Polaris: ogromny ból bez obrażeń (aquila/code/modules/pain/pain.dm), aż enzym zejdzie albo rozłoży go silny środek przeciwbólowy
/datum/reagent/aq_pain_enzyme
	name = "Enzym bólu"
	description = "Enzym, który pobudza nerwy do skrajnego bólu, choć ciało jest całe. Schodzi bardzo powoli. Rozkłada go dopiero silny środek przeciwbólowy albo dializa."
	reagent_state = LIQUID
	color = "#B03030"
	taste_description = "palący ogień"
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	overdose_threshold = 100

/// Ból, który enzym dodaje do bólu z ciała
/datum/reagent/aq_pain_enzyme/proc/aq_pain_amount()
	return min(AQ_PAIN_ENZYME_MAX, AQ_PAIN_ENZYME_BASE + volume * AQ_PAIN_ENZYME_PER_UNIT)

/datum/reagent/aq_pain_enzyme/on_mob_life(mob/living/carbon/M)
	for(var/datum/reagent/other as anything in M.reagents.reagent_list)
		if(GLOB.aq_painkillers[other.type] >= AQ_PAIN_ENZYME_STRONG_PAINKILLER)
			M.reagents.remove_reagent(type, 2)
			if(prob(10))
				to_chat(M, "<span class='notice'>Palenie w nerwach powoli przygasa.</span>")
			break
	if(prob(2))
		to_chat(M, "<span class='userdanger'>Całe ciało płonie żywym ogniem!</span>")
	..()

/datum/reagent/aq_pain_enzyme/overdose_process(mob/living/M)
	if(prob(10))
		M.emote("scream")
		M.Paralyze(2 SECONDS)
	..()

/// Enzym bólu dokłada ból do bólu z ciała, z tymi samymi wyjątkami (śmierć, znieczulenie, syntetyczne ciało)
/mob/living/carbon/human/aq_compute_pain()
	. = ..()
	var/datum/reagent/aq_pain_enzyme/enzyme = reagents?.get_reagent(/datum/reagent/aq_pain_enzyme)
	if(!enzyme || stat == DEAD || HAS_TRAIT(src, TRAIT_ANALGESIA) || (status_flags & GODMODE))
		return
	var/obj/item/bodypart/chest = get_bodypart(BODY_ZONE_CHEST)
	if(!chest || !IS_ORGANIC_LIMB(chest))
		return
	. += enzyme.aq_pain_amount()

/datum/chemical_reaction/aq_pain_enzyme
	name = "Enzym bólu"
	id = /datum/reagent/aq_pain_enzyme
	results = list(/datum/reagent/aq_pain_enzyme = 2)
	required_reagents = list(/datum/reagent/toxin/histamine = 1, /datum/reagent/consumable/condensedcapsaicin = 1, /datum/reagent/toxin/formaldehyde = 1)

// --- E5: Sok bolących mózgów ---

/// Citadel: jeden losowy uraz mózgu na dawkę, od lekkiego do ciężkiego (w oryginale co cykl, także specjalne)
/datum/reagent/toxin/aq_brain_hurting_juice
	name = "Sok bolących mózgów"
	description = "Mętny sok, od którego mózg dostaje losowego urazu, czasem lekkiego, czasem ciężkiego."
	reagent_state = LIQUID
	color = "#E0A0D0"
	taste_description = "zgrzyt w głowie"
	toxpwr = 0
	/// Uraz dany już w tej dawce
	var/aq_trauma_given = FALSE

/datum/reagent/toxin/aq_brain_hurting_juice/on_mob_life(mob/living/carbon/M)
	if(!aq_trauma_given && volume >= 1)
		aq_trauma_given = TRUE
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5)
		M.gain_trauma_type(prob(65) ? BRAIN_TRAUMA_MILD : BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_BASIC)
		to_chat(M, "<span class='warning'>Coś w twojej głowie przeskakuje nie na swoje miejsce.</span>")
	..()

/datum/chemical_reaction/aq_brain_hurting_juice
	name = "Sok bolących mózgów"
	id = /datum/reagent/toxin/aq_brain_hurting_juice
	results = list(/datum/reagent/toxin/aq_brain_hurting_juice = 2)
	required_reagents = list(/datum/reagent/toxin/bonehurtingjuice = 1, /datum/reagent/toxin/mindbreaker = 1)

// --- E6: Lek hiperpsychotyczny ---

/// white: rozdwojenie jaźni (nasz uraz split_personality, drugą osobowość dostaje duch z ankiety)
/datum/reagent/toxin/aq_hyperpsy
	name = "Lek hiperpsychotyczny"
	description = "Silna toksyna psychotyczna. Rozszczepia osobowość: w ciele zamieszkuje druga, obca świadomość."
	reagent_state = LIQUID
	color = "#7A2E8E"
	taste_description = "dwa smaki naraz"
	toxpwr = 0.5

/// Śladowa ilość nic nie robi: rozdwojenie dopiero od AQ_HYPERPSY_MIN_UNITS we krwi przez kilka cykli
/datum/reagent/toxin/aq_hyperpsy/on_mob_life(mob/living/carbon/M)
	if(current_cycle >= AQ_HYPERPSY_MIN_CYCLES && volume >= AQ_HYPERPSY_MIN_UNITS && M.mind && !M.has_trauma_type(/datum/brain_trauma/severe/split_personality))
		M.gain_trauma(/datum/brain_trauma/severe/split_personality, TRAUMA_RESILIENCE_SURGERY)
	return ..()

/datum/chemical_reaction/aq_hyperpsy
	name = "Lek hiperpsychotyczny"
	id = /datum/reagent/toxin/aq_hyperpsy
	results = list(/datum/reagent/toxin/aq_hyperpsy = 2)
	required_reagents = list(/datum/reagent/toxin/mindbreaker = 2, /datum/reagent/toxin/rotatium = 1, /datum/reagent/lithium = 1)

// --- E7: Randonium ---

/// Hippie: co chwilę wstrzykuje losowy reagent; u nas tylko z listy niegroźnych
/datum/reagent/aq_randonium
	name = "Randonium"
	description = "Musujący, chaotyczny płyn. Co chwilę zamienia się we krwi w coś innego: w wodę, mleko, kawę albo brokat."
	reagent_state = LIQUID
	color = "#FF66CC"
	taste_description = "wszystko naraz"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	/// Niegroźne reagenty, które może wstrzyknąć
	var/static/list/aq_harmless = list(
		/datum/reagent/water,
		/datum/reagent/consumable/sugar,
		/datum/reagent/consumable/sodiumchloride,
		/datum/reagent/consumable/milk,
		/datum/reagent/consumable/coffee,
		/datum/reagent/consumable/tea,
		/datum/reagent/consumable/space_cola,
		/datum/reagent/consumable/orangejuice,
		/datum/reagent/consumable/lemonjuice,
		/datum/reagent/consumable/banana,
		/datum/reagent/consumable/honey,
		/datum/reagent/consumable/cocoa/hot_cocoa,
		/datum/reagent/consumable/sprinkles,
		/datum/reagent/consumable/nothing,
		/datum/reagent/consumable/laughter,
		/datum/reagent/glitter,
		/datum/reagent/colorful_reagent,
	)

/datum/reagent/aq_randonium/on_mob_life(mob/living/carbon/M)
	if(current_cycle % 3 == 0)
		M.reagents.add_reagent(pick(aq_harmless), 2)
	..()

/datum/chemical_reaction/aq_randonium
	name = "Randonium"
	id = /datum/reagent/aq_randonium
	results = list(/datum/reagent/aq_randonium = 3)
	required_reagents = list(/datum/reagent/drug/methamphetamine = 1, /datum/reagent/teslium = 1, /datum/reagent/colorful_reagent = 1)

// --- E8: Rozłupująca trucizna ---

/// Vanderlin: na czas działania kończyny łatwiej odpadają przy obrażeniach (TRAIT_EASYDISMEMBER)
/datum/reagent/toxin/aq_splitting_poison
	name = "Rozłupująca trucizna"
	description = "Rozmiękcza stawy i ścięgna. Dopóki działa, kończyny odpadają od ciosów dużo łatwiej."
	reagent_state = LIQUID
	color = "#6E8B3D"
	taste_description = "trzeszczenie w stawach"
	toxpwr = 0.5

/datum/reagent/toxin/aq_splitting_poison/on_mob_metabolize(mob/living/L)
	. = ..()
	ADD_TRAIT(L, TRAIT_EASYDISMEMBER, type)

/datum/reagent/toxin/aq_splitting_poison/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_EASYDISMEMBER, type)
	return ..()

/datum/reagent/toxin/aq_splitting_poison/on_mob_life(mob/living/carbon/M)
	if(prob(5))
		to_chat(M, "<span class='warning'>Twoje stawy trzeszczą i luźno chodzą w zawiasach.</span>")
	..()

/datum/chemical_reaction/aq_splitting_poison
	name = "Rozłupująca trucizna"
	id = /datum/reagent/toxin/aq_splitting_poison
	results = list(/datum/reagent/toxin/aq_splitting_poison = 2)
	required_reagents = list(/datum/reagent/toxin/bonehurtingjuice = 1, /datum/reagent/toxin/acid/fluacid = 1)

// --- E9: Nanoboty energetyczne ---

/// /vg/: ładują po trochu ogniwa niesionych przedmiotów, zabierając odżywienie, i usuwają promieniowanie
/datum/reagent/aq_energetic_nanobots
	name = "Nanoboty energetyczne"
	description = "Mikroskopijne roboty, które ładują ogniwa przedmiotów noszonych przy ciele. Energię biorą z odżywienia nosiciela. Przy okazji wyłapują promieniowanie."
	reagent_state = LIQUID
	color = "#3A6EA5"
	taste_description = "bateryjka na języku"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	/// Ładunek dla jednego ogniwa na cykl
	var/aq_charge_per_cell = 100

/datum/reagent/aq_energetic_nanobots/on_mob_life(mob/living/carbon/M)
	var/charged = 0
	if(M.nutrition > NUTRITION_LEVEL_STARVING)
		for(var/obj/item/stock_parts/cell/cell in M.GetAllContents())
			if(cell.charge >= cell.maxcharge)
				continue
			cell.give(aq_charge_per_cell)
			cell.update_icon()
			charged++
			if(charged >= 4)
				break
	if(charged)
		M.adjust_nutrition(-charged)
	var/datum/component/irradiated/irradiated_component = M.GetComponent(/datum/component/irradiated)
	irradiated_component?.adjust_intensity(-1)
	..()

/datum/chemical_reaction/aq_energetic_nanobots
	name = "Nanoboty energetyczne"
	id = /datum/reagent/aq_energetic_nanobots
	results = list(/datum/reagent/aq_energetic_nanobots = 2)
	required_reagents = list(/datum/reagent/silicon = 2, /datum/reagent/teslium = 1, /datum/reagent/uranium = 1)

// --- E10: Syntetyczny czynnik wzrostu (SDGF) ---

/// Citadel: po dużej dawce i kilku minutach obok pijącego wyrasta kopia ciała, do której wchodzi duch z ankiety.
/// U nas: jedna kopia na gracza na rundę (GLOB.aq_sdgf_cloned), kopia naga, bez wspomnień i bez dostępu.
/// Bez chętnego ducha albo przy za małej dawce komórki wtapiają się w ciało i trochę je leczą.
/datum/reagent/aq_sdgf
	name = "Syntetyczny czynnik wzrostu"
	description = "Masa szybko dzielących się komórek, które kopiują DNA nosiciela. Duża dawka po kilku minutach wyrasta obok niego w osobne ciało: bez wspomnień, bez ubrania i bez dostępu."
	reagent_state = LIQUID
	color = "#E8C8B0"
	taste_description = "surowe mięso"
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	/// Ankieta duchów już wysłana w tej dawce
	var/aq_poll_started = FALSE
	/// Duchy, które zgłosiły się do kopii
	var/list/aq_candidates
	/// Kopii nie będzie (za mała dawka albo limit), komórki tylko leczą
	var/aq_merge_only = FALSE
	/// Ile zdążyło się wchłonąć: od tego zależy leczenie przy wtopieniu, żeby mikrodawki nie leczyły jak pełna
	var/aq_absorbed = 0

/// Klucz gracza do limitu kopii, stały także wtedy, gdy ciało chwilowo nie ma klienta (duch wyszedł z ciała):
/// klucz gracza zapisany w umyśle, bez umysłu ckey, a bez gracza samo ciało
/proc/aq_sdgf_key(mob/living/M)
	if(M.mind?.key)
		return ckey(M.mind.key)
	if(M.ckey)
		return M.ckey
	return REF(M)

/// Klucz limitu po DNA ciała: kopia ma to samo DNA co oryginał, więc nie wyhoduje następnej kopii tego ciała
/proc/aq_sdgf_dna_key(mob/living/M)
	var/mob/living/carbon/C = M
	if(!istype(C) || !C.dna?.unique_enzymes)
		return null
	return "dna:[C.dna.unique_enzymes]"

/proc/aq_sdgf_can_clone(mob/living/M)
	if(GLOB.aq_sdgf_cloned[aq_sdgf_key(M)])
		return FALSE
	var/dna_key = aq_sdgf_dna_key(M)
	return !(dna_key && GLOB.aq_sdgf_cloned[dna_key])

/// Wyhodowanie kopii ciała obok oryginału. Zapisuje limit. Bez ducha (candidate) ciało zostaje bez umysłu
/proc/aq_sdgf_grow_clone(mob/living/carbon/human/original, mob/dead/observer/candidate)
	if(!istype(original) || !aq_sdgf_can_clone(original))
		return
	var/turf/T = get_turf(original)
	var/mob/living/carbon/human/clone = new(T)
	original.dna.transfer_identity(clone)
	clone.real_name = original.real_name
	clone.name = original.real_name
	clone.updateappearance(mutcolor_update = TRUE)
	GLOB.aq_sdgf_cloned[aq_sdgf_key(original)] = clone.real_name
	var/dna_key = aq_sdgf_dna_key(original)
	if(dna_key)
		GLOB.aq_sdgf_cloned[dna_key] = clone.real_name
	original.visible_message("<span class='warning'>Spod skóry [original] wylewa się masa komórek, która w oczach układa się w drugie, nagie ciało!</span>", \
		"<span class='userdanger'>Komórki pękają ci pod skórą i wylewają się na zewnątrz, układając się w twoje drugie ciało!</span>")
	playsound(T, 'sound/effects/splat.ogg', 50, TRUE)
	if(candidate?.client)
		clone.key = candidate.key
		GLOB.aq_sdgf_cloned[aq_sdgf_key(clone)] = clone.real_name // gracz kopii też już ma swoją kopię za sobą
		to_chat(clone, "<span class='userdanger'>Jesteś kopią ciała [original.real_name], wyhodowaną z syntetycznego czynnika wzrostu.</span>")
		to_chat(clone, "<span class='warning'>Nie masz żadnych wspomnień oryginału: nie znasz jego przyjaciół, haseł ani tego, co robił. Nie masz też ubrania, dokumentów ani dostępu.</span>")
		log_game("[key_name(clone)] became the SDGF copy of [key_name(original)].")
		message_admins("[ADMIN_LOOKUPFLW(clone)] zostaje kopią ciała (SDGF) [ADMIN_LOOKUPFLW(original)].")
	else
		log_game("SDGF copy of [key_name(original)] grew without a ghost.")
	return clone

/datum/reagent/aq_sdgf/on_mob_life(mob/living/carbon/M)
	aq_absorbed += metabolization_rate * M.metabolism_efficiency
	if(!aq_poll_started)
		aq_poll_started = TRUE
		if(!ishuman(M) || !M.mind || volume < AQ_SDGF_MIN_DOSE || !aq_sdgf_can_clone(M))
			aq_merge_only = TRUE
		else
			to_chat(M, "<span class='notice'>Czujesz, jak coś zaczyna rosnąć ci pod skórą. Jeśli wejdzie w to duch, będzie wyglądać jak ty, ale nie będzie nic pamiętać.</span>")
			log_game("SDGF: [key_name(M)] took [volume]u of SDGF, ghosts polled.")
			INVOKE_ASYNC(src, PROC_REF(aq_poll_ghosts), M)
	if(!aq_merge_only)
		M.adjust_nutrition(-2)
		if(current_cycle == round(AQ_SDGF_GROW_CYCLES / 2))
			to_chat(M, "<span class='warning'>Coś przelewa ci się pod skórą, a żołądek skręca się z głodu.</span>")
		if(current_cycle >= AQ_SDGF_GROW_CYCLES)
			aq_finish_growth(M)
			return
	..()

/datum/reagent/aq_sdgf/proc/aq_poll_ghosts(mob/living/carbon/M)
	var/list/candidates = pollGhostCandidates("Chcesz zagrać jako kopia ciała [M.real_name]? Kopia nie ma wspomnień oryginału ani dostępu.", ROLE_EXPERIMENTAL_CLONE, null, 30 SECONDS)
	if(QDELETED(src))
		return
	aq_candidates = candidates

/// Koniec wzrostu: kopia z pierwszym dostępnym duchem albo wtopienie komórek w ciało
/datum/reagent/aq_sdgf/proc/aq_finish_growth(mob/living/carbon/M)
	var/mob/dead/observer/chosen
	for(var/mob/dead/observer/ghost in shuffle(aq_candidates))
		if(ghost.client && ghost.key)
			chosen = ghost
			break
	aq_candidates = null
	aq_merge_only = TRUE
	if(chosen && ishuman(M) && aq_sdgf_grow_clone(M, chosen))
		aq_merge_only = FALSE
	else
		aq_merge_heal(M, 1)
	holder.del_reagent(type)

/// Komórki bez kopii wtapiają się w ciało i trochę je leczą (scale 1 = pełne leczenie)
/datum/reagent/aq_sdgf/proc/aq_merge_heal(mob/living/carbon/M, scale)
	scale = clamp(scale, 0, 1)
	if(scale <= 0)
		return
	to_chat(M, "<span class='notice'>Komórki nie dają rady się oddzielić i wtapiają się w twoje ciało, zasklepiając rany.</span>")
	M.adjustBruteLoss(-15 * scale, 0)
	M.adjustFireLoss(-15 * scale, 0)
	M.adjustCloneLoss(-5 * scale, 0)

/datum/reagent/aq_sdgf/on_mob_delete(mob/living/L)
	if(aq_merge_only && !QDELETED(L) && L.stat != DEAD && current_cycle < AQ_SDGF_GROW_CYCLES)
		aq_merge_heal(L, aq_absorbed / AQ_SDGF_FULL_HEAL_UNITS)
	return ..()

/datum/chemical_reaction/aq_sdgf
	name = "Syntetyczny czynnik wzrostu"
	id = /datum/reagent/aq_sdgf
	results = list(/datum/reagent/aq_sdgf = 2)
	required_reagents = list(/datum/reagent/medicine/synthflesh = 1, /datum/reagent/stable_plasma = 1, /datum/reagent/uranium = 1, /datum/reagent/toxin/mutagen = 1, /datum/reagent/medicine/clonexadone = 1)
	required_catalysts = list(/datum/reagent/bluespace = 5)
	is_cold_recipe = TRUE
	required_temp = 100

// --- F: Pirotechnika ---

/// Goon: w płynie stabilny; rozlany na podłogę po chwili wysycha i wybucha od dotyku albo kroku. Podgrzany w pojemniku wybucha
/datum/reagent/aq_nitrogen_triiodide
	name = "Trijodek azotu"
	description = "Stabilny, póki jest mokry. Rozlany na podłogę wysycha po pół minuty i wybucha od pierwszego kroku albo dotyku. Podgrzany wybucha od razu."
	reagent_state = LIQUID
	color = "#4A2E1E"
	taste_description = "jod"

/datum/reagent/aq_nitrogen_triiodide/reaction_turf(turf/T, volume)
	if(volume < 5 || isspaceturf(T))
		return
	var/obj/effect/decal/cleanable/chem_pile/aq_nitrogen_triiodide/pile = locate() in T
	if(!pile)
		pile = new(T)
	pile.reagents.add_reagent(type, volume, no_react = TRUE)

/obj/effect/decal/cleanable/chem_pile/aq_nitrogen_triiodide
	name = "plama trijodku azotu"
	desc = "Ciemnobrązowa plama. Lepiej jej nie dotykać, gdy wyschnie."
	color = "#4A2E1E"
	mergeable_decal = FALSE
	/// Wyschnięta: wybucha od dotyku
	var/aq_dry = FALSE

/obj/effect/decal/cleanable/chem_pile/aq_nitrogen_triiodide/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(aq_dry_out)), 30 SECONDS)

/obj/effect/decal/cleanable/chem_pile/aq_nitrogen_triiodide/proc/aq_dry_out()
	aq_dry = TRUE
	desc = "Sucha, ciemnofioletowa skorupa. Trzeszczy od samego patrzenia."
	color = "#5A2A5A"

/obj/effect/decal/cleanable/chem_pile/aq_nitrogen_triiodide/proc/aq_detonate()
	if(QDELETED(src))
		return
	var/amount = reagents?.get_reagent_amount(/datum/reagent/aq_nitrogen_triiodide)
	var/turf/T = get_turf(src)
	qdel(src)
	aq_reagent_blast(T, amount / 20, "Trijodek azotu")

/obj/effect/decal/cleanable/chem_pile/aq_nitrogen_triiodide/on_entered(datum/source, atom/movable/O)
	. = ..()
	if(!aq_dry || !isliving(O))
		return
	var/mob/living/walker = O
	if(walker.movement_type & (FLYING | FLOATING))
		return
	INVOKE_ASYNC(src, PROC_REF(aq_detonate))

/obj/effect/decal/cleanable/chem_pile/aq_nitrogen_triiodide/attack_hand(mob/living/user)
	if(aq_dry)
		aq_detonate()
		return TRUE
	return ..()

/obj/effect/decal/cleanable/chem_pile/aq_nitrogen_triiodide/attackby(obj/item/W, mob/user, params)
	if(aq_dry)
		aq_detonate()
		return TRUE
	return ..()

/datum/chemical_reaction/aq_nitrogen_triiodide
	name = "Trijodek azotu"
	id = /datum/reagent/aq_nitrogen_triiodide
	results = list(/datum/reagent/aq_nitrogen_triiodide = 2)
	required_reagents = list(/datum/reagent/ammonia = 1, /datum/reagent/iodine = 2)

/datum/chemical_reaction/reagent_explosion/aq_nitrogen_triiodide_explosion
	name = "Wybuch trijodku azotu"
	id = "aq_nitrogen_triiodide_explosion"
	required_reagents = list(/datum/reagent/aq_nitrogen_triiodide = 1)
	required_temp = 374
	strengthdiv = 6

/// Goon: wybucha od światła. W pojemniku bezpieczny, rozlany na podłogę wybucha, gdy kafelek jest oświetlony
/datum/reagent/aq_photophosphide
	name = "Fotofosfid"
	description = "Materiał wybuchowy czuły na światło. W pojemniku bezpieczny, ale rozlany wybucha, gdy tylko pada na niego światło."
	reagent_state = LIQUID
	color = "#E8E070"
	taste_description = "błysk"

/datum/reagent/aq_photophosphide/reaction_turf(turf/T, volume)
	if(volume < 5 || isspaceturf(T))
		return
	var/obj/effect/decal/cleanable/chem_pile/aq_photophosphide/pile = locate() in T
	if(!pile)
		pile = new(T)
	pile.reagents.add_reagent(type, volume, no_react = TRUE)

/obj/effect/decal/cleanable/chem_pile/aq_photophosphide
	name = "plama fotofosfidu"
	desc = "Żółtawy proszek. Lepiej trzymać go w ciemności."
	color = "#E8E070"
	mergeable_decal = FALSE

/obj/effect/decal/cleanable/chem_pile/aq_photophosphide/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/decal/cleanable/chem_pile/aq_photophosphide/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/decal/cleanable/chem_pile/aq_photophosphide/process(delta_time)
	var/turf/T = get_turf(src)
	if(T)
		aq_check_light(T.get_lumcount())

/// Wybuch, jeśli kafelek jest dość jasny
/obj/effect/decal/cleanable/chem_pile/aq_photophosphide/proc/aq_check_light(lum)
	if(lum < AQ_PHOTOPHOSPHIDE_LUM || QDELETED(src))
		return FALSE
	var/amount = reagents?.get_reagent_amount(/datum/reagent/aq_photophosphide)
	var/turf/T = get_turf(src)
	qdel(src)
	aq_reagent_blast(T, amount / 10, "Fotofosfid")
	return TRUE

/datum/chemical_reaction/aq_photophosphide
	name = "Fotofosfid"
	id = /datum/reagent/aq_photophosphide
	results = list(/datum/reagent/aq_photophosphide = 4)
	required_reagents = list(/datum/reagent/toxin/plasma = 1, /datum/reagent/phosphorus = 1, /datum/reagent/iron = 1, /datum/reagent/diethylamine = 1)

/// Goon: wybucha, gdy ostygnie poniżej zera
/datum/reagent/aq_argine
	name = "Argina"
	description = "Dziwny związek, który w cieple jest spokojny, ale wybucha, gdy tylko ostygnie poniżej zera."
	reagent_state = LIQUID
	color = "#90D0F0"
	taste_description = "szron"

/datum/chemical_reaction/aq_argine
	name = "Argina"
	id = /datum/reagent/aq_argine
	results = list(/datum/reagent/aq_argine = 3)
	required_reagents = list(/datum/reagent/potassium = 1, /datum/reagent/stable_plasma = 1, /datum/reagent/nitrogen = 1)
	required_temp = 400

/datum/chemical_reaction/reagent_explosion/aq_argine_explosion
	name = "Wybuch arginy"
	id = "aq_argine_explosion"
	required_reagents = list(/datum/reagent/aq_argine = 1)
	is_cold_recipe = TRUE
	required_temp = T0C - 1
	strengthdiv = 6

/// /vg/: „budzik szalonego chemika”, wybucha w żywym ciele o pełnej godzinie rundy
/datum/reagent/aq_punctualite
	name = "Punktualit"
	description = "Nazywany budzikiem szalonego chemika. W żywym ciele wybucha równo o pełnej godzinie rundy."
	reagent_state = LIQUID
	color = "#D4AF37"
	taste_description = "tykanie"
	metabolization_rate = 0.05 * REAGENTS_METABOLISM
	/// Godzina rundy, w której reagent trafił do ciała
	var/aq_hour

/// Pełne godziny od startu rundy
/proc/aq_round_hour()
	return round((world.time - SSticker.round_start_time) / (1 HOURS))

/datum/reagent/aq_punctualite/on_mob_life(mob/living/carbon/M)
	var/hour = aq_round_hour()
	if(isnull(aq_hour))
		aq_hour = hour
	else if(hour > aq_hour)
		var/amount = volume
		holder.del_reagent(type)
		M.visible_message("<span class='userdanger'>Coś w [M] głośno wybija pełną godzinę!</span>")
		aq_reagent_blast(M, amount / 10, "Punktualit")
		return
	if(prob(1) && M.can_hear())
		to_chat(M, "<span class='notice'>Słyszysz cichutkie tykanie.</span>")
	..()

/datum/chemical_reaction/aq_punctualite
	name = "Punktualit"
	id = /datum/reagent/aq_punctualite
	results = list(/datum/reagent/aq_punctualite = 10)
	required_reagents = list(/datum/reagent/medicine/ephedrine = 10, /datum/reagent/fuel = 10)
	required_catalysts = list(/datum/reagent/toxin/zombiepowder = 1)

#undef AQ_AMNESTIC_MINUTES_PER_UNIT
#undef AQ_PAIN_ENZYME_BASE
#undef AQ_PAIN_ENZYME_PER_UNIT
#undef AQ_PAIN_ENZYME_MAX
#undef AQ_PAIN_ENZYME_STRONG_PAINKILLER
#undef AQ_SDGF_MIN_DOSE
#undef AQ_SDGF_GROW_CYCLES
#undef AQ_SDGF_FULL_HEAL_UNITS
#undef AQ_PHOTOPHOSPHIDE_LUM
#undef AQ_HYPERPSY_MIN_UNITS
#undef AQ_HYPERPSY_MIN_CYCLES
