/obj/effect/forcefield/wizard/heretic
	name = "labyrinth pages"
	desc = "Chmura kartek wirujących w powietrzu, odpychających niewiernych z niemożliwą siłą."
	icon = 'aquila/icons/effects/heretic_lockmoon.dmi'
	icon_state = "lintel"
	timeleft = 15 SECONDS
	/// AQUILA - właśnie odrzucani: u nas rzucający musi być mobem, więc tg-owe sprawdzanie thrower zastępuje ta lista
	var/static/list/repulsed_movers = list()

/obj/effect/forcefield/wizard/heretic/CanAllowThrough(atom/movable/mover, border_dir)
	if(mover.throwing && (mover in repulsed_movers))
		return TRUE
	return ..()

/obj/effect/forcefield/wizard/heretic/Bumped(atom/movable/AM)
	. = ..()
	var/mob/living/bumpee = AM
	if(!istype(bumpee) || IS_HERETIC_OR_MONSTER(bumpee))
		return
	var/throwtarget = get_edge_target_turf(loc, get_dir(loc, get_step_away(bumpee, loc)))
	repulsed_movers |= bumpee
	if(!bumpee.safe_throw_at(throwtarget, 10, 10, null, callback = CALLBACK(src, PROC_REF(end_repulse), bumpee), force = MOVE_FORCE_EXTREMELY_STRONG))
		repulsed_movers -= bumpee
	visible_message(span_danger("[src] odrzuca [bumpee] w burzy papieru!"))

/obj/effect/forcefield/wizard/heretic/proc/end_repulse(atom/movable/thrown)
	repulsed_movers -= thrown

///A heretic item that spawns a barrier at the clicked turf, 3 uses
/obj/item/heretic_labyrinth_handbook
	name = "labyrinth handbook"
	desc = "Księga praw i przepisów Zamkniętego Labiryntu, spisana na nieznanym materiale. Jej strony wiją się i napinają, chcąc się wyrwać i uciec."
	icon = 'aquila/icons/obj/service/library.dmi'
	icon_state = "heretichandbook"
	force = 10
	damtype = BURN
	worn_icon_state = "book"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("uderza", "przeklina")
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/items/handling/book_drop.ogg'
	pickup_sound = 'sound/items/handling/book_pickup.ogg'
	///what type of barrier do we spawn when used
	var/barrier_type = /obj/effect/forcefield/wizard/heretic
	/// Current charges remaining
	var/charges = 5
	/// Max possible amount of charges
	var/max_charges = 5
	/// List that contains each timer for the charge
	var/list/charge_timers = list()
	/// How long before a charge is restored
	var/charge_time = 15 SECONDS

/obj/item/heretic_labyrinth_handbook/examine(mob/user)
	. = ..()
	if(!IS_HERETIC_OR_MONSTER(user))
		return
	. += span_hypnophrase("Tworzy barierę na dowolnym polu w zasięgu wzroku, przez którą przejść możesz tylko ty. Trwa 15 sekund.")
	. += span_notice("Pozostałe ładunki: <b>[charges]</b>.")

// AQUILA - tg interact_with_atom: z bliska tworzy barierę zamiast bić; przedmioty i stoły obsługujemy normalnie
/obj/item/heretic_labyrinth_handbook/pre_attack(atom/target, mob/living/user, params)
	if(isitem(target) || istype(target, /obj/structure/table) || istype(target, /obj/machinery/disposal))
		return ..()
	if(!..())
		return FALSE
	use_handbook(target, user)
	return FALSE

// AQUILA - tg ranged_interact_with_atom
/obj/item/heretic_labyrinth_handbook/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(proximity_flag)
		return
	use_handbook(target, user)

/// Tworzy barierę na polu celu (albo karze nie-heretyka)
/obj/item/heretic_labyrinth_handbook/proc/use_handbook(atom/interacting_with, mob/living/user)
	if(!IS_HERETIC(user))
		if(ishuman(user))
			var/mob/living/carbon/human/human_user = user
			to_chat(human_user, span_userdanger("Gdy wpatrujesz się w księgę, twój umysł płonie, a ból głowy narasta, jakby mózg stanął w ogniu!"))
			human_user.adjust_organ_loss(ORGAN_SLOT_BRAIN, 30, 190)
			human_user.add_mood_event("gates_of_mansus", /datum/mood_event/gates_of_mansus)
			human_user.dropItemToGround(src)
		return FALSE

	if(charges <= 0)
		balloon_alert(user, "brak ładunków!")
		return FALSE

	var/turf/turf_target = get_turf(interacting_with)
	if(isnull(turf_target))
		return FALSE
	if(locate(barrier_type) in turf_target)
		user.balloon_alert(user, "już zajęte!")
		return FALSE
	turf_target.visible_message(span_warning("Pojawia się burza papieru!"))
	new /obj/effect/temp_visual/paper_scatter(turf_target)
	playsound(turf_target, 'sound/effects/smoke.ogg', 30)
	new barrier_type(turf_target, null, user)
	charges--
	charge_timers.Add(addtimer(CALLBACK(src, PROC_REF(recharge)), charge_time, TIMER_STOPPABLE))
	return TRUE

/obj/item/heretic_labyrinth_handbook/proc/recharge()
	charges = min(charges+1, max_charges)
