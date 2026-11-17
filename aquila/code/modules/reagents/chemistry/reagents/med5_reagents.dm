// AQUILA - leki AquilaMed 5 z Baystation12 (code/modules/reagents/chemistry/reagents/medicine.dm, Chemistry-Recipes.dm).
// Przeciwbólowe: paracetamol, tramadol, oksykodon. Siłę przeciwbólową mają w GLOB.aq_painkillers (pain/pain.dm).
// Na nastrój: citalopram, paroksetyna, metylofenidat (antydepresanty Bay, u nas przez moodlety Bee).
// Receptury jak w Bay, inaprowalinę zastępuje nasza epinefryna. Progi uzależnień są w
// addiction_types (reagents/addiction/addiction.dm, uzależnienia z tg).

// --- Przeciwbólowe ---

/datum/reagent/medicine/paracetamol
	name = "Paracetamol"
	description = "Słaby lek przeciwbólowy. Nie uzależnia i nie otępia, ale przedawkowanie niszczy wątrobę."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "gorycz"
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	overdose_threshold = 50

/datum/reagent/medicine/paracetamol/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 1)
	M.adjustToxLoss(0.5, 0)
	if(prob(5))
		to_chat(M, "<span class='warning'>Coś kłuje cię pod prawym żebrem.</span>")
	..()
	return TRUE

/datum/reagent/medicine/tramadol
	name = "Tramadol"
	description = "Opioid przeciwbólowy średniej siły. Lekko otępia, a brany regularnie uzależnia. Przedawkowanie spłyca oddech."
	reagent_state = LIQUID
	color = "#CB68FC"
	taste_description = "kwaśność"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 30

/datum/reagent/medicine/tramadol/on_mob_life(mob/living/carbon/M)
	if(current_cycle > 20 && prob(5))
		M.drowsyness = max(M.drowsyness, 2)
	..()

/datum/reagent/medicine/tramadol/overdose_process(mob/living/M)
	M.Dizzy(3)
	M.drowsyness = max(M.drowsyness, 5)
	if(prob(10))
		M.losebreath++
		to_chat(M, "<span class='warning'>Oddech robi ci się płytki i leniwy.</span>")
	..()

/datum/reagent/medicine/oxycodone
	name = "Oksykodon"
	description = "Silny opioid przeciwbólowy. Mocno otępia i szybko uzależnia. Przedawkowanie zatrzymuje oddech."
	reagent_state = LIQUID
	color = "#800080"
	taste_description = "gorzka mgła"
	metabolization_rate = 0.3 * REAGENTS_METABOLISM
	overdose_threshold = 20

/datum/reagent/medicine/oxycodone/on_mob_life(mob/living/carbon/M)
	M.drowsyness = max(M.drowsyness, 1)
	if(prob(5))
		M.Dizzy(2)
	..()

/datum/reagent/medicine/oxycodone/overdose_process(mob/living/M)
	M.drowsyness = max(M.drowsyness, 10)
	M.losebreath++
	M.adjustOxyLoss(1, 0)
	if(prob(10))
		M.Sleeping(4 SECONDS)
	..()
	return TRUE

/datum/chemical_reaction/tramadol
	name = "Tramadol"
	id = /datum/reagent/medicine/tramadol
	results = list(/datum/reagent/medicine/tramadol = 3)
	required_reagents = list(/datum/reagent/medicine/epinephrine = 1, /datum/reagent/consumable/ethanol = 1, /datum/reagent/acetone = 1)

/datum/chemical_reaction/paracetamol
	name = "Paracetamol"
	id = /datum/reagent/medicine/paracetamol
	results = list(/datum/reagent/medicine/paracetamol = 3)
	required_reagents = list(/datum/reagent/medicine/tramadol = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/water = 1)

/datum/chemical_reaction/oxycodone
	name = "Oksykodon"
	id = /datum/reagent/medicine/oxycodone
	results = list(/datum/reagent/medicine/oxycodone = 1)
	required_reagents = list(/datum/reagent/consumable/ethanol = 1, /datum/reagent/medicine/tramadol = 1)
	required_catalysts = list(/datum/reagent/toxin/plasma = 5)

// --- Na nastrój ---

/datum/reagent/medicine/citalopram
	name = "Citalopram"
	description = "Łagodny antydepresant. Działa długo i powoli poprawia nastrój. Nie uzależnia."
	reagent_state = LIQUID
	color = "#FF80FF"
	taste_description = "kreda"
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	overdose_threshold = 40

/datum/reagent/medicine/citalopram/on_mob_life(mob/living/carbon/M)
	if(current_cycle >= 5)
		SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "aq_antidepressant", /datum/mood_event/aq_citalopram)
	..()

/datum/reagent/medicine/citalopram/overdose_process(mob/living/M)
	M.Jitter(3)
	if(prob(5) && iscarbon(M))
		var/mob/living/carbon/C = M
		C.vomit(10)
	..()

/datum/reagent/medicine/paroxetine
	name = "Paroksetyna"
	description = "Silny antydepresant. Mocno poprawia nastrój, ale czasem daje halucynacje."
	reagent_state = LIQUID
	color = "#FF80BF"
	taste_description = "gorycz"
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	overdose_threshold = 30

/datum/reagent/medicine/paroxetine/on_mob_life(mob/living/carbon/M)
	if(current_cycle >= 5)
		SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "aq_antidepressant", /datum/mood_event/aq_paroxetine)
	if(prob(3))
		M.adjust_hallucinations(10 SECONDS)
	..()

/datum/reagent/medicine/paroxetine/overdose_process(mob/living/M)
	M.adjust_hallucinations(5 SECONDS)
	M.Jitter(4)
	..()

/datum/reagent/medicine/methylphenidate
	name = "Metylofenidat"
	description = "Stymulant poprawiający skupienie: uspokaja drżenie, rozjaśnia myśli i zawroty głowy. Brany regularnie uzależnia, przedawkowanie obciąża serce."
	reagent_state = LIQUID
	color = "#BF80BF"
	taste_description = "miętowa gorycz"
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	overdose_threshold = 30

/datum/reagent/medicine/methylphenidate/on_mob_life(mob/living/carbon/M)
	M.jitteriness = max(0, M.jitteriness - 5)
	M.confused = max(0, M.confused - 2)
	M.dizziness = max(0, M.dizziness - 2)
	if(current_cycle >= 5)
		SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "aq_methylphenidate", /datum/mood_event/aq_methylphenidate)
	..()

/datum/reagent/medicine/methylphenidate/on_mob_end_metabolize(mob/living/L)
	SEND_SIGNAL(L, COMSIG_CLEAR_MOOD_EVENT, "aq_methylphenidate")
	..()

/datum/reagent/medicine/methylphenidate/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_HEART, 0.5)
	M.Jitter(5)
	if(prob(5))
		to_chat(M, "<span class='warning'>Serce wali ci jak oszalałe.</span>")
	..()
	return TRUE

/datum/mood_event/aq_citalopram
	description = "<span class='nicegreen'>Jest mi spokojniej niż zwykle.</span>\n"
	mood_change = 4
	timeout = 5 MINUTES

/datum/mood_event/aq_paroxetine
	description = "<span class='nicegreen'>Wszystko wydaje się jakieś lżejsze.</span>\n"
	mood_change = 7
	timeout = 5 MINUTES

/datum/mood_event/aq_methylphenidate
	description = "<span class='nicegreen'>Myśli są jasne i poukładane.</span>\n"
	mood_change = 2

/datum/chemical_reaction/citalopram
	name = "Citalopram"
	id = /datum/reagent/medicine/citalopram
	results = list(/datum/reagent/medicine/citalopram = 2)
	required_reagents = list(/datum/reagent/toxin/mindbreaker = 1, /datum/reagent/carbon = 1)

/datum/chemical_reaction/paroxetine
	name = "Paroksetyna"
	id = /datum/reagent/medicine/paroxetine
	results = list(/datum/reagent/medicine/paroxetine = 3)
	required_reagents = list(/datum/reagent/toxin/mindbreaker = 1, /datum/reagent/oxygen = 1, /datum/reagent/medicine/epinephrine = 1)

/datum/chemical_reaction/methylphenidate
	name = "Metylofenidat"
	id = /datum/reagent/medicine/methylphenidate
	results = list(/datum/reagent/medicine/methylphenidate = 2)
	required_reagents = list(/datum/reagent/toxin/mindbreaker = 1, /datum/reagent/lithium = 1)

// --- Pigułki, fiolki, butelki ---

/obj/item/reagent_containers/pill/paracetamol
	name = "pigułka: paracetamol"
	desc = "Słaby lek przeciwbólowy."
	icon_state = "pill_shape_tablet_white_lined"
	list_reagents = list(/datum/reagent/medicine/paracetamol = 15)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/tramadol
	name = "pigułka: tramadol"
	desc = "Opioid przeciwbólowy średniej siły. Uzależnia."
	icon_state = "pill_shape_capsule_purple_pink"
	list_reagents = list(/datum/reagent/medicine/tramadol = 10)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/oxycodone
	name = "pigułka: oksykodon"
	desc = "Silny opioid przeciwbólowy. Szybko uzależnia."
	icon_state = "pill_shape_capsule_indigo"
	list_reagents = list(/datum/reagent/medicine/oxycodone = 10)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/citalopram
	name = "pigułka: citalopram"
	desc = "Łagodny antydepresant."
	icon_state = "pill_shape_tablet_pink_lined"
	list_reagents = list(/datum/reagent/medicine/citalopram = 10)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/paroxetine
	name = "pigułka: paroksetyna"
	desc = "Silny antydepresant. Czasem daje halucynacje."
	icon_state = "pill_shape_tablet_purple_lined"
	list_reagents = list(/datum/reagent/medicine/paroxetine = 10)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/methylphenidate
	name = "pigułka: metylofenidat"
	desc = "Poprawia skupienie. Uzależnia."
	icon_state = "pill_shape_tablet_skyblue_lined"
	list_reagents = list(/datum/reagent/medicine/methylphenidate = 10)
	rename_with_volume = TRUE

/obj/item/reagent_containers/pill/pax
	name = "pigułka: pax"
	desc = "Uspokaja tak, że nie da się nikogo skrzywdzić."
	icon_state = "pill_shape_tablet_lightgreen_flat"
	list_reagents = list(/datum/reagent/pax = 10)
	rename_with_volume = TRUE

/obj/item/storage/pill_bottle/paracetamol
	name = "pojemnik z pigułkami: Paracetamol"
	desc = "Zawiera pigułki na słabszy ból."

/obj/item/storage/pill_bottle/paracetamol/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/paracetamol(src)

/obj/item/storage/pill_bottle/tramadol
	name = "pojemnik z pigułkami: Tramadol"
	desc = "Zawiera opioid na średni ból. Uzależnia."

/obj/item/storage/pill_bottle/tramadol/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/tramadol(src)

/obj/item/storage/pill_bottle/oxycodone
	name = "pojemnik z pigułkami: Oksykodon"
	desc = "Zawiera silny opioid na ciężki ból. Szybko uzależnia, wydawać ostrożnie."

/obj/item/storage/pill_bottle/oxycodone/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/oxycodone(src)

/obj/item/storage/pill_bottle/citalopram
	name = "pojemnik z pigułkami: Citalopram"
	desc = "Zawiera łagodny antydepresant."

/obj/item/storage/pill_bottle/citalopram/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/citalopram(src)

/obj/item/storage/pill_bottle/paroxetine
	name = "pojemnik z pigułkami: Paroksetyna"
	desc = "Zawiera silny antydepresant."

/obj/item/storage/pill_bottle/paroxetine/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/paroxetine(src)

/obj/item/storage/pill_bottle/methylphenidate
	name = "pojemnik z pigułkami: Metylofenidat"
	desc = "Zawiera lek na skupienie. Uzależnia."

/obj/item/storage/pill_bottle/methylphenidate/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/methylphenidate(src)

/obj/item/storage/pill_bottle/pax
	name = "pojemnik z pigułkami: Pax"
	desc = "Zawiera pigułki uspokajające. Do użytku w gabinecie, nie do dosypywania komuś do kawy."

/obj/item/storage/pill_bottle/pax/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/pax(src)

/obj/item/reagent_containers/glass/bottle/oxycodone
	name = "butelka oksykodonu"
	desc = "Mała butelka silnego opioidu."
	list_reagents = list(/datum/reagent/medicine/oxycodone = 30)

/obj/item/reagent_containers/glass/bottle/tramadol
	name = "butelka tramadolu"
	desc = "Mała butelka opioidu średniej siły."
	list_reagents = list(/datum/reagent/medicine/tramadol = 30)
