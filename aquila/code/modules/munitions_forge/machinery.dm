// AQUILA - kuźnia amunicji: maszyny linii (logika na wzór smithingu z Paradise, zestaw maszyn jak kowalstwo z Monkestation).
// Piec łukowy (silos, forma, materiał lub stop, dogrzewanie) -> kowadło (minigra) -> stół montażowy.
// Sprite'y: Monkestation/Monkestation2.0 (arc forge, kowadło, stół montażowy), CC BY-SA 3.0.

/obj/machinery/munitions_forge
	name = "maszyna kuźni amunicji"
	icon = 'aquila/icons/obj/munitions_forge/forge_structures.dmi'
	icon_state = "crafting_bench_empty"
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF
	req_one_access = list(ACCESS_MUNITIONS)
	idle_power_usage = 50
	active_power_usage = 1000
	/// Czas jednej operacji
	var/operation_time = 5 SECONDS
	var/operating = FALSE
	/// Część obrabiana w maszynie (kowadło, dogrzewanie w piecu)
	var/obj/item/munition_part/working_part
	var/operation_sound
	/// Co robi z głową delikwenta trzymanego za szyję
	var/special_attack_cooldown = 10 SECONDS
	COOLDOWN_DECLARE(special_attack_cd)

/// Piec łukowy zajmuje 3x3 kafle, więc sąsiedztwo liczymy od każdego z nich.
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
			to_chat(user, "<span class='notice'>Kładziesz [I] na [src].</span>")
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
	if(use_power && (machine_stat & (NOPOWER|BROKEN)))
		to_chat(user, "<span class='warning'>[src] nie ma zasilania.</span>")
		return FALSE
	return TRUE

/obj/machinery/munitions_forge/proc/start_operation(mob/user)
	if(!can_operate(user))
		return FALSE
	operating = TRUE
	if(use_power)
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
	if(use_power && (machine_stat & (NOPOWER|BROKEN)))
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

/// Wybór materiału albo stopu dwóch materiałów, z których starczy na odlew. amount to ilość przed mnożnikiem materiału.
/proc/choose_munition_material(mob/user, datum/component/material_container/container, amount, title, allow_alloys = TRUE)
	var/list/choices = list()
	for(var/key in GLOB.munition_materials)
		var/datum/munition_material/M = GLOB.munition_materials[key]
		var/list/cost = M.get_cost(amount)
		if(container.has_materials(cost))
			choices["[M.name] ([munition_cost_text(cost)])"] = M
	var/alloy_choice = "stop dwóch materiałów..."
	if(allow_alloys)
		choices[alloy_choice] = TRUE
	var/choice = tgui_input_list(user, "Z jakiego materiału?", title, choices)
	if(!choice)
		return null
	if(choice != alloy_choice)
		return choices[choice]
	// stop: każdy składnik idzie po połowie
	var/list/firsts = list()
	for(var/key in GLOB.munition_materials)
		var/datum/munition_material/M = GLOB.munition_materials[key]
		if(container.has_enough_of_material(M.material_type, round(amount * M.sheets_mult * 0.5)))
			firsts[M.name] = M
	var/first_choice = tgui_input_list(user, "Pierwszy składnik stopu (połowa odlewu)", title, firsts)
	if(!first_choice)
		return null
	var/datum/munition_material/first = firsts[first_choice]
	var/list/seconds = list()
	for(var/key in GLOB.munition_materials)
		var/datum/munition_material/M = GLOB.munition_materials[key]
		if(M == first)
			continue
		var/datum/munition_material/alloy = get_munition_alloy(first, M)
		var/list/cost = alloy.get_cost(amount)
		if(container.has_materials(cost))
			seconds["[alloy.name] ([munition_cost_text(cost)])"] = alloy
	if(!length(seconds))
		to_chat(user, "<span class='warning'>Nie starczy materiału na żaden stop z: [first.name].</span>")
		return null
	var/second_choice = tgui_input_list(user, "Drugi składnik stopu", title, seconds)
	return second_choice ? seconds[second_choice] : null

/// "2 ark. uran + 1 ark. tytan" do list wyboru
/proc/munition_cost_text(list/cost)
	var/list/parts = list()
	for(var/mat in cost)
		var/datum/munition_material/M = get_munition_material(mat)
		parts += "[round(cost[mat] / MINERAL_MATERIAL_AMOUNT, 0.1)] ark.[M ? " [M.name]" : ""]"
	return jointext(parts, " + ")

// ---------------------------------------------------------------- piec łukowy

/obj/machinery/munitions_forge/arc_forge
	name = "piec łukowy"
	desc = "Wielki piec połączony z silosem rudy. Odlewa w formie części amunicji z materiału albo stopu dwóch materiałów i dogrzewa ostygnięte odlewy. Multitool z buforem silosu łączy go z silosem."
	icon = 'aquila/icons/obj/munitions_forge/arc_forge.dmi'
	icon_state = "arc_forge"
	bound_width = 96
	bound_height = 96
	max_integrity = 300
	circuit = /obj/item/circuitboard/machine/munitions_arc_forge
	operation_time = 6 SECONDS
	operation_sound = 'sound/machines/hiss.ogg'
	var/datum/component/remote_materials/materials
	var/obj/item/munition_cast/cast
	var/obj/item/munition_part/produced_part
	/// Mnożnik zużycia materiału (mniej = taniej)
	var/efficiency = 1
	var/cast_time = 6 SECONDS
	/// O ile dogrzewa część
	var/heat_amount = 5
	var/reheat_time = 4 SECONDS
	/// Co wylewamy w tej operacji (null = dogrzewanie)
	var/pending_product
	var/datum/munition_material/pending_material
	var/datum/munition_quality/pending_quality

/obj/machinery/munitions_forge/arc_forge/Initialize(mapload)
	. = ..()
	materials = AddComponent(/datum/component/remote_materials, "munitions_forge", mapload)

/obj/machinery/munitions_forge/arc_forge/Destroy()
	// Własny zapas (bez silosu) wysypujemy teraz: przy niszczeniu komponentów kontener znika przed remote_materials,
	// a ten potem sypie arkusze z odłączonego kontenera i rzuca runtime na parent = null
	if(materials && !materials.silo && materials.mat_container)
		materials.mat_container.retrieve_all(drop_location())
	materials = null
	if(cast)
		cast.forceMove(drop_location())
		cast = null
	if(produced_part)
		produced_part.forceMove(drop_location())
		produced_part = null
	return ..()

/obj/machinery/munitions_forge/arc_forge/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == cast)
		cast = null
		update_icon()
	else if(gone == produced_part)
		produced_part = null
		update_icon()

/obj/machinery/munitions_forge/arc_forge/RefreshParts()
	var/manipulators = 0
	var/bins = 0
	var/lasers = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		manipulators += M.rating
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		bins += B.rating
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		lasers += L.rating
	// jeden manipulator: 1-4, dwa pojemniki i dwa lasery: 2-8
	cast_time = max(initial(cast_time) - (manipulators - 1) * 1 SECONDS, 3 SECONDS)
	efficiency = 1.1 - bins * 0.05
	heat_amount = 3 + lasers
	reheat_time = max(initial(reheat_time) - (lasers - 2) * 0.4 SECONDS, 2 SECONDS)

/obj/machinery/munitions_forge/arc_forge/proc/get_container()
	return materials?.mat_container

/obj/machinery/munitions_forge/arc_forge/accepts_part(obj/item/munition_part/part)
	return !part.is_finished()

/obj/machinery/munitions_forge/arc_forge/examine(mob/user)
	. = ..()
	if(cast)
		. += "<span class='notice'>W gnieździe jest [cast]. Alt+klik, żeby ją wyjąć.</span>"
	else
		. += "<span class='notice'>Włóż formę, żeby odlewać. Ostygniętą część włóż, żeby ją dogrzać.</span>"
	if(produced_part)
		. += "<span class='notice'>W formie stygnie [produced_part]. Kliknij ręką, żeby go wyjąć.</span>"
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

/obj/machinery/munitions_forge/arc_forge/update_overlays()
	. = ..()
	if(operating && !(machine_stat & (NOPOWER|BROKEN)))
		. += "arc_forge_emissive"

/obj/machinery/munitions_forge/arc_forge/power_change()
	. = ..()
	update_icon()

/obj/machinery/munitions_forge/arc_forge/attackby(obj/item/I, mob/living/user, params)
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
	if(istype(I, /obj/item/munition_part) && !accepts_part(I))
		to_chat(user, "<span class='notice'>[I] jest już wykuty, nie trzeba go dogrzewać.</span>")
		return TRUE
	return ..()

/obj/machinery/munitions_forge/arc_forge/AltClick(mob/living/user)
	if(working_part)
		return ..()
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

/obj/machinery/munitions_forge/arc_forge/interact(mob/living/user)
	if(produced_part && !operating)
		var/obj/item/munition_part/part = produced_part
		produced_part = null
		part.hand_over(user)
		update_icon()
		return
	return ..()

/obj/machinery/munitions_forge/arc_forge/start_operation(mob/user)
	if(!can_operate(user))
		return FALSE
	if(working_part)
		if(working_part.forge_heat > 10)
			to_chat(user, "<span class='notice'>[working_part] jest już dobrze rozgrzany.</span>")
			return FALSE
		pending_product = null
		operation_time = reheat_time
		to_chat(user, "<span class='notice'>Dogrzewasz [working_part]...</span>")
		return ..()
	if(!prepare_cast(user))
		return FALSE
	operation_time = cast_time
	return ..()

/// Pobiera materiał na odlew z formy. TRUE = można lać.
/obj/machinery/munitions_forge/arc_forge/proc/prepare_cast(mob/user)
	if(produced_part)
		to_chat(user, "<span class='warning'>Najpierw wyjmij odlew.</span>")
		return FALSE
	if(!cast || !cast.selected_product)
		to_chat(user, "<span class='warning'>W gnieździe nie ma formy.</span>")
		return FALSE
	var/datum/component/material_container/container = get_container()
	if(!container)
		to_chat(user, "<span class='warning'>[src] nie jest połączony z magazynem materiałów.</span>")
		return FALSE
	if(materials.on_hold())
		to_chat(user, "<span class='warning'>Silos jest zablokowany.</span>")
		return FALSE
	var/obj/item/munition_part/product = cast.selected_product
	var/datum/munition_quality/quality = get_munition_quality(cast.quality)
	var/list/cost
	var/datum/munition_material/material = pending_material
	if(ispath(product, /obj/item/munition_part/body))
		var/obj/item/munition_part/body/body_path = product
		var/base_amount = initial(body_path.material_amount) * quality.material_mult * efficiency
		// materiał mógł zostać ustawiony wcześniej (testy), inaczej pytamy
		if(!material)
			material = choose_munition_material(user, container, base_amount, "Odlew: [initial(body_path.name)]")
			if(!material || QDELETED(src) || !user_can_reach(user) || !can_operate(user) || cast?.selected_product != product || working_part || produced_part)
				return FALSE
		cost = material.get_cost(base_amount)
	else
		// base_cost to lista, a initial() na listach nie działa — jak w Paradise czytamy ją z tymczasowej instancji
		var/obj/item/munition_part/temp = new product(null)
		cost = list()
		for(var/mat in temp.base_cost)
			cost[mat] = round(temp.base_cost[mat] * quality.material_mult * efficiency)
		qdel(temp)
	if(!container.has_materials(cost))
		to_chat(user, "<span class='warning'>W silosie zabrakło materiału.</span>")
		pending_material = null
		return FALSE
	container.use_materials(cost)
	materials.silo_log(src, "odlano", -1, initial(product.name), cost)
	pending_material = material
	pending_quality = quality
	pending_product = product
	to_chat(user, "<span class='notice'>Wlewasz płynny metal do formy...</span>")
	return TRUE

/obj/machinery/munitions_forge/arc_forge/complete_operation(mob/user)
	if(!pending_product)
		working_part?.heat_up(heat_amount)
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

/obj/machinery/munitions_forge/arc_forge/special_attack(mob/living/user, mob/living/carbon/target)
	target.visible_message("<span class='danger'>[user] wpycha głowę [target] do [src]!</span>", \
		"<span class='userdanger'>[user] wpycha ci głowę do [src]! Żar jest nie do zniesienia!</span>")
	target.apply_damage(40, BURN, BODY_ZONE_HEAD, target.run_armor_check(BODY_ZONE_HEAD, "melee"))
	target.adjust_fire_stacks(5)
	target.IgniteMob()
	target.emote("scream")
	playsound(src, 'sound/surgery/cautery1.ogg', 50, TRUE)
	return TRUE

// ---------------------------------------------------------------- kowadło

/obj/machinery/munitions_forge/anvil
	name = "kowadło"
	desc = "Kowadło do kształtowania gorących odlewów amunicji. Połóż na nim rozgrzaną część i kuj w rytm."
	icon_state = "anvil_empty"
	circuit = /obj/item/circuitboard/machine/munitions_anvil
	use_power = NO_POWER_USE
	max_integrity = 400
	/// Trwające kucie
	var/datum/munitions_anvil_game/game

/obj/machinery/munitions_forge/anvil/Destroy()
	QDEL_NULL(game)
	return ..()

/obj/machinery/munitions_forge/anvil/accepts_part(obj/item/munition_part/part)
	return !part.is_finished()

/obj/machinery/munitions_forge/anvil/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/munition_part) && !accepts_part(I))
		to_chat(user, "<span class='notice'>[I] jest już wykuty.</span>")
		return TRUE
	return ..()

/obj/machinery/munitions_forge/anvil/update_icon_state()
	icon_state = working_part ? "anvil_ingot" : "anvil_empty"
	return ..()

/obj/machinery/munitions_forge/anvil/start_operation(mob/user)
	if(game)
		if(user == game.user)
			ui_interact(user)
		else
			to_chat(user, "<span class='warning'>Ktoś już kuje na [src].</span>")
		return FALSE
	if(!can_operate(user))
		return FALSE
	if(!working_part)
		to_chat(user, "<span class='warning'>Na kowadle nic nie leży.</span>")
		return FALSE
	if(!working_part.forge_heat)
		to_chat(user, "<span class='warning'>[working_part] jest za zimny, żeby go kuć. Dogrzej go w piecu łukowym.</span>")
		return FALSE
	if(!user?.client)
		return FALSE
	game = new(src, user, working_part)
	operating = TRUE
	ui_interact(user)
	return TRUE

/// Wołane przez minigrę na koniec albo przy przerwaniu
/obj/machinery/munitions_forge/anvil/proc/game_over(datum/munitions_anvil_game/ended)
	if(ended != game)
		return
	game = null
	operating = FALSE
	SStgui.close_uis(src)
	update_icon()

/obj/machinery/munitions_forge/anvil/special_attack(mob/living/user, mob/living/carbon/target)
	target.visible_message("<span class='danger'>[user] tłucze głową [target] o [src]!</span>", \
		"<span class='userdanger'>[user] tłucze twoją głową o [src]!</span>")
	target.apply_damage(40, BRUTE, BODY_ZONE_HEAD, target.run_armor_check(BODY_ZONE_HEAD, "melee"))
	target.Paralyze(4 SECONDS)
	target.emote("scream")
	playsound(src, 'sound/effects/clang.ogg', 50, TRUE)
	return TRUE

// ---------------------------------------------------------------- stół montażowy

/obj/machinery/munitions_forge/assembly_bench
	name = "stół montażowy amunicji"
	desc = "Stół, na którym z korpusu, wypełnienia i zapalnika składa się gotową amunicję. Wypełnienie nie jest wymagane."
	icon_state = "crafting_bench_empty"
	circuit = /obj/item/circuitboard/machine/munitions_assembly_bench
	use_power = NO_POWER_USE
	operation_time = 5 SECONDS
	operation_sound = 'sound/items/ratchet.ogg'
	var/obj/item/munition_part/body/body
	var/obj/item/munition_part/filler/filler
	var/obj/item/munition_part/fuze/fuze

/obj/machinery/munitions_forge/assembly_bench/Destroy()
	for(var/obj/item/munition_part/part in list(body, filler, fuze))
		part.forceMove(drop_location())
	body = null
	filler = null
	fuze = null
	return ..()

/obj/machinery/munitions_forge/assembly_bench/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == body)
		body = null
	else if(gone == filler)
		filler = null
	else if(gone == fuze)
		fuze = null

/obj/machinery/munitions_forge/assembly_bench/RefreshParts()
	var/rating = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		rating += M.rating
	operation_time = max(initial(operation_time) - (rating - 1) * 1 SECONDS, 2 SECONDS)

/obj/machinery/munitions_forge/assembly_bench/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Korpus: [body ? body : "brak"].</span>"
	. += "<span class='notice'>Wypełnienie: [filler ? filler : "brak (zwykła amunicja)"].</span>"
	. += "<span class='notice'>Zapalnik: [fuze ? fuze : "brak"].</span>"
	. += "<span class='notice'>Alt+klik zdejmuje wszystkie części.</span>"

/obj/machinery/munitions_forge/assembly_bench/attackby(obj/item/I, mob/living/user, params)
	if(!istype(I, /obj/item/munition_part))
		return ..()
	var/obj/item/munition_part/part = I
	if(operating)
		to_chat(user, "<span class='warning'>Na [src] trwa montaż!</span>")
		return TRUE
	if(!part.is_finished())
		to_chat(user, "<span class='warning'>[part] trzeba jeszcze wykuć na kowadle.</span>")
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
	to_chat(user, "<span class='notice'>Kładziesz [part] na [src].</span>")
	return TRUE

/obj/machinery/munitions_forge/assembly_bench/AltClick(mob/living/user)
	if(!user_can_reach(user))
		return
	if(operating)
		to_chat(user, "<span class='warning'>Na [src] trwa montaż!</span>")
		return
	var/list/parts = list(body, filler, fuze) - null
	if(!length(parts))
		to_chat(user, "<span class='notice'>Na [src] nic nie ma.</span>")
		return
	for(var/obj/item/munition_part/part in parts)
		part.forceMove(drop_location())
	to_chat(user, "<span class='notice'>Zdejmujesz części z [src].</span>")

/// Montaż ręczny jak na stole z Monkestation: do_after zamiast timera maszyny
/obj/machinery/munitions_forge/assembly_bench/start_operation(mob/user)
	if(operating)
		to_chat(user, "<span class='warning'>Na [src] trwa montaż!</span>")
		return FALSE
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
	operating = TRUE
	playsound(src, operation_sound, 50, TRUE)
	var/success = do_after(user, operation_time, target = src)
	operating = FALSE
	if(!success || !body || !fuze)
		return FALSE
	complete_operation(user)
	return TRUE

/obj/machinery/munitions_forge/assembly_bench/complete_operation(mob/user)
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
		visible_message("<span class='notice'>Na [src] leży gotowy wyrób: [products[1]].</span>")
