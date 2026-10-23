/// Scout and assassin who can appear and disappear from glass surfaces. Damaged by being examined.
/mob/living/simple_animal/hostile/heretic_summon/maid_in_the_mirror
	name = "\improper Maid in the Mirror"
	real_name = "Maid in the Mirror"
	desc = "Unoszący się, płynący obłok zmrożonego powietrza. Gdy na niego zerkniesz, lekko migocze."
	icon = 'aquila/icons/mob/simple/mob.dmi'
	icon_state = "stand"
	icon_living = "stand" // Placeholder sprite... still
	speak_emote = list("szepcze")
	movement_type = FLOATING
	status_flags = CANSTUN | CANPUSH
	attack_sound = "shatter"
	maxHealth = 80
	health = 80
	melee_damage = 14
	sight = SEE_MOBS | SEE_OBJS | SEE_TURFS
	deathmessage = "roztrzaskuje się i znika, uwalniając podmuch zimnego powietrza."
	loot = list(
		/obj/effect/decal/cleanable/ash,
		/obj/item/clothing/suit/armor/vest,
		/obj/item/organ/lungs,
		/obj/item/shard,
	)
	/// Whether we take damage when someone looks at us
	var/harmed_by_examine = TRUE
	/// How often being examined by a specific mob can hurt us
	var/recent_examine_damage_cooldown = 10 SECONDS
	/// A list of REFs to people who recently examined us
	var/list/recent_examiner_refs = list()
	/// The 1920s English/Welsh name appended to the end of the maid's title.
	var/antiquated_name
	/// A large list of names. One is randomly chosen upon mirror maid creation and removed
	/// to prevent duplicates. If somehow emptied, the list is restored to its original state.
	var/static/list/antiquated_names

/mob/living/simple_animal/hostile/heretic_summon/maid_in_the_mirror/Initialize(mapload)
	. = ..()
	var/datum/action/cooldown/spell/jaunt/mirror_walk/walk = new(src)
	walk.Grant(src)
	ADD_TRAIT(src, TRAIT_UNHITTABLE_BY_LASERS, INNATE_TRAIT)

	if(!length(antiquated_names))
		antiquated_names = GLOB.mirror_maid_names.Copy()

	antiquated_name = pick_n_take(antiquated_names)
	name = "Mirror Maid [antiquated_name]"
	real_name = name

// AQUILA - u nas cecha TRAIT_UNHITTABLE_BY_LASERS nic nie robi, więc tu lasery po prostu przez nią przelatują
/mob/living/simple_animal/hostile/heretic_summon/maid_in_the_mirror/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	if(istype(P, /obj/item/projectile/beam))
		return BULLET_ACT_FORCE_PIERCE
	return ..()

/mob/living/simple_animal/hostile/heretic_summon/maid_in_the_mirror/death(gibbed)
	var/turf/open/death_turf = get_turf(src)
	if(istype(death_turf))
		death_turf.TakeTemperature(-40) // Spooky
	return ..()

// Examining them will harm them, on a cooldown.
/mob/living/simple_animal/hostile/heretic_summon/maid_in_the_mirror/examine(mob/user)
	. = ..()
	if(!harmed_by_examine || user == src || user.stat == DEAD || !isliving(user) || IS_HERETIC_OR_MONSTER(user))
		return

	var/user_ref = REF(user)
	if(user_ref in recent_examiner_refs)
		return

	// If we have health, we take some damage
	if(health > (maxHealth * 0.02))
		visible_message(
				span_warning("[src] lekko blednie i znów się pojawia."),
				span_userdanger("Spojrzenie [user] przeszywa całe twoje jestestwo!"),
		)

		recent_examiner_refs += user_ref
		apply_damage(maxHealth * 0.02) // We take 2% of our health as damage upon being examined
		playsound(src, 'sound/effects/ghost2.ogg', 40, TRUE)
		addtimer(CALLBACK(src, PROC_REF(clear_recent_examiner), user_ref), recent_examine_damage_cooldown)
		animate(src, alpha = 120, time = 0.5 SECONDS, easing = ELASTIC_EASING, loop = 2, flags = ANIMATION_PARALLEL)
		animate(alpha = 255, time = 0.5 SECONDS, easing = ELASTIC_EASING)

	// If we're examined on low enough health we die straight up
	else
		visible_message(
				span_danger("[src] znika z istnienia!"),
				span_userdanger("Spojrzenie [user] roztrzaskuje twoją postać i cię niszczy!"),
		)

		death()

/mob/living/simple_animal/hostile/heretic_summon/maid_in_the_mirror/proc/clear_recent_examiner(mob_ref)
	if(QDELETED(src) || !(mob_ref in recent_examiner_refs))
		return

	recent_examiner_refs -= mob_ref
	heal_overall_damage(5)

/mob/living/simple_animal/hostile/heretic_summon/maid_in_the_mirror/on_melee_hit(mob/living/victim)
	victim.apply_status_effect(/datum/status_effect/void_chill, 1)
