// AQUILA - Kapsuła ratunkowa z 1-2 rozbitkami (rola dla duchów), czasem z włamywaczem udającym rozbitka (port z Aurora.3 code/modules/events/rescue_pod.dm)
// Aurora enables a ghost spawner for survivors of an escape pod on a nearby planet; we have no away sites for it,
// so the pod lands on the ship like our stray cargo pod (its landing area and floor checks are reused through parent_type).
// Ghosts are polled before the pod comes in, like the lost crew body; without volunteers the pod lands with supplies only.
// One in three pods is the burglar variant: a single castaway with burglary tools, still a plain ghost role (no antag datum).
// Announced 66% of the time, the burglar pod only 22% (33% of 66%, like Aurora). Once per round, like Aurora.

/datum/round_event_control/aquila_hex_rescue_pod
	name = "Kapsuła ratunkowa"
	typepath = /datum/round_event/aquila_hex_rescue_pod
	weight = 10
	min_players = 5
	max_occurrences = 1
	earliest_start = 20 MINUTES

/datum/round_event/aquila_hex_rescue_pod
	parent_type = /datum/round_event/aquila_stray_cargo
	fakeable = FALSE
	/// Is this the burglar variant
	var/burglar = FALSE
	/// How many castaways the pod can carry
	var/castaway_count = 1

/datum/round_event/aquila_hex_rescue_pod/setup()
	burglar = prob(33)
	castaway_count = burglar ? 1 : rand(1, 2)
	announceChance = burglar ? 22 : 66
	return ..()

/datum/round_event/aquila_hex_rescue_pod/announce(fake)
	if(!landing_zone)
		return
	priority_announce("Sensory okrętu wykryły kapsułę ratunkową na kursie kolizyjnym z okrętem. Przewidywane miejsce lądowania: [impact_area?.name || "nieznane"]. Ewentualnych rozbitków należy przyjąć na pokład i udzielić im pomocy.", "Sensory okrętu")

/datum/round_event/aquila_hex_rescue_pod/start()
	if(!landing_zone)
		return kill()
	INVOKE_ASYNC(src, PROC_REF(launch_pod))

/// Polls ghosts, then sends the pod with the castaways that signed up
/datum/round_event/aquila_hex_rescue_pod/proc/launch_pod()
	var/list/chosen = poll_castaways()
	if(!landing_zone || is_blocked_turf(landing_zone, TRUE)) // something was built there during the poll
		landing_zone = get_landing_zone()
		if(!landing_zone)
			return
	var/obj/structure/closet/supplypod/pod = new
	new /obj/item/storage/box/survival(pod)
	new /obj/item/flashlight(pod)
	for(var/mob/dead/observer/ghost in chosen)
		if(!ghost.client)
			continue
		var/mob/living/carbon/human/castaway = make_castaway(pod, burglar)
		var/datum/mind/player_mind = new /datum/mind(ghost.key)
		player_mind.active = TRUE
		player_mind.transfer_to(castaway)
		player_mind.special_role = burglar ? "Rescue Pod Burglar" : "Rescue Pod Castaway"
		greet_castaway(castaway)
		message_admins("[ADMIN_LOOKUPFLW(castaway)] zostaje [burglar ? "włamywaczem-rozbitkiem" : "rozbitkiem"] z kapsuły ratunkowej.")
		log_game("[key_name(castaway)] was spawned as a [burglar ? "burglar " : ""]rescue pod castaway at [AREACOORD(landing_zone)].")
	var/obj/effect/pod_landingzone/landing_marker = new(landing_zone, pod)
	announce_to_ghosts(landing_marker)

/// Asks the ghosts, returns the list of chosen observers
/datum/round_event/aquila_hex_rescue_pod/proc/poll_castaways()
	var/datum/poll_config/config = new()
	config.question = burglar ? "Czy chcesz zagrać jako włamywacz udający rozbitka z kapsuły ratunkowej?" : "Czy chcesz zagrać jako rozbitek z kapsuły ratunkowej?"
	config.check_jobban = BAN_ROLE_ALL_GHOST
	config.poll_time = 20 SECONDS
	config.role_name_text = burglar ? "włamywacz-rozbitek" : "rozbitek"
	config.amount_to_pick = castaway_count
	var/result = SSpolling.poll_ghost_candidates(config)
	if(islist(result))
		return result
	return result ? list(result) : list()

/// Makes a castaway body (no player yet) in `location`
/datum/round_event/aquila_hex_rescue_pod/proc/make_castaway(atom/location, as_burglar)
	var/mob/living/carbon/human/castaway = new(location)
	randomize_human(castaway)
	castaway.dna.update_dna_identity()
	castaway.equipOutfit(as_burglar ? /datum/outfit/aquila_hex_castaway/burglar : /datum/outfit/aquila_hex_castaway)
	castaway.adjustBruteLoss(rand(5, 15)) // a rough landing after days in the pod
	return castaway

/datum/round_event/aquila_hex_rescue_pod/proc/greet_castaway(mob/living/carbon/human/castaway)
	if(burglar)
		to_chat(castaway, "<span class='big bold'>Jesteś włamywaczem, który ucieka kapsułą ratunkową i udaje rozbitka.</span>")
		to_chat(castaway, "<span class='notice'>Kapsuła zaraz wyląduje na okręcie Nanotrasen. Masz narzędzia do włamań i pustą kieszeń. \
			Możesz kraść i oszukiwać, ale nie jesteś antagonistą: nie zabijaj i nie sabotuj okrętu.</span>")
		castaway.mind?.store_memory("Jesteś włamywaczem udającym rozbitka z kapsuły ratunkowej.")
		return
	to_chat(castaway, "<span class='big bold'>Jesteś rozbitkiem, który przetrwał w kapsule ratunkowej.</span>")
	to_chat(castaway, "<span class='notice'>Twój statek zniszczono kilka dni temu. Kapsuła zaraz wyląduje na okręcie Nanotrasen. \
		Opowiedz załodze, co się stało, i postaraj się przeżyć. Nie jesteś antagonistą.</span>")
	castaway.mind?.store_memory("Jesteś rozbitkiem z kapsuły ratunkowej.")

/datum/outfit/aquila_hex_castaway
	name = "Rescue Pod Castaway"
	uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/sneakers/black
	suit = /obj/item/clothing/suit/space/fragile
	head = /obj/item/clothing/head/helmet/space/fragile
	back = /obj/item/storage/backpack
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/flashlight = 1,
	)

/datum/outfit/aquila_hex_castaway/burglar
	name = "Rescue Pod Burglar"
	uniform = /obj/item/clothing/under/color/black
	gloves = /obj/item/clothing/gloves/color/fyellow
	mask = /obj/item/clothing/mask/balaclava
	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
		/obj/item/flashlight = 1,
		/obj/item/crowbar = 1,
		/obj/item/screwdriver = 1,
		/obj/item/multitool = 1,
	)
