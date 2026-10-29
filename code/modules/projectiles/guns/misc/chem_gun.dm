//his isn't a subtype of the syringe gun because the syringegun subtype is made to hold syringes
//this is meant to hold reagents/obj/item/gun/syringe
/obj/item/gun/chem
	name = "pistolet na odczynniki"
	desc = "Wyrzutnia strzykawek Nanotrasen przerobiona tak, by sama syntetyzowała strzałki chemiczne i zamiast strzykawek przechowywała odczynniki."
	icon_state = "chemgun"
	item_state = "chemgun"
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3
	throw_range = 7
	force = 4
	materials = list(/datum/material/iron=2000)
	clumsy_check = FALSE
	fire_sound = 'sound/items/syringeproj.ogg'
	fire_rate = 1.5
	var/time_per_syringe = 250
	var/syringes_left = 4
	var/max_syringes = 4
	var/last_synth = 0
	var/casing = /obj/item/ammo_casing/chemgun

/obj/item/gun/chem/Initialize(mapload)
	. = ..()
	chambered = new casing(src)
	START_PROCESSING(SSobj, src)
	create_reagents(100, OPENCONTAINER)

/obj/item/gun/chem/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/gun/chem/can_shoot()
	return syringes_left

/obj/item/gun/chem/process_chamber()
	if(chambered && !chambered.BB && syringes_left)
		chambered.newshot()

/obj/item/gun/chem/process()
	if(syringes_left >= max_syringes)
		return
	if(world.time < last_synth+time_per_syringe)
		return
	to_chat(loc, "<span class='warning'>Słyszysz kliknięcie, gdy [src] syntetyzuje nową strzałkę.</span>")
	syringes_left++
	if(chambered && !chambered.BB)
		chambered.newshot()
	last_synth = world.time

/obj/item/gun/chem/bee
	name = "pszczeli pistolet"
	desc = "Dziwny wynalazek BLF. Strzela pszczołami wypełnionymi odczynnikami ze zbiornika broni albo jadem, jeśli zbiornik jest pusty."
	icon_state = "beegun"
	item_state = "chemgun"
	fire_sound = 'sound/creatures/bee.ogg'
	automatic = 1
	fire_rate = 5
	time_per_syringe = 80
	syringes_left = 20
	max_syringes = 20
	casing = /obj/item/ammo_casing/bee
	spread = 40
