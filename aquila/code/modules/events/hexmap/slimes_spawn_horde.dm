// AQUILA - Horda szlamów: ostrzeżenie o stworach w wentylacji, a po chwili z kilku wentylacji wypełza 4-8 wściekłych dorosłych szlamów (port z space-wizards/space-station-14 Resources/Prototypes/GameRules/events.yml, SlimesSpawnHorde)
// SS14 announces creatures in the vents and spawns 4-8 angry adult slimes (blue, green or yellow) at random vents
// (VentHordeRule). Ours uses our xenobiology slimes (/mob/living/simple_animal/slime) as rabid adults of the same three
// colours, which attack anything near them until disciplined, fed or killed. Unlike xenobiology slimes they do not grow,
// split or multiply: a killed horde slime just dies (no splitting into a baby), so the horde does not overrun the ship.
// Vents in maintenance are preferred, at most two slimes per vent. No vents on the ship: the event logs and stops.

/datum/round_event_control/aquila_hex_slimes_spawn_horde
	name = "Horda szlamów"
	typepath = /datum/round_event/aquila_hex_slimes_spawn_horde
	weight = 5
	min_players = 15
	max_occurrences = 1
	earliest_start = 20 MINUTES

/datum/round_event/aquila_hex_slimes_spawn_horde
	fakeable = FALSE
	announceWhen = 1
	startWhen = 6 // ok. 10 s po ostrzeżeniu
	/// Pola wentylacji wybrane w setup()
	var/list/vent_turfs

/datum/round_event/aquila_hex_slimes_spawn_horde/setup()
	vent_turfs = aquila_hex_vent_turfs()
	if(!length(vent_turfs))
		log_game("Slimes Spawn Horde: no open vents on the ship, cancelling the event.")
		kill()

/datum/round_event/aquila_hex_slimes_spawn_horde/announce(fake)
	if(!length(vent_turfs))
		return
	priority_announce("Uwaga. W systemie wentylacji okrętu wykryto dużą liczbę nieznanych form życia. Kontakt z nimi grozi oblepieniem i zjedzeniem. Zalecamy ostrożność i trzymanie się z dala od kratek wentylacyjnych.", "Alarm biologiczny", ANNOUNCER_ALIENS)

/datum/round_event/aquila_hex_slimes_spawn_horde/start()
	var/list/slimes = spawn_slimes(vent_turfs, rand(4, 8))
	if(!length(slimes))
		return kill()
	var/mob/living/simple_animal/slime/aquila_hex_horde/first = slimes[1]
	announce_to_ghosts(first)
	message_admins("Horda szlamów: z wentylacji wychodzi [length(slimes)] szlamów, np. w [ADMIN_VERBOSEJMP(first)].")
	log_game("Slimes Spawn Horde: [length(slimes)] rabid slimes spawned from the vents.")

/datum/round_event/aquila_hex_slimes_spawn_horde/kill()
	vent_turfs = null
	return ..()

/// Stawia count wściekłych dorosłych szlamów przy wentylacjach (najwyżej dwa przy jednej), zwraca listę szlamów
/datum/round_event/aquila_hex_slimes_spawn_horde/proc/spawn_slimes(list/turfs, count)
	var/list/mob/living/simple_animal/slime/aquila_hex_horde/slimes = list()
	. = slimes
	var/list/free = list()
	for(var/turf/T as anything in turfs)
		if(isturf(T) && !QDELETED(T))
			free += T
	var/list/used = list()
	while(length(slimes) < count && length(free))
		var/turf/spot = pick(free)
		used[spot]++
		if(used[spot] >= 2)
			free -= spot
		var/mob/living/simple_animal/slime/aquila_hex_horde/slime = new(spot, pick("blue", "green", "yellow"), TRUE)
		slime.rabid = TRUE
		slime.visible_message("<span class='warning'>[slime] wypełza z wentylacji!</span>")
		slimes += slime

/// Szlam z hordy: nie rośnie, nie dzieli się i po śmierci ginie zwyczajnie, zamiast rozpaść się na młodego szlama
/mob/living/simple_animal/slime/aquila_hex_horde

/mob/living/simple_animal/slime/aquila_hex_horde/death(gibbed)
	if(stat == DEAD)
		return
	var/was_adult = is_adult
	is_adult = FALSE // dorosły szlam w death() rodzi nowego szlama i wstaje jako młody
	. = ..()
	is_adult = was_adult
	regenerate_icons()

/mob/living/simple_animal/slime/aquila_hex_horde/Reproduce()
	to_chat(src, "<span class='warning'>Nie mogę się rozmnażać...</span>")

/mob/living/simple_animal/slime/aquila_hex_horde/Evolve()
	to_chat(src, "<span class='warning'>Nie mogę już urosnąć...</span>")
