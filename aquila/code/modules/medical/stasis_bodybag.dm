// AQUILA - stasis body bag from tgstation (code/game/objects/structures/crates_lockers/closets/bodybag.dm,
// code/game/objects/items/tools/medical/bodybag.dm). After 5 seconds inside the patient is put in stasis and put out,
// loose organs inside do not rot. Outside of the cold the bag wears out in about two minutes and falls apart.
// No own cold air (our closets share the turf air) and no wriggling out: an unlocked bag opens at once.
// Sprites from tgstation (CC-BY-SA 3.0).

/obj/item/bodybag/stasis
	name = "worek stazy"
	desc = "Jednorazowy worek, który utrzymuje zawartość w stazie, chroniąc ją przed rozkładem i dalszymi obrażeniami. \
		Sam worek nie wytrzyma długo i w końcu się rozpadnie."
	icon = 'aquila/icons/obj/medical/medical_tg.dmi'
	icon_state = "stasis_bag_folded"
	unfoldedbag_path = /obj/structure/closet/body_bag/stasis
	max_integrity = 300

/obj/item/bodybag/stasis/deploy_bodybag(mob/user, atom/location)
	. = ..()
	for(var/obj/structure/closet/body_bag/stasis/bag in location)
		if(bag.foldedbag_instance == src)
			bag.obj_integrity = obj_integrity
			bag.update_stasis_filter()

/obj/structure/closet/body_bag/stasis
	name = "worek stazy"
	desc = "Jednorazowy worek, który utrzymuje zawartość w stazie, chroniąc ją przed rozkładem i dalszymi obrażeniami. \
		Sam worek nie wytrzyma długo i w końcu się rozpadnie."
	icon = 'aquila/icons/obj/medical/bodybag_stasis.dmi'
	icon_state = "holobag_med"
	foldedbag_path = /obj/item/bodybag/stasis
	max_integrity = 300
	material_drop = /obj/item/stack/sheet/plastic
	appearance_flags = TILE_BOUND|PIXEL_SCALE|LONG_GLIDE|KEEP_TOGETHER
	/// How long the current occupant has been inside, -1 when empty
	var/seconds_freezing = -1
	/// Mobs this bag put in stasis, only they are thawed when they leave
	var/list/mob/living/frozen_mobs
	/// tgstation colour filter, fades as the bag wears out
	var/static/list/base_color_filter = list(
		1, 0, 0,
		0, 1, 0,
		0, 0, 2,
		0, 0, 0,
	)

/obj/structure/closet/body_bag/stasis/Initialize(mapload)
	. = ..()
	update_stasis_filter()

/obj/structure/closet/body_bag/stasis/Destroy()
	STOP_PROCESSING(SSobj, src)
	for(var/mob/living/frozen as anything in frozen_mobs)
		thaw(frozen)
	if(foldedbag_instance)
		foldedbag_instance.obj_integrity = obj_integrity
	return ..()

/obj/structure/closet/body_bag/stasis/examine(mob/user)
	. = ..()
	switch(100 * obj_integrity / max_integrity)
		if(50 to 75)
			. += "<span class='warning'>Wygląda na zużyty.</span>"
		if(25 to 50)
			. += "<span class='warning'>Jest mocno zużyty.</span>"
		if(0 to 25)
			. += "<span class='boldwarning'>Rozpada się!</span>"

/obj/structure/closet/body_bag/stasis/proc/update_stasis_filter()
	var/damage_percent = 1 - obj_integrity / max_integrity
	var/list/new_color_filter = base_color_filter.Copy()
	new_color_filter[1] -= 0.5 * damage_percent
	new_color_filter[5] -= 0.5 * damage_percent
	new_color_filter[9] -= 1.25 * damage_percent
	add_filter("stasis_color", 1, color_matrix_filter(new_color_filter))

/obj/structure/closet/body_bag/stasis/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(isorgan(arrived))
		var/obj/item/organ/organ = arrived
		organ.organ_flags |= ORGAN_FROZEN
	else if(isbodypart(arrived))
		for(var/obj/item/organ/organ in arrived)
			organ.organ_flags |= ORGAN_FROZEN
	else if(isliving(arrived) && seconds_freezing == -1)
		seconds_freezing = 0
		START_PROCESSING(SSobj, src)

/obj/structure/closet/body_bag/stasis/Exited(atom/movable/gone, direction)
	. = ..()
	if(isorgan(gone))
		var/obj/item/organ/organ = gone
		organ.organ_flags &= ~ORGAN_FROZEN
	else if(isbodypart(gone))
		for(var/obj/item/organ/organ in gone)
			organ.organ_flags &= ~ORGAN_FROZEN
	else if(isliving(gone))
		thaw(gone)
		if(!(locate(/mob/living) in src))
			seconds_freezing = -1
			STOP_PROCESSING(SSobj, src)

/obj/structure/closet/body_bag/stasis/process(delta_time)
	var/mob/living/freezing = locate() in src
	if(!freezing)
		seconds_freezing = -1
		return PROCESS_KILL
	seconds_freezing += delta_time
	if(seconds_freezing > 3 && freezing.on_fire)
		freezing.ExtinguishMob()
	if(seconds_freezing > 5)
		for(var/mob/living/inside in src)
			if(!(inside in frozen_mobs))
				freeze(inside)
	if(DT_PROB(2 * (seconds_freezing / 60), delta_time))
		freezing.Unconscious(1 SECONDS)
	var/datum/gas_mixture/air = loc?.return_air()
	if(air?.return_temperature() > T0C)
		take_damage(max_integrity * 0.008 * delta_time, BRUTE, 0, FALSE)
		if(!QDELETED(src))
			update_stasis_filter()

/obj/structure/closet/body_bag/stasis/proc/freeze(mob/living/target)
	if(target.IsInStasis())
		return
	LAZYADD(frozen_mobs, target)
	target.SetStasis(TRUE)
	playsound(src, 'sound/effects/spray.ogg', 25, TRUE, frequency = 0.5)
	if(target.stat == CONSCIOUS)
		to_chat(target, "<span class='notice'>Czujesz chłodne, odrętwiające zimno...</span>")

/obj/structure/closet/body_bag/stasis/proc/thaw(mob/living/target)
	if(!(target in frozen_mobs))
		return
	LAZYREMOVE(frozen_mobs, target)
	target.SetStasis(FALSE)
	if(target.stat == CONSCIOUS)
		to_chat(target, "<span class='notice'>Znów czujesz palce u rąk i nóg.</span>")

/obj/structure/closet/body_bag/stasis/obj_destruction(damage_flag)
	visible_message("<span class='warning'>[src] rozpruwa się na nitki!</span>")
	playsound(src, 'sound/items/poster_ripped.ogg', 50, TRUE)
	for(var/mob/living/left_behind in src)
		left_behind.Knockdown(3 SECONDS)
	return ..()
