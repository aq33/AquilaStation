//Cotton
/obj/item/grown/cotton
	seed = /obj/item/plant_seeds/preset/cotton
	name = "bawełna"
	desc = "Puszysta wiązka bawełny."
	icon_state = "cotton"
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 2
	throw_range = 3
	attack_verb = list("pompfuje")
	var/cotton_type = /obj/item/stack/sheet/cotton
	var/cotton_name = "surowej bawełny"

/obj/item/grown/cotton/attack_self(mob/user)
	user.show_message("<span class='notice'>Wyciągasz trochę [cotton_name] z [name]!</span>", MSG_VISUAL)
	var/seed_modifier = round(get_fruit_trait_power(src)*1.5)
	var/obj/item/stack/cotton = new cotton_type(user.loc, 1 + seed_modifier)
	var/old_cotton_amount = cotton.amount
	for(var/obj/item/stack/ST in user.loc)
		if(ST != cotton && istype(ST, cotton_type) && ST.amount < ST.max_amount)
			ST.attackby(cotton, user)
	if(cotton.amount > old_cotton_amount)
		to_chat(user, "<span class='notice'>Dodajesz świeżo uformowany [cotton_name] do stosu. Zawiera teraz: [cotton.amount] [cotton_name].</span>")
	qdel(src)

//reinforced mutated variant
/obj/item/grown/cotton/durathread
	name = "duranitka"
	desc = "Twarda wiązka duranitki. Powodzenia w rozplątywaniu."
	icon_state = "durathread"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 2
	throw_range = 3
	attack_verb = list("grzmoci", "okłada", "tłucze", "wali")
	cotton_type = /obj/item/stack/sheet/cotton/durathread
	cotton_name = "surowej duranitki"
	discovery_points = 300
