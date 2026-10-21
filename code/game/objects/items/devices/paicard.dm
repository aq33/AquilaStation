/obj/item/paicard
	name = "personal AI device"
	icon = 'icons/obj/aicards.dmi'
	icon_state = "pai"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	var/mob/living/silicon/pai/pai
	resistance_flags = FIRE_PROOF | ACID_PROOF | INDESTRUCTIBLE

/obj/item/paicard/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] smutno wpatruje się w [src]! Nie może dalej żyć bez prawdziwej ludzkiej bliskości!</span>")
	return OXYLOSS

/obj/item/paicard/Initialize(mapload)
	SSpai.pai_card_list += src
	add_overlay("pai-off")
	return ..()

/obj/item/paicard/Destroy()
	//Will stop people throwing friend pAIs into the singularity so they can respawn
	SSpai.pai_card_list -= src
	if (!QDELETED(pai))
		QDEL_NULL(pai)
	return ..()

/obj/item/paicard/attack_self(mob/user)
	if (!in_range(src, user))
		return
	ui_interact(user)

/obj/item/paicard/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/paicard/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaiCard")
		ui.open()

/obj/item/paicard/ui_data(mob/user)
	var/list/data = list()
	if(!pai)
		data["candidates"] = SSpai.get_ready_candidates_ui_data()
		data["pai"] = null
		return data
	data["pai"] = list(
		"name" = pai.name,
		"master" = pai.master,
		"dna" = pai.master_dna,
		"prime_directive" = pai.laws.zeroth,
		"laws" = pai.laws.supplied,
		"can_holo" = pai.canholo,
		"has_radio" = !!pai.radio,
		"transmit" = pai.can_transmit,
		"receive" = pai.can_receive,
		"is_master" = is_pai_master(user),
	)
	return data

/obj/item/paicard/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/mob/user = usr
	if(!user || user.stat)
		return

	if(action == "request")
		SSpai.findPAI(src, user)
		return TRUE

	if(!pai)
		if(action == "download")
			var/datum/paiCandidate/candidate = locate(params["candidate"]) in SSpai.candidates
			if(candidate)
				SSpai.download_candidate(src, candidate)
			return TRUE
		return

	if(loc != user)
		return

	switch(action)
		if("set_dna")
			if(pai.master_dna)
				return
			if(!iscarbon(user))
				to_chat(user, "<span class='warning'>Nie masz DNA albo twoje DNA jest niezgodne z tym urządzeniem!</span>")
				return
			var/mob/living/carbon/M = user
			pai.master = M.real_name
			pai.master_dna = M.dna.unique_enzymes
			to_chat(pai, "<span class='notice'>Zostajesz związany z nowym właścicielem.</span>")
			pai.laws.set_zeroth_law("Służ swojemu właścicielowi.")
			pai.emittersemicd = FALSE
			return TRUE
		if("wipe_pai")
			var/confirm = tgui_alert(user, "Czy NA PEWNO chcesz usunąć obecną osobowość? Tej operacji nie można cofnąć.", "Usunięcie osobowości", list("Tak", "Nie"))
			if(confirm != "Tak" || !pai || loc != user)
				return
			to_chat(pai, "<span class='warning'>Czujesz, jak wymykasz się rzeczywistości.</span>")
			to_chat(pai, "<span class='danger'>Bajt po bajcie tracisz poczucie własnego ja.</span>")
			to_chat(pai, "<span class='userdanger'>Opuszczają cię zdolności umysłowe.</span>")
			to_chat(pai, "<span class='rose'>oblivion... </span>")
			qdel(pai)
			return TRUE
		if("clear_zero")
			if(!is_pai_master(user))
				return
			var/confirm = tgui_alert(user, "Czy NA PEWNO chcesz usunąć dyrektywę główną tego pAI? Tej operacji nie można cofnąć.", "Usuń dyrektywę", list("Tak", "Nie"))
			if(confirm != "Tak" || !pai)
				return
			pai.laws.clear_zeroth_law()
			return TRUE
		if("toggle_radio")
			if(!pai.radio)
				return
			var/transmitting = params["option"] == "transmit" //it can't be both so if we know it's not transmitting it must be receiving.
			var/transmit_holder = (transmitting ? WIRE_TX : WIRE_RX)
			if(transmitting)
				pai.can_transmit = !pai.can_transmit
			else //receiving
				pai.can_receive = !pai.can_receive
			pai.radio.wires.cut(transmit_holder)//wires.cut toggles cut and uncut states
			transmit_holder = (transmitting ? pai.can_transmit : pai.can_receive) //recycling can be fun!
			to_chat(user, "<span class='warning'>[transmit_holder ? "Włączasz" : "Wyłączasz"] [transmitting ? "wychodzące" : "przychodzące"] transmisje radiowe swojego pAI!</span>")
			to_chat(pai, "<span class='warning'>Twój właściciel [transmit_holder ? "włączył" : "wyłączył"] twoje [transmitting ? "wychodzące" : "przychodzące"] transmisje radiowe!</span>")
			return TRUE
		if("set_laws")
			var/newlaws = stripped_multiline_input(user, "Wpisz dodatkowe dyrektywy, które ma wykonywać twoja osobowość pAI. Nie nadpiszą one lojalności osobowości wobec zapisanego właściciela. Sprzeczne dyrektywy zostaną zignorowane.", "Konfiguracja dyrektyw pAI", pai.laws.supplied[1])
			if(newlaws && pai)
				pai.add_supplied_law(0, newlaws)
			return TRUE
		if("toggle_holo")
			if(!is_pai_master(user))
				return
			if(pai.canholo)
				to_chat(pai, "<span class='userdanger'>Twój właściciel wyłączył twoje projektory holomatrycy!</span>")
				pai.canholo = FALSE
				to_chat(user, "<span class='warning'>Wyłączasz holomatrycę swojego pAI!</span>")
			else
				to_chat(pai, "<span class='boldnotice'>Twój właściciel włączył twoje projektory holomatrycy!</span>")
				pai.canholo = TRUE
				to_chat(user, "<span class='notice'>Włączasz holomatrycę swojego pAI!</span>")
			return TRUE

/// Czy użytkownik jest zapisanym właścicielem pAI (imię albo DNA)
/obj/item/paicard/proc/is_pai_master(mob/user)
	if(!pai || !ishuman(user))
		return FALSE
	var/mob/living/carbon/human/H = user
	return (H.real_name == pai.master || H.dna?.unique_enzymes == pai.master_dna)

// 		WIRE_SIGNAL = 1
//		WIRE_RECEIVE = 2
//		WIRE_TRANSMIT = 4

/obj/item/paicard/proc/setPersonality(mob/living/silicon/pai/personality)
	src.pai = personality
	src.add_overlay("pai-null")

	pai.modularInterface?.saved_identification = pai.name

	playsound(loc, 'sound/effects/pai_boot.ogg', 50, 1, -1)
	audible_message("[src] odtwarza radosny dźwięk uruchamiania!")
	SStgui.update_uis(src)

/obj/item/paicard/proc/setEmotion(emotion)
	if(pai)
		src.cut_overlays()
		switch(emotion)
			if(1)
				src.add_overlay("pai-happy")
			if(2)
				src.add_overlay("pai-cat")
			if(3)
				src.add_overlay("pai-extremely-happy")
			if(4)
				src.add_overlay("pai-face")
			if(5)
				src.add_overlay("pai-laugh")
			if(6)
				src.add_overlay("pai-off")
			if(7)
				src.add_overlay("pai-sad")
			if(8)
				src.add_overlay("pai-angry")
			if(9)
				src.add_overlay("pai-what")
			if(10)
				src.add_overlay("pai-null")
			if(11)
				src.add_overlay("pai-sunglasses")

/obj/item/paicard/proc/alertUpdate()
	var/image/I = image(icon, src, icon_state = "pai-alert")
	flick_overlay_view(I, src, 5 SECONDS)
	playsound(src, 'sound/machines/ping.ogg', 100)
	audible_message("<span class ='info'>Na ekranie [src] wyświetla się komunikat: \"Dostępne są dodatkowe osobowości do pobrania.\"</span>", "<span class='notice'>[src] wibruje, sygnalizując powiadomienie.</span>")
	SStgui.update_uis(src)

/obj/item/paicard/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(pai && !pai.holoform)
		pai.emp_act(severity)
