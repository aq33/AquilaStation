/obj/item/grenade/spawnergrenade
	desc = "Uwolni w okolicy bliżej nieokreśloną anomalię."
	name = "granat dostawczy"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "delivery"
	item_state = "flashbang"
	var/spawner_type = null // must be an object path
	var/deliveryamt = 1 // amount of type to deliver

/obj/item/grenade/spawnergrenade/prime(mob/living/lanced_by)			// Prime now just handles the two loops that query for people in lockers and people who can see it.
	. = ..()
	if(!.)
		return
	update_mob()
	if(spawner_type && deliveryamt)
		// Make a quick flash
		var/turf/T = get_turf(src)
		playsound(T, 'sound/effects/phasein.ogg', 100, 1)
		for(var/mob/living/carbon/C in viewers(T))
			C.flash_act()

		// Spawn some hostile syndicate critters and spread them out
		var/list/spawned = spawn_and_random_walk(spawner_type, T, deliveryamt, walk_chance=50, admin_spawn=((flags_1 & ADMIN_SPAWNED_1) ? TRUE : FALSE))
		afterspawn(spawned)

	qdel(src)

/obj/item/grenade/spawnergrenade/proc/afterspawn(list/mob/spawned)
	return

/obj/item/grenade/spawnergrenade/manhacks
	name = "granat dostawczy z wiscerotorami"
	spawner_type = /mob/living/simple_animal/hostile/viscerator
	deliveryamt = 10

/obj/item/grenade/spawnergrenade/spesscarp
	name = "granat dostawczy z karpiami"
	spawner_type = /mob/living/simple_animal/hostile/carp
	deliveryamt = 5

/obj/item/grenade/spawnergrenade/syndiesoap
	name = "Mister Scrubby"
	spawner_type = /obj/item/soap/syndie

/obj/item/grenade/spawnergrenade/buzzkill
	name = "granat Buzzkill"
	desc = "Na etykiecie widnieje napis: „OSTRZEŻENIE: PO AKTYWACJI URZĄDZENIE UWOLNI ŻYWE OKAZY. PRZED UŻYCIEM USZCZELNIJ KOMBINEZON.” Jest ciepły w dotyku i lekko wibruje."
	icon_state = "holy_grenade"
	spawner_type = /mob/living/simple_animal/hostile/poison/bees/toxin
	deliveryamt = 10

/obj/item/grenade/spawnergrenade/clown
	name = "C.L.U.W.N.E."
	desc = "Elegancki gadżet, który klauni często dostają na 10. urodziny do samoobrony. Ze środka dobiega ciche drapanie."
	icon_state = "clown_ball"
	item_state = "clown_ball"
	spawner_type = list(/mob/living/simple_animal/hostile/retaliate/clown/fleshclown, /mob/living/simple_animal/hostile/retaliate/clown/clownhulk, /mob/living/simple_animal/hostile/retaliate/clown/longface, /mob/living/simple_animal/hostile/retaliate/clown/clownhulk/chlown, /mob/living/simple_animal/hostile/retaliate/clown/clownhulk/honcmunculus, /mob/living/simple_animal/hostile/retaliate/clown/mutant/blob, /mob/living/simple_animal/hostile/retaliate/clown/banana, /mob/living/simple_animal/hostile/retaliate/clown/honkling, /mob/living/simple_animal/hostile/retaliate/clown/lube)
	deliveryamt = 1

/obj/item/grenade/spawnergrenade/clown_broken
	name = "napchany C.L.U.W.N.E."
	desc = "Elegancki gadżet, który klauni często dostają na 10. urodziny do samoobrony. Zwykły C.L.U.W.N.E. mieści tylko jedno stworzenie, ale głupiutcy młodzi klauni czasem próbują wepchnąć ich więcej, często z katastrofalnym skutkiem."
	icon_state = "clown_broken"
	item_state = "clown_broken"
	spawner_type = /mob/living/simple_animal/hostile/retaliate/clown/mutant
	deliveryamt = 5
