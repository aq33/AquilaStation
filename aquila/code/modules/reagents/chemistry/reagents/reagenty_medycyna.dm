// AQUILA - reagenty z przeglądu 246 kodów (raport/reagenty_02_plan_portu.md), grupa A: medycyna.
// Pomysły z Polaris (Osteodaksyn), tg (Sangwiryt), TGMC i Eris (Szybkie krzepnięcie), Baystation12 (Perydaksyna),
// MapleStation (Bupropion), Foundation-19 (Naltreksan), Eris (Aminazyna, Addyktol), Goonstation (sole trzeźwiące),
// SS14 (Ignizol), Fallout 13 (Toksyna hamująca metabolizm), /vg/ (Equalizon), Yogstation (Mikroplastik),
// Skyrat (Dermagen). Kod własny na naszych mechanikach, celowo słabszy niż w oryginałach:
// - Osteodaksyn nie zrasta kości sam, tylko przyspiesza zrost złamania opatrzonego żelem i taśmą (wounds/blunt.dm).
// - Perydaksyna leczy narządy tylko do progu lekkiego uszkodzenia (low_threshold), pełne zdrowie daje operacja albo czas.
// - Szybkie krzepnięcie wstrzymuje krwawienie (też wewnętrzne: pierce.dm, śledziona), ale ran nie leczy.
// - Leki na nałogi działają na nasze uzależnienia (reagents/addiction/addiction.dm).

#define AQ_QUICKCLOT_TRAIT "aq_quickclot_reagent"

// --- Kości ---

/datum/reagent/medicine/osteodaxon
	name = "Osteodaksyn"
	description = "Przyspiesza zrastanie złamań opatrzonych żelem kostnym i taśmą chirurgiczną. Sam kości nie zrasta, a zrost pod jego wpływem mocno boli."
	reagent_state = LIQUID
	color = "#C9BDA8"
	taste_description = "kreda"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30

/datum/reagent/medicine/osteodaxon/on_mob_life(mob/living/carbon/M)
	var/knitting = FALSE
	for(var/obj/item/bodypart/limb as anything in M.bodyparts)
		for(var/datum/wound/blunt/bone in limb.wounds)
			if(!bone.taped || !bone.regen_time)
				continue
			// Life co 2 s, a zrost dostaje 2 s na sekundę procesu: tyle samo drugi raz, czyli dwa razy szybciej
			bone.regen_progress += 2 SECONDS
			knitting = TRUE
	if(knitting)
		M.adjustStaminaLoss(2, 0)
		if(prob(10))
			to_chat(M, "<span class='danger'>Kości pulsują ci bólem, jakby ktoś je ściskał imadłem.</span>")
	..()
	return TRUE

/datum/reagent/medicine/osteodaxon/overdose_process(mob/living/M)
	M.adjustToxLoss(1, 0)
	M.adjustStaminaLoss(5, 0)
	..()
	return TRUE

/datum/chemical_reaction/osteodaxon
	name = "Osteodaksyn"
	id = /datum/reagent/medicine/osteodaxon
	results = list(/datum/reagent/medicine/osteodaxon = 3)
	required_reagents = list(/datum/reagent/medicine/bicaridine = 1, /datum/reagent/consumable/milk = 1, /datum/reagent/toxin/plasma = 1)

// --- Krzepnięcie ---

/datum/reagent/medicine/sanguirite
	name = "Sangwiryt"
	description = "Środek przyspieszający krzepnięcie. Krwawienie z ran powoli słabnie. Heparyna i sangwiryt znoszą się nawzajem."
	reagent_state = LIQUID
	color = "#B31F1F"
	taste_description = "żelazo"
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	overdose_threshold = 40

/datum/reagent/medicine/sanguirite/on_mob_metabolize(mob/living/L)
	. = ..()
	ADD_TRAIT(L, TRAIT_COAGULATING, type)

/datum/reagent/medicine/sanguirite/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_COAGULATING, type)
	return ..()

/datum/reagent/medicine/sanguirite/on_mob_life(mob/living/carbon/M)
	M.reagents.remove_reagent(/datum/reagent/toxin/heparin, 1)
	if(M.is_bleeding())
		M.cauterise_wounds(0.1)
	..()

/datum/reagent/medicine/sanguirite/overdose_process(mob/living/M)
	M.adjustToxLoss(0.5, 0)
	if(prob(5))
		to_chat(M, "<span class='warning'>Ręce i stopy drętwieją ci od gęstej krwi.</span>")
	..()
	return TRUE

/datum/reagent/toxin/heparin/on_mob_life(mob/living/carbon/M)
	M.reagents.remove_reagent(/datum/reagent/medicine/sanguirite, 1)
	return ..()

/datum/chemical_reaction/sanguirite
	name = "Sangwiryt"
	id = /datum/reagent/medicine/sanguirite
	results = list(/datum/reagent/medicine/sanguirite = 3)
	required_reagents = list(/datum/reagent/medicine/styptic_powder = 1, /datum/reagent/iron = 1, /datum/reagent/water = 1)

/datum/reagent/medicine/quickclot
	name = "Szybkie krzepnięcie"
	description = "Bojowy środek krzepnący. Póki działa, rany i krwotoki wewnętrzne nie tracą krwi, ale nic się nie goi: po jego zejściu krwawienie wraca. Przedawkowany robi zakrzepy."
	reagent_state = LIQUID
	color = "#7A0E0E"
	taste_description = "krew i guma"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 20

/datum/reagent/medicine/quickclot/on_mob_metabolize(mob/living/L)
	. = ..()
	ADD_TRAIT(L, TRAIT_AQ_QUICKCLOT, AQ_QUICKCLOT_TRAIT)
	ADD_TRAIT(L, TRAIT_COAGULATING, type)
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		if(C.is_bleeding())
			to_chat(C, "<span class='notice'>Krew w ranach gęstnieje i przestaje płynąć.</span>")

/datum/reagent/medicine/quickclot/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_AQ_QUICKCLOT, AQ_QUICKCLOT_TRAIT)
	REMOVE_TRAIT(L, TRAIT_COAGULATING, type)
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		if(C.is_bleeding())
			to_chat(C, "<span class='warning'>Skrzepy puszczają i rany znowu krwawią!</span>")
	return ..()

/datum/reagent/medicine/quickclot/on_mob_life(mob/living/carbon/M)
	M.reagents.remove_reagent(/datum/reagent/toxin/heparin, 2)
	..()

/datum/reagent/medicine/quickclot/overdose_process(mob/living/M)
	M.adjustToxLoss(1, 0)
	M.adjustOrganLoss(ORGAN_SLOT_HEART, 1)
	if(prob(10))
		to_chat(M, "<span class='danger'>Coś twardego przesuwa ci się w żyłach, a serce gubi rytm.</span>")
	..()
	return TRUE

/datum/chemical_reaction/quickclot
	name = "Szybkie krzepnięcie"
	id = /datum/reagent/medicine/quickclot
	results = list(/datum/reagent/medicine/quickclot = 2)
	required_reagents = list(/datum/reagent/medicine/sanguirite = 1, /datum/reagent/medicine/epinephrine = 1, /datum/reagent/silicon = 1)

/obj/item/reagent_containers/hypospray/medipen/quickclot
	name = "medipen szybkiego krzepnięcia"
	desc = "Autostrzykawka bojowa: na kilka minut wstrzymuje krwawienie. Ran nie leczy."
	icon_state = "atropen"
	volume = 10
	amount_per_transfer_from_this = 10
	list_reagents = list(/datum/reagent/medicine/quickclot = 10)

// --- Narządy ---

/datum/reagent/medicine/peridaxon
	name = "Perydaksyna"
	description = "Odbudowuje uszkodzone narządy wewnętrzne, także niewydolne, ale tylko do granicy lekkiego uszkodzenia. Dalej narząd goi się sam albo na stole. Przy uszkodzonym mózgu otępia."
	reagent_state = LIQUID
	color = "#561EC3"
	taste_description = "gorzka mięta"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 20
	// Działa też przy niewydolnej wątrobie (liver_toxins.dm metabolizuje wtedy tylko self_consuming), bo ją też ma leczyć
	self_consuming = TRUE

/datum/reagent/medicine/peridaxon/on_mob_life(mob/living/carbon/M)
	for(var/obj/item/organ/organ as anything in M.internal_organs)
		if(organ.organ_flags & ORGAN_SYNTHETIC)
			continue
		var/floor = organ.low_threshold
		if(organ.damage <= floor)
			continue
		organ.applyOrganDamage(-min(1.5, organ.damage - floor))
		if(organ.slot == ORGAN_SLOT_BRAIN)
			M.drowsyness = max(M.drowsyness, 3)
			M.confused = max(M.confused, 2)
	..()
	return TRUE

/datum/reagent/medicine/peridaxon/overdose_process(mob/living/M)
	M.adjustToxLoss(1.5, 0)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.5)
	..()
	return TRUE

/datum/chemical_reaction/peridaxon
	name = "Perydaksyna"
	id = /datum/reagent/medicine/peridaxon
	results = list(/datum/reagent/medicine/peridaxon = 2)
	required_reagents = list(/datum/reagent/medicine/bicaridine = 2, /datum/reagent/medicine/clonexadone = 2)
	required_catalysts = list(/datum/reagent/toxin/plasma = 5)

// --- Nałogi ---

/// Takes addiction points of these kinds off the mind
/datum/reagent/medicine/proc/aq_wean(mob/living/carbon/M, list/kinds, amount)
	if(!M.mind)
		return
	for(var/kind in kinds)
		if(LAZYACCESS(M.mind.aq_addiction_points, kind))
			M.mind.aq_remove_addiction_points(kind, amount)

/datum/reagent/medicine/bupropion
	name = "Bupropion"
	description = "Lek na rzucanie palenia i stymulantów: wypłukuje z organizmu głód nikotyny i stymulantów. Mdli."
	reagent_state = LIQUID
	color = "#E6E6B4"
	taste_description = "kwaśna kreda"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30

/datum/reagent/medicine/bupropion/on_mob_life(mob/living/carbon/M)
	aq_wean(M, list(/datum/addiction/nicotine, /datum/addiction/stimulants), 15)
	M.adjust_disgust(1)
	..()

/datum/reagent/medicine/bupropion/overdose_process(mob/living/M)
	M.Jitter(5)
	if(prob(5))
		M.emote("twitch")
	..()

/datum/chemical_reaction/bupropion
	name = "Bupropion"
	id = /datum/reagent/medicine/bupropion
	results = list(/datum/reagent/medicine/bupropion = 2)
	required_reagents = list(/datum/reagent/drug/nicotine = 1, /datum/reagent/acetone = 1, /datum/reagent/bromine = 1)

/datum/reagent/medicine/naltrexone
	name = "Naltreksan"
	description = "Lek na odwyk od alkoholu i opioidów: z każdą dawką nałóg słabnie. Obciąża wątrobę."
	reagent_state = LIQUID
	color = "#BFD9E8"
	taste_description = "metaliczna gorycz"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 25

/datum/reagent/medicine/naltrexone/on_mob_life(mob/living/carbon/M)
	aq_wean(M, list(/datum/addiction/alcohol, /datum/addiction/opioids), 15)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.2)
	..()
	return TRUE

/datum/reagent/medicine/naltrexone/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 1)
	M.adjustToxLoss(0.5, 0)
	..()
	return TRUE

/datum/chemical_reaction/naltrexone
	name = "Naltreksan"
	id = /datum/reagent/medicine/naltrexone
	results = list(/datum/reagent/medicine/naltrexone = 2)
	required_reagents = list(/datum/reagent/medicine/naloxone = 1, /datum/reagent/consumable/ethanol = 1, /datum/reagent/carbon = 1)

/datum/reagent/medicine/aminazine
	name = "Aminazyna"
	description = "Silny środek uspokajający. Nie leczy nałogu, ale póki działa, tłumi objawy odstawienia. Otępia."
	reagent_state = LIQUID
	color = "#F0F0D2"
	taste_description = "słodkawa gorycz"
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	overdose_threshold = 30

/datum/reagent/medicine/aminazine/on_mob_life(mob/living/carbon/M)
	for(var/kind in M.mind?.aq_active_addictions)
		var/datum/addiction/addiction = GLOB.aq_addictions[kind]
		if(M.mind.aq_active_addictions[kind] > 1)
			addiction.end_withdrawal(M)
	if(prob(10))
		M.drowsyness = max(M.drowsyness, 2)
	..()

/datum/reagent/medicine/aminazine/overdose_process(mob/living/M)
	M.drowsyness = max(M.drowsyness, 8)
	M.Dizzy(3)
	if(prob(10))
		M.Sleeping(4 SECONDS)
	..()

/datum/chemical_reaction/aminazine
	name = "Aminazyna"
	id = /datum/reagent/medicine/aminazine
	results = list(/datum/reagent/medicine/aminazine = 3)
	required_reagents = list(/datum/reagent/medicine/diphenhydramine = 1, /datum/reagent/chlorine = 1, /datum/reagent/sulfur = 1)

/datum/reagent/medicine/addictol
	name = "Addyktol"
	description = "Silny lek odwykowy: szybko wypłukuje wszystkie nałogi naraz, kosztem mdłości i zawrotów głowy."
	reagent_state = LIQUID
	color = "#5FB878"
	taste_description = "ziołowa gorycz"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 20

/datum/reagent/medicine/addictol/on_mob_life(mob/living/carbon/M)
	aq_wean(M, GLOB.aq_addictions, 25)
	M.adjust_disgust(2)
	if(prob(10))
		M.Dizzy(3)
	..()

/datum/reagent/medicine/addictol/overdose_process(mob/living/M)
	M.adjustToxLoss(1, 0)
	M.adjust_disgust(5)
	..()
	return TRUE

/datum/chemical_reaction/addictol
	name = "Addyktol"
	id = /datum/reagent/medicine/addictol
	results = list(/datum/reagent/medicine/addictol = 2)
	required_reagents = list(/datum/reagent/medicine/bupropion = 1, /datum/reagent/medicine/naltrexone = 1, /datum/reagent/medicine/aminazine = 1)
	required_temp = 400

// --- Cucenie i ciepło ---

/datum/reagent/medicine/ammonium_bicarbonate
	name = "Sole trzeźwiące"
	description = "Wodorowęglan amonu. Ostry zapach wybudza ze snu i omdlenia, rozwiewa senność i otępienie. Nie leczy ran i nie stawia na nogi ciężko rannych."
	reagent_state = SOLID
	color = "#F5F5F5"
	taste_description = "amoniak"
	metabolization_rate = REAGENTS_METABOLISM

/// The sharp smell: wakes from sleep and fainting, unless the body is too broken to wake (crit)
/datum/reagent/medicine/ammonium_bicarbonate/proc/aq_wake(mob/living/M)
	if(M.stat == DEAD || M.health <= HEALTH_THRESHOLD_CRIT)
		return
	M.drowsyness = 0
	M.confused = max(0, M.confused - 5)
	if(M.IsSleeping() || M.IsUnconscious())
		M.SetSleeping(0)
		M.SetUnconscious(0)
		M.visible_message("<span class='notice'>[M] krztusi się i gwałtownie otwiera oczy.</span>", "<span class='warning'>Ostry smród amoniaku wyrywa cię ze snu!</span>")
	if(prob(30))
		M.emote("cough")

/datum/reagent/medicine/ammonium_bicarbonate/reaction_mob(mob/living/M, method = TOUCH, reac_volume, show_message = 1, touch_protection = 0, obj/item/bodypart/affecting)
	. = ..()
	if(method == VAPOR || method == TOUCH)
		aq_wake(M)

/datum/reagent/medicine/ammonium_bicarbonate/on_mob_life(mob/living/carbon/M)
	aq_wake(M)
	..()

/datum/chemical_reaction/ammonium_bicarbonate
	name = "Sole trzeźwiące"
	id = /datum/reagent/medicine/ammonium_bicarbonate
	results = list(/datum/reagent/medicine/ammonium_bicarbonate = 3)
	required_reagents = list(/datum/reagent/ammonia = 1, /datum/reagent/carbondioxide = 1, /datum/reagent/sodium = 1)

/datum/reagent/medicine/ignisol
	name = "Ignizol"
	description = "Szybko rozgrzewa ciało: leczy wychłodzenie i cofa odmrożenia. Bardzo łatwopalny. Przedawkowany przegrzewa."
	reagent_state = LIQUID
	color = "#FF7A1C"
	taste_description = "palący pieprz"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 30

/datum/reagent/medicine/ignisol/on_mob_life(mob/living/carbon/M)
	if(M.bodytemperature < BODYTEMP_NORMAL)
		M.adjust_bodytemperature(min(15, BODYTEMP_NORMAL - M.bodytemperature))
	for(var/obj/item/bodypart/limb as anything in M.bodyparts)
		if(limb.aq_frost)
			limb.aq_frost = max(0, limb.aq_frost - 5)
	..()

/datum/reagent/medicine/ignisol/reaction_mob(mob/living/M, method = TOUCH, reac_volume, show_message = 1, touch_protection = 0, obj/item/bodypart/affecting)
	. = ..()
	if(method == TOUCH || method == VAPOR)
		M.adjust_fire_stacks(reac_volume / 10)

/datum/reagent/medicine/ignisol/overdose_process(mob/living/M)
	M.adjust_bodytemperature(10)
	if(prob(10))
		to_chat(M, "<span class='danger'>Pali cię od środka!</span>")
	..()

/datum/chemical_reaction/ignisol
	name = "Ignizol"
	id = /datum/reagent/medicine/ignisol
	results = list(/datum/reagent/medicine/ignisol = 2)
	required_reagents = list(/datum/reagent/fuel = 1, /datum/reagent/medicine/leporazine = 1, /datum/reagent/phosphorus = 1)

// --- Trucizny na leki i nietypowe leki ---

/datum/reagent/toxin/metabolism_inhibitor
	name = "Toksyna hamująca metabolizm"
	description = "Niszczy wątrobę i nerki. Póki jest w krwi, leki rozkładają się bez pożytku i działają słabiej."
	reagent_state = LIQUID
	color = "#6B5B3A"
	taste_description = "stęchlizna"
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	toxpwr = 0.5

/datum/reagent/toxin/metabolism_inhibitor/on_mob_life(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.5)
	M.adjustOrganLoss(ORGAN_SLOT_KIDNEYS, 0.5)
	for(var/datum/reagent/medicine/med in M.reagents.reagent_list)
		M.reagents.remove_reagent(med.type, 0.4)
	return ..()

/datum/chemical_reaction/metabolism_inhibitor
	name = "Toksyna hamująca metabolizm"
	id = /datum/reagent/toxin/metabolism_inhibitor
	results = list(/datum/reagent/toxin/metabolism_inhibitor = 2)
	required_reagents = list(/datum/reagent/mercury = 1, /datum/reagent/toxin = 1, /datum/reagent/lithium = 1)

/datum/reagent/medicine/equalizone
	name = "Equalizon"
	description = "Rozkłada obrażenia po całym ciele: siniaki, oparzenia, zatrucie i niedotlenienie wyrównują się do średniej. Sam niczego nie leczy."
	reagent_state = LIQUID
	color = "#9DD8E0"
	taste_description = "nic"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/medicine/equalizone/on_mob_life(mob/living/carbon/M)
	// Odporny na toksyny nie może dostać zatrucia, więc jego toksyny nie biorą udziału w wyrównaniu (suma zostaje ta sama)
	var/use_tox = !HAS_TRAIT(M, TRAIT_TOXIMMUNE)
	var/list/losses = list(M.getBruteLoss(), M.getFireLoss(), use_tox ? M.getToxLoss() : 0, M.getOxyLoss())
	var/kinds = use_tox ? 4 : 3
	var/average = (losses[1] + losses[2] + losses[3] + losses[4]) / kinds
	// Po trochu (najwyżej 2 z każdego typu ponad średnią), a zabrane rozdziela na typy poniżej średniej
	var/taken = 0
	var/deficit = 0
	for(var/i in 1 to 4)
		if(i == 3 && !use_tox)
			continue
		if(losses[i] > average)
			taken += min(2, losses[i] - average)
		else
			deficit += average - losses[i]
	if(taken <= 0 || deficit <= 0)
		return ..()
	var/list/deltas = list(0, 0, 0, 0)
	for(var/i in 1 to 4)
		if(i == 3 && !use_tox)
			continue
		deltas[i] = losses[i] > average ? -min(2, losses[i] - average) : taken * (average - losses[i]) / deficit
	M.adjustBruteLoss(deltas[1], 0)
	M.adjustFireLoss(deltas[2], 0)
	if(use_tox)
		M.adjustToxLoss(deltas[3], 0)
	M.adjustOxyLoss(deltas[4], 0)
	..()
	return TRUE

/datum/chemical_reaction/equalizone
	name = "Equalizon"
	id = /datum/reagent/medicine/equalizone
	results = list(/datum/reagent/medicine/equalizone = 2)
	required_reagents = list(/datum/reagent/medicine/tricordrazine = 1, /datum/reagent/cryptobiolin = 1, /datum/reagent/silver = 1)

/datum/reagent/toxin/microplastics
	name = "Mikroplastik"
	description = "Drobiny plastiku, których organizm prawie nie wydala. Latami siedzą w narządach i po trochu je niszczą. Wypłukują je tylko węgiel aktywny i kalomel."
	reagent_state = SOLID
	color = "#E8E8E8"
	taste_description = "nic"
	metabolization_rate = 0.01 * REAGENTS_METABOLISM
	toxpwr = 0

/datum/reagent/toxin/microplastics/on_mob_life(mob/living/carbon/M)
	if(prob(20) && length(M.internal_organs))
		var/obj/item/organ/organ = pick(M.internal_organs)
		if(!(organ.organ_flags & ORGAN_SYNTHETIC))
			organ.applyOrganDamage(0.5)
	return ..()

/datum/chemical_reaction/microplastics
	name = "Mikroplastik"
	id = /datum/reagent/toxin/microplastics
	results = list(/datum/reagent/toxin/microplastics = 2)
	required_reagents = list(/datum/reagent/plastic_polymers = 1, /datum/reagent/space_cleaner = 1)

/datum/reagent/medicine/dermagen
	name = "Dermagen"
	description = "Maść regenerująca skórę. Nałożona na ciało wygładza blizny. Wypita nic nie daje."
	reagent_state = LIQUID
	color = "#F2C9B5"
	taste_description = "wosk"

/datum/reagent/medicine/dermagen/reaction_mob(mob/living/M, method = TOUCH, reac_volume, show_message = 1, touch_protection = 0, obj/item/bodypart/affecting)
	. = ..()
	if(!(method == TOUCH || method == PATCH) || !iscarbon(M) || reac_volume < 5)
		return
	var/mob/living/carbon/C = M
	var/removed = 0
	for(var/obj/item/bodypart/limb as anything in C.bodyparts)
		if(!LAZYLEN(limb.scars))
			continue
		var/to_remove = min(length(limb.scars), round(reac_volume / 5) - removed)
		if(to_remove <= 0)
			break
		limb.scars.Cut(1, to_remove + 1)
		UNSETEMPTY(limb.scars)
		removed += to_remove
	if(removed && show_message)
		to_chat(C, "<span class='notice'>Skóra mrowi i wygładza się, blizny bledną.</span>")

/datum/chemical_reaction/dermagen
	name = "Dermagen"
	id = /datum/reagent/medicine/dermagen
	results = list(/datum/reagent/medicine/dermagen = 2)
	required_reagents = list(/datum/reagent/medicine/synthflesh = 1, /datum/reagent/medicine/silver_sulfadiazine = 1)
