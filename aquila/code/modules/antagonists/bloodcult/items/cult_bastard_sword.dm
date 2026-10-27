/// Cult Bastard Sword, earned by cultists when they manage to sacrifice a heretic.
// AQUILA - nie mamy komponentów spin2win i soul_stealer z tg. Wirowanie to nasz status_effect/sword_spin
// (ten sam, którego używał stary miecz Bee), a kradzież dusz to logika ze starego miecza Bee w afterattack.
/obj/item/cult_bastard
	name = "krwawy miecz półtoraręczny"
	desc = "Ogromny miecz, którym kultyści Nar'Sie szybko zbierają dusze niewiernych."
	w_class = WEIGHT_CLASS_HUGE
	/// AQUILA - szansa bloku jak w tg (cult_chance_block)
	var/block_chance = 50
	block_sound = 'sound/weapons/parry.ogg'
	throwforce = 20
	force = 35
	armour_penetration = 45
	throw_speed = 1
	throw_range = 3
	sharpness = SHARP_EDGED
	light_color = "#ff0000"
	attack_verb = list("atakuje", "ciacha", "dźga", "kroi", "rozdziera", "szarpie", "rozrywa", "siecze", "rozpłatuje")
	icon = 'aquila/icons/bloodcult/monke/obj/cult/items_and_weapons.dmi'
	icon_state = "cultbastard"
	item_state = "cultbastard"
	hitsound = 'sound/weapons/bladeslice.ogg'
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	actions_types = list()
	item_flags = SLOWS_WHILE_IN_HAND
	///if we are using our attack_self ability
	var/spinning = FALSE
	/// AQUILA - odnowienie wirowania (tg spin2win: spin_cooldown_time)
	var/spin_cooldown_time = 25 SECONDS
	/// AQUILA - czas wirowania (tg spin2win: spin_duration)
	var/spin_duration = 5 SECONDS
	COOLDOWN_DECLARE(spin_cooldown)

/obj/item/cult_bastard/Initialize(mapload)
	. = ..()
	set_light(4)
	AddComponent(/datum/component/butchering, 50, 80)
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)

/obj/item/cult_bastard/examine(mob/user)
	. = ..()
	var/souls = 0
	for(var/obj/item/soulstone/stone in contents)
		souls++
	if(souls)
		. += span_notice("W rdzeniu miecza uwięziono dusz: <b>[souls]</b>.")

/// AQUILA - tg spin2win: wirowanie na użycie w ręce
/obj/item/cult_bastard/attack_self(mob/living/user)
	if(spinning)
		return
	if(!COOLDOWN_FINISHED(src, spin_cooldown))
		to_chat(user, span_warning("Runy miecza jeszcze nie odzyskały mocy."))
		return
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		return
	COOLDOWN_START(src, spin_cooldown, spin_cooldown_time)
	on_spin(user, spin_duration)
	addtimer(CALLBACK(src, PROC_REF(on_unspin), user), spin_duration)

/obj/item/cult_bastard/proc/on_spin(mob/living/user, duration)
	// AQUILA - kolor, odporność na ogłuszenie i obrót robi nasz status_effect/sword_spin (z komunikatami)
	user.apply_status_effect(/datum/status_effect/sword_spin)
	block_chance = 100
	slowdown += 1.5
	spinning = TRUE

/obj/item/cult_bastard/proc/on_unspin(mob/living/user)
	block_chance = 50
	slowdown -= 1.5
	spinning = FALSE

/obj/item/cult_bastard/can_be_pulled(user)
	return FALSE

/obj/item/cult_bastard/pickup(mob/living/user)
	. = ..()
	if(!IS_CULTIST(user))
		if(!IS_HERETIC(user))
			to_chat(user, span_cultlarge("\"Nie radziłbym.\"") )
			force = 5
			return
		else
			to_chat(user, span_cultlarge("\"Czepiasz się Zapomnianych Bogów, jakbyś był dla nich kimś więcej niż pionkiem.\""))
			to_chat(user, span_userdanger("Straszliwa siła szarpie cię za rękę!"))
			user.emote("scream")
			user.apply_damage(30, BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
			user.dropItemToGround(src, TRUE)
			user.Paralyze(50)
			return
	force = initial(force)

/obj/item/cult_bastard/IsReflect(def_zone)
	if(!spinning)
		return FALSE
	return TRUE

/obj/item/cult_bastard/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	if(!prob(block_chance))
		return FALSE
	owner.visible_message(span_danger("[owner] paruje [attack_text] za pomocą [src]!"))
	return TRUE

/// AQUILA - zamiast tg soul_stealer: łapie duszę pokonanego człowieka do zwykłego odłamka (nie doskonałego) w mieczu,
/// a dusze z miecza można wlać w skorupę konstruktu. Logika ze starego miecza Bee.
/obj/item/cult_bastard/afterattack(atom/target, mob/user, proximity, click_parameters)
	. = ..()
	if(!proximity)
		return
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.stat != CONSCIOUS)
			var/obj/item/soulstone/SS = new /obj/item/soulstone(src)
			SS.attack(H, user)
			if(!LAZYLEN(SS.contents))
				qdel(SS)
	if(istype(target, /obj/structure/constructshell))
		var/obj/item/soulstone/SS = locate() in contents
		if(istype(SS))
			SS.transfer_soul("CONSTRUCT", target, user)
			qdel(SS)
