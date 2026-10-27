
/obj/effect/cult_ritual/backup_spawn
	name = "brama"
	desc = "Coś się przez nią przedostaje!"
	icon = 'aquila/icons/bloodcult/cult.dmi'
	icon_state = "runetrigger-build"
	anchored = 1
	mouse_opacity = 1
	var/static/bloodstone_backup = 0

/obj/effect/cult_ritual/backup_spawn/New()
	..()
	spawn (30)
		bloodstone_backup++
		var/mobtype
		switch (bloodstone_backup)
			if (0, 1, 2)
				mobtype = pick(
					1;/mob/living/simple_animal/hostile/retaliate/bat,
					2;/mob/living/simple_animal/hostile/retaliate/bat,
					)
			if (3, 4)
				mobtype = pick(
					1;/mob/living/simple_animal/hostile/retaliate/bat,
					3;/mob/living/simple_animal/hostile/retaliate/bat,
					2;/mob/living/simple_animal/hostile/retaliate/bat,
					)
			if (5, 6)
				mobtype = pick(
					2;/mob/living/simple_animal/hostile/retaliate/bat,
					2;/mob/living/simple_animal/hostile/retaliate/bat,
					1;/mob/living/simple_animal/hostile/retaliate/bat,
					)
			if (7 to INFINITY)
				mobtype = pick(
					2;/mob/living/simple_animal/hostile/retaliate/bat,
					1;/mob/living/simple_animal/hostile/retaliate/bat,
					)
		new mobtype(get_turf(src))
		qdel(src)
