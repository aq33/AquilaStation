/*!
 * Contains the eldritch robes for heretics, a suit of armor that they can make via a ritual
 */

// AQUILA - różnice wobec tg:
// - pancerz to nasza lista armor (rany tg -> "bleed", stamina jak melee, rad jak bio albo 100 przy ochronie przed promieniowaniem),
// - clothing_traits z tg -> robe_traits nakładane na noszącego przy założeniu,
// - tekstury części ciała (bodypart_texture) z tg pominięte (u nas brak systemu),
// - kaptur: nasze /hooded nie ma on_hood_up/on_hood_down, więc wołamy je z ToggleHood()/RemoveHood().

// Eldritch armor. Looks cool, hood lets you cast heretic spells.
/obj/item/clothing/suit/hooded/cultrobes/eldritch
	name = "ominous armor"
	desc = "Podarta, zakurzona szata. Od środka wyścielają ją dziwne oczy."
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "eldritch_armor"
	item_state = "eldritch_armor"
	flags_inv = HIDESHOES | HIDEJUMPSUIT | HIDEBELT
	body_parts_covered = CHEST | GROIN | LEGS | FEET | ARMS
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	clothing_flags = THICKMATERIAL
	transparent_protection = HIDEGLOVES | HIDESUITSTORAGE | HIDEJUMPSUIT | HIDESHOES | HIDENECK
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	allowed = list(/obj/item/melee/sickly_blade, /obj/item/gun/ballistic/rifle/lionhunter, /obj/item/flashlight/lantern/heretic)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 35, "bio" = 20, "rad" = 20, "fire" = 20, "acid" = 20, "stamina" = 50, "bleed" = 20)
	/// AQUILA - tg: clothing_traits; cechy nadawane każdemu, kto nosi szatę
	var/list/robe_traits = list(TRAIT_HERETIC_AURA_HIDDEN)
	// hood_up dziedziczone z /obj/item/clothing/suit/hooded/cultrobes (kult krwi „Cult 4”)
	/// AQUILA - czy efekty szaty (on_robes_gained) są teraz aktywne
	var/robes_active = FALSE

/obj/item/clothing/suit/hooded/cultrobes/eldritch/equipped(mob/user, slot, initial)
	. = ..()
	if(!(slot_flags & slot))
		return
	if(length(robe_traits))
		user.add_traits(robe_traits, REF(src))
	if(!IS_HERETIC(user))
		robes_side_effect(user)
		return
	// Heretic equipped the robes? Grant them the effects
	robes_active = TRUE
	on_robes_gained(user)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/dropped(mob/living/user)
	. = ..()
	if(length(robe_traits))
		user.remove_traits(robe_traits, REF(src))
	if(!robes_active)
		return
	robes_active = FALSE
	on_robes_lost(user)

/// Adds effects to the user when they equip their robes
/obj/item/clothing/suit/hooded/cultrobes/eldritch/proc/on_robes_gained(mob/living/user)
	return

/// Removes any effects that our robes have, returns `TRUE` if the item dropped was not robes
/obj/item/clothing/suit/hooded/cultrobes/eldritch/proc/on_robes_lost(mob/living/user)
	return

/// Applies a punishment to the user when the robes are equipped
/obj/item/clothing/suit/hooded/cultrobes/eldritch/proc/robes_side_effect(mob/living/user)
	SHOULD_NOT_SLEEP(TRUE) // sleep here would fuck over the timing

/obj/item/clothing/suit/hooded/cultrobes/eldritch/proc/is_equipped(mob/wearer)
	if(!ishuman(wearer))
		return FALSE
	var/mob/living/carbon/human/human_wearer = wearer
	return human_wearer.wear_suit == src

/obj/item/clothing/suit/hooded/cultrobes/eldritch/ToggleHood()
	var/was_up = suittoggled
	. = ..()
	if(!was_up && suittoggled)
		on_hood_up(hood)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/RemoveHood()
	var/was_up = suittoggled
	. = ..()
	if(was_up)
		on_hood_down(hood)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/proc/on_hood_up(obj/item/clothing/head/hooded/hood)
	hood_up = TRUE

/obj/item/clothing/suit/hooded/cultrobes/eldritch/proc/on_hood_down(obj/item/clothing/head/hooded/hood)
	hood_up = FALSE

/obj/item/clothing/head/hooded/cult_hoodie/eldritch
	name = "ominous hood"
	desc = "Podarty, zakurzony kaptur. Od środka wyścielają go dziwne oczy."
	icon = 'icons/obj/clothing/hats.dmi'
	icon_state = "eldritch"
	flags_inv = HIDEMASK | HIDEEARS | HIDEEYES | HIDEFACE | HIDEHAIR | HIDEFACIALHAIR | HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	flash_protect = 2
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	clothing_flags = THICKMATERIAL | SNUG_FIT
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 35, "bio" = 20, "rad" = 20, "fire" = 20, "acid" = 20, "stamina" = 50, "bleed" = 20)

//---- Path-Specific Eldritch Robes, First is robes, then is hood

// Ash
// Prevents fire from decaying while worn, also passively generates fire via the toggle
/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash
	name = "\improper Scorched Mantle"
	desc = "Pozostawiony, by spłonąć w strzępy, jest dziś ledwie poczerniałym echem płaszcza Straży. \
		A jednak zadymione fałdy odbijają ostrze i płomień od tego, kto je nosi. Krótka ulga, zanim jego spojrzenie zwróci się do środka."
	icon = 'aquila/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'aquila/icons/mob/clothing/suits/armor.dmi'
	icon_state = "ash_armor"
	worn_icon_state = "ash_armor"
	item_state = null
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/ash
	armor = list("melee" = 40, "bullet" = 60, "laser" = 50, "energy" = 50, "bomb" = 100, "bio" = 20, "rad" = 100, "fire" = 100, "acid" = 20, "stamina" = 40, "bleed" = 20)
	flags_inv = HIDEBELT
	body_parts_covered = FULL_BODY
	heat_protection = FULL_BODY
	max_heat_protection_temperature = 50000
	cold_protection = FULL_BODY
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF | LAVA_PROOF | FREEZE_PROOF
	actions_types = list(/datum/action/item_action/toggle_hood, /datum/action/item_action/toggle/flames)
	/// If our robes are actively generating flames
	var/flame_generation = FALSE
	/// Cooldown before our robes will create new flames
	COOLDOWN_DECLARE(flame_creation)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/on_robes_gained(mob/living/user)
	// AQUILA - tg: fire_stack_decay_rate = 0; u nas ogień gaśnie co Life(), więc szata uzupełnia ubytek w process()
	START_PROCESSING(SSobj, src)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/on_robes_lost(mob/living/user)
	if(flame_generation)
		toggle_flames(user)
	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/robes_side_effect(mob/living/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/victim = user
	var/iteration = 0
	for(var/obj/item/bodypart/limb as anything in victim.get_bodyparts())
		if(istype(limb, /obj/item/bodypart/head) || istype(limb, /obj/item/bodypart/chest))
			continue
		iteration++
		addtimer(CALLBACK(src, PROC_REF(burn_limbs), limb), 1 SECONDS * iteration)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/proc/burn_limbs(obj/item/bodypart/limb)
	if(QDELETED(limb) || !limb.owner || !is_equipped(limb.owner))
		return
	limb.dismember(BURN)

/datum/action/item_action/toggle/flames
	name = "Toggle Flames"
	icon_icon = 'aquila/icons/effects/magic.dmi'
	button_icon_state = "fireball"

/datum/action/item_action/toggle/flames/Trigger()
	var/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/item_target = target
	if(!istype(item_target) || !IsAvailable())
		return FALSE
	item_target.toggle_flames(owner)
	return TRUE

/// Starts/Stops the passive generation of fire stacks on our wearer
/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/proc/toggle_flames(mob/living/user)
	flame_generation = !flame_generation

	if(!flame_generation)
		// Extinguishes the wearer after they disable the flames
		user.extinguish_mob()

	user.balloon_alert(user, flame_generation ? "włączono" : "wyłączono")

/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash/process(seconds_per_tick)
	var/mob/living/wearer = loc
	if(!isliving(wearer) || !robes_active)
		flame_generation = FALSE
		return PROCESS_KILL
	// Ogień na noszącym nie wygasa sam z siebie
	if(wearer.on_fire && wearer.fire_stacks > 0)
		wearer.adjust_fire_stacks(0.1)
	if(!flame_generation || !COOLDOWN_FINISHED(src, flame_creation))
		return
	COOLDOWN_START(src, flame_creation, 5 SECONDS)
	wearer.adjust_fire_stacks(1)
	wearer.ignite_mob(TRUE)

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/ash
	name = "\improper Scorched Mantle"
	desc = "Pozostawiony, by spłonąć w strzępy, jest dziś ledwie poczerniałym echem płaszcza Straży. \
		A jednak zadymione fałdy odbijają ostrze i płomień od tego, kto je nosi. Krótka ulga, zanim jego spojrzenie zwróci się do środka."
	icon = 'aquila/icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'aquila/icons/mob/clothing/head/helmet.dmi'
	icon_state = "ash_armor"
	armor = list("melee" = 40, "bullet" = 60, "laser" = 50, "energy" = 50, "bomb" = 100, "bio" = 20, "rad" = 100, "fire" = 100, "acid" = 20, "stamina" = 40, "bleed" = 20)
	heat_protection = HEAD
	max_heat_protection_temperature = 50000
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF | LAVA_PROOF | FREEZE_PROOF

// Blade
// Is shock-proof and gives you baton resistance
/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade
	name = "\improper Shattered Panoply"
	desc = "Naostrzone krawędzie tego starożytnego pancerza głoszą prawdę znaną adeptom bitwy: \
		prawdziwego wojownika nie da się odróżnić od ostrza, którym włada."
	icon = 'aquila/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'aquila/icons/mob/clothing/suits/armor.dmi'
	icon_state = "blade_armor"
	worn_icon_state = "blade_armor"
	item_state = null
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/blade
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 50, "bio" = 50, "rad" = 50, "fire" = 50, "acid" = 50, "stamina" = 50, "bleed" = 50)
	siemens_coefficient = 0
	var/murdering_with_blades = FALSE

/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/on_robes_gained(mob/living/user)
	. = ..()
	user.add_traits(list(TRAIT_SHOCKIMMUNE, TRAIT_BATON_RESISTANCE, TRAIT_STUNRESISTANCE), REF(src))

/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/on_robes_lost(mob/user, obj/item/clothing/suit/hooded/cultrobes/eldritch/robes)
	. = ..()
	if(.)
		return
	user.remove_traits(list(TRAIT_SHOCKIMMUNE, TRAIT_BATON_RESISTANCE, TRAIT_STUNRESISTANCE), REF(src))

/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/robes_side_effect(mob/living/user)
	INVOKE_ASYNC(src, PROC_REF(start_throwing_blades), user)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/proc/start_throwing_blades(mob/living/target)
	if(murdering_with_blades)
		return
	murdering_with_blades = TRUE

	var/delay = 2 SECONDS
	var/knives = 100
	for(var/knife in 1 to knives)
		if(!should_keep_cutting(target))
			break
		addtimer(CALLBACK(src, PROC_REF(cut_em_good), target), delay * knife)
		delay = max(0.5 SECONDS, delay - 0.1 SECONDS)

	murdering_with_blades = FALSE

/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/proc/should_keep_cutting(mob/living/target)
	if(target.stat == DEAD || !is_equipped(target))
		return FALSE
	return TRUE

/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/proc/cut_em_good(mob/living/target)
	if(!should_keep_cutting(target))
		return
	var/list/turf/valid_turfs = get_blade_turfs(get_turf(target))
	if(!length(valid_turfs))
		if(iscarbon(target))
			var/mob/living/carbon/carbon_target = target
			// AQUILA - ciężka rana cięta na lekkich ranach Aquili
			var/obj/item/bodypart/limb = pick(carbon_target.get_bodyparts())
			carbon_target.apply_damage(10, BRUTE, limb)
			limb.aq_force_wound(WOUND_SLASH, WOUND_SEVERITY_SEVERE)
		return
	throw_blade(pick(valid_turfs), target)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/proc/get_blade_turfs(turf/center)
	var/list/valid_turfs = list()
	if(!center)
		return valid_turfs
	// tg: get_perimeter(center, 4) - pierścień pól w odległości 4
	for(var/turf/open/valid_turf in range(4, center))
		if(get_dist(valid_turf, center) != 4)
			continue
		if(!is_blocked_turf(valid_turf) && get_angle(valid_turf, center) != 180)
			valid_turfs |= valid_turf
	return valid_turfs

/obj/item/kitchen/knife/magic
	icon = 'aquila/icons/effects/eldritch.dmi'
	icon_state = "dio_knife"
	name = "magic knife"
	throwforce = 15
	// most importantly, this ignores shields
	armour_penetration = 200
	pass_flags = ALL
	embedding = list("embed_chance" = 150, "fall_chance" = 0, "pain_mult" = 0, "impact_pain_mult" = 0, "ignore_throwspeed_threshold" = TRUE)

/obj/item/kitchen/knife/magic/Initialize(mapload)
	. = ..()
	// AQUILA - tg: movetype_handler + cechy ruchu; u nas typ ruchu wprost
	setMovetype(movement_type | PHASING | FLYING)
	add_traits(list(TRAIT_UNCATCHABLE), INNATE_TRAIT)
	add_filter("dio_knife", 2, list("type" = "outline", "color" = "#ececff", "size" = 1))

/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade/proc/throw_blade(turf/target_turf, mob/user)
	var/obj/item/kitchen/knife/magic/knife = new(target_turf)
	knife.alpha = 0

	var/matrix/transform = matrix(knife.transform)
	var/angle = get_angle(target_turf, user)
	transform.Turn(angle)
	var/appear_delay = 0.5 SECONDS
	var/throw_delay = 1 SECONDS
	var/delete_delay = 10 SECONDS
	addtimer(CALLBACK(knife, TYPE_PROC_REF(/atom/movable, throw_at), user, 50, 5, null, FALSE), throw_delay)
	animate(knife, transform = transform, time = throw_delay, flags = ANIMATION_PARALLEL)
	animate(knife, alpha = 255, time = appear_delay, flags = ANIMATION_PARALLEL)
	animate(alpha = 0, time = delete_delay)
	QDEL_IN(knife, delete_delay + appear_delay + throw_delay)

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/blade
	name = "\improper Shattered Panoply"
	desc = "Naostrzone krawędzie tego starożytnego pancerza głoszą prawdę znaną adeptom bitwy: \
		prawdziwego wojownika nie da się odróżnić od ostrza, którym włada."
	icon = 'aquila/icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'aquila/icons/mob/clothing/head/helmet.dmi'
	icon_state = "blade_armor"
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 50, "bio" = 50, "rad" = 50, "fire" = 50, "acid" = 50, "stamina" = 50, "bleed" = 50)
	siemens_coefficient = 0

// Cosmic
// Allows you to toggle gravity for yourself at will
/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic
	name = "\improper Starwoven Cloak"
	desc = "Lśniące klejnoty przywołują smugi mocy, które krążą wokół, oświetlając noszącego przyćmionym blaskiem. \
		Patrząc na tę szatę, nie możesz oprzeć się wrażeniu, że ktoś cię zauważył."
	icon = 'aquila/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'aquila/icons/mob/clothing/suits/armor.dmi'
	icon_state = "cosmic_armor"
	worn_icon_state = "cosmic_armor"
	item_state = null
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/cosmic
	armor = list("melee" = 20, "bullet" = 30, "laser" = 60, "energy" = 60, "bomb" = 35, "bio" = 20, "rad" = 100, "fire" = 20, "acid" = 20, "stamina" = 20, "bleed" = 20)
	clothing_flags = THICKMATERIAL | STOPSPRESSUREDAMAGE
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	actions_types = list(/datum/action/item_action/toggle_hood, /datum/action/item_action/toggle/gravity)
	/// If our robes are making us weightless
	var/weightless_enabled = FALSE

// Removes your antigravity if you lose the robes
/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic/on_robes_lost(mob/user, obj/item/clothing/suit/hooded/cultrobes/eldritch/robes)
	if(.)
		return
	if(weightless_enabled)
		toggle_gravity(user)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic/robes_side_effect(mob/living/user)
	var/obj/item/organ/brain/victim_brain = user.getorganslot(ORGAN_SLOT_BRAIN)
	if(!victim_brain)
		return

	victim_brain.gain_trauma(/datum/brain_trauma/magic/stalker/cosmic, TRAUMA_RESILIENCE_MAGIC)

/datum/action/item_action/toggle/gravity
	name = "Toggle Gravity"
	icon_icon = 'aquila/icons/effects/magic.dmi'
	button_icon_state = "magicm"

/datum/action/item_action/toggle/gravity/Trigger()
	var/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic/item_target = target
	if(!istype(item_target) || !IsAvailable())
		return FALSE
	if(!item_target.robes_active)
		owner.balloon_alert(owner, "szata cię nie słucha!")
		return FALSE
	item_target.toggle_gravity(owner)
	return TRUE

/// Gives us free movement in 0 gravity when enabled
/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic/proc/toggle_gravity(mob/living/user)
	if(!weightless_enabled)
		user.add_traits(list(TRAIT_NEGATES_GRAVITY, TRAIT_MOVE_FLYING, TRAIT_FREE_HYPERSPACE_MOVEMENT), REF(src))
		// AQUILA - u nas swobodny ruch w nieważkości przez sygnał COMSIG_MOVABLE_SPACEMOVE
		RegisterSignal(user, COMSIG_MOVABLE_SPACEMOVE, PROC_REF(on_spacemove))
		user.balloon_alert(user, "włączono")
	else
		user.remove_traits(list(TRAIT_NEGATES_GRAVITY, TRAIT_MOVE_FLYING, TRAIT_FREE_HYPERSPACE_MOVEMENT), REF(src))
		UnregisterSignal(user, COMSIG_MOVABLE_SPACEMOVE)
		user.balloon_alert(user, "wyłączono")
	weightless_enabled = !weightless_enabled

/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic/proc/on_spacemove(mob/source, movement_dir)
	SIGNAL_HANDLER
	return COMSIG_MOVABLE_STOP_SPACEMOVE

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/cosmic
	name = "\improper Starwoven Hood"
	desc = "Lśniące klejnoty przywołują smugi mocy, które krążą wokół, oświetlając noszącego przyćmionym blaskiem. \
		Patrząc na tę szatę, nie możesz oprzeć się wrażeniu, że ktoś cię zauważył."
	icon = 'aquila/icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'aquila/icons/mob/clothing/head/helmet.dmi'
	icon_state = "cosmic_armor"
	armor = list("melee" = 20, "bullet" = 30, "laser" = 60, "energy" = 60, "bomb" = 35, "bio" = 20, "rad" = 100, "fire" = 20, "acid" = 20, "stamina" = 20, "bleed" = 20)
	clothing_flags = THICKMATERIAL | STOPSPRESSUREDAMAGE | SNUG_FIT
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT

// Flesh
// Emits a healing aura that affects any heretic summons (excluding the heretic himself)
/obj/item/clothing/suit/hooded/cultrobes/eldritch/flesh
	name = "\improper Writhing Embrace"
	desc = "Gnijące truchło - a może kilka - poskręcane w mięsiste polipy, zasupłane jelita i popękane kości. \
		Jak można to „nosić”, przekracza rozsądne pojmowanie. Porusza się, gdy myśli, że nikt nie patrzy."
	icon = 'aquila/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'aquila/icons/mob/clothing/suits/armor.dmi'
	icon_state = "flesh_armor"
	worn_icon_state = "flesh_armor"
	item_state = null
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/flesh
	armor = list("melee" = 70, "bullet" = 40, "laser" = 30, "energy" = 30, "bomb" = 35, "bio" = 100, "rad" = 100, "fire" = 0, "acid" = 100, "stamina" = 70, "bleed" = 20)
	/// The aura healing component. Used to delete it when taken off.
	var/datum/component/healing_aura

/obj/item/clothing/suit/hooded/cultrobes/eldritch/flesh/on_robes_gained(mob/living/user)
	QDEL_NULL(healing_aura)
	healing_aura = user.AddComponent( \
		/datum/component/aura_healing, \
		range = 15, \
		brute_heal = 3, \
		burn_heal = 3, \
		blood_heal = 3, \
		suffocation_heal = 3, \
		stamina_heal = 15, \
		simple_heal = 3, \
		requires_visibility = FALSE, \
		limit_to_trait = TRAIT_HERETIC_SUMMON, \
		healing_color = COLOR_RED, \
		self_heal = FALSE, \
	)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/flesh/on_robes_lost(mob/user, obj/item/clothing/suit/hooded/cultrobes/eldritch/robes)
	QDEL_NULL(healing_aura)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/flesh/robes_side_effect(mob/living/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/victim = user
	var/iteration = 0
	for(var/obj/item/bodypart/limb as anything in victim.get_bodyparts())
		iteration++
		addtimer(CALLBACK(src, PROC_REF(tear_limb), victim, limb), 1 SECONDS * iteration)

/// AQUILA - krytyczna rana cięta w każdej kończynie (lekkie rany Aquili) i obrażenia
/obj/item/clothing/suit/hooded/cultrobes/eldritch/flesh/proc/tear_limb(mob/living/carbon/victim, obj/item/bodypart/limb)
	if(QDELETED(victim) || QDELETED(limb) || limb.owner != victim || !is_equipped(victim))
		return
	victim.apply_damage(15, BRUTE, limb)
	limb.aq_force_wound(WOUND_SLASH, WOUND_SEVERITY_CRITICAL)
	playsound(victim, 'sound/weapons/bladeslice.ogg', 50, TRUE)

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/flesh
	name = "\improper Writhing Embrace"
	desc = "Gnijące truchło poskręcane w mięsiste polipy. Widać przez nie to, co kryje się pod skórą innych."
	icon = 'aquila/icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'aquila/icons/mob/clothing/head/helmet.dmi'
	icon_state = "flesh_armor"
	armor = list("melee" = 70, "bullet" = 40, "laser" = 30, "energy" = 30, "bomb" = 35, "bio" = 100, "rad" = 100, "fire" = 0, "acid" = 100, "stamina" = 70, "bleed" = 20)

// AQUILA - tg: clothing_traits = list(TRAIT_MEDICAL_HUD); u nas cecha + HUD medyczny
/obj/item/clothing/head/hooded/cult_hoodie/eldritch/flesh/equipped(mob/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_HEAD))
		return
	ADD_TRAIT(user, TRAIT_MEDICAL_HUD, REF(src))
	var/datum/atom_hud/med_hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	med_hud.add_hud_to(user)

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/flesh/dropped(mob/user)
	if(HAS_TRAIT_FROM(user, TRAIT_MEDICAL_HUD, REF(src)))
		REMOVE_TRAIT(user, TRAIT_MEDICAL_HUD, REF(src))
		if(!HAS_TRAIT(user, TRAIT_MEDICAL_HUD))
			var/datum/atom_hud/med_hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
			med_hud.remove_hud_from(user)
	return ..()

// Lock
// Gives you digital camo, silences your footsteps and makes you un-examineable
/obj/item/clothing/suit/hooded/cultrobes/eldritch/lock
	name = "\improper Shifting Guise"
	desc = "Szata bez stałego kształtu. Patrząc na noszącego, nie potrafisz zapamiętać ani jego twarzy, ani głosu."
	icon = 'aquila/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'aquila/icons/mob/clothing/suits/armor.dmi'
	icon_state = "lock_armor"
	worn_icon_state = "lock_armor"
	item_state = null
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/lock
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 40, "bomb" = 40, "bio" = 40, "rad" = 40, "fire" = 40, "acid" = 40, "stamina" = 40, "bleed" = 40)
	flags_inv = HIDESHOES | HIDEJUMPSUIT | HIDEBELT | HIDEMUTWINGS

/obj/item/clothing/suit/hooded/cultrobes/eldritch/lock/on_robes_gained(mob/living/user)
	user.AddElement(/datum/element/digital_camo)
	user.add_traits(list(TRAIT_SILENT_FOOTSTEPS, TRAIT_UNKNOWN_APPEARANCE, TRAIT_UNKNOWN_VOICE), REF(src))

/obj/item/clothing/suit/hooded/cultrobes/eldritch/lock/on_robes_lost(mob/user, obj/item/clothing/suit/hooded/cultrobes/eldritch/robes)
	user.RemoveElement(/datum/element/digital_camo)
	user.remove_traits(list(TRAIT_SILENT_FOOTSTEPS, TRAIT_UNKNOWN_APPEARANCE, TRAIT_UNKNOWN_VOICE), REF(src))

/obj/item/clothing/suit/hooded/cultrobes/eldritch/lock/robes_side_effect(mob/living/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/victim = user
	var/list/things = victim.get_equipped_items(TRUE) + victim.held_items
	var/turf/our_turf = get_turf(victim)
	var/list/turf/nearby_turfs = RANGE_TURFS(5, our_turf) - our_turf
	for(var/obj/item/to_throw in things)
		if(user.dropItemToGround(to_throw))
			to_throw.safe_throw_at(pick(nearby_turfs), 2, 1, spin = TRUE)

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/lock
	name = "\improper Shifting Guise"
	desc = "Kaptur bez stałego kształtu. Rysy twarzy pod nim nieustannie się przesuwają."
	icon = 'aquila/icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'aquila/icons/mob/clothing/head/helmet.dmi'
	icon_state = "lock_armor"
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 40, "bomb" = 40, "bio" = 40, "rad" = 40, "fire" = 40, "acid" = 40, "stamina" = 40, "bleed" = 40)
	flags_inv = HIDEMASK | HIDEEARS | HIDEEYES | HIDEFACE | HIDEHAIR | HIDEFACIALHAIR | HIDESNOUT | HIDEANTENNAE

// Moon
// Converts all damage into brain damage, nullifying the attack in the process
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon
	name = "\improper Resplendant Regalia"
	desc = "Zwodnicza natura tego wystawnego stroju skręca i wykrzywia spojrzenie. \
		Patrzący musi dojść do mrożącego krew w żyłach wniosku: \
		to, co widzi, jest równie prawdziwe jak każda inna twarz."
	icon = 'aquila/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'aquila/icons/mob/clothing/suits/armor.dmi'
	icon_state = "moon_armor"
	worn_icon_state = "moon_armor"
	item_state = null
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/moon
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 0)
	flags_inv = HIDESHOES | HIDEJUMPSUIT | HIDEMUTWINGS
	robe_traits = list(
		TRAIT_HERETIC_AURA_HIDDEN,
		TRAIT_BATON_RESISTANCE,
		TRAIT_STUNIMMUNE,
		TRAIT_NEVER_WOUNDED,
		TRAIT_PACIFISM,
		TRAIT_NOHUNGER
	)
	/// Boolean if you are brain dead so the sound doesn't spam during the delay
	var/braindead = FALSE
	//---- Messages that get sent when someone wearing the moon robes is attacked
	/// Visible message that nearby people see
	var/static/list/visible_message_list = list(
		"%USER zdaje się ledwie zauważać, że %ATTACKER wyrządził mu krzywdę - nawet nie drgnie.",
		"Choć ranny, %USER zdaje się nie dostrzegać %ATTACKER.",
		"Słyszysz, jak %USER się śmieje. A przecież nie wydał żadnego dźwięku, nawet gdy %ATTACKER go uderzył.",
	)
	/// Message sent to the wearer who got attacked
	var/static/list/self_message_list = list(
		"Twoje ciało faluje jak świeżo poruszona woda. To uczucie jest wyborne, a zawdzięczasz je %ATTACKER.",
		"Bije dzwon. %ATTACKER wybił godzinę, a ty tykasz w tym rytmie.",
		"%ATTACKER cię potrąca i rozlewasz herbatę. Nic nie szkodzi. Masz mnóstwo filiżanek.",
		"Słyszysz ryk fal uderzających o łódź. Morze jest ogromne i ciemne. Widzisz, jak %ATTACKER uderza w wodę, przeklinając jej pana.",
		"Wokół %ATTACKER rozsypują się cekiny. Cekiny...",
		"Zauważasz, że od kołnierza odpadł ci guzik. Jak to się stało? Może to wina %ATTACKER.",
		"%ATTACKER nie jest zbyt zabawny, a ty z trudem łapiesz puentę.",
	)
	/// Message sent to blind people nearby
	var/static/list/blind_message_list = list(
		"Słyszysz echo śmiechu.",
		"Słyszysz odległy chór.",
		"Słyszysz dzwonki i gwizdki.",
		"Słyszysz brzęk tamburynu.",
	)
	/// List of all signals registered, used for cleanup
	var/signal_registered = list()
	/// damage modifier to all incoming damage, which is also converted to brain damage
	var/damage_modifier = 1.15
	/// AQUILA - zapamiętane modyfikatory fizjologii noszącego (u nas tak zerujemy obrażenia)
	var/list/saved_physiology
	/// AQUILA - kto teraz nosi szatę (do sprzątania)
	var/mob/living/carbon/human/current_wearer
	/// AQUILA - wskaźnik zdrowia księżyca na HUD
	var/atom/movable/screen/moon_health/moon_hud

/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/equipped(mob/user, slot, initial)
	. = ..()
	if(!ishuman(user) || !(slot_flags & slot))
		return
	var/mob/living/carbon/human/human_user = user
	if(current_wearer == human_user)
		return
	current_wearer = human_user
	// Gives the hud to the wearer, if there's no hud, register the signal to be given on creation
	if(human_user.hud_used)
		on_hud_created(human_user)
	else
		RegisterSignal(human_user, COMSIG_MOB_HUD_CREATED, PROC_REF(on_hud_created))
		signal_registered += COMSIG_MOB_HUD_CREATED

	// AQUILA - tg: COMSIG_MOB_APPLY_DAMAGE_MODIFIERS (damage_mods += 0); u nas zerujemy fizjologię, a obrażenia liczymy z sygnału apply_damage
	saved_physiology = list(
		"brute" = human_user.physiology.brute_mod,
		"burn" = human_user.physiology.burn_mod,
		"tox" = human_user.physiology.tox_mod,
		"oxy" = human_user.physiology.oxy_mod,
		"clone" = human_user.physiology.clone_mod,
		"stamina" = human_user.physiology.stamina_mod,
	)
	human_user.physiology.brute_mod = 0
	human_user.physiology.burn_mod = 0
	human_user.physiology.tox_mod = 0
	human_user.physiology.oxy_mod = 0
	human_user.physiology.clone_mod = 0
	human_user.physiology.stamina_mod = 0
	RegisterSignal(human_user, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_apply_damage))
	signal_registered += COMSIG_MOB_APPLY_DAMAGE

	// adjust ignores damage modifiers so we listen to them separately
	var/list/damage_adjust_signals = list(
		COMSIG_LIVING_ADJUST_BRUTE_DAMAGE,
		COMSIG_LIVING_ADJUST_BURN_DAMAGE,
		COMSIG_LIVING_ADJUST_OXY_DAMAGE,
		COMSIG_LIVING_ADJUST_TOX_DAMAGE,
		COMSIG_LIVING_ADJUST_STAMINA_DAMAGE
	)

	RegisterSignals(human_user, damage_adjust_signals, PROC_REF(adjust_damage))
	signal_registered += damage_adjust_signals

	RegisterSignal(human_user, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	signal_registered += COMSIG_LIVING_DEATH

	RegisterSignal(human_user, COMSIG_SEND_ITEM_ATTACK_MESSAGE_CARBON, PROC_REF(item_attack_response))
	signal_registered += COMSIG_SEND_ITEM_ATTACK_MESSAGE_CARBON

	START_PROCESSING(SSobj, src)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/dropped(mob/living/user)
	. = ..()
	if(!ishuman(user) || current_wearer != user)
		return
	var/mob/living/carbon/human/wearer = user
	current_wearer = null
	UnregisterSignal(wearer, signal_registered)
	signal_registered = list()
	if(saved_physiology)
		wearer.physiology.brute_mod = saved_physiology["brute"]
		wearer.physiology.burn_mod = saved_physiology["burn"]
		wearer.physiology.tox_mod = saved_physiology["tox"]
		wearer.physiology.oxy_mod = saved_physiology["oxy"]
		wearer.physiology.clone_mod = saved_physiology["clone"]
		wearer.physiology.stamina_mod = saved_physiology["stamina"]
		saved_physiology = null
	REMOVE_TRAIT(src, TRAIT_NODROP, REF(src))
	braindead = FALSE
	STOP_PROCESSING(SSobj, src)
	on_hud_remove(wearer)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(moon_hud)
	current_wearer = null
	return ..()

/// AQUILA - tg: COMSIG_MOB_APPLY_DAMAGE_MODIFIERS; sygnał z apply_damage: (damage, damagetype, def_zone)
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/on_apply_damage(mob/living/user, damage, damagetype, def_zone)
	SIGNAL_HANDLER
	if(braindead || damagetype == BRAIN)
		return
	handle_damage(user, damage)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/adjust_damage(mob/living/user, type, amount, forced)
	SIGNAL_HANDLER
	handle_damage(user, amount)
	return COMPONENT_IGNORE_CHANGE

/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/handle_damage(mob/living/user, damage)
	if(damage <= 0 || braindead)
		return
	add_brain_damage(user, damage * damage_modifier)

/// AQUILA - u nas mózg przy maksymalnych obrażeniach zabija od razu, więc zatrzymujemy się tuż przed progiem i odpalamy efekt z tg
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/add_brain_damage(mob/living/user, amount)
	var/obj/item/organ/brain/our_brain = user.getorganslot(ORGAN_SLOT_BRAIN)
	if(!our_brain || braindead)
		return
	if(our_brain.damage + amount >= our_brain.maxHealth - 1)
		user.setOrganLoss(ORGAN_SLOT_BRAIN, our_brain.maxHealth - 1)
	else
		user.adjustOrganLoss(ORGAN_SLOT_BRAIN, amount)
	moon_hud?.update_health(our_brain)
	check_braindeath(user)

/// Gives the health HUD to the wearer
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/on_hud_created(mob/living/carbon/human/wearer)
	SIGNAL_HANDLER
	var/datum/hud/original_hud = wearer.hud_used
	if(!original_hud)
		return
	original_hud.healths?.invisibility = INVISIBILITY_ABSTRACT
	original_hud.healthdoll?.invisibility = INVISIBILITY_ABSTRACT

	// Add the moon health hud element
	QDEL_NULL(moon_hud)
	moon_hud = new /atom/movable/screen/moon_health(null, original_hud)
	if(!QDELETED(moon_hud))
		original_hud.infodisplay += moon_hud
		wearer.client?.screen += moon_hud
	UnregisterSignal(wearer, COMSIG_MOB_HUD_CREATED)
	signal_registered -= COMSIG_MOB_HUD_CREATED

/// Removes the HUD element from the wearer
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/on_hud_remove(mob/living/carbon/human/wearer)
	var/datum/hud/original_hud = wearer.hud_used
	if(moon_hud)
		original_hud?.infodisplay -= moon_hud
		wearer.client?.screen -= moon_hud
		QDEL_NULL(moon_hud)
	if(!original_hud)
		return
	// Restore the old health elements
	original_hud.healths?.invisibility = initial(original_hud.healths.invisibility)
	original_hud.healthdoll?.invisibility = initial(original_hud.healthdoll.invisibility)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/item_attack_response(mob/living/victim, obj/item/weapon, mob/living/attacker)
	SIGNAL_HANDLER
	if(!attacker)
		return
	var/visible_message = pick(visible_message_list)
	visible_message = replacetext(visible_message, "%USER", victim.get_visible_name())
	visible_message = replacetext(visible_message, "%ATTACKER", attacker.get_visible_name())

	var/self_message = pick(self_message_list)
	self_message = replacetext(self_message, "%ATTACKER", attacker.get_visible_name())

	var/blind_message = pick(blind_message_list)
	victim.visible_message(span_danger(visible_message), span_userdanger(self_message), span_danger(blind_message))
	return SIGNAL_MESSAGE_MODIFIED

/// Once you reach this point you're completely brain dead, so lets play our effects before you eat shit
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/kill_wearer(mob/living/carbon/human/wearer)
	if(QDELETED(wearer) || wearer.stat == DEAD)
		return
	if(IS_HERETIC(wearer))
		var/datum/action/cooldown/spell/aoe/moon_ringleader/temp_spell = new(wearer)
		temp_spell.cast(wearer)
		qdel(temp_spell)
	wearer.setOrganLoss(ORGAN_SLOT_BRAIN, INFINITY)
	wearer.death()

/// Blows up your head when you die
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/on_death(mob/wearer)
	SIGNAL_HANDLER
	if(!ishuman(wearer))
		return
	var/mob/living/carbon/human/human_wearer = wearer
	var/obj/item/bodypart/head/to_explode = human_wearer.get_bodypart(BODY_ZONE_HEAD)
	if(!to_explode)
		return
	human_wearer.visible_message(span_warning("Głowa [human_wearer] rozpryskuje się z obrzydliwym chrupnięciem!"))
	new /obj/effect/gibspawner/generic(get_turf(human_wearer), human_wearer)
	INVOKE_ASYNC(src, PROC_REF(explode_head), to_explode)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/explode_head(obj/item/bodypart/head/to_explode)
	if(QDELETED(to_explode))
		return
	to_explode.dismember(BRUTE)
	to_explode.drop_organs()
	qdel(to_explode)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/process(seconds_per_tick)
	var/mob/living/carbon/human/wearer = loc
	if(!istype(wearer) || wearer.wear_suit != src || wearer.stat == DEAD)
		return
	if(!IS_HERETIC_OR_MONSTER(wearer))
		add_brain_damage(wearer, 20)
	var/brain_damage = wearer.getOrganLoss(ORGAN_SLOT_BRAIN)
	// AQUILA - tg: can_mob_unequip() - nie da się zdjąć szaty z uszkodzonym mózgiem
	if(brain_damage > 0)
		ADD_TRAIT(src, TRAIT_NODROP, REF(src))
	else
		REMOVE_TRAIT(src, TRAIT_NODROP, REF(src))
	var/obj/item/organ/brain/our_brain = wearer.getorganslot(ORGAN_SLOT_BRAIN)
	if(our_brain)
		moon_hud?.update_health(our_brain)
	var/emote_rng = 0
	var/list/emote_list = list()
	switch(brain_damage)
		if(0)
			emote_rng = 0
			emote_list = list()
		if(1 to 30)
			emote_rng = 20
			emote_list = list("laugh")
		if(31 to 60)
			emote_rng = 40
			emote_list = list("laugh", "smile")
		if(61 to 100)
			emote_rng = 60
			emote_list = list("laugh", "smile", "cough")
		if(101 to 150)
			emote_rng = 80
			emote_list = list("laugh", "smile", "cough", "gasp")
		if(151 to 200)
			emote_rng = 100
			emote_list = list("laugh", "smile", "cough", "gasp", "scream")
	if(!prob(emote_rng))
		return
	for(var/perform in emote_list)
		wearer.emote("[perform]")
	check_braindeath(wearer)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/examine(mob/user)
	. = ..()
	if(HAS_TRAIT_FROM(src, TRAIT_NODROP, REF(src)))
		. += span_warning("Nie da się jej zdjąć, póki mózg noszącego jest uszkodzony!")

/// Checks if you are brain dead, starts the dying process once you've reached it
/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/proc/check_braindeath(mob/living/carbon/human/wearer)
	var/obj/item/organ/brain/our_brain = wearer.getorganslot(ORGAN_SLOT_BRAIN)
	if(braindead || !our_brain || our_brain.damage < our_brain.maxHealth - 1)
		return

	braindead = TRUE
	moon_hud?.update_health(our_brain)
	playsound(wearer, 'sound/effects/pope_entry.ogg', 50)
	to_chat(wearer, span_bold(span_hypnophrase("Spotkał cię straszny los.")))
	addtimer(CALLBACK(src, PROC_REF(kill_wearer), wearer), 5 SECONDS)

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/moon
	name = "\improper Resplendant Hood"
	desc = "Kaptur, który skręca i wykrzywia spojrzenie patrzącego."
	icon = 'aquila/icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'aquila/icons/mob/clothing/head/helmet.dmi'
	icon_state = "moon_armor"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 0)

/atom/movable/screen/moon_health
	name = "Health Level"
	icon = 'aquila/icons/hud/moon_health_64x64.dmi'
	icon_state = "moon_hud_1"
	base_icon_state = "moon_hud"
	screen_loc = "EAST-2:28,CENTER-2:13"

/atom/movable/screen/moon_health/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	if(isnull(hud_owner) || !ishuman(hud_owner.mymob))
		return INITIALIZE_HINT_QDEL
	hud = hud_owner
	var/mob/living/carbon/human/wearer = hud_owner.mymob
	var/obj/item/organ/brain/our_brain = wearer.getorganslot(ORGAN_SLOT_BRAIN)
	if(!our_brain)
		return INITIALIZE_HINT_QDEL
	update_health(our_brain)

/// Changes the icon based on the brain health of the wearer
/atom/movable/screen/moon_health/proc/update_health(obj/item/organ/brain)
	if(!brain?.owner || !ishuman(brain.owner))
		return
	var/mob/living/carbon/human/wearer = brain.owner
	if(istype(wearer.wear_suit, /obj/item/clothing/suit/hooded/cultrobes/eldritch/moon))
		var/obj/item/clothing/suit/hooded/cultrobes/eldritch/moon/robes = wearer.wear_suit
		if(robes.braindead)
			icon_state = base_icon_state + "_6"
			return // Don't update the icon once our "dying" process has begun
	switch(brain.damage)
		if(0 to 20)
			icon_state = base_icon_state + "_1"
		if(21 to 50)
			icon_state = base_icon_state + "_2"
		if(51 to 100)
			icon_state = base_icon_state + "_3"
		if(101 to 150)
			icon_state = base_icon_state + "_4"
		if(151 to 189)
			icon_state = base_icon_state + "_5"
		if(190 to INFINITY)
			icon_state = base_icon_state + "_6"

// Rust
// Gains more armor while standing on top of rust. Has an animated overlay
/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust
	name = "\improper Salvaged Remains"
	desc = "Dotknięcie fałd tej prostej szaty napełnia niepokojem. \
		Nawet samo patrzenie przyprawia o zawrót głowy. \
		Jakiś puls grozi, że wciągnie cię do środka."
	icon = 'aquila/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'aquila/icons/mob/clothing/suits/armor.dmi'
	icon_state = "rust_armor"
	worn_icon_state = "rust_armor"
	item_state = null
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 50, "bio" = 30, "rad" = 30, "fire" = 30, "acid" = 30, "stamina" = 30, "bleed" = 30)
	/// Grace period timer before the
	COOLDOWN_DECLARE(rust_grace_period)
	/// If our armor is rusted, used to update the sprite
	var/rusted = FALSE
	/// Overlay for the armor object
	var/image/object_overlay
	/// Overlay for the hood object
	var/image/hood_object_overlay
	/// Turf we're currently listening to for rust trait gains
	var/turf/listening_turf
	/// AQUILA - pancerz bez rdzy i na rdzy (tg: /datum/armor/eldritch_armor/rust i /on_rust)
	var/static/list/base_armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 50, "bio" = 30, "rad" = 30, "fire" = 30, "acid" = 30, "stamina" = 30, "bleed" = 30)
	var/static/list/rust_armor = list("melee" = 60, "bullet" = 60, "laser" = 60, "energy" = 60, "bomb" = 100, "bio" = 60, "rad" = 60, "fire" = 60, "acid" = 60, "stamina" = 60, "bleed" = 60)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/Initialize(mapload)
	. = ..()
	if(!object_overlay)
		object_overlay = image(icon, icon_state = "rust_armor_overlay")
	if(!hood_object_overlay)
		hood_object_overlay = image('aquila/icons/obj/clothing/head/helmet.dmi', icon_state = "rust_armor_overlay")

/// AQUILA - tg: set_armor(/datum/armor/...)
/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/proc/set_rust_armor(on_rust)
	armor = getArmor(arglist(on_rust ? rust_armor : base_armor))
	hood?.armor = getArmor(arglist(on_rust ? rust_armor : base_armor))

/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/on_robes_gained(mob/living/user)
	. = ..()
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	register_turf_listener(user)
	update_rust_state(user)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/on_robes_lost(mob/user, obj/item/clothing/suit/hooded/cultrobes/eldritch/robes)
	. = ..()
	if(.)
		return
	UnregisterSignal(user, list(COMSIG_MOVABLE_MOVED))
	if(listening_turf)
		UnregisterSignal(listening_turf, SIGNAL_ADDTRAIT(TRAIT_RUSTY))
		listening_turf = null
	rusted = FALSE
	set_rust_armor(FALSE)

	REMOVE_TRAIT(user, TRAIT_PIERCEIMMUNE, REF(src))
	cut_overlay(object_overlay)
	hood?.cut_overlay(hood_object_overlay)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/robes_side_effect(mob/living/user)
	. = ..()
	if(!iscarbon(user))
		return
	var/mob/living/carbon/victim = user
	var/list/organ_list = victim.internal_organs
	if(!length(organ_list))
		return

	var/iteration = 0
	var/organs_to_puke = rand(1, 3)
	for(var/obj/item/organ/to_puke as anything in organ_list)
		if(iteration > organs_to_puke)
			break
		iteration++
		addtimer(CALLBACK(src, PROC_REF(vomit_your_guts_out), victim), 1 SECONDS * iteration)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/proc/vomit_your_guts_out(mob/living/carbon/victim)
	if(QDELETED(victim) || !is_equipped(victim))
		return
	victim.vomit(20, TRUE, TRUE, 1, TRUE)
	victim.spew_organ(rand(4, 6))

/// Keeps our turf rust listener aligned with where the wearer currently stands.
/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/proc/register_turf_listener(mob/source)
	var/turf/new_turf = get_turf(source)
	if(listening_turf == new_turf)
		return
	if(listening_turf)
		UnregisterSignal(listening_turf, SIGNAL_ADDTRAIT(TRAIT_RUSTY))
	listening_turf = new_turf
	if(listening_turf)
		RegisterSignal(listening_turf, SIGNAL_ADDTRAIT(TRAIT_RUSTY), PROC_REF(on_turf_became_rusty))

/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/proc/on_turf_became_rusty(turf/source, rust_trait)
	SIGNAL_HANDLER
	var/mob/living/wearer = loc
	if(!isliving(wearer) || !is_equipped(wearer))
		return
	update_rust_state(wearer)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/proc/update_rust_state(mob/source)
	if(source.is_touching_rust())
		set_rust_armor(TRUE)

		ADD_TRAIT(source, TRAIT_PIERCEIMMUNE, REF(src))
		COOLDOWN_RESET(src, rust_grace_period)
		if(rusted) // Already rusted, don't update overlay
			return
		rusted = TRUE
		update_rust()
	else
		if(!rusted) // Already unrusted, don't update overlay
			return
		// Start the timer for the first time we step off rust
		if(!COOLDOWN_STARTED(src, rust_grace_period))
			COOLDOWN_START(src, rust_grace_period, 1 SECONDS)
			return
		if(!COOLDOWN_FINISHED(src, rust_grace_period))
			return

		// *Actually* remove the effects after our grace period expires.
		// Keep in mind since we call updates `on_move` this means you can technically stand still to keep the benefits.
		COOLDOWN_RESET(src, rust_grace_period)
		set_rust_armor(FALSE)
		REMOVE_TRAIT(source, TRAIT_PIERCEIMMUNE, REF(src))
		rusted = FALSE
		update_rust()

/*
 * Signal proc for [COMSIG_MOVABLE_MOVED].
 *
 * Checks if our armor values should be increased on the new turf
 */
/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/proc/on_move(mob/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	register_turf_listener(source)
	update_rust_state(source)

/// Updates the icon of our overlay
/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/proc/update_rust()
	// AQUILA - tg animuje nakładkę przez render_target i flick(); u nas nakładka w worn_overlays i odświeżenie stroju
	if(!rusted)
		cut_overlay(object_overlay)
		hood?.cut_overlay(hood_object_overlay)
	else
		add_overlay(object_overlay)
		hood?.add_overlay(hood_object_overlay)
	var/mob/living/carbon/human/wearer = loc
	if(istype(wearer))
		wearer.update_inv_wear_suit()

/obj/item/clothing/suit/hooded/cultrobes/eldritch/rust/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file)
	. = ..()
	if(isinhands || !rusted)
		return
	. += mutable_appearance('aquila/icons/mob/clothing/suits/armor.dmi', "rust_armor_overlay")

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/rust
	name = "\improper Salvaged Remains"
	desc = "Dotknięcie fałd tego prostego kaptura napełnia niepokojem. \
		Nawet samo patrzenie przyprawia o zawrót głowy. \
		Jakiś puls grozi, że wciągnie cię do środka."
	icon = 'aquila/icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'aquila/icons/mob/clothing/head/helmet.dmi'
	icon_state = "rust_armor"
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 50, "bio" = 30, "rad" = 30, "fire" = 30, "acid" = 30, "stamina" = 30, "bleed" = 30)

// Void
// Gives you a short stealth when you are hit
/obj/item/clothing/suit/hooded/cultrobes/eldritch/void
	name = "\improper Hollow Weave"
	desc = "Z początku puste płótno tej szaty zdaje się migotać słabym, zimnym światłem. \
		Lecz gdy uważniej prześledzić kształt fałd, lepiej opisać je jako brak czegokolwiek."
	icon = 'aquila/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'aquila/icons/mob/clothing/suits/armor.dmi'
	icon_state = "void_armor"
	worn_icon_state = "void_armor"
	item_state = null
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch/void
	armor = list("melee" = 40, "bullet" = 40, "laser" = 50, "energy" = 50, "bomb" = 40, "bio" = 40, "rad" = 40, "fire" = 40, "acid" = 40, "stamina" = 40, "bleed" = 40)
	/// Cooldown before we can go back into stealth
	COOLDOWN_DECLARE(stealth_cooldown)
	/// Timer before our stealth runs out
	var/stealth_timer

/obj/item/clothing/suit/hooded/cultrobes/eldritch/void/on_robes_lost(mob/user, obj/item/clothing/suit/hooded/cultrobes/eldritch/robes)
	. = ..()
	if(. || !stealth_timer || !timeleft(stealth_timer))
		return
	// Remove from stealth when you lose the robes
	deltimer(stealth_timer)
	stealth_timer = null
	end_stealth(user)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/void/robes_side_effect(mob/living/user)
	. = ..()
	user.adjust_bodytemperature(-INFINITY)
	ADD_TRAIT(user, TRAIT_HYPOTHERMIC, REF(src))
	// AQUILA - tg: /frozenstasis/irresistable; nasz frozenstasis nie ma wariantu bez możliwości wyrwania się
	user.apply_status_effect(/datum/status_effect/frozenstasis)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/void/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	. = ..()
	if(!robes_active || !COOLDOWN_FINISHED(src, stealth_cooldown))
		return
	COOLDOWN_START(src, stealth_cooldown, 20 SECONDS)
	stealth_timer = addtimer(CALLBACK(src, PROC_REF(end_stealth), owner), 5 SECONDS, TIMER_STOPPABLE)
	owner.alpha = 0
	return TRUE

/obj/item/clothing/suit/hooded/cultrobes/eldritch/void/proc/end_stealth(mob/living/carbon/human/owner)
	stealth_timer = null
	animate(owner, time = 1 SECONDS, alpha = initial(owner.alpha))

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/void
	name = "\improper Hollow Weave"
	desc = "Z początku puste płótno tego kaptura zdaje się migotać słabym, zimnym światłem. \
		Lecz gdy uważniej prześledzić kształt fałd, lepiej opisać je jako brak czegokolwiek."
	icon = 'aquila/icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'aquila/icons/mob/clothing/head/helmet.dmi'
	icon_state = "void_armor"
	armor = list("melee" = 40, "bullet" = 40, "laser" = 50, "energy" = 50, "bomb" = 40, "bio" = 40, "rad" = 40, "fire" = 40, "acid" = 40, "stamina" = 40, "bleed" = 40)

// Void cloak. Turns invisible with the hood up, lets you hide stuff.
/obj/item/clothing/head/hooded/cult_hoodie/void
	name = "void hood"
	desc = "Czarny jak smoła, nie odbija żadnego światła. Na zewnątrz biegną runiczne symbole. \
		Z każdym błyskiem coraz mniej rozumiesz, na co patrzysz."
	icon = 'aquila/icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'aquila/icons/mob/clothing/head/helmet.dmi'
	icon_state = "void_cloak"
	flags_inv = NONE
	flags_cover = NONE
	item_flags = EXAMINE_SKIP
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 15, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 30, "bleed" = 10)

/obj/item/clothing/head/hooded/cult_hoodie/void/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_NO_STRIP, TRAIT_EXAMINE_SKIP), INNATE_TRAIT)

/obj/item/clothing/suit/hooded/cultrobes/void
	name = "void cloak"
	desc = "Czarny jak smoła, nie odbija żadnego światła. Na zewnątrz biegną runiczne symbole. \
		Z każdym błyskiem coraz mniej rozumiesz, na co patrzysz."
	icon = 'aquila/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'aquila/icons/mob/clothing/suits/armor.dmi'
	icon_state = "void_cloak"
	worn_icon_state = "void_cloak"
	item_state = null
	allowed = list(/obj/item/melee/sickly_blade)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/void
	flags_inv = NONE
	body_parts_covered = CHEST|GROIN|ARMS
	// slightly worse than normal cult robes
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 15, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 30, "bleed" = 10)
	// AQUILA - tg: alternative_mode + create_storage(/datum/storage/pockets/void_cloak)
	qdel_hood = TRUE
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/void_cloak
	// hood_up dziedziczone z /obj/item/clothing/suit/hooded/cultrobes (kult krwi „Cult 4”)

/obj/item/clothing/suit/hooded/cultrobes/void/Initialize(mapload)
	. = ..()
	make_visible()
	ADD_TRAIT(src, TRAIT_CONTRABAND_BLOCKER, INNATE_TRAIT)

/obj/item/clothing/suit/hooded/cultrobes/void/ToggleHood()
	if(!suittoggled && !can_create_hood())
		return
	var/was_up = suittoggled
	. = ..()
	if(!was_up && suittoggled)
		on_hood_up(hood)

/obj/item/clothing/suit/hooded/cultrobes/void/RemoveHood()
	var/was_up = suittoggled
	. = ..()
	if(was_up)
		on_hood_down(hood)

/obj/item/clothing/suit/hooded/cultrobes/void/proc/on_hood_up(obj/item/clothing/head/hooded/hood)
	hood_up = TRUE
	make_invisible()

/obj/item/clothing/suit/hooded/cultrobes/void/proc/on_hood_down(obj/item/clothing/head/hooded/hood)
	hood_up = FALSE
	make_visible()

/obj/item/clothing/suit/hooded/cultrobes/void/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_OCLOTHING)
		RegisterSignal(user, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(hide_item), override = TRUE)
		RegisterSignal(user, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(show_item), override = TRUE)
		if(!hood_up)
			user.add_traits(list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTCOLD), REF(src))
		if(ishuman(user))
			var/mob/living/carbon/human/human_user = user
			if(human_user.s_store)
				hide_item(user, human_user.s_store, ITEM_SLOT_SUITSTORE)

/obj/item/clothing/suit/hooded/cultrobes/void/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, list(COMSIG_MOB_UNEQUIPPED_ITEM, COMSIG_MOB_EQUIPPED_ITEM))
	user.remove_traits(list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTCOLD), REF(src))
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(human_user.s_store)
			show_item(user, human_user.s_store)

/obj/item/clothing/suit/hooded/cultrobes/void/proc/hide_item(datum/source, obj/item/item, slot)
	SIGNAL_HANDLER
	if(!(slot & ITEM_SLOT_SUITSTORE))
		return
	item.add_traits(list(TRAIT_NO_STRIP, TRAIT_NO_WORN_ICON, TRAIT_EXAMINE_SKIP), REF(src))
	item.item_flags |= EXAMINE_SKIP
	var/mob/living/carbon/human/wearer = source
	if(istype(wearer))
		wearer.update_inv_s_store()

/obj/item/clothing/suit/hooded/cultrobes/void/proc/show_item(datum/source, obj/item/item, slot)
	SIGNAL_HANDLER
	if(!HAS_TRAIT_FROM(item, TRAIT_EXAMINE_SKIP, REF(src)))
		return
	item.remove_traits(list(TRAIT_NO_STRIP, TRAIT_NO_WORN_ICON, TRAIT_EXAMINE_SKIP), REF(src))
	item.item_flags &= ~EXAMINE_SKIP
	var/mob/living/carbon/human/wearer = source
	if(istype(wearer))
		wearer.update_inv_s_store()

/obj/item/clothing/suit/hooded/cultrobes/void/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user) || !hood_up)
		return

	// Let examiners know this works as a focus only if the hood is down
	. += span_notice("Z opuszczonym kapturem możesz rzucać zaklęcia heretyka.")
	. += span_notice("Z opuszczonym kapturem chroni w próżni.")

/obj/item/clothing/suit/hooded/cultrobes/void/proc/can_create_hood()
	if(!isliving(loc))
		CRASH("[src] attempted to make a hood on a non-living thing: [loc]")
	var/mob/living/wearer = loc
	if(IS_HERETIC_OR_MONSTER(wearer))
		return TRUE

	loc.balloon_alert(loc, "nie możesz założyć kaptura!")
	return FALSE

/// Makes our cloak "invisible". Not the wearer, the cloak itself.
/obj/item/clothing/suit/hooded/cultrobes/void/proc/make_invisible()
	add_traits(list(TRAIT_NO_STRIP, TRAIT_EXAMINE_SKIP), REF(src))
	item_flags |= EXAMINE_SKIP

	if(isliving(loc))
		loc.remove_traits(list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTCOLD), REF(src))
		loc.balloon_alert(loc, "płaszcz ukryty")
		loc.visible_message(span_notice("Światło wokół [loc] się zakrzywia i płaszcz staje się niewidzialny!"))

/// Makes our cloak "visible" again.
/obj/item/clothing/suit/hooded/cultrobes/void/proc/make_visible()
	remove_traits(list(TRAIT_NO_STRIP, TRAIT_EXAMINE_SKIP), REF(src))
	item_flags &= ~EXAMINE_SKIP

	if(isliving(loc))
		var/mob/living/carbon/human/wearer = loc
		if(istype(wearer) && wearer.wear_suit == src)
			wearer.add_traits(list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTCOLD), REF(src))
		loc.balloon_alert(loc, "płaszcz odsłonięty")
		loc.visible_message(span_notice("Wokół [loc] zapada się kalejdoskop barw i nagle pojawia się płaszcz!"))
