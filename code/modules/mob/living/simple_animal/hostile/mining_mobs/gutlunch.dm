//Gutlunches, passive mods that devour blood and gibs
/mob/living/simple_animal/hostile/asteroid/gutlunch
	name = "żarłoczek"
	desc = "Padlinożerca jedzący surowe mięso, często spotykany u boku popielnych wędrowców. Daje gęste, pożywne mleko."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "gutlunch"
	icon_living = "gutlunch"
	icon_dead = "gutlunch"
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak_emote = list("gulgocze", "drży")
	emote_hear = list("trylikuje.")
	emote_see = list("węszy.", "beka.")
	weather_immunities = list("lava","ash")
	faction = list("mining", "ashwalker")
	density = FALSE
	speak_chance = 1
	turns_per_move = 8
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	move_to_delay = 15
	response_help  = "głaszcze"
	response_disarm = "delikatnie odsuwa na bok"
	response_harm   = "rozgniata"
	friendly = "szczypie"
	combat_mode = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	gold_core_spawnable = FRIENDLY_SPAWN
	stat_attack = UNCONSCIOUS
	gender = NEUTER
	stop_automated_movement = FALSE
	stop_automated_movement_when_pulled = TRUE
	stat_exclusive = TRUE
	robust_searching = TRUE
	search_objects = 3 //Ancient simplemob AI shitcode. This makes them ignore all other mobs.
	del_on_death = TRUE
	loot = list(/obj/effect/decal/cleanable/blood/gibs)
	deathmessage = "zostaje rozgnieciony na robaczą papkę."

	animal_species = /mob/living/simple_animal/hostile/asteroid/gutlunch
	childtype = list(/mob/living/simple_animal/hostile/asteroid/gutlunch/grublunch = 100)

	wanted_objects = list(/obj/effect/decal/cleanable/xenoblood/xgibs, /obj/effect/decal/cleanable/blood/gibs/, /obj/item/organ)

/mob/living/simple_animal/hostile/asteroid/gutlunch/Initialize(mapload)
	. = ..()
	// AQ EDIT START - the udder component, as in Bee (milking, generation and guthen breeding in aquila/code/datums/components/udder.dm)
	if(length(wanted_objects))
		AddComponent(/datum/component/udder, /obj/item/udder/gutlunch, CALLBACK(src, PROC_REF(regenerate_icons)), CALLBACK(src, PROC_REF(regenerate_icons)))
	// AQ EDIT END

/mob/living/simple_animal/hostile/asteroid/gutlunch/CanAttack(atom/the_target) // Gutlunch-specific version of CanAttack to handle stupid stat_exclusive = true crap so we don't have to do it for literally every single simple_animal/hostile except the two that spawn in lavaland
	if(isturf(the_target) || !the_target || the_target.type == /atom/movable/lighting_object) // bail out on invalids
		return FALSE

	if(see_invisible < the_target.invisibility)//Target's invisible to us, forget it
		return FALSE

	if(isliving(the_target))
		var/mob/living/L = the_target

		if(faction_check_mob(L) && !attack_same)
			return FALSE
		if(L.stat > stat_attack || L.stat != stat_attack && stat_exclusive)
			return FALSE

		return TRUE

	if(isobj(the_target) && is_type_in_typecache(the_target, wanted_objects))
		return TRUE

	return FALSE

// AQ EDIT START - the udder component calls this with its volume (Bee); milking goes through the component
/mob/living/simple_animal/hostile/asteroid/gutlunch/regenerate_icons(new_udder_volume, max_udder_volume)
	cut_overlays()
	if(new_udder_volume && new_udder_volume == max_udder_volume)
		add_overlay("gl_full")
	..()

/mob/living/simple_animal/hostile/asteroid/gutlunch/AttackingTarget()
	if(is_type_in_typecache(target,wanted_objects)) //we eats
		var/datum/component/udder/udder_component = GetComponent(/datum/component/udder)
		udder_component?.udder.generate()
		visible_message("<span class='notice'>[src] wsysa [target].</span>")
		qdel(target)
	return ..()
// AQ EDIT END

//Male gutlunch. They're smaller and more colorful!
/mob/living/simple_animal/hostile/asteroid/gutlunch/gubbuck
	name = "żarłoczek samiec"
	gender = MALE

/mob/living/simple_animal/hostile/asteroid/gutlunch/gubbuck/Initialize(mapload)
	. = ..()
	add_atom_colour(pick("#E39FBB", "#D97D64", "#CF8C4A"), FIXED_COLOUR_PRIORITY)
	resize = 0.85
	update_transform()

//Lady gutlunch. They make the babby.
/mob/living/simple_animal/hostile/asteroid/gutlunch/guthen
	name = "żarłoczka"
	gender = FEMALE

// AQ EDIT - a full guthen breeds from its udder (aquila/code/datums/components/udder.dm), as in Bee

/mob/living/simple_animal/hostile/asteroid/gutlunch/grublunch
	name = "młody żarłoczek"
	wanted_objects = list() //They don't eat.
	gold_core_spawnable = NO_SPAWN
	var/growth = 0

//Baby gutlunch
/mob/living/simple_animal/hostile/asteroid/gutlunch/grublunch/Initialize(mapload)
	. = ..()
	add_atom_colour("#9E9E9E", FIXED_COLOUR_PRIORITY) //Somewhat hidden
	resize = 0.45
	update_transform()

/mob/living/simple_animal/hostile/asteroid/gutlunch/grublunch/Life()
	..()
	growth++
	if(growth > 50) //originally used a timer for this but was more problem that it's worth.
		growUp()

/mob/living/simple_animal/hostile/asteroid/gutlunch/grublunch/proc/growUp()
	var/mob/living/L
	if(prob(45))
		L = new /mob/living/simple_animal/hostile/asteroid/gutlunch/gubbuck(loc)
	else
		L = new /mob/living/simple_animal/hostile/asteroid/gutlunch/guthen(loc)
	mind?.transfer_to(L)
	L.faction = faction
	L.setDir(dir)
	L.Stun(20, ignore_canstun = TRUE)
	visible_message("<span class='notice'>[src] dorasta, stając się [L].</span>")
	Destroy()

// AQ EDIT - the gutlunch udder (/obj/item/udder/gutlunch) is in aquila/code/datums/components/udder.dm
