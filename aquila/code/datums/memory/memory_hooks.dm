// Miejsca, w których postacie dostają wspomnienia (odpowiedniki wywołań add_memory w plikach tg).
// Nadpisania z ..(); jednolinijkowe haki w core są oznaczone „AQ EDIT - wspomnienia z tg”.

// ---------------------------------------------------------------- śmierć

/mob/living/carbon/human/death(gibbed)
	var/was_dead = stat == DEAD
	. = ..()
	if(was_dead || stat != DEAD)
		return
	// Deaths of people undergoing surgery don't count (tg)
	if(HAS_TRAIT(src, TRAIT_READY_TO_OPERATE))
		return
	add_memory_in_range(src, 7, (gibbed ? /datum/memory/witness_gib : /datum/memory/witnessed_death), protagonist = src)

/// tg: basic moby z SENDS_DEATH_MOODLETS (Ian, Runtime). U nas zwierzaki domowe to /mob/living/basic/pet.
/mob/living/basic/pet/death(gibbed)
	if(stat != DEAD && !QDELETED(src))
		add_memory_in_range(src, 7, /datum/memory/pet_died, deuteragonist = src)
	return ..()

/mob/living/simple_animal/hostile/megafauna/death(gibbed)
	var/was_dead = stat == DEAD
	. = ..()
	if(was_dead || stat != DEAD || (flags_1 & ADMIN_SPAWNED_1))
		return
	for(var/mob/living/slayer in oviewers(7, src))
		if(slayer.stat)
			continue
		slayer.add_mob_memory(/datum/memory/megafauna_slayer, antagonist = src)

// ---------------------------------------------------------------- ciało

/mob/living/carbon/slip(knockdown_amount, obj/O, lube, paralyze, force_drop)
	. = ..()
	if(.)
		add_mob_memory(/datum/memory/was_slipped, antagonist = O || get_turf(src))

/mob/living/IgniteMob()
	. = ..()
	if(.)
		add_mob_memory(/datum/memory/was_burning)

/obj/item/bodypart/dismember(dam_type = BRUTE)
	var/mob/living/carbon/limb_owner = owner
	. = ..()
	if(. && limb_owner)
		limb_owner.add_mob_memory(/datum/memory/was_dismembered, lost_limb = src)

/// Spaghetti wysypujące się z kieszeni (komponent spill istnieje tylko dla tego memu)
/datum/component/spill/knockdown_react(mob/living/fool)
	. = ..()
	fool.add_mob_memory(/datum/memory/lost_spaghetti)

// ---------------------------------------------------------------- bomby

/obj/item/grenade/preprime(mob/user, delayoverride, msg = TRUE, volume = 60)
	. = ..()
	if(user)
		user.add_mob_memory(/datum/memory/bomb_planted, antagonist = src)

/obj/machinery/syndicatebomb/settings(mob/user)
	var/was_active = active
	. = ..()
	if(!was_active && active && user && !istype(payload, /obj/item/bombcore/training))
		user.add_mob_memory(/datum/memory/bomb_planted/syndicate, antagonist = src)

/obj/machinery/nuclearbomb/set_active()
	var/was_timing = timing
	. = ..()
	if(!was_timing && timing && ismob(usr))
		var/mob/armer = usr
		armer.add_mob_memory(/datum/memory/bomb_planted/nuke, antagonist = src)

/// tg: rozbrojenie i nieudane rozbrojenie bomby Syndykatu (nie bomby treningowej)
/datum/wires/syndicatebomb/proc/remember_defuse(was_active, was_exploding, time_left)
	var/obj/machinery/syndicatebomb/bomb = holder
	if(!was_active || !ismob(usr) || istype(bomb.payload, /obj/item/bombcore/training))
		return
	if(!was_exploding && bomb.explode_now)
		add_memory_in_range(bomb, 7, /datum/memory/bomb_defuse_failure, protagonist = usr, antagonist = bomb)
	else if(!bomb.active)
		add_memory_in_range(bomb, 7, /datum/memory/bomb_defuse_success, protagonist = usr, antagonist = bomb, bomb_time_left = time_left)

/datum/wires/syndicatebomb/on_pulse(wire)
	var/obj/machinery/syndicatebomb/bomb = holder
	var/was_active = bomb.active
	var/was_exploding = bomb.explode_now
	. = ..()
	if(was_active && !was_exploding && bomb.explode_now)
		remember_defuse(was_active, was_exploding, 0)

/datum/wires/syndicatebomb/on_cut(wire, mend)
	var/obj/machinery/syndicatebomb/bomb = holder
	var/was_active = bomb.active
	var/was_exploding = bomb.explode_now
	var/time_left = was_active ? bomb.seconds_remaining() : 0
	. = ..()
	if(!mend)
		remember_defuse(was_active, was_exploding, time_left)

// ---------------------------------------------------------------- świadkowie

/obj/machinery/power/supermatter_crystal/Consume(atom/movable/AM)
	if(isliving(AM))
		add_memory_in_range(src, 7, /datum/memory/witness_supermatter_dusting, protagonist = AM, antagonist = src)
	return ..()

/obj/machinery/vending/tilt(mob/fatty, crit = FALSE)
	. = ..()
	if(!in_range(fatty, src))
		return
	for(var/mob/living/carbon/crushed in get_turf(fatty))
		add_memory_in_range(crushed, 7, /datum/memory/witness_vendor_crush, protagonist = crushed, antagonist = src)

/obj/item/gun/ballistic/revolver/russian/afterattack(atom/target, mob/living/user, flag, params)
	var/was_spun = spun
	var/loaded_rounds = get_ammo(TRUE)
	var/obj/item/ammo_casing/old_chambered = chambered
	. = ..()
	// spun wraca do FALSE tylko wtedy, gdy gracz naprawdę pociągnął za spust, celując w siebie
	if(target != user || !ishuman(user) || !was_spun || spun || !loaded_rounds)
		return
	var/zone = check_zone(user.zone_selected)
	if(zone != BODY_ZONE_HEAD)
		return
	var/fired = old_chambered && !chambered
	add_memory_in_range(user, 7, /datum/memory/witnessed_russian_roulette, \
		protagonist = user, \
		antagonist = src, \
		rounds_loaded = loaded_rounds, \
		aimed_at = strefa_pl(zone), \
		result = (fired ? "lost" : "won"), \
	)

// ---------------------------------------------------------------- rewolucja

/datum/antagonist/rev/add_revolutionary(datum/mind/rev_mind, stun = TRUE)
	. = ..()
	if(.)
		rev_mind.add_memory(/datum/memory/recruited_by_headrev, protagonist = rev_mind.current, antagonist = owner.current)

/datum/team/revolution/process_victory(revs_win_injection_amount)
	. = ..()
	if(. == REVOLUTION_VICTORY)
		for(var/datum/mind/headrev_mind as anything in ex_headrevs)
			var/mob/living/real_headrev = headrev_mind.current
			if(isnull(real_headrev))
				continue
			add_memory_in_range(real_headrev, 5, /datum/memory/revolution_rev_victory, protagonist = real_headrev)
	else if(. == STATION_VICTORY)
		for(var/datum/objective/mutiny/head_tracker in objectives)
			var/mob/living/head_of_staff = head_tracker.target?.current
			if(!isnull(head_of_staff))
				add_memory_in_range(head_of_staff, 5, /datum/memory/revolution_heads_victory, protagonist = head_of_staff)
		// tg: przywódca, który przeżył klęskę (wygnaniec)
		for(var/datum/mind/headrev_mind as anything in ex_headrevs)
			if(considered_alive(headrev_mind))
				headrev_mind.add_memory(/datum/memory/revolution_rev_defeat)

// ---------------------------------------------------------------- ważne wspomnienia

/datum/controller/subsystem/job/promote_to_captain(mob/dead/new_player/new_captain, acting_captain = FALSE)
	. = ..()
	var/mob/living/carbon/human/captain = new_captain?.new_character
	if(captain && spare_id_safe_code)
		captain.add_mob_memory(/datum/memory/key/captains_spare_code, safe_code = spare_id_safe_code)

/datum/quirk/allergic/post_add()
	. = ..()
	if(allergy_string)
		quirk_holder.add_mob_memory(/datum/memory/key/quirk_allergy, allergy_string = allergy_string)

/datum/quirk/family_heirloom/post_add()
	. = ..()
	if(heirloom)
		quirk_holder.add_mob_memory(/datum/memory/key/quirk_heirloom, protagonist = quirk_holder, heirloom_name = heirloom.name)

/datum/quirk/junkie/smoker/post_add()
	. = ..()
	if(drug_container_type)
		quirk_holder.add_mob_memory(/datum/memory/key/quirk_smoker, protagonist = quirk_holder, preferred_brand = initial(drug_container_type.name))

/datum/quirk/alcoholic/post_add()
	. = ..()
	if(drink_instance)
		quirk_holder.add_mob_memory(/datum/memory/key/quirk_alcoholic, protagonist = quirk_holder, preferred_brandy = drink_instance.name)
