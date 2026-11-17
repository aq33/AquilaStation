// AQUILA - zarazki i sterylność (AquilaMed 5, etap 3). Pomysł z Baystation12 i Paradise (germ_level na kończynach,
// narzędziach i rękawiczkach, code/modules/surgery/surgery.dm: spread_germs_to_organ, spread_germs_by_incision), kod własny.
// - Każda organiczna kończyna ma zarazki 0-100. Zbierają się z otwartych ran bez opatrunku i z operacji.
// - Operacja na otwartej kończynie przenosi brud: z narzędzia, z rąk albo rękawiczek, z miejsca (podłoga gorsza niż stół
//   operacyjny), z bałaganu wokół i od ludzi bez maseczek obok. Sterylizyna albo alkohol na pacjencie mocno to ograniczają.
//   Narzędzia i rękawiczki brudzą się od każdego kroku, czyści je autoklaw, sterylizyna, środek czyszczący albo mocny alkohol.
// - Od 30 zakażenie (ból), od 60 gorączka, od 90 sepsa: ciężko osłabia (toksyny, zmęczenie, zawroty), ale nie zabija.
// - Antybiotyk (spaceacylina) cofa zakażenie w kilka minut, sterylizyna na skórę i operacja oczyszczenia pomagają od razu.
// - Zakażenie oparzeń (wounds/burn.dm) jest teraz zarazkami kończyny: oparzenie trzeciego stopnia brudzi się najszybciej.
// Bez zarazków w narządach (decyzja w raport/medycyna5_01_plan.md).

#define AQ_GERMS_MAX 100
/// Infection (pain), fever, sepsis
#define AQ_GERMS_INFECTED 30
#define AQ_GERMS_FEVER 60
#define AQ_GERMS_SEPSIS 90
/// Germs per second: an infection grows, a clean limb fights them off, an antibiotic knocks them back
#define AQ_GERMS_GROWTH 0.06
#define AQ_GERMS_IMMUNE 0.02
#define AQ_GERMS_ANTIBIOTIC 0.3
/// Sepsis weakens but does not kill: it stops adding toxins and stamina damage past these
#define AQ_SEPSIS_TOX_CAP 40
#define AQ_SEPSIS_STAMINA_CAP 60

/obj/item/bodypart
	/// Germs on this limb, 0-100
	var/aq_germs = 0

/obj/item
	/// Dirt of a tool or gloves, 0-10: what an operation carries into the patient
	var/aq_dirt = 0

/// Germs on an organic limb; clamps and ignores prostheses
/obj/item/bodypart/proc/aq_add_germs(amount)
	if(!IS_ORGANIC_LIMB(src) || !amount)
		return
	aq_germs = clamp(aq_germs + amount, 0, AQ_GERMS_MAX)

/// Short name of the infection stage, or null
/obj/item/bodypart/proc/aq_infection_stage_name()
	if(aq_germs >= AQ_GERMS_SEPSIS)
		return "sepsa"
	if(aq_germs >= AQ_GERMS_FEVER)
		return "zakażenie z gorączką"
	if(aq_germs >= AQ_GERMS_INFECTED)
		return "zakażenie"
	if(aq_germs >= 10)
		return "zabrudzona rana"
	return null

// --- Ciało ---

/mob/living/carbon/human/Life()
	. = ..()
	if(QDELETED(src) || notransform || stat == DEAD || IsInStasis())
		return
	aq_handle_germs(2)

/// Germs grow on infected limbs, fall on clean ones and with antibiotics; fever and sepsis from the worst limb
/mob/living/carbon/human/proc/aq_handle_germs(delta)
	var/antibiotic = reagents?.has_reagent(/datum/reagent/medicine/spaceacillin)
	var/worst = 0
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		if(!IS_ORGANIC_LIMB(limb) || !limb.aq_germs)
			continue
		if(antibiotic)
			limb.aq_add_germs(-AQ_GERMS_ANTIBIOTIC * delta)
		else if(limb.aq_germs >= AQ_GERMS_INFECTED)
			limb.aq_add_germs(AQ_GERMS_GROWTH * delta)
		else if(!aq_limb_has_open_wound(limb))
			limb.aq_add_germs(-AQ_GERMS_IMMUNE * delta)
		worst = max(worst, limb.aq_germs)
	if(worst >= AQ_GERMS_FEVER)
		if(bodytemperature < BODYTEMP_NORMAL + 3)
			adjust_bodytemperature(1 * delta)
		if(prob(2 * delta))
			to_chat(src, "<span class='warning'>[pick("Masz dreszcze, a czoło pali cię od gorączki.", "Kręci ci się w głowie od gorączki.", "Całe ciało pali cię i boli od gorączki.")]</span>")
	if(worst >= AQ_GERMS_SEPSIS)
		if(getToxLoss() < AQ_SEPSIS_TOX_CAP)
			adjustToxLoss(0.3 * delta)
		if(getStaminaLoss() < AQ_SEPSIS_STAMINA_CAP)
			adjustStaminaLoss(3 * delta)
		if(prob(3 * delta))
			Dizzy(5)
			to_chat(src, "<span class='danger'>Słabniesz, cały organizm walczy z zakażeniem.</span>")

/// An untreated cut, puncture or burn lets germs in
/mob/living/carbon/proc/aq_limb_has_open_wound(obj/item/bodypart/limb)
	for(var/datum/wound/wound as anything in limb.wounds)
		if(!wound.treated && (wound.wound_type == WOUND_SLASH || wound.wound_type == WOUND_PIERCE || wound.wound_type == WOUND_BURN))
			return TRUE
	return FALSE

/// Pain an infected limb adds (pain/pain.dm)
/obj/item/bodypart/proc/aq_infection_pain()
	if(aq_germs >= AQ_GERMS_SEPSIS)
		return 30
	if(aq_germs >= AQ_GERMS_FEVER)
		return 20
	if(aq_germs >= AQ_GERMS_INFECTED)
		return 10
	return 0

/// Lines for the health analyzer (wounds/_wounds.dm get_wound_scan_lines)
/mob/living/carbon/proc/aq_germ_scan_lines()
	. = list()
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		var/stage = limb.aq_infection_stage_name()
		if(stage)
			. += "<span class='alert'>[capitalize(limb.name)]: <b>[stage]</b> ([round(limb.aq_germs)]%). Spaceacylina, sterylizyna na skórę albo operacja oczyszczenia.</span>"

// --- Rany zbierają zarazki ---

/datum/wound
	/// Germs per second this wound lets into its limb while untreated
	var/germ_rate = 0

/datum/wound/slash/deep
	germ_rate = 0.03

/datum/wound/slash/artery
	germ_rate = 0.05

/datum/wound/pierce/puncture
	germ_rate = 0.02

/datum/wound/pierce/open
	germ_rate = 0.04

/datum/wound/pierce/cavity
	germ_rate = 0.06

/datum/wound/burn/second_degree
	germ_rate = 0.08

/datum/wound/burn/third_degree
	germ_rate = 0.15

/datum/wound/process(delta_time)
	. = ..()
	if(QDELETED(src) || !germ_rate || treated || !limb || victim?.stat == DEAD)
		return
	limb.aq_add_germs(germ_rate * delta_time)

// --- Operacje przenoszą brud ---

/// Germs one operation step carries into an open limb, from the tool, the hands, the place, the mess and the people around
/datum/surgery_operation/proc/aq_spread_surgery_germs(atom/movable/operating_on, mob/living/surgeon, tool)
	var/obj/item/bodypart/limb = operating_on
	if(!istype(limb) || !limb.owner || !IS_ORGANIC_LIMB(limb) || !LIMB_HAS_ANY_SURGERY_STATE(limb, ALL_SURGERY_SKIN_STATES))
		return
	var/mob/living/carbon/patient = limb.owner
	var/dirt = 0
	var/obj/item/tool_item = isitem(tool) ? tool : null
	if(tool_item)
		dirt += tool_item.aq_dirt
	var/obj/item/clothing/gloves/gloves
	if(ishuman(surgeon))
		var/mob/living/carbon/human/gloved = surgeon
		gloves = gloved.gloves
	if(gloves)
		dirt += gloves.aq_dirt
	else
		var/mob/living/carbon/human/bare = surgeon
		dirt += (istype(bare) && bare.hygiene <= HYGIENE_LEVEL_DIRTY) ? 8 : 4
	dirt += aq_place_dirt(get_turf(patient))
	var/mess = 0
	for(var/obj/effect/decal/cleanable/filth in range(1, patient))
		if(++mess >= 4)
			break
	dirt += mess
	var/unmasked = 0
	for(var/mob/living/carbon/human/person in range(2, patient))
		if(person == patient || person.stat == DEAD || person.is_mouth_covered())
			continue
		if(++unmasked >= 3)
			break
	dirt += unmasked
	if(patient.aq_surgery_speed_mod_active(/datum/reagent/space_cleaner/sterilizine))
		dirt *= 0.25
	else if(patient.aq_surgery_speed_mod_active("alcohol"))
		dirt *= 0.5
	limb.aq_add_germs(dirt)
	if(tool_item)
		tool_item.aq_dirt = min(10, tool_item.aq_dirt + 2)
	if(gloves)
		gloves.aq_dirt = min(10, gloves.aq_dirt + 2)

/// Dirt of where the patient lies: an operating table is clean, the floor is not
/datum/surgery_operation/proc/aq_place_dirt(turf/place)
	var/static/list/places = list(
		/obj/structure/table/optable = 0,
		/obj/machinery/stasis = 1,
		/obj/structure/table = 2,
		/obj/structure/bed = 3,
	)
	. = 5
	for(var/obj/thing in place)
		for(var/kind in places)
			if(istype(thing, kind))
				. = min(., places[kind])
				break

/mob/living/proc/aq_surgery_speed_mod_active(id)
	return !isnull(LAZYACCESS(mob_surgery_speed_mods, id))

// --- Czyszczenie narzędzi i rękawiczek ---

/datum/reagent/space_cleaner/reaction_obj(obj/O, reac_volume)
	. = ..()
	if(isitem(O))
		var/obj/item/cleaned = O
		cleaned.aq_dirt = 0

/datum/reagent/consumable/ethanol/reaction_obj(obj/O, reac_volume)
	. = ..()
	if(isitem(O) && boozepwr >= 40)
		var/obj/item/cleaned = O
		cleaned.aq_dirt = 0

/obj/item/examine(mob/user)
	. = ..()
	if(aq_dirt >= 4 && (is_surgical_tool() || istype(src, /obj/item/clothing/gloves)))
		. += "<span class='warning'>Jest brudny po poprzednim pacjencie. Przed operacją wysterylizuj go.</span>"

// --- Sterylizacja skóry pacjenta ---

/datum/reagent/space_cleaner/sterilizine/reaction_mob(mob/living/carbon/C, method = TOUCH, reac_volume)
	. = ..()
	if(iscarbon(C) && (method in list(TOUCH, VAPOR, PATCH)))
		C.aq_disinfect_skin(reac_volume * 4)

/datum/reagent/consumable/ethanol/reaction_mob(mob/living/M, method = TOUCH, reac_volume)
	. = ..()
	if(iscarbon(M) && boozepwr >= 40 && (method in list(TOUCH, VAPOR, PATCH)))
		var/mob/living/carbon/C = M
		C.aq_disinfect_skin(reac_volume * 2)

/// Disinfecting the skin knocks back germs that have not taken hold yet (below sepsis)
/mob/living/carbon/proc/aq_disinfect_skin(amount)
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		if(limb.aq_germs < AQ_GERMS_SEPSIS)
			limb.aq_add_germs(-min(amount, 30))

// --- Operacja oczyszczenia zakażenia (Paradise: external_infection_treatment) ---

/datum/surgery_operation/limb/clean_infection
	name = "oczyszczenie zakażenia"
	catalog_sections = list(SURGERY_SECTION_WOUNDS)
	rnd_name = "Oczyszczenie zakażenia"
	desc = "Wypłukuje zakażenie z otwartej kończyny pojemnikiem ze sterylizyną albo spaceacyliną (zużywa 5 j.)."
	implements = list(/obj/item/reagent_containers = 1)
	time = 3 SECONDS
	operation_flags = OPERATION_AFFECTS_MOOD
	all_surgery_states_required = SURGERY_SKIN_OPEN
	required_bodytype = BODYTYPE_ORGANIC
	success_sound = 'sound/effects/spray.ogg'

/datum/surgery_operation/limb/clean_infection/all_required_strings()
	return list("kończyna musi mieć zarazki", "pojemnik z 5 j. sterylizyny albo spaceacyliny") + ..()

/datum/surgery_operation/limb/clean_infection/get_default_radial_image()
	return image(icon = 'icons/obj/chemical.dmi', icon_state = "medspray")

/datum/surgery_operation/limb/clean_infection/state_check(obj/item/bodypart/limb)
	return limb.aq_germs >= 10

/datum/surgery_operation/limb/clean_infection/tool_check(obj/item/tool)
	var/obj/item/reagent_containers/container = tool
	if(!istype(container) || !container.reagents)
		return FALSE
	return container.reagents.get_reagent_amount(/datum/reagent/space_cleaner/sterilizine) >= 5 || container.reagents.get_reagent_amount(/datum/reagent/medicine/spaceacillin) >= 5

/datum/surgery_operation/limb/clean_infection/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz wypłukiwać zakażenie ([FORMAT_LIMB_OWNER(limb)])..."),
		span_notice("[surgeon] zaczyna wypłukiwać zakażenie ([FORMAT_LIMB_OWNER(limb)]) za pomocą [tool]."),
		span_notice("[surgeon] zaczyna płukać ranę ([FORMAT_LIMB_OWNER(limb)])."),
	)
	display_pain(limb.owner, "Rana ([strefa_pl(limb.body_zone)]) piecze, jakby ktoś polał ją kwasem!")

/datum/surgery_operation/limb/clean_infection/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/obj/item/reagent_containers/container = tool
	var/reagent = container.reagents.get_reagent_amount(/datum/reagent/space_cleaner/sterilizine) >= 5 ? /datum/reagent/space_cleaner/sterilizine : /datum/reagent/medicine/spaceacillin
	container.reagents.remove_reagent(reagent, 5)
	limb.aq_add_germs(-70)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Wypłukujesz zakażenie ([FORMAT_LIMB_OWNER(limb)])."),
		span_notice("[surgeon] wypłukuje zakażenie ([FORMAT_LIMB_OWNER(limb)])."),
		span_notice("[surgeon] kończy płukać ranę ([FORMAT_LIMB_OWNER(limb)])."),
	)

/mob/living/carbon/fully_heal(admin_revive = FALSE)
	. = ..()
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		limb.aq_germs = 0

#undef AQ_GERMS_MAX
#undef AQ_GERMS_INFECTED
#undef AQ_GERMS_FEVER
#undef AQ_GERMS_SEPSIS
#undef AQ_GERMS_GROWTH
#undef AQ_GERMS_IMMUNE
#undef AQ_GERMS_ANTIBIOTIC
#undef AQ_SEPSIS_TOX_CAP
#undef AQ_SEPSIS_STAMINA_CAP
