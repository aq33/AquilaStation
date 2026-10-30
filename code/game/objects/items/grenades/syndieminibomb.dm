/obj/item/grenade/syndieminibomb
	desc = "Ładunek wybuchowy produkcji Syndykatu, który sieje zniszczenie i chaos."
	name = "minibomba Syndykatu"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "syndicate"
	item_state = "flashbang"
	ex_dev = 1
	ex_heavy = 2
	ex_light = 4
	ex_flame = 2


/obj/item/grenade/syndieminibomb/prime(mob/living/lanced_by)
	. = ..()
	if(!.)
		return
	update_mob()
	qdel(src)

/obj/item/grenade/syndieminibomb/concussion
	name = "granat burzący"
	desc = "Kompaktowy granat odłamkowy, który ma spustoszyć pobliskie organizmy i przy okazji narobić szkód. Wyciągnij zawleczkę i rzuć w przeciwną stronę."
	icon_state = "concussion"
	ex_heavy = 2
	ex_light = 3
	ex_flame = 3

/obj/item/grenade/frag
	name = "granat odłamkowy"
	desc = "Przeciwpiechotny granat odłamkowy. Świetnie zabija miękkie cele, szatkując je metalowymi odłamkami."
	icon_state = "frag"
	shrapnel_type = /obj/item/projectile/bullet/shrapnel
	shrapnel_radius = 4
	ex_heavy = 1
	ex_light = 3
	ex_flame = 4

/obj/item/grenade/frag/mega
	name = "\improper granat ODŁAMKOWY"
	desc = "Granat odłamkowy przeciwko wszystkiemu. Świetnie zabija cokolwiek i wszystko, szatkując to metalowymi odłamkami."
	shrapnel_type = /obj/item/projectile/bullet/shrapnel/mega
	shrapnel_radius = 12

/obj/item/grenade/frag/prime(mob/living/lanced_by)
	. = ..()
	if(!.)
		return
	update_mob()
	qdel(src)

/obj/item/grenade/gluon
	desc = "Zaawansowany granat, który uwalnia szkodliwy strumień gluonów napromieniowujący wszystkich w pobliżu. Strumienie gluonów wyczerpują też ofiary i wywołują dreszcze. Ten skrajny chłód najpewniej zamoczy też pobliską podłogę."
	name = "gluonowy granat odłamkowy"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "bluefrag"
	item_state = "flashbang"
	var/freeze_range = 4
	var/rad_damage = 350
	var/rad_stamina_damage = 30

/obj/item/grenade/gluon/prime(mob/living/lanced_by)
	. = ..()
	if(!.)
		return
	update_mob()
	playsound(loc, 'sound/effects/empulse.ogg', 50, 1)
	radiation_pulse(src, rad_damage)
	for(var/turf/open/floor/F in view(freeze_range,loc))
		F.MakeSlippery(TURF_WET_PERMAFROST, 6 MINUTES)
		for(var/mob/living/carbon/L in F)
			L.adjustStaminaLoss(rad_stamina_damage)
			L.adjust_bodytemperature(-230)
	qdel(src)
