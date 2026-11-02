/obj/item/reagent_containers/medspray
	name = "spray medyczny"
	desc = "Medyczna butelka z rozpylaczem do precyzyjnego nakładania, z odkręcaną nakrętką."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "medspray"
	item_state = "spraycan"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	item_flags = NOBLUDGEON
	obj_flags = UNIQUE_RENAME
	reagent_flags = OPENCONTAINER
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7
	amount_per_transfer_from_this = 10
	volume = 60
	var/can_fill_from_container = TRUE
	var/apply_type = PATCH
	var/apply_method = "spray"
	var/self_delay = 30
	var/squirt_mode = 0
	var/squirt_amount = 5
	custom_price = 40

/obj/item/reagent_containers/medspray/attack_self(mob/user)
	squirt_mode = !squirt_mode
	if(squirt_mode)
		amount_per_transfer_from_this = squirt_amount
	else
		amount_per_transfer_from_this = initial(amount_per_transfer_from_this)
	to_chat(user, "<span class='notice'>Będziesz teraz podawać zawartość medsprayu [squirt_mode ? "krótkimi strzałami":"długim rozpylaniem"]. Na jedno użycie zużyjesz [amount_per_transfer_from_this] j.</span>")

/obj/item/reagent_containers/medspray/attack(mob/living/carbon/M, mob/user, def_zone)
	if(!iscarbon(M))
		return

	if(!reagents || !reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] jest pusty!</span>")
		return

	var/obj/item/bodypart/affecting = M.get_bodypart(check_zone(user.zone_selected))
	if(!affecting)
		balloon_alert(user, "Brakuje tej kończyny.")
		return
	if(!IS_ORGANIC_LIMB(affecting))
		balloon_alert(user, "[src] nie działa na robotyczne kończyny.")
		return

	if(M == user)
		M.visible_message("<span class='notice'>[user] próbuje spryskać się za pomocą [src].</span>")
		if(self_delay)
			if(!do_mob(user, M, self_delay))
				return
			if(!reagents || !reagents.total_volume)
				return
		to_chat(M, "<span class='notice'>Spryskujesz się za pomocą [src].</span>")

	else
		log_combat(user, M, "attempted to apply", src, reagents.log_list())
		M.visible_message("<span class='danger'>[user] próbuje spryskać [M] za pomocą [src].</span>", \
							"<span class='userdanger'>[user] próbuje spryskać cię za pomocą [src].</span>")
		if(!do_mob(user, M))
			return
		if(!reagents || !reagents.total_volume)
			return
		M.visible_message("<span class='danger'>[user] spryskuje [M] za pomocą [src].</span>", \
							"<span class='userdanger'>[user] spryskuje cię za pomocą [src].</span>")

	if(!reagents || !reagents.total_volume)
		return

	else
		log_combat(user, M, "applied", src, reagents.log_list())
		playsound(src, 'sound/effects/spray2.ogg', 50, 1, -6)
		var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1)
		reagents.reaction(M, apply_type, fraction, affecting = affecting)
		reagents.trans_to(M, amount_per_transfer_from_this, transfered_by = user)
	return

/obj/item/reagent_containers/medspray/styptic
	name = "spray medyczny (proszek hemostatyczny)"
	desc = "Medyczna butelka z rozpylaczem do precyzyjnego nakładania, z odkręcaną nakrętką. Ta zawiera proszek hemostatyczny do leczenia skaleczeń i stłuczeń."
	icon_state = "brutespray"
	list_reagents = list(/datum/reagent/medicine/styptic_powder = 60)

/obj/item/reagent_containers/medspray/silver_sulf
	name = "spray medyczny (sulfadiazyna srebra)"
	desc = "Medyczna butelka z rozpylaczem do precyzyjnego nakładania, z odkręcaną nakrętką. Ta zawiera sulfadiazynę srebra, przydatną przy oparzeniach."
	icon_state = "burnspray"
	list_reagents = list(/datum/reagent/medicine/silver_sulfadiazine = 60)

/obj/item/reagent_containers/medspray/synthflesh
	name = "spray medyczny (syntetyczne ciało)"
	desc = "Medyczna butelka z rozpylaczem do precyzyjnego nakładania, z odkręcaną nakrętką. Ta zawiera syntetyczne ciało, najlepszy środek na urazy i oparzenia."
	icon_state = "synthspray"
	list_reagents = list(/datum/reagent/medicine/synthflesh = 60)
	custom_price = 80

/obj/item/reagent_containers/medspray/sterilizine
	name = "spray sterylizujący"
	desc = "Spryskiwacz z nietoksycznym środkiem sterylizującym. Przydaje się przy przygotowaniu do operacji."
	list_reagents = list(/datum/reagent/space_cleaner/sterilizine = 60)

/obj/item/reagent_containers/medspray/barber
	name = "spray do włosów"
	desc = "Spryskiwacz z nieznanym środkiem na porost włosów."
	icon_state = "hairgrowth"
	apply_type = TOUCH
	list_reagents = list(/datum/reagent/barbers_aid = 60)
	squirt_amount = 1
	squirt_mode = 1

/obj/item/reagent_containers/medspray/dye
	name = "farba do włosów"
	desc = "Spryskiwacz z uniwersalną farbą do włosów."
	icon_state = "hairdye"
	apply_type = TOUCH
	list_reagents = list(/datum/reagent/hair_dye = 60)
	squirt_amount = 1
	squirt_mode = 1

/obj/item/reagent_containers/medspray/spraytan
	name = "samoopalacz w sprayu"
	desc = "Butelka samoopalacza w sprayu, prowizorycznie przerobiona tak, by każde psiknięcie dawało trochę za dużo."
	icon_state = "spraytan"
	apply_type = TOUCH
	list_reagents = list(/datum/reagent/spraytan = 55)
	amount_per_transfer_from_this = 11
