
/obj/effect/decal/cleanable/food
	icon = 'icons/effects/tomatodecal.dmi'
	gender = NEUTER

/obj/effect/decal/cleanable/food/tomato_smudge
	name = "pomidorowa plama"
	desc = "Jest czerwona."
	icon_state = "tomato_floor1"
	random_icon_states = list("tomato_floor1", "tomato_floor2", "tomato_floor3")

/obj/effect/decal/cleanable/food/plant_smudge
	name = "roślinna plama"
	desc = "Chlorofil? Raczej nudofil!"
	icon_state = "smashed_plant"

/obj/effect/decal/cleanable/food/egg_smudge
	name = "rozbite jajko"
	desc = "Z tego chyba już nic się nie wykluje."
	icon_state = "smashed_egg1"
	random_icon_states = list("smashed_egg1", "smashed_egg2", "smashed_egg3")

/obj/effect/decal/cleanable/food/pie_smudge //honk
	name = "rozbity placek"
	desc = "To krem z placka z kremem."
	icon_state = "smashed_pie"

/obj/effect/decal/cleanable/food/salt
	name = "kupka soli"
	desc = "Spora kupka soli kuchennej. Ktoś musi być nieźle zasolony."
	icon_state = "salt_pile"

/obj/effect/decal/cleanable/food/salt/on_entered(datum/source, atom/movable/L)
	if(is_species(L, /datum/species/snail))
		var/mob/living/snail
		snail.adjustFireLoss(10, TRUE)
		to_chat(L, "<span class='danger'>Sól! Parzy!</span>")

/obj/effect/decal/cleanable/food/flour
	name = "mąka"
	desc = "Wciąż jest dobra. Zasada czterech sekund!"
	icon_state = "flour"
