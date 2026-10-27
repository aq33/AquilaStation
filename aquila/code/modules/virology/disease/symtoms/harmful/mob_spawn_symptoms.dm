/datum/symptom/acute/spawn
	name = "Arachnogenesis Effect"
	desc = "Converts the infected's stomach to begin producing creatures of the arachnid variety."
	stage = 4
	max_multiplier = 7
	badness = EFFECT_DANGER_HARMFUL
	severity = 2
	var/list/spawn_types= list(/mob/living/simple_animal/hostile/spider/growing/spiderling = 10)
	///what gets added based on multiplier NOT INCLUSIVE OF PREVIOUS TIERS
	var/list/multipler_unlocks = list()

/datum/symptom/acute/spawn/activate(mob/living/mob)
	check_unlocks()
	playsound(mob.loc, 'sound/effects/splat.ogg', 50, 1)
	var/atom/spawn_type = pick_weight(spawn_types)
	if(!spawn_type)
		return
	var/spawn_name = initial(spawn_type.name)
	var/mob/living/spawned_mob = new spawn_type(get_turf(mob))
	mob.emote("me", 1, "vomits up a live [spawn_name]!")
	if(multiplier < 4)
		addtimer(CALLBACK(src, PROC_REF(kill_mob), spawned_mob), 1 MINUTES)

/datum/symptom/acute/spawn/proc/check_unlocks()
	spawn_types = initial(spawn_types)
	var/text_multi = num2text(round(multiplier))

	if(!(text_multi in multipler_unlocks))
		return
	spawn_types += multipler_unlocks[text_multi]

/datum/symptom/acute/spawn/proc/kill_mob(mob/living/mob)
	mob.visible_message(span_warning("The [mob] falls apart!"), span_warning("You fall apart!"))
	mob.death()

/datum/symptom/acute/spawn/roach
	name = "Blattogenesis Effect"
	desc = "Converts the infected's stomach to begin producing creatures of the blattid variety."
	stage = 4
	badness = EFFECT_DANGER_HINDRANCE
	severity = 3
	spawn_types = list(/mob/living/simple_animal/cockroach = 10)
	multipler_unlocks = list(
		"4" = list(/mob/living/simple_animal/cockroach = 3),
		"5" = list(/mob/living/simple_animal/cockroach = 4),
		"6" = list(/mob/living/simple_animal/cockroach = 5, /mob/living/simple_animal/cockroach = 3),
		"7" = list(/mob/living/simple_animal/cockroach = 5, /mob/living/simple_animal/cockroach = 3, /mob/living/simple_animal/cockroach = 3),
		)
