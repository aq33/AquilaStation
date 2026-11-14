/// Odstęp między nagraniami: najdłuższe (pożyczka promu z bombą) trwa 12 s
#define PR640_CLIP_INTERVAL (13 SECONDS)

/datum/test_chamber_kit/pr_640
	name = "Głos SI: ogłoszenia eventów"
	pr = "aq33/AquilaStation#640"
	description = "Zestaw nic nie zrzuca, tylko odtwarza tobie po kolei wszystkie nowe nagrania ogłoszeń eventów (co 13 s, nazwa w czacie). Ponowne zrzucenie zestawu zatrzymuje twoje odtwarzanie. Sprawdź, czy głos brzmi jak dubbing sound/ai/default, czy głośność się zgadza i czy treść pasuje do eventu. \
	Potem odpal kilka eventów przez Trigger Event (np. Anomalia grawitacyjna, Pożyczka promu, Zorza, Fala mięsoroidów) i sprawdź, czy gra ich nagranie, a nie „Uwaga!”. Fala mięsoroidów ma tytuł „Alarm meteorytowy”."
	items = list()
	/// ckey -> numer bieżącego odtwarzania tej osoby. Zestaw jest jeden na serwer, więc stan jest osobno dla każdego admina
	var/list/play_runs = list()
	/// Licznik numerów odtwarzań
	var/last_run = 0

/datum/test_chamber_kit/pr_640/setup(list/spawned, list/turfs, turf/center, mob/user)
	if(!user?.ckey)
		return
	if(play_runs[user.ckey])
		play_runs -= user.ckey
		to_chat(user, span_notice("Zatrzymano odtwarzanie nagrań."))
		return
	var/run = ++last_run
	play_runs[user.ckey] = run
	var/list/names = GLOB.aquila_event_announcement_sounds.Copy()
	to_chat(user, span_notice("Odtwarzam [length(names)] nagrań ogłoszeń eventów. Zrzuć zestaw jeszcze raz, żeby przerwać."))
	play_next_clip(user, user.ckey, names, 1, run)

/datum/test_chamber_kit/pr_640/proc/play_next_clip(mob/user, ckey, list/names, index, run)
	if(play_runs[ckey] != run)
		return
	if(QDELETED(user) || index > length(names))
		play_runs -= ckey
		return
	to_chat(user, span_notice("[index]/[length(names)]: [names[index]]"))
	SEND_SOUND(user, sound(GLOB.aquila_event_announcement_sounds[names[index]]))
	addtimer(CALLBACK(src, PROC_REF(play_next_clip), user, ckey, names, index + 1, run), PR640_CLIP_INTERVAL)

#undef PR640_CLIP_INTERVAL
