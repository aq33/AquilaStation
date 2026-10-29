/* Beds... get your mind out of the gutter, they're for sleeping!
 * Contains:
 * 		Beds
 *		Roller beds
 */

/*
 * Beds
 */
/obj/structure/bed
	name = "łóżko"
	desc = "Można się na nim położyć, przespać albo do niego przypiąć."
	icon_state = "bed"
	icon = 'icons/obj/beds_chairs/beds.dmi'
	anchored = TRUE
	can_buckle = TRUE
	buckle_lying = 90
	resistance_flags = FLAMMABLE
	max_integrity = 100
	integrity_failure = 30
	dir = SOUTH
	var/buildstacktype = /obj/item/stack/sheet/iron
	var/buildstackamount = 2
	var/bolts = TRUE

// dir check for buckle_lying state
/obj/structure/bed/Initialize()
	RegisterSignal(src, COMSIG_ATOM_DIR_CHANGE, PROC_REF(dir_changed)) //This gets called later during initialization
	. = ..()

/obj/structure/bed/Destroy()
	UnregisterSignal(src, COMSIG_ATOM_DIR_CHANGE)
	return ..()

/obj/structure/bed/examine(mob/user)
	. = ..()
	if(bolts)
		. += "<span class='notice'>Trzyma się na kilku <b>śrubach</b>.</span>"

/obj/structure/bed/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(buildstacktype)
			new buildstacktype(loc,buildstackamount)
	..()

/obj/structure/bed/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/bed/wrench_act_secondary(mob/living/user, obj/item/weapon)
	if(flags_1&NODECONSTRUCT_1)
		return TRUE
	..()
	weapon.play_tool_sound(src)
	deconstruct(disassembled = TRUE)
	return TRUE

/obj/structure/bed/proc/dir_changed(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	switch(new_dir)
		if(WEST, SOUTH)
			buckle_lying = 90
		if(EAST, NORTH)
			buckle_lying = 270

/*
 * Roller beds
 */
/obj/structure/bed/roller
	name = "łóżko na kółkach"
	icon = 'icons/obj/beds_chairs/rollerbed.dmi'
	icon_state = "down"
	anchored = FALSE
	resistance_flags = NONE
	var/foldabletype = /obj/item/roller

/obj/structure/bed/roller/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/roller/robo))
		var/obj/item/roller/robo/R = W
		if(R.loaded)
			to_chat(user, "<span class='warning'>Już masz zadokowane łóżko na kółkach!</span>")
			return

		if(has_buckled_mobs())
			if(buckled_mobs.len > 1)
				unbuckle_all_mobs()
				user.visible_message("<span class='notice'>[user] odpina wszystkie istoty z [src].</span>")
			else
				user_unbuckle_mob(buckled_mobs[1],user)
		else
			R.loaded = src
			forceMove(R)
			user.visible_message("[user] składa [src].", "<span class='notice'>Zbierasz [src].</span>")
		return 1
	else
		return ..()

/obj/structure/bed/roller/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr))
		if(!ishuman(usr) || !usr.canUseTopic(src, BE_CLOSE))
			return 0
		if(has_buckled_mobs())
			return 0
		usr.visible_message("[usr] składa [src.name].", "<span class='notice'>Składasz [src.name].</span>")
		var/obj/structure/bed/roller/B = new foldabletype(get_turf(src))
		usr.put_in_hands(B)
		qdel(src)

/obj/structure/bed/roller/post_buckle_mob(mob/living/M)
	density = TRUE
	icon_state = "up"
	M.pixel_y = M.base_pixel_y

/obj/structure/bed/roller/Moved()
	. = ..()
	if(has_gravity())
		playsound(src, 'sound/effects/roll.ogg', 100, 1)

/obj/structure/bed/roller/post_unbuckle_mob(mob/living/M)
	density = FALSE
	icon_state = "down"
	M.pixel_x = M.base_pixel_x + M.get_standard_pixel_x_offset(M.lying)
	M.pixel_y = M.base_pixel_y + M.get_standard_pixel_y_offset(M.lying)

/obj/item/roller
	name = "łóżko na kółkach"
	desc = "Złożone łóżko na kółkach, które można nosić."
	icon = 'icons/obj/beds_chairs/rollerbed.dmi'
	icon_state = "folded"
	w_class = WEIGHT_CLASS_NORMAL // No more excuses, stop getting blood everywhere

/obj/item/roller/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/roller/robo))
		var/obj/item/roller/robo/R = I
		if(R.loaded)
			to_chat(user, "<span class='warning'>[R] ma już załadowane łóżko na kółkach!</span>")
			return
		user.visible_message("<span class='notice'>[user] ładuje [src].</span>", "<span class='notice'>Ładujesz [src] do [R].</span>")
		R.loaded = new/obj/structure/bed/roller(R)
		qdel(src) //"Load"
		return
	else
		return ..()

/obj/item/roller/attack_self(mob/user)
	deploy_roller(user, user.loc)

/obj/item/roller/afterattack(obj/target, mob/user , proximity)
	. = ..()
	if(!proximity)
		return
	if(isopenturf(target))
		deploy_roller(user, target)

/obj/item/roller/proc/deploy_roller(mob/user, atom/location)
	var/obj/structure/bed/roller/R = new /obj/structure/bed/roller(location)
	R.add_fingerprint(user)
	qdel(src)

/obj/item/roller/robo //ROLLER ROBO DA!
	name = "dok łóżka na kółkach"
	desc = "Złożone łóżko na kółkach, które można wysunąć w nagłym wypadku. Po użyciu trzeba je złożyć albo wymienić."
	var/obj/structure/bed/roller/loaded = null

/obj/item/roller/robo/Initialize(mapload)
	. = ..()
	loaded = new(src)

/obj/item/roller/robo/examine(mob/user)
	. = ..()
	. += "Dok jest [loaded ? "załadowany" : "pusty"]."

/obj/item/roller/robo/deploy_roller(mob/user, atom/location)
	if(loaded)
		loaded.forceMove(location)
		user.visible_message("[user] rozkłada [loaded].", "<span class='notice'>Rozkładasz [loaded].</span>")
		loaded = null
	else
		to_chat(user, "<span class='warning'>Dok jest pusty!</span>")

//Dog bed

/obj/structure/bed/dogbed
	name = "legowisko dla psa"
	icon_state = "dogbed"
	desc = "Wygodnie wyglądające legowisko dla psa. Możesz nawet przypiąć do niego zwierzaka, na wypadek gdyby wysiadła grawitacja."
	anchored = FALSE
	buildstacktype = /obj/item/stack/sheet/mineral/wood
	buildstackamount = 10
	var/owned = FALSE

/obj/structure/bed/dogbed/ian
	desc = "Legowisko Iana! Wygląda wygodnie."
	name = "legowisko Iana"
	anchored = TRUE

/obj/structure/bed/dogbed/cayenne
	desc = "Wygląda jakoś... podejrzanie rybio."
	name = "legowisko Cayenne"
	anchored = TRUE

/obj/structure/bed/dogbed/renault
	desc = "Legowisko Renault! Wygląda wygodnie. Lisia osoba potrzebuje lisiego zwierzaka."
	name = "legowisko Renault"
	anchored = TRUE

/obj/structure/bed/dogbed/runtime
	desc = "Wygodnie wyglądające legowisko dla kota. Możesz nawet przypiąć do niego zwierzaka, na wypadek gdyby wysiadła grawitacja."
	name = "legowisko Runtime"
	anchored = TRUE

/obj/structure/bed/dogbed/vector
	desc = "Legowisko Vectora! Chwila... Czy chomiki w ogóle mają legowiska...?"
	name = "legowisko Vectora"
	anchored = TRUE

/obj/structure/bed/dogbed/walter
	desc = "Legowisko Waltera! Cuchnie testosteronem i olejem silnikowym."
	name = "legowisko Waltera"
	anchored = TRUE

///Used to set the owner of a dogbed, returns FALSE if called on an owned bed or an invalid one, TRUE if the possesion succeeds
/obj/structure/bed/dogbed/proc/update_owner(mob/living/M)
	if(owned || type != /obj/structure/bed/dogbed) //Only marked beds work, this is hacky but I'm a hacky man
		return FALSE //Failed
	owned = TRUE
	name = "legowisko: [M]"
	desc = "Legowisko, które należy do: [M]. Wygląda wygodnie."
	return TRUE //Let any callers know that this bed is ours now

/obj/structure/bed/dogbed/buckle_mob(mob/living/M, force, check_loc)
	. = ..()
	update_owner(M)

/obj/structure/bed/alien
	name = "urządzenie do odpoczynku"
	desc = "Wygląda podobnie do zwykłego ziemskiego łóżka. Czyżby obcy kradli <b>naszą technologię</b>?"
	icon_state = "abed"

/obj/structure/bed/alien/examine(mob/user)
	. = ..()
	if(isabductor(user))
		. += "<span class='abductor'>Jesteśmy prawie pewni, że tę technologię zwyczajnie ukradliśmy.</span>"

//unfortunateley no sickness mechanics on them... yet
/obj/structure/bed/maint
	name = "brudny materac"
	desc = "Stary, zapuszczony materac. Starasz się nie myśleć, skąd mogły się wziąć te plamy."
	icon_state = "dirty_mattress"

//Double Beds, for luxurious sleeping, i.e. the captain and maybe heads - if people use this for ERP, send them to skyrat, or worse, acacia
/obj/structure/bed/double
	name = "łóżko małżeńskie"
	desc = "Luksusowe łóżko małżeńskie dla tych, którzy są zbyt ważni na małe sny."
	icon_state = "bed_double"
	buildstackamount = 4
	max_buckled_mobs = 2
	///The mob who buckled to this bed second, to avoid other mobs getting pixel-shifted before they unbuckles.
	var/mob/living/goldilocks

/obj/structure/bed/double/post_buckle_mob(mob/living/M)
	if(buckled_mobs.len > 1 && !goldilocks) //Push the second buckled mob a bit higher from the normal lying position, also, if someone can figure out the same thing for plushes, i'll be really glad to know how to
		M.pixel_y = initial(M.pixel_y) + 6
		goldilocks = M
		RegisterSignal(goldilocks, COMSIG_PARENT_QDELETING, PROC_REF(goldilocks_deleted))

/obj/structure/bed/double/post_unbuckle_mob(mob/living/M)
	M.pixel_y = initial(M.pixel_y) + M.get_standard_pixel_y_offset(M.lying)
	if(M == goldilocks)
		UnregisterSignal(goldilocks, COMSIG_PARENT_QDELETING)
		goldilocks = null

//Called when the signal is raised, removes the reference
//preventing the hard delete.
/obj/structure/bed/double/proc/goldilocks_deleted(datum/source, force)
	UnregisterSignal(goldilocks, COMSIG_PARENT_QDELETING)
	goldilocks = null

/obj/structure/bed/double/maint
	name = "podwójny brudny materac"
	desc = "Stary, zapuszczony materac królewskich rozmiarów. Naprawdę starasz się nie myśleć, skąd mogły się wziąć te plamy."
	icon_state = "dirty_mattress_double"

/obj/structure/bed/double/alien
	name = "podwójne urządzenie do odpoczynku"
	desc = "Wygląda podobnie do zwykłego ziemskiego łóżka małżeńskiego. Czyżby obcy kradli <b>naszą technologię</b>?"
	icon_state = "abed_double"

/obj/structure/bed/double/alien/examine(mob/user)
	. = ..()
	if(isabductor(user))
		. += "<span class='abductor'>Jesteśmy prawie pewni, że tę technologię zwyczajnie ukradliśmy... Po co my to w ogóle kradliśmy?</span>"
