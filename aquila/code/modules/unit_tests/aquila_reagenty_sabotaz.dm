// AQUILA - testy reagentów z grupy sabotaz (raport/reagenty_02_plan_portu.md).
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - sabotaż: Obskurytol tłucze lampy, Rozrusznik niszczy nanity, Fulguracyna pali syntetyków, Kardoks wiąże plazmę i rani szlamy
/datum/unit_test/aquila_reagenty_sabotaz

/datum/unit_test/aquila_reagenty_sabotaz/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	var/turf/open/floor = get_turf(human)
	var/obj/item/reagent_containers/glass/beaker/large/beaker = allocate(/obj/item/reagent_containers/glass/beaker/large)

	// Obskurytol: lampa obok rozlanego reagentu pęka
	var/obj/machinery/light/lamp = allocate(/obj/machinery/light)
	TEST_ASSERT(lamp.status == LIGHT_OK, "The test lamp starts broken ([lamp.status])")
	var/datum/reagent/obscuritol/obscuritol = new()
	obscuritol.reaction_turf(get_turf(lamp), 10)
	qdel(obscuritol)
	TEST_ASSERT(lamp.status == LIGHT_BROKEN, "Obscuritol did not break a lamp on the splashed tile ([lamp.status])")

	// Rozrusznik radiomagnetyczny: nanity znikają
	var/datum/component/nanites/nanites = human.AddComponent(/datum/component/nanites, 100)
	TEST_ASSERT(nanites, "The human did not accept nanites")
	human.reagents.add_reagent(/datum/reagent/toxin/radiomagnetic_disruptor, 5)
	var/datum/reagent/toxin/radiomagnetic_disruptor/disruptor = human.reagents.get_reagent(/datum/reagent/toxin/radiomagnetic_disruptor)
	disruptor.on_mob_life(human)
	TEST_ASSERT(QDELETED(nanites) || nanites.nanite_volume <= 80, "The disruptor did not destroy nanites ([nanites?.nanite_volume])")
	human.reagents.clear_reagents()

	// Fulguracyna: zwykły człowiek cały, IPC poparzony
	beaker.reagents.add_reagent(/datum/reagent/fulguracin, 20)
	beaker.reagents.reaction(human, TOUCH)
	TEST_ASSERT(human.getFireLoss() == 0, "Fulguracin burned an organic human ([human.getFireLoss()])")
	var/mob/living/carbon/human/ipc = allocate(/mob/living/carbon/human)
	ipc.set_species(/datum/species/ipc)
	beaker.reagents.reaction(ipc, TOUCH)
	TEST_ASSERT(ipc.getFireLoss() > 0, "Fulguracin did not burn an IPC")
	beaker.reagents.clear_reagents()

	// Kardoks: wiąże 10 moli plazmy na jednostkę i rani szlamy
	TEST_ASSERT(istype(floor) && floor.air, "The test tile has no air")
	var/plasma_before = floor.air.get_moles(GAS_PLASMA)
	floor.air.set_moles(GAS_PLASMA, 100)
	var/datum/reagent/toxin/cardox/cardox = new()
	cardox.reaction_turf(floor, 5)
	var/plasma_after = floor.air.get_moles(GAS_PLASMA)
	floor.air.set_moles(GAS_PLASMA, plasma_before)
	TEST_ASSERT(abs(plasma_after - 50) < 0.1, "5 u of cardox left [plasma_after] of 100 mol of plasma, expected 50")
	var/mob/living/simple_animal/slime/slime = allocate(/mob/living/simple_animal/slime)
	var/slime_health = slime.health
	cardox.reaction_mob(slime, TOUCH, 5)
	qdel(cardox)
	TEST_ASSERT(slime.health < slime_health, "Cardox did not hurt a slime ([slime.health] / [slime_health])")

/// AQUILA - sterowanie lekami: Malaksytol, Enzym wzmacniający, Polimer glukozy w tabletce, Kordiolis hepatyczny
/datum/unit_test/aquila_reagenty_leki
	/// Ile razy pacjent dostał reakcję połknięcia z tabletki z polimerem
	var/ingest_reactions = 0

/datum/unit_test/aquila_reagenty_leki/proc/on_expose(datum/source, list/reagents, datum/reagents/holder, method)
	SIGNAL_HANDLER
	if(method == INGEST && locate(/datum/reagent/medicine/salbutamol) in reagents)
		ingest_reactions++

/datum/unit_test/aquila_reagenty_leki/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)

	// Malaksytol: inny reagent traci drugi raz tyle, ile zwykle na tick. Najedzony (1,25): leki rate / 1,25, reszta rate * 1,25
	patient.metabolism_efficiency = 1.25
	patient.reagents.add_reagent(/datum/reagent/malaxitol, 10)
	patient.reagents.add_reagent(/datum/reagent/medicine/salbutamol, 10)
	patient.reagents.add_reagent(/datum/reagent/toxin, 10)
	var/datum/reagent/medicine/salbutamol/salbutamol = patient.reagents.get_reagent(/datum/reagent/medicine/salbutamol)
	var/datum/reagent/toxin/toxin = patient.reagents.get_reagent(/datum/reagent/toxin)
	var/expected = 10 - salbutamol.metabolization_rate / 1.25
	var/expected_toxin = 10 - toxin.metabolization_rate * 1.25
	var/datum/reagent/malaxitol/malaxitol = patient.reagents.get_reagent(/datum/reagent/malaxitol)
	malaxitol.on_mob_life(patient)
	TEST_ASSERT(abs(patient.reagents.get_reagent_amount(/datum/reagent/medicine/salbutamol) - expected) < 0.01, "Malaxitol left [patient.reagents.get_reagent_amount(/datum/reagent/medicine/salbutamol)] u of salbutamol at efficiency 1.25, expected [expected]")
	TEST_ASSERT(abs(patient.reagents.get_reagent_amount(/datum/reagent/toxin) - expected_toxin) < 0.01, "Malaxitol left [patient.reagents.get_reagent_amount(/datum/reagent/toxin)] u of toxin at efficiency 1.25, expected [expected_toxin]")
	patient.reagents.clear_reagents()

	// Enzym wzmacniający: odtwarza zużycie leku (głodny, 0,8: rate / 0,8), ale nie ponad 18 j.
	patient.metabolism_efficiency = 0.8
	patient.reagents.add_reagent(/datum/reagent/medicine/booster_enzyme, 10)
	patient.reagents.add_reagent(/datum/reagent/medicine/salbutamol, 10)
	salbutamol = patient.reagents.get_reagent(/datum/reagent/medicine/salbutamol)
	expected = 10 + salbutamol.metabolization_rate / 0.8
	var/datum/reagent/medicine/booster_enzyme/enzyme = patient.reagents.get_reagent(/datum/reagent/medicine/booster_enzyme)
	enzyme.on_mob_life(patient)
	TEST_ASSERT(abs(patient.reagents.get_reagent_amount(/datum/reagent/medicine/salbutamol) - expected) < 0.01, "The booster enzyme left [patient.reagents.get_reagent_amount(/datum/reagent/medicine/salbutamol)] u of salbutamol at efficiency 0.8, expected [expected]")
	patient.metabolism_efficiency = 1
	patient.reagents.add_reagent(/datum/reagent/medicine/salbutamol, 18 - patient.reagents.get_reagent_amount(/datum/reagent/medicine/salbutamol))
	enzyme.on_mob_life(patient)
	TEST_ASSERT(patient.reagents.get_reagent_amount(/datum/reagent/medicine/salbutamol) <= 18.001, "The booster enzyme pushed salbutamol past 18 u")
	patient.reagents.clear_reagents()

	// Polimer glukozy: połknięta tabletka oddaje resztę zawartości po trochu
	var/obj/item/organ/stomach/belly = patient.getorganslot(ORGAN_SLOT_STOMACH)
	TEST_ASSERT(belly?.reagents, "The test human has no stomach")
	var/obj/item/reagent_containers/pill/pill = allocate(/obj/item/reagent_containers/pill)
	pill.reagents.add_reagent(/datum/reagent/consumable/glucose_polymer, 10)
	pill.reagents.add_reagent(/datum/reagent/medicine/salbutamol, 20)
	TEST_ASSERT(pill.attack(patient, patient), "Swallowing a polymer pill failed")
	var/datum/status_effect/aq_extended_release/release = patient.has_status_effect(/datum/status_effect/aq_extended_release)
	TEST_ASSERT(release, "A swallowed polymer pill did not start a slow release")
	var/swallowed = belly.reagents.get_reagent_amount(/datum/reagent/medicine/salbutamol) + patient.reagents.get_reagent_amount(/datum/reagent/medicine/salbutamol)
	TEST_ASSERT(swallowed == 0, "Salbutamol from a polymer pill reached the stomach at once ([swallowed] u)")
	TEST_ASSERT(belly.reagents.get_reagent_amount(/datum/reagent/consumable/glucose_polymer) > 0, "The polymer itself did not reach the stomach")
	RegisterSignal(patient, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(on_expose))
	release.tick()
	UnregisterSignal(patient, COMSIG_ATOM_EXPOSE_REAGENTS)
	TEST_ASSERT(ingest_reactions == 1, "A slow release tick gave [ingest_reactions] swallow reactions, expected 1")
	var/first = belly.reagents.get_reagent_amount(/datum/reagent/medicine/salbutamol)
	// 10 j. polimeru: 120 s, czyli 60 ticków po 2 s
	TEST_ASSERT(first > 0 && first < 1, "The first release tick gave [first] u of salbutamol, expected about 0.33")
	for(var/i in 1 to 70)
		if(QDELETED(release))
			break
		release.tick()
	TEST_ASSERT(QDELETED(release), "The slow release did not end after its time")
	var/total = belly.reagents.get_reagent_amount(/datum/reagent/medicine/salbutamol) + patient.reagents.get_reagent_amount(/datum/reagent/medicine/salbutamol)
	TEST_ASSERT(abs(total - 20) < 0.1, "The slow release delivered [total] u of 20")
	belly.purge_contents()
	patient.reagents.clear_reagents()

	// Płukanie żołądka zabiera też nieuwolnioną część tabletki
	pill = allocate(/obj/item/reagent_containers/pill)
	pill.reagents.add_reagent(/datum/reagent/consumable/glucose_polymer, 10)
	pill.reagents.add_reagent(/datum/reagent/medicine/salbutamol, 20)
	TEST_ASSERT(pill.attack(patient, patient), "Swallowing the second polymer pill failed")
	release = patient.has_status_effect(/datum/status_effect/aq_extended_release)
	release.tick()
	belly.purge_contents()
	TEST_ASSERT(QDELETED(release), "Pumping the stomach left the rest of a polymer pill releasing ([release?.stash?.total_volume] u)")
	patient.reagents.clear_reagents()

	// Kordiolis hepatyczny: toksyny nie niszczą wątroby, a serce dalej obrywa od innych źródeł
	var/obj/item/organ/liver/liver = patient.getorganslot(ORGAN_SLOT_LIVER)
	TEST_ASSERT(liver, "The test human has no liver")
	liver.setOrganDamage(0)
	patient.reagents.add_reagent(/datum/reagent/toxin, 20)
	liver.process_reagents(patient)
	TEST_ASSERT(liver.damage > 0, "20 u of toxin did not hurt an unprotected liver")
	liver.setOrganDamage(0)
	patient.reagents.clear_reagents()
	patient.reagents.add_reagent(/datum/reagent/medicine/cordiolis_hepatico, 10)
	patient.reagents.add_reagent(/datum/reagent/toxin, 20)
	liver.process_reagents(patient)
	TEST_ASSERT(liver.damage == 0, "Cordiolis did not protect the liver from toxins ([liver.damage])")
	TEST_ASSERT(!patient.aq_chem_organ_shield, "The organ shield stayed up after metabolism")
	var/obj/item/organ/heart/heart = patient.getorganslot(ORGAN_SLOT_HEART)
	patient.adjustOrganLoss(ORGAN_SLOT_HEART, 5)
	TEST_ASSERT(heart.damage >= 5, "Cordiolis blocked heart damage outside of metabolism")
	heart.setOrganDamage(0)
	patient.reagents.clear_reagents()

#undef TEST_ASSERT
