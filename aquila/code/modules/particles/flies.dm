/obj/emitter/flies
	particles = new/particles/flies

/particles/flies
	position = generator("box", list(-5, -5, -5), list(5, 5, 5), NORMAL_RAND)
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = list("pest_particle")
	count = 4
	spawning = 4
	spin = generator("num", 30, 40, NORMAL_RAND)
	rotation = generator("num", 0, 360, NORMAL_RAND)
	lifespan = 8 SECONDS
	fade = 1
	fadein = 1

// Version for bees
/obj/emitter/bees
	particles = new/particles/flies/bees

/particles/flies/bees
	icon_state = list("bee_particle")

// Cząsteczki roślin z BeeStation/BeeStation-Hornet#14133

/*
	Plant confetti
*/
//leaves
/obj/emitter/confetti/leaves
	particles = new/particles/confetti/leaves("#64A344")

/obj/emitter/confetti/leaves/proc/set_colour(colour = "#64A344")
	QDEL_NULL(particles)
	particles = new/particles/confetti/leaves(colour)

/particles/confetti/leaves
	icon_state = list("leaf_1", "leaf_2", "leaf_3")
	color = "#FFF"
	velocity = generator("box", list(-10, 10, -10), list(10, 10, 10), NORMAL_RAND)
	position =  generator("box", list(-10, 5, -10), list(10, -5, 10), NORMAL_RAND)
	friction = 0.5

/particles/confetti/leaves/New(_colour)
	. = ..()
	color = _colour

//dust
/obj/emitter/plant_dust/Initialize(mapload, time, _color)
	. = ..()
	particles = new/particles/confetti/plant_dust
	add_filter("blur", 1, list(type="blur", size=1.5))

/particles/confetti/plant_dust
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("steam_1" = 1, "steam_2" = 1, "steam_3" = 2)
	velocity = generator("box", list(-5, -5, -5), list(5, 5, 5), NORMAL_RAND)
	friction = 0.23
	gravity = list(0, 0, 0)
	color = "#ffffff50"
