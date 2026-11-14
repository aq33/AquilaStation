// AQUILA - harmoniczne fale grawitacyjne: przez 10–15 min tarcze okrętu tracą energię szybciej, niż zwykle się ładują (port z CEV-Eris code/game/gamemodes/events/space_weather.dm)

/// Jaka część maksymalnej wytrzymałości tarczy znika co tick (2 s). Przy domyślnym podziale mocy 50/50 generator odnawia ok. 0,5%,
/// więc tarcza traci netto ok. 0,5% na tick, czyli całość w ~7 min, chyba że inżynieria przerzuci moc na regenerację.
#define HARMONIC_SURGE_DRAIN_FRACTION 0.01
/// Najmniejszy ubytek na tick, żeby słaba tarcza też coś traciła
#define HARMONIC_SURGE_MIN_DRAIN 5

/datum/round_event_control/aquila_hex_harmonic_surge
	name = "Harmonic Feedback Surge"
	typepath = /datum/round_event/aquila_hex_harmonic_surge
	weight = 10
	min_players = 0
	max_occurrences = 2
	earliest_start = 10 MINUTES

/datum/round_event/aquila_hex_harmonic_surge
	announceWhen = 3
	startWhen = 1

/datum/round_event/aquila_hex_harmonic_surge/setup()
	endWhen = rand(300, 450) // 10–15 min

/datum/round_event/aquila_hex_harmonic_surge/announce(fake)
	priority_announce("Okręt przechodzi przez silne fronty fal grawitacyjnych. Przez pewien czas będą poważnie zakłócać tarcze kadłuba.", "Harmoniczne fale grawitacyjne", ANNOUNCER_GRANOMALIES)

/datum/round_event/aquila_hex_harmonic_surge/tick()
	drain_shield(aquila_hex_shield_data(SSstar_system.find_main_overmap()))

/datum/round_event/aquila_hex_harmonic_surge/end()
	priority_announce("Fronty fal grawitacyjnych minęły.", "Harmoniczne fale grawitacyjne")

/// Zabiera tarczy część energii. Zwraca, ile ubyło.
/datum/round_event/aquila_hex_harmonic_surge/proc/drain_shield(list/shield)
	if(!islist(shield) || shield["integrity"] <= 0)
		return 0
	var/drain = min(shield["integrity"], max(HARMONIC_SURGE_MIN_DRAIN, shield["max_integrity"] * HARMONIC_SURGE_DRAIN_FRACTION))
	shield["integrity"] -= drain
	return drain

/// Lista stanu tarczy okrętu ("integrity", "max_integrity"): generator tarczy albo symulowane tarcze okrętów AI
/proc/aquila_hex_shield_data(obj/structure/overmap/ship)
	if(!ship?.shields)
		return
	if(istype(ship.shields, /obj/machinery/shield_generator))
		var/obj/machinery/shield_generator/generator = ship.shields
		return generator.shield
	var/datum/component/overmap_shields/component = ship.shields
	if(istype(component))
		return component.shield

#undef HARMONIC_SURGE_DRAIN_FRACTION
#undef HARMONIC_SURGE_MIN_DRAIN
