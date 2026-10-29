/obj/item/assembly/signaler
	name = "zdalny sygnalizator"
	desc = "Służy do zdalnego uruchamiania urządzeń. Zabezpieczony sygnalizator można zsynchronizować z innym, używając go na nim."
	icon_state = "signaller"
	item_state = "signaler"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	custom_materials = list(/datum/material/iron=400, /datum/material/glass=120)
	wires = WIRE_RECEIVE | WIRE_PULSE | WIRE_RADIO_PULSE | WIRE_RADIO_RECEIVE
	attachable = TRUE


	var/code = DEFAULT_SIGNALER_CODE
	var/frequency = FREQ_SIGNALER
	var/datum/radio_frequency/radio_connection
	///Holds the mind that commited suicide.
	var/datum/mind/suicider
	///Holds a reference string to the mob, decides how much of a gamer you are.
	var/suicide_mob
	var/hearing_range = 1

/obj/item/assembly/signaler/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] zjada [src]! Jeśli dostanie sygnał, umrze!</span>")
	playsound(src, 'sound/items/eatfood.ogg', 50, TRUE)
	moveToNullspace()
	suicider = user.mind
	suicide_mob = REF(user)
	return MANUAL_SUICIDE_NONLETHAL

/obj/item/assembly/signaler/proc/manual_suicide(datum/mind/suicidee)
	var/mob/living/user = suicidee.current
	if(!istype(user))
		return
	if(suicide_mob == REF(user))
		user.visible_message("<span class='suicide'>[src] w [user] odbiera sygnał, natychmiast go zabijając!</span>")
	else
		user.visible_message("<span class='suicide'>[src] w [user] odbiera sygnał, a on umiera jak prawdziwy gamer!</span>")
	user.adjustOxyLoss(200)//it sends an electrical pulse to their heart, killing them. or something.
	user.death(0)
	user.set_suicide(TRUE)
	user.suicide_log()
	playsound(user, 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
	qdel(src)

/obj/item/assembly/signaler/Initialize(mapload)
	. = ..()
	set_frequency(frequency)

/obj/item/assembly/signaler/Destroy()
	SSradio.remove_object(src,frequency)
	suicider = null
	. = ..()

/obj/item/assembly/signaler/activate()
	if(!..())//cooldown processing
		return FALSE
	signal()
	return TRUE

/obj/item/assembly/signaler/update_icon()
	if(holder)
		holder.update_icon()
	return

/obj/item/assembly/signaler/ui_status(mob/user)
	if(is_secured(user))
		return ..()
	return UI_CLOSE


/obj/item/assembly/signaler/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/assembly/signaler/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Signaler")
		ui.open()

/obj/item/assembly/signaler/ui_data(mob/user)
	var/list/data = list()
	data["frequency"] = frequency
	data["code"] = code
	data["minFrequency"] = MIN_FREE_FREQ
	data["maxFrequency"] = MAX_FREE_FREQ
	data["connection"] = !!radio_connection
	return data

/obj/item/assembly/signaler/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("signal")
			INVOKE_ASYNC(src, PROC_REF(signal))
			. = TRUE
		if("freq")
			var/new_frequency = sanitize_frequency(unformat_frequency(params["freq"]), TRUE)
			set_frequency(new_frequency)
			. = TRUE
		if("code")
			code = text2num(params["code"])
			code = round(code)
			. = TRUE
		if("reset")
			if(params["reset"] == "freq")
				frequency = initial(frequency)
			else
				code = initial(code)
			. = TRUE

	if(.)
		update_icon()

/obj/item/assembly/signaler/attackby(obj/item/W, mob/user, params)
	if(issignaler(W))
		var/obj/item/assembly/signaler/signaler2 = W
		if(secured && signaler2.secured)
			code = signaler2.code
			set_frequency(signaler2.frequency)
			to_chat(user, "Przenosisz częstotliwość i kod z [signaler2.name] do [name].")
			ui_update()
	..()

/obj/item/assembly/signaler/proc/signal()
	if(!radio_connection)
		return

	var/datum/signal/signal = new(list("code" = code))
	radio_connection.post_signal(src, signal)

	var/time = time2text(world.realtime,"hh:mm:ss")
	var/turf/T = get_turf(src)
	if(usr)
		GLOB.lastsignalers.Add("[time] <B>:</B> [usr.key] użył: [src] @ położenie ([T.x],[T.y],[T.z]) <B>:</B> częstotliwość: [format_frequency(frequency)]/[code]")
		log_telecomms("[time] <B>:</B> [usr.key] used [src] @ location [AREACOORD(T)] <B>:</B> with frequency: [format_frequency(frequency)]/[code]")
		message_admins("<B>:</B> [usr.key] użył: [src] @ położenie [AREACOORD(T)] <B>:</B> częstotliwość: [format_frequency(frequency)]/[code]")

/obj/item/assembly/signaler/receive_signal(datum/signal/signal)
	. = FALSE
	if(!signal)
		return
	if(signal.data["code"] != code)
		return
	if(!(src.wires & WIRE_RADIO_RECEIVE))
		return
	if(suicider)
		manual_suicide(suicider)
		return
	pulse(TRUE)
	audible_message("[icon2html(src, hearers(src))] *bip* *bip* *bip*", null, hearing_range)
	playsound(get_turf(src), 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
	return TRUE

/obj/item/assembly/signaler/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_SIGNALER)

// Embedded signaller used in grenade construction.
// It's necessary because the signaler doens't have an off state.
// Generated during grenade construction.  -Sayu
/obj/item/assembly/signaler/receiver
	var/on = FALSE

/obj/item/assembly/signaler/receiver/proc/toggle_safety()
	on = !on

/obj/item/assembly/signaler/receiver/activate()
	toggle_safety()
	return TRUE

/obj/item/assembly/signaler/receiver/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Odbiornik radiowy jest [on?"włączony":"wyłączony"].</span>"

/obj/item/assembly/signaler/receiver/receive_signal(datum/signal/signal)
	if(!on)
		return
	return ..(signal)

// Embedded signaller used in anomalies.
/obj/item/assembly/signaler/anomaly
	name = "rdzeń anomalii"
	desc = "Zneutralizowany rdzeń anomalii. Pewnie przydałby się do badań."
	icon_state = "anomaly core"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	resistance_flags = FIRE_PROOF
	var/anomaly_type = /obj/effect/anomaly

/obj/item/assembly/signaler/anomaly/receive_signal(datum/signal/signal)
	if(!signal)
		return FALSE
	if(signal.data["code"] != code)
		return FALSE
	if(suicider)
		manual_suicide(suicider)
	for(var/obj/effect/anomaly/A in get_turf(src))
		A.anomalyNeutralize()
	return TRUE

/obj/item/assembly/signaler/anomaly/manual_suicide(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[src] w [user] reaguje na sygnał radiowy, wykrzywiając jego ciało!</span>")
	user.set_suicide(TRUE)
	user.suicide_log()
	user.gib()

/obj/item/assembly/signaler/anomaly/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_ANALYZER)
		to_chat(user, "<span class='notice'>Analiza... Ustabilizowane pole [src] oscyluje na częstotliwości [format_frequency(frequency)], kod [code].</span>")
	..()

//Anomaly cores
/obj/item/assembly/signaler/anomaly/pyro
	name = "\improper rdzeń anomalii piroklastycznej"
	desc = "Zneutralizowany rdzeń anomalii piroklastycznej. Jest ciepły w dotyku. Pewnie przydałby się do badań."
	icon_state = "pyro core"
	anomaly_type = /obj/effect/anomaly/pyro

/obj/item/assembly/signaler/anomaly/grav
	name = "\improper rdzeń anomalii grawitacyjnej"
	desc = "Zneutralizowany rdzeń anomalii grawitacyjnej. Wydaje się dużo cięższy, niż wygląda. Pewnie przydałby się do badań."
	icon_state = "grav core"
	anomaly_type = /obj/effect/anomaly/grav

/obj/item/assembly/signaler/anomaly/flux
	name = "\improper rdzeń anomalii strumienia"
	desc = "Zneutralizowany rdzeń anomalii strumienia. Gdy go dotykasz, mrowi cię skóra. Pewnie przydałby się do badań."
	icon_state = "flux core"
	anomaly_type = /obj/effect/anomaly/flux

/obj/item/assembly/signaler/anomaly/bluespace
	name = "\improper rdzeń anomalii bluespace"
	desc = "Zneutralizowany rdzeń anomalii bluespace. Raz po raz znika i pojawia się z powrotem. Pewnie przydałby się do badań."
	icon_state = "anomaly core"
	anomaly_type = /obj/effect/anomaly/bluespace

/obj/item/assembly/signaler/anomaly/vortex
	name = "\improper rdzeń anomalii wirowej"
	desc = "Zneutralizowany rdzeń anomalii wirowej. Nie chce leżeć spokojnie, jakby działała na niego jakaś niewidzialna siła. Pewnie przydałby się do badań."
	icon_state = "vortex core"
	anomaly_type = /obj/effect/anomaly/bhole

/obj/item/assembly/signaler/anomaly/delimber
	name = "\improper rdzeń anomalii odczłonkowującej"
	desc = "Zneutralizowany rdzeń anomalii odczłonkowującej. Wije się, jakby się ruszał. Pewnie przydałby się do badań."
	icon_state = "delimber core"
	anomaly_type = /obj/effect/anomaly/delimber

/obj/item/assembly/signaler/anomaly/hallucination
	name = "\improper rdzeń anomalii halucynacyjnej"
	desc = "Zneutralizowany rdzeń anomalii halucynacyjnej. Wydaje się poruszać, ale to pewnie twoja wyobraźnia. Pewnie przydałby się do badań."
	icon_state = "hallucination core"
	anomaly_type = /obj/effect/anomaly/hallucination

/obj/item/assembly/signaler/anomaly/attack_self()
	return

/obj/item/assembly/signaler/cyborg

/obj/item/assembly/signaler/cyborg/attackby(obj/item/W, mob/user, params)
	return
/obj/item/assembly/signaler/cyborg/screwdriver_act(mob/living/user, obj/item/I)
	return
