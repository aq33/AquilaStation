// Okna dozownika napojów i dozownika alkoholi w formie urządzeń (port pomysłu polonium14/polonium-station#1301).
// Klawisze napojów w kolorze napoju, w dozowniku alkoholi butelki na półce, naczynie pod dyszą,
// dawki, WYLEJ i WYJMIJ oraz kartka z zawartością naczynia. Dozownik chemiczny zostaje przy starym oknie.
// Receptury i nagrywanie są tylko w starym oknie: klawisz KLASYCZNE je otwiera.

/// Napoje gazowane: w strumieniu widać bąbelki
#define AQ_BAR_FIZZY list(\
	/datum/reagent/consumable/space_cola,\
	/datum/reagent/consumable/spacemountainwind,\
	/datum/reagent/consumable/dr_gibb,\
	/datum/reagent/consumable/space_up,\
	/datum/reagent/consumable/tonic,\
	/datum/reagent/consumable/sodawater,\
	/datum/reagent/consumable/lemon_lime,\
	/datum/reagent/consumable/pwr_game,\
	/datum/reagent/consumable/shamblers,\
	/datum/reagent/consumable/ethanol/beer,\
	/datum/reagent/consumable/ethanol/ale,\
	/datum/reagent/consumable/ethanol/hcider,\
	/datum/reagent/consumable/ethanol/thirteenloko,\
	/datum/reagent/consumable/ethanol/whiskey_cola,\
)

/obj/machinery/chem_dispenser/drinks
	/// Licznik udanych dolań (okno animuje strumień tylko na jego wzrost)
	var/aq_pour_serial = 0
	/// Identyfikator napoju z ostatniego udanego dolania
	var/aq_pour_reagent

/obj/machinery/chem_dispenser/drinks/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return
	if(aq_wants_classic_ui(user))
		return ..()
	ui = new(user, src, "BarDispenserDevice")
	ui.set_autoupdate(!user.hallucinating()) // energia
	ui.open()

/obj/machinery/chem_dispenser/drinks/ui_close(mob/user)
	. = ..()
	aq_forget_classic_ui(user)

/obj/machinery/chem_dispenser/drinks/ui_data(mob/user)
	var/list/data = ..()
	var/static/list/fizzy_types
	if(!fizzy_types)
		fizzy_types = typecacheof(AQ_BAR_FIZZY, only_root_path = TRUE)
	// Rodzaj strumienia dla każdego napoju z listy (ten sam klucz "id" co w starym oknie)
	var/list/kinds = list()
	for(var/reagent_type in dispensable_reagents)
		var/datum/reagent/reagent = GLOB.chemical_reagents_list[reagent_type]
		if(!reagent)
			continue
		var/kind = "liquid"
		if(ispath(reagent_type, /datum/reagent/consumable/ice))
			kind = "ice"
		else if(ispath(reagent_type, /datum/reagent/consumable/sugar))
			kind = "grains"
		else if(fizzy_types[reagent_type])
			kind = "fizzy"
		kinds[ckey(reagent.name)] = kind
	data["kinds"] = kinds
	data["bottles"] = istype(src, /obj/machinery/chem_dispenser/drinks/beer)
	data["powered"] = is_operational
	if(beaker)
		data["beakerName"] = capitalize(format_text(beaker.name))
		data["beakerIcon"] = pixel_device_icon(beaker)
		data["beakerColor"] = beaker.reagents.total_volume ? mix_color_from_reagents(beaker.reagents.reagent_list) : null
	var/list/colors = list()
	if(beaker)
		for(var/datum/reagent/reagent as anything in beaker.reagents.reagent_list)
			colors[reagent.name] = reagent.color
	data["beakerColors"] = colors
	data["pourSerial"] = aq_pour_serial
	data["pourReagent"] = aq_pour_reagent
	return data

/obj/machinery/chem_dispenser/drinks/ui_act(action, params)
	var/obj/item/reagent_containers/poured_into = beaker
	var/volume_before = beaker?.reagents.total_volume
	. = ..()
	// Potwierdzenie dla okna: strumień tylko wtedy, gdy do tego samego naczynia naprawdę coś doszło
	if(action == "dispense" && beaker && beaker == poured_into && beaker.reagents.total_volume > volume_before)
		aq_pour_serial++
		aq_pour_reagent = params["reagent"]
	if(.)
		return
	switch(action)
		// Klawisz STARE: stare okno z recepturami do zamknięcia go
		if("classic")
			aq_open_classic_ui(usr)
			return TRUE
		// Klawisz WYLEJ: opróżnia całe naczynie
		if("drain")
			return aq_drain()

/obj/machinery/chem_dispenser/drinks/proc/aq_drain()
	if(!beaker?.reagents.total_volume || !is_operational)
		return FALSE
	beaker.reagents.clear_reagents()
	playsound(src, 'sound/effects/slosh.ogg', 25, TRUE)
	work_animation()
	return TRUE

#undef AQ_BAR_FIZZY
