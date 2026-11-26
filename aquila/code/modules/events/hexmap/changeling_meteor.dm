// AQUILA - Meteor zmiennokształtnego: z ogona komety w okręt uderza mięsisty meteor, z którego wychodzi zmiennokształtny z duszą gracza (port z Monkestation/Monkestation2.0 code/modules/events/ghost_role/changeling_event.dm i code/modules/meteors/meteor_changeling.dm)
// Monkestation polls ghosts, makes a space changeling (its own antag datum with void adaption and an arm blade, a
// flesh space suit) and throws it at the station in a changeling meteor, which drops it on impact and throws it at the
// station if it misses. We have no space changeling datum, void adaption or flesh suit, so ours is our ordinary
// changeling (/datum/antagonist/changeling, own objectives) in a fragile space suit with an oxygen tank, in a meaty
// meteor variant that does not wreck the turfs it flies through, lets the changeling out when it hits something or
// stops, and throws it towards its target turf on the ship. The poll checks the changeling ban and the ghost role switch.

/datum/round_event_control/aquila_hex_changeling_meteor
	name = "Meteor zmiennokształtnego"
	typepath = /datum/round_event/ghost_role/aquila_hex_changeling_meteor
	weight = 5
	min_players = 20
	max_occurrences = 1
	earliest_start = 30 MINUTES

/datum/round_event/ghost_role/aquila_hex_changeling_meteor
	minimum_required = 1
	role_name = "Zmiennokształtny z meteoru"
	fakeable = FALSE

/datum/round_event/ghost_role/aquila_hex_changeling_meteor/spawn_role()
	var/list/candidates = get_candidates(ROLE_CHANGELING, null)
	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS
	var/turf/target = aquila_hex_random_ship_turf()
	var/turf/start = meteor_start(target)
	if(!target || !start)
		return MAP_ERROR
	var/mob/dead/selected = pick_n_take(candidates)
	var/mob/living/carbon/human/changeling = make_changeling(start, selected.key)
	if(!changeling)
		return NOT_ENOUGH_PLAYERS
	launch(changeling, start, target)
	message_admins("[ADMIN_LOOKUPFLW(changeling)] zostaje zmiennokształtnym w meteorze lecącym na [ADMIN_VERBOSEJMP(target)].")
	log_game("[key_name(changeling)] was spawned as a meteor changeling by an event, aimed at [AREACOORD(target)].")
	spawned_mobs += changeling
	return SUCCESSFUL_SPAWN

/// Pole kosmosu na brzegu mapy po losowej stronie poziomu target, z którego wyleci meteor
/datum/round_event/ghost_role/aquila_hex_changeling_meteor/proc/meteor_start(turf/target)
	if(!isturf(target))
		return null
	for(var/attempt in 1 to 10)
		var/turf/start = spaceDebrisStartLoc(pick(GLOB.cardinals), target.z)
		if(isspaceturf(start))
			return start

/// Ciało zmiennokształtnego na spot; z kluczem gracza dostaje jego umysł i antagonistę. Bez klucza (test) samo ciało.
/datum/round_event/ghost_role/aquila_hex_changeling_meteor/proc/make_changeling(turf/spot, player_key)
	if(!isturf(spot))
		return null
	var/mob/living/carbon/human/changeling = new(spot)
	randomize_human(changeling)
	changeling.dna.update_dna_identity()
	changeling.equipOutfit(/datum/outfit/aquila_hex_meteor_changeling)
	if(!player_key)
		return changeling
	var/datum/mind/player_mind = new /datum/mind(player_key)
	player_mind.active = TRUE
	player_mind.transfer_to(changeling)
	player_mind.special_role = ROLE_CHANGELING
	player_mind.add_antag_datum(/datum/antagonist/changeling)
	to_chat(changeling, "<span class='changeling big'>Lecimy w mięsistym meteorze prosto na okręt Nanotrasen!</span>")
	to_chat(changeling, "<span class='changeling'>Nie jesteśmy częścią załogi i nikt nas tu nie zna. Po uderzeniu musimy sami dostać się do środka okrętu.</span>")
	SEND_SOUND(changeling, sound('sound/magic/mutate.ogg'))
	return changeling

/// Wkłada ciało do meteoru i wystrzeliwuje go ze start na target; zwraca meteor
/datum/round_event/ghost_role/aquila_hex_changeling_meteor/proc/launch(mob/living/carbon/human/changeling, turf/start, turf/target)
	if(QDELETED(changeling) || !isturf(start))
		return null
	var/obj/effect/meteor/meaty/aquila_hex_changeling/meteor = new(start, target)
	changeling.forceMove(meteor)
	return meteor

/datum/outfit/aquila_hex_meteor_changeling
	name = "Meteor Changeling"
	uniform = /obj/item/clothing/under/color/black
	shoes = /obj/item/clothing/shoes/sneakers/black
	suit = /obj/item/clothing/suit/space/fragile
	head = /obj/item/clothing/head/helmet/space/fragile
	mask = /obj/item/clothing/mask/breath
	suit_store = /obj/item/tank/internals/oxygen
	internals_slot = ITEM_SLOT_SUITSTORE
	back = /obj/item/storage/backpack
	backpack_contents = list(/obj/item/storage/box/survival = 1)

/// Mięsisty meteor, w którym leci zmiennokształtny: nie niszczy pól, przez które leci, a po uderzeniu albo zatrzymaniu wypuszcza pasażera
/obj/effect/meteor/meaty/aquila_hex_changeling
	name = "niepokojąco mięsisty meteor"
	desc = "Ciasno zbita masa mięsa i skóry, która pulsuje życiem."
	color = "#b04050"
	heavy = FALSE
	hits = 1
	hitpwr = EXPLODE_LIGHT
	threat = 100
	/// Pole, na które ma trafić pasażer
	var/turf/landing_target

/obj/effect/meteor/meaty/aquila_hex_changeling/Initialize(mapload, target)
	landing_target = target
	flags_1 |= ADMIN_SPAWNED_1 // pasażer nie dostaje za darmo osiągnięcia za obejrzenie meteoru
	return ..()

/obj/effect/meteor/meaty/aquila_hex_changeling/ram_turf(turf/T)
	return // bez ex_act na polach po drodze, żeby nie trafić własnego pasażera

/obj/effect/meteor/meaty/aquila_hex_changeling/Destroy()
	release_passengers()
	landing_target = null
	return ..()

/// Wypuszcza pasażerów na pole meteoru; w kosmosie rzuca ich w stronę celu
/obj/effect/meteor/meaty/aquila_hex_changeling/proc/release_passengers()
	var/turf/here = get_turf(src)
	if(!here)
		here = landing_target
	if(!here)
		return
	for(var/mob/living/passenger in contents)
		passenger.forceMove(here)
		playsound(here, 'sound/effects/splat.ogg', 50, TRUE)
		passenger.visible_message("<span class='warning'>[passenger] wypada z rozrywającego się meteoru!</span>", "<span class='changeling'>Wyrywamy się z meteoru!</span>")
		if(isspaceturf(here) && landing_target)
			passenger.throw_at(landing_target, 3, 2)
