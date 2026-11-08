// AQUILA - halucynacja płonięcia: nasza dawna wersja (nakładka OnFire.dmi, alerty ognia i gorąca) w szkielecie Bee.
// Bee używa nakładek ognia z tg i fałszywego „stop, drop, roll”, których nie mamy.

/datum/hallucination/fire
	random_hallucination_weight = 3
	hallucination_tier = HALLUCINATION_TIER_UNCOMMON
	/// Are we currently burning our mob?
	var/active = TRUE
	/// Current stage of the fake fire alert
	var/stage = 0
	/// The fire overlay we apply over our mob
	var/image/fire_overlay

/datum/hallucination/fire/start()
	hallucinator.fire_stacks = max(hallucinator.fire_stacks, 0.1) // Placebo flammability
	fire_overlay = image('icons/mob/OnFire.dmi', hallucinator, "Standing", ABOVE_MOB_LAYER)
	hallucinator.client?.images |= fire_overlay
	to_chat(hallucinator, span_userdanger("Stajesz w płomieniach!"))
	hallucinator.throw_alert(ALERT_FIRE, /atom/movable/screen/alert/fire, override = TRUE)
	INVOKE_ASYNC(src, PROC_REF(burn_loop))
	return TRUE

/datum/hallucination/fire/Destroy()
	if(!QDELETED(hallucinator))
		hallucinator.clear_alert(ALERT_FIRE, clear_override = TRUE)
		hallucinator.clear_alert(ALERT_TEMPERATURE, clear_override = TRUE)
		hallucinator.client?.images -= fire_overlay
	fire_overlay = null
	return ..()

/datum/hallucination/fire/proc/burn_loop()
	sleep(2 SECONDS)
	for(var/i in 1 to 3)
		if(QDELETED(src) || hallucinator.fire_stacks <= 0)
			clear_fire()
			return
		stage++
		update_temp()
		sleep(3 SECONDS)
	for(var/i in 1 to rand(5, 10))
		if(QDELETED(src) || hallucinator.fire_stacks <= 0)
			clear_fire()
			return
		hallucinator.adjustStaminaLoss(15)
		sleep(2 SECONDS)
	clear_fire()

/datum/hallucination/fire/proc/update_temp()
	hallucinator.clear_alert(ALERT_TEMPERATURE, clear_override = TRUE)
	if(stage > 0)
		hallucinator.throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, stage, override = TRUE)

/datum/hallucination/fire/proc/clear_fire()
	if(QDELETED(src) || !active)
		return
	active = FALSE
	hallucinator.clear_alert(ALERT_FIRE, clear_override = TRUE)
	hallucinator.client?.images -= fire_overlay
	fire_overlay = null
	while(stage > 0 && !QDELETED(src))
		stage--
		update_temp()
		sleep(3 SECONDS)
	if(!QDELETED(src))
		qdel(src)
