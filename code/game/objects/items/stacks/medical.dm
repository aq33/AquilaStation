/obj/item/stack/medical
	name = "pakiet medyczny"
	singular_name = "pakiet medyczny"
	icon = 'icons/obj/stack_objects.dmi'
	amount = 6
	max_amount = 6
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	resistance_flags = FLAMMABLE
	max_integrity = 40
	novariants = FALSE
	///How much brute does it heal?
	var/heal_brute = 0
	///How much burn does it heal?
	var/heal_burn = 0
	///How much bleeding rate does it suppress?
	var/stop_bleeding = 0
	///How long does it take to apply on yourself?
	var/self_delay = 2 SECONDS

/obj/item/stack/medical/attack(mob/living/M, mob/user)
	if(!M || !user || (isliving(M) && !M.can_inject(user, TRUE))) //If no mob, user and if we can't inject the mob just return
		return

	if(M.stat == DEAD && !stop_bleeding)
		to_chat(user, "<span class='danger'>[M] nie żyje, nie możesz mu pomóc!</span>")
		return

	if(!iscarbon(M) && !isanimal_or_basicmob(M)) // AQ EDIT - basic moby
		to_chat(user, "<span class='danger'>Nie wiesz, jak użyć [src] na [M]!</span>")
		return

	if(isanimal_or_basicmob(M)) // AQ EDIT - basic moby (healable jest też na basic mobach)
		var/mob/living/simple_animal/critter = M
		if(!(critter.healable) || stop_bleeding)
			to_chat(user, "<span class='notice'>Nie możesz użyć [src] na [M]!</span>")
			return
		if(critter.health == critter.maxHealth)
			to_chat(user, "<span class='notice'>[M] jest w pełni zdrowy.</span>")
			return
		if(heal_brute < DAMAGE_PRECISION)
			to_chat(user, "<span class='notice'>[src] w ogóle nie pomoże [M].</span>")
			return
		M.heal_bodypart_damage((heal_brute * 0.5), (heal_burn * 0.5)) //half as effective on animals, since it's not made for them
		user.visible_message("<span class='green'>[user] nakłada [src] na [M].</span>", "<span class='green'>Nakładasz [src] na [M].</span>")
		use(1)
		return

	var/obj/item/bodypart/affecting
	var/mob/living/carbon/C = M
	affecting = C.get_bodypart(check_zone(user.zone_selected))

	if(M in user.do_afters) //One at a time, please.
		return

	if(!affecting) //Missing limb?
		to_chat(user, "<span class='warning'>[C] nie ma tej części ciała: [strefa_pl(user.zone_selected)]!</span>")
		return

	if(stop_bleeding)
		if(!C.is_bleeding())
			if(C.is_bandaged()) //so you can't stack bleed suppression
				to_chat(user, "<span class='warning'>Krwawienie [C] jest już opatrzone!</span>")
			else
				to_chat(user, "<span class='warning'>[C] nie krwawi!</span>")
			return
		C.suppress_bloodloss(stop_bleeding)
		if(C.is_bleeding())
			C.balloon_alert(user, "krwawienie zmniejszone do [C.get_bleed_rate_string()]")
		else
			C.balloon_alert(user, "krwawienie zatamowane!")

	if(!IS_ORGANIC_LIMB(affecting))
		to_chat(user, "<span class='warning'>Lekarstwo nie zadziała na robotyczną kończynę!</span>")
		return

	if(!(affecting.brute_dam || affecting.burn_dam))
		to_chat(user, "<span class='warning'>[M] nie ma obrażeń w tej części ciała: [strefa_pl(user.zone_selected)]!</span>")
		return

	if((affecting.brute_dam && !affecting.burn_dam && !heal_brute) || (affecting.burn_dam && !affecting.brute_dam && !heal_burn)) //suffer
		to_chat(user, "<span class='warning'>Ten rodzaj lekarstwa nie nadaje się do tego rodzaju rany.</span>")
		return

	if(C == user)
		user.visible_message("<span class='notice'>[user] zaczyna nakładać na siebie [src]...</span>", "<span class='notice'>Zaczynasz nakładać na siebie [src]...</span>")
		if(!do_mob(user, M, self_delay))
			return

	user.visible_message("<span class='green'>[user] nakłada [src] na [M].</span>", "<span class='green'>Nakładasz [src] na [M].</span>")
	if(heal_brute) //AQUILA EDIT
		playsound(user.loc, 'aquila/sound/effects/suture.ogg', 100, 1) //AQUILA EDIT
	if(affecting.heal_damage(heal_brute, heal_burn) || stop_bleeding)
		C.update_damage_overlays()
		use(1)

// AQ EDIT - gauze, bruise packs and ointment removed: bandage, sutures and mesh in aquila/ replace them
