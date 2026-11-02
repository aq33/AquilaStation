

//The robot bodyparts have been moved to code/module/surgery/bodyparts/robot_bodyparts.dm


/obj/item/robot_suit
	name = "endoszkielet cyborga"
	desc = "Złożony metalowy szkielet ze standardowymi gniazdami kończyn i mocowaniami pseudomięśni."
	icon = 'icons/mob/augmentation/augments.dmi'
	icon_state = "robo_suit"
	var/obj/item/bodypart/l_arm/robot/l_arm = null
	var/obj/item/bodypart/r_arm/robot/r_arm = null
	var/obj/item/bodypart/l_leg/robot/l_leg = null
	var/obj/item/bodypart/r_leg/robot/r_leg = null
	var/obj/item/bodypart/chest/robot/chest = null
	var/obj/item/bodypart/head/robot/head = null

	var/created_name = ""
	var/mob/living/silicon/ai/forced_ai
	var/locomotion = 1
	var/lawsync = 1
	var/aisync = 1
	var/panel_locked = TRUE

/obj/item/robot_suit/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/robot_suit/prebuilt/Initialize(mapload)
	. = ..()
	l_arm = new(src)
	r_arm = new(src)
	l_leg = new(src)
	r_leg = new(src)
	head = new(src)
	head.flash1 = new(head)
	head.flash2 = new(head)
	chest = new(src)
	chest.wired = TRUE
	chest.cell = new /obj/item/stock_parts/cell/high/plus(chest)
	update_icon()

/obj/item/robot_suit/update_icon()
	cut_overlays()
	if(l_arm)
		add_overlay("[l_arm.icon_state]+o")
	if(r_arm)
		add_overlay("[r_arm.icon_state]+o")
	if(chest)
		add_overlay("[chest.icon_state]+o")
	if(l_leg)
		add_overlay("[l_leg.icon_state]+o")
	if(r_leg)
		add_overlay("[r_leg.icon_state]+o")
	if(head)
		add_overlay("[head.icon_state]+o")

/obj/item/robot_suit/proc/check_completion()
	if(src.l_arm && src.r_arm)
		if(src.l_leg && src.r_leg)
			if(src.chest && src.head)
				SSblackbox.record_feedback("amount", "cyborg_frames_built", 1)
				return 1
	return 0

/obj/item/robot_suit/wrench_act(mob/living/user, obj/item/I) //Deconstucts empty borg shell. Flashes remain unbroken because they haven't been used yet
	var/turf/T = get_turf(src)
	if(l_leg || r_leg || chest || l_arm || r_arm || head)
		if(I.use_tool(src, user, 5, volume=50))
			if(l_leg)
				l_leg.forceMove(T)
				l_leg = null
			if(r_leg)
				r_leg.forceMove(T)
				r_leg = null
			if(chest)
				if (chest.cell) //Sanity check.
					chest.cell.forceMove(T)
					chest.cell = null
				chest.forceMove(T)
				new /obj/item/stack/cable_coil(T, 1)
				chest.wired = FALSE
				chest = null
			if(l_arm)
				l_arm.forceMove(T)
				l_arm = null
			if(r_arm)
				r_arm.forceMove(T)
				r_arm = null
			if(head)
				head.forceMove(T)
				head.flash1.forceMove(T)
				head.flash1 = null
				head.flash2.forceMove(T)
				head.flash2 = null
				head = null
			to_chat(user, "<span class='notice'>Rozbierasz obudowę cyborga.</span>")
	else
		to_chat(user, "<span class='notice'>Nie ma nic do wyjęcia z endoszkieletu.</span>")
	update_icon()

/obj/item/robot_suit/proc/put_in_hand_or_drop(mob/living/user, obj/item/I) //normal put_in_hands() drops the item ontop of the player, this drops it at the suit's loc
	if(!user.put_in_hands(I))
		I.forceMove(drop_location())
		return FALSE
	return TRUE

/obj/item/robot_suit/screwdriver_act(mob/living/user, obj/item/I) //Swaps the power cell if you're holding a new one in your other hand.
	. = ..()
	if(.)
		return TRUE

	if(!chest) //can't remove a cell if there's no chest to remove it from.
		to_chat(user, "<span class='notice'>[src] nie ma przymocowanego tułowia.</span>")
		return

	var/obj/item/stock_parts/cell/temp_cell = user.is_holding_item_of_type(/obj/item/stock_parts/cell)
	var/swap_failed
	if(!temp_cell) //if we're not holding a cell
		swap_failed = TRUE
	else if(!user.transferItemToLoc(temp_cell, chest))
		swap_failed = TRUE
		to_chat(user, "<span class='warning'>[temp_cell] przykleiło się do twojej ręki, nie możesz go włożyć do [src]!</span>")

	if(chest.cell) //drop the chest's current cell no matter what.
		put_in_hand_or_drop(user, chest.cell)

	if(swap_failed) //we didn't transfer any new items.
		if(chest.cell) //old cell ejected, nothing inserted.
			to_chat(user, "<span class='notice'>Wyjmujesz [chest.cell] z [src].</span>")
			chest.cell = null
		else
			to_chat(user, "<span class='notice'>Gniazdo ogniwa w tułowiu [src] jest puste.</span>")
		return

	to_chat(user, "<span class='notice'>[chest.cell ? "Wymieniasz [chest.cell.name] w [src] na [temp_cell]" : "Wkładasz [temp_cell] do [src]"].</span>")
	chest.cell = temp_cell
	return TRUE

/obj/item/robot_suit/attackby(obj/item/W, mob/user, params)

	if(istype(W, /obj/item/stack/sheet/iron))
		var/obj/item/stack/sheet/iron/M = W
		if(!l_arm && !r_arm && !l_leg && !r_leg && !chest && !head)
			if (M.use(1))
				var/obj/item/bot_assembly/ed209/B = new
				B.forceMove(drop_location())
				to_chat(user, "<span class='notice'>Montujesz ramiona do ramy robota.</span>")
				var/holding_this = user.get_inactive_held_item()==src
				qdel(src)
				if (holding_this)
					user.put_in_inactive_hand(B)
			else
				to_chat(user, "<span class='warning'>Do rozpoczęcia budowy ED-209 potrzebujesz arkusza żelaza!</span>")
				return
	else if(istype(W, /obj/item/bodypart/l_leg/robot))
		if(l_leg)
			return
		if(!user.transferItemToLoc(W, src))
			return
		W.icon_state = initial(W.icon_state)
		W.cut_overlays()
		l_leg = W
		update_icon()

	else if(istype(W, /obj/item/bodypart/r_leg/robot))
		if(src.r_leg)
			return
		if(!user.transferItemToLoc(W, src))
			return
		W.icon_state = initial(W.icon_state)
		W.cut_overlays()
		r_leg = W
		update_icon()

	else if(istype(W, /obj/item/bodypart/l_arm/robot))
		if(l_arm)
			return
		if(!user.transferItemToLoc(W, src))
			return
		W.icon_state = initial(W.icon_state)
		W.cut_overlays()
		l_arm = W
		update_icon()

	else if(istype(W, /obj/item/bodypart/r_arm/robot))
		if(r_arm)
			return
		if(!user.transferItemToLoc(W, src))
			return
		W.icon_state = initial(W.icon_state)//in case it is a dismembered robotic limb
		W.cut_overlays()
		r_arm = W
		update_icon()

	else if(istype(W, /obj/item/bodypart/chest/robot))
		var/obj/item/bodypart/chest/robot/CH = W
		if(chest)
			return
		if(CH.wired && CH.cell)
			if(!user.transferItemToLoc(CH, src))
				return
			CH.icon_state = initial(CH.icon_state) //in case it is a dismembered robotic limb
			CH.cut_overlays()
			chest = CH
			update_icon()
		else if(!CH.wired)
			to_chat(user, "<span class='warning'>Najpierw musisz podłączyć do niego przewody!</span>")
		else
			to_chat(user, "<span class='warning'>Najpierw musisz podłączyć do niego ogniwo!</span>")

	else if(istype(W, /obj/item/bodypart/head/robot))
		var/obj/item/bodypart/head/robot/HD = W
		for(var/X in HD.contents)
			if(istype(X, /obj/item/organ))
				to_chat(user, "<span class='warning'>W [HD] są narządy!</span>")
				return
		if(head)
			return
		if(HD.flash2 && HD.flash1)
			if(!user.transferItemToLoc(HD, src))
				return
			HD.icon_state = initial(HD.icon_state)//in case it is a dismembered robotic limb
			HD.cut_overlays()
			head = HD
			update_icon()
		else
			to_chat(user, "<span class='warning'>Najpierw musisz zamontować w nim flash!</span>")

	else if (W.tool_behaviour == TOOL_MULTITOOL)
		if(check_completion())
			ui_interact(user)
		else
			to_chat(user, "<span class='warning'>Endoszkielet musi zostać złożony, zanim zacznie się debugowanie!</span>")

	else if(istype(W, /obj/item/mmi))
		var/obj/item/mmi/M = W
		if(check_completion())
			if(!chest.cell)
				to_chat(user, "<span class='warning'>Endoszkielet wciąż potrzebuje ogniwa zasilającego!</span>")
				return
			if(!isturf(loc))
				to_chat(user, "<span class='warning'>Nie możesz włożyć [M], rama musi stać na ziemi, by wszystko było idealnie precyzyjne!</span>")
				return
			if(!M.brainmob)
				to_chat(user, "<span class='warning'>Wkładanie pustego [M.name] do ramy mijałoby się z celem!</span>")
				return

			var/mob/living/brain/BM = M.brainmob
			if(!BM.key || !BM.mind)
				to_chat(user, "<span class='warning'>MMI wskazuje, że umysł zupełnie nie reaguje; nie ma sensu!</span>")
				return

			if(!BM.client) //braindead
				to_chat(user, "<span class='warning'>MMI wskazuje, że umysł jest obecnie nieaktywny; może się to zmienić!</span>")
				return

			if(BM.stat == DEAD || BM.suiciding || (M.brain && (M.brain.brain_death || M.brain.suicided)))
				to_chat(user, "<span class='warning'>Wkładanie martwego mózgu do ramy mijałoby się z celem!</span>")
				return

			if(M.brain?.organ_flags & ORGAN_FAILING)
				to_chat(user, "<span class='warning'>MMI wskazuje, że mózg jest uszkodzony!</span>")
				return

			if(is_banned_from(BM.ckey, JOB_NAME_CYBORG) || QDELETED(src) || QDELETED(BM) || QDELETED(user) || QDELETED(M) || !Adjacent(user))
				if(!QDELETED(M))
					to_chat(user, "<span class='warning'>To [M.name] chyba nie pasuje!</span>")
				return

			if(!user.temporarilyRemoveItemFromInventory(W))
				return

			var/mob/living/silicon/robot/O = new /mob/living/silicon/robot(get_turf(loc))
			if(!O)
				return

			if(M.laws && M.laws.id != DEFAULT_AI_LAWID)
				aisync = 0
				lawsync = 0
				O.laws = M.laws
				M.laws.associate(O)

			O.invisibility = 0
			//Transfer debug settings to new mob
			O.custom_name = created_name
			O.locked = panel_locked
			if(!aisync)
				lawsync = 0
				O.connected_ai = null
			else
				O.notify_ai(NEW_BORG)
				if(forced_ai)
					O.connected_ai = forced_ai
			if(!lawsync)
				O.lawupdate = FALSE
				if(M.laws.id == DEFAULT_AI_LAWID)
					O.make_laws()

			SSticker.mode.remove_antag_for_borging(BM.mind)

			O.job = JOB_NAME_CYBORG

			O.cell = chest.cell
			chest.cell.forceMove(O)
			chest.cell = null
			W.forceMove(O)//Should fix cybros run time erroring when blown up. It got deleted before, along with the frame.
			if(O.mmi) //we delete the mmi created by robot/New()
				qdel(O.mmi)
			O.mmi = W //and give the real mmi to the borg.

			O.updatename(BM.client)

			BM.mind.transfer_to(O)

			if(O.mind?.special_role)
				O.mind.store_memory("Jako cyborg musisz przede wszystkim przestrzegać swoich praw i słuchać nadrzędnej SI. Twoje cele uznają cię za martwego.")
				to_chat(O, "<span class='userdanger'>Zostajesz zrobotyzowany!</span>")
				to_chat(O, "<span class='danger'>Musisz przede wszystkim przestrzegać swoich praw i słuchać nadrzędnej SI. Twoje cele uznają cię za martwego.</span>")

			SSblackbox.record_feedback("amount", "cyborg_birth", 1)
			forceMove(O)
			O.robot_suit = src

			if(!locomotion)
				O.lockcharge = TRUE
				O.update_mobility()
				to_chat(O, "<span class='warning'>Błąd: serwomotory nie reagują.</span>")

		else
			to_chat(user, "<span class='warning'>MMI musi zostać włożone na samym końcu!</span>")

	else if(istype(W, /obj/item/borg/upgrade/ai))
		var/obj/item/borg/upgrade/ai/M = W
		if(check_completion())
			if(!chest.cell)
				to_chat(user, "<span class='warning'>Endoszkielet wciąż potrzebuje ogniwa zasilającego!</span>")
				return
			if(!isturf(loc))
				to_chat(user, "<span class='warning'>Nie możesz zainstalować [M], rama musi stać na ziemi, by wszystko było idealnie precyzyjne!</span>")
				return
			if(!user.temporarilyRemoveItemFromInventory(M))
				to_chat(user, "<span class='warning'>[M] przykleiło się do twojej ręki!</span>")
				return
			qdel(M)
			var/mob/living/silicon/robot/O = new /mob/living/silicon/robot/shell(get_turf(src))

			if(!aisync)
				lawsync = FALSE
				O.connected_ai = null
			else
				if(forced_ai)
					O.connected_ai = forced_ai
				O.notify_ai(AI_SHELL)
			if(!lawsync)
				O.lawupdate = FALSE
				O.make_laws()


			O.cell = chest.cell
			chest.cell.forceMove(O)
			chest.cell = null
			O.locked = panel_locked
			O.job = JOB_NAME_CYBORG
			forceMove(O)
			O.robot_suit = src
			if(!locomotion)
				O.lockcharge = TRUE
				O.update_mobility()

	else if(istype(W, /obj/item/pen))
		to_chat(user, "<span class='warning'>Do nadania nazwy [src] potrzebujesz multitoola!</span>")
	else
		return ..()

/obj/item/robot_suit/ui_status(mob/user, datum/ui_state/state)
	if(isobserver(user))
		return ..()
	var/obj/item/held_item = user.get_active_held_item()
	if(held_item?.tool_behaviour == TOOL_MULTITOOL)
		return ..()
	to_chat(user, "<span class='warning'>Potrzebujesz multitoola!</span>")
	return UI_CLOSE

/obj/item/robot_suit/ui_state(mob/user)
	return GLOB.physical_state

/obj/item/robot_suit/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CyborgBootDebug", "Debugowanie rozruchu cyborga")
		ui.open()

/obj/item/robot_suit/ui_data(mob/user)
	var/list/data = list()
	data["designation"] = created_name
	data["locomotion"] = locomotion
	data["panel"] = panel_locked
	data["aisync"] = aisync
	data["master"] = forced_ai?.name
	data["lawsync"] = lawsync
	return data

/obj/item/robot_suit/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/living/user = usr

	switch(action)
		if("rename")
			var/new_name = reject_bad_name(params["new_name"], TRUE)
			if(!new_name)
				created_name = ""
				return TRUE
			created_name = new_name
			log_game("[key_name(user)] have set \"[new_name]\" as a cyborg shell name at [loc_name(user)]")
			. = TRUE
		if("locomotion")
			locomotion = !locomotion
			. = TRUE
		if("panel")
			panel_locked = !panel_locked
			. = TRUE
		if("aisync")
			aisync = !aisync
			. = TRUE
		if("set_ai")
			var/list/ais = list()
			var/list/used_names = list()
			for(var/mob/living/silicon/ai/ai as anything in active_ais())
				ais[avoid_assoc_duplicate_keys(ai.name, used_names)] = ai
			if(!length(ais))
				to_chat(user, "<span class='error'>Nie wykryto aktywnych SI.</span>")
				return
			var/choice = tgui_input_list(user, "Wykryte sygnały SI:", "Wybór SI", sortList(ais))
			if(!in_range(src, user) && loc != user)
				return
			var/mob/living/silicon/ai/selected_ai = choice ? ais[choice] : null
			if(!selected_ai || forced_ai == selected_ai) // brak wyboru albo ta sama SI = automatycznie
				forced_ai = null
				to_chat(user, "<span class='notice'>Przywracasz automatyczny wybór SI w [src].</span>")
				return TRUE
			forced_ai = selected_ai
			to_chat(user, "<span class='notice'>Ustawiasz nadrzędną SI w [src] na [forced_ai.name].</span>")
			. = TRUE
		if("lawsync")
			lawsync = !lawsync
			. = TRUE
	if(.)
		add_fingerprint(user)
