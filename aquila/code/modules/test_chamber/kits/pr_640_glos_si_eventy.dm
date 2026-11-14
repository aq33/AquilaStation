/datum/test_chamber_kit/pr_640
	name = "Głos SI: ogłoszenia eventów"
	pr = "aq33/AquilaStation#640"
	description = "Zestaw nic nie zrzuca, tylko odtwarza tobie po kolei wszystkie nowe nagrania z aquila/sound/ai/events (co 9 s, nazwa pliku w czacie). Sprawdź, czy głos brzmi jak dubbing sound/ai/default, czy głośność się zgadza i czy treść pasuje do eventu. \
	Potem odpal kilka eventów przez Trigger Event (np. Anomalia grawitacyjna, Pożyczka promu, Zorza, Fala mięsoroidów) i sprawdź, czy gra ich nagranie, a nie „Uwaga!”. Fala mięsoroidów ma tytuł „Alarm meteorytowy”."
	items = list()

/datum/test_chamber_kit/pr_640/setup(list/spawned, list/turfs, turf/center, mob/user)
	if(!user)
		return
	var/list/files = list()
	for(var/name in flist("aquila/sound/ai/events/"))
		if(findtext(name, ".ogg", -4))
			files += name
	to_chat(user, span_notice("Odtwarzam [length(files)] nagrań ogłoszeń eventów."))
	play_next_clip(user, files, 1)

/datum/test_chamber_kit/pr_640/proc/play_next_clip(mob/user, list/files, index)
	if(QDELETED(user) || index > length(files))
		return
	to_chat(user, span_notice("[index]/[length(files)]: [files[index]]"))
	SEND_SOUND(user, sound(file("aquila/sound/ai/events/[files[index]]")))
	addtimer(CALLBACK(src, PROC_REF(play_next_clip), user, files, index + 1), 9 SECONDS)
