/datum/station_trait/bananium_shipment
	name = "Dostawa bananium"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	report_message = "Plotka głosi, że planeta klaunów wysyła paczki pomocowe klaunom w tym układzie"
	trait_to_give = STATION_TRAIT_BANANIUM_SHIPMENTS

/datum/station_trait/ian_adventure
	name = "Przygoda Iana"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = FALSE
	report_message = "Ian wyruszył na wyprawę gdzieś po stacji."

/datum/station_trait/ian_adventure/on_round_start()
	for(var/mob/living/simple_animal/pet/dog/corgi/dog in GLOB.mob_list)
		if(!(istype(dog, /mob/living/simple_animal/pet/dog/corgi/Ian) || istype(dog, /mob/living/simple_animal/pet/dog/corgi/puppy/Ian)))
			continue

		// The extended safety checks at time of writing are about chasms and lava
		// if there are any chasms and lava on stations in the future, woah
		var/turf/current_turf = get_turf(dog)
		var/turf/adventure_turf = find_safe_turf(extended_safety_checks = TRUE, dense_atoms = FALSE)

		// Poof!
		do_smoke(location=current_turf)
		dog.forceMove(adventure_turf)
		do_smoke(location=adventure_turf)


/datum/station_trait/glitched_pdas
	name = "Usterka PDA"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 8
	show_in_report = TRUE
	report_message = "Coś jest nie tak z wydanymi wam na tę zmianę PDA. Ale nic strasznego."
	trait_to_give = STATION_TRAIT_PDA_GLITCHED

/datum/station_trait/announcement_medbot
	name = "Ogłoszenia „Systemu”"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = TRUE
	report_message = "Nasz system ogłoszeń przechodzi obecnie planową konserwację. Na szczęście mamy zapasowy."
	blacklist = list(
		/datum/station_trait/announcement_intern,
		/datum/station_trait/announcement_baystation
		)

/datum/station_trait/announcement_medbot/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/medbot

/datum/station_trait/announcement_baystation
	name = "Spiker: taśma archiwalna"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = TRUE
	report_message = "Zgubiliśmy główną taśmę z nagraniami głosowymi systemu ogłoszeń. Znaleźliśmy jednak starszą kopię zapasową."
	blacklist = list(/datum/station_trait/announcement_intern,
	/datum/station_trait/announcement_medbot
	)

/datum/station_trait/announcement_baystation/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/baystation
