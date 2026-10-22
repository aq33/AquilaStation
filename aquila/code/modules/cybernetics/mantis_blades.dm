// Port cybernetyki z Monkestation: ostrza modliszki (C.H.R.O.M.A.T.A., S.A.Y.A., A.R.A.S.A.K.A.)
// Różnice: zamiast wound_bonus mamy bleed_force, blokowanie idzie przez nasz block_level,
// rzut A.R.A.S.A.K.A. jest w afterattack, postawa obronna S.A.Y.A. to prosty status effect.

/obj/item/organ/cyberimp/arm/mantis
	name = "implanty ostrzy modliszki C.H.R.O.M.A.T.A."
	desc = "Zaawansowane implanty z ostrzem modliszki. Poręczna broń, która zadaje paskudne rany."
	icon = 'aquila/icons/obj/cybernetics/implants.dmi'
	icon_state = "toolkit_security"
	items_to_create = list(/obj/item/mantis_blade)

/obj/item/organ/cyberimp/arm/mantis/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/mantis/shield
	name = "implanty obronne ramion S.A.Y.A."
	desc = "Implanty z ostrzami-tarczami, które pozwalają blokować nadchodzące ataki kosztem mobilności i siły ataku."
	items_to_create = list(/obj/item/mantis_blade/shield)

/obj/item/organ/cyberimp/arm/mantis/shield/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/syndie_mantis
	name = "implanty ostrzy modliszki A.R.A.S.A.K.A."
	desc = "Unowocześnione ostrze modliszki, ulubione przez agentów Tygrysa. Ostrzejsza klinga z energetycznymi siłownikami czyni z niego znacznie groźniejszą broń."
	icon = 'aquila/icons/obj/cybernetics/implants.dmi'
	icon_state = "toolkit_syndie"
	syndicate_implant = TRUE
	items_to_create = list(/obj/item/mantis_blade/syndicate)

/obj/item/organ/cyberimp/arm/syndie_mantis/l
	zone = BODY_ZONE_L_ARM

/obj/item/mantis_blade
	name = "ostrze modliszki C.H.R.O.M.A.T.A."
	desc = "Potężne wbudowane ostrze ukryte tuż pod skórą. Wystarczy jeden sygnał z mózgu, by w kilka sekund było gotowe do walki. \
		Użyj w ręce, by przełączyć tryb cięcia i podważania; z dwoma ostrzami podważysz nawet zasilone drzwi."
	icon = 'aquila/icons/obj/cybernetics/implants.dmi'
	icon_state = "mantis"
	item_state = "mantis"
	lefthand_file = 'aquila/icons/obj/cybernetics/implants_lefthand.dmi'
	righthand_file = 'aquila/icons/obj/cybernetics/implants_righthand.dmi'
	hitsound = 'sound/weapons/bladeslice.ogg'
	flags_1 = CONDUCT_1
	force = 12
	bleed_force = BLEED_CUT
	w_class = WEIGHT_CLASS_NORMAL
	sharpness = IS_SHARP
	tool_behaviour = TOOL_KNIFE
	max_integrity = 200
	block_upgrade_walk = 1
	block_flags = BLOCKING_ACTIVE
	attack_verb = list("atakuje", "ciacha", "dźga", "kroi", "rozdziera", "rozrywa", "sieka", "tnie")
	/// Ostrze z drugiej ręki właśnie dokłada swój cios, żeby nie odbijać ataku w kółko
	var/dual_attacking = FALSE

/obj/item/mantis_blade/equipped(mob/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_HANDS)
		return
	// Ostrza są rysowane lustrzanie zależnie od ręki
	transform = user.get_held_index_of_item(src) % 2 ? null : matrix(-1, 0, 0, 0, 1, 0)

/obj/item/mantis_blade/dropped(mob/user, silent)
	. = ..()
	set_cutting_mode(user, silent = TRUE)

/// Druga ręka trzyma ostrze tego samego typu
/obj/item/mantis_blade/proc/get_paired_blade(mob/user)
	var/obj/item/mantis_blade/other = user.get_inactive_held_item()
	if(istype(other, type) && other != src)
		return other

/obj/item/mantis_blade/attack(mob/living/M, mob/living/user, params)
	. = ..()
	if(dual_attacking || user.get_active_held_item() != src)
		return
	var/obj/item/mantis_blade/other = get_paired_blade(user)
	if(!other || QDELETED(M))
		return
	other.dual_attacking = TRUE
	other.attack(M, user, params)
	other.dual_attacking = FALSE

/obj/item/mantis_blade/attack_self(mob/user)
	if(tool_behaviour == TOOL_CROWBAR)
		set_cutting_mode(user)
		return
	if(!get_paired_blade(user))
		balloon_alert(user, "potrzebujesz dwóch ostrzy!")
		return
	tool_behaviour = TOOL_CROWBAR
	ADD_TRAIT(src, TRAIT_DOOR_PRYER, REF(src))
	balloon_alert(user, "tryb podważania")

/obj/item/mantis_blade/proc/set_cutting_mode(mob/user, silent = FALSE)
	if(tool_behaviour == TOOL_KNIFE)
		return
	tool_behaviour = TOOL_KNIFE
	REMOVE_TRAIT(src, TRAIT_DOOR_PRYER, REF(src))
	if(!silent && user)
		balloon_alert(user, "tryb cięcia")

/obj/item/mantis_blade/syndicate
	name = "ostrze modliszki A.R.A.S.A.K.A."
	desc = "Unowocześnione ostrze modliszki agentów Tygrysa. Z dwoma ostrzami możesz doskoczyć do celu oddalonego o 3 kratki (koszt wytrzymałości, odnowienie 10 s)."
	icon_state = "syndie_mantis"
	item_state = "syndie_mantis"
	force = 15
	block_level = 1
	block_power = 20
	bleed_force = BLEED_DEEP_WOUND
	armour_penetration = 85
	/// Odnowienie doskoku
	COOLDOWN_DECLARE(lunge_cooldown)

/obj/item/mantis_blade/syndicate/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(proximity_flag || !isliving(target) || !isliving(user))
		return
	if(!COOLDOWN_FINISHED(src, lunge_cooldown) || get_dist(user, target) > 3)
		return
	var/obj/item/mantis_blade/syndicate/other = get_paired_blade(user)
	if(!other)
		return
	var/mob/living/lunger = user
	for(var/i in 1 to get_dist(lunger, target))
		if(!step_towards(lunger, target) && get_dist(lunger, target) >= 1)
			break
	COOLDOWN_START(src, lunge_cooldown, 10 SECONDS)
	COOLDOWN_START(other, lunge_cooldown, 10 SECONDS)
	lunger.adjustStaminaLoss(25)
	if(!lunger.Adjacent(target))
		return
	lunger.do_attack_animation(target)
	attack(target, lunger, click_parameters)

/////////OSTRZA-TARCZE S.A.Y.A./////////

/obj/item/mantis_blade/shield
	name = "system obronny ramion S.A.Y.A."
	desc = "Wytrzymałe, chowane ostrze z twardych materiałów, z szeroką osłoną. Celowo poświęca siłę ataku i mobilność na rzecz lepszej ochrony. \
		Użyj w ręce z dwoma ostrzami, by przyjąć postawę obronną: blokujesz ciosy i pociski z przodu i z boków, ale zwalniasz, a ciosy tylko odpychają."
	icon_state = "shield_mantis"
	item_state = "shield_mantis"
	force = 12
	bleed_force = BLEED_SURFACE
	armour_penetration = 40
	attack_speed = 10
	block_level = 1
	block_power = 30
	/// Właściciel stoi w postawie obronnej
	var/in_stance = FALSE

/obj/item/mantis_blade/shield/attack_self(mob/living/user)
	if(!istype(user))
		return
	if(user.has_status_effect(/datum/status_effect/shield_mantis_defense))
		user.remove_status_effect(/datum/status_effect/shield_mantis_defense)
		to_chat(user, span_notice("Przestajesz zasłaniać się ostrzami."))
		return
	if(!get_paired_blade(user))
		to_chat(user, span_warning("Do postawy obronnej potrzebujesz ostrzy w obu rękach."))
		return
	if(!do_after(user, 1.5 SECONDS, FALSE, user))
		to_chat(user, span_warning("Coś ci przerwało!"))
		return
	if(!get_paired_blade(user))
		return
	user.apply_status_effect(/datum/status_effect/shield_mantis_defense)
	to_chat(user, span_notice("Przyjmujesz postawę obronną z ostrzami modliszki."))

/obj/item/mantis_blade/shield/attack(mob/living/M, mob/living/user, params)
	// W postawie obronnej ostrza nie tną, tylko odpychają
	if(in_stance && ishuman(M) && ishuman(user))
		var/mob/living/carbon/human/defender = user
		defender.dna.species.disarm(defender, M)
		user.changeNext_move(CLICK_CD_MELEE)
		return
	return ..()

/obj/item/mantis_blade/shield/dropped(mob/user, silent)
	. = ..()
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.remove_status_effect(/datum/status_effect/shield_mantis_defense)

#define MANTIS_STANCE_MOVESPEED "mantis_shield_stance"

/// Postawa obronna S.A.Y.A.: oba ostrza blokują z przodu i z boków, także pociski; właściciel zwalnia.
/datum/status_effect/shield_mantis_defense
	id = "mantis_defensive"
	alert_type = null
	/// Ostrza, które dostały premię do blokowania
	var/list/obj/item/mantis_blade/shield/blades

/datum/status_effect/shield_mantis_defense/on_apply()
	blades = list()
	for(var/obj/item/mantis_blade/shield/blade in owner.held_items)
		blades += blade
	if(length(blades) < 2)
		blades = null
		return FALSE
	for(var/obj/item/mantis_blade/shield/blade as anything in blades)
		blade.in_stance = TRUE
		blade.block_level = 3
		blade.block_flags = BLOCKING_PROJECTILE
	owner.add_movespeed_modifier(MANTIS_STANCE_MOVESPEED, TRUE, multiplicative_slowdown = 1.25)
	owner.balloon_alert_to_viewers("zaczyna się zasłaniać!")
	return TRUE

/datum/status_effect/shield_mantis_defense/on_remove()
	for(var/obj/item/mantis_blade/shield/blade as anything in blades)
		blade.in_stance = FALSE
		blade.block_level = initial(blade.block_level)
		blade.block_flags = initial(blade.block_flags)
	blades = null
	owner.remove_movespeed_modifier(MANTIS_STANCE_MOVESPEED)
	owner.balloon_alert_to_viewers("przestaje się zasłaniać!")

/datum/status_effect/shield_mantis_defense/tick()
	if(owner.stat != CONSCIOUS || owner.IsParalyzed() || owner.IsKnockdown())
		owner.remove_status_effect(/datum/status_effect/shield_mantis_defense)

#undef MANTIS_STANCE_MOVESPEED
