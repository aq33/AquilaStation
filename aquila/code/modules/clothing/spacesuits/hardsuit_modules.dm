// Hardsuity Aquili przejęły funkcje MOD-ów (modsuity usunięte): instalowane moduły (/obj/item/mod/module/*),
// rdzeń z baterią (/obj/item/mod/core/*) i wbudowana butla z tlenem. Moduły widzą hardsuit jako swoje `mod`.
// Projekt: raport/zbiorczy_0711_02_hardsuity_projekt.md. Kod przeniesiony i uproszczony z dawnego mod_control.dm (port BeeStation).
// Części: kombinezon (tułów, ręce, nogi, plecy, pas) i hełm (głowa, oczy, maska, uszy). Moduły na rękawice albo buty siedzą w kombinezonie.

/// Sloty obsługiwane przez sam kombinezon
#define HARDSUIT_BODY_SLOTS (ITEM_SLOT_OCLOTHING|ITEM_SLOT_ICLOTHING|ITEM_SLOT_GLOVES|ITEM_SLOT_FEET|ITEM_SLOT_BACK|ITEM_SLOT_BELT|ITEM_SLOT_NECK|ITEM_SLOT_SUITSTORE)
/// Sloty obsługiwane przez hełm
#define HARDSUIT_HEAD_SLOTS (ITEM_SLOT_HEAD|ITEM_SLOT_EYES|ITEM_SLOT_MASK|ITEM_SLOT_EARS)
/// Ciśnienie pełnej wbudowanej butli (tyle daje przy tworzeniu, tyle uzupełnia szafa i najwyżej tyle można dolać)
#define HARDSUIT_TANK_PRESSURE (6 * ONE_ATMOSPHERE)

/obj/item/clothing/suit/space/hardsuit
	/// Moduły w kombinezonie
	var/list/obj/item/mod/module/modules = list()
	/// Moduły wkładane przy tworzeniu (ścieżki typów)
	var/list/initial_modules = list()
	/// Ile złożoności modułów mieści kombinezon
	var/complexity_max = DEFAULT_MAX_COMPLEXITY
	/// Obecna złożoność modułów
	var/complexity = 0
	/// Pobór prądu samego kombinezonu z modułami (na sekundę)
	var/charge_drain = DEFAULT_CHARGE_DRAIN
	/// Rdzeń zasilania (null = bez zasilania, kombinezon działa, moduły nie)
	var/obj/item/mod/core/core
	/// Rdzeń przy tworzeniu (ścieżka typu)
	var/initial_core = /obj/item/mod/core/standard
	/// Ogniwo wkładane do standardowego rdzenia przy tworzeniu (ścieżka typu, null = rdzeń bez ogniwa)
	var/initial_cell = /obj/item/stock_parts/cell/high
	/// Wybrany moduł aktywny
	var/obj/item/mod/module/selected_module
	/// Kto nosi kombinezon
	var/mob/living/carbon/human/wearer
	/// Kombinezon założony i uruchomiony (blokada DNA wpuściła noszącego)
	var/active = FALSE
	/// Moduły zależne od części mają prąd: uruchomiony kombinezon z naładowanym rdzeniem (stan z ostatniego refresh_seals())
	var/modules_powered = FALSE
	/// Kombinezon zakłada ktoś inny przez menu ściągania (tylko na czas założenia): wtedy kombinezon nie uruchamia się sam
	var/dressed_by_other = FALSE
	/// Zgodność z modułami MOD (u nas zawsze FALSE: hardsuit nie ma sekwencji uszczelniania)
	var/activating = FALSE
	/// Zgodność z modułami MOD (panel otwiera okno, moduły wkłada się ręką)
	var/open = TRUE
	/// Części jak w MOD: klucz to suma obsługiwanych slotów, wartość to /datum/mod_part
	var/list/mod_parts = list()
	/// Zgodność z modułami MOD: nazwa „skórki” do pamięci podręcznej nakładek
	var/skin = "hardsuit"
	/// Zgodność z modułami MOD: czas kroku uszczelniania
	var/activation_step_time = 0
	/// Wbudowana butla z tlenem (null = brak)
	var/obj/item/tank/internals/hardsuit/integrated_tank
	/// Butla przy tworzeniu (ścieżka typu, null = brak)
	var/integrated_tank_type = /obj/item/tank/internals/hardsuit
	/// Ile spowolnienia dokładają teraz moduły (reszta `slowdown` należy do kombinezonu, np. tryb bojowy hardsuitu Syndykatu)
	var/module_slowdown = 0

/obj/item/clothing/suit/space/hardsuit/Initialize(mapload)
	// akcje modułów i butli powstają w Initialize() przedmiotu z actions_types, więc dopisujemy je wcześniej
	actions_types = (actions_types || list()) | list(/datum/action/item_action/mod/panel, /datum/action/item_action/mod/module, /datum/action/item_action/hardsuit_tank)
	. = ..()
	var/datum/mod_part/body = new
	body.part_item = src
	mod_parts["[HARDSUIT_BODY_SLOTS]"] = body
	if(ispath(initial_core))
		var/obj/item/mod/core/new_core = new initial_core(src)
		if(ispath(initial_cell) && istype(new_core, /obj/item/mod/core/standard))
			var/obj/item/mod/core/standard/cell_core = new_core
			cell_core.cell = new initial_cell(cell_core)
		new_core.install(src)
	if(ispath(integrated_tank_type))
		integrated_tank = new integrated_tank_type(src)
	for(var/module_type in initial_modules)
		var/obj/item/mod/module/module = new module_type(src)
		if(!install(module, null, TRUE))
			stack_trace("[type]: nie udało się zainstalować modułu startowego [module_type]")
			qdel(module)
	START_PROCESSING(SSobj, src)

/obj/item/clothing/suit/space/hardsuit/Destroy()
	STOP_PROCESSING(SSobj, src)
	// moduły zdejmują efekty z noszącego, póki wearer jest ustawiony
	for(var/obj/item/mod/module/module as anything in modules)
		uninstall(module, deleting = TRUE)
		qdel(module)
	// przed ..(), bo /obj/item/Destroy() zdejmuje przedmiot z moba dopiero po wyczyszczeniu wearer, więc dropped() nic by nie zrobił
	if(wearer)
		unset_wearer()
	QDEL_NULL(core)
	QDEL_NULL(integrated_tank)
	QDEL_LIST_ASSOC_VAL(mod_parts)
	selected_module = null
	wearer = null
	return ..()

/// Hełm jako część (po MakeHelmet); wołane też, gdy hełm jest podmieniony
/obj/item/clothing/suit/space/hardsuit/proc/update_helmet_part()
	var/key = "[HARDSUIT_HEAD_SLOTS]"
	var/datum/mod_part/head_part = mod_parts[key]
	if(!helmet)
		if(head_part)
			mod_parts -= key
			qdel(head_part)
		return
	if(!head_part)
		head_part = new
		mod_parts[key] = head_part
	head_part.part_item = helmet
	head_part.sealed = suittoggled && wearer && wearer.head == helmet

/obj/item/clothing/suit/space/hardsuit/MakeHelmet()
	. = ..()
	update_helmet_part()

/obj/item/clothing/suit/space/hardsuit/ToggleHelmet()
	. = ..()
	refresh_seals()

/obj/item/clothing/suit/space/hardsuit/RemoveHelmet()
	. = ..()
	refresh_seals()

/// Przelicza szczelność części i włącza albo wyłącza moduły zależne od części
/obj/item/clothing/suit/space/hardsuit/proc/refresh_seals()
	var/datum/mod_part/body = mod_parts["[HARDSUIT_BODY_SLOTS]"]
	if(!body || QDELING(src)) // kombinezon w trakcie niszczenia: części już usunięte
		return
	update_helmet_part()
	body.sealed = active
	// jak dawniej w MOD: bez prądu moduły zależne od części (także pasywne, np. szybkie noszenie) nie działają
	modules_powered = active && get_charge() > 0
	for(var/obj/item/mod/module/module as anything in modules)
		var/ready = modules_powered && module.has_required_parts(mod_parts, need_active = TRUE)
		if(ready && !module.part_activated)
			module.on_part_activation()
			module.part_activated = TRUE
		else if(!ready && module.part_activated)
			if(module.active)
				module.deactivate(display_message = FALSE)
			module.on_part_deactivation()
			module.part_activated = FALSE
	update_speed()
	wearer?.update_clothing(slot_flags)

/obj/item/clothing/suit/space/hardsuit/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_OCLOTHING)
		if(wearer != user)
			if(wearer)
				unset_wearer()
			set_wearer(user)
	else if(wearer)
		unset_wearer()

/obj/item/clothing/suit/space/hardsuit/dropped(mob/user)
	. = ..()
	if(wearer)
		unset_wearer()

/obj/item/clothing/suit/space/hardsuit/proc/set_wearer(mob/living/carbon/human/user)
	if(!istype(user))
		return
	wearer = user
	SEND_SIGNAL(src, COMSIG_MOD_WEARER_SET, wearer)
	for(var/obj/item/mod/module/module as anything in modules)
		module.on_equip()
		var/datum/action/item_action/mod/pinned_module/action = module.pinned_to[REF(wearer)]
		action?.Grant(wearer)
	if(dressed_by_other)
		// jak dawniej przy MOD: założony komuś kombinezon czeka, aż noszący sam go uruchomi (try_activate())
		active = FALSE
		if(length(modules))
			to_chat(wearer, "<span class='notice'>Ktoś założył na ciebie [src]. Moduły uruchomisz akcją kombinezonu.</span>")
	else
		// blokada DNA i podobne moduły mogą nie wpuścić noszącego
		active = !(SEND_SIGNAL(src, COMSIG_MOD_ACTIVATE, wearer) & MOD_CANCEL_ACTIVATE)
		if(QDELETED(src) || wearer != user) // wzmocniona blokada ninja zabiła noszącego
			return
	refresh_seals()
	update_charge_alert()

/// Uruchamia kombinezon, którego noszący jeszcze nie uruchomił (założony przez kogoś innego albo odrzucony przez blokadę DNA).
/// Blokada sprawdza wtedy noszącego tak jak dawniej przy aktywacji MOD. Zwraca TRUE, gdy kombinezon działa.
/obj/item/clothing/suit/space/hardsuit/proc/try_activate(mob/user)
	if(active)
		return TRUE
	if(!user || user != wearer)
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_MOD_ACTIVATE, user) & MOD_CANCEL_ACTIVATE)
		return FALSE
	if(QDELETED(src) || user != wearer)
		return FALSE
	active = TRUE
	refresh_seals()
	update_charge_alert()
	balloon_alert(user, "kombinezon uruchomiony")
	return TRUE

/// Blokada DNA (sygnał jak przy dawnym otwieraniu pokrywy MOD): TRUE, gdy tej osobie nie wolno wkładać ani wyjmować części
/obj/item/clothing/suit/space/hardsuit/proc/parts_locked(mob/user)
	if(SEND_SIGNAL(src, COMSIG_MOD_MODULE_REMOVAL, user) & MOD_CANCEL_REMOVAL)
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return TRUE
	return FALSE

/obj/item/clothing/suit/space/hardsuit/proc/unset_wearer()
	if(!wearer)
		return
	var/mob/living/carbon/human/old_wearer = wearer
	if(integrated_tank && old_wearer.internal == integrated_tank)
		old_wearer.internal = null
		old_wearer.update_internals_hud_icon(0)
	for(var/obj/item/mod/module/module as anything in modules)
		if(module.active)
			module.deactivate(display_message = FALSE)
	active = FALSE
	refresh_seals()
	for(var/obj/item/mod/module/module as anything in modules)
		module.on_unequip()
	old_wearer.clear_alert("mod_charge")
	SEND_SIGNAL(src, COMSIG_MOD_WEARER_UNSET, old_wearer)
	wearer = null

/obj/item/clothing/suit/space/hardsuit/process(delta_time)
	if(!active || !wearer)
		return
	if(!length(modules))
		return
	if(!get_charge())
		for(var/obj/item/mod/module/module as anything in modules)
			if(module.active)
				module.deactivate(display_message = FALSE)
		if(modules_powered)
			refresh_seals()
		update_charge_alert()
		return
	if(!modules_powered) // prąd wrócił (np. ładowarka borgów)
		refresh_seals()
	subtract_charge(charge_drain * delta_time)
	update_charge_alert()
	for(var/obj/item/mod/module/module as anything in modules)
		module.on_process(delta_time)

/obj/item/clothing/suit/space/hardsuit/examine(mob/user)
	. = ..()
	if(core)
		. += "<span class='notice'>Rdzeń zasilania: [core.name], naładowany w [get_charge_percent()]%.</span>"
	else
		. += "<span class='warning'>Nie ma rdzenia zasilania: moduły nie działają.</span>"
	if(integrated_tank)
		. += "<span class='notice'>Wbudowana butla: [round(integrated_tank.air_contents.return_pressure())] kPa.</span>"
	if(length(modules))
		var/list/names = list()
		for(var/obj/item/mod/module/module as anything in modules)
			names += module.name
		. += "<span class='notice'>Moduły ([complexity]/[complexity_max] złożoności): [english_list(names)].</span>"
	. += "<span class='notice'>Moduły i rdzeń wkładasz ręką, gdy kombinezon jest zdjęty. Łomem je wyjmujesz.</span>"

// Wkładanie modułów i rdzenia oraz przelewanie gazu do wbudowanej butli
/obj/item/clothing/suit/space/hardsuit/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mod/module))
		if(wearer)
			balloon_alert(user, "najpierw zdejmij kombinezon!")
			return TRUE
		if(parts_locked(user))
			return TRUE
		install(I, user)
		return TRUE
	if(istype(I, /obj/item/mod/core))
		if(wearer)
			balloon_alert(user, "najpierw zdejmij kombinezon!")
			return TRUE
		if(core)
			balloon_alert(user, "ma już rdzeń!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return TRUE
		if(parts_locked(user))
			return TRUE
		var/obj/item/mod/core/new_core = I
		if(!user.transferItemToLoc(new_core, src))
			return TRUE
		new_core.install(src)
		balloon_alert(user, "rdzeń zainstalowany")
		playsound(src, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
		update_charge_alert()
		return TRUE
	if(istype(I, /obj/item/tank/internals) && integrated_tank && !istype(I, /obj/item/tank/internals/hardsuit))
		fill_integrated_tank(I, user)
		return TRUE
	return ..()

/obj/item/clothing/suit/space/hardsuit/crowbar_act(mob/living/user, obj/item/tool)
	if(wearer)
		balloon_alert(user, "najpierw zdejmij kombinezon!")
		return TRUE
	if(parts_locked(user))
		return TRUE
	var/list/choices = list()
	for(var/obj/item/mod/module/module as anything in modules)
		if(module.removable)
			choices[module.name] = module
	var/obj/item/mod/core/standard/cell_core = core
	if(istype(cell_core) && cell_core.cell)
		choices["ogniwo: [cell_core.cell.name]"] = cell_core.cell
	if(core)
		choices["rdzeń: [core.name]"] = core
	if(!length(choices))
		balloon_alert(user, "nic do wyjęcia!")
		return TRUE
	var/picked = tgui_input_list(user, "Co wyjąć z kombinezonu?", "Hardsuit", choices)
	if(!picked || wearer || !user.Adjacent(src) || parts_locked(user))
		return TRUE
	var/obj/item/thing = choices[picked]
	if(istype(cell_core) && core == cell_core && thing == cell_core.cell)
		cell_core.mod_uninstall_cell(user)
		return TRUE
	if(thing == core)
		core.uninstall()
		thing.forceMove(drop_location())
	else if(thing in modules)
		uninstall(thing)
		thing.forceMove(drop_location())
		SEND_SIGNAL(src, COMSIG_MOD_MODULE_REMOVED, user)
	else
		return TRUE
	user.put_in_hands(thing)
	tool.play_tool_sound(src, 100)
	balloon_alert(user, "wyjęto: [thing.name]")
	return TRUE

// Zniszczenie (obrażenia, kwas, ogień): moduły odinstalowane bez kasowania, więc schowek i klamra wyrzucają zawartość jak dawniej w MOD
/obj/item/clothing/suit/space/hardsuit/obj_destruction(damage_flag)
	for(var/obj/item/mod/module/module as anything in modules)
		uninstall(module)
	return ..()

/obj/item/clothing/suit/space/hardsuit/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!wearer || !length(modules))
		return
	to_chat(wearer, "<span class='warning'>Moduły kombinezonu zakłóca impuls elektromagnetyczny!</span>")
	for(var/obj/item/mod/module/module as anything in modules)
		if(module.active && prob(50 / severity))
			module.deactivate()
	subtract_charge(get_max_charge() / (5 * severity))

/obj/item/clothing/suit/space/hardsuit/get_cell()
	var/obj/item/stock_parts/cell/cell = get_charge_source()
	if(istype(cell))
		return cell

// API kontrolera MOD, z którego korzystają moduły

/obj/item/clothing/suit/space/hardsuit/proc/install(obj/item/mod/module/new_module, mob/user, initial = FALSE)
	for(var/obj/item/mod/module/old_module as anything in modules)
		if(is_type_in_list(new_module, old_module.incompatible_modules) || is_type_in_list(old_module, new_module.incompatible_modules))
			if(user)
				balloon_alert(user, "niezgodne z: [old_module]!")
				playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return FALSE
	if(!initial && complexity + new_module.complexity > complexity_max)
		if(user)
			balloon_alert(user, "przekroczona maksymalna złożoność!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(user && !user.transferItemToLoc(new_module, src))
		return FALSE
	new_module.forceMove(src)
	modules += new_module
	complexity += new_module.complexity
	new_module.mod = src
	new_module.on_install()
	if(wearer)
		new_module.on_equip()
	refresh_seals()
	if(user)
		balloon_alert(user, "dodano: [new_module]")
		playsound(src, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
		SEND_SIGNAL(src, COMSIG_MOD_MODULE_ADDED, user)
	return TRUE

/obj/item/clothing/suit/space/hardsuit/proc/uninstall(obj/item/mod/module/old_module, deleting = FALSE)
	modules -= old_module
	complexity -= old_module.complexity
	if(old_module.active)
		old_module.deactivate(display_message = !deleting, deleting = deleting)
	if(old_module.part_activated)
		old_module.on_part_deactivation(deleting = deleting)
		old_module.part_activated = FALSE
	if(wearer)
		old_module.on_unequip()
	old_module.on_uninstall(deleting = deleting)
	QDEL_LIST_ASSOC_VAL(old_module.pinned_to)
	if(selected_module == old_module)
		selected_module = null
	old_module.mod = null
	if(!deleting)
		update_speed()

/obj/item/clothing/suit/space/hardsuit/proc/get_parts(all = FALSE)
	. = list()
	for(var/key in mod_parts)
		var/datum/mod_part/part = mod_parts[key]
		if(!all && part.part_item == src)
			continue
		. += part.part_item

/obj/item/clothing/suit/space/hardsuit/proc/get_part_datums(all = FALSE)
	. = list()
	for(var/key in mod_parts)
		var/datum/mod_part/part = mod_parts[key]
		if(!all && part.part_item == src)
			continue
		. += part

/obj/item/clothing/suit/space/hardsuit/proc/get_part_datum(obj/item/part)
	RETURN_TYPE(/datum/mod_part)
	for(var/key in mod_parts)
		var/datum/mod_part/mod_part = mod_parts[key]
		if(mod_part.part_item == part)
			return mod_part

/obj/item/clothing/suit/space/hardsuit/proc/get_part_datum_from_slot(slot)
	RETURN_TYPE(/datum/mod_part)
	for(var/key in mod_parts)
		if(text2num(key) & slot)
			return mod_parts[key]

/obj/item/clothing/suit/space/hardsuit/proc/get_part_from_slot(slot)
	var/datum/mod_part/part = get_part_datum_from_slot(slot)
	return part?.part_item

/obj/item/clothing/suit/space/hardsuit/proc/get_sealed_slots(list/parts)
	var/covered_slots = NONE
	for(var/key in mod_parts)
		var/datum/mod_part/part = mod_parts[key]
		if(part.sealed)
			covered_slots |= text2num(key)
	return covered_slots

/obj/item/clothing/suit/space/hardsuit/proc/get_wearer()
	return wearer

/obj/item/clothing/suit/space/hardsuit/proc/get_charge_source()
	return core?.charge_source()

/obj/item/clothing/suit/space/hardsuit/proc/get_charge()
	return core?.charge_amount() || 0

/obj/item/clothing/suit/space/hardsuit/proc/get_max_charge()
	return core?.max_charge_amount() || 1

/obj/item/clothing/suit/space/hardsuit/proc/get_charge_percent()
	return ROUND_UP((get_charge() / get_max_charge()) * 100)

/obj/item/clothing/suit/space/hardsuit/proc/add_charge(amount)
	return core?.add_charge(amount) || FALSE

/obj/item/clothing/suit/space/hardsuit/proc/subtract_charge(amount)
	return core?.subtract_charge(amount) || FALSE

/obj/item/clothing/suit/space/hardsuit/proc/check_charge(amount)
	return core?.check_charge(amount) || FALSE

/obj/item/clothing/suit/space/hardsuit/proc/update_charge_alert()
	if(!wearer)
		return
	if(!length(modules))
		wearer.clear_alert("mod_charge")
		return
	if(!core)
		wearer.throw_alert("mod_charge", /atom/movable/screen/alert/nocore)
		return
	core.update_charge_alert()

/// Spowolnienie: kombinezon plus moduły (sygnał jak w MOD). Zmienia tylko część od modułów,
/// bo kombinezon sam zmienia `slowdown` (tryb bojowy Syndykatu, mikstura szybkości).
/obj/item/clothing/suit/space/hardsuit/proc/update_speed()
	var/prevent_slowdown = HAS_TRAIT(src, TRAIT_SPEED_POTIONED)
	var/list/module_slowdowns = list()
	SEND_SIGNAL(src, COMSIG_MOD_UPDATE_SPEED, module_slowdowns, prevent_slowdown)
	var/new_module_slowdown = 0
	for(var/module_slow in module_slowdowns)
		new_module_slowdown += module_slow
	slowdown = max(slowdown + new_module_slowdown - module_slowdown, 0)
	module_slowdown = new_module_slowdown
	wearer?.update_equipment_speed_mods()

/// Wybór modułu radialem (akcja kombinezonu)
/obj/item/clothing/suit/space/hardsuit/proc/quick_module(mob/user)
	if(!length(modules))
		balloon_alert(user, "brak modułów!")
		return
	var/list/display_names = list()
	var/list/items = list()
	for(var/obj/item/mod/module/module as anything in modules)
		if(module.module_type == MODULE_PASSIVE)
			continue
		display_names[module.name] = REF(module)
		var/image/module_image = image(icon = module.icon, icon_state = module.icon_state)
		if(module == selected_module)
			module_image.underlays += image(icon = 'icons/mob/radial.dmi', icon_state = "module_selected")
		else if(module.active)
			module_image.underlays += image(icon = 'icons/mob/radial.dmi', icon_state = "module_active")
		if(!COOLDOWN_FINISHED(module, cooldown_timer))
			module_image.add_overlay(image(icon = 'icons/mob/radial.dmi', icon_state = "module_cooldown"))
		items += list(module.name = module_image)
	if(!length(items))
		return
	var/radial_anchor = src
	if(istype(user.loc, /obj/effect/dummy/phased_mob))
		radial_anchor = get_turf(user.loc)
	var/pick = show_radial_menu(user, radial_anchor, items, custom_check = FALSE, require_near = TRUE, tooltips = TRUE)
	if(!pick)
		return
	var/module_reference = display_names[pick]
	var/obj/item/mod/module/picked_module = locate(module_reference) in modules
	if(!istype(picked_module))
		return
	picked_module.on_select()

// Zgodność z modułami MOD: hardsuit nie ma nakładek modułów ani wizjera
/obj/item/clothing/suit/space/hardsuit/proc/get_visor_overlay(mutable_appearance/standing)
	return

/obj/item/clothing/suit/space/hardsuit/proc/generate_suit_mask()
	return icon('icons/effects/effects.dmi', "nothing")

/obj/item/clothing/suit/space/hardsuit/proc/power_off()
	for(var/obj/item/mod/module/module as anything in modules)
		if(module.active)
			module.deactivate(display_message = FALSE)

/obj/item/mod/module/generate_worn_overlay(mutable_appearance/standing)
	return list()

////////////////////////////////////////////////////////////////////
//					WBUDOWANA BUTLA Z TLENEM					  //
////////////////////////////////////////////////////////////////////

/obj/item/tank/internals/hardsuit
	name = "wbudowana butla hardsuitu"
	desc = "Mała butla z tlenem wbudowana w plecy hardsuitu. Hełm podaje z niej powietrze bez maski."
	icon_state = "emergency_double"
	volume = 10
	slot_flags = NONE
	w_class = WEIGHT_CLASS_SMALL
	item_flags = ABSTRACT

/obj/item/tank/internals/hardsuit/populate_gas()
	air_contents.set_moles(GAS_O2, full_oxygen_moles())

/obj/item/tank/internals/hardsuit/Destroy()
	// butla zniszczona w kombinezonie: kombinezon i noszący nie trzymają do niej odwołań
	var/obj/item/clothing/suit/space/hardsuit/suit = loc
	if(istype(suit) && suit.integrated_tank == src)
		suit.integrated_tank = null
		if(suit.wearer?.internal == src)
			suit.wearer.internal = null
			suit.wearer.update_internals_hud_icon(0)
	return ..()

/// Ile moli tlenu ma pełna butla (tyle dostaje przy tworzeniu i tyle uzupełnia szafa na skafandry)
/obj/item/tank/internals/hardsuit/proc/full_oxygen_moles()
	return HARDSUIT_TANK_PRESSURE * volume / (R_IDEAL_GAS_EQUATION * T20C)

/// Przelewa gaz z trzymanej butli do wbudowanej, aż ciśnienia się wyrównają, ale najwyżej do ciśnienia pełnej butli
/obj/item/clothing/suit/space/hardsuit/proc/fill_integrated_tank(obj/item/tank/internals/source, mob/user)
	var/datum/gas_mixture/source_air = source.return_air()
	var/datum/gas_mixture/target_air = integrated_tank.return_air()
	var/source_pressure = source_air.return_pressure()
	var/target_pressure = target_air.return_pressure()
	if(target_pressure >= HARDSUIT_TANK_PRESSURE)
		balloon_alert(user, "butla jest pełna!")
		return
	if(source_pressure <= target_pressure)
		balloon_alert(user, "butla ma za niskie ciśnienie!")
		return
	var/source_volume = source_air.return_volume()
	var/target_volume = target_air.return_volume()
	var/final_pressure = min((source_pressure * source_volume + target_pressure * target_volume) / (source_volume + target_volume), HARDSUIT_TANK_PRESSURE)
	var/moles = (final_pressure - target_pressure) * target_volume / (R_IDEAL_GAS_EQUATION * max(source_air.return_temperature(), TCMB))
	source_air.transfer_to(target_air, moles)
	playsound(src, 'sound/effects/spray2.ogg', 30, TRUE)
	balloon_alert(user, "butla napełniona: [round(target_air.return_pressure())] kPa")

/// Włącza albo wyłącza oddychanie z wbudowanej butli
/obj/item/clothing/suit/space/hardsuit/proc/toggle_integrated_tank(mob/living/carbon/human/user)
	if(!integrated_tank)
		balloon_alert(user, "brak wbudowanej butli!")
		return
	if(user != wearer)
		balloon_alert(user, "najpierw załóż kombinezon!")
		return
	if(user.internal == integrated_tank)
		user.internal = null
		user.update_internals_hud_icon(0)
		balloon_alert(user, "butla zamknięta")
		return
	if(!user.can_breathe_internals())
		balloon_alert(user, "potrzebny hełm albo maska!")
		return
	user.internal = integrated_tank
	user.update_internals_hud_icon(1)
	balloon_alert(user, "oddychasz z wbudowanej butli")
	playsound(src, 'sound/effects/spray2.ogg', 20, TRUE)

/// Czy oddychamy z wbudowanej butli hardsuitu, który mamy na sobie (butla leży w kombinezonie, nie w mobie)
/mob/living/carbon/proc/aquila_internal_in_worn_hardsuit()
	var/obj/item/clothing/suit/space/hardsuit/suit = get_item_by_slot(ITEM_SLOT_OCLOTHING)
	return istype(suit) && internal && internal == suit.integrated_tank

// Hełm hardsuitu działa jak maska do butli: podaje powietrze z wbudowanej butli i z każdej innej
/obj/item/clothing/head/helmet/space/hardsuit/Initialize(mapload)
	. = ..()
	clothing_flags |= HEADINTERNALS

// Tryb bojowy hełmu Syndykatu (uniesiony wizjer) zdejmuje visor_flags, więc razem ze szczelnością znika podawanie powietrza
/obj/item/clothing/head/helmet/space/hardsuit/syndi/Initialize(mapload)
	. = ..()
	if(visor_flags & STOPSPRESSUREDAMAGE)
		visor_flags |= HEADINTERNALS
		if(!on)
			clothing_flags &= ~HEADINTERNALS

/datum/action/item_action/hardsuit_tank
	name = "Wbudowana butla"
	desc = "Włącza albo wyłącza oddychanie z butli wbudowanej w kombinezon."
	icon_icon = 'icons/obj/tank.dmi'
	button_icon_state = "emergency_double"

// Bazowe ui_action_click() woła attack_self(), a to otwierało panel kombinezonu przy każdej akcji (hełm, butla).
// Akcje modułów mają własne Trigger(), więc tu zostają tylko hełm i butla. Pełne nadpisanie bez ..(): LEGACY_OVERRIDES.md.
/obj/item/clothing/suit/space/hardsuit/ui_action_click(mob/user, datum/actiontype)
	if(handle_tank_action(user, actiontype))
		return
	ToggleHelmet()

/// Akcja wbudowanej butli; TRUE, gdy to była ona
/obj/item/clothing/suit/space/hardsuit/proc/handle_tank_action(mob/user, datum/actiontype)
	if(!istype(actiontype, /datum/action/item_action/hardsuit_tank))
		return FALSE
	if(ishuman(user))
		toggle_integrated_tank(user)
	return TRUE

// Hardsuity Syndykatu i ERT mają własne ui_action_click() bez ..() (switch po akcjach), więc butla jest obsługiwana przed nimi
/obj/item/clothing/suit/space/hardsuit/syndi/ui_action_click(mob/user, datum/actiontype)
	if(handle_tank_action(user, actiontype))
		return
	return ..()

/obj/item/clothing/suit/space/hardsuit/shielded/syndi/ui_action_click(mob/user, datum/actiontype)
	if(handle_tank_action(user, actiontype))
		return
	return ..()

/obj/item/clothing/suit/space/hardsuit/ert/ui_action_click(mob/user, datum/actiontype)
	if(handle_tank_action(user, actiontype))
		return
	return ..()

// Kombinezon założony komuś przez menu ściągania nie uruchamia się sam: blokada DNA sprawdzi noszącego dopiero przy akcji kombinezonu
/datum/strippable_item/mob_item_slot/finish_equip(atom/source, obj/item/equipping, mob/user)
	var/obj/item/clothing/suit/space/hardsuit/suit = equipping
	if(!istype(suit) || user == source)
		return ..()
	suit.dressed_by_other = TRUE
	. = ..()
	suit.dressed_by_other = FALSE

#undef HARDSUIT_BODY_SLOTS
#undef HARDSUIT_HEAD_SLOTS
#undef HARDSUIT_TANK_PRESSURE
