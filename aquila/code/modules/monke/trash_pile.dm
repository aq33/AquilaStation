// Sterty śmieci z Monkestation (code/game/objects/structures/trash_pile.dm).
// Różnice: płaska pula śmieci z pickweight (nie mamy zagnieżdżonych tabel tg), bez elementu elevation,
// a eject_mob naprawdę wyrzuca chowającego się (u Monke tylko grał alert).

/// Ile śmieci najwyżej wyrzuci jedna osoba w trakcie jednego grzebania
#define MAXIMUM_TRASH_THROWS 7

/// Śmieci wyrzucane w trakcie grzebania (typ = waga)
GLOBAL_LIST_INIT(trash_pile_loot, list(
	/obj/item/trash/can = 60,
	/obj/item/trash/candy = 60,
	/obj/item/trash/candle = 30,
	/obj/item/trash/cheesie = 60,
	/obj/item/trash/chips = 60,
	/obj/item/trash/pistachios = 60,
	/obj/item/trash/popcorn = 60,
	/obj/item/trash/raisins = 60,
	/obj/item/trash/sosjerky = 60,
	/obj/item/cigbutt = 60,
	/obj/item/paper/crumpled = 60,
	/obj/item/shard = 30,
	/obj/item/stack/sheet/cardboard = 30,
	/obj/item/light/bulb = 20,
	/obj/item/light/tube = 20,
	/obj/item/c_tube = 20,
	/obj/item/paper = 20,
	/obj/item/pen = 15,
	/obj/item/folder/yellow = 10,
	/obj/item/storage/box = 15,
	/obj/item/clothing/mask/breath = 15,
	/obj/item/food/urinalcake = 5,
	/obj/item/stock_parts/capacitor = 10,
	/obj/item/stock_parts/manipulator = 10,
	/obj/item/stock_parts/matter_bin = 10,
	/obj/item/stock_parts/micro_laser = 10,
	/obj/item/stock_parts/scanning_module = 10,
	/obj/item/rack_parts = 5,
	/obj/item/camera_film = 5,
	/obj/item/hand_labeler = 5,
	/obj/item/toy/eightball = 5,
	/obj/item/coin/silver = 5,
	/obj/item/poster/random_contraband = 5,
	/obj/item/poster/random_official = 5,
	/obj/item/grown/bananapeel = 10,
	/obj/item/grown/bananapeel/bluespace = 1,
))

/obj/structure/trash_pile
	name = "sterta śmieci"
	desc = "Zbita kupa śmieci. Może jest w środku coś ciekawego?"
	icon = 'aquila/icons/obj/monke/trash_piles.dmi'
	icon_state = "randompile"
	density = TRUE
	anchored = TRUE
	climbable = TRUE
	layer = TABLE_LAYER
	pass_flags_self = LETPASSTHROW
	max_integrity = 50
	var/hide_person_time = 3 SECONDS
	var/hide_item_time = 1 SECONDS
	/// ckey => TRUE, kto już dostał łup z tej sterty
	var/list/searched_by_ckeys = list()
	/// ckey => ile śmieci jeszcze może wyrzucić
	var/list/remaining_trash_throws = list()
	/// Kto właśnie grzebie albo się chowa
	var/list/busy_users = list()
	var/trash_delay = 0.5 SECONDS
	var/funny_sound_delay = 0.2 SECONDS
	COOLDOWN_DECLARE(trash_cooldown)
	COOLDOWN_DECLARE(funny_sound_cooldown)
	/// Śmieszne dźwięki przy grzebaniu (dźwięk = waga)
	var/static/list/funny_sounds = list(
		'sound/effects/adminhelp.ogg' = 1,
		'sound/effects/clownstep1.ogg' = 5,
		'sound/effects/clownstep2.ogg' = 5,
		'sound/effects/attackblob.ogg' = 10,
		'sound/effects/bang.ogg' = 10,
		'sound/effects/bin_close.ogg' = 20,
		'sound/effects/bin_open.ogg' = 20,
		'sound/effects/cashregister.ogg' = 1,
		'sound/effects/glassbash.ogg' = 50,
		'sound/effects/glassbr1.ogg' = 20,
		'sound/effects/glassbr2.ogg' = 20,
		'sound/effects/glassbr3.ogg' = 20,
		'sound/effects/grillehit.ogg' = 20,
		'sound/effects/hit_on_shattered_glass.ogg' = 20,
		'sound/effects/rustle1.ogg' = 100,
		'sound/effects/rustle2.ogg' = 100,
		'sound/effects/rustle3.ogg' = 100,
		'sound/effects/rustle4.ogg' = 100,
		'sound/effects/rustle5.ogg' = 100,
	)

/obj/structure/trash_pile/Initialize(mapload)
	. = ..()
	icon_state = pick("pile1", "pile2", "pilechair", "piletable", "pilevending", "brtrashpile", "microwavepile", "rackpile", "boxfort", "trashbag", "brokecomp")

/obj/structure/trash_pile/Destroy()
	var/atom/drop_loc = drop_location()
	for(var/atom/movable/thing as anything in contents)
		thing.forceMove(drop_loc)
	busy_users = null
	return ..()

/obj/structure/trash_pile/add_context_self(datum/screentip_context/context, mob/user)
	context.add_attack_hand_action("Przeszukaj")
	context.add_right_click_action("Schowaj się")
	context.add_left_click_item_action("Schowaj przedmiot", /obj/item)

/obj/structure/trash_pile/attack_hand(mob/living/user, list/modifiers)
	if(user in contents)
		eject_mob(user)
		return TRUE
	if(busy_users[user])
		return TRUE
	if(!ishuman(user) || user.combat_mode || !user.ckey)
		return ..()

	user.visible_message("<span class='notice'>[user] grzebie w [src]...</span>", "<span class='notice'>Grzebiesz w [src]...</span>")
	playsound(src, pick('sound/effects/rustle1.ogg', 'sound/effects/rustle2.ogg', 'sound/effects/rustle3.ogg', 'sound/effects/rustle4.ogg', 'sound/effects/rustle5.ogg'), 50)
	busy_users[user] = TRUE
	var/success = do_after(user, 3 SECONDS, target = src, extra_checks = CALLBACK(src, PROC_REF(throw_trash), user))
	if(QDELETED(src))
		return TRUE
	busy_users -= user
	if(!success)
		return TRUE

	var/content_length = length(contents)
	if(content_length)
		var/atom/movable/hidden = contents[content_length]
		if(isliving(hidden))
			balloon_alert(user, "ktoś tu jest!")
			eject_mob(hidden)
		else
			balloon_alert(user, "coś znalazłeś!")
			hidden.forceMove(drop_location())
		return TRUE
	if(searched_by_ckeys[user.ckey])
		balloon_alert(user, "pusto...")
		return TRUE
	searched_by_ckeys[user.ckey] = TRUE
	var/item_to_spawn = pickweight(GLOB.maintenance_loot)
	if(!ispath(item_to_spawn))
		balloon_alert(user, "nic nie ma...")
		return TRUE
	var/atom/movable/spawned_item = new item_to_spawn(drop_location())
	if(QDELETED(spawned_item))
		balloon_alert(user, "nic nie ma...")
	else
		balloon_alert(user, "znalazłeś [spawned_item.name]!")
	return TRUE

/obj/structure/trash_pile/attackby(obj/item/attacking_item, mob/living/user, params)
	if(user in contents)
		eject_mob(user)
		return
	if(user.combat_mode || busy_users[user])
		return ..()
	if(length(contents) >= 10)
		balloon_alert(user, "pełna!")
		return
	balloon_alert(user, "chowam przedmiot...")
	busy_users[user] = TRUE
	var/success = do_after(user, hide_item_time, target = src)
	if(QDELETED(src))
		return
	busy_users -= user
	if(!success || QDELETED(attacking_item))
		return
	if(user.transferItemToLoc(attacking_item, src))
		balloon_alert(user, "przedmiot schowany!")

/obj/structure/trash_pile/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(!iscarbon(user) || busy_users[user] || (user in contents))
		return
	var/mob/living/carbon/carbon_user = user
	if(!(carbon_user.mobility_flags & MOBILITY_MOVE))
		return
	carbon_user.visible_message("<span class='warning'>[carbon_user] zaczyna nurkować w [src].</span>", "<span class='notice'>Zaczynasz nurkować w [src]...</span>")
	var/dive_time = hide_person_time
	if(carbon_user.restrained())
		dive_time *= 2
	busy_users[carbon_user] = TRUE
	var/success = do_after(carbon_user, dive_time, target = src)
	if(QDELETED(src))
		return
	busy_users -= carbon_user
	if(!success)
		return
	for(var/mob/living/hidden_mob in contents)
		balloon_alert(carbon_user, "ktoś tu jest!")
		eject_mob(hidden_mob)
		return
	carbon_user.forceMove(src)

/obj/structure/trash_pile/container_resist(mob/living/user)
	user.forceMove(drop_location())

/obj/structure/trash_pile/relaymove(mob/living/user, direction)
	container_resist(user)

/// Wyrzuca śmieć w stronę grzebiącego; extra_checks do_after, więc FALSE przerywa grzebanie
/obj/structure/trash_pile/proc/throw_trash(mob/user)
	if(QDELETED(src) || QDELETED(user))
		return FALSE
	if(!user.CanReach(src))
		return FALSE
	var/ckey = user.ckey
	if(searched_by_ckeys[ckey])
		return TRUE
	if(isnull(remaining_trash_throws[ckey]))
		remaining_trash_throws[ckey] = MAXIMUM_TRASH_THROWS
	else if(remaining_trash_throws[ckey] < 1)
		return TRUE

	if(COOLDOWN_FINISHED(src, trash_cooldown))
		COOLDOWN_START(src, trash_cooldown, trash_delay * 0.5 + rand() * trash_delay)
		remaining_trash_throws[ckey]--
		var/item_to_spawn = pickweight(GLOB.trash_pile_loot)
		var/obj/item/spawned_item = new item_to_spawn(drop_location())
		if(!QDELETED(spawned_item))
			var/turf/throw_target = get_ranged_target_turf_direct(src, user, 7, rand(-60, 60))
			if(spawned_item.safe_throw_at(throw_target, rand(2, 4), rand(1, 3), user, spin = TRUE))
				playsound(src, 'sound/weapons/punchmiss.ogg', 10)

	if(COOLDOWN_FINISHED(src, funny_sound_cooldown))
		COOLDOWN_START(src, funny_sound_cooldown, funny_sound_delay * 0.5 + rand() * funny_sound_delay)
		playsound(src, pickweight(funny_sounds), 25)
	return TRUE

/// Wyrzuca schowanego moba ze sterty
/obj/structure/trash_pile/proc/eject_mob(mob/living/hidden_mob)
	playsound(src, 'sound/machines/chime.ogg', 50, FALSE, -5)
	hidden_mob.forceMove(drop_location())
	hidden_mob.do_alert_animation(hidden_mob)
	return TRUE

#undef MAXIMUM_TRASH_THROWS
