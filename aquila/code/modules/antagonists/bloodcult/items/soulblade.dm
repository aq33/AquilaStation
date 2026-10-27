/obj/item/melee/soulblade
	name = "ostrze dusz"
	desc = "Obsydianowe ostrze z osadzonym klejnotem dusz, dzięki któremu potrafi chwytać dusze."
	icon = 'aquila/icons/bloodcult/cult_64x64.dmi'
	lefthand_file = 'aquila/icons/bloodcult/in_hands/swords_axes_l.dmi'
	righthand_file = 'aquila/icons/bloodcult/in_hands/swords_axes_r.dmi'
	item_state = "soulblade"
	SET_BASE_PIXEL(-16, -16)
	icon_state = "soulblade"
	w_class = WEIGHT_CLASS_BULKY
	force = 30//30 brute, plus 5 burn
	throwforce = 20
	sharpness = SHARP_EDGED
	var/mob/living/simple_animal/shade/shade = null
	var/blood = 0
	var/passivebloodregen = 0//increments every Life() proc of the Shade inside, and increases blood by 1 once it reaches the current blood count/3
	var/maxblood = 100
	var/movespeed = 2//smaller = faster
	max_integrity = 60
	var/reflector = FALSE
	var/mob/living/linked_cultist = null

/obj/item/melee/soulblade/Destroy()
	var/turf/T = get_turf(src)
	if (istype(loc, /obj/item/projectile))
		qdel(loc)

	if (shade)
		shade.remove_blade_powers()
		if (T)
			shade.soulblade_ritual = FALSE
			shade.forceMove(T)
			shade.status_flags &= ~GODMODE // AQUILA - u nas nieśmiertelność to flaga GODMODE (w drafcie TRAIT_GODMODE na ostrzu)
			//shade.canmove = 1
			shade.cancel_camera()
			var/datum/control/C = shade.control_object
			if(C)
				C.break_control()
				qdel(C)
		else
			qdel(shade)


	if (T)
		var/obj/item/melee/cultblade/nocult/B = new (T)
		B.Move(get_step_rand(T))
		new /obj/item/soulstone(T)
	shade = null
	linked_cultist = null
	..()

/obj/item/melee/soulblade/attack_hand(mob/living/user)
	if (shade)
		if (IS_CULTIST(user) && (linked_cultist != user))
			linked_cultist = user
			to_chat(shade, span_notice("Nawiązujesz kontakt z [user]. Dopóki jesteś w promieniu 5 pól od tej osoby, możesz poruszać się sam bez utraty krwi i szybciej odnawiasz krew."))
	..()

/obj/item/melee/soulblade/salt_act()
	qdel(src)


/obj/item/melee/soulblade/examine(mob/user)
	. = ..()
	if (areYouWorthy(user))
		. += span_info("krew w ostrzu: [blood]%")
		. += span_info("stan ostrza: [round((obj_integrity/max_integrity)*100)]%")


/obj/item/melee/soulblade/narsie_act()
	return

/obj/item/melee/soulblade/attack_self(mob/living/user)
	var/choices = list(
		list("Oddaj krew", "radial_giveblood", "Przelej trochę swojej krwi do [src], by je naprawić i uzupełnić jego krew. Możesz też po prostu kogoś ciąć."),
		list("Wyjmij klejnot", "radial_removegem", "Wyjmij klejnot dusz z ostrza."),
		)

	if (!areYouWorthy(user))
		choices = list(
			list("Wyjmij klejnot", "radial_removegem", "Wyjmij klejnot dusz z [src]."),
			)

	var/list/made_choices = list()
	for(var/list/choice in choices)
		var/datum/radial_menu_choice/option = new
		option.image = image(icon = 'aquila/icons/bloodcult/cult_radial3.dmi', icon_state = choice[2])
		option.info = span_boldnotice(choice[3])
		made_choices[choice[1]] = option

	var/task = show_radial_menu(user, user, made_choices, tooltips = TRUE, radial_icon = 'aquila/icons/bloodcult/cult_radial3.dmi')//spawning on loc so we aren't offset by pixel_x/pixel_y, or affected by animate()
	var/obj/item/active_hand_item = user.get_active_held_item()
	if (active_hand_item != src)
		to_chat(user, span_warning("Musisz trzymać [src] w aktywnej ręce.") )
		return
	switch (task)
		if ("Oddaj krew")
			var/data = use_available_blood(user, 10)
			if (data[BLOODCOST_RESULT] != BLOODCOST_FAILURE)
				blood = min(maxblood, blood+35)//reminder that the blade cannot give blood back to their wielder, so this should prevent some exploits
				obj_integrity = min(obj_integrity, max_integrity+10)
				update_icon()
		if ("Wyjmij klejnot")
			if (!areYouWorthy(user) && shade && ((IS_CULTIST(shade) && !IS_CULTIST(user))))
				shade.say("Dedo ol'btoh!")
				user.take_overall_damage(25, 25)
				if (iscarbon(user))
					user.bodytemperature += 60
				playsound(user.loc, 'aquila/sound/bloodcult/bloodboil.ogg', 50, 0, -1)
				to_chat(user, span_danger("Udaje ci się wyłuskać klejnot z [src], ale fala okultystycznej energii ostrza sprawia, że krew się w tobie gotuje!") )
			var/turf/T = get_turf(user)
			playsound(T, 'sound/items/Deconstruct.ogg', 50, 0, -3)
			user.dropItemToGround(src)
			var/obj/item/melee/cultblade/CB = new (T)
			var/obj/item/soulstone/gem/SG = new (T)
			user.put_in_active_hand(CB)
			user.put_in_inactive_hand(SG)
			if (shade)
				shade.forceMove(SG)
				SG.contents += shade
				shade.remove_blade_powers()
				shade.soulblade_ritual = FALSE
				SG.icon_state = "soulstone2"
				SG.name = "klejnot dusz: [shade.real_name]"
				shade = null
			loc = null//so we won't drop a broken blade and shard
			qdel(src)

/obj/item/melee/soulblade/attack(mob/living/target, mob/living/carbon/human/user)
	if(!areYouWorthy(user))
		user.Paralyze(5)
		to_chat(user, span_warning("Niewytłumaczalna siła z mocą odpycha [src] od [target]!") )
		user.adjustFireLoss(5)
		return
	if (IS_CULTIST(user) && !IS_CULTIST(target) && !target.stat == DEAD)
		var/datum/antagonist/cult/cult_datum = user.mind.has_antag_datum(/datum/antagonist/cult)
		if (target.mind)
			cult_datum.gain_devotion(30, DEVOTION_TIER_3, "attack_soulblade", target)
		else
			cult_datum.gain_devotion(30, DEVOTION_TIER_2, "attack_soulblade_nomind", target)
	if (ishuman(target) && target.resting)
		var/obj/structure/cult/altar/altar = locate() in target.loc
		if (altar)
			altar.attackby(src, user)
			return
	..()


/obj/item/melee/soulblade/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag)
		return
	if (HAS_TRAIT(user, TRAIT_PACIFISM))
		return

	if (blood >= 5)
		blood = max(0, blood-5)
		update_icon()
		var/turf/starting = get_turf(user)
		var/obj/item/projectile/bloodslash/blood_slash = new (starting)
		blood_slash.preparePixelProjectile(target, user)
		if(user.zone_selected)
			blood_slash.def_zone = user.zone_selected
		else
			blood_slash.def_zone = BODY_ZONE_CHEST
		blood_slash.fire(direct_target = target)
		playsound(starting, 'aquila/sound/bloodcult/forge.ogg', 100, 1)
		blood_slash.process()

/obj/item/melee/soulblade/attack(mob/living/attacked, mob/living/carbon/human/user)
	. = ..()
	if (ismob(attacked))
		var/mob/living/M = attacked
		M.adjustFireLoss(5)
		if (iscarbon(M))
			var/mob/living/carbon/C = M
			if (C.stat != DEAD)
				C.blood_volume -= 10
				blood = min(100, blood+20)
				to_chat(user, span_warning("Kradniesz trochę ich krwi!") )
			else
				C.blood_volume -= 5
				blood = min(100, blood+10)
				to_chat(user, span_warning("Kradniesz odrobinę ich krwi, ale niewiele.") )
			update_icon()
			if (shade)
				shade.DisplayUI("Soulblade")
		else if (M.blood_volume)
			var/mob/living/simple_animal/SA = M
			if (SA.stat != DEAD)
				blood = min(100, blood+20)
				to_chat(user, span_warning("Kradniesz trochę ich krwi!") )
			else
				blood = min(100, blood+10)
				to_chat(user, span_warning("Kradniesz odrobinę ich krwi, ale niewiele.") )
			update_icon()
			if (shade)
				shade.DisplayUI("Soulblade")


/obj/item/melee/soulblade/pickup(mob/living/user)
	..()
	if(!areYouWorthy(user))
		to_chat(user, span_warning("Gdy podnosisz [src], ogarnia cię przytłaczające uczucie grozy. Rozsądnie byłoby szybko się tego pozbyć.") )
		user.adjust_dizzy(120)
	else
		user.adjust_dizzy(-120)
	update_icon()

/obj/item/melee/soulblade/proc/areYouWorthy(mob/living/user)
	if (IS_CULTIST(user))
		return TRUE
	else if (!shade)
		return FALSE
	else if (user == shade)
		return TRUE
	else if (user == shade.master)
		return TRUE
	return FALSE

/obj/item/melee/soulblade/dropped(mob/user)
	..()
	update_icon()

/obj/item/melee/soulblade/update_icon()
	. = ..()
	overlays.len = 0
	animate(src, pixel_y = -16 * 1, time = 3, easing = SINE_EASING)
	shade = locate() in src
	if (shade)
		plane = HUD_PLANE//let's keep going and see where this takes us
		icon_state = "soulblade-full"
		animate(src, pixel_y = -8 * 1 , time = 7, loop = -1, easing = SINE_EASING)
		animate(pixel_y = -12 * 1, time = 7, loop = -1, easing = SINE_EASING)
	else
		if (!ismob(loc))
			plane = initial(plane)
			layer = initial(layer)
		icon_state = "soulblade"

	if (istype(loc, /mob/living/carbon))
		var/mob/living/carbon/C = loc
		if (areYouWorthy(C))
			var/image/I = image('aquila/icons/bloodcult/hud.dmi', src, "consthealth[10*round((blood/maxblood)*10)]")
			I.pixel_x = 16
			I.pixel_y = 16
			overlays += I


/obj/item/melee/soulblade/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force = MOVE_FORCE_STRONG, gentle = FALSE, quickstart = TRUE)
	var/turf/starting = get_turf(src)
	var/turf/second_target = target
	var/obj/item/projectile/soulbullet/soul_bullet = new (starting)
	soul_bullet.firer = thrower
	soul_bullet.def_zone = ran_zone(thrower.zone_selected)
	soul_bullet.preparePixelProjectile(target, starting)
	soul_bullet.secondary_target = second_target
	soul_bullet.shade = shade
	soul_bullet.blade = src
	src.forceMove(soul_bullet)
	soul_bullet.fire()
	soul_bullet.process()

/obj/item/melee/soulblade/ex_act(severity)
	switch(severity)
		if (1)
			takeDamage(100)
		if (2)
			takeDamage(40)
		if (3)
			takeDamage(20)

/obj/item/melee/soulblade/proc/takeDamage(damage)
	if (!damage)
		return
	obj_integrity -= damage
	if (obj_integrity <= 0)
		playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		qdel(src)
	else
		playsound(loc, pick('sound/items/trayhit1.ogg', 'sound/items/trayhit2.ogg'), 70, 1)

/obj/item/melee/soulblade/attackby(obj/item/I, mob/user)
	if (HAS_TRAIT(user, TRAIT_PACIFISM))
		return
	if(I.force)
		var/damage = I.force
		takeDamage(damage)
		user.visible_message(span_danger("[user] atakuje [src] za pomocą [I].") )

/obj/item/melee/soulblade/hitby(atom/movable/hitting_atom, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(.)
		return

	visible_message(span_warning("[hitting_atom] trafia w [src].") )
	if (isobj(hitting_atom))
		var/obj/O = hitting_atom
		takeDamage(O.throwforce)

/obj/item/melee/soulblade/proc/capture_shade(mob/living/simple_animal/shade/target, mob/user)

	if(shade)
		to_chat(user, "<span class='danger'>Nie udało się złapać!: </span>[capitalize(src.name)] ma już cień! Wyjmij klejnot dusz, jeśli mimo to chcesz skrzywdzić tego cienia.")
	else
		target.forceMove(src) //put shade in blade
		target.status_flags |= GODMODE // AQUILA - u nas nieśmiertelność to flaga GODMODE (w drafcie TRAIT_GODMODE na ostrzu)
		target.health = target.maxHealth//full heal
		target.give_blade_powers()
		shade = target
		dir = NORTH
		update_icon()
		to_chat(target, "Ostrze dusz pochwyciło twoją duszę, a jego tajemne energie splatają na nowo twoją eteryczną postać i cię leczą.")
		to_chat(user, "<span class='notice'><b>Złapano!</b>: </span>[target.real_name] został pochwycony i zamknięty w klejnocie twojego ostrza.")
		target.master = user

		//Is our user a cultist? Then you're a cultist too now!
		if (IS_CULTIST(user) && !IS_CULTIST(target))
			var/datum/team/cult/cult = locate_team(/datum/team/cult)
			if (cult && !cult.CanConvert())
				to_chat(user, span_danger("Kult ma już zbyt wielu członków. Ten cień i tak będzie ci jednak posłuszny.") )
				return
			// AQUILA - draft robił new(target.mind), co nie dodaje antagonisty do umysłu
			var/datum/antagonist/cult/newCultist = target.mind.add_antag_datum(/datum/antagonist/cult)
			cult.HandleRecruitedRole(newCultist)
			//newCultist.Greet(GREET_SOULSTONE)
			newCultist.conversion["soulstone"] = user
