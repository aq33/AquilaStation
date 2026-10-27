// Port BeeStation/BeeStation-Hornet#14750 (code/datums/stamina_holder.dm), okrojony do sprintu.
// To osobna pula „kondycji”: nie ma nic wspólnego z naszą staminą per kończyna (staminaloss, stamcrit).
// Różnice względem Bee: regeneruje się w SSprocessing zamiast osobnego SSstamina, bez modyfikatorów max/regen,
// leżenie podwaja regenerację tutaj, a nie przez osobny modyfikator.

/mob/living/carbon
	///Kondycja do sprintu, patrz [/datum/component/carbon_sprint]
	var/datum/stamina_container/sprint_stamina

/datum/stamina_container
	///Właściciel puli
	var/mob/living/carbon/parent
	///Maksymalna kondycja
	var/maximum = SPRINT_STAMINA_MAX
	///Obecna kondycja
	var/current = SPRINT_STAMINA_MAX
	///Ile kondycji wraca na sekundę
	var/regen_rate = SPRINT_STAMINA_REGEN
	///Do tego world.time regeneracja stoi
	var/regen_blocked_until = 0

/datum/stamina_container/New(mob/living/carbon/parent, maximum = SPRINT_STAMINA_MAX, regen_rate = SPRINT_STAMINA_REGEN)
	src.parent = parent
	src.maximum = maximum
	src.current = maximum
	src.regen_rate = regen_rate

/datum/stamina_container/Destroy()
	if(parent?.sprint_stamina == src)
		parent.sprint_stamina = null
	parent = null
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/stamina_container/process(delta_time)
	if(QDELETED(parent))
		return PROCESS_KILL
	// Zwłoki nie regenerują i nie wiszą w SSprocessing; revive() wznawia
	if(parent.stat == DEAD)
		return PROCESS_KILL
	if(world.time >= regen_blocked_until)
		var/rate = regen_rate
		if(!(parent.mobility_flags & MOBILITY_STAND))
			rate *= SPRINT_STAMINA_RESTING_REGEN_MULTIPLIER
		current = min(current + rate * delta_time, maximum)
	update()
	if(current >= maximum)
		return PROCESS_KILL

///Wstrzymuje regenerację na podany czas
/datum/stamina_container/proc/block_regen(time)
	regen_blocked_until = max(regen_blocked_until, world.time + time)

///Zmienia kondycję o amt. Zwraca faktyczną zmianę.
/datum/stamina_container/proc/adjust(amt)
	if(!amt)
		return 0
	var/old_current = current
	current = round(clamp(current + amt, 0, maximum), DAMAGE_PRECISION)
	if(current < maximum)
		START_PROCESSING(SSprocessing, src)
	update()
	return current - old_current

///Wznawia regenerację niepełnej puli (np. po wskrzeszeniu)
/datum/stamina_container/proc/resume()
	if(current < maximum)
		START_PROCESSING(SSprocessing, src)
	update()

///Pełna kondycja od razu (np. po aheal)
/datum/stamina_container/proc/refill()
	current = maximum
	regen_blocked_until = 0
	update()

/datum/stamina_container/proc/update()
	parent?.on_sprint_stamina_update()

///Kondycja jako ułamek 0-1
/datum/stamina_container/proc/get_fraction()
	return maximum ? current / maximum : 0
