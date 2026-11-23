// AQUILA: lawowy pędrak (lavagrub) - port of Shiptest code/modules/mob/living/simple_animal/hostile/mining_mobs/goldgrub.dm
// (/mob/living/simple_animal/hostile/asteroid/goldgrub/lavagrub, AGPLv3) as a subtype of our basic goldgrub. Sprites:
// Shiptest icons/mob/lavaland/lavaland_monsters.dmi (CC BY-SA 3.0), copied to aquila/icons/planets/fauna/lava_fauna.dmi.
// As in Shiptest it is a goldgrub that leaves burning ground behind it and bursts into flames when it dies (our turf fires,
// /turf/proc/IgniteTurf(), stand in for Shiptest's ignite_turf() and flame_radius()). A dead lavagrub being dragged does
// not set fires (Shiptest's does).

/// Radius of the fire a dying lavagrub leaves
#define LAVAGRUB_DEATH_FIRE_RADIUS 2

/mob/living/basic/mining/goldgrub/lavagrub
	name = "lawowy pędrak"
	desc = "Robak, który tyje, pożerając wszystko, co zobaczy. Ta wyjątkowa mutacja, spotykana na planetoidach lawowych, podpala wszystko wokół siebie, pewnie żeby odstraszyć drapieżniki."
	icon = 'aquila/icons/planets/fauna/lava_fauna.dmi'
	icon_state = "lavagrub"
	icon_living = "lavagrub"
	icon_dead = "lavagrub_dead"
	death_message = "nieruchomieje, a jego truchło staje w płomieniach!"

/mob/living/basic/mining/goldgrub/lavagrub/Initialize(mapload)
	. = ..()
	// replaces the goldgrub's alert sprite (one appearance_on_aggro per mob)
	AddComponent(/datum/component/appearance_on_aggro, aggro_state = "lavagrub_alert", target_key = BB_BASIC_MOB_FLEE_TARGET)

/mob/living/basic/mining/goldgrub/lavagrub/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	if (stat == DEAD || !isturf(OldLoc) || OldLoc == loc)
		return
	var/turf/flame_to_turf = OldLoc
	flame_to_turf.IgniteTurf(10)

/mob/living/basic/mining/goldgrub/lavagrub/death(gibbed)
	var/turf/death_turf = get_turf(src)
	. = ..()
	if (isnull(death_turf))
		return
	for (var/turf/open/turf_to_flame in circlerangeturfs(death_turf, LAVAGRUB_DEATH_FIRE_RADIUS))
		turf_to_flame.IgniteTurf(5)

#undef LAVAGRUB_DEATH_FIRE_RADIUS
