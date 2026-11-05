/obj/structure/spawner
	name = "gniazdo potworów"
	icon = 'icons/mob/animal.dmi'
	icon_state = "hole"
	max_integrity = 100

	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	anchored = TRUE
	density = TRUE

	var/max_mobs = 5
	var/spawn_time = 300 //30 seconds default
	var/mob_types = list(/mob/living/simple_animal/hostile/carp)
	var/spawn_text = "wyłania się z"
	var/faction = list("hostile")
	var/spawner_type = /datum/component/spawner

/obj/structure/spawner/Initialize(mapload)
	. = ..()
	AddComponent(spawner_type, mob_types, spawn_time, faction, spawn_text, max_mobs)

/obj/structure/spawner/attack_animal(mob/living/simple_animal/M)
	if(faction_check(faction, M.faction, FALSE)&&!M.client)
		return
	..()


/obj/structure/spawner/syndicate
	name = "radiolatarnia przesyłowa"
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"
	spawn_text = "przenika z"
	mob_types = list(/mob/living/simple_animal/hostile/syndicate/ranged)
	faction = list(FACTION_SYNDICATE)

/obj/structure/spawner/skeleton
	name = "dół z kośćmi"
	desc = "Dół pełen kości, a niektóre chyba wciąż się ruszają..."
	icon_state = "hole"
	icon = 'icons/mob/nest.dmi'
	max_integrity = 150
	max_mobs = 15
	spawn_time = 150
	mob_types = list(/mob/living/simple_animal/hostile/skeleton)
	spawn_text = "wychodzi z"
	faction = list("skeleton")

/obj/structure/spawner/clown
	name = "Rechoczący Larry"
	desc = "Roześmiana, jowialna postać. Coś chyba utknęło mu w gardle."
	icon_state = "clownbeacon"
	icon = 'icons/obj/device.dmi'
	max_integrity = 200
	max_mobs = 15
	spawn_time = 150
	mob_types = list(/mob/living/simple_animal/hostile/retaliate/clown, /mob/living/simple_animal/hostile/retaliate/clown/fleshclown, /mob/living/simple_animal/hostile/retaliate/clown/clownhulk, /mob/living/simple_animal/hostile/retaliate/clown/longface, /mob/living/simple_animal/hostile/retaliate/clown/clownhulk/chlown, /mob/living/simple_animal/hostile/retaliate/clown/clownhulk/honcmunculus, /mob/living/simple_animal/hostile/retaliate/clown/mutant/blob, /mob/living/simple_animal/hostile/retaliate/clown/banana, /mob/living/simple_animal/hostile/retaliate/clown/honkling, /mob/living/simple_animal/hostile/retaliate/clown/lube)
	spawn_text = "wychodzi z"
	faction = list("clown")

/obj/structure/spawner/mining
	name = "legowisko potworów"
	desc = "Dziura wykopana w ziemi, w której kryją się wszelkie potwory spotykane w większości jaskiń i asteroid górniczych."
	icon_state = "hole"
	max_integrity = 200
	max_mobs = 3
	icon = 'icons/mob/nest.dmi'
	spawn_text = "wypełza z"
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/goldgrub, /mob/living/simple_animal/hostile/asteroid/goliath, /mob/living/simple_animal/hostile/asteroid/hivelord, /mob/living/simple_animal/hostile/asteroid/basilisk, /mob/living/simple_animal/hostile/asteroid/fugu)
	faction = list("mining")

/obj/structure/spawner/mining/goldgrub
	name = "legowisko złotych pędraków"
	desc = "Legowisko z gniazdem złotych pędraków. Irytujące, ale chyba lepsze od wszystkiego innego, co znajdziesz w gnieździe."
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/goldgrub)

/obj/structure/spawner/mining/goliath
	name = "legowisko goliatów"
	desc = "Legowisko z gniazdem goliatów. O Boże, czemu?"
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/goliath)

/obj/structure/spawner/mining/hivelord
	name = "legowisko władców roju"
	desc = "Legowisko z gniazdem władców roju."
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/hivelord)

/obj/structure/spawner/mining/basilisk
	name = "legowisko bazyliszków"
	desc = "Legowisko z gniazdem bazyliszków. Weź kurtkę."
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/basilisk)

/obj/structure/spawner/mining/wumborian
	name = "legowisko wumboriańskich fugu"
	desc = "Legowisko z gniazdem wumboriańskich fugu. Jak one się tam w ogóle mieszczą?"
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/fugu)
