/datum/overmap_objective/cargo/transfer/specimen
	name = "Dostarcz okaz"
	desc = "Dostarcz konkretny okaz przekazany w ramach celu"
	crate_name = "Bezpieczny transfer okazu"

/datum/overmap_objective/cargo/transfer/specimen/New()
	var/picked = pick( list (
		// Dangerous specimens
		/mob/living/simple_animal/slime/random,
		/mob/living/basic/alien, // AQ EDIT - basic moby
		/mob/living/simple_animal/hostile/swarmer,
		/mob/living/simple_animal/hostile/carp,

		// Benign specimens
		/mob/living/basic/lizard, // AQ EDIT - basic moby
		/mob/living/basic/pet/dog/corgi, // AQ EDIT - basic moby
		/mob/living/basic/pet/dog/bullterrier, // AQ EDIT - basic moby
		/mob/living/basic/pet/cat, // AQ EDIT - basic moby
		/mob/living/basic/pet/fox, // AQ EDIT - basic moby
		/mob/living/basic/pet/hamster, // AQ EDIT - basic moby
		/mob/living/basic/pet/penguin/emperor, // AQ EDIT - basic moby
		/mob/living/basic/chicken, // AQ EDIT - basic moby
		/mob/living/simple_animal/parrot,
		/mob/living/basic/butterfly, // AQ EDIT - basic moby
		/mob/living/basic/crab, // AQ EDIT - basic moby
		/mob/living/basic/cow // AQ EDIT - basic moby
	) )

	var/datum/freight_type/single/specimen/C = new /datum/freight_type/single/specimen( picked )
	C.send_prepackaged_item = TRUE
	C.allow_replacements = FALSE // Once a packaged specimen gets out it may be too large to fit in a crate, or it may get killed. Prevents gamemode softlocks from incomplete objectives
	C.overmap_objective = src
	freight_type_group = new( list( C ) )
