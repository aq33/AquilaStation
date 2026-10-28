// AQUILA - bullets staying in the body, from tgstation (/datum/embedding/bullet): 20% at point blank, 3 less for each
// tile flown and half the armor less. The bullet becomes our ballistic fragment (detective work keeps its rifling)
// embedded in the limb without a message: it hurts when moving and can be pulled out by hand, with a hemostat or by
// the foreign body removal surgery. Armor piercing and non-lethal rounds don't stay.

/obj/item/projectile/bullet
	/// Chance to stay in the body at point blank
	var/lodge_chance = 20

/obj/item/projectile/bullet/proc/try_lodge(mob/living/carbon/human/target, blocked)
	if(!lodge_chance || wound_kind != WOUND_PIERCE)
		return
	var/chance = lodge_chance - 3 * get_dist(starting, target) - blocked * 0.5
	if(!prob(chance))
		return
	var/obj/item/bodypart/limb = target.get_bodypart(target.check_limb_hit(def_zone)) || target.get_bodypart(BODY_ZONE_CHEST)
	if(!limb || !IS_ORGANIC_LIMB(limb))
		return
	var/obj/item/bullet_fragment/fragment = new(get_turf(target), ballistic_id, ballistic_caliber)
	fragment.tryEmbed(limb, forced = TRUE, silent = TRUE)
	if(!(fragment in limb.embedded_objects))
		qdel(fragment)
		return
	return fragment

/obj/item/bullet_fragment
	embedding = list("embed_chance" = 100, "fall_chance" = 0.5, "pain_chance" = 15, "pain_mult" = 2, "impact_pain_mult" = 4, \
		"remove_pain_mult" = 6, "rip_time" = 3 SECONDS, "ignore_throwspeed_threshold" = TRUE, "jostle_chance" = 5, "jostle_pain_mult" = 1)

/obj/item/projectile/bullet/c10mm_ap
	lodge_chance = 0
/obj/item/projectile/bullet/c46x30mm_ap
	lodge_chance = 0
/obj/item/projectile/bullet/c9mm_ap
	lodge_chance = 0
/obj/item/projectile/bullet/mac_round/ap
	lodge_chance = 0
/obj/item/projectile/bullet/mm712x82_ap
	lodge_chance = 0
/obj/item/projectile/bullet/shrapnel
	lodge_chance = 0 // already embeds its own shard
/obj/item/projectile/bullet/dart
	lodge_chance = 0
/obj/item/projectile/bullet/reusable
	lodge_chance = 0
