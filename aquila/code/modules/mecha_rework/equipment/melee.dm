// AQUILA - broń wręcz mechów (port z Yogstation, code/game/mecha/equipment/weapons/melee_weapons.dm, ten sam /obj/mecha).
// Zamiast pustej pięści mech uderza bronią: cios precyzyjny w cel (zasięg 1) albo zamach w trzy pola przed sobą
// (kliknięcie podłogi w combat mode / na intencji harm). Typ obrażeń, przebicie pancerza, premia na faunę i na konstrukcje
// zależą od broni. Różnice wobec Yoga: obrażenia nakładamy przez nasze apply_damage (bez ran i krwawienia z wound_bonus),
// parowanie liczy run_obj_armor (bonus do deflect_chance, gdy broń jest wybrana), zamiast efektu sweep_attack jest firing_effect.
// Zostaje pięć broni: ostrze (krótki miecz GD6), młot ASW-8, pałka ogłuszająca AV-98 oraz z innych kodów zgniatacz górniczy
// (Paradise) i mega mop WLLY (Paradise).

/obj/item/mecha_parts/mecha_equipment/aq_melee
	name = "broń wręcz egzoszkieletu"
	desc = "Ogólna broń wręcz dla mechów."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "mecha_generic_melee"
	range = MECHA_MELEE | MECHA_RANGED
	destroy_sound = 'sound/mecha/weapdestr.ogg'
	mech_flags = EXOSUIT_MODULE_COMBAT
	harmful = TRUE
	aq_slot = AQ_MECHA_SLOT_ARM
	/// Tylko na mechach bojowych (ciężka broń)
	var/combat_only = TRUE
	/// Dodatkowy zasięg ponad sąsiednie pole
	var/extended_range = 0
	/// Mnożnik czasu między ciosami
	var/attack_speed_modifier = 1
	var/attack_sound = 'aquila/sound/mecha/mechasword.ogg'
	var/mob_strike_sound = 'sound/weapons/bladeslice.ogg'
	/// Zamach w trzy pola przed mechem
	var/cleave = FALSE
	/// Cios w jeden cel
	var/precise_attacks = TRUE
	var/dam_type = BRUTE
	var/attack_sharpness = 0
	/// Obrażenia dodawane do siły mecha przy zamachu
	var/weapon_damage = 0
	/// Obrażenia dodawane do siły mecha przy ciosie precyzyjnym
	var/precise_weapon_damage = 0
	var/minimum_damage = 0
	/// Bonus do odbijania ataków, gdy broń jest wybrana
	var/deflect_bonus = 0
	/// Przebicie pancerza (podwójne przy ciosie precyzyjnym)
	var/base_armor_piercing = 0
	/// Dodatkowe obrażenia przeciw faunie (planety, asteroidy)
	var/fauna_damage_bonus = 0
	var/structure_damage_mult = 3
	var/mech_damage_multiplier = 0.5
	var/can_stab_turfs = FALSE
	var/hit_effect = ATTACK_EFFECT_SLASH
	/// Cios precyzyjny nie rani żywych (pałki)
	var/precise_no_mobdamage = FALSE

/obj/item/mecha_parts/mecha_equipment/aq_melee/can_attach(obj/mecha/M)
	if(!..())
		return FALSE
	if(istype(M, /obj/mecha/combat))
		return TRUE
	if(!combat_only)
		return TRUE
	if((locate(/obj/item/mecha_parts/concealed_weapon_bay) in M.contents) && !(locate(/obj/item/mecha_parts/mecha_equipment/aq_melee) in M.equipment) && !(locate(/obj/item/mecha_parts/mecha_equipment/weapon) in M.equipment))
		return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/aq_melee/start_cooldown()
	set_ready_state(0)
	chassis.use_power(energy_drain)
	aq_on_used()
	var/cd = chassis.melee_cooldown * attack_speed_modifier
	if(chassis.aq_overclock)
		cd /= chassis.aq_overclock_coeff
	addtimer(CALLBACK(src, PROC_REF(set_ready_state), 1), cd)

/obj/item/mecha_parts/mecha_equipment/aq_melee/action(atom/target, params)
	if(!action_checks(target))
		return 0
	var/turf/curloc = get_turf(chassis)
	var/turf/targloc = get_turf(target)
	if(!targloc || !curloc || targloc == curloc)
		return 0
	var/mob/living/pilot = chassis.occupant
	if(target == targloc && pilot?.combat_mode && cleave)
		cleave_attack(chassis.dir)
	else if(precise_attacks && get_dist(chassis, target) <= (1 + extended_range) && can_stab_at(chassis, target) && !isitem(target) && !iseffect(target))
		if(isopenturf(target) && !can_stab_turfs)
			return 0
		precise_attack(target)
	else if(cleave && get_dist(chassis, target) <= 1)
		cleave_attack(chassis.dir)
	else
		return 0
	chassis.log_message("Attacked with [name], targeting [target].", LOG_MECHA)
	return 1

/// Linia ciosu: jak linia wzroku, ale nic gęstego po drodze (Yogstation)
/obj/item/mecha_parts/mecha_equipment/aq_melee/proc/can_stab_at(atom/attacker, atom/target)
	var/turf/starter = get_turf(attacker)
	var/turf/targloc = get_turf(target)
	if(attacker.Adjacent(target))
		return TRUE
	var/turf/current
	if(abs(starter.x - targloc.x) == abs(starter.y - targloc.y))
		current = get_step_towards(starter, targloc)
	else
		current = get_step_towards2(starter, targloc)
	if(!starter.Adjacent(current))
		return FALSE
	var/turf/next
	if(current != targloc)
		next = get_step_towards(current, targloc)
	var/safety = 5
	while(current != targloc && safety--)
		if(!current.Adjacent(next))
			return FALSE
		if(current.density)
			return FALSE
		for(var/obj/O in current)
			if(O.density && !(O.pass_flags & LETPASSTHROW))
				return FALSE
		current = next
		if(next != targloc)
			next = get_step_towards(next, targloc)
	return TRUE

/proc/aq_is_mecha_fauna(mob/living/L)
	return ismegafauna(L) || istype(L, /mob/living/simple_animal/hostile/asteroid) || ("mining" in L.faction)

/// Obrażenia w żywy cel (przez pancerz w strefie, którą celuje pilot)
/obj/item/mecha_parts/mecha_equipment/aq_melee/proc/hit_living(mob/living/L, damage, piercing, precise = FALSE)
	if(iscarbon(L))
		var/zone = precise ? (chassis.occupant?.zone_selected || BODY_ZONE_CHEST) : pick(BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_HEAD)
		var/armor_block = L.run_armor_check(zone, "melee", armour_penetration = piercing)
		L.apply_damage(damage, dam_type, zone, armor_block)
	else
		L.apply_damage(damage, dam_type)
	if(fauna_damage_bonus && aq_is_mecha_fauna(L))
		L.apply_damage(fauna_damage_bonus, dam_type)

/obj/item/mecha_parts/mecha_equipment/aq_melee/proc/hit_object(obj/O, damage, piercing)
	var/object_damage = damage * structure_damage_mult * (ismecha(O) ? mech_damage_multiplier : 1)
	O.take_damage(object_damage, dam_type, "melee", 0, null, piercing)

/obj/item/mecha_parts/mecha_equipment/aq_melee/proc/precise_attack(atom/target)
	special_hit(target)
	var/damage = max(chassis.force + precise_weapon_damage, minimum_damage)
	if(isliving(target))
		var/mob/living/L = target
		if(!precise_no_mobdamage)
			hit_living(L, damage, base_armor_piercing * 2, TRUE)
		L.visible_message("<span class='danger'>[chassis.name] uderza [L] bronią [src]!</span>", "<span class='userdanger'>[chassis.name] uderza cię bronią [src]!</span>")
		log_combat(chassis.occupant, L, "attacked", src, "(precise)")
	else if(isobj(target))
		hit_object(target, damage, base_armor_piercing * 2)
	else if(isclosedturf(target) && can_stab_turfs)
		target.mech_melee_attack(chassis)
	else
		return
	chassis.do_attack_animation(target, hit_effect)
	playsound(chassis, attack_sound, 50, TRUE)

/obj/item/mecha_parts/mecha_equipment/aq_melee/proc/cleave_attack(attack_dir)
	playsound(chassis, attack_sound, 50, TRUE)
	var/turf/M = get_turf(chassis)
	var/damage = max(chassis.force + weapon_damage, minimum_damage)
	for(var/i in 0 to 2)
		var/turf/T = get_step(M, turn(attack_dir, 45 * (1 - i)))
		if(!T)
			continue
		special_hit(T)
		for(var/atom/A as anything in T.contents)
			if(A == chassis)
				continue
			if(isliving(A) && can_stab_at(chassis, A))
				var/mob/living/L = A
				special_hit(L)
				hit_living(L, damage, base_armor_piercing)
				L.visible_message("<span class='danger'>[chassis.name] trafia [L] szerokim zamachem [src]!</span>", "<span class='userdanger'>[chassis.name] trafia cię [src]!</span>")
				log_combat(chassis.occupant, L, "attacked", src, "(cleave)")
				playsound(L, mob_strike_sound, 50)
			else if((isstructure(A) || ismachinery(A) || ismecha(A)) && can_stab_at(chassis, A))
				var/obj/O = A
				if(!O.density && !istype(O, /obj/structure/spacevine))
					continue
				hit_object(O, damage, base_armor_piercing)
				playsound(O, istype(O, /obj/structure/window) ? 'sound/effects/Glasshit.ogg' : 'sound/weapons/smash.ogg', 50)
	new /obj/effect/temp_visual/dir_setting/firing_effect(get_turf(chassis), attack_dir)

/// Efekt specjalny trafienia (podpalenie, odrzut, ogłuszenie)
/obj/item/mecha_parts/mecha_equipment/aq_melee/proc/special_hit(atom/target)
	return

// ---------------------------------------------------------------- ostrze, pałka, młot
/obj/item/mecha_parts/mecha_equipment/aq_melee/shortsword
	name = "\improper krótki miecz GD6 \"Jaeger\""
	desc = "Wysuwane ostrze montowane na ramieniu mecha. Szybkie i lżejsze cięcia, a mała masa pozwala parować część ataków."
	cleave = TRUE
	attack_sharpness = IS_SHARP
	energy_drain = 2
	weapon_damage = 10
	precise_weapon_damage = 15
	fauna_damage_bonus = 30
	deflect_bonus = 15
	base_armor_piercing = 15
	structure_damage_mult = 2.5
	minimum_damage = 25

/obj/item/mecha_parts/mecha_equipment/aq_melee/shortsword/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 3 SECONDS, 120)

/obj/item/mecha_parts/mecha_equipment/aq_melee/baton
	name = "\improper ciężka pałka ogłuszająca AV-98 \"Ingram\""
	desc = "Pałka ogłuszająca, tylko dużo większa. Cios precyzyjny ogłusza zamiast ranić, zamach odpycha tłum."
	icon_state = "mecha_batong"
	cleave = TRUE
	combat_only = FALSE
	energy_drain = 30
	attack_speed_modifier = 2
	structure_damage_mult = 1
	precise_weapon_damage = -25
	weapon_damage = -25
	minimum_damage = 10
	hit_effect = ATTACK_EFFECT_BOOP
	precise_no_mobdamage = TRUE
	harmful = FALSE
	mob_strike_sound = 'sound/weapons/egloves.ogg'
	attack_sound = 'sound/weapons/egloves.ogg'
	mech_flags = EXOSUIT_MODULE_COMBAT | EXOSUIT_MODULE_RIPLEY
	var/baton_stamina = 75

/obj/item/mecha_parts/mecha_equipment/aq_melee/baton/special_hit(atom/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/armor_block = H.run_armor_check(BODY_ZONE_CHEST, "energy")
		H.apply_damage(baton_stamina, STAMINA, BODY_ZONE_CHEST, armor_block)
		H.Jitter(10)
		if(H.getStaminaLoss() >= 90)
			H.Paralyze(6 SECONDS)
	if(isliving(target))
		step_away(target, chassis)

/obj/item/mecha_parts/mecha_equipment/aq_melee/maul
	name = "\improper ciężki młot ASW-8 \"Barbatos\""
	desc = "Masywny, nieporęczny młot. Wolne, potężne ciosy odrzucają cel i kruszą konstrukcje: dobry do wyważania przejść przy abordażu."
	icon_state = "mecha_maul"
	cleave = TRUE
	energy_drain = 4
	weapon_damage = 25
	precise_weapon_damage = 30
	attack_speed_modifier = 2.5
	fauna_damage_bonus = 40
	structure_damage_mult = 4
	mob_strike_sound = 'sound/effects/meteorimpact.ogg'
	hit_effect = ATTACK_EFFECT_SMASH
	can_stab_turfs = TRUE

/obj/item/mecha_parts/mecha_equipment/aq_melee/maul/special_hit(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		var/turf/throwtarget = get_edge_target_turf(chassis, get_dir(chassis, get_step_away(L, chassis)))
		L.throw_at(throwtarget, 8, 2, chassis)

/obj/item/mecha_parts/mecha_equipment/aq_melee/crusher
	name = "zgniatacz górniczy egzoszkieletu"
	desc = "Kinetyczny zgniatacz dla mechów górniczych (Paradise): przeciw faunie planet i asteroid zadaje ogromne obrażenia, przeciw ludziom słabo."
	icon_state = "mecha_crusher"
	combat_only = FALSE
	precise_weapon_damage = 0
	weapon_damage = 0
	fauna_damage_bonus = 60
	minimum_damage = 10
	mech_flags = EXOSUIT_MODULE_RIPLEY
	hit_effect = ATTACK_EFFECT_SMASH

/obj/item/mecha_parts/mecha_equipment/aq_melee/mop
	name = "mega mop WLLY"
	desc = "Bardzo duży mop dla egzoszkieletów (Paradise, Yogstation). Zamach myje trzy pola przed mechem, a w ruchu mech sam zmywa podłogę przed sobą."
	icon_state = "mecha_mop"
	combat_only = FALSE
	cleave = TRUE
	precise_attacks = FALSE
	harmful = FALSE
	energy_drain = 5
	weapon_damage = 0
	structure_damage_mult = 0
	attack_sound = 'sound/effects/slosh.ogg'
	mech_flags = EXOSUIT_MODULE_RIPLEY

/obj/item/mecha_parts/mecha_equipment/aq_melee/mop/attach(obj/mecha/M)
	. = ..()
	RegisterSignal(M, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/obj/item/mecha_parts/mecha_equipment/aq_melee/mop/detach(atom/moveto)
	if(chassis)
		UnregisterSignal(chassis, COMSIG_MOVABLE_MOVED)
	return ..()

/obj/item/mecha_parts/mecha_equipment/aq_melee/mop/proc/on_moved(obj/mecha/mech)
	SIGNAL_HANDLER
	if(mech.equipment_disabled)
		return
	var/turf/T = get_step(mech, mech.dir)
	if(T)
		mop_turf(T)

/obj/item/mecha_parts/mecha_equipment/aq_melee/mop/proc/mop_turf(turf/T)
	SEND_SIGNAL(T, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
	for(var/obj/effect/decal/cleanable/C in T)
		qdel(C)

/obj/item/mecha_parts/mecha_equipment/aq_melee/mop/cleave_attack(attack_dir)
	playsound(chassis, attack_sound, 50, TRUE)
	for(var/turf/T in list(get_step(chassis, attack_dir), get_step(chassis, turn(attack_dir, -45)), get_step(chassis, turn(attack_dir, 45))))
		mop_turf(T)
	new /obj/effect/temp_visual/dir_setting/firing_effect(get_turf(chassis), attack_dir)
