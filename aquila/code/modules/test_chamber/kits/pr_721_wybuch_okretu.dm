// aq33/AquilaStation#721 - zniszczenie okrętu z jego własnego sprite'a, obsada ruin według frakcji układu

/datum/test_chamber_kit/pr_721
	name = "PR 721: wybuch okrętu i obsada ruin"
	pr = "aq33/AquilaStation#721"
	description = "Trzech lokatorów ruiny z mapy (piraci i Rosjanin) od razu zmienia się w ochronę NT, jak w ruinie w układzie NT: mają tę samą broń i strzelają dopiero zaatakowani. \
	Po 5 sekundach leci tylko u ciebie scena zniszczenia okrętu (przez ok. 40 s nie ruszysz się): wasz okręt z overmapy, pięć trafień z pożarami, koziołkowanie, błysk, wielki wybuch i wrak w trzech kawałkach. \
	Mapa nie może prześwitywać przy krawędziach ekranu, scena ma być na środku. Sprawdź też na szerokim ekranie. \
	Syndykat w ruinie: wywołaj planet_garrison_ruin na polach z piratami, z frakcją syndicate i szansą 100."
	items = list()

/datum/test_chamber_kit/pr_721/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/list/turf/spots = list()
	for(var/turf/open/T in range(2, center))
		if(!is_blocked_turf(T, TRUE))
			spots += T
	if(length(spots) < 3)
		return
	var/list/originals = list(/mob/living/basic/trooper/pirate/ranged, /mob/living/basic/trooper/pirate/melee, /mob/living/basic/trooper/russian/ranged/trooper)
	var/list/turf/used = list()
	for(var/trooper_type in originals)
		var/turf/T = pick_n_take(spots)
		new trooper_type(T)
		used += T
	planet_garrison_ruin(used, "nanotrasen", 100, "komora testowa")
	for(var/turf/T as anything in used)
		for(var/mob/living/basic/trooper/trooper in T)
			spawned += trooper
	addtimer(CALLBACK(src, PROC_REF(play_kaboom), user), 5 SECONDS)

/datum/test_chamber_kit/pr_721/proc/play_kaboom(mob/user)
	if(QDELETED(user) || !user.client)
		return
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	if(ship)
		GLOB.ship_kaboom_source = list(ship.icon, ship.icon_state)
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(Cinematic), CINEMATIC_NSV_SHIP_KABOOM, list(user))
