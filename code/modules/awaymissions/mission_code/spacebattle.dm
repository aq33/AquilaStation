//Spacebattle Areas

/area/awaymission/spacebattle
	name = "Bitwa Kosmiczna"
	icon_state = "awaycontent1"
	requires_power = FALSE

/area/awaymission/spacebattle/cruiser
	name = "\improper Krążownik Nanotrasen"
	icon_state = "awaycontent2"

/area/awaymission/spacebattle/syndicate1
	name = "Okręt Szturmowy Syndykatu 1"
	icon_state = "awaycontent3"

/area/awaymission/spacebattle/syndicate2
	name = "Okręt Szturmowy Syndykatu 2"
	icon_state = "awaycontent4"

/area/awaymission/spacebattle/syndicate3
	name = "Okręt Szturmowy Syndykatu 3"
	icon_state = "awaycontent5"

/area/awaymission/spacebattle/syndicate4
	name = "Sfera Bojowa Syndykatu 1"
	icon_state = "awaycontent6"

/area/awaymission/spacebattle/syndicate5
	name = "Sfera Bojowa Syndykatu 2"
	icon_state = "awaycontent7"

/area/awaymission/spacebattle/syndicate6
	name = "Sfera Bojowa Syndykatu 3"
	icon_state = "awaycontent8"

/area/awaymission/spacebattle/syndicate7
	name = "Myśliwiec Syndykatu (Bitwa Kosmiczna)"
	icon_state = "awaycontent9"

/area/awaymission/spacebattle/secret
	name = "Ukryta Komnata"
	icon_state = "awaycontent10"

/mob/living/simple_animal/hostile/syndicate/ranged/spacebattle
	loot = list(/obj/effect/mob_spawn/human/corpse/syndicatesoldier,
				/obj/item/gun/ballistic/automatic/c20r,
				/obj/item/shield/energy)

/mob/living/simple_animal/hostile/syndicate/melee/spacebattle
	deathmessage = "wiotczeje, puszczając broń energetyczną i aktywując funkcję samozniszczenia!"
	loot = list(/obj/effect/mob_spawn/human/corpse/syndicatesoldier)
