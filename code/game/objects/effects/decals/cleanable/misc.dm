/obj/effect/decal/cleanable/generic
	name = "bałagan"
	desc = "Ktoś powinien to posprzątać."
	icon = 'icons/obj/objects.dmi'
	icon_state = "shards"

/obj/effect/decal/cleanable/ash
	name = "popiół"
	desc = "Z popiołu powstałeś, w proch się obrócisz i w kosmos polecisz."
	icon = 'icons/obj/objects.dmi'
	icon_state = "ash"
	mergeable_decal = FALSE
	decal_reagent = /datum/reagent/ash
	reagent_amount = 30

/obj/effect/decal/cleanable/ash/Initialize(mapload)
	. = ..()
	pixel_x = base_pixel_x + rand(-5, 5)
	pixel_y = base_pixel_y + rand(-5, 5)

/obj/effect/decal/cleanable/ash/crematorium
//crematoriums need their own ash cause default ash deletes itself if created in an obj
	turf_loc_check = FALSE

/obj/effect/decal/cleanable/ash/large
	name = "duża kupka popiołu"
	icon_state = "big_ash"
	decal_reagent = /datum/reagent/ash
	reagent_amount = 60

/obj/effect/decal/cleanable/glass
	name = "drobne odłamki"
	desc = "Z powrotem w piasek."
	icon = 'icons/obj/shards.dmi'
	icon_state = "tiny"

/obj/effect/decal/cleanable/glass/Initialize(mapload)
	. = ..()
	setDir(pick(GLOB.cardinals))

/obj/effect/decal/cleanable/glass/ex_act()
	qdel(src)

/obj/effect/decal/cleanable/glass/plasma
	icon_state = "plasmatiny"

/obj/effect/decal/cleanable/dirt
	name = "brud"
	desc = "Ktoś powinien to posprzątać."
	icon_state = "dirt"
	canSmoothWith = list(/obj/effect/decal/cleanable/dirt, /turf/closed/wall, /obj/structure/falsewall)
	smooth = SMOOTH_FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/cleanable/dirt/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	if(T.tiled_dirt)
		smooth = SMOOTH_MORE
		icon = 'icons/effects/dirt.dmi'
		icon_state = ""
		queue_smooth(src)
	queue_smooth_neighbors(src)

/obj/effect/decal/cleanable/dirt/Destroy()
	queue_smooth_neighbors(src)
	return ..()

/obj/effect/decal/cleanable/dirt/dust
	name = "kurz"
	desc = "Cienka warstwa kurzu na podłodze."

/obj/effect/decal/cleanable/greenglow
	name = "świecąca maź"
	desc = "Rany. Mam nadzieję, że to nie na obiad."
	icon_state = "greenglow"
	light_power = 3
	light_range = 2
	light_color = LIGHT_COLOR_GREEN

/obj/effect/decal/cleanable/greenglow/ex_act()
	return

/obj/effect/decal/cleanable/greenglow/filled
	decal_reagent = /datum/reagent/uranium
	reagent_amount = 5

/obj/effect/decal/cleanable/greenglow/filled/Initialize(mapload)
	decal_reagent = pick(/datum/reagent/uranium, /datum/reagent/uranium/radium)
	. = ..()

/obj/effect/decal/cleanable/greenglow/ecto
	name = "kałuża ektoplazmy"
	desc = "Wiesz, po kogo zadzwonić."
	light_power = 2

/obj/effect/decal/cleanable/cobweb
	name = "pajęczyna"
	desc = "Ktoś powinien to usunąć."
	gender = NEUTER
	layer = WALL_OBJ_LAYER
	icon_state = "cobweb1"
	resistance_flags = FLAMMABLE

/obj/effect/decal/cleanable/cobweb/cobweb2
	icon_state = "cobweb2"

/obj/effect/decal/cleanable/molten_object
	name = "lepka szara masa"
	desc = "Wygląda jak stopione... coś."
	gender = NEUTER
	icon = 'icons/effects/effects.dmi'
	icon_state = "molten"
	mergeable_decal = FALSE

/obj/effect/decal/cleanable/molten_object/large
	name = "duża lepka szara masa"
	icon_state = "big_molten"

//Vomit (sorry)
/obj/effect/decal/cleanable/vomit
	name = "wymiociny"
	desc = "Ojej, jakie to nieprzyjemne."
	icon = 'icons/effects/blood.dmi'
	icon_state = "vomit_1"
	random_icon_states = list("vomit_1", "vomit_2", "vomit_3", "vomit_4")

/obj/effect/decal/cleanable/vomit/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(isflyperson(H))
			playsound(get_turf(src), 'sound/items/drink.ogg', 50, 1) //slurp
			H.visible_message("<span class='alert'>[H] wysuwa małą ssawkę do kałuży wymiocin i wysysa ją z siorbnięciem.</span>")
			if(reagents)
				for(var/datum/reagent/R in reagents.reagent_list)
					if (istype(R, /datum/reagent/consumable))
						var/datum/reagent/consumable/nutri_check = R
						if(nutri_check.nutriment_factor > 0)
							H.adjust_nutrition(nutri_check.nutriment_factor * nutri_check.volume * 15) //Volume is typically really low so it needs a multiplier
							reagents.remove_reagent(nutri_check.type,nutri_check.volume)
			reagents.trans_to(H, reagents.total_volume, transfered_by = user)
			qdel(src)

/obj/effect/decal/cleanable/vomit/old
	name = "zaschnięte wymiociny"
	desc = "Próbujesz nie patrzeć na kawałki i ci się nie udaje."
	var/list/disease = list()

/obj/effect/decal/cleanable/vomit/old/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	icon_state += "-old"
	if(prob(95))//vomit is much more likely to be diseased than blood is
		var/datum/disease/advance/R = new /datum/disease/advance/random(rand(2, 5), rand(7, 9), 4, infected = src)
		disease += R

/obj/effect/decal/cleanable/vomit/old/extrapolator_act(mob/user, var/obj/item/extrapolator/E, scan = TRUE)
	if(!disease.len)
		return FALSE
	if(scan)
		E.scan(src, disease, user)
	else
		E.extrapolate(src, disease, user)
	return TRUE

/obj/effect/decal/cleanable/chem_pile
	name = "kupka chemikaliów"
	desc = "Kupka chemikaliów. Trudno powiedzieć, co jest w środku."
	gender = NEUTER
	icon = 'icons/obj/objects.dmi'
	icon_state = "ash"

/obj/effect/decal/cleanable/shreds
	name = "strzępy"
	desc = "Poszarpane resztki czegoś, co wygląda na ubranie."
	icon_state = "shreds"
	gender = PLURAL
	mergeable_decal = FALSE

/obj/effect/decal/cleanable/shreds/ex_act(severity, target)
	if(severity == 1) //so shreds created during an explosion aren't deleted by the explosion.
		qdel(src)

/obj/effect/decal/cleanable/shreds/Initialize(mapload)
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)
	. = ..()

/obj/effect/decal/cleanable/glitter
	name = "kupka zwykłego brokatu"
	desc = "Opryszczka świata rękodzieła."
	icon = 'icons/effects/atmospherics.dmi'
	icon_state = "plasma_old"
	gender = NEUTER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/cleanable/glitter/pink
	name = "różowy brokat"
	icon_state = "plasma"

/obj/effect/decal/cleanable/glitter/white
	name = "biały brokat"
	icon_state = "nitrous_oxide"

/obj/effect/decal/cleanable/glitter/blue
	name = "niebieski brokat"
	icon_state = "freon"

/obj/effect/decal/cleanable/plasma
	name = "ustabilizowana plazma"
	desc = "Kałuża ustabilizowanej plazmy."
	icon_state = "flour"
	icon = 'icons/effects/tomatodecal.dmi'
	color = "#2D2D2D"

/obj/effect/decal/cleanable/insectguts
	name = "wnętrzności owada"
	desc = "Jeden robal rozgnieciony. Na jego miejsce przyjdą cztery kolejne."
	icon = 'icons/effects/blood.dmi'
	icon_state = "xfloor1"
	random_icon_states = list("xfloor1", "xfloor2", "xfloor3", "xfloor4", "xfloor5", "xfloor6", "xfloor7")

/obj/effect/decal/cleanable/ants
	name = "kosmiczne mrówki"
	desc = "Mała kolonia kosmicznych mrówek. Zwykle żyją w próżni kosmosu, więc nie wspinają się zbyt dobrze."
	icon = 'icons/obj/debris.dmi'
	icon_state = "ants"
	//beauty = -150
	plane = GAME_PLANE
	layer = LOW_OBJ_LAYER
	decal_reagent = /datum/reagent/ants
	reagent_amount = 5
	/// Sound the ants make when biting
	var/bite_sound = 'sound/weapons/bite.ogg'

/obj/effect/decal/cleanable/ants/Initialize(mapload)
	reagent_amount = rand(3, 5)
	. = ..()
	update_ant_damage()

/obj/effect/decal/cleanable/ants/handle_merge_decal(obj/effect/decal/cleanable/merger)
	. = ..()
	var/obj/effect/decal/cleanable/ants/ants = merger
	ants.update_ant_damage()

/obj/effect/decal/cleanable/ants/proc/update_ant_damage()
	var/ant_bite_damage = min(10, round((reagents.get_reagent_amount(/datum/reagent/ants) * 0.1),0.1)) // 100u ants = 10 max_damage

	var/ant_flags = (CALTROP_NOCRAWL | CALTROP_NOSTUN) /// Small amounts of ants won't be able to bite through shoes.
	if(ant_bite_damage > 1)
		ant_flags = (CALTROP_NOCRAWL | CALTROP_NOSTUN | CALTROP_BYPASS_SHOES)

	switch(ant_bite_damage)
		if(0 to 1)
			icon_state = initial(icon_state)
		if(1.1 to 4)
			icon_state = "[initial(icon_state)]_2"
		if(4.1 to 7)
			icon_state = "[initial(icon_state)]_3"
		if(7.1 to 10)
			icon_state = "[initial(icon_state)]_4"

	AddComponent(/datum/component/caltrop, min_damage = 0.1, max_damage = ant_bite_damage, flags = ant_flags, soundfile = bite_sound)
	update_icon(UPDATE_OVERLAYS)

/obj/effect/decal/cleanable/ants/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_light", alpha = src.alpha)
