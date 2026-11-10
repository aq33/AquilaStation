// AQUILA - dźwięk alarmu pożarowego z tg (tgstation/tgstation, sound/machines/fire_alarm)
// Zamiast jednego dźwięku NSV przy każdym wyzwoleniu alarm gra w pętli, dopóki obszar jest w alarmie pożarowym.
// Pętla gaśnie sama po skasowaniu alarmu, utracie zasilania albo zepsuciu. Zemagowany alarm pociągnięty ręcznie też gra (jak w tg).

/datum/looping_sound/firealarm
	mid_sounds = list(
		'aquila/sound/machines/fire_alarm/fire_alarm1.ogg',
		'aquila/sound/machines/fire_alarm/fire_alarm2.ogg',
		'aquila/sound/machines/fire_alarm/fire_alarm3.ogg',
		'aquila/sound/machines/fire_alarm/fire_alarm4.ogg',
	)
	mid_length = 2.4 SECONDS
	// Głośniej niż w tg (75) i z łagodnym zanikiem: pełna głośność w promieniu 6 kratek, potem powolny spadek,
	// żeby alarm było wyraźnie słychać w całym pomieszczeniu i na korytarzu obok
	volume = 100
	extra_range = 7
	falloff_distance = 6
	falloff_exponent = 2

/datum/looping_sound/firealarm/sound_loop(starttime)
	var/obj/machinery/firealarm/alarm = parent
	if(!istype(alarm) || !alarm.should_sound_alarm())
		stop()
		return
	return ..()

/obj/machinery/firealarm
	var/datum/looping_sound/firealarm/soundloop

/obj/machinery/firealarm/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/firealarm/proc/should_sound_alarm()
	if(!is_operational)
		return FALSE
	var/area/our_area = get_area(src)
	return our_area?.fire

/obj/machinery/firealarm/proc/start_alarm_sound()
	if(!soundloop)
		soundloop = new(src, FALSE)
	soundloop.start()

/// Po powrocie zasilania (albo naprawie) alarm, który dalej trwa, znowu gra
/obj/machinery/firealarm/on_set_is_operational(old_value)
	. = ..()
	if(soundloop && should_sound_alarm())
		start_alarm_sound()

/obj/machinery/firealarm/reset(mob/user)
	. = ..()
	soundloop?.stop()
