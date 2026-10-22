/*
*	PHASE EMITTERS
*/

/*
*	Basically the heart of the gun, can be upgraded.
*/
/obj/item/microfusion_phase_emitter
	name = "podstawowy emiter fazowy microfusion"
	desc = "Emiter fazowy pierwszej generacji. Serce broni i źródło wiązki."
	icon = 'aquila/icons/microfusion/microfusion_gun_attachments.dmi'
	icon_state = "phase_emitter"
	base_icon_state = "phase_emitter"
	w_class = WEIGHT_CLASS_NORMAL
	/// Max heat before it breaks
	var/max_heat = 2000
	/// Current heat level
	var/current_heat = 0
	/// Thermal throttle percentage
	var/throttle_percentage = 80
	/// How much heat it dissipates passively
	var/heat_dissipation_per_tick = 30
	/// Active cooling system
	var/cooling_system = FALSE
	/// How quickly does the active cooling system cool - 1/1 ratio of cell charge to cooling point
	var/cooling_system_rate = 30
	/// What is our dynamic integrity?
	var/integrity = 100
	/// Are we fucked?
	var/damaged = FALSE
	/// Hard ref to the gun.
	var/obj/item/gun/microfusion/parent_gun
	/// Are we "hacked" thus allowing overclocking?
	var/hacked = FALSE
	/// The fire delay this emitter adds to the gun.
	var/fire_delay = 0

/obj/item/microfusion_phase_emitter/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/microfusion_phase_emitter/Destroy()
	parent_gun = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/microfusion_phase_emitter/process(delta_time)
	if(current_heat == 0)
		return
	var/calculated_heat_dissipation_per_tick = heat_dissipation_per_tick
	if(isspaceturf(get_turf(src)))
		calculated_heat_dissipation_per_tick += PHASE_HEAT_DISSIPATION_BONUS_SPACE // Passive cooling in space boost!
	if(parent_gun)
		calculated_heat_dissipation_per_tick += parent_gun.heat_dissipation_bonus
	else
		calculated_heat_dissipation_per_tick += PHASE_HEAT_DISSIPATION_BONUS_AIR //We get some passive cooling from being out of the gun.
	if(cooling_system && parent_gun?.cell?.use(cooling_system_rate))
		calculated_heat_dissipation_per_tick += cooling_system_rate

	current_heat = clamp(current_heat - (calculated_heat_dissipation_per_tick * delta_time) * 0.5, 0, INFINITY)
	if(current_heat > max_heat)
		integrity = integrity - current_heat / 1000 * delta_time * 0.5

	process_fire_delay()

	if(integrity <= 0)
		kill()
	update_appearance()
	parent_gun?.update_appearance()

/obj/item/microfusion_phase_emitter/proc/toggle_cooling_system(mob/user)
	if(!parent_gun)
		return
	if(!cooling_system && !parent_gun.cell)
		if(user)
			to_chat(user, "<span class='warning'>Do włączenia chłodzenia potrzebne jest ogniwo.</span>")
		return

	cooling_system = !cooling_system

	if(user)
		to_chat(user, "<span class='notice'>[cooling_system ? "Włączasz" : "Wyłączasz"] układ chłodzenia.</span>")

/obj/item/microfusion_phase_emitter/multitool_act(mob/living/user, obj/item/tool)
	if(hacked)
		to_chat(user, "<span class='warning'>[src] jest już odblokowany!</span>")
		return TRUE
	to_chat(user, "<span class='notice'>Zaczynasz obchodzić zabezpieczenie przed podkręcaniem termicznym...</span>")
	if(do_after(user, 5 SECONDS, target = src))
		hacked = TRUE
		to_chat(user, "<span class='notice'>Obchodzisz zabezpieczenie przed podkręcaniem termicznym.</span>")
	return TRUE

/obj/item/microfusion_phase_emitter/proc/set_overclock(mob/living/user)
	if(!hacked)
		return
	var/new_throttle = tgui_input_number(user, "Podaj nowy próg dławienia termicznego (1-300%):", "Podkręcanie emitera fazowego", throttle_percentage, 300, 1)
	if(isnull(new_throttle) || QDELETED(src))
		return
	new_throttle = clamp(new_throttle, 1, 300)

	to_chat(user, "<span class='notice'>Próg dławienia termicznego ustawiony na: [new_throttle]%.</span>")

	if(new_throttle > 100)
		to_chat(user, "<span class='danger'>UWAGA: próg dławienia powyżej 100% może uszkodzić emiter.</span>")

	throttle_percentage = new_throttle

/obj/item/microfusion_phase_emitter/update_icon_state()
	. = ..()
	if(damaged)
		icon_state = "[base_icon_state]_damaged"
		return
	switch(get_heat_percent())
		if(40 to 69)
			icon_state = "[base_icon_state]_hot"
		if(70 to INFINITY)
			icon_state = "[base_icon_state]_critical"
		else
			icon_state = base_icon_state

/// Integrity loss and overheating slow the gun down
/obj/item/microfusion_phase_emitter/proc/process_fire_delay()
	var/fire_delay_to_add = 0
	if(integrity < 100)
		fire_delay_to_add = fire_delay_to_add + (100 - integrity) / 10

	if(current_heat > max_heat)
		fire_delay_to_add = fire_delay_to_add + (current_heat - max_heat) / 100 //Holy shit this emitter is tanking

	fire_delay = round(fire_delay_to_add, 1.45)

/obj/item/microfusion_phase_emitter/examine(mob/user)
	. = ..()
	if(damaged)
		. += "<span class='danger'>Jest nieodwracalnie uszkodzony.</span>"
	else
		. += "<span class='notice'>Wytrzymałość termiczna: [max_heat] C</span>"
		. += "<span class='notice'>Oddawanie ciepła: [heat_dissipation_per_tick] C/s</span>"
		. += "<span class='notice'>Nagrzanie: [get_heat_percent()]%</span>"
		. += "<span class='notice'>Integralność: [integrity]%</span>"
		. += "<span class='notice'>Dławienie termiczne: [throttle_percentage]%</span>"
		. += "<span class='notice'>Układ chłodzenia: [cooling_system ? "włączony, chłodzi o [cooling_system_rate] C/s" : "wyłączony"].</span>"
		if(!hacked)
			. += "<span class='notice'>Zabezpieczenie przed podkręcaniem da się obejść <b>multitoolem</b>.</span>"

/obj/item/microfusion_phase_emitter/proc/get_heat_percent()
	return round(current_heat / max_heat * 100)

/obj/item/microfusion_phase_emitter/proc/check_emitter()
	if(damaged)
		return PHASE_FAILURE_DAMAGED
	if(get_heat_percent() >= throttle_percentage)
		return PHASE_FAILURE_THROTTLE
	return SHOT_SUCCESS

/obj/item/microfusion_phase_emitter/proc/add_heat(heat_to_add)
	current_heat += heat_to_add
	update_appearance()

/obj/item/microfusion_phase_emitter/proc/kill()
	damaged = TRUE
	name = "uszkodzony [name]"
	playsound(src, 'aquila/sound/microfusion/overheat.ogg', 70)
	say("BŁĄD: utrata integralności!")
	STOP_PROCESSING(SSobj, src)

/obj/item/microfusion_phase_emitter/enhanced
	name = "ulepszony emiter fazowy microfusion"
	desc = "Emiter fazowy drugiej generacji z wytrzymalszych materiałów. Zniesie więcej ciepła, szybciej je oddaje i chłodzi, a dławienie termiczne włącza się później."
	max_heat = 2500
	throttle_percentage = 85
	heat_dissipation_per_tick = 40
	cooling_system_rate = 40
	integrity = 120
	color = "#ffffcc"

/obj/item/microfusion_phase_emitter/advanced
	name = "zaawansowany emiter fazowy microfusion"
	desc = "Emiter fazowy trzeciej generacji. Duża pojemność cieplna, lepsze oddawanie ciepła i chłodzenie, a do tego materiały wyższej klasy, więc jest trwalszy."
	max_heat = 3000
	throttle_percentage = 90
	heat_dissipation_per_tick = 50
	cooling_system_rate = 50
	integrity = 150
	color = "#99ffcc"

/obj/item/microfusion_phase_emitter/bluespace
	name = "bluespace'owy emiter fazowy microfusion"
	desc = "Emiter fazowy czwartej generacji. Trzyma ciepło w bluespace'owym ośrodku, więc pracuje chłodniej, niż pozwala na to zwykła przestrzeń. Zrobiony z samych najnowszych materiałów, najtrwalszy emiter na rynku."
	max_heat = 3500
	throttle_percentage = 95
	heat_dissipation_per_tick = 60
	cooling_system_rate = 60
	integrity = 200
	color = "#66ccff"

/obj/item/microfusion_phase_emitter/nanocarbon
	name = "nanowęglowy emiter fazowy microfusion"
	desc = "Eksperymentalny emiter fazowy z nanowęgla, najtrwalszego materiału na rynku. Mieści i oddaje ogromne ilości ciepła."
	max_heat = 15000
	throttle_percentage = 95
	heat_dissipation_per_tick = 130
	cooling_system_rate = 60
	integrity = 500
	color = "#6966ff"
