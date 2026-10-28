// Port BeeStation/BeeStation-Hornet#14750 (code/datums/stamina_holder.dm).
// Jedna pula staminy na każdym /mob/living: z niej płaci sprint, zamachy i odpychanie, w nią idą obrażenia STAMINA.
// Różnice względem Bee: regeneruje się w SSprocessing zamiast osobnego SSstamina, leżenie bez obezwładnienia
// podwaja regenerację tutaj (bez osobnego modyfikatora), a zwłoki nie wiszą w przetwarzaniu.

/mob/living
	///Pula staminy, patrz [/datum/stamina_container]
	var/datum/stamina_container/stamina

/datum/stamina_container
	///Właściciel puli
	var/mob/living/parent
	///Maksymalna stamina
	var/maximum = STAMINA_MAX
	///Obecna stamina
	var/current = STAMINA_MAX
	///Ile staminy wraca na sekundę
	var/regen_rate = STAMINA_REGEN
	///Różnica między maksimum a obecną staminą
	var/loss = 0
	///To samo w procentach maksimum
	var/loss_as_percent = 0
	///Do tego world.time regeneracja stoi
	var/regen_blocked_until = 0

	var/default_max = STAMINA_MAX
	var/default_regen = STAMINA_REGEN

	var/list/maximum_modifiers
	var/list/regen_modifiers
	var/list/regen_multipliers

/datum/stamina_container/New(mob/living/parent, maximum = STAMINA_MAX, regen_rate = STAMINA_REGEN)
	src.parent = parent
	src.maximum = maximum
	src.default_max = maximum
	src.current = maximum
	src.regen_rate = regen_rate
	src.default_regen = regen_rate

/datum/stamina_container/Destroy()
	if(parent?.stamina == src)
		parent.stamina = null
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
		if(!(parent.mobility_flags & MOBILITY_STAND) && !parent.IsParalyzed() && !parent.IsStun() && !parent.IsUnconscious())
			rate *= STAMINA_RESTING_REGEN_MULTIPLIER
		current = min(current + rate * delta_time, maximum)
	update()
	if(current >= maximum)
		return PROCESS_KILL

///Wstrzymuje regenerację na podany czas
/datum/stamina_container/proc/block_regen(time)
	regen_blocked_until = max(regen_blocked_until, world.time + time)

///Zmienia staminę o amt (ujemne = utrata). Zwraca faktyczną zmianę.
/datum/stamina_container/proc/adjust(amt, forced)
	if(!amt)
		return 0
	// W stamcricie nie da się stracić więcej, więc biciem nie przedłuża się powalenia
	if(amt < 0 && parent.is_stamcrit())
		return 0
	if(SEND_SIGNAL(parent, COMSIG_LIVING_ADJUST_STAMINA_DAMAGE, STAMINA, -amt, forced) & COMPONENT_IGNORE_CHANGE)
		return 0
	var/modify = parent.pre_stamina_change(amt, forced)
	if(!modify)
		return 0
	var/old_current = current
	current = round(clamp(current + modify, 0, maximum), DAMAGE_PRECISION)
	resume()
	. = current - old_current
	if(. < 0)
		parent.on_stamina_loss()

///Wznawia regenerację niepełnej puli i przelicza stan właściciela
/datum/stamina_container/proc/resume()
	if(current < maximum)
		START_PROCESSING(SSprocessing, src)
	update()

///Pełna stamina od razu (np. po aheal)
/datum/stamina_container/proc/refill()
	current = maximum
	regen_blocked_until = 0
	update()

/datum/stamina_container/proc/update()
	loss = maximum - current
	loss_as_percent = maximum ? loss / maximum * 100 : 0
	parent?.on_stamina_update()

///Stamina jako ułamek 0-1
/datum/stamina_container/proc/get_fraction()
	return maximum ? current / maximum : 0

/datum/stamina_container/proc/add_regen_modifier(source, amount)
	LAZYSET(regen_modifiers, source, amount)
	update_stamina_regen()

/datum/stamina_container/proc/remove_regen_modifier(source)
	if(isnull(LAZYACCESS(regen_modifiers, source)))
		return
	LAZYREMOVE(regen_modifiers, source)
	update_stamina_regen()

/datum/stamina_container/proc/add_regen_multiplier(source, multiplier)
	if(LAZYACCESS(regen_multipliers, source) == multiplier)
		return
	LAZYSET(regen_multipliers, source, multiplier)
	update_stamina_regen()

/datum/stamina_container/proc/remove_regen_multiplier(source)
	if(isnull(LAZYACCESS(regen_multipliers, source)))
		return
	LAZYREMOVE(regen_multipliers, source)
	update_stamina_regen()

/datum/stamina_container/proc/update_stamina_regen()
	var/new_regen_rate = default_regen
	for(var/source in regen_modifiers)
		new_regen_rate += regen_modifiers[source]
	for(var/source in regen_multipliers)
		new_regen_rate *= regen_multipliers[source]
	regen_rate = max(new_regen_rate, 2)

/datum/stamina_container/proc/add_max_modifier(source, amount)
	if(LAZYACCESS(maximum_modifiers, source) == amount)
		return
	LAZYSET(maximum_modifiers, source, amount)
	update_maximum()

/datum/stamina_container/proc/remove_max_modifier(source)
	if(isnull(LAZYACCESS(maximum_modifiers, source)))
		return
	LAZYREMOVE(maximum_modifiers, source)
	update_maximum()

/datum/stamina_container/proc/update_maximum()
	var/new_max_stamina = default_max
	for(var/source in maximum_modifiers)
		new_max_stamina += maximum_modifiers[source]
	maximum = max(new_max_stamina, 50)
	current = min(current, maximum)
	resume()
