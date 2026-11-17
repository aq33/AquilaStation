// AQUILA - narządy aberracyjne (AquilaMed 5, etap 12). Uproszczony port z CEV-Eris (code/modules/aberrants/), sprite'y
// organoidów, przetwornika biomasy (disgorger) i drukarki narządów z Eris (CC BY-SA 3.0).
// - Rusztowanie ma trzy gniazda: organoid wejścia (na co reaguje), przetwarzania (jak często i jak mocno) i wyjścia
//   (co robi). Kompletne rusztowanie wszczepia się w klatkę piersiową, w jedno z trzech dodatkowych miejsc.
// - Organoidy wycina się nożem z teratom (łup z wraków i misji, zwłoki potworów z asteroid) albo drukuje w drukarce
//   narządów z biomasy, którą robi przetwornik biomasy z narządów, mięsa i teratom.
// Różnice od Eris: dwa rodzaje wejścia (reagent we krwi, obrażenia), trzy przetwarzania, dwa wyjścia (reagent do krwi,
// leczenie); bez wydajności, rozmiaru narządów i bez organoidów pożerających przedmioty, prąd, jaja i dym.

#define AQ_ABERRANT_SLOTS list("aq_aberrant_1", "aq_aberrant_2", "aq_aberrant_3")
#define AQ_ORGANOID_INPUT "wejście"
#define AQ_ORGANOID_PROCESS "przetwarzanie"
#define AQ_ORGANOID_OUTPUT "wyjście"

/// Reagents an input organoid can feed on
GLOBAL_LIST_INIT(aq_organoid_input_reagents, list(/datum/reagent/water, /datum/reagent/consumable/sugar, /datum/reagent/consumable/ethanol, /datum/reagent/consumable/nutriment, /datum/reagent/iron, /datum/reagent/carbon))
/// Reagents an output organoid can secrete
GLOBAL_LIST_INIT(aq_organoid_output_reagents, list(/datum/reagent/medicine/epinephrine, /datum/reagent/medicine/spaceacillin, /datum/reagent/medicine/morphine, /datum/reagent/medicine/bicaridine, /datum/reagent/medicine/kelotane, /datum/reagent/medicine/charcoal, /datum/reagent/medicine/salbutamol, /datum/reagent/medicine/inaprovaline, /datum/reagent/drug/space_drugs))

// --- Organoidy ---

/obj/item/aq_organoid
	name = "organoid"
	icon = 'aquila/icons/obj/medical/organ_mods_eris.dmi'
	w_class = WEIGHT_CLASS_TINY
	/// Socket in the scaffold
	var/kind

/obj/item/aq_organoid/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Gniazdo rusztowania: [kind]. [effect_text()]</span>"

/// What it does, for examine
/obj/item/aq_organoid/proc/effect_text()
	return ""

/obj/item/aq_organoid/input
	kind = AQ_ORGANOID_INPUT

/// Did the trigger happen this Life; uses up what it feeds on
/obj/item/aq_organoid/input/proc/triggered(mob/living/carbon/owner)
	return FALSE

/obj/item/aq_organoid/input/reagent
	name = "organoid metaboliczny"
	desc = "Tkanka czynnościowa, która reaguje na reagent we krwi i go zużywa."
	var/datum/reagent/trigger_reagent

/obj/item/aq_organoid/input/reagent/Initialize(mapload)
	. = ..()
	icon_state = "input_organoid-[rand(1, 5)]"
	trigger_reagent ||= pick(GLOB.aq_organoid_input_reagents)

/obj/item/aq_organoid/input/reagent/effect_text()
	return "Działa, gdy we krwi jest [initial(trigger_reagent.name)] (zużywa 1 j.)."

/obj/item/aq_organoid/input/reagent/triggered(mob/living/carbon/owner)
	if(!owner.reagents?.has_reagent(trigger_reagent, 1))
		return FALSE
	owner.reagents.remove_reagent(trigger_reagent, 1)
	return TRUE

/obj/item/aq_organoid/input/damage
	name = "organoid nocyceptywny"
	desc = "Tkanka czynnościowa, która reaguje na obrażenia ciała."
	var/damage_type

/obj/item/aq_organoid/input/damage/Initialize(mapload)
	. = ..()
	icon_state = "input_organoid-[rand(1, 5)]"
	damage_type ||= pick(BRUTE, BURN, TOX, OXY)

/obj/item/aq_organoid/input/damage/effect_text()
	return "Działa, gdy ciało ma ponad 20 obrażeń: [list(BRUTE = "fizycznych", BURN = "od oparzeń", TOX = "od toksyn", OXY = "z niedotlenienia")[damage_type]]."

/obj/item/aq_organoid/input/damage/triggered(mob/living/carbon/owner)
	switch(damage_type)
		if(BRUTE)
			return owner.getBruteLoss() > 20
		if(BURN)
			return owner.getFireLoss() > 20
		if(TOX)
			return owner.getToxLoss() > 20
		if(OXY)
			return owner.getOxyLoss() > 20

/obj/item/aq_organoid/process
	kind = AQ_ORGANOID_PROCESS
	icon_state = "process_organoid-1"
	var/cooldown = 30 SECONDS
	var/magnitude = 1

/obj/item/aq_organoid/process/effect_text()
	return "Działa co [DisplayTimeText(cooldown)], siła [round(magnitude * 100)]%."

/obj/item/aq_organoid/process/tubular
	name = "organoid kanalikowy"
	desc = "Tkanka czynnościowa, która łączy wejście z wyjściem."

/obj/item/aq_organoid/process/circadian
	name = "organoid okołodobowy"
	desc = "Tkanka czynnościowa, która przyspiesza rytm narządu, ale osłabia każde działanie."
	icon_state = "process_organoid-2"
	cooldown = 15 SECONDS
	magnitude = 0.6

/obj/item/aq_organoid/process/enzymal
	name = "organoid enzymatyczny"
	desc = "Tkanka czynnościowa, która wzmacnia każde działanie narządu, ale spowalnia jego rytm."
	icon_state = "process_organoid-3"
	cooldown = 60 SECONDS
	magnitude = 2

/obj/item/aq_organoid/output
	kind = AQ_ORGANOID_OUTPUT

/obj/item/aq_organoid/output/proc/act(mob/living/carbon/owner, magnitude)
	return

/obj/item/aq_organoid/output/reagent
	name = "organoid wątrobowy"
	desc = "Tkanka czynnościowa, która wydziela reagent do krwi."
	var/datum/reagent/made_reagent

/obj/item/aq_organoid/output/reagent/Initialize(mapload)
	. = ..()
	icon_state = "output_organoid-[rand(1, 5)]"
	made_reagent ||= pick(GLOB.aq_organoid_output_reagents)

/obj/item/aq_organoid/output/reagent/effect_text()
	return "Wydziela do krwi 3 j. reagentu [initial(made_reagent.name)]."

/obj/item/aq_organoid/output/reagent/act(mob/living/carbon/owner, magnitude)
	owner.reagents?.add_reagent(made_reagent, 3 * magnitude)

/obj/item/aq_organoid/output/heal
	name = "organoid endokrynny"
	desc = "Tkanka czynnościowa, która wydziela hormony gojące rany."
	icon_state = "output_organoid-3"

/obj/item/aq_organoid/output/heal/effect_text()
	return "Leczy 4 obrażenia fizyczne i 4 od oparzeń."

/obj/item/aq_organoid/output/heal/act(mob/living/carbon/owner, magnitude)
	owner.heal_overall_damage(4 * magnitude, 4 * magnitude)

// --- Rusztowanie ---

/obj/item/organ/aq_aberrant
	name = "puste rusztowanie narządu"
	desc = "Rusztowanie z biopolimeru z trzema gniazdami na organoidy: wejścia, przetwarzania i wyjścia. Włóż organoid, a gotowy narząd wszczep w klatkę piersiową."
	icon = 'aquila/icons/obj/medical/organ_mods_eris.dmi'
	icon_state = "membrane-1"
	zone = BODY_ZONE_CHEST
	slot = "aq_aberrant_1"
	var/obj/item/aq_organoid/input/input
	var/obj/item/aq_organoid/process/processor
	var/obj/item/aq_organoid/output/output
	var/next_act = 0

/obj/item/organ/aq_aberrant/Destroy()
	QDEL_NULL(input)
	QDEL_NULL(processor)
	QDEL_NULL(output)
	return ..()

/obj/item/organ/aq_aberrant/proc/is_complete()
	return input && processor && output

/obj/item/organ/aq_aberrant/proc/aq_update_scaffold_name()
	if(is_complete())
		name = "narząd aberracyjny"
		icon_state = "membrane-[rand(2, 5)]"
	else
		name = initial(name)

/obj/item/organ/aq_aberrant/examine(mob/user)
	. = ..()
	for(var/obj/item/aq_organoid/organoid in list(input, processor, output))
		. += "<span class='notice'>[organoid.kind]: [organoid.name]. [organoid.effect_text()]</span>"
	if(!is_complete())
		. += "<span class='warning'>Brakuje organoidów, w ciele nic nie zrobi.</span>"

/obj/item/organ/aq_aberrant/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/aq_organoid))
		return ..()
	if(owner)
		to_chat(user, "<span class='warning'>Najpierw wyjmij [src] z ciała.</span>")
		return TRUE
	var/obj/item/aq_organoid/organoid = I
	var/obj/item/aq_organoid/current = organoid.kind == AQ_ORGANOID_INPUT ? input : (organoid.kind == AQ_ORGANOID_PROCESS ? processor : output)
	if(current)
		to_chat(user, "<span class='warning'>Gniazdo ([organoid.kind]) jest zajęte.</span>")
		return TRUE
	if(!user.transferItemToLoc(organoid, src))
		return TRUE
	switch(organoid.kind)
		if(AQ_ORGANOID_INPUT)
			input = organoid
		if(AQ_ORGANOID_PROCESS)
			processor = organoid
		if(AQ_ORGANOID_OUTPUT)
			output = organoid
	aq_update_scaffold_name()
	to_chat(user, "<span class='notice'>Wszczepiasz [organoid] w gniazdo ([organoid.kind]).</span>")
	return TRUE

/// The first free extra slot in the chest
/obj/item/organ/aq_aberrant/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	for(var/free_slot in AQ_ABERRANT_SLOTS)
		if(!M.getorganslot(free_slot))
			slot = free_slot
			break
	return ..()

/obj/item/organ/aq_aberrant/on_life()
	. = ..()
	if(!owner || owner.stat == DEAD || !is_complete() || (organ_flags & ORGAN_FAILING) || world.time < next_act)
		return
	if(!input.triggered(owner))
		return
	next_act = world.time + processor.cooldown
	output.act(owner, processor.magnitude)

// --- Teratoma ---

/obj/item/aq_teratoma
	name = "teratoma"
	desc = "Zbita masa tkanek: włosy, zęby, kawałki narządów. Nożem albo skalpelem da się z niej wyciąć organoid."
	icon = 'aquila/icons/obj/medical/organ_mods_eris.dmi'
	icon_state = "parasitic_organoid"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/aq_teratoma/attackby(obj/item/I, mob/user, params)
	if(!I.is_sharp())
		return ..()
	to_chat(user, "<span class='notice'>Wycinasz organoid z [src]...</span>")
	if(!do_after(user, 3 SECONDS, target = src))
		return TRUE
	var/organoid_type = pick(subtypesof(/obj/item/aq_organoid/input) + subtypesof(/obj/item/aq_organoid/process) + subtypesof(/obj/item/aq_organoid/output))
	var/obj/item/aq_organoid/organoid = new organoid_type(drop_location())
	to_chat(user, "<span class='notice'>Wycinasz z teratomy [organoid.name].</span>")
	qdel(src)
	return TRUE

/// Monsters from the asteroids sometimes carry a teratoma
/mob/living/simple_animal/hostile/asteroid/death(gibbed)
	if(!gibbed && stat != DEAD && prob(5))
		new /obj/item/aq_teratoma(drop_location())
	return ..()

/// Wrecks, missions and maintenance piles (one shared loot list) sometimes hold a teratoma
/obj/effect/spawner/lootdrop/maintenance/Initialize(mapload)
	if(!GLOB.maintenance_loot[/obj/item/aq_teratoma])
		GLOB.maintenance_loot[/obj/item/aq_teratoma] = 1
	return ..()

// --- Przetwornik biomasy i drukarka narządów ---

/obj/item/stack/aq_biomass
	name = "biomasa"
	singular_name = "kostka biomasy"
	desc = "Sprasowana masa tkanek z przetwornika biomasy. Z niej drukarka narządów drukuje rusztowania, organoidy i narządy."
	icon = 'aquila/icons/obj/machines/aberrant_machines.dmi'
	icon_state = "carne_cansada"
	max_amount = 100
	w_class = WEIGHT_CLASS_SMALL
	novariants = TRUE

/obj/machinery/aq_biomass_recycler
	name = "przetwornik biomasy"
	desc = "Mięsista maszyna, która przeżuwa narządy, mięso i teratomy na kostki biomasy dla drukarki narządów."
	icon = 'aquila/icons/obj/machines/aberrant_machines.dmi'
	icon_state = "disgorger"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/aq_biomass_recycler
	idle_power_usage = 20

/// Biomass from one item, 0 = not accepted
/obj/machinery/aq_biomass_recycler/proc/biomass_value(obj/item/I)
	if(istype(I, /obj/item/aq_teratoma))
		return 10
	var/obj/item/organ/organ = I
	if(istype(organ) && !istype(organ, /obj/item/organ/cyberimp) && !(organ.status & ORGAN_ROBOTIC))
		return 5
	if(istype(I, /obj/item/food/meat))
		return 2
	return 0

/obj/machinery/aq_biomass_recycler/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "disgorger_p", "disgorger", I) || default_deconstruction_crowbar(I))
		return TRUE
	var/value = biomass_value(I)
	if(!value)
		return ..()
	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(user, "<span class='warning'>[src] nie działa.</span>")
		return TRUE
	if(!user.transferItemToLoc(I, src))
		return TRUE
	qdel(I)
	flick("disgorger_chew", src)
	playsound(src, 'sound/effects/splat.ogg', 40, TRUE)
	new /obj/item/stack/aq_biomass(drop_location(), value)
	to_chat(user, "<span class='notice'>[src] przeżuwa [I] i wypluwa [value] kostek biomasy.</span>")
	return TRUE

/obj/machinery/aq_organ_printer
	name = "drukarka narządów"
	desc = "Biodrukarka, która z kostek biomasy drukuje rusztowania narządów, organoidy i proste narządy. Włóż biomasę, potem kliknij, żeby wybrać wydruk."
	icon = 'aquila/icons/obj/machines/aberrant_machines.dmi'
	icon_state = "organ_fabricator"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/aq_organ_printer
	idle_power_usage = 20
	active_power_usage = 500
	var/biomass = 0
	var/busy = FALSE
	/// Printable things and their biomass cost
	var/static/list/products = list(
		"puste rusztowanie narządu" = list(/obj/item/organ/aq_aberrant, 20),
		"organoid wejścia" = list(/obj/item/aq_organoid/input, 15),
		"organoid przetwarzania" = list(/obj/item/aq_organoid/process, 15),
		"organoid wyjścia" = list(/obj/item/aq_organoid/output, 15),
		"wątroba" = list(/obj/item/organ/liver, 30),
		"płuca" = list(/obj/item/organ/lungs, 30),
		"serce" = list(/obj/item/organ/heart, 40),
		"nerki" = list(/obj/item/organ/kidneys, 30),
		"żołądek" = list(/obj/item/organ/stomach, 25),
		"oczy" = list(/obj/item/organ/eyes, 25),
	)

/obj/machinery/aq_organ_printer/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Biomasa: [biomass].</span>"

/obj/machinery/aq_organ_printer/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "organ_fabricator_panel", "organ_fabricator", I) || default_deconstruction_crowbar(I))
		return TRUE
	if(istype(I, /obj/item/stack/aq_biomass))
		var/obj/item/stack/aq_biomass/stack = I
		biomass += stack.amount
		to_chat(user, "<span class='notice'>Wkładasz [stack.amount] kostek biomasy do [src]. Biomasa: [biomass].</span>")
		qdel(stack)
		return TRUE
	return ..()

/obj/machinery/aq_organ_printer/attack_hand(mob/living/user)
	. = ..()
	if(. || busy || (machine_stat & (NOPOWER|BROKEN)))
		return
	var/list/choices = list()
	for(var/product in products)
		choices["[product] ([products[product][2]])"] = product
	var/choice = tgui_input_list(user, "Biomasa: [biomass]. Co wydrukować?", "Drukarka narządów", choices)
	var/product = choices[choice]
	if(!product || busy || !user.canUseTopic(src, BE_CLOSE))
		return
	var/list/entry = products[product]
	if(biomass < entry[2])
		to_chat(user, "<span class='warning'>Za mało biomasy ([biomass] z [entry[2]]).</span>")
		return
	biomass -= entry[2]
	busy = TRUE
	icon_state = "organ_fabricator_work"
	use_power(active_power_usage)
	addtimer(CALLBACK(src, PROC_REF(finish_print), entry[1]), 5 SECONDS)

/obj/machinery/aq_organ_printer/proc/finish_print(product_type)
	busy = FALSE
	icon_state = initial(icon_state)
	if(ispath(product_type, /obj/item/aq_organoid) && length(subtypesof(product_type)))
		product_type = pick(subtypesof(product_type))
	new product_type(drop_location())
	playsound(src, 'sound/machines/ding.ogg', 40, TRUE)

/obj/item/circuitboard/machine/aq_biomass_recycler
	name = "przetwornik biomasy (płytka)"
	build_path = /obj/machinery/aq_biomass_recycler
	req_components = list(/obj/item/stock_parts/matter_bin = 2, /obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/machine/aq_organ_printer
	name = "drukarka narządów (płytka)"
	build_path = /obj/machinery/aq_organ_printer
	req_components = list(/obj/item/stock_parts/matter_bin = 1, /obj/item/stock_parts/manipulator = 2, /obj/item/stack/sheet/glass = 1)

/datum/design/board/aq_biomass_recycler
	name = "Płytka: przetwornik biomasy"
	desc = "Płytka przetwornika biomasy dla drukarki narządów."
	id = "aq_biomass_recycler"
	build_path = /obj/item/circuitboard/machine/aq_biomass_recycler
	category = list("Medical Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/board/aq_organ_printer
	name = "Płytka: drukarka narządów"
	desc = "Płytka biodrukarki rusztowań, organoidów i narządów."
	id = "aq_organ_printer"
	build_path = /obj/item/circuitboard/machine/aq_organ_printer
	category = list("Medical Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/aq_aberrant_scaffold
	name = "Puste rusztowanie narządu"
	desc = "Rusztowanie z gniazdami na organoidy."
	id = "aq_aberrant_scaffold"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 500, /datum/material/silver = 200)
	build_path = /obj/item/organ/aq_aberrant
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/techweb_node/cyber_organs/New()
	. = ..()
	design_ids += list("aq_biomass_recycler", "aq_organ_printer", "aq_aberrant_scaffold")

#undef AQ_ABERRANT_SLOTS
#undef AQ_ORGANOID_INPUT
#undef AQ_ORGANOID_PROCESS
#undef AQ_ORGANOID_OUTPUT

/// Xenobiology: a green slime extract with blood grows a teratoma (the only green extract reaction with blood)
/datum/chemical_reaction/slime/aq_teratoma
	name = "Teratoma ze szlamu"
	id = "aq_slime_teratoma"
	required_reagents = list(/datum/reagent/blood = 1)
	required_container = /obj/item/slime_extract/green
	required_other = TRUE
	catalog_desc = "Daje teratomę, z której nożem wycina się organoid."

/datum/chemical_reaction/slime/aq_teratoma/on_reaction(datum/reagents/holder)
	new /obj/item/aq_teratoma(get_turf(holder.my_atom))
	..()
