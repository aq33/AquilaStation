// AQUILA - reszta rodzajów zaklęć z tgstation potrzebna heretykowi: pociski, przenikanie (jaunt), przemiana,
// ładowane/wiązki, przywoływanie. Nazwy zmiennych i procedur jak w tg, żeby kod z tg pasował bez przeróbek.

#define CHANNEL_CHARGED_SPELL 1009

/datum/action/cooldown/spell
	/// tg: szkoła magii (u nas tylko informacyjnie)
	var/school = SCHOOL_UNSET
	/// tg: poziom zaklęcia czarodzieja
	var/spell_level = 1
	/// tg: najwyższy poziom
	var/spell_max_level = 5
	/// tg: skrócenie odnowienia na poziom
	var/cooldown_reduction_per_rank = 0
	/// tg: dym przy rzuceniu (typ /datum/effect_system/smoke_spread)
	var/smoke_type
	/// tg: zasięg dymu
	var/smoke_amt = 0
	/// tg: szansa na zniekształcenie inkantacji (u nas bez efektu)
	var/garbled_invocation_prob = 50
	/// tg: obramówka przycisku (u nas bez efektu)
	var/overlay_icon_state
	/// tg: obramówka aktywnego przycisku (u nas bez efektu)
	var/active_overlay_icon_state

/// tg: rzucający dla zaklęć bez celowania. U nas zawsze sam cel.
/datum/action/cooldown/spell/proc/get_caster_from_target(atom/target)
	if(isnull(target?.loc))
		return null
	return target

/datum/action/cooldown/spell/proc/level_spell(bypass_cap = FALSE)
	if(spell_max_level <= 1)
		return FALSE
	if(!bypass_cap && (spell_level >= spell_max_level))
		return FALSE
	spell_level++
	cooldown_time = max(cooldown_time - cooldown_reduction_per_rank, 0.25 SECONDS)
	name = "[get_spell_title()][initial(name)]"
	UpdateButtonIcon()
	return TRUE

/datum/action/cooldown/spell/proc/delevel_spell()
	if(spell_max_level <= 1 || spell_level <= 1)
		return FALSE
	spell_level--
	if(cooldown_reduction_per_rank > 0)
		cooldown_time = min(cooldown_time + cooldown_reduction_per_rank, initial(cooldown_time))
	else
		cooldown_time = max(cooldown_time + cooldown_reduction_per_rank, initial(cooldown_time))
	name = "[get_spell_title()][initial(name)]"
	UpdateButtonIcon()
	return TRUE

/datum/action/cooldown/spell/proc/get_spell_title()
	switch(spell_level)
		if(2)
			return "Efficient "
		if(3)
			return "Quickened "
		if(4)
			return "Free "
		if(5)
			return "Instant "
		if(6)
			return "Ludicrous "
	return ""

/// tg: odświeżenie przycisków akcji. U nas jeden przycisk.
/datum/action/proc/build_all_button_icons(update_flags, force = FALSE)
	UpdateButtonIcon(force = force)

// Pociski: kliknięcie w cel wystrzeliwuje pocisk

/datum/action/cooldown/spell/pointed/projectile
	/// Typ pocisku
	var/obj/item/projectile/projectile_type = /obj/item/projectile/magic
	/// Ile strzałów na jedno włączenie
	var/projectile_amount = 1
	/// Ile strzałów zostało
	var/current_amount = 0
	/// Ile pocisków na strzał
	var/projectiles_per_fire = 1

/datum/action/cooldown/spell/pointed/projectile/New(Target)
	. = ..()
	if(projectile_amount > 1)
		unset_after_click = FALSE

/datum/action/cooldown/spell/pointed/projectile/is_valid_target(atom/cast_on)
	return TRUE

/datum/action/cooldown/spell/pointed/projectile/on_activation(mob/on_who)
	. = ..()
	if(!.)
		return
	current_amount = projectile_amount

/datum/action/cooldown/spell/pointed/projectile/on_deactivation(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(projectile_amount > 1 && current_amount)
		StartCooldown(cooldown_time * ((projectile_amount - current_amount) / projectile_amount))
		current_amount = 0

/datum/action/cooldown/spell/pointed/projectile/cast(atom/cast_on)
	. = ..()
	var/atom/caster = get_caster_from_target(owner)
	if(!isturf(caster?.loc))
		return FALSE
	fire_projectile(cast_on)
	owner.newtonian_move(get_dir(cast_on, owner))
	if(current_amount <= 0)
		unset_click_ability(owner, refund_cooldown = FALSE)
	return TRUE

/datum/action/cooldown/spell/pointed/projectile/after_cast(atom/cast_on)
	. = ..()
	if(current_amount > 0)
		reset_spell_cooldown()

/datum/action/cooldown/spell/pointed/projectile/proc/fire_projectile(atom/target)
	current_amount--
	for(var/i in 1 to projectiles_per_fire)
		var/obj/item/projectile/to_fire = new projectile_type(get_turf(owner))
		ready_projectile(to_fire, target, owner, i)
		SEND_SIGNAL(owner, COMSIG_MOB_SPELL_PROJECTILE, src, target, to_fire)
		to_fire.fire()
	return TRUE

/datum/action/cooldown/spell/pointed/projectile/proc/ready_projectile(obj/item/projectile/to_fire, atom/target, mob/user, iteration)
	to_fire.firer = owner
	to_fire.fired_from = owner
	to_fire.aim_projectile(target, owner)
	RegisterSignal(to_fire, COMSIG_PROJECTILE_SELF_ON_HIT, PROC_REF(on_cast_hit))

/datum/action/cooldown/spell/pointed/projectile/proc/on_cast_hit(datum/source, mob/firer, atom/target, angle, hit_limb)
	SIGNAL_HANDLER
	SEND_SIGNAL(src, COMSIG_SPELL_PROJECTILE_HIT, source, firer, target, angle, hit_limb)

/// tg: ustawia pocisk w stronę celu
/obj/item/projectile/proc/aim_projectile(atom/target, atom/source, list/modifiers, deviation = 0)
	preparePixelProjectile(target, source, null, deviation)

/// Pocisk w stronę, w którą patrzy rzucający
/datum/action/cooldown/spell/basic_projectile
	/// Jak daleko celujemy
	var/projectile_range = 7
	/// Typ pocisku
	var/obj/item/projectile/projectile_type = /obj/item/projectile/magic

/datum/action/cooldown/spell/basic_projectile/cast(atom/cast_on)
	. = ..()
	var/turf/target_turf = get_turf(cast_on)
	for(var/i in 1 to projectile_range - 1)
		var/turf/next_turf = get_step(target_turf, cast_on.dir)
		if(!next_turf || next_turf.density)
			break
		target_turf = next_turf
	fire_projectile(target_turf, cast_on)

/datum/action/cooldown/spell/basic_projectile/proc/fire_projectile(atom/target, atom/caster)
	var/obj/item/projectile/to_fire = new projectile_type(get_turf(caster))
	to_fire.firer = caster
	to_fire.aim_projectile(target, caster)
	SEND_SIGNAL(caster, COMSIG_MOB_SPELL_PROJECTILE, src, target, to_fire)
	to_fire.fire()
	return to_fire

// Przenikanie (jaunt): rzucający znika w obiekcie-pojemniku i porusza się przez ściany

/datum/action/cooldown/spell/jaunt
	school = SCHOOL_TRANSMUTATION
	invocation_type = INVOCATION_NONE
	spell_requirements = SPELL_CASTABLE_WHILE_PHASED
	/// Typ pojemnika
	var/jaunt_type = /obj/effect/dummy/phased_mob/tg

/datum/action/cooldown/spell/jaunt/before_cast(atom/cast_on)
	return ..() | SPELL_NO_FEEDBACK

/datum/action/cooldown/spell/jaunt/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	var/area/owner_area = get_area(owner)
	var/turf/owner_turf = get_turf(owner)
	if(!owner_area || !owner_turf)
		return FALSE
	if((owner_area.teleport_restriction == TELEPORT_ALLOW_NONE) && !istype(owner.loc, jaunt_type))
		if(feedback)
			to_chat(owner, "<span class='danger'>Jakaś tępa, wszechobecna siła nie pozwala ci tu przeniknąć.</span>")
		return FALSE
	if(owner_turf.flags_1 & NOJAUNT_1)
		if(feedback)
			to_chat(owner, "<span class='danger'>Nieziemska siła nie pozwala ci tu przeniknąć.</span>")
		return FALSE
	return isliving(owner)

/datum/action/cooldown/spell/jaunt/proc/enter_jaunt(mob/living/jaunter, turf/loc_override)
	SHOULD_CALL_PARENT(TRUE)
	var/obj/effect/dummy/phased_mob/tg/jaunt = new jaunt_type(loc_override || get_turf(jaunter), jaunter)
	RegisterSignal(jaunt, COMSIG_MOB_EJECTED_FROM_JAUNT, PROC_REF(on_jaunt_exited))
	ADD_TRAIT(jaunter, TRAIT_MAGICALLY_PHASED, REF(src))
	spell_feedback()
	SEND_SIGNAL(jaunter, COMSIG_MOB_ENTER_JAUNT, src, jaunt)
	return jaunt

/datum/action/cooldown/spell/jaunt/proc/exit_jaunt(mob/living/unjaunter, turf/loc_override)
	SHOULD_CALL_PARENT(TRUE)
	var/obj/effect/dummy/phased_mob/tg/jaunt = unjaunter?.loc
	if(!istype(jaunt))
		return FALSE
	if(jaunt.jaunter != unjaunter)
		CRASH("Jaunt spell attempted to exit_jaunt with an invalid unjaunter, somehow.")
	if(loc_override)
		jaunt.forceMove(loc_override)
	jaunt.eject_jaunter()
	return TRUE

/datum/action/cooldown/spell/jaunt/proc/on_jaunt_exited(obj/effect/dummy/phased_mob/tg/jaunt, mob/living/unjaunter)
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)
	REMOVE_TRAIT(unjaunter, TRAIT_MAGICALLY_PHASED, REF(src))
	SEND_SIGNAL(unjaunter, COMSIG_MOB_AFTER_EXIT_JAUNT, src)

/datum/action/cooldown/spell/jaunt/proc/is_jaunting(atom/thing)
	return istype(thing?.loc, /obj/effect/dummy/phased_mob/tg)

/datum/action/cooldown/spell/jaunt/Remove(mob/living/remove_from)
	exit_jaunt(remove_from)
	if(!is_jaunting(remove_from))
		return ..()
	var/obj/effect/dummy/phased_mob/tg/jaunt = remove_from.loc
	jaunt.eject_jaunter()
	return ..()

/// Przenikanie czarodzieja: na kilka sekund, wychodzi w ostatnim wolnym miejscu
/datum/action/cooldown/spell/jaunt/ethereal_jaunt
	name = "Ethereal Jaunt"
	desc = "This spell turns your form ethereal, temporarily making you invisible and able to pass through walls."
	button_icon_state = "jaunt"
	sound = 'sound/magic/ethereal_enter.ogg'
	cooldown_time = 30 SECONDS
	cooldown_reduction_per_rank = 5 SECONDS
	jaunt_type = /obj/effect/dummy/phased_mob/tg/spell_jaunt
	/// Dźwięk wyjścia
	var/exit_jaunt_sound = 'sound/magic/ethereal_exit.ogg'
	/// Jak długo trwa
	var/jaunt_duration = 5 SECONDS
	/// Jak długo trwa wyłanianie się
	var/jaunt_in_time = 0.5 SECONDS
	/// Efekt wyłaniania
	var/obj/effect/jaunt_in_type = /obj/effect/temp_visual/wizard
	/// Efekt znikania
	var/obj/effect/jaunt_out_type = /obj/effect/temp_visual/wizard/out
	/// Ostatnie wolne pola (do wyjścia)
	var/list/exit_point_list

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/enter_jaunt(mob/living/jaunter, turf/loc_override)
	. = ..()
	if(!.)
		return
	var/turf/cast_turf = get_turf(.)
	new jaunt_out_type(cast_turf, jaunter.dir)
	jaunter.ExtinguishMob()
	do_steam_effects(cast_turf)

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/cast(mob/living/cast_on)
	. = ..()
	do_jaunt(cast_on)

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/proc/do_jaunt(mob/living/cast_on)
	var/obj/effect/dummy/phased_mob/tg/holder = enter_jaunt(cast_on)
	if(!holder)
		CRASH("[type] attempted do_jaunt but failed to create a jaunt holder via enter_jaunt.")
	LAZYINITLIST(exit_point_list)
	RegisterSignal(holder, COMSIG_MOVABLE_MOVED, PROC_REF(update_exit_point))
	addtimer(CALLBACK(src, PROC_REF(stop_jaunt), cast_on, holder, get_turf(holder)), jaunt_duration)

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/proc/stop_jaunt(mob/living/cast_on, obj/effect/dummy/phased_mob/tg/spell_jaunt/holder, turf/start_point)
	if(QDELETED(cast_on) || QDELETED(holder) || QDELETED(src))
		return
	UnregisterSignal(holder, COMSIG_MOVABLE_MOVED)
	if(cast_on.loc != holder)
		qdel(holder)
		return
	var/turf/found_exit
	for(var/turf/possible_exit as anything in exit_point_list)
		if(is_blocked_turf(possible_exit))
			continue
		found_exit = possible_exit
		break
	if(!found_exit)
		if(get_turf(cast_on) != start_point)
			to_chat(cast_on, "<span class='danger'>Nie ma wolnego miejsca, więc zostajesz wyrwany z powrotem tam, skąd zacząłeś.</span>")
		found_exit = start_point
	exit_point_list = null
	holder.forceMove(found_exit)
	do_steam_effects(found_exit)
	holder.reappearing = TRUE
	if(exit_jaunt_sound)
		playsound(found_exit, exit_jaunt_sound, 50, TRUE)
	ADD_TRAIT(cast_on, TRAIT_IMMOBILIZED, REF(src))
	if(2.5 SECONDS - jaunt_in_time <= 0)
		do_jaunt_in(cast_on, holder, found_exit)
	else
		addtimer(CALLBACK(src, PROC_REF(do_jaunt_in), cast_on, holder, found_exit), 2.5 SECONDS - jaunt_in_time)

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/proc/do_jaunt_in(mob/living/cast_on, obj/effect/dummy/phased_mob/tg/spell_jaunt/holder, turf/final_point)
	if(QDELETED(cast_on) || QDELETED(holder) || QDELETED(src))
		return
	new jaunt_in_type(final_point, holder.dir)
	cast_on.setDir(holder.dir)
	if(jaunt_in_time > 0)
		cast_on.Immobilize(jaunt_in_time, ignore_canstun = TRUE)
		addtimer(CALLBACK(src, PROC_REF(end_jaunt), cast_on, holder, final_point), jaunt_in_time)
	else
		end_jaunt(cast_on, holder, final_point)

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/proc/end_jaunt(mob/living/cast_on, obj/effect/dummy/phased_mob/tg/spell_jaunt/holder, turf/final_point)
	if(QDELETED(cast_on) || QDELETED(holder) || QDELETED(src))
		return
	exit_jaunt(cast_on)
	REMOVE_TRAIT(cast_on, TRAIT_IMMOBILIZED, REF(src))
	if(final_point.density)
		var/list/aside_turfs = get_adjacent_open_turfs(final_point)
		if(length(aside_turfs))
			cast_on.forceMove(pick(aside_turfs))

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/proc/update_exit_point(atom/movable/source)
	SIGNAL_HANDLER
	var/turf/location = get_turf(source)
	if(is_blocked_turf(location))
		return
	exit_point_list.Insert(1, location)
	if(length(exit_point_list) >= 5)
		exit_point_list.Cut(5)

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/proc/do_steam_effects(turf/loc)
	var/datum/effect_system/steam_spread/steam = new()
	steam.set_up(10, FALSE, loc)
	steam.start()

/// Pojemnik przenikania w stylu tg. Osobny typ, żeby nie ruszać naszych starych (slaughter, spell_jaunt, shadow).
/obj/effect/dummy/phased_mob/tg
	name = "ethereal form"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	density = FALSE
	anchored = TRUE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	invisibility = INVISIBILITY_OBSERVER
	movement_type = FLOATING
	/// Kto jest w środku
	var/atom/movable/jaunter
	/// Kiedy można się ruszyć
	var/movedelay = 0
	/// Odstęp między ruchami
	var/movespeed = 0
	/// Znacznik pozycji dla gracza w środku
	var/image/position_indicator
	var/phased_mob_icon = 'icons/obj/projectiles.dmi'
	var/phased_mob_icon_state = "ice_1"

/obj/effect/dummy/phased_mob/tg/Initialize(mapload, atom/movable/jaunter)
	. = ..()
	if(jaunter)
		set_jaunter(jaunter)

/obj/effect/dummy/phased_mob/tg/proc/set_jaunter(atom/movable/new_jaunter)
	jaunter = new_jaunter
	jaunter.forceMove(src)
	if(!ismob(jaunter))
		return
	var/mob/mob_jaunter = jaunter
	position_indicator = image(phased_mob_icon, src, phased_mob_icon_state, ABOVE_LIGHTING_LAYER)
	position_indicator.plane = ABOVE_LIGHTING_PLANE
	position_indicator.appearance_flags |= RESET_ALPHA
	RegisterSignal(mob_jaunter, COMSIG_MOB_LOGIN, PROC_REF(show_client_image))
	RegisterSignal(mob_jaunter, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_change))
	mob_jaunter.reset_perspective(src)
	show_client_image(mob_jaunter)

/obj/effect/dummy/phased_mob/tg/proc/show_client_image(mob/show_to)
	SIGNAL_HANDLER
	show_to.client?.images |= position_indicator

/obj/effect/dummy/phased_mob/tg/Destroy()
	if(jaunter && jaunter.loc == src)
		jaunter.forceMove(get_turf(src))
	jaunter = null
	position_indicator = null
	return ..()

/obj/effect/dummy/phased_mob/tg/proc/eject_jaunter()
	if(!jaunter)
		return
	var/turf/eject_spot = get_turf(src)
	if(!eject_spot)
		return
	var/area/destination_area = get_area(eject_spot)
	if((destination_area.teleport_restriction == TELEPORT_ALLOW_NONE))
		if(isliving(jaunter))
			to_chat(jaunter, "<span class='userdanger'>Ten obszar zajmuje potężna, wszechobecna siła - zostajesz rozrzucony po kosmosie!</span>")
			if(ishuman(jaunter))
				shake_camera(jaunter, 20, 1)
		jaunter.forceMove(find_safe_turf(z) || eject_spot)
	else
		jaunter.forceMove(eject_spot)
	qdel(src)

/obj/effect/dummy/phased_mob/tg/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == jaunter)
		UnregisterSignal(jaunter, list(COMSIG_MOB_STATCHANGE, COMSIG_MOB_LOGIN))
		if(ismob(jaunter))
			var/mob/mob_jaunter = jaunter
			mob_jaunter.client?.images -= position_indicator
			mob_jaunter.reset_perspective()
		SEND_SIGNAL(src, COMSIG_MOB_EJECTED_FROM_JAUNT, jaunter)
		jaunter = null

/obj/effect/dummy/phased_mob/tg/ex_act()
	return FALSE

/obj/effect/dummy/phased_mob/tg/bullet_act(obj/item/projectile/P, def_zone, piercing_hit)
	return BULLET_ACT_FORCE_PIERCE

/obj/effect/dummy/phased_mob/tg/relaymove(mob/living/user, direction)
	var/turf/newloc = phased_check(user, direction)
	if(!newloc)
		return
	if(direction in GLOB.alldirs)
		setDir(direction)
	forceMove(newloc)

/// Czy można wejść na pole w danym kierunku; zwraca pole albo null
/obj/effect/dummy/phased_mob/tg/proc/phased_check(mob/living/user, direction)
	RETURN_TYPE(/turf)
	if(movedelay > world.time || !direction)
		return
	var/turf/newloc = get_step_multiz(src, direction)
	if(!newloc)
		return
	var/area/destination_area = newloc.loc
	movedelay = world.time + movespeed
	if(SEND_SIGNAL(src, COMSIG_MOB_PHASED_CHECK, user, newloc) & COMPONENT_BLOCK_PHASED_MOVE)
		return null
	if(newloc.flags_1 & NOJAUNT_1)
		to_chat(user, "<span class='warning'>Jakaś dziwna aura blokuje drogę.</span>")
		return
	if((destination_area.teleport_restriction == TELEPORT_ALLOW_NONE))
		to_chat(user, "<span class='danger'>Jakaś tępa, wszechobecna siła blokuje drogę. Jej przytłaczający nacisk wydaje się groźny.</span>")
		return
	return newloc

/obj/effect/dummy/phased_mob/tg/proc/on_stat_change(mob/living/source, new_stat, old_stat)
	SIGNAL_HANDLER
	if(source == jaunter && source.stat >= SOFT_CRIT)
		eject_jaunter()

/// Pojemnik przenikania czarodzieja (wolniejszy, blokowany przez poświęcone pola)
/obj/effect/dummy/phased_mob/tg/spell_jaunt
	movespeed = 2
	/// Wyłania się - nie można się już ruszać
	var/reappearing = FALSE

/obj/effect/dummy/phased_mob/tg/spell_jaunt/phased_check(mob/living/user, direction)
	if(reappearing)
		return
	. = ..()
	if(!.)
		return
	var/turf/new_loc = .
	if(locate(/obj/effect/blessing) in new_loc)
		to_chat(user, "<span class='warning'>Święta energia blokuje ci drogę!</span>")
		return null

/obj/effect/dummy/phased_mob/tg/spell_jaunt/red
	phased_mob_icon_state = "red_1"

// Przemiana: rzucający zamienia się w innego moba, a jego ciało czeka w środku

/datum/action/cooldown/spell/shapeshift
	button_icon_state = "shapeshift"
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 10 SECONDS
	/// Wymagania sprzed przemiany
	var/pre_shift_requirements
	/// Czy wracamy do ciała po śmierci formy
	var/revert_on_death = TRUE
	/// Czy śmierć formy zabija też rzucającego
	var/die_with_shapeshifted_form = TRUE
	/// Czy przenosimy obrażenia między formami
	var/convert_damage = TRUE
	/// Rodzaj przenoszonych obrażeń
	var/convert_damage_type = BRUTE
	/// Wybrana forma
	var/mob/living/shapeshift_type
	/// Możliwe formy do wyboru
	var/list/atom/possible_shapes
	/// Status przemiany
	var/shapechange_type = /datum/status_effect/shapechange_mob/from_spell

/datum/action/cooldown/spell/shapeshift/Remove(mob/remove_from)
	unshift_owner()
	return ..()

/datum/action/cooldown/spell/shapeshift/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/shapeshift/before_cast(mob/living/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
	if(shapeshift_type)
		if(cast_on.has_status_effect(/datum/status_effect/shapechange_mob/from_spell) && !is_type_in_list(cast_on, possible_shapes))
			to_chat(cast_on, "<span class='warning'>To zaklęcie nie cofnie cię z tej formy!</span>")
			return . | SPELL_CANCEL_CAST
		return
	if(length(possible_shapes) == 1)
		shapeshift_type = possible_shapes[1]
		return
	var/list/shape_names_to_types = list()
	var/list/shape_names_to_image = list()
	for(var/atom/path as anything in possible_shapes)
		var/shape_name = initial(path.name)
		shape_names_to_types[shape_name] = path
		shape_names_to_image[shape_name] = image(icon = initial(path.icon), icon_state = initial(path.icon_state))
	var/picked_type = show_radial_menu(cast_on, cast_on, shape_names_to_image, custom_check = CALLBACK(src, PROC_REF(check_menu), cast_on), radius = 38)
	if(!picked_type)
		return . | SPELL_CANCEL_CAST
	var/atom/shift_type = shape_names_to_types[picked_type]
	if(!ispath(shift_type))
		return . | SPELL_CANCEL_CAST
	shapeshift_type = shift_type
	if(QDELETED(src) || QDELETED(owner) || !can_cast_spell(feedback = FALSE))
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/shapeshift/cast(mob/living/cast_on)
	. = ..()
	cast_on.buckled?.unbuckle_mob(cast_on, force = TRUE)
	if(cast_on.has_status_effect(/datum/status_effect/shapechange_mob/from_spell))
		do_unshapeshift(cast_on)
	else
		do_shapeshift(cast_on)

/datum/action/cooldown/spell/shapeshift/proc/check_menu(mob/living/caster)
	if(QDELETED(src) || QDELETED(caster))
		return FALSE
	return !caster.incapacitated()

/datum/action/cooldown/spell/shapeshift/proc/do_shapeshift(mob/living/caster)
	var/mob/living/new_shape = create_shapeshift_mob(caster.loc)
	var/datum/status_effect/shapechange_mob/shapechange = new_shape.apply_status_effect(shapechange_type, caster, src)
	if(!shapechange)
		to_chat(caster, "<span class='warning'>W tej formie nie możesz się przemienić!</span>")
		qdel(new_shape)
		return
	pre_shift_requirements = spell_requirements
	spell_requirements &= ~SPELL_REQUIRES_HUMAN
	ADD_TRAIT(new_shape, TRAIT_SHAPESHIFTED, SHAPESHIFT_TRAIT)
	return new_shape

/datum/action/cooldown/spell/shapeshift/proc/do_unshapeshift(mob/living/caster)
	var/datum/status_effect/shapechange_mob/shapechange = caster.has_status_effect(shapechange_type)
	if(!shapechange)
		to_chat(caster, "<span class='warning'>Nie możesz cofnąć tej przemiany!</span>")
		return
	spell_requirements = pre_shift_requirements
	pre_shift_requirements = null
	var/mob/living/unshapeshifted_mob = shapechange.caster_mob
	caster.remove_status_effect(shapechange_type)
	return unshapeshifted_mob

/datum/action/cooldown/spell/shapeshift/proc/create_shapeshift_mob(atom/loc)
	return new shapeshift_type(loc)

/datum/action/cooldown/spell/shapeshift/proc/unshift_owner()
	if(isnull(owner))
		return
	var/mob/living/living_owner = owner
	if(istype(living_owner) && living_owner.has_status_effect(/datum/status_effect/shapechange_mob/from_spell))
		do_unshapeshift(owner)

/// Status przemiany moba: nakładany na NOWĄ formę, trzyma ciało rzucającego w środku
/datum/status_effect/shapechange_mob
	id = "shapechange_mob"
	alert_type = /atom/movable/screen/alert/status_effect/shapeshifted
	on_remove_on_mob_delete = TRUE
	/// Prawdziwe ciało
	var/mob/living/caster_mob
	/// Czy już wróciliśmy
	var/already_restored = FALSE

/datum/status_effect/shapechange_mob/on_creation(mob/living/new_owner, mob/living/caster)
	if(QDELETED(caster) || !istype(caster))
		qdel(src)
		return
	for(var/datum/status_effect/shapechange_mob/existing in new_owner.status_effects)
		qdel(src)
		return
	caster_mob = caster
	return ..()

/datum/status_effect/shapechange_mob/on_apply()
	caster_mob.mind?.transfer_to(owner)
	caster_mob.forceMove(owner)
	caster_mob.notransform = TRUE
	caster_mob.status_flags |= GODMODE
	RegisterSignal(owner, COMSIG_MOB_DEATH, PROC_REF(on_shape_death))
	RegisterSignal(caster_mob, COMSIG_MOB_DEATH, PROC_REF(on_caster_death))
	RegisterSignal(caster_mob, COMSIG_PARENT_QDELETING, PROC_REF(on_caster_deleted))
	SEND_SIGNAL(caster_mob, COMSIG_LIVING_SHAPESHIFTED, owner)
	return TRUE

/datum/status_effect/shapechange_mob/on_remove()
	if(!QDELETED(owner))
		restore_caster()
	caster_mob = null

/datum/status_effect/shapechange_mob/proc/restore_caster(kill_caster_after = FALSE)
	if(already_restored || !caster_mob)
		return
	already_restored = TRUE
	UnregisterSignal(owner, COMSIG_MOB_DEATH)
	UnregisterSignal(caster_mob, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DEATH))
	caster_mob.notransform = FALSE
	caster_mob.status_flags &= ~GODMODE
	var/atom/former_loc = owner.loc
	owner.moveToNullspace()
	caster_mob.forceMove(former_loc)
	if(kill_caster_after)
		caster_mob.death()
	after_unchange()
	var/mob/living/former_body = owner
	owner.mind?.transfer_to(caster_mob)
	qdel(former_body)

/datum/status_effect/shapechange_mob/proc/after_unchange()
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(owner, COMSIG_LIVING_UNSHAPESHIFTED, caster_mob)

/datum/status_effect/shapechange_mob/proc/on_shape_death(datum/source, gibbed)
	SIGNAL_HANDLER
	if(gibbed)
		return
	INVOKE_ASYNC(src, PROC_REF(restore_caster))

/datum/status_effect/shapechange_mob/proc/on_caster_death(datum/source, gibbed)
	SIGNAL_HANDLER
	if(gibbed)
		owner.gib()
	else
		owner.death()

/datum/status_effect/shapechange_mob/proc/on_caster_deleted(datum/source)
	SIGNAL_HANDLER
	caster_mob = null
	if(!QDELETED(owner))
		qdel(owner)

/// Przemiana z zaklęcia: przenosi zaklęcie i obrażenia
/datum/status_effect/shapechange_mob/from_spell
	id = "shapechange_from_spell"
	/// Zaklęcie, które nas przemieniło
	var/datum/weakref/source_weakref

/datum/status_effect/shapechange_mob/from_spell/on_creation(mob/living/new_owner, mob/living/caster, datum/action/cooldown/spell/shapeshift/source_spell)
	if(!istype(source_spell))
		qdel(src)
		return
	source_weakref = WEAKREF(source_spell)
	return ..()

/datum/status_effect/shapechange_mob/from_spell/on_apply()
	var/datum/action/cooldown/spell/shapeshift/source_spell = source_weakref.resolve()
	. = ..()
	if(source_spell?.owner == caster_mob)
		source_spell.Grant(owner)
		if(source_spell.convert_damage)
			var/damage_to_apply = owner.maxHealth * ((caster_mob.maxHealth - caster_mob.health) / caster_mob.maxHealth)
			owner.apply_damage(damage_to_apply, source_spell.convert_damage_type, forced = TRUE)
	for(var/datum/action/bodybound_action as anything in caster_mob.actions)
		if(bodybound_action.target != caster_mob)
			continue
		bodybound_action.Grant(owner)

/datum/status_effect/shapechange_mob/from_spell/restore_caster(kill_caster_after)
	var/datum/action/cooldown/spell/shapeshift/source_spell = source_weakref.resolve()
	if(!QDELETED(source_spell) && source_spell.owner == owner)
		source_spell.Grant(caster_mob)
	for(var/atom/movable/thing as anything in owner?.contents)
		if(thing == caster_mob || isitem(thing) && (thing in owner.held_items))
			continue
		if(isitem(thing))
			thing.forceMove(get_turf(owner))
	for(var/datum/action/bodybound_action as anything in owner.actions)
		if(bodybound_action.target != caster_mob)
			continue
		bodybound_action.Grant(caster_mob)
	return ..()

/datum/status_effect/shapechange_mob/from_spell/after_unchange()
	. = ..()
	var/datum/action/cooldown/spell/shapeshift/source_spell = source_weakref?.resolve()
	if(QDELETED(source_spell) || !source_spell.convert_damage)
		return
	caster_mob.revive(full_heal = TRUE)
	var/damage_to_apply = caster_mob.maxHealth * ((owner.maxHealth - owner.health) / owner.maxHealth)
	caster_mob.apply_damage(damage_to_apply, source_spell.convert_damage_type, forced = TRUE)

/datum/status_effect/shapechange_mob/from_spell/on_shape_death(datum/source, gibbed)
	var/datum/action/cooldown/spell/shapeshift/source_spell = source_weakref.resolve()
	if(!QDELETED(source_spell) && source_spell.die_with_shapeshifted_form)
		if(source_spell.revert_on_death)
			INVOKE_ASYNC(src, PROC_REF(restore_caster), TRUE)
		return
	return ..()

/datum/status_effect/shapechange_mob/from_spell/on_caster_death(datum/source)
	var/datum/action/cooldown/spell/shapeshift/source_spell = source_weakref.resolve()
	if(!QDELETED(source_spell) && !source_spell.revert_on_death)
		return
	return ..()

/atom/movable/screen/alert/status_effect/shapeshifted
	name = "Shapeshifted"
	desc = "Twoja forma nie jest twoja... jesteś przemieniony w inną istotę!"
	icon_state = "default"

// Ładowane: przed rzuceniem trzeba wytrzymać kilka sekund

/datum/action/cooldown/spell/charged
	/// Komunikat na początku ładowania
	var/channel_message
	/// Czy teraz ładujemy
	var/currently_channeling = FALSE
	/// Jak długo
	var/channel_time = 10 SECONDS
	/// tg: flagi do_after (u nas bez efektu, ruch nie przerywa)
	var/channel_flags
	/// Nakładka w trakcie ładowania
	var/charge_overlay_icon
	var/charge_overlay_state
	var/mutable_appearance/charge_overlay_instance
	/// Dźwięk ładowania
	var/charge_sound
	var/sound/charge_sound_instance

/datum/action/cooldown/spell/charged/New(Target, original)
	. = ..()
	if(!channel_message)
		channel_message = "<span class='notice'>Zaczynasz ładować [src]...</span>"
	if(charge_sound)
		charge_sound_instance = sound(charge_sound, channel = CHANNEL_CHARGED_SPELL)
	if(charge_overlay_icon && charge_overlay_state)
		charge_overlay_instance = mutable_appearance(charge_overlay_icon, charge_overlay_state, EFFECTS_LAYER)

/datum/action/cooldown/spell/charged/Destroy()
	if(owner)
		stop_channel_effect(owner)
	charge_overlay_instance = null
	charge_sound_instance = null
	return ..()

/datum/action/cooldown/spell/charged/Remove(mob/living/remove_from)
	stop_channel_effect(remove_from)
	return ..()

/datum/action/cooldown/spell/charged/is_action_active()
	return currently_channeling

/datum/action/cooldown/spell/charged/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(currently_channeling)
		if(feedback)
			to_chat(owner, "<span class='warning'>Już ładujesz [src]!</span>")
		return FALSE
	return TRUE

/datum/action/cooldown/spell/charged/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
	to_chat(cast_on, channel_message)
	if(charge_sound_instance)
		playsound(cast_on, charge_sound_instance, 50, FALSE)
	if(charge_overlay_instance)
		cast_on.add_overlay(charge_overlay_instance)
	currently_channeling = TRUE
	UpdateButtonIcon()
	if(!do_after(cast_on, channel_time, FALSE, cast_on))
		stop_channel_effect(cast_on)
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/charged/cast(atom/cast_on)
	. = ..()
	stop_channel_effect(cast_on)

/datum/action/cooldown/spell/charged/proc/stop_channel_effect(mob/for_who)
	if(charge_overlay_instance)
		for_who.cut_overlay(charge_overlay_instance)
	if(charge_sound_instance)
		for_who.stop_sound_channel(CHANNEL_CHARGED_SPELL)
	currently_channeling = FALSE
	UpdateButtonIcon()

/// Ładowana wiązka: po naładowaniu uderza w cel w pobliżu
/datum/action/cooldown/spell/charged/beam
	/// Zasięg szukania celu
	var/target_radius = 5
	/// Ile odbić
	var/max_beam_bounces = 1
	/// Wybrany cel
	var/atom/initial_target

/datum/action/cooldown/spell/charged/beam/Destroy()
	initial_target = null
	return ..()

/datum/action/cooldown/spell/charged/beam/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
	initial_target = get_target(cast_on)
	if(isnull(initial_target))
		cast_on.balloon_alert(cast_on, "brak celów w pobliżu!")
		stop_channel_effect(cast_on)
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/charged/beam/cast(atom/cast_on)
	. = ..()
	send_beam(cast_on, initial_target, max_beam_bounces)
	initial_target = null

/datum/action/cooldown/spell/charged/beam/proc/send_beam(atom/origin, atom/to_beam, bounces)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("[type] did not implement send_beam")

/datum/action/cooldown/spell/charged/beam/proc/get_target(atom/center)
	var/list/things = list()
	for(var/atom/nearby_thing in range(target_radius, center))
		if(nearby_thing == owner || nearby_thing == center)
			continue
		things += nearby_thing
	if(!length(things))
		return null
	return pick(things)

// Przywoływanie: tworzy rzeczy w promieniu

/datum/action/cooldown/spell/conjure
	sound = 'sound/items/welder.ogg'
	school = SCHOOL_CONJURATION
	/// Promień
	var/summon_radius = 7
	/// Lista typów do przywołania (losowo)
	var/list/summon_type = list()
	/// Czas życia, 0 = na zawsze
	var/summon_lifespan = 0
	/// Ile rzeczy
	var/summon_amount = 1
	/// Czy omijamy gęste pola
	var/summon_respects_density = FALSE
	/// Czy nie przywołujemy dwa razy na tym samym polu
	var/summon_respects_prev_spawn_points = TRUE
	/// Ile trzeba stać w miejscu przed przywołaniem
	var/create_summon_timer

/datum/action/cooldown/spell/conjure/is_valid_target(atom/cast_on)
	return isturf(cast_on.loc)

/datum/action/cooldown/spell/conjure/cast(atom/cast_on)
	. = ..()
	if(create_summon_timer && !do_after(owner, create_summon_timer, TRUE, cast_on.loc))
		owner?.balloon_alert(owner, "musisz stać w miejscu!")
		return
	var/list/to_summon_in = list()
	for(var/turf/summon_turf in range(summon_radius, cast_on))
		if(summon_respects_density && summon_turf.density)
			continue
		to_summon_in += summon_turf
	for(var/i in 1 to summon_amount)
		if(!length(to_summon_in))
			break
		var/atom/summoned_object_type = pick(summon_type)
		var/turf/spawn_place = pick(to_summon_in)
		if(summon_respects_prev_spawn_points)
			to_summon_in -= spawn_place
		if(ispath(summoned_object_type, /turf))
			spawn_place.ChangeTurf(summoned_object_type, flags = CHANGETURF_INHERIT_AIR)
			continue
		var/atom/summoned_object = new summoned_object_type(spawn_place)
		summoned_object.flags_1 |= ADMIN_SPAWNED_1
		if(summon_lifespan > 0)
			QDEL_IN(summoned_object, summon_lifespan)
		post_summon(summoned_object, cast_on)

/datum/action/cooldown/spell/conjure/proc/post_summon(atom/summoned_object, atom/cast_on)
	return

/// Przywoływanie z limitem jednocześnie istniejących rzeczy
/datum/action/cooldown/spell/conjure/limit_summons
	/// Limit
	var/max_summons
	/// Ile teraz istnieje
	var/number_of_summons = 0

/datum/action/cooldown/spell/conjure/limit_summons/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(number_of_summons >= max_summons)
		return FALSE
	return TRUE

/datum/action/cooldown/spell/conjure/limit_summons/post_summon(atom/summoned_object, atom/cast_on)
	RegisterSignal(summoned_object, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DEATH), PROC_REF(delete_copy))
	number_of_summons++

/datum/action/cooldown/spell/conjure/limit_summons/proc/delete_copy(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DEATH))
	number_of_summons--

#undef CHANNEL_CHARGED_SPELL
