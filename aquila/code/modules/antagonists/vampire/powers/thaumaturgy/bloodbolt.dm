/datum/action/vampire/targeted/bloodbolt
	name = "Taumaturgia: Pocisk krwi"
	desc = "Wystrzel we wroga pocisk krwi, który zadaje oparzenia."
	button_icon_state = "power_bloodbolt"
	background_icon_state_on = "tremere_power_plat_on"
	background_icon_state_off = "tremere_power_plat_off"
	power_explanation = "Wystrzeliwuje zaklęty pocisk krwi, który zadaje oparzenia."
	power_flags = NONE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 75
	cooldown_time = 60 SECONDS
	target_range = 80 // Sniper :)
	power_activates_immediately = FALSE
	prefire_message = "Wybierz cel."

/datum/action/vampire/targeted/bloodbolt/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/living_owner = owner
	check_witnesses(target_atom)
	living_owner.balloon_alert(living_owner, "wystrzeliwujesz pocisk krwi!")
	living_owner.face_atom(target_atom)
	living_owner.changeNext_move(CLICK_CD_RANGE)
	living_owner.newtonian_move(get_dir(target_atom, living_owner))

	var/obj/item/projectile/magic/arcane_barrage/vampire/bolt = new(living_owner.loc)
	bolt.vampire_power = src
	bolt.firer = living_owner
	bolt.fired_from = living_owner
	bolt.original = target_atom
	bolt.def_zone = ran_zone(living_owner.get_combat_bodyzone())
	bolt.preparePixelProjectile(target_atom, living_owner)
	INVOKE_ASYNC(bolt, TYPE_PROC_REF(/obj/item/projectile, fire))

	power_activated_sucessfully()

/**
 * 	# Blood Bolt
 *
 *	This is the projectile this Power will fire.
 */
/obj/item/projectile/magic/arcane_barrage/vampire
	name = "pocisk krwi"
	icon_state = "mini_leaper"
	damage = 40
	var/datum/action/vampire/targeted/bloodbolt/vampire_power

/obj/item/projectile/magic/arcane_barrage/vampire/Destroy()
	. = ..()
	vampire_power = null

/obj/item/projectile/magic/arcane_barrage/vampire/on_hit(atom/target_atom)
	new /obj/effect/gibspawner/generic(target_atom.loc)
	if(istype(target_atom, /obj/structure/closet))
		var/obj/structure/closet/hit_closet = target_atom
		hit_closet.bust_open()
		qdel(src)
		return BULLET_ACT_HIT

	if(istype(target_atom, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/airlock = target_atom
		airlock.unbolt()
		airlock.open(forced = TRUE)
		qdel(src)
		return BULLET_ACT_HIT

	if(isliving(target_atom))
		var/mob/living/living_target = target_atom
		living_target.add_splatter_floor(get_turf(living_target))
		living_target.blood_volume -= 50
		living_target.emote("screams")
		living_target.set_jitter(6 SECONDS)
		living_target.Unconscious(3 SECONDS)
		visible_message(span_danger("[living_target] tryska z ran wrzącą krwią!"), span_userdanger("O Boże, jak to pali!"))
		qdel(src)
		return BULLET_ACT_HIT
	. = ..()
