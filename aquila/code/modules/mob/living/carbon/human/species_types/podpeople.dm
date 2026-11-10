/datum/species/pod
	speech_sound = "pod"

// Promieniowanie z BeeStation/BeeStation-Hornet#13442: ludzie-strąki żywią się promieniowaniem jak Diona w Bee
// (TRAIT_RADHEALER). Bez wywołania bazowej procki, bo ta powala i wywołuje wymioty.
/datum/species/pod/handle_radiation(mob/living/carbon/human/H, intensity, delta_time)
	H.adjust_nutrition(intensity * 0.1 * delta_time)
	if(intensity > 50)
		H.heal_overall_damage(brute = 1 * delta_time, burn = 1 * delta_time, required_status = BODYTYPE_ORGANIC)
		H.adjustToxLoss(-2 * delta_time)
		H.adjustOxyLoss(-1 * delta_time)
