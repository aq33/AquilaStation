// AQUILA - zepsuty HUD zdrowia z Bee, na naszym hal_screwyhud (Bee robi to grupowymi efektami statusu, których nie mamy)

/mob/living/carbon/proc/set_screwyhud(hud_type)
	hal_screwyhud = hud_type
	update_health_hud()

/// Screwyhud, makes the user's health bar hud wonky
/datum/hallucination/screwy_hud
	abstract_hallucination_parent = /datum/hallucination/screwy_hud
	random_hallucination_weight = 4
	hallucination_tier = HALLUCINATION_TIER_COMMON

	/// The type of hud we give to the hallucinator
	var/screwy_hud_type = SCREWYHUD_NONE

/datum/hallucination/screwy_hud/start()
	if(!iscarbon(hallucinator))
		return FALSE
	var/mob/living/carbon/carbon_hallucinator = hallucinator
	carbon_hallucinator.set_screwyhud(screwy_hud_type)
	feedback_details += "Type: [screwy_hud_type]"
	QDEL_IN(src, rand(10 SECONDS, 25 SECONDS))
	return TRUE

/datum/hallucination/screwy_hud/Destroy()
	if(iscarbon(hallucinator) && !QDELETED(hallucinator))
		var/mob/living/carbon/carbon_hallucinator = hallucinator
		if(carbon_hallucinator.hal_screwyhud == screwy_hud_type)
			carbon_hallucinator.set_screwyhud(SCREWYHUD_NONE)
	return ..()

/datum/hallucination/screwy_hud/crit
	screwy_hud_type = SCREWYHUD_CRIT

/datum/hallucination/screwy_hud/dead
	screwy_hud_type = SCREWYHUD_DEAD

/datum/hallucination/screwy_hud/healthy
	screwy_hud_type = SCREWYHUD_HEALTHY
