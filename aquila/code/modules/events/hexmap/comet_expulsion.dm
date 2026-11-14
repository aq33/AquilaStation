// AQUILA - wyrzut komety: kilka uderzeń odłamków komety sypie na statek lodowe i zwykłe meteory (port z Aurora.3 code/modules/events/comet_expulsion.dm)
// Tu są też lodowe meteory używane przez ogon komety (comet_tail.dm).

/// Poziomy Z okrętu głównego (gdy nie ma okrętu, poziomy z cechą stacji)
/proc/aquila_hex_ship_zlevels()
	var/list/levels = list()
	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	for(var/datum/space_level/level as anything in main?.occupying_levels)
		levels |= level.z_value
	if(!length(levels))
		levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	return levels

/// Lodowy meteor z komety: po rozbiciu zostawia śnieg, oszronioną podłogę i wychładza ludzi obok
/obj/effect/meteor/aquila_ice
	name = "lodowy odłamek komety"
	desc = "Bryła brudnego lodu z komety, pędząca prosto na kadłub."
	icon_state = "small"
	color = "#bfeaff"
	hits = 4
	hitpwr = EXPLODE_LIGHT
	meteordrop = list(/obj/item/stack/sheet/mineral/snow)
	dropamt = 3
	threat = 4
	/// Promień oszronienia po rozbiciu
	var/chill_range = 1
	/// O ile kelwinów spada temperatura ciała ludzi w promieniu
	var/chill_amount = 30

/obj/effect/meteor/aquila_ice/meteor_effect()
	..()
	chill_area()
	explode_ice()

/// Wybuch przy rozbiciu, lżejszy niż zwykłego meteoru tej wielkości
/obj/effect/meteor/aquila_ice/proc/explode_ice()
	explosion(src.loc, 0, 0, 2, 3, 0)

/// Lód z rozbitego meteoru: śliska, zamarznięta podłoga i zimno
/obj/effect/meteor/aquila_ice/proc/chill_area()
	var/turf/center = get_turf(src)
	if(!center)
		return
	for(var/turf/open/T in range(chill_range, center))
		if(isspaceturf(T))
			continue
		T.MakeSlippery(TURF_WET_PERMAFROST, 30 SECONDS)
		for(var/mob/living/victim in T)
			victim.adjust_bodytemperature(-chill_amount)

/obj/effect/meteor/aquila_ice/big
	name = "lodowa bryła komety"
	desc = "Ogromny blok lodu i skał oderwany od jądra komety."
	icon_state = "large"
	hits = 6
	hitpwr = EXPLODE_HEAVY
	heavy = 1
	dropamt = 4
	threat = 8
	chill_range = 2
	chill_amount = 50

/obj/effect/meteor/aquila_ice/big/explode_ice()
	explosion(src.loc, 0, 1, 3, 4, 0)

/obj/effect/meteor/aquila_ice/dust
	name = "lodowy pył komety"
	desc = "Chmura drobnych kryształków lodu, wciąż dość szybka, żeby przebić szybę."
	icon_state = "dust"
	pass_flags = PASSTABLE | PASSGRILLE
	hits = 1
	hitpwr = EXPLODE_LIGHT
	meteorsound = 'sound/weapons/gunshot_smg.ogg'
	dropamt = 1
	threat = 1
	chill_range = 0
	chill_amount = 15

/obj/effect/meteor/aquila_ice/dust/explode_ice()
	return

/datum/round_event_control/aquila_hex_comet_expulsion
	name = "Wyrzut materii z komety"
	typepath = /datum/round_event/aquila_hex_comet_expulsion
	weight = 10
	min_players = 10
	max_occurrences = 2
	earliest_start = 25 MINUTES

/datum/round_event/aquila_hex_comet_expulsion
	announceWhen = 1
	startWhen = 30 // około minuty na przygotowanie
	endWhen = 31
	/// Ile odłamków komety trafi w statek (jak wycelowane odłamki w oryginale)
	var/impacts_left = 0
	/// Tick, w którym trafia kolejny odłamek
	var/next_impact = 0
	/// Meteory sypiące się przy każdym trafieniu
	var/static/list/comet_meteors = list(
		/obj/effect/meteor/aquila_ice = 5,
		/obj/effect/meteor/aquila_ice/big = 2,
		/obj/effect/meteor/medium = 2,
		/obj/effect/meteor/big = 1,
	)

/datum/round_event/aquila_hex_comet_expulsion/setup()
	impacts_left = rand(2, 5)
	endWhen = startWhen + impacts_left * 5

/datum/round_event/aquila_hex_comet_expulsion/announce(fake)
	priority_announce("Uwaga, czujniki dalekiego zasięgu wykryły nieprzewidziany wyrzut materii z komety na kursie kolizyjnym z [station_name()]. \
		Cała załoga: stan gotowości obronnej. Zespoły kontroli uszkodzeń mają być gotowe do łatania wyrw w kadłubie.", "Czujniki obiektów dalekiego zasięgu", ANNOUNCER_METEORS)

/datum/round_event/aquila_hex_comet_expulsion/start()
	next_impact = activeFor
	comet_impact()

/datum/round_event/aquila_hex_comet_expulsion/tick()
	if(activeFor >= next_impact)
		comet_impact()

/// Jeden odłamek trafia w statek: na każdym poziomie okrętu sypie się 3 albo 5 meteorów
/datum/round_event/aquila_hex_comet_expulsion/proc/comet_impact()
	if(impacts_left <= 0)
		return
	impacts_left--
	next_impact = activeFor + 5
	for(var/z in aquila_hex_ship_zlevels())
		spawn_meteors(pick(3, 5), comet_meteors, z)
