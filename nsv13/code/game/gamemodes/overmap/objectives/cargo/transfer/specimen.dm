/datum/overmap_objective/cargo/transfer/specimen
	name = "Dostarcz okaz"
	desc = "Dostarcz konkretny okaz przekazany w ramach celu"
	crate_name = "Bezpieczny transfer okazu"

/datum/overmap_objective/cargo/transfer/specimen/New()
	var/picked = pick( list (
		// Dangerous specimens
		/mob/living/simple_animal/slime/random,
		/mob/living/simple_animal/hostile/alien,
		/mob/living/simple_animal/hostile/swarmer,
		/mob/living/simple_animal/hostile/carp,

		// Benign specimens
		/mob/living/simple_animal/hostile/lizard,
		/mob/living/simple_animal/pet/dog/corgi,
		/mob/living/simple_animal/pet/dog/bullterrier,
		/mob/living/simple_animal/pet/cat,
		/mob/living/simple_animal/pet/fox,
		/mob/living/simple_animal/pet/hamster,
		/mob/living/simple_animal/pet/penguin/emperor,
		/mob/living/simple_animal/chicken,
		/mob/living/simple_animal/parrot,
		/mob/living/simple_animal/butterfly,
		/mob/living/simple_animal/crab,
		/mob/living/simple_animal/cow
	) )

	var/datum/freight_type/single/specimen/C = new /datum/freight_type/single/specimen( picked )
	C.send_prepackaged_item = TRUE
	C.allow_replacements = FALSE // Once a packaged specimen gets out it may be too large to fit in a crate, or it may get killed. Prevents gamemode softlocks from incomplete objectives
	C.overmap_objective = src
	freight_type_group = new( list( C ) )
