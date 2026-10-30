// AQUILA - tg code/modules/surgery/operations/operation_lipo.dm
// Liposukcja (stara wersja: code/modules/surgery/lipoplasty.dm, dwa kroki: wycięcie i wyjęcie tłuszczu).
// Zostaje nasze zachowanie: wystarczy cecha otyłości (TRAIT_FAT), pacjent wraca do poziomu "najedzony", nadmiar
// odżywienia trafia do kawałka tłustego mięsa gatunku pacjenta. Tylko organiczna klatka piersiowa.
// Z tg: jeden krok i więcej narzędzi (skalpel, miecz energetyczny, noże, dowolny ostry przedmiot). Pominięta wersja dla protez.

/datum/surgery_operation/limb/lipoplasty
	name = "wycięcie nadmiaru tłuszczu"
	rnd_name = "Liposukcja (wycięcie tłuszczu)"
	desc = "Usuwa nadmiar tłuszczu z ciała pacjenta."
	operation_flags = OPERATION_NOTABLE | OPERATION_AFFECTS_MOOD
	implements = list(
		TOOL_SAW = 1,
		TOOL_SCALPEL = 1.25,
		/obj/item/melee/transforming/energy/sword = 1.33,
		/obj/item/hatchet = 2.85,
		/obj/item/kitchen/knife = 3.33,
		/obj/item = 5,
	)
	time = 6.4 SECONDS
	required_bodytype = BODYTYPE_ORGANIC
	preop_sound = list(
		TOOL_SAW = 'sound/surgery/saw.ogg',
		/obj/item = 'sound/surgery/scalpel1.ogg',
	)
	success_sound = 'sound/surgery/organ2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/limb/lipoplasty/get_any_tool()
	return "Dowolny ostry przedmiot"

/datum/surgery_operation/limb/lipoplasty/get_default_radial_image()
	return get_item_radial_image(/obj/item/food/meat/slab/human)

/datum/surgery_operation/limb/lipoplasty/all_required_strings()
	return list("operacja na: [strefa_pl(BODY_ZONE_CHEST)]") + ..() + list("pacjent musi mieć nadmiar tłuszczu")

/datum/surgery_operation/limb/lipoplasty/tool_check(obj/item/tool)
	return is_specific_implement(tool, implements) || tool.is_sharp()

/datum/surgery_operation/limb/lipoplasty/state_check(obj/item/bodypart/limb)
	return limb.body_zone == BODY_ZONE_CHEST && HAS_TRAIT(limb.owner, TRAIT_FAT)

/datum/surgery_operation/limb/lipoplasty/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz wycinać nadmiar tłuszczu [limb.owner]..."),
		span_notice("[surgeon] zaczyna wycinać nadmiar tłuszczu [limb.owner]."),
		span_notice("[surgeon] zaczyna nacinać ciało [limb.owner] ([strefa_pl(limb.body_zone)]) za pomocą [tool]."),
	)
	display_pain(limb.owner, "Czujesz kłucie ([strefa_pl(limb.body_zone)])!")

/datum/surgery_operation/limb/lipoplasty/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/carbon/patient = limb.owner
	display_results(
		surgeon,
		patient,
		span_notice("Wycinasz i wydobywasz nadmiar tłuszczu [patient]."),
		span_notice("[surgeon] wycina i wydobywa nadmiar tłuszczu [patient]!"),
		span_notice("[surgeon] kończy nacinać ciało [patient] ([strefa_pl(limb.body_zone)])."),
	)
	patient.overeatduration = 0 // pacjent już nie jest otyły
	var/removednutriment = patient.nutrition
	patient.set_nutrition(NUTRITION_LEVEL_WELL_FED)
	removednutriment -= NUTRITION_LEVEL_WELL_FED // to, co wycięto, idzie do mięsa

	var/typeofmeat = /obj/item/food/meat/slab/human
	if(ishuman(patient))
		var/mob/living/carbon/human/human_patient = patient
		if(human_patient.dna?.species?.meat)
			typeofmeat = human_patient.dna.species.meat

	var/obj/item/food/meat/slab/newmeat = new typeofmeat(patient.loc)
	newmeat.name = "fatty meat"
	newmeat.desc = "Extremely fatty tissue taken from a patient."
	newmeat.subjectname = patient.real_name
	newmeat.subjectjob = patient.job
	newmeat.reagents.add_reagent(/datum/reagent/consumable/nutriment, (removednutriment / 15)) // jak nutriment_factor odżywki
