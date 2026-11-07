// AQUILA - dźwięki otoczenia jak w SS14: szum z konkretnych maszyn (wentylacje, odciągi, szafki APC, automaty).
// Co sekundę każdy gracz dostaje kilka najgłośniejszych pobliskich źródeł, każde w pętli na własnym kanale.
// Bliżej, dalej i za ścianą zmienia się tylko głośność (SOUND_UPDATE), plik nie jest wysyłany od nowa.
// Pozycja jak w playsound(): blisko klient śledzi źródło (apply_sound_position, sound_occlusion.dm).
// Pętle robi aquila/tools/make_ambient_loops.py. Przełącznik: preferencja dźwięków statku (jak ambient_buzz).

/// Ile źródeł naraz słyszy gracz (każde na osobnym kanale)
#define AMBIENT_EMITTER_SLOTS 3
/// Ilu najbliższym kandydatom liczymy wygłuszenie (reszta odpada po samej odległości)
#define AMBIENT_EMITTER_CANDIDATES 6
/// Bok kwadratu siatki źródeł w kafelkach
#define AMBIENT_EMITTER_CELL 8
/// Ciszej niż to źródło nie gra
#define AMBIENT_EMITTER_MIN_VOLUME 1
/// Ile głośności zabiera pełne wygłuszenie (szum przez ścianę prawie znika)
#define AMBIENT_EMITTER_OCCLUSION 0.8

SUBSYSTEM_DEF(ambient_emitters)
	name = "Ambient Emitters"
	wait = 1 SECONDS
	flags = SS_BACKGROUND
	priority = FIRE_PRIORITY_AMBIENCE
	init_order = INIT_ORDER_DEFAULT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	/// "z:x:y" komórki siatki -> lista maszyn
	var/list/emitters_by_cell = list()
	/// maszyna -> klucz komórki, w której jest zapisana
	var/list/emitter_cells = list()
	/// Kanały zarezerwowane raz dla wszystkich (kanał jest osobny u każdego klienta)
	var/list/channels = list()
	var/list/currentrun = list()

/datum/controller/subsystem/ambient_emitters/Initialize(start_timeofday)
	for(var/i in 1 to AMBIENT_EMITTER_SLOTS)
		var/channel = SSsounds.reserve_sound_channel_datumless()
		if(channel)
			channels += channel
	return ..()

/datum/controller/subsystem/ambient_emitters/stat_entry(msg)
	msg = "E:[length(emitter_cells)]"
	return ..()

/datum/controller/subsystem/ambient_emitters/fire(resumed)
	if(!resumed)
		currentrun = GLOB.clients.Copy()
	while(length(currentrun))
		var/client/C = currentrun[length(currentrun)]
		currentrun.len--
		if(C)
			update_client(C)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/ambient_emitters/proc/cell_key(turf/T)
	return "[T.z]:[round(T.x / AMBIENT_EMITTER_CELL)]:[round(T.y / AMBIENT_EMITTER_CELL)]"

/datum/controller/subsystem/ambient_emitters/proc/add_emitter(obj/machinery/M)
	var/turf/T = get_turf(M)
	if(!T)
		return
	remove_emitter(M)
	var/key = cell_key(T)
	LAZYADD(emitters_by_cell[key], M)
	emitter_cells[M] = key

/datum/controller/subsystem/ambient_emitters/proc/remove_emitter(obj/machinery/M)
	var/key = emitter_cells[M]
	if(!key)
		return
	LAZYREMOVE(emitters_by_cell[key], M)
	if(!length(emitters_by_cell[key]))
		emitters_by_cell -= key
	emitter_cells -= M

/**
 * Najgłośniejsze źródła słyszane z kafelka: maszyna -> głośność, po jednym na plik pętli.
 * Najpierw odległość (tanio), wygłuszenie tylko dla kilku najgłośniejszych kandydatów.
 */
/datum/controller/subsystem/ambient_emitters/proc/select_for(turf/listener_turf)
	var/list/base = list()
	var/cx = round(listener_turf.x / AMBIENT_EMITTER_CELL)
	var/cy = round(listener_turf.y / AMBIENT_EMITTER_CELL)
	for(var/x in cx - 1 to cx + 1)
		for(var/y in cy - 1 to cy + 1)
			for(var/obj/machinery/M as anything in emitters_by_cell["[listener_turf.z]:[x]:[y]"])
				var/turf/T = M.loc
				if(!isturf(T))
					continue
				if(T.z != listener_turf.z)
					continue
				var/distance = get_dist(T, listener_turf)
				if(distance > M.ambient_hum_range || !M.ambient_hum_active())
					continue
				var/volume = M.ambient_hum_volume * ((1 - distance / (M.ambient_hum_range + 1)) ** 1.5)
				if(volume >= AMBIENT_EMITTER_MIN_VOLUME)
					base[M] = volume
	if(!length(base))
		return base
	sortTim(base, GLOBAL_PROC_REF(cmp_numeric_dsc), associative = TRUE)
	var/list/scored = list()
	var/checked = 0
	for(var/obj/machinery/M as anything in base)
		if(++checked > AMBIENT_EMITTER_CANDIDATES)
			break
		var/volume = base[M] * (1 - get_sound_occlusion(M.loc, listener_turf) * AMBIENT_EMITTER_OCCLUSION)
		if(volume >= AMBIENT_EMITTER_MIN_VOLUME)
			scored[M] = volume
	sortTim(scored, GLOBAL_PROC_REF(cmp_numeric_dsc), associative = TRUE)
	. = list()
	var/list/files = list()
	for(var/obj/machinery/M as anything in scored)
		if(files[M.ambient_hum])
			continue // jedna pętla na rodzaj szumu, trzy wentylacje obok siebie to nadal jeden szum
		files[M.ambient_hum] = TRUE
		.[M] = scored[M]
		if(length(.) >= AMBIENT_EMITTER_SLOTS)
			break

/datum/controller/subsystem/ambient_emitters/proc/update_client(client/C)
	var/mob/listener = C.mob
	var/turf/listener_turf = get_turf(listener)
	if(!listener_turf || isnewplayer(listener) || !(C.prefs?.toggles & PREFTOGGLE_SOUND_SHIP_AMBIENCE) || !listener.can_hear_ambience())
		stop_all(C)
		return
	var/list/picked = select_for(listener_turf)
	if(!C.ambient_emitter_slots)
		if(!length(picked))
			return
		C.ambient_emitter_slots = new /list(length(channels))
	var/list/slots = C.ambient_emitter_slots
	for(var/i in 1 to length(slots))
		if(slots[i] && !(slots[i] in picked))
			slots[i] = null
			listener.stop_sound_channel(channels[i])
	for(var/obj/machinery/M as anything in picked)
		var/slot = slots.Find(M)
		var/is_new = !slot
		if(is_new)
			slot = slots.Find(null)
			if(!slot)
				break
			slots[slot] = M
		send_hum(listener, listener_turf, M, picked[M], channels[slot], is_new)

/datum/controller/subsystem/ambient_emitters/proc/send_hum(mob/listener, turf/listener_turf, obj/machinery/M, volume, channel, is_new)
	var/sound/S = sound(is_new ? M.ambient_hum : null, repeat = is_new, wait = 0, channel = channel, volume = volume)
	if(is_new)
		S.offset = rand(0, 20) / 10 // dwa takie same źródła nie grają równo
	else
		S.status = SOUND_UPDATE
	listener.apply_sound_position(S, M.loc, listener_turf, M, 1, 0)
	S.falloff = SOUND_RANGE // głośność liczy serwer, FMOD nie dokłada swojego tłumienia
	var/area/A = get_area(listener_turf)
	S.environment = listener.sound_environment_override != SOUND_ENVIRONMENT_NONE ? listener.sound_environment_override : A?.get_sound_environment()
	if(S.environment != SOUND_ENVIRONMENT_NONE)
		S.echo = list(0, 0, 0, 0, 0, 0, 0, 0.25, 1.5, 1.0, 0, 1.0, 0, 0, 0, 0, 1.0, 0)
	SEND_SOUND(listener, S)

/datum/controller/subsystem/ambient_emitters/proc/stop_all(client/C)
	var/list/slots = C.ambient_emitter_slots
	if(!slots)
		return
	for(var/i in 1 to length(slots))
		if(slots[i])
			slots[i] = null
			C.mob?.stop_sound_channel(channels[i])

/client
	/// Maszyny, których szum gra temu klientowi, po jednej na kanał SSambient_emitters.channels
	var/list/ambient_emitter_slots

// Źródła szumu

/obj/machinery
	/// Pętla szumu tej maszyny (aquila/sound/ambience/emitters), null = cicha
	var/ambient_hum
	/// Głośność szumu tuż przy maszynie
	var/ambient_hum_volume = 12
	/// Z ilu kafelków słychać szum
	var/ambient_hum_range = 5

/obj/machinery/Initialize(mapload)
	. = ..()
	if(ambient_hum)
		SSambient_emitters.add_emitter(src)

/obj/machinery/Destroy()
	if(ambient_hum)
		SSambient_emitters.remove_emitter(src)
	return ..()

/obj/machinery/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	if(ambient_hum && SSambient_emitters.emitter_cells[src])
		SSambient_emitters.add_emitter(src)

/// Czy maszyna teraz szumi
/obj/machinery/proc/ambient_hum_active()
	return is_operational

/obj/machinery/atmospherics/components/unary/vent_pump
	ambient_hum = 'aquila/sound/ambience/emitters/vent.ogg'
	ambient_hum_volume = 14

/obj/machinery/atmospherics/components/unary/vent_pump/ambient_hum_active()
	return on && ..()

/obj/machinery/atmospherics/components/unary/vent_scrubber
	ambient_hum = 'aquila/sound/ambience/emitters/scrubber.ogg'
	ambient_hum_volume = 12

/obj/machinery/atmospherics/components/unary/vent_scrubber/ambient_hum_active()
	return on && ..()

/obj/machinery/power/apc
	ambient_hum = 'aquila/sound/ambience/emitters/apc.ogg'
	ambient_hum_volume = 10
	ambient_hum_range = 3

/obj/machinery/power/apc/ambient_hum_active()
	return operating && !(machine_stat & (BROKEN | MAINT))

/obj/machinery/vending
	ambient_hum = 'aquila/sound/ambience/emitters/vending.ogg'
	ambient_hum_volume = 10
	ambient_hum_range = 4

#undef AMBIENT_EMITTER_SLOTS
#undef AMBIENT_EMITTER_CANDIDATES
#undef AMBIENT_EMITTER_CELL
#undef AMBIENT_EMITTER_MIN_VOLUME
#undef AMBIENT_EMITTER_OCCLUSION
