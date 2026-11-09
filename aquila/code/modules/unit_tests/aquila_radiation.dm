// Makra TEST_ASSERT* są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc test modularny ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Promieniowanie z BeeStation/BeeStation-Hornet#13442: izolacja na linii, basen, strój ochronny,
/// leki i naturalny zanik, kolektory, licznik Geigera i reakcja pluoxium
/datum/unit_test/aquila_radiation
	/// Kafelki zmienione w teście, do przywrócenia (kafelek -> pierwotny typ)
	var/list/changed_turfs = list()

/datum/unit_test/aquila_radiation/Destroy()
	for(var/turf/changed as anything in changed_turfs)
		changed.ChangeTurf(changed_turfs[changed])
	changed_turfs = null
	return ..()

/// Zmienia kafelek na czas testu
/datum/unit_test/aquila_radiation/proc/swap_turf(turf/target, new_type)
	if(!changed_turfs[target])
		changed_turfs[target] = target.type
	return target.ChangeTurf(new_type)

/// Przelicza od razu wszystkie impulsy z kolejki SSradiation (poza MC pulse() kończy po jednym kafelku)
/datum/unit_test/aquila_radiation/proc/flush_pulses()
	var/safety = 1000
	while(length(SSradiation.processing) && safety-- > 0)
		var/datum/radiation_pulse_information/pulse_information = SSradiation.processing[1]
		var/atom/source = pulse_information.source_ref.resolve()
		if(isnull(source) || !length(pulse_information.turfs_to_process))
			SSradiation.processing -= pulse_information
			continue
		SSradiation.pulse(source, pulse_information)

/datum/unit_test/aquila_radiation/proc/intensity_of(atom/target)
	var/datum/component/irradiated/irradiated_component = target.GetComponent(/datum/component/irradiated)
	return irradiated_component ? irradiated_component.intensity : 0

/datum/unit_test/aquila_radiation/Run()
	var/turf/source_turf = locate(run_loc_floor_bottom_left.x, run_loc_floor_bottom_left.y + 2, run_loc_floor_bottom_left.z)
	var/turf/middle_turf = locate(source_turf.x + 2, source_turf.y, source_turf.z)
	var/turf/target_turf = locate(source_turf.x + 4, source_turf.y, source_turf.z)
	TEST_ASSERT(isopenturf(source_turf) && isopenturf(middle_turf) && isopenturf(target_turf), "Linia testowa nie leży na podłodze")

	// Izolacja na linii: wolna linia nic nie osłabia, ściana mnoży przez 0,7, ściana wzmocniona przez 0,6
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, target_turf)
	TEST_ASSERT_EQUAL(SSradiation.get_insulation_to(source_turf, victim, 0, list()), 1, "Wolna linia osłabia promieniowanie")
	swap_turf(middle_turf, /turf/closed/wall)
	var/through_wall = SSradiation.get_insulation_to(source_turf, victim, 0, list())
	TEST_ASSERT(abs(through_wall - RAD_MEDIUM_INSULATION) < 0.001, "Ściana dała izolację [through_wall] zamiast [RAD_MEDIUM_INSULATION]")
	swap_turf(middle_turf, /turf/closed/wall/r_wall)
	var/through_rwall = SSradiation.get_insulation_to(source_turf, victim, 0, list())
	TEST_ASSERT(through_rwall < through_wall, "Ściana wzmocniona ([through_rwall]) nie osłabia bardziej niż zwykła ([through_wall])")

	// Impuls z progiem 0,8 nie przechodzi przez ścianę, a bez niej człowiek dostaje pełne natężenie
	radiation_pulse(source_turf, max_range = 4, threshold = RAD_LIGHT_INSULATION, intensity = 10)
	flush_pulses()
	TEST_ASSERT_EQUAL(intensity_of(victim), 0, "Impuls przeszedł przez ścianę wzmocnioną")
	middle_turf = middle_turf.ChangeTurf(/turf/open/floor/plasteel)
	radiation_pulse(source_turf, max_range = 4, threshold = RAD_LIGHT_INSULATION, intensity = 10)
	flush_pulses()
	TEST_ASSERT_EQUAL(intensity_of(victim), 10, "Człowiek bez ochrony nie dostał natężenia impulsu")
	TEST_ASSERT(HAS_TRAIT(victim, TRAIT_IRRADIATED), "Napromieniowany człowiek nie ma cechy TRAIT_IRRADIATED")

	// Basen (NSV13) tłumi promieniowanie: przez kafelek wody impuls z progiem 0,8 nie przechodzi
	swap_turf(middle_turf, /turf/open/indestructible/sound/pool)
	var/through_pool = SSradiation.get_insulation_to(source_turf, victim, 0, list())
	TEST_ASSERT(through_pool <= RAD_EXTREME_INSULATION, "Basen dał izolację [through_pool]")
	radiation_pulse(source_turf, max_range = 4, threshold = RAD_LIGHT_INSULATION, intensity = 10)
	flush_pulses()
	TEST_ASSERT_EQUAL(intensity_of(victim), 10, "Impuls przeszedł przez basen")
	middle_turf = middle_turf.ChangeTurf(/turf/open/floor/plasteel)

	// Naturalny zanik: 10 sekund to RADIATION_NATURAL_DECAY_PER_SECOND * 10
	var/datum/component/irradiated/irradiated_component = victim.GetComponent(/datum/component/irradiated)
	irradiated_component.process(10)
	TEST_ASSERT(abs(irradiated_component.intensity - (10 - RADIATION_NATURAL_DECAY_PER_SECOND * 10)) < 0.001, "Naturalny zanik dał [irradiated_component.intensity]% zamiast [10 - RADIATION_NATURAL_DECAY_PER_SECOND * 10]%")

	// Jodek potasu: obniża natężenie i wstrzymuje skutki na czas metabolizmu
	victim.reagents.add_reagent(/datum/reagent/medicine/potass_iodide, 10)
	var/datum/reagent/medicine/potass_iodide/iodide = victim.reagents.has_reagent(/datum/reagent/medicine/potass_iodide)
	TEST_ASSERT(iodide, "Nie udało się podać jodku potasu")
	var/before_iodide = irradiated_component.intensity
	iodide.on_mob_metabolize(victim)
	TEST_ASSERT(HAS_TRAIT(victim, TRAIT_HALT_RADIATION_EFFECTS), "Jodek potasu nie wstrzymuje skutków promieniowania")
	iodide.on_mob_life(victim)
	TEST_ASSERT(irradiated_component.intensity < before_iodide, "Jodek potasu nie obniżył natężenia ([before_iodide]% -> [irradiated_component.intensity]%)")
	iodide.on_mob_end_metabolize(victim)
	TEST_ASSERT(!HAS_TRAIT(victim, TRAIT_HALT_RADIATION_EFFECTS), "Cecha wstrzymania została po jodku potasu")

	// Przy zerowym natężeniu komponent znika
	irradiated_component.intensity = 0.05
	irradiated_component.process(1)
	TEST_ASSERT(QDELETED(irradiated_component), "Komponent napromieniowania został po zaniku do zera")
	TEST_ASSERT(!HAS_TRAIT(victim, TRAIT_IRRADIATED), "Cecha TRAIT_IRRADIATED została po zaniku")

	// Kombinezon i kaptur przeciwradiacyjny chronią, sam kombinezon nie
	var/mob/living/carbon/human/radsuit_wearer = allocate(/mob/living/carbon/human, target_turf)
	radsuit_wearer.equip_to_slot_or_del(new /obj/item/clothing/suit/radiation(radsuit_wearer), ITEM_SLOT_OCLOTHING)
	TEST_ASSERT(!SSradiation.wearing_rad_protected_clothing(radsuit_wearer), "Sam kombinezon bez kaptura chroni przed promieniowaniem")
	radsuit_wearer.equip_to_slot_or_del(new /obj/item/clothing/head/radiation(radsuit_wearer), ITEM_SLOT_HEAD)
	TEST_ASSERT(SSradiation.wearing_rad_protected_clothing(radsuit_wearer), "Kombinezon z kapturem nie chroni przed promieniowaniem")

	// Hardsuit z pancerzem rad = 100 (inżynierii, elitarny) dostaje ochronę sam z siebie
	var/mob/living/carbon/human/hardsuit_wearer = allocate(/mob/living/carbon/human, target_turf)
	var/obj/item/clothing/suit/space/hardsuit/engine/elite/elite_suit = new(hardsuit_wearer)
	TEST_ASSERT(HAS_TRAIT(elite_suit, TRAIT_RADIATION_PROTECTED_CLOTHING), "Hardsuit z pancerzem rad 100 nie dostał ochrony przed promieniowaniem")
	hardsuit_wearer.equip_to_slot_or_del(elite_suit, ITEM_SLOT_OCLOTHING)
	hardsuit_wearer.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/hardsuit/engine/elite(hardsuit_wearer), ITEM_SLOT_HEAD)
	TEST_ASSERT(SSradiation.wearing_rad_protected_clothing(hardsuit_wearer), "Komplet hardsuitu z rad 100 nie chroni przed promieniowaniem")

	// Zwykły inżynieryjny hardsuit z hełmem też chroni (Aquila: rad podniesiony do 100), a hardsuit atmosferyki nie
	var/mob/living/carbon/human/engineer = allocate(/mob/living/carbon/human, target_turf)
	engineer.equip_to_slot_or_del(new /obj/item/clothing/suit/space/hardsuit/engine(engineer), ITEM_SLOT_OCLOTHING)
	engineer.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/hardsuit/engine(engineer), ITEM_SLOT_HEAD)
	TEST_ASSERT(SSradiation.wearing_rad_protected_clothing(engineer), "Inżynieryjny hardsuit z hełmem nie chroni przed promieniowaniem")
	var/obj/item/clothing/suit/space/hardsuit/engine/atmos/atmos_suit = allocate(/obj/item/clothing/suit/space/hardsuit/engine/atmos)
	TEST_ASSERT(!HAS_TRAIT(atmos_suit, TRAIT_RADIATION_PROTECTED_CLOTHING), "Hardsuit atmosferyki dostał ochronę przed promieniowaniem")

	// Licznik Geigera na podłodze w zasięgu odnotowuje impuls
	var/obj/item/geiger_counter/geiger = allocate(/obj/item/geiger_counter, target_turf)
	radiation_pulse(source_turf, max_range = 4, threshold = RAD_LIGHT_INSULATION, intensity = 10)
	flush_pulses()
	TEST_ASSERT_EQUAL(intensity_of(radsuit_wearer), 0, "Kombinezon przeciwradiacyjny nie ochronił przed impulsem")
	TEST_ASSERT_EQUAL(intensity_of(hardsuit_wearer), 0, "Hardsuit z rad 100 nie ochronił przed impulsem")
	TEST_ASSERT_EQUAL(intensity_of(victim), 10, "Człowiek bez ochrony nie dostał drugiego impulsu")
	TEST_ASSERT(!isnull(geiger.last_perceived_radiation_danger), "Licznik Geigera nie odnotował impulsu")

	// Kolektor promieniowania (zostaje na mapach) dostaje dawną siłę: 1000 / odległość² minus próg 80, razy 100
	var/turf/collector_turf = locate(source_turf.x + 2, source_turf.y + 1, source_turf.z)
	var/obj/machinery/power/rad_collector/collector = allocate(/obj/machinery/power/rad_collector/anchored, collector_turf)
	collector.loaded_tank = new /obj/item/tank/internals/plasma(collector)
	collector.active = TRUE
	collector.stored_energy = 0
	radiation_pulse(source_turf, max_range = 0, threshold = RAD_FULL_INSULATION, intensity = 1, collector_power = 1000)
	TEST_ASSERT_EQUAL(round(collector.stored_energy), (1000 / 4 - 80) * 100, "Kolektor dostał inną energię z impulsu")
	collector.active = FALSE
	collector.stored_energy = 0
	radiation_pulse(source_turf, max_range = 0, threshold = RAD_FULL_INSULATION, intensity = 1, collector_power = 1000)
	TEST_ASSERT_EQUAL(collector.stored_energy, 0, "Wyłączony kolektor zbierał energię")
	flush_pulses()

	// Pluoxium: zimna mieszanka CO2 i tlenu z odrobiną trytu
	var/found_reaction = FALSE
	for(var/datum/gas_reaction/reaction as anything in SSair.gas_reactions)
		if(istype(reaction, /datum/gas_reaction/pluox_formation))
			found_reaction = TRUE
			break
	TEST_ASSERT(found_reaction, "Reakcja powstawania pluoxium nie jest zarejestrowana w SSair")
	var/datum/gas_mixture/cold = new(CELL_VOLUME)
	cold.set_moles(GAS_CO2, 10)
	cold.set_moles(GAS_O2, 10)
	cold.set_moles(GAS_TRITIUM, 1)
	cold.set_temperature(200)
	var/datum/gas_reaction/pluox_formation/formation = new
	formation.react(cold, null)
	TEST_ASSERT(cold.get_moles(GAS_PLUOXIUM) > 0, "Reakcja nie wytworzyła pluoxium")
	TEST_ASSERT(cold.get_moles(GAS_CO2) < 10, "Reakcja nie zużyła CO2")
	var/datum/gas_mixture/cold_auxmos = new(CELL_VOLUME)
	cold_auxmos.set_moles(GAS_CO2, 10)
	cold_auxmos.set_moles(GAS_O2, 10)
	cold_auxmos.set_moles(GAS_TRITIUM, 1)
	cold_auxmos.set_temperature(200)
	cold_auxmos.react()
	TEST_ASSERT(cold_auxmos.get_moles(GAS_PLUOXIUM) > 0, "Auxmos nie uruchomił reakcji pluoxium")
	var/datum/gas_mixture/warm = new(CELL_VOLUME)
	warm.set_moles(GAS_CO2, 10)
	warm.set_moles(GAS_O2, 10)
	warm.set_moles(GAS_TRITIUM, 1)
	warm.set_temperature(T20C)
	formation.react(warm, null)
	TEST_ASSERT_EQUAL(warm.get_moles(GAS_PLUOXIUM), 0, "Pluoxium powstało w temperaturze pokojowej")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
