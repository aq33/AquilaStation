// AQUILA - port z tgstation (code/game/machinery/dna_infuser/organ_sets/roach_organs.dm)

/// serce karalucha: przewrócenia trwają 3x dłużej (tylko Knockdown, jak w tg)
#define TRAIT_INFUSER_ROACH_KNOCKDOWN "infuser_roach_knockdown"

/mob/living/carbon/human/Knockdown(amount, updating = TRUE, ignore_canstun = FALSE)
	if(amount > 0 && HAS_TRAIT(src, TRAIT_INFUSER_ROACH_KNOCKDOWN))
		amount *= 3
	return ..()

/// bonus karalucha: odporność na eksplozje, promieniowanie i wirusy
/datum/status_effect/organ_set_bonus/roach
	id = "organ_set_bonus_roach"
	organs_needed = 4
	bonus_activate_text = "<span class='notice'>DNA karalucha przeniknęło cię do głębi! \
		Czujesz się coraz bardziej odporny na materiały wybuchowe, promieniowanie i wirusy.</span>"
	bonus_deactivate_text = "<span class='notice'>Nie jesteś już w większości karaluchem \
		i czujesz się dużo bardziej bezbronny wobec nuklearnej apokalipsy.</span>"
	bonus_traits = list(TRAIT_NUKEIMMUNE, TRAIT_RADIMMUNE, TRAIT_VIRUS_RESISTANCE)
	bonus_biotype = MOB_BUG
	/// pancerz wewnętrzny dodawany do fizjologii
	var/bomb_armor = 100
	var/bio_armor = 90

/datum/status_effect/organ_set_bonus/roach/enable_bonus(obj/item/organ/inserted_organ)
	. = ..()
	if(!. || !ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.armor = human_owner.physiology.armor.modifyRating(bomb = bomb_armor, bio = bio_armor)

/datum/status_effect/organ_set_bonus/roach/disable_bonus(obj/item/organ/removed_organ)
	. = ..()
	if(QDELETED(owner) || !ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.armor = human_owner.physiology.armor.modifyRating(bomb = -bomb_armor, bio = -bio_armor)

/// Serce karalucha: mniej obrażeń od ciosów w plecy, ale dłuższe przewrócenia
/obj/item/organ/heart/roach
	name = "zmutowane karalusze serce"
	desc = "DNA karalucha wszczepione w coś, co kiedyś było zwykłym sercem."
	icon = 'aquila/icons/dna_infuser/organs.dmi'
	icon_state = "roach_heart"
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	organ_traits = list(TRAIT_INFUSER_ROACH_KNOCKDOWN)
	/// czy obrażenia z tego ciosu są właśnie zmniejszone
	var/blocking = FALSE
	COOLDOWN_DECLARE(harden_effect_cd)

/obj/item/organ/heart/roach/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "Ma stwardniałą, nieco przezroczystą skórę.")
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/roach)

/obj/item/organ/heart/roach/update_icon()
	icon_state = "roach_heart"

/obj/item/organ/heart/roach/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(owner != M || !ishuman(M))
		return
	var/mob/living/carbon/human/human_owner = M
	RegisterSignal(human_owner, COMSIG_HUMAN_ATTACKED, PROC_REF(on_attacked))

/obj/item/organ/heart/roach/Remove(mob/living/carbon/M, special = 0)
	if(ishuman(M) && owner == M)
		var/mob/living/carbon/human/human_owner = M
		UnregisterSignal(human_owner, COMSIG_HUMAN_ATTACKED)
		if(blocking)
			stop_blocking(human_owner)
	return ..()

/// COMSIG_HUMAN_ATTACKED leci z check_shields() tuż przed zadaniem obrażeń - jeśli cios idzie w plecy, zmniejszamy obrażenia fizyczne o połowę do końca tego ticka
/obj/item/organ/heart/roach/proc/on_attacked(mob/living/carbon/human/source, atom/movable/attacker, attack_text, damage, attack_type, armour_penetration)
	SIGNAL_HANDLER
	if(blocking || damage < 5 || !is_blocking(source, attacker))
		return
	blocking = TRUE
	source.physiology.brute_mod *= 0.5
	addtimer(CALLBACK(src, PROC_REF(stop_blocking), source), 1)
	if(COOLDOWN_FINISHED(src, harden_effect_cd))
		source.visible_message("<span class='warning'>Plecy [source] twardnieją pod ciosem!</span>")
		playsound(source, 'sound/effects/clang.ogg', 25, TRUE, -1)
	COOLDOWN_START(src, harden_effect_cd, 5 SECONDS) // reset przy KAŻDYM ciosie

/obj/item/organ/heart/roach/proc/stop_blocking(mob/living/carbon/human/source)
	if(!blocking)
		return
	blocking = FALSE
	if(!QDELETED(source))
		source.physiology.brute_mod /= 0.5

/// czy karaluch przyjmuje cios na pancerz pleców
/obj/item/organ/heart/roach/proc/is_blocking(mob/living/carbon/human/blocker, atom/movable/attacker)
	if(!attacker || blocker.stat != CONSCIOUS)
		return FALSE
	var/turf/attacker_turf = get_turf(attacker)
	var/turf/blocker_turf = get_turf(blocker)
	if(!attacker_turf || !blocker_turf || attacker_turf == blocker_turf)
		return FALSE
	if(!(blocker.mobility_flags & MOBILITY_STAND))
		return TRUE
	// kierunek lotu ciosu pokrywa się z kierunkiem, w który patrzy karaluch = cios od tyłu
	var/attack_direction = get_dir(attacker_turf, blocker_turf)
	return (blocker.dir & attack_direction)

/// Żołądek karalucha: obrzydzenie znika błyskawicznie, ale większy głód
/obj/item/organ/stomach/roach
	name = "zmutowany karaluszy żołądek"
	desc = "DNA karalucha wszczepione w coś, co kiedyś było zwykłym żołądkiem."
	icon = 'aquila/icons/dna_infuser/organs.dmi'
	icon_state = "roach_stomach"
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	disgust_metabolism = 32
	/// mnożnik głodu
	var/hunger_modifier = 3

/obj/item/organ/stomach/roach/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/roach)

/obj/item/organ/stomach/roach/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(owner == M && ishuman(M))
		var/mob/living/carbon/human/human_owner = M
		human_owner.physiology.hunger_mod *= hunger_modifier

/obj/item/organ/stomach/roach/Remove(mob/living/carbon/M, special = 0)
	if(ishuman(M) && owner == M)
		var/mob/living/carbon/human/human_owner = M
		human_owner.physiology.hunger_mod /= hunger_modifier
	return ..()

/// Wątroba karalucha: toleruje więcej toksyn, ale jak już się przebiją, bolą podwójnie
/obj/item/organ/liver/roach
	name = "zmutowana karalusza wątroba"
	desc = "DNA karalucha wszczepione w coś, co kiedyś było zwykłą wątrobą."
	icon = 'aquila/icons/dna_infuser/organs.dmi'
	icon_state = "roach_liver"
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	toxTolerance = 5

/obj/item/organ/liver/roach/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/roach)

/obj/item/organ/liver/roach/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(owner == M && ishuman(M))
		var/mob/living/carbon/human/human_owner = M
		human_owner.physiology.tox_mod *= 2

/obj/item/organ/liver/roach/Remove(mob/living/carbon/M, special = 0)
	if(ishuman(M) && owner == M)
		var/mob/living/carbon/human/human_owner = M
		human_owner.physiology.tox_mod /= 2
	return ..()

/// Wyrostek karalucha: żadnego zapalenia wyrostka!
/obj/item/organ/appendix/roach
	name = "zmutowany karaluszy wyrostek"
	desc = "DNA karalucha wszczepione w coś, co kiedyś było zwykłym wyrostkiem. Może być <i>gorzej</i>?"
	icon = 'aquila/icons/dna_infuser/organs.dmi'
	icon_state = "roach_appendix"
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD

/obj/item/organ/appendix/roach/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/roach)

/obj/item/organ/appendix/roach/update_icon()
	inflamed = FALSE
	icon_state = "roach_appendix"
	name = initial(name)

/obj/item/organ/appendix/roach/on_life()
	. = ..()
	if(!owner)
		return
	for(var/datum/disease/appendicitis/appendicitis in owner.diseases)
		appendicitis.cure(FALSE)

#undef TRAIT_INFUSER_ROACH_KNOCKDOWN
