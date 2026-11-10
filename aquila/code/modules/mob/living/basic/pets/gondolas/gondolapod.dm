// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/pets/gondolas/gondolapod.dm (bee/master 0adf0fe9ae)
// Was code/modules/cargo/gondolapod.dm. Our Polish verbs stay instead of Bee's innate actions.
/mob/living/basic/pet/gondola/gondolapod
	name = "gondola"
	real_name = "gondola"
	desc = "Cichy wędrowiec. Ten chyba pracuje w firmie kurierskiej."
	icon = 'icons/obj/supplypods.dmi'
	icon_state = "gondola"
	icon_living = "gondola"
	base_pixel_x = -16 //2x2 sprite
	base_pixel_y = -5
	layer = TABLE_LAYER //so that deliveries dont appear underneath it
	gold_core_spawnable = NO_SPAWN

	loot = list(
		/obj/effect/decal/cleanable/blood/gibs = 1,
		/obj/item/stack/sheet/animalhide/gondola = 2,
		/obj/item/food/meat/slab/gondola = 2,
	)

	///Boolean on whether the pod is currently open, and should appear such.
	var/opened = FALSE
	///The supply pod attached to the gondola, that actually holds the contents of our delivery.
	var/obj/structure/closet/supplypod/centcompod/linked_pod

/mob/living/basic/pet/gondola/gondolapod/Initialize(mapload, pod)
	linked_pod = pod || new(src)
	name = linked_pod.name
	return ..()

/mob/living/basic/pet/gondola/gondolapod/death(gibbed)
	QDEL_NULL(linked_pod) //Will cause the open() proc for the linked supplypod to be called with the "broken" parameter set to true, meaning that it will dump its contents on death
	return ..()

/mob/living/basic/pet/gondola/gondolapod/create_gondola()
	return

/mob/living/basic/pet/gondola/gondolapod/update_overlays()
	. = ..()
	if(opened)
		. += "[icon_state]_open"

/mob/living/basic/pet/gondola/gondolapod/verb/deliver()
	set name = "Release Contents"
	set category = "Gondola"
	set desc = "Wypuść wszystko, co przechowujesz w swoim przepastnym brzuchu."
	linked_pod.open_pod(src, forced = TRUE)

/mob/living/basic/pet/gondola/gondolapod/examine(mob/user)
	. = ..()
	if (contents.len)
		. += "<span class='notice'>Wygląda na to, że jeszcze nie dostarczył przesyłki.</b></span>"
	else
		. += "<span class='notice'>Wygląda na to, że już dostarczył przesyłkę.</b></span>"

/mob/living/basic/pet/gondola/gondolapod/verb/check()
	set name = "Count Contents"
	set category = "Gondola"
	set desc = "Zajrzyj głęboko w siebie i policz, co jest w środku."
	var/total = contents.len
	if (total)
		to_chat(src, "<span class='notice'>Wykrywasz obiekty w swoim niewiarygodnie przepastnym brzuchu (liczba: [total]).</span>")
	else
		to_chat(src, "<span class='notice'>Bliższe spojrzenie w głąb siebie ujawnia... nic.</span>")

/mob/living/basic/pet/gondola/gondolapod/setOpened()
	opened = TRUE
	layer = initial(layer)
	update_appearance()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, setClosed)), 5 SECONDS)

/mob/living/basic/pet/gondola/gondolapod/setClosed()
	opened = FALSE
	layer = BELOW_MOB_LAYER
	update_appearance()
