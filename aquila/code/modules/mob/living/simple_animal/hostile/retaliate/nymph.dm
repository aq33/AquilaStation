// Nimfa diony z BeeStation-Hornet (code/modules/mob/living/simple_animal/hostile/retaliate/nymph.dm).
// Rozbiegają się, gdy diona się rozpada albo odszczepia nimfę. Jedną steruje gracz. Dorosła nimfa
// wraz z drugą nimfą wyrasta w nowy gestalt, a nimfy bez gracza odbudowują dionie brakujące kończyny.
/mob/living/simple_animal/hostile/retaliate/nymph
	name = "nimfa diony"
	desc = "Czy to roślina?"
	icon = 'aquila/icons/mob/species/diona/nymph.dmi'
	icon_state = "nymph"
	icon_living = "nymph"
	icon_dead = "nymph_dead"
	faction = list(FACTION_DIONA)
	gender = NEUTER
	gold_core_spawnable = FRIENDLY_SPAWN
	pass_flags = PASSTABLE | PASSMOB
	density = FALSE
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	ventcrawler = VENTCRAWLER_ALWAYS
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	head_icon = 'aquila/icons/mob/species/diona/nymph_head.dmi'
	held_lh = 'aquila/icons/mob/species/diona/nymph_lefthand.dmi'
	held_rh = 'aquila/icons/mob/species/diona/nymph_righthand.dmi'
	held_state = "nymph"
	butcher_results = list(/obj/item/food/meat/slab/human/mutant/plant = 4)
	initial_language_holder = /datum/language_holder/diona
	speak_emote = list("terkocze")
	response_help = "głaszcze"
	response_disarm = "odsuwa"
	response_harm = "kopie"
	attacktext = "gryzie"
	health = 50
	maxHealth = 50
	melee_damage = 1.5
	obj_damage = 10
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 2.7
	attack_sound = 'aquila/sound/emotes/diona/hit.ogg'
	deathmessage = "zdycha z żałosnym ćwierknięciem..."

	/// Postęp dorastania, 1 na tick Life()
	var/amount_grown = 0
	var/max_grown = 150
	/// Czy duch może przejąć tę nimfę
	var/is_ghost_spawn = TRUE
	/// Imię gestaltu, z którego pochodzi nimfa gracza
	var/old_name
	/// Cechy wyglądu gestaltu, wracają przy dorośnięciu
	var/list/features = list()
	var/time_spent_in_light = 0
	/// Trwa wchłanianie innej nimfy
	var/assimilating = FALSE
	var/grown_message_sent = FALSE
	var/datum/action/nymph_evolve/evolve_ability

/mob/living/simple_animal/hostile/retaliate/nymph/Initialize(mapload)
	. = ..()
	name = "[initial(name)] ([rand(1, 1000)])"
	real_name = name
	ADD_TRAIT(src, TRAIT_MUTE, INNATE_TRAIT)
	evolve_ability = new
	evolve_ability.Grant(src)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/mob/living/simple_animal/hostile/retaliate/nymph/Destroy()
	QDEL_NULL(evolve_ability)
	return ..()

/mob/living/simple_animal/hostile/retaliate/nymph/get_stat_tab_status()
	var/list/tab_data = ..()
	tab_data["Dorastanie"] = GENERATE_STAT_TEXT("[round(amount_grown / max_grown * 100)]%")
	return tab_data

/mob/living/simple_animal/hostile/retaliate/nymph/Life()
	. = ..()
	if(stat == DEAD)
		return
	if(amount_grown < max_grown)
		amount_grown++
	if(!grown_message_sent && amount_grown >= max_grown)
		grown_message_sent = TRUE
		to_chat(src, "<span class='userdanger'>Czujesz, że możesz już dorosnąć!</span>")
	if(stat != CONSCIOUS)
		remove_status_effect(/datum/status_effect/diona_planthealing)
		return
	if(!isturf(loc))
		return
	var/turf/T = loc
	var/light_amount = min(1, T.get_lumcount()) - 0.5
	if(light_amount > 0.2)
		time_spent_in_light++
		if(time_spent_in_light > 5)
			apply_status_effect(/datum/status_effect/diona_planthealing)
	else
		remove_status_effect(/datum/status_effect/diona_planthealing)
		time_spent_in_light = 0

/mob/living/simple_animal/hostile/retaliate/nymph/death(gibbed)
	remove_status_effect(/datum/status_effect/diona_planthealing)
	return ..()

/mob/living/simple_animal/hostile/retaliate/nymph/spawn_gibs()
	new /obj/effect/decal/cleanable/insectguts(drop_location())
	playsound(drop_location(), 'sound/effects/blobattack.ogg', 60, TRUE)

/// Nimfa gracza wchłania nimfę bez gracza i razem wyrastają w nowy gestalt
/mob/living/simple_animal/hostile/retaliate/nymph/attack_animal(mob/living/simple_animal/M)
	if(isnymph(M) && stat != DEAD && !mind)
		var/mob/living/simple_animal/hostile/retaliate/nymph/user = M
		if(user.assimilating)
			return
		user.assimilating = TRUE
		playsound(user, 'aquila/sound/emotes/diona/venus_trap_death.ogg', 25, TRUE)
		user.visible_message("<span class='notice'>[user] zaczyna wchłaniać [src].</span>", "<span class='notice'>Zaczynasz wchłaniać [src].</span>")
		toggle_ai(AI_OFF)
		if(do_after(user, 30 SECONDS, target = src))
			user.evolve(src)
			return
		toggle_ai(AI_ON)
		user.assimilating = FALSE
		return
	return ..()

/mob/living/simple_animal/hostile/retaliate/nymph/attack_ghost(mob/dead/observer/user)
	if(client || key || ckey)
		to_chat(user, "<span class='warning'>[src] ma już gracza.</span>")
		return
	if(!is_ghost_spawn || stat == DEAD)
		to_chat(user, "<span class='warning'>Nie możesz przejąć [src]!</span>")
		return
	if(tgui_alert(user, "Czy chcesz przejąć [src]?", "Czas na ćwierkanie?", list("Tak", "Nie")) != "Tak")
		return
	if(QDELETED(src) || QDELETED(user) || !user.client || client || key || stat == DEAD)
		return
	key = user.key
	to_chat(src, "<span class='boldwarning'>Pamiętaj, że zapomniałeś wszystkie swoje poprzednie życia i jesteś nową osobą!</span>")

/mob/living/simple_animal/hostile/retaliate/nymph/proc/on_entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(isdiona(arrived))
		INVOKE_ASYNC(src, PROC_REF(nymph_assimilation), arrived)

/// Nimfa bez gracza odbudowuje dionie, która na nią weszła, brakującą kończynę
/mob/living/simple_animal/hostile/retaliate/nymph/proc/nymph_assimilation(mob/living/carbon/human/arrived_diona)
	if(mind || stat == DEAD || assimilating)
		return
	var/list/limbs_to_heal = arrived_diona.get_missing_limbs()
	if(!length(limbs_to_heal))
		return
	assimilating = TRUE
	toggle_ai(AI_OFF)
	if(!do_after(arrived_diona, 5 SECONDS, target = src))
		toggle_ai(AI_IDLE)
		assimilating = FALSE
		return
	if(QDELETED(src) || QDELETED(arrived_diona) || !isdiona(arrived_diona))
		return
	playsound(arrived_diona, 'aquila/sound/emotes/diona/venus_trap_hit.ogg', 25, TRUE)
	var/healed_zone = pick(limbs_to_heal)
	arrived_diona.regenerate_limb(healed_zone)
	var/obj/item/bodypart/healed_limb = arrived_diona.get_bodypart(healed_zone)
	if(healed_limb)
		healed_limb.brute_dam = getBruteLoss()
		healed_limb.burn_dam = getFireLoss()
		arrived_diona.updatehealth()
	arrived_diona.update_body()
	arrived_diona.visible_message("<span class='notice'>[arrived_diona] wchłania [src].</span>")
	qdel(src)

/// Dorośnięcie: nowa diona bez kończyn, które trzeba odbudować nimfami
/mob/living/simple_animal/hostile/retaliate/nymph/proc/evolve(mob/living/simple_animal/hostile/retaliate/nymph/helper)
	if(istype(loc, /obj/item/clothing/head/mob_holder))
		var/obj/item/clothing/head/mob_holder/holder = loc
		holder.release()
	visible_message("<span class='warning'>[src] zaczyna drżeć, a po wchłonięciu drugiej nimfy wybucha deszczem zrzuconej kory, splatając się w nowy gestalt diony.</span>",
		"<span class='warning'>Zaczynasz drżeć, a twoja świadomość się rozszczepia. Zużywamy zapasy i razem z przyjaciółką rozrastamy się w plątaninę pnączy. Osiągnęliśmy postać gestaltu. Przyjaciele powinni pomóc nam odzyskać resztę kończyn...</span>")
	if(!helper)
		helper = new(loc)
	var/mob/living/carbon/human/species/diona/adult = new(loc)
	for(var/obj/item/bodypart/limb as anything in adult.bodyparts.Copy())
		if(limb.body_zone == BODY_ZONE_CHEST)
			limb.receive_damage(helper.getBruteLoss(), helper.getFireLoss())
		else if(limb.body_zone == BODY_ZONE_HEAD)
			limb.receive_damage(getBruteLoss(), getFireLoss())
		else // Mała diona nie ma kończyn
			limb.drop_limb(TRUE)
			qdel(limb)
	if(!("neutral" in faction))
		adult.faction = faction.Copy()
	if(old_name)
		adult.fully_replace_character_name(adult.real_name, old_name)
		if(length(features))
			adult.dna.features = features.Copy()
	else
		adult.fully_replace_character_name(adult.real_name, adult.dna.species.random_name(unique = TRUE))
		adult.dna.features["mcolor"] = sanitize_hexcolor(random_color())
	if(mind)
		mind.transfer_to(adult)
	else if(key)
		adult.key = key
	adult.updatehealth()
	adult.update_body()
	adult.update_hair()
	adult.update_body_parts(TRUE)
	adult.set_nutrition(NUTRITION_LEVEL_HUNGRY)
	qdel(helper)
	qdel(src)
	return adult

/datum/action/nymph_evolve
	name = "Dorośnij"
	desc = "Wyrośnij w dorosłą postać z pomocą innej nimfy."
	icon_icon = 'aquila/icons/mob/species/diona/actions.dmi'
	button_icon_state = "grow"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_STUN

/datum/action/nymph_evolve/Trigger()
	if(!..())
		return FALSE
	var/mob/living/simple_animal/hostile/retaliate/nymph/nymph = owner
	if(!isnymph(nymph))
		return FALSE
	if(nymph.movement_type & VENTCRAWLING)
		to_chat(nymph, "<span class='danger'>Nie możesz dorosnąć w rurze wentylacyjnej.</span>")
		return FALSE
	if(nymph.amount_grown < nymph.max_grown)
		to_chat(nymph, "<span class='danger'>Nie jesteś jeszcze gotowa, by sama dorosnąć.</span>")
		return FALSE
	playsound(nymph, 'aquila/sound/emotes/diona/venus_trap_death.ogg', 25, TRUE)
	nymph.evolve()
	return TRUE
