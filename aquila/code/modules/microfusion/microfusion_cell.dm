/*
MICROFUSION CELL SYSTEM

Microfusion cells are small battery units that house controlled nuclear fusion within, and that fusion is converted into useable energy.

Essentially, power cells that malfunction if not used in an MCR, and should only be able to charge inside of one
*/

/obj/item/stock_parts/cell/microfusion //Just a standard cell.
	name = "ogniwo microfusion"
	desc = "Standardowe ogniwo microfusion produkcji Micron Control Systems. Ze względów bezpieczeństwa da się je ładować tylko w zgodnej broni Micron Control Systems."
	icon = 'aquila/icons/microfusion/microfusion_cells.dmi'
	icon_state = "microfusion"
	w_class = WEIGHT_CLASS_NORMAL
	maxcharge = 1200 //12 shots
	chargerate = 0 //MF cells should be unable to recharge if they are not currently inside of an MCR
	ratingdesc = FALSE

	/// A hard referenced list of upgrades currently attached to the weapon.
	var/list/attachments = list()
	/// Are we melting down? For icon stuffs.
	var/meltdown = FALSE
	/// How many upgrades can you have on this cell?
	var/max_attachments = 1
	/// Hard ref to the parent gun.
	var/obj/item/gun/microfusion/parent_gun
	/// Do we play an alarm when empty?
	var/empty_alarm = TRUE
	/// What sound do we play when empty?
	var/empty_alarm_sound = 'sound/weapons/smg_empty_alarm.ogg'
	/// Do we have the self charging upgrade?
	var/self_charging = FALSE
	/// Is this cell stabilised? No sparks, no radiation.
	var/stabilised = FALSE
	/// The probability of the cell failing, either through being makeshift or being used in something it shouldn't
	var/fail_prob = 10

/obj/item/stock_parts/cell/microfusion/Initialize(mapload, override_maxcharge)
	. = ..()
	charge = 0 //MF cells should start empty
	update_appearance()

/obj/item/stock_parts/cell/microfusion/Destroy()
	if(length(attachments))
		for(var/obj/item/iterating_item as anything in attachments)
			iterating_item.forceMove(get_turf(src))
		attachments = null
	parent_gun = null
	return ..()

/obj/item/stock_parts/cell/microfusion/attackby(obj/item/attacking_item, mob/living/user, params)
	if(istype(attacking_item, /obj/item/microfusion_cell_attachment))
		add_attachment(attacking_item, user)
		return TRUE
	return ..()

/obj/item/stock_parts/cell/microfusion/attack_self(mob/user)
	if(charge)
		cell_removal_discharge()
		balloon_alert(user, "rozładowano ogniwo")
		return
	return ..()

/obj/item/stock_parts/cell/microfusion/emp_act(severity)
	var/prob_percent = charge / 100 * severity
	if(prob(prob_percent) && !meltdown && !stabilised)
		process_instability()

/obj/item/stock_parts/cell/microfusion/use(amount, force)
	if(!parent_gun) // If an MCR cell is used in anything that's not an MCR, you might have problems
		if(prob(fail_prob))
			process_instability()
	if(charge >= amount)
		var/check_if_empty = charge - amount
		if(check_if_empty < amount && empty_alarm && !self_charging)
			playsound(src, empty_alarm_sound, 50)
	return ..()

/obj/item/stock_parts/cell/microfusion/proc/process_instability()
	var/seconds_to_explode = rand(MICROFUSION_CELL_FAILURE_LOWER, MICROFUSION_CELL_FAILURE_UPPER)
	meltdown = TRUE
	say("Awaria za [seconds_to_explode / 10] sekund!")
	playsound(src, 'sound/machines/warning-buzzer.ogg', 30, FALSE, FALSE)
	add_filter("rad_glow", 2, list("type" = "outline", "color" = "#ff5e0049", "size" = 2))
	addtimer(CALLBACK(src, PROC_REF(process_failure)), seconds_to_explode)

/obj/item/stock_parts/cell/microfusion/proc/process_failure()
	var/fuckup_type = rand(1, 4)
	remove_filter("rad_glow")
	playsound(src, 'sound/effects/spray.ogg', 70)
	meltdown = FALSE
	switch(fuckup_type)
		if(MICROFUSION_CELL_FAILURE_TYPE_CHARGE_DRAIN)
			charge = clamp(charge - MICROFUSION_CELL_DRAIN_FAILURE, 0, maxcharge)
		if(MICROFUSION_CELL_FAILURE_TYPE_EXPLOSION)
			explode()
		if(MICROFUSION_CELL_FAILURE_TYPE_EMP)
			empulse(get_turf(src), MICROFUSION_CELL_EMP_HEAVY_FAILURE, MICROFUSION_CELL_EMP_LIGHT_FAILURE)
		if(MICROFUSION_CELL_FAILURE_TYPE_RADIATION)
			radiation_pulse(src, MICROFUSION_CELL_RADIATION_FAILURE)

/obj/item/stock_parts/cell/microfusion/update_icon()
	cut_overlays()
	for(var/obj/item/microfusion_cell_attachment/microfusion_cell_attachment as anything in attachments)
		add_overlay(microfusion_cell_attachment.attachment_overlay_icon_state)
	if(charge < 0.01)
		return
	else if(charge/maxcharge >= 0.995)
		add_overlay("cell-o2")
	else
		add_overlay("cell-o1")

/obj/item/stock_parts/cell/microfusion/screwdriver_act(mob/living/user, obj/item/tool)
	if(!length(attachments))
		balloon_alert(user, "brak dodatków!")
		return TRUE
	remove_attachments()
	playsound(src, 'sound/items/screwdriver.ogg', 70, TRUE)
	balloon_alert(user, "zdjęto dodatki")
	return TRUE

/obj/item/stock_parts/cell/microfusion/process(delta_time)
	for(var/obj/item/microfusion_cell_attachment/microfusion_cell_attachment as anything in attachments)
		microfusion_cell_attachment.process_attachment(src, delta_time)

/obj/item/stock_parts/cell/microfusion/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Zmieści dodatków: [max_attachments].</span>"
	. += "<span class='warning'>Wkładanie tego do czegokolwiek innego niż karabin microfusion to chyba fatalny pomysł.</span>"
	if(length(attachments))
		for(var/obj/item/microfusion_cell_attachment/microfusion_cell_attachment as anything in attachments)
			. += "<span class='notice'>Zamontowano: [microfusion_cell_attachment.name].</span>"
		. += "<span class='notice'>Dodatki zdejmiesz <b>śrubokrętem</b>.</span>"
	. += "<span class='notice'>Użycie <b>w ręce</b> rozładowuje ogniwo, jeśli ładunek blokuje włożenie go do broni microfusion.</span>"

/obj/item/stock_parts/cell/microfusion/proc/add_attachment(obj/item/microfusion_cell_attachment/microfusion_cell_attachment, mob/living/user)
	if(length(attachments) >= max_attachments)
		balloon_alert(user, "nie zmieści więcej!")
		return FALSE
	if(is_type_in_list(microfusion_cell_attachment, attachments))
		balloon_alert(user, "już zamontowano!")
		return FALSE
	if(!user.transferItemToLoc(microfusion_cell_attachment, src))
		return FALSE
	attachments += microfusion_cell_attachment
	microfusion_cell_attachment.add_attachment(src)
	balloon_alert(user, "zamontowano dodatek")
	playsound(src, 'sound/effects/pop.ogg', 70, TRUE)
	update_appearance()
	return TRUE

/obj/item/stock_parts/cell/microfusion/proc/remove_attachments()
	for(var/obj/item/microfusion_cell_attachment/microfusion_cell_attachment as anything in attachments)
		attachments -= microfusion_cell_attachment
		microfusion_cell_attachment.remove_attachment(src)
		microfusion_cell_attachment.forceMove(get_turf(src))
	update_appearance()

/obj/item/stock_parts/cell/microfusion/proc/inserted_into_weapon()
	chargerate = 300

/obj/item/stock_parts/cell/microfusion/proc/cell_removal_discharge()
	chargerate = 0
	charge = 0
	do_sparks(4, FALSE, src)
	update_appearance()

/datum/crafting_recipe/makeshift_microfusion_cell
	name = "Prowizoryczne ogniwo microfusion"
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER, TOOL_WELDER)
	result = /obj/item/stock_parts/cell/microfusion/makeshift
	reqs = list(
		/obj/item/trash/can = 1,
		/obj/item/stack/sheet/iron = 1,
		/obj/item/stack/cable_coil = 1,
	)
	time = 12 SECONDS
	category = CAT_MISC

//WHY WOULD YOU MAKE THIS?
/obj/item/stock_parts/cell/microfusion/makeshift
	name = "prowizoryczne ogniwo microfusion"
	desc = "Coś... złożonego ze zwykłej aluminiowej puszki, w którą ciasno wepchnięto kilka cywilnych baterii. Przypomina ogniwo microfusion, jeśli przechylisz głowę pod kątem dokładnie pięćdziesięciu stopni. Wrogom może nie zaszkodzi, ale gwarancji broni na pewno. Co ty sobie myślałeś?"
	icon_state = "microfusion_makeshift"
	maxcharge = 6000
	max_attachments = 0

/obj/item/stock_parts/cell/microfusion/makeshift/use(amount, force)
	if(prob(fail_prob))
		process_instability()
	return ..()

/obj/item/stock_parts/cell/microfusion/enhanced
	name = "ulepszone ogniwo microfusion"
	desc = "Ogniwo microfusion drugiej generacji. Waży tyle co standardowe i ma tyle samo miejsca na dodatki, ale mieści więcej ładunku."
	icon_state = "microfusion_enhanced"
	maxcharge = 1500

/obj/item/stock_parts/cell/microfusion/advanced
	name = "zaawansowane ogniwo microfusion"
	desc = "Ogniwo microfusion trzeciej generacji o znacznie większej liczbie strzałów. Mieści do trzech dodatków."
	icon_state = "microfusion_advanced"
	maxcharge = 1700
	max_attachments = 3

/obj/item/stock_parts/cell/microfusion/bluespace
	name = "bluespace'owe ogniwo microfusion"
	desc = "Ogniwo microfusion czwartej generacji. Trzyma energię w bluespace'owym ośrodku, który w środku jest większy niż na zewnątrz. Mieści do czterech dodatków."
	icon_state = "microfusion_bluespace"
	maxcharge = 2000
	max_attachments = 4

/obj/item/stock_parts/cell/microfusion/nanocarbon
	name = "nanowęglowe ogniwo fuzyjne"
	desc = "Łączy najnowszą nanotechnologię z zaawansowaną mikrofuzją, żeby rozwiązać odwieczny problem agentów Nanotrasen Asset Protection, czyli amunicję, samą jej ilością. Tylko do macierzy kondensatorów marki Nanotrasen. Wrzucenie do toalety unieważnia gwarancję."
	icon_state = "microfusion_nanocarbon"
	maxcharge = 30000
	max_attachments = 420
