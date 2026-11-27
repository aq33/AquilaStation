// AQUILA - Rozdarcie klaunów: wariant rozdarcia wymiarów, z którego zamiast piekielnych stworów wysypują się klauny i honkusie z honkmunkulusem na końcu (port z ParadiseSS13/Paradise code/modules/events/tear_honk.dm)
// Paradise's honk tear is the dimensional tear with clowns and clown goblins and a cluwne goblin leader, announced
// with an air horn. Ours is our tear (tear.dm) with our clown basic mobs: clowns, honklings (our nearest thing to clown
// goblins), clownanas and lube clowns, and a honkmunculus leader instead of the cluwne goblin we do not have. They keep
// their clown AI, which only hits back, so it is chaos more than danger. The tear is the same bag of holding sprite
// tinted pink. Like the dimensional tear it opens on a free safe floor of a safe room and closes on its own.

/datum/round_event_control/aquila_hex_tear_honk
	name = "Rozdarcie klaunów"
	typepath = /datum/round_event/aquila_hex_tear/honk
	weight = 5
	min_players = 5
	max_occurrences = 1
	earliest_start = 15 MINUTES

/datum/round_event/aquila_hex_tear/honk
	tear_type = /obj/effect/aquila_hex_tear/honk
	announce_title = "Alarm honkomalii"

/datum/round_event/aquila_hex_tear/honk/announce_text(area_name)
	return "Czujniki wykryły honkomalię: rozdarcie w tkance zdrowego rozsądku. Przewidywane miejsce: [area_name]. Prosimy zabezpieczyć skórki od bananów i nie dawać się sprowokować."

/datum/round_event/aquila_hex_tear/honk/announce(fake)
	. = ..()
	if(tear_turf)
		for(var/mob/listener in GLOB.player_list)
			if(!isnewplayer(listener) && listener.can_hear())
				SEND_SOUND(listener, sound('sound/items/airhorn.ogg', volume = 50))

/obj/effect/aquila_hex_tear/honk
	name = "rozdarcie klaunów"
	desc = "Rozdarcie w tkance zdrowego rozsądku. Po drugiej stronie ktoś trąbi."
	color = "#ff7ad9"
	light_color = LIGHT_COLOR_PINK
	possible_mobs = list(
		/mob/living/basic/clown,
		/mob/living/basic/clown,
		/mob/living/basic/clown/honkling,
		/mob/living/basic/clown/honkling,
		/mob/living/basic/clown/banana,
		/mob/living/basic/clown/lube,
	)
	leader_type = /mob/living/basic/clown/clownhulk/honkmunculus
	open_sound = 'sound/items/bikehorn.ogg'

/obj/effect/aquila_hex_tear/honk/rift_faction()
	return "clown" // jak gniazdo klaunów (/obj/structure/spawner/clown)
