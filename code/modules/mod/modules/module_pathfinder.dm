///Pathfinder - Can fly the suit from a long distance to an implant installed in someone.
/obj/item/mod/module/pathfinder
	name = "moduł nawigatora MOD"
	desc = "Ten moduł od Nakamura Engineering składa się z dwóch części. \
		Pierwsza to zestaw silniczków i skomputeryzowana podprocedura lokalizacji zainstalowana w samej \
		jednostce sterującej skafandra; pozwala mu latać z prędkością autostradową, korzystając z blokad dostępu skafandra \
		do nawigacji po stacji, i odnaleźć drugą część systemu: \
		implant nawigacyjny wszczepiany u podstawy kręgosłupa użytkownika, \
		który nadaje jego położenie do skafandra i pozwala w każdej chwili przywołać go do siebie. \
		Implant jest przechowywany w module i trzeba go wstrzyknąć człowiekowi, żeby działał. \
		Nakamura Engineering zarzeka się, że są hamulce aerodynamiczne."
	icon_state = "pathfinder"
	complexity = 1
	module_type = MODULE_USABLE
	use_power_cost = DEFAULT_CHARGE_DRAIN * 10
	incompatible_modules = list(/obj/item/mod/module/pathfinder)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	/// The pathfinding implant.
	var/obj/item/implant/mod/implant
	/// Whether your modsuit will cheat on you instead of returning.
	var/faithful_return = FALSE

/obj/item/mod/module/pathfinder/plus
	name = "moduł nawigatora+ MOD"
	desc = "Ten zmodyfikowany moduł nawigatora, oparty na projekcie Nakamura Engineering, \
		DonkCo przerobiło, dodając pole porażające, które gwarantuje \
		niedoszłym złodziejom paskudną niespodziankę, a właścicielowi szybki powrót skafandra."

	faithful_return = TRUE

/obj/item/mod/module/pathfinder/Initialize(mapload)
	. = ..()
	implant = new(src)

/obj/item/mod/module/pathfinder/Destroy()
	QDEL_NULL(implant)
	return ..()

/obj/item/mod/module/pathfinder/Exited(atom/movable/gone, direction)
	if(gone == implant)
		implant = null
		update_icon_state()
	return ..()

/obj/item/mod/module/pathfinder/update_icon_state()
	. = ..()
	icon_state = implant ? "pathfinder" : "pathfinder_empty"

/obj/item/mod/module/pathfinder/examine(mob/user)
	. = ..()
	if(implant)
		. += span_notice("Użyj go na człowieku, by mu go wszczepić.")
	else
		. += span_warning("Brakuje implantu.")

/obj/item/mod/module/pathfinder/attack(mob/living/target, mob/living/user, params)
	if(!ishuman(target) || !implant)
		return
	if(!do_after(user, 1.5 SECONDS, target = target))
		balloon_alert(user, "przerwano!")
		return
	if(!implant.implant(target, user))
		balloon_alert(user, "nie da się wszczepić!")
		return
	if(target == user)
		to_chat(user, span_notice("Wszczepiasz sobie: [implant]."))
	else
		target.visible_message(span_notice("[user] wszczepia implant: [target]."), span_notice("[user] wszczepia ci: [implant]."))
	playsound(src, 'sound/effects/spray.ogg', 30, TRUE, -6)

/obj/item/mod/module/pathfinder/proc/attach(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	if(human_user.get_item_by_slot(mod.slot_flags) && !human_user.dropItemToGround(human_user.get_item_by_slot(mod.slot_flags)))
		return
	if(!human_user.equip_to_slot_if_possible(mod, mod.slot_flags, qdel_on_fail = FALSE, disable_warning = TRUE))
		return
	mod.quick_deploy(user)
	human_user.update_action_buttons(TRUE)
	balloon_alert(human_user, "podłączono: [mod]")
	playsound(mod, 'sound/machines/ping.ogg', 50, TRUE)
	drain_power(use_power_cost)
	module_type = MODULE_PASSIVE

/obj/item/mod/module/pathfinder/on_use()
	. = ..()
	if (!ishuman(mod.wearer) || !implant)
		return
	if(!implant.implant(mod.wearer, mod.wearer))
		balloon_alert(mod.wearer, "nie da się wszczepić!")
		return
	balloon_alert(mod.wearer, "wszczepiono")
	playsound(src, 'sound/effects/spray.ogg', 30, TRUE, -6)
	module_type = MODULE_PASSIVE
	var/datum/action/item_action/mod/pinned_module/existing_action = pinned_to[REF(mod.wearer)]
	if(existing_action)
		//mod.remove_item_action(existing_action)
		qdel(existing_action)

/obj/item/implant/mod
	name = "implant nawigatora MOD"
	desc = "Pozwala w każdej chwili przywołać do siebie MODsuit."
	actions_types = list(/datum/action/item_action/mod_recall)
	/// The pathfinder module we are linked to.
	var/obj/item/mod/module/pathfinder/module
	/// The jet icon we apply to the MOD.
	var/image/jet_icon

/obj/item/implant/mod/Initialize(mapload)
	. = ..()
	if(!istype(loc, /obj/item/mod/module/pathfinder))
		return INITIALIZE_HINT_QDEL
	module = loc
	jet_icon = image(icon = 'icons/obj/clothing/modsuit/mod_modules.dmi', icon_state = "mod_jet", layer = LOW_ITEM_LAYER)

/obj/item/implant/mod/Destroy()
	if(module?.mod?.ai_controller)
		end_recall(successful = FALSE)
	module = null
	jet_icon = null
	return ..()

/obj/item/implant/mod/get_data()
	var/dat = {"<b>Specyfikacja implantu:</b><BR>
				<b>Nazwa:</b> Implant nawigatora Nakamura Engineering<BR>
				<b>Szczegóły implantu:</b> pozwala posiadaczowi implantu w każdej chwili przywołać Modularne Urządzenie Zewnętrzne.<BR>"}
	return dat

/obj/item/implant/mod/proc/recall()
	if(!module?.mod)
		balloon_alert(imp_in, "brak połączonej jednostki!")
		return FALSE
	if(module.mod.open)
		balloon_alert(imp_in, "pokrywa otwarta!")
		return FALSE
	if(module.mod.ai_controller)
		balloon_alert(imp_in, "już się porusza!")
		return FALSE
	if(ismob(get_atom_on_turf(module.mod)))
		var/mob/living/carbon/carrying_mob = get_atom_on_turf(module.mod)
		if(carrying_mob == imp_in)
			balloon_alert(imp_in, "już jest na użytkowniku!")
			return FALSE
		if(!module.faithful_return)
			balloon_alert(imp_in, "już jest na kimś!")
			return FALSE //Someone is in the suit, but our suit doesn't love us
		check_recall_mob() //The suit is stolen, and is faithful to us
		return FALSE
	//balloon_alert(imp_in, "check returned TRUE!")
	if(module.z != z || get_dist(imp_in, module.mod) > MOD_AI_RANGE)
		balloon_alert(imp_in, "za daleko!")
		return FALSE
	var/datum/ai_controller/mod_ai = new /datum/ai_controller/mod(module.mod)
	module.mod.ai_controller = mod_ai
	mod_ai.current_movement_target = imp_in
	mod_ai.blackboard[BB_MOD_TARGET] = imp_in
	mod_ai.blackboard[BB_MOD_IMPLANT] = src
	module.mod.interaction_flags_item &= ~INTERACT_ITEM_ATTACK_HAND_PICKUP
	module.mod.movement_type |= FLYING
	animate(module.mod, 0.2 SECONDS, pixel_x = base_pixel_y, pixel_y = base_pixel_y)
	module.mod.add_overlay(jet_icon)
	RegisterSignal(module.mod, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	balloon_alert(imp_in, "skafander przywołany")
	return TRUE

/obj/item/implant/mod/proc/check_recall_mob()
	balloon_alert(imp_in, "środki zaradcze za 3 sekundy.")
	var/mob/living/carbon/carrying_mob = get_atom_on_turf(module.mod)
	balloon_alert(carrying_mob, "uruchamianie środków zaradczych!")
	playsound(carrying_mob, 'sound/creatures/guarddeath2.ogg', 50, TRUE)
	addtimer(CALLBACK(src, PROC_REF(recall_zap_thief), carrying_mob), 3 SECONDS)
	//return FALSE //We zapped them, but its still not valid until the modsuit is actually dropped

/obj/item/implant/mod/proc/recall_zap_thief(var/mob/living/carrying_mob)
	if(!ismob(get_atom_on_turf(module.mod)))
		return FALSE //They dropped it
	carrying_mob.Paralyze(5 SECONDS)
	carrying_mob?.dropItemToGround(module.mod)
	recall()

/obj/item/implant/mod/proc/end_recall(successful = TRUE)
	if(!module?.mod)
		return
	QDEL_NULL(module.mod.ai_controller)
	module.mod.interaction_flags_item |= INTERACT_ITEM_ATTACK_HAND_PICKUP
	module.mod.movement_type &= ~FLYING
	module.mod.cut_overlay(jet_icon)
	module.mod.transform = matrix()
	UnregisterSignal(module.mod, COMSIG_MOVABLE_MOVED)
	if(!successful)
		balloon_alert(imp_in, "skafander stracił połączenie!")
	else
		balloon_alert(imp_in, "Tęskniłem za tobą!")

/obj/item/implant/mod/proc/on_move(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	var/matrix/mod_matrix = matrix()
	mod_matrix.Turn(get_angle(source, imp_in))
	source.transform = mod_matrix

/datum/action/item_action/mod_recall
	name = "Przywołaj MOD"
	desc = "Przywołuje MODsuit wszędzie i zawsze."
	check_flags = AB_CHECK_CONSCIOUS
	background_icon_state = "bg_mod"
	icon_icon = 'icons/mob/actions/actions_mod.dmi'
	button_icon_state = "recall"
	/// The cooldown for the recall.
	COOLDOWN_DECLARE(recall_cooldown)

/datum/action/item_action/mod_recall/New(Target)
	..()
	if(!istype(Target, /obj/item/implant/mod))
		qdel(src)
		return

/datum/action/item_action/mod_recall/Trigger(trigger_flags)
	if(!IsAvailable())
		return FALSE
	var/obj/item/implant/mod/implant = target
	if(!COOLDOWN_FINISHED(src, recall_cooldown))
		implant.balloon_alert(implant.imp_in, "odnawia się!")
		return
	if(implant.recall())
		COOLDOWN_START(src, recall_cooldown, 15 SECONDS)
