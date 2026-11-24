// AQUILA - cyberpsychoza (Citadel RP code/datums/components/cyberpsychosis.dm).
// Psychika ma pojemność 100. Każda proteza (10, zaawansowana 14, kołek i proteza kinetyczna 0), organ cybernetyczny (4)
// i implant cybernetyczny (aq_cyberpsychosis_cost, domyślnie 5) ją zmniejsza. Poniżej 80 pojawiają się objawy, tym częściej
// i gorsze, im mniej zostało: swędzenie i szepty, potem urywki wspomnień i fałszywe dźwięki, potem natrętne myśli i zakłócenia
// obrazu, a poniżej 20 napady (halucynacje, drżenie, upuszczanie rzeczy). W Citadelu pojemność liczy się raz przy pojawieniu,
// u nas na bieżąco, więc nowy implant od robotyka od razu ją zmniejsza. Lek: neuratreksat (receptura w tym pliku), wstrzymuje
// objawy, póki jest w krwi, i odsuwa następny o 5 minut. Syntetyków (pozytronowy mózg) to nie dotyczy.
// Teksty objawów są nasze, w duchu oryginału.

/mob/living/carbon/human
	/// AQUILA - kiedy najwcześniej następny objaw cyberpsychozy
	var/aq_cyberpsychosis_next = 0

/// Koszt organu dla cyberpsychozy: własny koszt narządu (cyberoko z laserem, mózg z łączem SI), inaczej domyślny
/obj/item/organ/proc/aq_get_cyberpsychosis_cost()
	if(aq_cyberpsychosis_cost)
		return aq_cyberpsychosis_cost
	if(organ_flags & ORGAN_SYNTHETIC)
		return 4
	return 0

/obj/item/organ/cyberimp/aq_get_cyberpsychosis_cost()
	return aq_cyberpsychosis_cost

// zwykły mózg (także pozytronowy) nie obciąża psychiki, mózg z łączem SI ma własny koszt
/obj/item/organ/brain/aq_get_cyberpsychosis_cost()
	return aq_cyberpsychosis_cost

/obj/item/bodypart/proc/aq_get_cyberpsychosis_cost()
	if(!isnull(aq_cyberpsychosis_cost))
		return aq_cyberpsychosis_cost
	if(IS_ORGANIC_LIMB(src) || is_pseudopart || !(bodytype & BODYTYPE_ROBOTIC))
		return 0
	return 10

/// Czy ta osoba może mieć cyberpsychozę (organiczny mózg)
/mob/living/carbon/human/proc/aq_can_have_cyberpsychosis()
	if(MOB_ROBOTIC in mob_biotypes)
		return FALSE
	var/obj/item/organ/brain/brain = getorganslot(ORGAN_SLOT_BRAIN)
	return brain && !(brain.organ_flags & ORGAN_SYNTHETIC)

/// Obciążenie psychiki cybernetyką (liczy też port serwisowy EMSI)
/mob/living/carbon/proc/aq_cyberpsychosis_load()
	. = 0
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		. += limb.aq_get_cyberpsychosis_cost()
	for(var/obj/item/organ/organ as anything in internal_organs)
		. += organ.aq_get_cyberpsychosis_cost()

/// Ile zostało pojemności psychiki (100 = zdrowa)
/mob/living/carbon/human/proc/aq_cyberpsychosis_capacity()
	if(!aq_can_have_cyberpsychosis())
		return 100
	return 100 - aq_cyberpsychosis_load()

/// Stopień cyberpsychozy: 0 brak, 1 lekka, 2 umiarkowana, 3 ciężka, 4 krytyczna
/mob/living/carbon/human/proc/aq_cyberpsychosis_stage()
	var/capacity = aq_cyberpsychosis_capacity()
	if(capacity < AQ_CYBERPSYCHOSIS_CRITICAL)
		return 4
	if(capacity < AQ_CYBERPSYCHOSIS_SEVERE)
		return 3
	if(capacity < AQ_CYBERPSYCHOSIS_MODERATE)
		return 2
	if(capacity < AQ_CYBERPSYCHOSIS_MILD)
		return 1
	return 0

/mob/living/carbon/human/proc/aq_cyberpsychosis_tick()
	if(world.time < aq_cyberpsychosis_next)
		return
	var/stage = aq_cyberpsychosis_stage()
	if(!stage)
		return
	if(reagents?.has_reagent(/datum/reagent/medicine/aq_neuratrextate))
		aq_cyberpsychosis_next = world.time + 5 MINUTES
		return
	aq_cyberpsychosis_symptom(stage)
	// lekka: co 5 minut, krytyczna: co minutę
	aq_cyberpsychosis_next = world.time + max(1 MINUTES, (6 - stage) * 1 MINUTES) + rand(0, 30 SECONDS)

/// Jeden objaw: losuje stopień nie wyższy niż obecny, więc lżejsze objawy zostają
/mob/living/carbon/human/proc/aq_cyberpsychosis_symptom(stage)
	var/tier = rand(1, stage)
	switch(tier)
		if(1)
			to_chat(src, "<span class='notice'>[pick(GLOB.aq_cyberpsychosis_mild)]</span>")
		if(2)
			if(prob(50))
				to_chat(src, "<span class='notice'>[pick(GLOB.aq_cyberpsychosis_memories)]</span>")
			else
				cause_hallucination(pick(/datum/hallucination/fake_sound/normal/airlock, /datum/hallucination/fake_sound/normal/glass, /datum/hallucination/fake_sound/normal/distant_boom, /datum/hallucination/fake_sound/normal/console), "cyberpsychoza")
		if(3)
			to_chat(src, "<span class='danger'>[pick(GLOB.aq_cyberpsychosis_intrusive)]</span>")
			cause_hallucination(/datum/hallucination/body/staticguy, "cyberpsychoza")
			SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "aq_cyberpsychosis", /datum/mood_event/aq_cyberpsychosis)
		if(4)
			to_chat(src, "<span class='userdanger'>[pick(GLOB.aq_cyberpsychosis_critical)]</span>")
			adjust_hallucinations(30 SECONDS)
			Jitter(20)
			SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "aq_cyberpsychosis", /datum/mood_event/aq_cyberpsychosis/severe)
			var/obj/item/held = get_active_held_item()
			if(held && prob(50) && dropItemToGround(held))
				to_chat(src, "<span class='danger'>Ręka sama się zaciska i wypuszczasz [held]!</span>")

GLOBAL_LIST_INIT(aq_cyberpsychosis_mild, list(
	"Skóra wokół implantów swędzi.",
	"Czujesz chwilowy ucisk za oczami.",
	"Język wydaje się za duży.",
	"Ktoś obok szepcze. Nikogo nie ma.",
	"Skórę głowy przeszywa krótkie kłucie.",
	"Na chwilę prawie przypominasz sobie zapach domu.",
))

GLOBAL_LIST_INIT(aq_cyberpsychosis_memories, list(
	"Czujesz zapach ulubionego jedzenia z dzieciństwa.",
	"Przez ułamek sekundy słyszysz letni gwar podwórka sprzed lat.",
	"Pamiętasz chłód pokoju, w którym kiedyś mieszkałeś.",
	"Ktoś znajomy woła cię po imieniu.",
	"Byłeś tu kiedyś. Na pewno. Prawda?",
	"Ściany na skraju wzroku jakby się burzyły.",
))

GLOBAL_LIST_INIT(aq_cyberpsychosis_intrusive, list(
	"Pamiętasz, jak wszyscy się na ciebie gapili.",
	"Ktoś cię obserwuje.",
	"Kim ty właściwie jesteś?",
	"Patrzysz na swoje dłonie. Czy to w ogóle twoje dłonie?",
	"Przed oczami trzeszczą przez chwilę cyfrowe artefakty.",
	"Podłoga rozmazuje się w neonowe linie i wraca na miejsce.",
))

GLOBAL_LIST_INIT(aq_cyberpsychosis_critical, list(
	"Powinieneś wyrwać sobie te implanty.",
	"Wiem, co zrobiłeś.",
	"Ochrona już po ciebie idzie.",
	"Nikomu nie ufaj. Wszyscy chcą twoich części.",
	"Zgrzyt cybernetyki nie ustaje. Topisz się w nim.",
))

/datum/mood_event/aq_cyberpsychosis
	description = "<span class='warning'>Coś jest nie tak z moją głową. To przez te implanty.</span>\n"
	mood_change = -3
	timeout = 5 MINUTES

/datum/mood_event/aq_cyberpsychosis/severe
	description = "<span class='boldwarning'>Moje ciało nie jest już moje.</span>\n"
	mood_change = -6

/datum/reagent/medicine/aq_neuratrextate
	name = "Neuratreksat"
	description = "Stabilizator łącza nerwowo-cybernetycznego. Wstrzymuje objawy cyberpsychozy, póki jest w krwi."
	reagent_state = LIQUID
	color = "#5f8fd6"
	taste_description = "metaliczna mięta"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30
	chem_flags = CHEMICAL_RNG_GENERAL

/datum/reagent/medicine/aq_neuratrextate/overdose_process(mob/living/M)
	M.drowsyness = max(M.drowsyness, 3)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.5 * REM)
	return ..()

/datum/chemical_reaction/aq_neuratrextate
	name = "Neuratreksat"
	id = /datum/reagent/medicine/aq_neuratrextate
	results = list(/datum/reagent/medicine/aq_neuratrextate = 3)
	required_reagents = list(/datum/reagent/medicine/mannitol = 1, /datum/reagent/medicine/haloperidol = 1, /datum/reagent/silicon = 1)

// --- Wspólny krok życia robotyki ---

/mob/living/carbon/human/Life()
	. = ..()
	if(QDELETED(src) || notransform || stat == DEAD)
		return
	aq_cyberpsychosis_tick()
