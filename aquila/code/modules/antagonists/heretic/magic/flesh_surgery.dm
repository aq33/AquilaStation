/datum/action/cooldown/spell/touch/flesh_surgery
	name = "Knit Flesh"
	desc = "Zaklęcie dotyku, które pozwala pozyskiwać albo przywracać ciało celu. \
		Lewym przyciskiem wyjmujesz organy ofiary bez operacji i patroszenia. \
		Możesz też chwycić leżący organ i wsadzić go ofierze. \
		Prawym przyciskiem leczysz swoje przywołańce i sługi oraz uszkodzone organy."
	background_icon_state = "bg_ecult"
	overlay_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "mad_touch"
	sound = null

	school = SCHOOL_FORBIDDEN
	cooldown_time = 20 SECONDS
	invocation = "CL'M M'N!" // "CLAIM MINE", but also almost "KALI MA"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	hand_path = /obj/item/melee/spell_hand/flesh_surgery
	can_cast_on_self = TRUE

	/// If used on an organ, how much percent of the organ's HP do we restore
	var/organ_percent_healing = 0.5
	/// If used on a heretic mob, how much brute do we heal
	var/monster_brute_healing = 10
	/// If used on a heretic mob, how much burn do we heal
	var/monster_burn_healing = 5
	/// The organ being held in the touch attack - which will be implanted into mobs.
	var/obj/item/organ/held_organ
	/// Can we implant cybernetic organs?
	var/allow_cyber_organs = FALSE

/datum/action/cooldown/spell/touch/flesh_surgery/is_valid_target(atom/cast_on)
	return isliving(cast_on) || isorgan(cast_on)

/datum/action/cooldown/spell/touch/flesh_surgery/remove_hand(mob/living/hand_owner, reset_cooldown_after)
	var/obj/item/organ/the_organ = held_organ
	if(the_organ)
		unregister_held_organ(the_organ)
		the_organ.forceMove(hand_owner ? hand_owner.drop_location() : get_turf(attached_hand))

	return ..()

/datum/action/cooldown/spell/touch/flesh_surgery/cast_on_hand_hit(obj/item/melee/spell_hand/flesh_surgery/hand, atom/victim, mob/living/carbon/caster)
	if(isorgan(victim))
		grab_organ(hand, victim, caster)
		return FALSE

	if(isliving(victim))
		if(held_organ)
			return insert_organ_into_mob(held_organ, hand, victim, caster)
		return steal_organ_from_mob(hand, victim, caster)

	return FALSE

/datum/action/cooldown/spell/touch/flesh_surgery/cast_on_secondary_hand_hit(obj/item/melee/spell_hand/flesh_surgery/hand, atom/victim, mob/living/carbon/caster)
	if(isorgan(victim))
		return heal_organ(hand, victim, caster) ? SECONDARY_ATTACK_CONTINUE_CHAIN : SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(isliving(victim))
		var/mob/living/mob_victim = victim
		if(mob_victim.stat == DEAD || !HAS_TRAIT(mob_victim, TRAIT_HERETIC_SUMMON))
			return SECONDARY_ATTACK_CALL_NORMAL

		if(heal_heretic_monster(hand, mob_victim, caster))
			return SECONDARY_ATTACK_CONTINUE_CHAIN

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

// AQUILA - tg: podpowiedzi kontekstowe (screentips) i COMSIG_ATOM_ITEM_INTERACTION. Podpowiedzi u nas nie ma,
// a włożenie organu do dłoni (organ w drugiej ręce, klik na dłoń) łapiemy przez attackby dłoni.
/datum/action/cooldown/spell/touch/flesh_surgery/register_hand_signals()
	. = ..()
	RegisterSignal(attached_hand, COMSIG_PARENT_ATTACKBY, PROC_REF(hand_interacted_with))

/datum/action/cooldown/spell/touch/flesh_surgery/unregister_hand_signals()
	. = ..()
	UnregisterSignal(attached_hand, COMSIG_PARENT_ATTACKBY)

/datum/action/cooldown/spell/touch/flesh_surgery/proc/hand_interacted_with(obj/item/melee/spell_hand/source, obj/item/tool, mob/living/user, params)
	SIGNAL_HANDLER
	if(!isorgan(tool))
		return NONE
	grab_organ(source, tool, user)
	return COMPONENT_NO_AFTERATTACK

/// If cast on an organ with left-click, we'll try to grab it.
/datum/action/cooldown/spell/touch/flesh_surgery/proc/grab_organ(obj/item/melee/spell_hand/hand, obj/item/organ/to_grab, mob/living/carbon/caster)
	if(held_organ)
		hand.balloon_alert(caster, "już trzymasz organ!")
		return FALSE
	if((to_grab.organ_flags & ORGAN_SYNTHETIC) && !allow_cyber_organs)
		hand.balloon_alert(caster, "nie przyjmie cybernetycznego organu!")
		return FALSE
	if(!caster.transferItemToLoc(to_grab, hand))
		hand.balloon_alert(caster, "nie da się chwycić organu!")
		return FALSE
	register_held_organ(to_grab, hand)
	return TRUE

/datum/action/cooldown/spell/touch/flesh_surgery/proc/register_held_organ(obj/item/organ/new_held_organ, obj/item/melee/spell_hand/hand)
	hand.vis_contents += new_held_organ
	held_organ = new_held_organ
	ADD_TRAIT(new_held_organ, TRAIT_SKIP_BASIC_REACH_CHECK, REF(src))
	new_held_organ.vis_flags |= VIS_INHERIT_PLANE
	RegisterSignal(new_held_organ, COMSIG_MOVABLE_MOVED, PROC_REF(unregister_held_organ))
	RegisterSignal(new_held_organ, COMSIG_PARENT_QDELETING, PROC_REF(unregister_held_organ))
	// We gotta offset ourselves via pixel_w/z, so we don't end up z fighting with the touch attack
	new_held_organ.pixel_w = new_held_organ.pixel_x
	new_held_organ.pixel_z = new_held_organ.pixel_y
	new_held_organ.pixel_x = 0
	new_held_organ.pixel_y = 0

/datum/action/cooldown/spell/touch/flesh_surgery/proc/unregister_held_organ(obj/item/organ/removed_organ)
	SIGNAL_HANDLER
	if(attached_hand)
		attached_hand.vis_contents -= removed_organ
	held_organ = null
	REMOVE_TRAIT(removed_organ, TRAIT_SKIP_BASIC_REACH_CHECK, REF(src))
	removed_organ.vis_flags &= ~VIS_INHERIT_PLANE
	UnregisterSignal(removed_organ, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
	// Reset item offsets
	removed_organ.pixel_x = removed_organ.pixel_w
	removed_organ.pixel_y = removed_organ.pixel_z
	removed_organ.pixel_w = 0
	removed_organ.pixel_z = 0

/// If cast on an organ with right-click, we'll restore its health and even un-fail it.
/datum/action/cooldown/spell/touch/flesh_surgery/proc/heal_organ(obj/item/melee/spell_hand/hand, obj/item/organ/to_heal, mob/living/carbon/caster)
	if(held_organ)
		hand.balloon_alert(caster, "najpierw odłóż organ!")
		return FALSE
	if(to_heal.damage == 0)
		to_heal.balloon_alert(caster, "już jest w dobrym stanie!")
		return FALSE
	to_heal.balloon_alert(caster, "leczenie organu...")
	if(!do_after(caster, 1 SECONDS, target = to_heal, extra_checks = CALLBACK(src, PROC_REF(heal_checks), hand, to_heal, caster)))
		to_heal.balloon_alert(caster, "przerwano!")
		return FALSE

	var/organ_hp_to_heal = to_heal.maxHealth * organ_percent_healing
	to_heal.setOrganDamage(max(0, to_heal.damage - organ_hp_to_heal))
	to_heal.balloon_alert(caster, "organ uleczony")
	playsound(to_heal, 'sound/magic/staff_healing.ogg', 30)
	new /obj/effect/temp_visual/cult/sparks(get_turf(to_heal))
	var/condition = (to_heal.damage > 0) ? "lepszego" : "idealnego"
	caster.visible_message(
		span_warning("Dłoń [caster] rozbłyska jaskrawą czerwienią, gdy przywraca [to_heal] do [condition] stanu!"),
		span_notice("Twoja dłoń rozbłyska jaskrawą czerwienią, gdy przywracasz [to_heal] do [condition] stanu!"),
	)

	return TRUE

/// If cast on a heretic monster who's not dead we'll heal it a bit.
/datum/action/cooldown/spell/touch/flesh_surgery/proc/heal_heretic_monster(obj/item/melee/spell_hand/hand, mob/living/to_heal, mob/living/carbon/caster)
	var/what_are_we = ishuman(to_heal) ? "sługi" : "przywołańca"
	to_heal.balloon_alert(caster, "leczenie [what_are_we]...")
	if(!do_after(caster, 1 SECONDS, target = to_heal, extra_checks = CALLBACK(src, PROC_REF(heal_checks), hand, to_heal, caster)))
		to_heal.balloon_alert(caster, "przerwano!")
		return FALSE

	// Keep in mind that, for simplemobs(summons), this will just flat heal the combined value of both brute and burn healing,
	// while for human minions(ghouls), this will heal brute and burn like normal. So be careful adjusting to bigger numbers
	to_heal.balloon_alert(caster, "uleczono")
	to_heal.heal_overall_damage(monster_brute_healing, monster_burn_healing)
	playsound(to_heal, 'sound/magic/staff_healing.ogg', 30)
	new /obj/effect/temp_visual/cult/sparks(get_turf(to_heal))
	caster.visible_message(
		span_warning("Dłoń [caster] rozbłyska jaskrawą czerwienią, gdy przywraca [to_heal] do dobrego stanu!"),
		span_notice("Twoja dłoń rozbłyska jaskrawą czerwienią, gdy przywracasz [to_heal] do dobrego stanu!"),
	)
	return TRUE

/// AQUILA - tg: parse_zone_with_bodypart. Nazwa strefy ciała w dopełniaczu.
/datum/action/cooldown/spell/touch/flesh_surgery/proc/zone_name(zone)
	switch(zone)
		if(BODY_ZONE_HEAD)
			return "głowy"
		if(BODY_ZONE_CHEST)
			return "klatki piersiowej"
		if(BODY_ZONE_L_ARM)
			return "lewej ręki"
		if(BODY_ZONE_R_ARM)
			return "prawej ręki"
		if(BODY_ZONE_L_LEG)
			return "lewej nogi"
		if(BODY_ZONE_R_LEG)
			return "prawej nogi"
		if(BODY_ZONE_PRECISE_EYES)
			return "oczu"
		if(BODY_ZONE_PRECISE_MOUTH)
			return "ust"
		if(BODY_ZONE_PRECISE_GROIN)
			return "podbrzusza"
	return parse_zone(zone)

/// If cast on a carbon, we'll try to steal one of their organs directly from their person.
/datum/action/cooldown/spell/touch/flesh_surgery/proc/steal_organ_from_mob(obj/item/melee/spell_hand/hand, mob/living/victim, mob/living/carbon/caster)
	var/mob/living/carbon/carbon_victim = victim
	if(!istype(carbon_victim) || !length(carbon_victim.internal_organs))
		victim.balloon_alert(caster, "brak organów!")
		return FALSE

	// Round u pto the nearest generic zone (body, chest, arm)
	var/zone_to_check = check_zone(caster.zone_selected)
	var/parsed_zone = zone_name(zone_to_check)

	var/list/organs_we_can_remove = list()
	for(var/obj/item/organ/organ as anything in carbon_victim.internal_organs)
		// Only show organs which are in our generic zone
		if(check_zone(organ.zone) != zone_to_check)
			continue
		// Also, some organs to exclude. Don't remove vital (brains), don't remove synthetics, and don't remove unremovable
		if(organ.organ_flags & (ORGAN_SYNTHETIC|ORGAN_VITAL|ORGAN_UNREMOVABLE))
			continue

		organs_we_can_remove[organ.name] = organ

	if(!length(organs_we_can_remove))
		victim.balloon_alert(caster, "brak organów w tym miejscu!")
		return FALSE

	var/chosen_organ = tgui_input_list(caster, "Który organ chcesz wyjąć?", name, sortList(organs_we_can_remove))
	if(isnull(chosen_organ))
		return FALSE
	var/obj/item/organ/picked_organ = organs_we_can_remove[chosen_organ]
	if(!istype(picked_organ) || !extraction_checks(picked_organ, hand, victim, caster))
		return FALSE

	// Don't let people stam crit into steal heart true combo
	var/time_it_takes = carbon_victim.stat == DEAD ? 3 SECONDS : 15 SECONDS

	// Sure you can remove your own organs, fun party trick
	if(carbon_victim == caster)
		var/are_you_sure = tgui_alert(caster, "Na pewno chcesz wyjąć własny organ ([chosen_organ])?", "Na pewno?", list("Tak", "Nie"))
		if(are_you_sure != "Tak" || !extraction_checks(picked_organ, hand, victim, caster))
			return FALSE

		time_it_takes = 6 SECONDS
		caster.visible_message(
			span_danger("Dłoń [caster] rozbłyska jaskrawą czerwienią, gdy sięga prosto do własnej [parsed_zone]!"),
			span_userdanger("Twoja dłoń rozbłyska jaskrawą czerwienią, gdy sięgasz prosto do własnej [parsed_zone]!"),
		)

	else
		carbon_victim.visible_message(
			span_danger("Dłoń [caster] rozbłyska jaskrawą czerwienią, gdy sięga prosto do [parsed_zone] [carbon_victim]!"),
			span_userdanger("Dłoń [caster] rozbłyska jaskrawą czerwienią, gdy sięga prosto do twojej [parsed_zone]!"),
		)

	carbon_victim.balloon_alert(caster, "wyjmowanie: [chosen_organ]...")
	playsound(victim, 'sound/weapons/slice.ogg', 50, TRUE)
	carbon_victim.add_atom_colour(COLOR_DARK_RED, TEMPORARY_COLOUR_PRIORITY)
	if(!do_after(caster, time_it_takes, target = carbon_victim, extra_checks = CALLBACK(src, PROC_REF(extraction_checks), picked_organ, hand, victim, caster)))
		carbon_victim.balloon_alert(caster, "przerwano!")
		carbon_victim.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_DARK_RED)
		return FALSE

	// Visible message done before Remove()
	// Mainly so it gets across if you're taking the eyes of someone who's conscious
	if(carbon_victim == caster)
		caster.visible_message(
			span_bolddanger("[caster] wyrywa sobie organ ([chosen_organ]) z własnej [parsed_zone]!!"),
			span_userdanger("Wyrywasz sobie organ ([chosen_organ]) z własnej [parsed_zone]!!"),
		)

	else
		carbon_victim.visible_message(
			span_bolddanger("[caster] wyrywa [carbon_victim] organ ([chosen_organ]) z [parsed_zone]!!"),
			span_userdanger("[caster] wyrywa ci organ ([chosen_organ]) z [parsed_zone]!!"),
		)

	picked_organ.Remove(carbon_victim)
	picked_organ.forceMove(get_turf(carbon_victim))
	carbon_victim.balloon_alert(caster, "wyjęto: [chosen_organ]")
	carbon_victim.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_DARK_RED)
	playsound(victim, 'aquila/sound/effects/dismember.ogg', 50, TRUE)
	if(!IS_UNCONSCIOUS_OR_CRIT(carbon_victim))
		// AQUILA - tg: heretycki bełkot (status speech/slurring/heretic); u nas zwykły bełkot
		carbon_victim.adjust_slurring(15 SECONDS)
		carbon_victim.emote("scream")

	// We need to wait for the spell to actually finish casting to put the organ in their hands, hence, 1 ms timer.
	addtimer(CALLBACK(caster, TYPE_PROC_REF(/mob, put_in_hands), picked_organ), 0.1 SECONDS)
	return TRUE

/datum/action/cooldown/spell/touch/flesh_surgery/proc/insert_organ_into_mob(obj/item/organ/inserted_organ, obj/item/melee/spell_hand/flesh_surgery/hand, mob/living/carbon/victim, mob/living/carbon/caster)
	if(!istype(victim))
		hand.balloon_alert(caster, "brak organów!")
		return FALSE

	var/zone_organ_goes_in = inserted_organ.zone
	var/zone_text = zone_name(zone_organ_goes_in)
	if(!victim.get_bodypart(check_zone(zone_organ_goes_in)))
		hand.balloon_alert(caster, "nie ma gdzie go włożyć!")
		return FALSE

	var/slot_organ_goes_in = inserted_organ.slot
	var/obj/item/organ/organ_victim_already_has = victim.getorganslot(slot_organ_goes_in)
	if(organ_victim_already_has?.organ_flags & (ORGAN_VITAL|ORGAN_UNREMOVABLE))
		hand.balloon_alert(caster, "nie da się wymienić tego organu!")
		return FALSE

	var/time_it_takes
	var/using_on_self = victim == caster
	var/replacing_with_failing = !(organ_victim_already_has?.organ_flags & ORGAN_FAILING) && (inserted_organ.organ_flags & ORGAN_FAILING)
	if(using_on_self)
		time_it_takes = inserted_organ.w_class * 2 SECONDS
	else if(victim.stat == DEAD)
		time_it_takes = inserted_organ.w_class * 1 SECONDS
	else if(replacing_with_failing)
		time_it_takes = 15 SECONDS
	else
		time_it_takes = inserted_organ.w_class * 3 SECONDS

	if(using_on_self && replacing_with_failing && organ_victim_already_has)
		var/are_you_sure = tgui_alert(caster,
			"Na pewno chcesz zastąpić swój organ ([organ_victim_already_has.name]) niedziałającym ([inserted_organ.name])?",
			"Na pewno?",
			list("Tak", "Nie"))
		if(are_you_sure != "Tak")
			return FALSE

	if(!insertion_checks(inserted_organ, hand, victim, caster))
		return FALSE

	if(using_on_self)
		caster.visible_message(
			span_danger("Dłoń [caster] rozbłyska jaskrawą czerwienią, gdy zaczyna wpychać [inserted_organ] do własnej [zone_text]!!"),
			span_userdanger("Zaczynasz wpychać [inserted_organ] do własnej [zone_text]!")
		)
	else
		caster.visible_message(
			span_danger("Dłoń [caster] rozbłyska jaskrawą czerwienią, gdy zaczyna wpychać [inserted_organ] do [zone_text] [victim]!!"),
			span_notice("Zaczynasz wpychać [inserted_organ] do [zone_text] [victim].")
		)

	victim.balloon_alert(caster, "wkładanie: [inserted_organ]...")
	playsound(victim, 'sound/weapons/slice.ogg', 50, TRUE)
	victim.add_atom_colour(COLOR_DARK_RED, TEMPORARY_COLOUR_PRIORITY)
	if(!do_after(caster, time_it_takes, target = victim, extra_checks = CALLBACK(src, PROC_REF(insertion_checks), inserted_organ, hand, victim, caster)))
		victim.balloon_alert(caster, "przerwano!")
		victim.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_DARK_RED)
		return FALSE

	organ_victim_already_has = victim.getorganslot(slot_organ_goes_in) // This COULD have changed over the course of the do_after

	if(using_on_self)
		caster.visible_message(
			span_danger("[caster] wciska [inserted_organ] do własnej [zone_text][organ_victim_already_has ? ", wypychając swój organ ([organ_victim_already_has.name])": ""]!"),
			span_userdanger("Kończysz wkładać [inserted_organ] do własnej [zone_text][organ_victim_already_has ? ", wypychając swój organ ([organ_victim_already_has.name])" : ""]!")
		)
	else
		caster.visible_message(
			span_danger("[caster] wciska [inserted_organ] do [zone_text] [victim][organ_victim_already_has ? ", wypychając organ ([organ_victim_already_has.name])": ""]!"),
			span_notice("Kończysz wkładać [inserted_organ] do [zone_text] [victim][organ_victim_already_has ? ", wypychając organ ([organ_victim_already_has.name])": ""].")
		)

	unregister_held_organ(inserted_organ)
	inserted_organ.Insert(victim)
	victim.balloon_alert(caster, "włożono: [inserted_organ]")
	victim.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_DARK_RED)
	playsound(victim, 'aquila/sound/effects/dismember.ogg', 50, TRUE)
	if(!IS_UNCONSCIOUS_OR_CRIT(victim))
		victim.emote("scream")
		if(!using_on_self)
			victim.adjust_slurring(15 SECONDS)

	return TRUE

/// Extra checks ran while we're extracting an organ to make sure we can continue to do.
/datum/action/cooldown/spell/touch/flesh_surgery/proc/extraction_checks(obj/item/organ/picked_organ, obj/item/melee/spell_hand/flesh_surgery/hand, mob/living/carbon/victim, mob/living/carbon/caster)
	if(QDELETED(src) || QDELETED(hand) || QDELETED(picked_organ) || QDELETED(victim) || held_organ || !IsAvailable())
		return FALSE
	if(picked_organ.owner != victim)
		return FALSE

	return TRUE

/// Extra checks ran while we're healing something (organ, mob).
/datum/action/cooldown/spell/touch/flesh_surgery/proc/heal_checks(obj/item/melee/spell_hand/flesh_surgery/hand, atom/healing, mob/living/carbon/caster)
	if(QDELETED(src) || QDELETED(hand) || QDELETED(healing) || held_organ || !IsAvailable())
		return FALSE

	return TRUE

/// Extra checks ran while we're inserting an organ.
/datum/action/cooldown/spell/touch/flesh_surgery/proc/insertion_checks(obj/item/organ/inserted_organ, obj/item/melee/spell_hand/flesh_surgery/hand, mob/living/carbon/victim, mob/living/carbon/caster)
	if(QDELETED(src) || QDELETED(hand) || QDELETED(victim) || QDELETED(inserted_organ) || (held_organ != inserted_organ) || !IsAvailable())
		return FALSE
	var/obj/item/organ/organ_victim_already_has = victim.getorganslot(inserted_organ.slot)
	if(organ_victim_already_has?.organ_flags & (ORGAN_VITAL|ORGAN_UNREMOVABLE))
		return FALSE

	return TRUE

/obj/item/melee/spell_hand/flesh_surgery
	name = "\improper knit flesh"
	desc = "Czas trochę popraktykować medycynę."
	icon = 'aquila/icons/obj/weapons/hand.dmi'
	icon_state = "disintegrate"
	item_state = "disintegrate"
