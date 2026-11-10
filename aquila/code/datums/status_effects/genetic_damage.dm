// Uszkodzenia genetyczne z BeeStation/BeeStation-Hornet#13442 (port tg): konsola DNA daje je zamiast promieniowania.
#define GORILLA_MUTATION_CHANCE_PER_SECOND 0.25
#define GORILLA_MUTATION_MINIMUM_DAMAGE 2500

/datum/status_effect/genetic_damage
	id = "genetic_damage"
	alert_type = null
	status_type = STATUS_EFFECT_REFRESH // Nowe efekty dodają się do total_damage
	duration = -1
	tick_interval = 2 SECONDS
	on_remove_on_mob_delete = TRUE
	/// Suma uszkodzeń genetycznych
	var/total_damage = 0
	/// Ile uszkodzeń mob zniesie, zanim zacznie dostawać obrażenia od toksyn
	var/minimum_before_tox_damage = 500
	/// Ile uszkodzeń znika na sekundę
	var/remove_per_second = 1 / 3
	/// Obrażenia od toksyn na sekundę powyżej progu
	var/toxin_damage_per_second = 1 / 3

/datum/status_effect/genetic_damage/on_creation(mob/living/new_owner, total_damage)
	. = ..()
	src.total_damage = total_damage

/datum/status_effect/genetic_damage/refresh(mob/living/owner, total_damage)
	src.total_damage += total_damage

/datum/status_effect/genetic_damage/tick(delta_time)
	if(ismonkey(owner) && total_damage >= GORILLA_MUTATION_MINIMUM_DAMAGE && DT_PROB(GORILLA_MUTATION_CHANCE_PER_SECOND, delta_time))
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.gorillize()
		qdel(src)
		return

	if(total_damage >= minimum_before_tox_damage)
		owner.adjustToxLoss(toxin_damage_per_second * delta_time)

	total_damage -= remove_per_second * delta_time
	if(total_damage <= 0)
		qdel(src)
		return

/// Tekst do analizatora zdrowia (Aquila: w Bee przez COMSIG_LIVING_HEALTHSCAN, którego nie mamy)
/datum/status_effect/genetic_damage/proc/get_scan_text(advanced)
	if(advanced)
		return "Uszkodzenia genetyczne: [round(total_damage / minimum_before_tox_damage * 100, 0.1)]%"
	if(total_damage >= minimum_before_tox_damage)
		return "Wykryto poważne uszkodzenia genetyczne."
	return "Wykryto drobne uszkodzenia genetyczne."

#undef GORILLA_MUTATION_CHANCE_PER_SECOND
#undef GORILLA_MUTATION_MINIMUM_DAMAGE
