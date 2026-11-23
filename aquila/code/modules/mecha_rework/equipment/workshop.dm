// AQUILA - mech jako warsztat: autolat w mechu (wzór: Aurora, /obj/item/mecha_equipment/autolathe).
// Moduł ma własny magazyn materiałów (żelazo, szkło jak autolat), ładowany arkuszami użytymi na mechu albo klikiem
// w arkusze obok mecha. Projekty to te same, które zna autolat (bez hakowanych). Wydruk ląduje pod mechem.

/obj/item/mecha_parts/mecha_equipment/aq_autolathe
	name = "montowany autolat egzoszkieletu"
	desc = "Autolat zamknięty w kadłubie mecha (Aurora): drukuje przedmioty z autolatu z żelaza i szkła w magazynie modułu. Materiały ładuje się, używając arkuszy na mechu; projekt wybiera się w oknie mecha."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "aq_autolathe"
	selectable = FALSE
	aq_slot = AQ_MECHA_UTILITY
	energy_drain = 100
	mech_flags = EXOSUIT_MODULE_RIPLEY
	var/datum/techweb/specialized/autounlocking/autolathe/stored_research
	var/busy = FALSE

/obj/item/mecha_parts/mecha_equipment/aq_autolathe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/material_container, list(/datum/material/iron, /datum/material/glass), 50000, TRUE, /obj/item/stack)
	stored_research = new

/obj/item/mecha_parts/mecha_equipment/aq_autolathe/Destroy()
	QDEL_NULL(stored_research)
	return ..()

/obj/item/mecha_parts/mecha_equipment/aq_autolathe/proc/container()
	return GetComponent(/datum/component/material_container)

/obj/item/mecha_parts/mecha_equipment/aq_autolathe/get_equip_info()
	var/datum/component/material_container/mats = container()
	return "[..()] \[żelazo [round(mats.get_material_amount(/datum/material/iron) / MINERAL_MATERIAL_AMOUNT, 0.1)], szkło [round(mats.get_material_amount(/datum/material/glass) / MINERAL_MATERIAL_AMOUNT, 0.1)] ark.\] - <a href='byond://?src=[REF(src)];aq_print=1'>drukuj</a>"

/obj/item/mecha_parts/mecha_equipment/aq_autolathe/Topic(href, href_list)
	..()
	if(href_list["aq_print"] && chassis?.occupant)
		INVOKE_ASYNC(src, PROC_REF(pick_design), chassis.occupant)

/// Ładuje arkusze do magazynu modułu. Zwraca TRUE, jeśli coś weszło.
/obj/item/mecha_parts/mecha_equipment/aq_autolathe/proc/load(obj/item/stack/sheet/S, mob/user)
	if(!istype(S, /obj/item/stack/sheet/iron) && !istype(S, /obj/item/stack/sheet/glass))
		return FALSE
	var/datum/component/material_container/mats = container()
	var/inserted = mats.insert_item(S)
	if(!inserted)
		return FALSE
	if(user)
		to_chat(user, "<span class='notice'>Ładujesz materiał do autolatu mecha.</span>")
	SStgui.update_uis(chassis)
	return TRUE

/obj/item/mecha_parts/mecha_equipment/aq_autolathe/proc/available_designs()
	. = list()
	for(var/id in stored_research.researched_designs)
		var/datum/design/D = SSresearch.techweb_design_by_id(id)
		if(!D?.build_path || ("hacked" in D.category))
			continue
		.["[D.name]"] = D

/obj/item/mecha_parts/mecha_equipment/aq_autolathe/proc/pick_design(mob/user)
	if(busy)
		to_chat(user, "<span class='warning'>Autolat jeszcze drukuje.</span>")
		return
	var/list/designs = available_designs()
	var/choice = input(user, "Co wydrukować?", "Autolat mecha") as null|anything in sortList(designs)
	if(!choice || !chassis || chassis.occupant != user)
		return
	print(designs[choice], user)

/// Koszt projektu w prawdziwych materiałach: kategoria (MAT_CATEGORY_*) zamieniona na materiał z magazynu, którego
/// wystarczy (autolat pyta o wybór, tu bierzemy pierwszy). Null, gdy czegoś brakuje.
/obj/item/mecha_parts/mecha_equipment/aq_autolathe/proc/design_cost(datum/design/D)
	var/datum/component/material_container/mats = container()
	var/list/cost = list()
	for(var/mat in D.materials)
		var/datum/material/used = mat
		if(istext(mat))
			used = null
			for(var/datum/material/M as anything in SSmaterials.materials_by_category[mat])
				if(mats.materials[M] >= D.materials[mat])
					used = M
					break
			if(!used)
				return null
		cost[used] += D.materials[mat]
	if(!length(cost) || !mats.has_materials(cost))
		return null
	return cost

/obj/item/mecha_parts/mecha_equipment/aq_autolathe/proc/print(datum/design/D, mob/user)
	var/datum/component/material_container/mats = container()
	var/list/cost = design_cost(D)
	if(!cost)
		if(user)
			to_chat(user, "<span class='warning'>Za mało materiałów na: [D.name].</span>")
		return FALSE
	if(!chassis.has_charge(energy_drain))
		return FALSE
	if(!mats.use_materials(cost))
		return FALSE
	busy = TRUE
	chassis.use_power(energy_drain)
	playsound(chassis, 'sound/machines/click.ogg', 40, TRUE)
	sleep(max(1 SECONDS, (D.construction_time || 32) / 2))
	busy = FALSE
	if(!chassis)
		return FALSE
	var/atom/A = new D.build_path(chassis.drop_location())
	if(isitem(A))
		var/obj/item/I = A
		I.set_custom_materials(cost)
	chassis.occupant_message("<span class='notice'>Autolat wydrukował: [A.name].</span>")
	return TRUE

/obj/mecha/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/sheet/iron) || istype(W, /obj/item/stack/sheet/glass))
		for(var/obj/item/mecha_parts/mecha_equipment/aq_autolathe/lathe in equipment)
			if(lathe.load(W, user))
				return
	return ..()
