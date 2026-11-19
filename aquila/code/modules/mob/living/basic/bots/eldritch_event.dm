// Event „Eldritchowe boty”: na okręcie pojawia się kilka przeklętych botów z Goona (disasters.dm), które po minucie
// same wybuchają, a z rzadka zbzikowany Secbuddy (Evilbot), który zostaje na dobre.

/datum/round_event_control/aquila_eldritch_bots
	name = "Eldritch Bots"
	typepath = /datum/round_event/aquila_eldritch_bots
	weight = 5
	max_occurrences = 1
	earliest_start = 20 MINUTES
	min_players = 10

/datum/round_event/aquila_eldritch_bots
	announceWhen = 5
	startWhen = 1
	/// Ile botów się pojawi
	var/bot_count = 4

/datum/round_event/aquila_eldritch_bots/setup()
	bot_count = rand(3, 5)

/datum/round_event/aquila_eldritch_bots/announce(fake)
	priority_announce("Wykryto nieeuklidesowe zakłócenia w sieci sterowania botów. Część jednostek może zachowywać się... niewłaściwie. Prosimy zachować ostrożność.", "Alarm: Anomalia robotyki", ANNOUNCER_GRANOMALIES)

/datum/round_event/aquila_eldritch_bots/start()
	var/static/list/eldritch_types = list(
		/mob/living/basic/bot/secbot/eldritch,
		/mob/living/basic/bot/medbot/eldritch,
		/mob/living/basic/bot/firebot/eldritch,
		/mob/living/basic/bot/cleanbot/eldritch,
	)
	var/list/turfs = get_safe_random_station_turfs(amount = bot_count + 1)
	for(var/i in 1 to min(bot_count, length(turfs)))
		var/bot_type = pick(eldritch_types)
		var/mob/living/basic/bot/spawned = new bot_type(turfs[i])
		announce_to_ghosts(spawned)
	if(prob(25) && length(turfs) > bot_count)
		var/mob/living/basic/bot/secbuddy/evilbot = new(turfs[bot_count + 1])
		announce_to_ghosts(evilbot)
	log_game("Eldritch bots event spawned [bot_count] bots.")
