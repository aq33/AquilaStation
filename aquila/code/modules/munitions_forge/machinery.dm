// AQUILA - kuźnia amunicji: maszyny linii (na wzór smithingu z Paradise, code/modules/smithing).
// Tygiel (silos) -> basen odlewniczy (forma + materiał) -> młot pneumatyczny / piec indukcyjny -> monter.
// Sprite'y: ParadiseSS13/Paradise, CC BY-SA 3.0.

/obj/machinery/munitions_forge
	name = "maszyna kuźni amunicji"
	icon = 'aquila/icons/obj/munitions_forge/smithing_machines.dmi'
	icon_state = "assembler"
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF
	req_one_access = list(ACCESS_MUNITIONS)
	idle_power_usage = 50
	active_power_usage = 1000
	/// Czas jednej operacji
	var/operation_time = 5 SECONDS
	var/operating = FALSE
	/// Część obrabiana w maszynie (młot i piec)
	var/obj/item/munition_part/working_part
	var/operation_sound
	/// Nakładka przy otwartym panelu
	var/wires_overlay
	/// Co robi z głową delikwenta trzymanego za szyję
	var/special_attack_cooldown = 10 SECONDS
	COOLDOWN_DECLARE(special_attack_cd)

/// Duże maszyny (tygiel, młot, piec) zajmują kilka kafli, więc sąsiedztwo liczymy od każdego z nich.
/obj/machinery/munitions_forge/Adjacent(atom/neighbor)
	if(neighbor == loc)
		return TRUE
	for(var/turf/T in locs)
		if(T.Adjacent(neighbor, target = neighbor, mover = src))
			return TRUE
	return FALSE

/obj/machinery/munitions_forge/proc/user_can_reach(mob/living/user)
	return istype(user) && !user.incapacitated() && Adjacent(user)

/obj/machinery/munitions_forge/Destroy()
	if(working_part)
		working_part.forceMove(drop_location())
		working_part = null
	return ..()

/obj/machinery/munitions_forge/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == working_part)
		working_part = null
		update_icon()

/obj/machinery/munitions_forge/examine(mob/user)
	. = ..()
	if(working_part)
		. += "<span class='notice'>W środku jest [working_part]. Alt+klik, żeby wyjąć.</span>"

/obj/machinery/munitions_forge/screwdriver_act(mob/living/user, obj/item/I)
	if(operating)
		to_chat(user, "<span class='warning'>[src] jeszcze pracuje!</span>")
		return TRUE
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		update_icon()
		return TRUE

/obj/machinery/munitions_forge/crowbar_act(mob/living/user, obj/item/I)
	if(operating)
		return TRUE
	if(default_deconstruction_crowbar(I))
		return TRUE

/obj/machinery/munitions_forge/update_overlays()
	. = ..()
	if(panel_open && wires_overlay)
		. += wires_overlay

/// Czy maszyna przyjmuje tę część do working_part
/obj/machinery/munitions_forge/proc/accepts_part(obj/item/munition_part/part)
	return FALSE

/obj/machinery/munitions_forge/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/munition_part) && accepts_part(I))
		if(operating)
			to_chat(user, "<span class='warning'>[src] jeszcze pracuje!</span>")
			return TRUE
		if(!user.transferItemToLoc(I, src))
			to_chat(user, "<span class='warning'>[I] przywarło ci do ręki!</span>")
			return TRUE
		var/obj/item/munition_part/old_part = working_part
		working_part = I
		if(old_part)
			old_part.hand_over(user)
			to_chat(user, "<span class='notice'>Zamieniasz [old_part] na [I] w [src].</span>")
		else
			to_chat(user, "<span class='notice'>Wkładasz [I] do [src].</span>")
		update_icon()
		return TRUE
	return ..()

/obj/machinery/munitions_forge/AltClick(mob/living/user)
	if(!user_can_reach(user))
		return
	if(operating)
		to_chat(user, "<span class='warning'>[src] jeszcze pracuje!</span>")
		return
	if(!working_part)
		to_chat(user, "<span class='notice'>W [src] nic nie ma.</span>")
		return
	var/obj/item/munition_part/part = working_part
	working_part = null
	part.hand_over(user)
	update_icon()

/obj/machinery/munitions_forge/interact(mob/living/user)
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Brak dostępu.</span>")
		return
	if(isliving(user.pulling) && user.grab_state >= GRAB_NECK && Adjacent(user.pulling))
		try_special_attack(user, user.pulling)
		return
	start_operation(user)

/// Sprawdza, czy można zacząć; sama wypisuje powód odmowy.
/obj/machinery/munitions_forge/proc/can_operate(mob/user)
	if(operating)
		to_chat(user, "<span class='warning'>[src] jeszcze pracuje!</span>")
		return FALSE
	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(user, "<span class='warning'>[src] nie ma zasilania.</span>")
		return FALSE
	return TRUE

/obj/machinery/munitions_forge/proc/start_operation(mob/user)
	if(!can_operate(user))
		return FALSE
	operating = TRUE
	use_power(active_power_usage)
	if(operation_sound)
		playsound(src, operation_sound, 50, TRUE)
	update_icon()
	addtimer(CALLBACK(src, PROC_REF(finish_operation), user), operation_time)
	return TRUE

/obj/machinery/munitions_forge/proc/finish_operation(mob/user)
	operating = FALSE
	update_icon()
	if(QDELETED(src))
		return
	if(machine_stat & (NOPOWER|BROKEN))
		visible_message("<span class='warning'>[src] gaśnie w połowie pracy.</span>")
		return
	complete_operation(user)
	update_icon()

/// Właściwy efekt operacji
/obj/machinery/munitions_forge/proc/complete_operation(mob/user)
	return

/obj/machinery/munitions_forge/proc/try_special_attack(mob/living/user, mob/living/target)
	if(!COOLDOWN_FINISHED(src, special_attack_cd))
		return
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>Wsadzenie [target] do [src] mogłoby zrobić krzywdę!</span>")
		return
	if(!iscarbon(target))
		to_chat(user, "<span class='warning'>To się tam nie zmieści!</span>")
		return
	var/mob/living/carbon/C = target
	if(!C.get_bodypart(BODY_ZONE_HEAD))
		to_chat(user, "<span class='warning'>[C] nie ma głowy!</span>")
		return
	if(!special_attack(user, C))
		return
	COOLDOWN_START(src, special_attack_cd, special_attack_cooldown)
	user.changeNext_move(CLICK_CD_MELEE)
	log_combat(user, C, "used [src] on")

/obj/machinery/munitions_forge/proc/special_attack(mob/living/user, mob/living/carbon/target)
	return FALSE

/obj/machinery/munitions_forge/proc/ping()
	playsound(src, 'sound/machines/ping.ogg', 50, FALSE)

// ---------------------------------------------------------------- tygiel

/obj/machinery/munitions_forge/crucible
	name = "tygiel amunicji"
	desc = "Wielki tygiel połączony z silosem rudy. Topi to, czego potrzebują baseny odlewnicze obok. Multitool z buforem silosu łączy go z silosem."
	icon = 'aquila/icons/obj/munitions_forge/magma_crucible.dmi'
	icon_state = "crucible"
	wires_overlay = "crucible_wires"
	bound_width = 96
	bound_height = 96
	max_integrity = 300
	circuit = /obj/item/circuitboard/machine/munitions_crucible
	var/datum/component/remote_materials/materials
	var/pouring = FALSE

/obj/machinery/munitions_forge/crucible/Initialize(mapload)
	. = ..()
	materials = AddComponent(/datum/component/remote_materials, "munitions_forge", mapload)

/obj/machinery/munitions_forge/crucible/Destroy()
	materials = null
	return ..()

/obj/machinery/munitions_forge/crucible/proc/get_container()
	return materials?.mat_container

/obj/machinery/munitions_forge/crucible/examine(mob/user)
	. = ..()
	var/datum/component/material_container/container = get_container()
	if(!container)
		. += "<span class='warning'>Nie jest połączony z żadnym magazynem materiałów.</span>"
		return
	. += "<span class='notice'>[materials.silo ? "Połączony z silosem." : "Pracuje na własnym zapasie."] Dostępne materiały:</span>"
	for(var/key in GLOB.munition_materials)
		var/datum/munition_material/M = GLOB.munition_materials[key]
		var/amount = container.get_material_amount(M.material_type)
		if(amount)
			. += "<span class='notice'> - [M.name]: [round(amount / MINERAL_MATERIAL_AMOUNT, 0.1)] arkuszy</span>"

/obj/machinery/munitions_forge/crucible/interact(mob/living/user)
	user.examinate(src)

/obj/machinery/munitions_forge/crucible/update_icon_state()
	if(machine_stat & BROKEN)
		icon_state = "crucible_broken"
	else if(machine_stat & NOPOWER)
		icon_state = "crucible_off"
	else
		icon_state = "crucible"
	return ..()

/obj/machinery/munitions_forge/crucible/update_overlays()
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	. += pouring ? "crucible_output" : "crucible_passive"

/obj/machinery/munitions_forge/crucible/power_change()
	. = ..()
	update_icon()

/obj/machinery/munitions_forge/crucible/proc/animate_pour(duration)
	pouring = TRUE
	update_icon()
	addtimer(CALLBACK(src, PROC_REF(stop_pour)), duration, TIMER_UNIQUE | TIMER_OVERRIDE)

/obj/machinery/munitions_forge/crucible/proc/stop_pour()
	pouring = FALSE
	update_icon()

// ---------------------------------------------------------------- basen odlewniczy

/obj/machinery/munitions_forge/basin
	name = "basen odlewniczy"
	desc = "Stół z basenem na płynny metal i gniazdem na formę. Pobiera materiał z pobliskiego tygla amunicji."
	icon_state = "casting_open"
	wires_overlay = "casting_wires"
	circuit = /obj/item/circuitboard/machine/munitions_basin
	operation_time = 6 SECONDS
	operation_sound = 'sound/machines/hiss.ogg'
	var/obj/item/munition_cast/cast
	var/obj/item/munition_part/produced_part
	/// Mnożnik zużycia materiału (mniej = taniej)
	var/efficiency = 1
	/// Co wylewamy w tej operacji
	var/datum/munition_material/pending_material
	var/datum/munition_quality/pending_quality
	var/pending_product

/obj/machinery/munitions_forge/basin/Destroy()
	if(cast)
		cast.forceMove(drop_location())
		cast = null
	if(produced_part)
		produced_part.forceMove(drop_location())
		produced_part = null
	return ..()

/obj/machinery/munitions_forge/basin/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == cast)
		cast = null
		update_icon()
	else if(gone == produced_part)
		produced_part = null
		update_icon()

/obj/machinery/munitions_forge/basin/RefreshParts()
	var/rating = 0
	for(var/obj/item/stock_parts/P in component_parts)
		rating += P.rating
	// dwie części: od 2 (tier 1) do 8 (tier 4)
	operation_time = max(initial(operation_time) - (rating - 2) * 0.5 SECONDS, 2 SECONDS)
	efficiency = 1.1 - rating * 0.05

/obj/machinery/munitions_forge/basin/examine(mob/user)
	. = ..()
	if(cast)
		. += "<span class='notice'>W gnieździe jest [cast]. Alt+klik, żeby ją wyjąć.</span>"
	if(produced_part)
		. += "<span class='notice'>W basenie stygnie [produced_part]. Kliknij ręką, żeby go wyjąć.</span>"
	if(!find_crucible())
		. += "<span class='warning'>W pobliżu nie ma tygla amunicji.</span>"

/obj/machinery/munitions_forge/basin/proc/find_crucible()
	for(var/obj/machinery/munitions_forge/crucible/C in range(4, src))
		return C

/obj/machinery/munitions_forge/basin/update_overlays()
	. = ..()
	if(cast)
		. += produced_part ? "[cast.basin_state]_full" : cast.basin_state
		. += "casting_lip"
	if(operating)
		. += "casting_pour"

/obj/machinery/munitions_forge/basin/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/munition_cast))
		if(operating)
			to_chat(user, "<span class='warning'>[src] jeszcze pracuje!</span>")
			return TRUE
		if(!user.transferItemToLoc(I, src))
			return TRUE
		if(cast)
			user.put_in_hands(cast)
			to_chat(user, "<span class='notice'>Zamieniasz [cast] na [I].</span>")
		else
			to_chat(user, "<span class='notice'>Wkładasz [I] do [src].</span>")
		cast = I
		update_icon()
		return TRUE
	return ..()

/obj/machinery/munitions_forge/basin/AltClick(mob/living/user)
	if(!user_can_reach(user))
		return
	if(operating)
		to_chat(user, "<span class='warning'>[src] jeszcze pracuje!</span>")
		return
	if(produced_part)
		to_chat(user, "<span class='warning'>Najpierw wyjmij odlew.</span>")
		return
	if(!cast)
		to_chat(user, "<span class='notice'>W gnieździe nie ma formy.</span>")
		return
	user.put_in_hands(cast)
	cast = null
	update_icon()

/obj/machinery/munitions_forge/basin/interact(mob/living/user)
	if(produced_part && !operating)
		var/obj/item/munition_part/part = produced_part
		produced_part = null
		part.hand_over(user)
		update_icon()
		return
	return ..()

/obj/machinery/munitions_forge/basin/start_operation(mob/user)
	if(!can_operate(user))
		return FALSE
	if(!cast || !cast.selected_product)
		to_chat(user, "<span class='warning'>W gnieździe nie ma formy.</span>")
		return FALSE
	var/obj/machinery/munitions_forge/crucible/crucible = find_crucible()
	var/datum/component/material_container/container = crucible?.get_container()
	if(!container)
		to_chat(user, "<span class='warning'>W pobliżu nie ma działającego tygla amunicji.</span>")
		return FALSE
	if(crucible.materials.on_hold())
		to_chat(user, "<span class='warning'>Silos jest zablokowany.</span>")
		return FALSE
	var/obj/item/munition_part/product = cast.selected_product
	var/datum/munition_quality/quality = get_munition_quality(cast.quality)
	var/list/cost
	var/datum/munition_material/material
	if(ispath(product, /obj/item/munition_part/body))
		var/obj/item/munition_part/body/body_path = product
		var/base_amount = initial(body_path.material_amount) * quality.material_mult * efficiency
		var/list/choices = list()
		for(var/key in GLOB.munition_materials)
			var/datum/munition_material/M = GLOB.munition_materials[key]
			var/amount = round(base_amount * M.sheets_mult)
			if(container.has_enough_of_material(M.material_type, amount))
				choices["[M.name] ([round(amount / MINERAL_MATERIAL_AMOUNT, 0.1)] ark.)"] = M
		if(!length(choices))
			to_chat(user, "<span class='warning'>W silosie nie ma dość żadnego materiału na [initial(body_path.name)].</span>")
			return FALSE
		var/choice = tgui_input_list(user, "Z jakiego materiału odlać [initial(body_path.name)]?", name, choices)
		if(!choice || QDELETED(src) || !user_can_reach(user) || !can_operate(user) || cast?.selected_product != product)
			return FALSE
		material = choices[choice]
		cost = list()
		cost[material.material_type] = round(base_amount * material.sheets_mult)
	else
		// base_cost to lista, a initial() na listach nie działa — jak w Paradise czytamy ją z tymczasowej instancji
		var/obj/item/munition_part/temp = new product(null)
		cost = list()
		for(var/mat in temp.base_cost)
			cost[mat] = round(temp.base_cost[mat] * quality.material_mult * efficiency)
		qdel(temp)
	if(!container.has_materials(cost))
		to_chat(user, "<span class='warning'>W silosie zabrakło materiału.</span>")
		return FALSE
	container.use_materials(cost)
	crucible.materials.silo_log(src, "odlano", -1, initial(product.name), cost)
	pending_material = material
	pending_quality = quality
	pending_product = product
	crucible.animate_pour(operation_time)
	to_chat(user, "<span class='notice'>Wlewasz płynny metal do [src]...</span>")
	return ..()

/obj/machinery/munitions_forge/basin/complete_operation(mob/user)
	if(!pending_product)
		return
	var/obj/item/munition_part/part = new pending_product(src)
	if(istype(part, /obj/item/munition_part/body))
		var/obj/item/munition_part/body/body = part
		body.set_material(pending_material)
	part.cast_finished(pending_quality)
	produced_part = part
	pending_product = null
	pending_material = null
	pending_quality = null
	ping()

// ---------------------------------------------------------------- piec indukcyjny

/obj/machinery/munitions_forge/furnace
	name = "piec indukcyjny"
	desc = "Piec, który dogrzewa niedokończone odlewy, żeby dało się je dalej kuć."
	icon = 'aquila/icons/obj/munitions_forge/large_smithing_machines.dmi'
	icon_state = "furnace"
	wires_overlay = "furnace_wires"
	bound_width = 64
	bound_height = 64
	circuit = /obj/item/circuitboard/machine/munitions_furnace
	operation_time = 4 SECONDS
	operation_sound = 'sound/surgery/cautery1.ogg'
	var/heat_amount = 5

/obj/machinery/munitions_forge/furnace/RefreshParts()
	var/rating = 0
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		rating += L.rating
	// dwa lasery: 2-8
	heat_amount = 3 + rating
	operation_time = max(initial(operation_time) - (rating - 2) * 0.4 SECONDS, 2 SECONDS)

/obj/machinery/munitions_forge/furnace/accepts_part(obj/item/munition_part/part)
	return TRUE

/obj/machinery/munitions_forge/furnace/update_icon_state()
	icon_state = operating ? "furnace" : "furnace_off"
	if(machine_stat & BROKEN)
		icon_state = "furnace_broken"
	return ..()

/obj/machinery/munitions_forge/furnace/start_operation(mob/user)
	if(!working_part)
		to_chat(user, "<span class='warning'>W piecu nic nie ma.</span>")
		return FALSE
	if(working_part.is_finished())
		to_chat(user, "<span class='notice'>[working_part] jest już ukształtowany.</span>")
		return FALSE
	if(working_part.forge_heat > 10)
		to_chat(user, "<span class='notice'>[working_part] jest już dobrze rozgrzany.</span>")
		return FALSE
	return ..()

/obj/machinery/munitions_forge/furnace/complete_operation(mob/user)
	working_part?.heat_up(heat_amount)

/obj/machinery/munitions_forge/furnace/special_attack(mob/living/user, mob/living/carbon/target)
	target.visible_message("<span class='danger'>[user] wpycha głowę [target] do [src]!</span>", \
		"<span class='userdanger'>[user] wpycha ci głowę do [src]! Żar jest nie do zniesienia!</span>")
	target.apply_damage(40, BURN, BODY_ZONE_HEAD, target.run_armor_check(BODY_ZONE_HEAD, "melee"))
	target.adjust_fire_stacks(5)
	target.IgniteMob()
	target.emote("scream")
	playsound(src, operation_sound, 50, TRUE)
	return TRUE

// ---------------------------------------------------------------- młot pneumatyczny

/obj/machinery/munitions_forge/hammer
	name = "młot pneumatyczny"
	desc = "Ciężki młot do kształtowania gorących odlewów. Multitool przełącza tryb automatyczny."
	icon = 'aquila/icons/obj/munitions_forge/large_smithing_machines.dmi'
	icon_state = "power_hammer"
	wires_overlay = "hammer_wires"
	bound_width = 64
	bound_height = 64
	circuit = /obj/item/circuitboard/machine/munitions_hammer
	operation_time = 4 SECONDS
	operation_sound = 'sound/effects/clang.ogg'
	/// Tryb automatyczny: kuje, dopóki część jest gorąca i niedokończona
	var/repeating = FALSE

/obj/machinery/munitions_forge/hammer/RefreshParts()
	var/rating = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		rating += M.rating
	// dwa manipulatory: 2-8
	operation_time = max(initial(operation_time) - (rating - 2) * 0.4 SECONDS, 1.5 SECONDS)

/obj/machinery/munitions_forge/hammer/accepts_part(obj/item/munition_part/part)
	return TRUE

/obj/machinery/munitions_forge/hammer/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Tryb automatyczny jest [repeating ? "włączony" : "wyłączony"].</span>"

/obj/machinery/munitions_forge/hammer/update_icon_state()
	icon_state = (machine_stat & BROKEN) ? "hammer_broken" : "power_hammer"
	return ..()

/obj/machinery/munitions_forge/hammer/update_overlays()
	. = ..()
	if(machine_stat & BROKEN)
		return
	. += operating ? "hammer_hit" : "hammer_idle"
	if(!(machine_stat & NOPOWER))
		. += "hammer_fan_on"

/obj/machinery/munitions_forge/hammer/power_change()
	. = ..()
	update_icon()

/obj/machinery/munitions_forge/hammer/multitool_act(mob/living/user, obj/item/I)
	repeating = !repeating
	to_chat(user, "<span class='notice'>[repeating ? "Włączasz" : "Wyłączasz"] tryb automatyczny [src].</span>")
	return TRUE

/obj/machinery/munitions_forge/hammer/start_operation(mob/user)
	if(!working_part)
		to_chat(user, "<span class='warning'>Pod młotem nic nie ma.</span>")
		return FALSE
	if(working_part.is_finished())
		to_chat(user, "<span class='notice'>[working_part] jest już ukształtowany.</span>")
		return FALSE
	if(!working_part.forge_heat)
		to_chat(user, "<span class='warning'>[working_part] jest za zimny, żeby go kuć. Dogrzej go w piecu.</span>")
		return FALSE
	return ..()

/obj/machinery/munitions_forge/hammer/complete_operation(mob/user)
	if(!working_part)
		return
	working_part.hammer()
	do_sparks(3, TRUE, src)
	if(working_part.is_finished())
		ping()
		return
	if(repeating && working_part.forge_heat)
		addtimer(CALLBACK(src, PROC_REF(start_operation), user), 0.5 SECONDS)

/obj/machinery/munitions_forge/hammer/special_attack(mob/living/user, mob/living/carbon/target)
	target.visible_message("<span class='danger'>[user] wkłada głowę [target] pod [src]!</span>", \
		"<span class='userdanger'>[user] wkłada ci głowę pod [src]! Czy ktoś zapisał numer rejestracyjny?</span>")
	target.apply_damage(40, BRUTE, BODY_ZONE_HEAD, target.run_armor_check(BODY_ZONE_HEAD, "melee"))
	target.Paralyze(4 SECONDS)
	target.emote("scream")
	playsound(src, operation_sound, 50, TRUE)
	return TRUE

// ---------------------------------------------------------------- monter

/obj/machinery/munitions_forge/assembler
	name = "monter amunicji"
	desc = "Składa korpus, wypełnienie i zapalnik w gotową amunicję. Wypełnienie nie jest wymagane."
	icon_state = "assembler"
	wires_overlay = "assembler_wires"
	circuit = /obj/item/circuitboard/machine/munitions_assembler
	operation_time = 5 SECONDS
	operation_sound = 'sound/items/welder.ogg'
	var/obj/item/munition_part/body/body
	var/obj/item/munition_part/filler/filler
	var/obj/item/munition_part/fuze/fuze

/obj/machinery/munitions_forge/assembler/Destroy()
	for(var/obj/item/munition_part/part in list(body, filler, fuze))
		part.forceMove(drop_location())
	body = null
	filler = null
	fuze = null
	return ..()

/obj/machinery/munitions_forge/assembler/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == body)
		body = null
	else if(gone == filler)
		filler = null
	else if(gone == fuze)
		fuze = null

/obj/machinery/munitions_forge/assembler/RefreshParts()
	var/rating = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		rating += M.rating
	operation_time = max(initial(operation_time) - (rating - 2) * 0.5 SECONDS, 2 SECONDS)

/obj/machinery/munitions_forge/assembler/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Korpus: [body ? body : "brak"].</span>"
	. += "<span class='notice'>Wypełnienie: [filler ? filler : "brak (zwykła amunicja)"].</span>"
	. += "<span class='notice'>Zapalnik: [fuze ? fuze : "brak"].</span>"
	. += "<span class='notice'>Alt+klik wyjmuje wszystkie części.</span>"

/obj/machinery/munitions_forge/assembler/attackby(obj/item/I, mob/living/user, params)
	if(!istype(I, /obj/item/munition_part))
		return ..()
	var/obj/item/munition_part/part = I
	if(operating)
		to_chat(user, "<span class='warning'>[src] jeszcze pracuje!</span>")
		return TRUE
	if(!part.is_finished())
		to_chat(user, "<span class='warning'>[part] trzeba jeszcze dokończyć pod młotem.</span>")
		return TRUE
	if(!user.transferItemToLoc(part, src))
		return TRUE
	var/obj/item/munition_part/old_part
	if(istype(part, /obj/item/munition_part/body))
		old_part = body
		body = part
	else if(istype(part, /obj/item/munition_part/filler))
		old_part = filler
		filler = part
	else
		old_part = fuze
		fuze = part
	if(old_part)
		old_part.hand_over(user)
	to_chat(user, "<span class='notice'>Wkładasz [part] do [src].</span>")
	return TRUE

/obj/machinery/munitions_forge/assembler/AltClick(mob/living/user)
	if(!user_can_reach(user))
		return
	if(operating)
		to_chat(user, "<span class='warning'>[src] jeszcze pracuje!</span>")
		return
	var/list/parts = list(body, filler, fuze) - null
	if(!length(parts))
		to_chat(user, "<span class='notice'>W [src] nic nie ma.</span>")
		return
	for(var/obj/item/munition_part/part in parts)
		part.forceMove(drop_location())
	to_chat(user, "<span class='notice'>Wyjmujesz części z [src].</span>")

/obj/machinery/munitions_forge/assembler/start_operation(mob/user)
	if(!body)
		to_chat(user, "<span class='warning'>Brakuje korpusu.</span>")
		return FALSE
	if(!fuze)
		to_chat(user, "<span class='warning'>Brakuje zapalnika.</span>")
		return FALSE
	if(!istype(fuze, body.fuze_type))
		var/obj/item/munition_part/needed = body.fuze_type
		to_chat(user, "<span class='warning'>Do [body] pasuje [initial(needed.name)], a nie [fuze].</span>")
		return FALSE
	return ..()

/obj/machinery/munitions_forge/assembler/complete_operation(mob/user)
	if(!body || !fuze)
		return
	// Jak w Paradise: wyrób dostaje najniższą jakość ze wszystkich części
	var/datum/munition_quality/lowest = body.quality
	for(var/obj/item/munition_part/part in list(fuze, filler))
		if(part.quality.bonus < lowest.bonus)
			lowest = part.quality
	var/datum/munition_filler/filler_datum = filler ? get_munition_filler(filler.filler_type) : null
	var/list/products = body.create_product(drop_location(), lowest, filler_datum)
	SSblackbox.record_feedback("tally", "munitions_forge_production", 1, "[body.type]")
	QDEL_NULL(body)
	QDEL_NULL(fuze)
	if(filler)
		QDEL_NULL(filler)
	ping()
	if(length(products))
		visible_message("<span class='notice'>[src] wypluwa [products[1]].</span>")
