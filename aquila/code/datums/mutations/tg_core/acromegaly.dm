// AQUILA - port z tgstation (code/datums/mutations/body.dm, /datum/mutation/acromegaly)
// Wzrost tg (HUMAN_HEIGHT_TALLEST) uproszczony do filtrów displacement na całym mobie:
// człowiek ma KEEP_TOGETHER, więc filtr obejmuje ciało, ubranie i trzymane przedmioty, a przy leżeniu obraca się razem z ciałem.

/// Klucze filtrów (jak nazwy filtrów wzrostu w tg)
#define ACROMEGALY_FILTER_TORSO "Lenghten_Torso"
#define ACROMEGALY_FILTER_ARMS "Lenghten_Arms"
#define ACROMEGALY_FILTER_LEGS "Lenghten_Legs"
/// Ile trwa zachwianie po uderzeniu głową (tg STAGGERED_SLOWDOWN_LENGTH) i maksimum łącznie
#define ACROMEGALY_STAGGER_LENGTH (3 SECONDS)
#define ACROMEGALY_STAGGER_MAX (10 SECONDS)

/datum/mutation/acromegaly
	name = "Akromegalia"
	desc = "Komórki pacjenta piętrzą się jedna na drugiej, przez co wydaje się on niezwykle wysoki."
	quality = MINOR_NEGATIVE
	difficulty = 16
	synchronizer_coeff = 1
	conflicts = list(/datum/mutation/dwarfism)
	/// Do kiedy trwa zachwianie po uderzeniu głową
	var/stagger_end = 0

/datum/mutation/acromegaly/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	ADD_TRAIT(owner, TRAIT_TOO_TALL, GENETIC_MUTATION)
	owner.visible_message("<span class='danger'>[owner] nagle wyrasta w górę!</span>", "<span class='notice'>Czujesz dziwną chęć, by walczyć z małymi ludźmi uzbrojonymi w procę. Albo pograć w koszykówkę.</span>")
	apply_height_filters(owner)

/datum/mutation/acromegaly/on_losing(mob/living/carbon/owner)
	if(..())
		return TRUE
	REMOVE_TRAIT(owner, TRAIT_TOO_TALL, GENETIC_MUTATION)
	owner.visible_message("<span class='danger'>[owner] nagle się kurczy!</span>", "<span class='notice'>Wracasz do swojego zwykłego wzrostu.</span>")
	owner.remove_filter(list(ACROMEGALY_FILTER_TORSO, ACROMEGALY_FILTER_ARMS, ACROMEGALY_FILTER_LEGS))
	owner.remove_movespeed_modifier("acromegaly_stagger")

/// tg apply_height_filter dla HUMAN_HEIGHT_TALLEST: wydłużony tułów, ręce i nogi
/datum/mutation/acromegaly/proc/apply_height_filters(mob/living/carbon/target)
	var/static/icon/lenghten_torso_mask = icon('aquila/icons/mutations/tg_core/cut.dmi', "Cut3")
	var/static/icon/lenghten_legs_mask = icon('aquila/icons/mutations/tg_core/cut.dmi', "Cut4")
	var/static/icon/lenghten_arms_mask = icon('aquila/icons/mutations/tg_core/cut.dmi', "Cut5")
	target.add_filter(ACROMEGALY_FILTER_TORSO, 1, displacement_map_filter(lenghten_torso_mask, x = 0, y = 0, size = 1))
	target.add_filter(ACROMEGALY_FILTER_ARMS, 1, displacement_map_filter(lenghten_arms_mask, x = 0, y = 0, size = 1))
	target.add_filter(ACROMEGALY_FILTER_LEGS, 1, displacement_map_filter(lenghten_legs_mask, x = 0, y = 0, size = 1))

// This is specifically happening because they're not used to their new height and are stumbling around into machinery made for normal humans
/datum/mutation/acromegaly/on_move(new_loc)
	if(!owner)
		return
	var/atom/movable/whacked_by = (locate(/obj/machinery/door/airlock) in owner.loc) || (locate(/obj/machinery/door/firedoor) in owner.loc) || (locate(/obj/structure/mineral_door) in owner.loc)
	if(!whacked_by || prob(100 - (8 * GET_MUTATION_SYNCHRONIZER(src))))
		return
	to_chat(owner, "<span class='danger'>Uderzasz głową w nadproże [whacked_by]!</span>")
	// tg TRAIT_HEAD_INJURY_BLOCKED u nas nie istnieje - chroni hełm na głowie
	var/obj/item/head_item = owner.head
	var/dmg = istype(head_item, /obj/item/clothing/head/helmet) ? rand(1,4) : rand(2,9)
	owner.apply_damage(dmg, BRUTE, BODY_ZONE_HEAD)
	owner.do_attack_animation(whacked_by, ATTACK_EFFECT_PUNCH)
	playsound(whacked_by, 'sound/effects/bang.ogg', 10, TRUE)
	stagger()

/// tg adjust_staggered_up_to: chwilowe spowolnienie, kolejne uderzenia przedłużają je do limitu
/datum/mutation/acromegaly/proc/stagger()
	stagger_end = min(max(stagger_end, world.time) + ACROMEGALY_STAGGER_LENGTH, world.time + ACROMEGALY_STAGGER_MAX)
	owner.add_movespeed_modifier("acromegaly_stagger", multiplicative_slowdown = 0.85)
	addtimer(CALLBACK(src, PROC_REF(end_stagger)), stagger_end - world.time, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/mutation/acromegaly/proc/end_stagger()
	owner?.remove_movespeed_modifier("acromegaly_stagger")

#undef ACROMEGALY_FILTER_TORSO
#undef ACROMEGALY_FILTER_ARMS
#undef ACROMEGALY_FILTER_LEGS
#undef ACROMEGALY_STAGGER_LENGTH
#undef ACROMEGALY_STAGGER_MAX
