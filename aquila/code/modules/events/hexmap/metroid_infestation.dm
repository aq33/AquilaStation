// AQUILA - Plaga dzikich szlamów: z wentylacji wypełza kilka naładowanych energią młodych szlamów, które rzucają się na ludzi i wysysają ich, ale nie rosną ani się nie dzielą (port z CHOMPStation2/CHOMPStation2 modular_chomp/code/modules/event/metroid_infestation.dm)
// CHOMP spawns 2-4 (times severity) juvenile metroids of six weighted kinds from the vents; they latch on and drain their
// victims, can grow and even moult into queens. We have no metroids, so ours are our xenobiology slimes on the horde
// slime of E4 (slimes_spawn_horde.dm): babies of four "energetic" colours with a full electric charge (powerlevel 5, so
// they shock whoever hits them), rabid from the start. Like the horde they never grow, split or turn into a new baby when
// killed, so 3-6 slimes are all the event ever makes. Announced only after they are out; about ten minutes later the
// sensors name the rooms where some still live, as in CHOMP's end().

/datum/round_event_control/aquila_hex_metroid_infestation
	name = "Plaga dzikich szlamów"
	typepath = /datum/round_event/aquila_hex_metroid_infestation
	weight = 8
	min_players = 15
	max_occurrences = 1
	earliest_start = 25 MINUTES

/datum/round_event/aquila_hex_metroid_infestation
	fakeable = FALSE
	startWhen = 1
	announceWhen = 10
	endWhen = 300
	/// Słabe referencje do wypuszczonych szlamów
	var/list/slimes = list()

/datum/round_event/aquila_hex_metroid_infestation/start()
	var/list/spawned = spawn_slimes(aquila_hex_vent_turfs(), rand(3, 6))
	if(!length(spawned))
		log_game("Metroid Infestation: no open vents on the ship, cancelling the event.")
		return kill()
	var/mob/living/first = spawned[1]
	announce_to_ghosts(first)
	message_admins("Plaga dzikich szlamów: z wentylacji wychodzi [length(spawned)] szlamów, np. w [ADMIN_VERBOSEJMP(first)].")
	log_game("Metroid Infestation: [length(spawned)] wild slimes spawned from the vents.")

/datum/round_event/aquila_hex_metroid_infestation/announce(fake)
	if(!length(aquila_hex_living_areas(slimes)))
		return
	priority_announce("Na pokład dostały się wysokoenergetyczne formy życia. Rzucają się na ludzi i wysysają z nich siły, a uderzone razią prądem. Zachowajcie czujność i słuchajcie poleceń ochrony.", "Alarm biologiczny", ANNOUNCER_ALIENS)

/datum/round_event/aquila_hex_metroid_infestation/end()
	var/list/areas = aquila_hex_living_areas(slimes)
	if(length(areas))
		priority_announce("Czujniki zawęziły miejsca pobytu pozostałych form życia do: [english_list(areas)].", "Alarm biologiczny")

/datum/round_event/aquila_hex_metroid_infestation/kill()
	slimes = null
	return ..()

/// Stawia count dzikich szlamów przy wentylacjach (po jednym przy każdej), zwraca listę szlamów
/datum/round_event/aquila_hex_metroid_infestation/proc/spawn_slimes(list/turfs, count)
	. = aquila_hex_spawn_on_turfs(turfs, count, /mob/living/simple_animal/slime/aquila_hex_horde/wild, 1, "%MOB wypełza z kratki wentylacyjnej, trzeszcząc od ładunku!")
	for(var/mob/living/simple_animal/slime/aquila_hex_horde/wild/slime as anything in .)
		LAZYADD(slimes, WEAKREF(slime))

/// Dziki szlam: młody, naładowany i wściekły od początku; jak szlam z hordy nie rośnie i się nie dzieli
/mob/living/simple_animal/slime/aquila_hex_horde/wild

/mob/living/simple_animal/slime/aquila_hex_horde/wild/Initialize(mapload, new_colour, new_is_adult)
	. = ..(mapload, pick("yellow", "dark blue", "bluespace", "cerulean"), FALSE)
	rabid = TRUE
	powerlevel = 5
