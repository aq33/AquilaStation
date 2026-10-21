// AQUILA - port z tgstation (code/modules/unit_tests/dna_infusion.dm)
// Makra testów z upstreamu są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc mamy własne kopie.
#ifndef TEST_ASSERT
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define INFUSER_UNDEF_TEST_ASSERT
#endif

/// Wejścia infusera, które nie są mobami, muszą mieć TRAIT_VALID_DNA_INFUSION
/datum/unit_test/valid_dna_infusion

/datum/unit_test/valid_dna_infusion/Run()
	// typy bazowe, których nie da się sensownie stworzyć bez nasiona
	var/static/list/concrete_types = list(
		/obj/item/food/grown = /obj/item/food/grown/apple,
		/obj/item/grown = /obj/item/grown/log,
	)
	for(var/entry_type in GLOB.infuser_entries)
		var/datum/infuser_entry/infuser_entry = GLOB.infuser_entries[entry_type]
		for(var/input_type in infuser_entry.input_obj_or_mob)
			if(ispath(input_type, /mob/living))
				continue
			var/spawn_type = concrete_types[input_type] || input_type
			var/atom/movable/movable = allocate(spawn_type)
			if(!HAS_TRAIT(movable, TRAIT_VALID_DNA_INFUSION))
				Fail("[input_type] jest w 'input_obj_or_mob' wpisu [infuser_entry.type], ale nie ma TRAIT_VALID_DNA_INFUSION.")

/// Każdy efekt organ_set_bonus musi mieć unikalne id (u nas has_status_effect porównuje po id)
/datum/unit_test/organ_set_bonus_id

/datum/unit_test/organ_set_bonus_id/Run()
	var/list/existing_ids = list()
	for(var/datum/status_effect/organ_set_bonus/bonus_effect as anything in typesof(/datum/status_effect/organ_set_bonus))
		var/effect_id = initial(bonus_effect.id)
		TEST_ASSERT(!(effect_id in existing_ids), "ID [bonus_effect] powtarza się w innym efekcie statusu.")
		existing_ids += effect_id

/// Organy z infusera: bonus zestawu włącza się po wszczepieniu i wyłącza po usunięciu
/datum/unit_test/organ_set_bonus_sanity

/datum/unit_test/organ_set_bonus_sanity/Run()
	// wpisy, których bonus zmienia gatunek (podmienia organy)
	var/list/species_changing_entries = typecacheof(list(
		/datum/infuser_entry/fly,
	))
	for(var/entry_type in GLOB.infuser_entries)
		var/datum/infuser_entry/infuser_entry = GLOB.infuser_entries[entry_type]
		var/mob/living/carbon/human/lab_rat = allocate(/mob/living/carbon/human)
		var/list/obj/item/organ/inserted_organs = list()

		for(var/organ_type in infuser_entry.output_organs)
			var/obj/item/organ/organ = new organ_type()
			organ.replace_into(lab_rat)
			inserted_organs += organ

		var/datum/status_effect/organ_set_bonus/added_status
		if(!infuser_entry.unreachable_effect)
			added_status = locate(/datum/status_effect/organ_set_bonus) in lab_rat.status_effects

		var/has_threshold = (infuser_entry.threshold_desc != DNA_INFUSION_NO_THRESHOLD)
		var/total_organs_needed = added_status?.organs_needed || 0
		var/total_organs = length(infuser_entry.output_organs)
		var/total_inserted = length(inserted_organs)

		TEST_ASSERT((added_status && has_threshold) || (!added_status && !has_threshold), "threshold_desc w `[infuser_entry.type]` nie zgadza się z obecnością efektu organ_set_bonus.")

		if(has_threshold)
			TEST_ASSERT(total_organs_needed, "`organs_needed` w `[added_status.type]` powinno być dodatnie.")
			TEST_ASSERT(total_organs_needed <= total_organs, "`output_organs` w `[infuser_entry.type]` ma [total_organs] organów, a `[added_status.type]` wymaga [total_organs_needed].")
			TEST_ASSERT(added_status.bonus_active, "Bonus `[added_status.type]` nie włączył się po wszczepieniu [total_inserted] z [total_organs_needed] wymaganych organów.")

		if(!total_inserted || species_changing_entries[infuser_entry.type])
			continue

		for(var/obj/item/organ/test_organ as anything in inserted_organs)
			if(test_organ.owner == lab_rat)
				test_organ.Remove(lab_rat, TRUE)

		var/datum/status_effect/organ_set_bonus/removed_status = locate(/datum/status_effect/organ_set_bonus) in lab_rat.status_effects
		TEST_ASSERT(!removed_status || !removed_status.bonus_active, "Bonus `[added_status?.type]` nie wyłączył się po usunięciu organów.")

/// Infuzja z martwego karpia daje organ karpia, a nieznana próbka - muchę
/datum/unit_test/dna_infuser_machine

/datum/unit_test/dna_infuser_machine/Run()
	var/mob/living/carbon/human/subject = allocate(/mob/living/carbon/human)
	var/mob/living/simple_animal/hostile/carp/carp = allocate(/mob/living/simple_animal/hostile/carp)
	TEST_ASSERT(istype(carp.get_infusion_entry(), /datum/infuser_entry/carp), "Karp nie daje wpisu karpia.")
	var/obj/item/food/deadmouse/mouse = allocate(/obj/item/food/deadmouse)
	TEST_ASSERT(istype(mouse.get_infusion_entry(), /datum/infuser_entry/rat), "Martwa mysz nie daje wpisu szczura.")
	var/obj/item/bikehorn/horn = allocate(/obj/item/bikehorn)
	TEST_ASSERT(istype(horn.get_infusion_entry(), /datum/infuser_entry/fly), "Nieznana próbka nie daje muchy.")
	var/datum/infuser_entry/carp_entry = GLOB.infuser_entries[/datum/infuser_entry/carp]
	TEST_ASSERT(subject.infuse_organ(carp_entry, carp), "Infuzja karpia nie podmieniła żadnego organu.")
	var/found_carp_organ = FALSE
	for(var/obj/item/organ/organ as anything in subject.internal_organs)
		if(organ.organ_flags & ORGAN_MUTANT)
			found_carp_organ = TRUE
			TEST_ASSERT(organ.type in carp_entry.output_organs, "Infuzja karpia dała obcy organ [organ.type].")
	TEST_ASSERT(found_carp_organ, "Po infuzji nie ma organu z flagą ORGAN_MUTANT.")

#ifdef INFUSER_UNDEF_TEST_ASSERT
#undef TEST_ASSERT
#undef INFUSER_UNDEF_TEST_ASSERT
#endif
