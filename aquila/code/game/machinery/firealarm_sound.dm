// AQUILA - dźwięk alarmu pożarowego z tg (tgstation/tgstation, sound/machines/fire_alarm)
// Zamiast jednego dźwięku NSV przy każdym wyzwoleniu alarm gra w pętli, dopóki obszar jest w alarmie pożarowym.
// Pętla gaśnie sama po skasowaniu alarmu, utracie zasilania, zepsuciu albo emagu.

/datum/looping_sound/firealarm
	mid_sounds = list(
		'aquila/sound/machines/fire_alarm/fire_alarm1.ogg',
		'aquila/sound/machines/fire_alarm/fire_alarm2.ogg',
		'aquila/sound/machines/fire_alarm/fire_alarm3.ogg',
		'aquila/sound/machines/fire_alarm/fire_alarm4.ogg',
	)
	mid_length = 2.4 SECONDS
	volume = 30

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
	if(!is_operational || (obj_flags & EMAGGED))
		return FALSE
	var/area/our_area = get_area(src)
	return our_area?.fire

/obj/machinery/firealarm/proc/start_alarm_sound()
	if(!soundloop)
		soundloop = new(src, FALSE)
	soundloop.start()

/obj/machinery/firealarm/reset(mob/user)
	. = ..()
	soundloop?.stop()
