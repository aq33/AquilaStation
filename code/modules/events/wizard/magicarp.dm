/datum/round_event_control/wizard/magicarp //these fish is loaded
	name = "Magicarp"
	weight = 1
	typepath = /datum/round_event/wizard/magicarp
	max_occurrences = 1
	earliest_start = 0 MINUTES

/datum/round_event/wizard/magicarp
	announceWhen	= 3
	startWhen = 50

/datum/round_event/wizard/magicarp/setup()
	startWhen = rand(40, 60)

/datum/round_event/wizard/magicarp/announce(fake)
	priority_announce("W pobliżu [station_name()] wykryto nieznane magiczne istoty, prosimy czekać na dalsze informacje.", "Alarm - formy życia", SSstation.announcer.get_rand_alert_sound())

/datum/round_event/wizard/magicarp/start()
	for(var/obj/effect/landmark/carpspawn/C in GLOB.landmarks_list)
		if(prob(5))
			new /mob/living/basic/carp/magic/chaos(C.loc) // AQ EDIT - basic moby
		else
			new /mob/living/basic/carp/magic(C.loc) // AQ EDIT - basic moby

// AQ EDIT - magikarpie są basic mobami (aquila\code\modules\mob\living\basic\space_fauna\carp\magicarp.dm)
