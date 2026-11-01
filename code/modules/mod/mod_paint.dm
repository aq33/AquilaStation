#define MODPAINT_MAX_COLOR_VALUE 1.25
#define MODPAINT_MIN_COLOR_VALUE 0
#define MODPAINT_MAX_SECTION_COLORS 2
#define MODPAINT_MIN_SECTION_COLORS 0.25
#define MODPAINT_MAX_OVERALL_COLORS 4
#define MODPAINT_MIN_OVERALL_COLORS 1.5

/obj/item/mod/paint
	name = "zestaw do malowania MOD"
	desc = "Ten zestaw przemaluje twój MODsuit na coś niepowtarzalnego."
	icon = 'icons/obj/clothing/modsuit/mod_construction.dmi'
	icon_state = "paintkit"
	var/obj/item/mod/control/editing_mod
	var/atom/movable/screen/color_matrix_proxy_view/proxy_view
	var/list/current_color

/obj/item/mod/paint/Initialize(mapload)
	. = ..()
	current_color = color_matrix_identity()

/obj/item/mod/paint/examine(mob/user)
	. = ..()
	. += span_notice("Użyj go na MODsuicie, by zmienić jego skórkę albo kolory.")

// Our pre_attack returns TRUE to continue the attack chain and FALSE to stop it
/obj/item/mod/paint/pre_attack(atom/attacked_atom, mob/living/user, params)
	if(!istype(attacked_atom, /obj/item/mod/control))
		return ..()
	var/obj/item/mod/control/mod = attacked_atom
	if(mod.active || mod.activating)
		balloon_alert(user, "jednostka aktywna!")
		return FALSE
	var/choice = tgui_alert(user, "Co chcesz zrobić z: [mod]?", name, list("Zmień skórkę", "Przemaluj"))
	if(!choice || !user.is_holding(src) || !user.Adjacent(mod) || mod.active || mod.activating)
		return FALSE
	if(choice == "Zmień skórkę")
		paint_skin(mod, user)
		return FALSE
	if(editing_mod)
		return FALSE
	editing_mod = mod
	proxy_view = new()
	proxy_view.appearance = editing_mod.appearance
	proxy_view.color = null
	proxy_view.register_to_client(user.client)
	ui_interact(user)
	return FALSE

/obj/item/mod/paint/ui_interact(mob/user, datum/tgui/ui)
	if(!editing_mod)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MODpaint", name)
		ui.open()

/obj/item/mod/paint/ui_host()
	return editing_mod

/obj/item/mod/paint/ui_close(mob/user)
	. = ..()
	editing_mod = null
	QDEL_NULL(proxy_view)
	current_color = color_matrix_identity()

/obj/item/mod/paint/ui_status(mob/user)
	if(check_menu(editing_mod, user))
		return ..()
	return UI_CLOSE

/obj/item/mod/paint/ui_static_data(mob/user)
	var/list/data = list()
	data["mapRef"] = proxy_view.assigned_map
	return data

/obj/item/mod/paint/ui_data(mob/user)
	var/list/data = list()
	data["currentColor"] = current_color
	return data

/obj/item/mod/paint/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("transition_color")
			current_color = params["color"]
			animate(proxy_view, time = 0.5 SECONDS, color = current_color)
		if("confirm")
			if(length(current_color) != 20) //20 is the length of a matrix identity list
				return
			for(var/color_value in current_color)
				if(isnum(color_value))
					continue
				return
			var/total_color_value = 0
			var/list/total_colors = current_color.Copy()
			total_colors.Cut(13, length(total_colors)) // 13 to 20 are just a and c, dont want to count them
			var/red_value = current_color[1] + current_color[5] + current_color[9] //rr + gr + br
			var/green_value = current_color[2] + current_color[6] + current_color[10] //rg + gg + bg
			var/blue_value = current_color[3] + current_color[7] + current_color[11] //rb + gb + bb
			if(red_value > MODPAINT_MAX_SECTION_COLORS)
				balloon_alert(usr, "za dużo czerwieni! ([red_value*100]%/[MODPAINT_MAX_SECTION_COLORS*100]%)")
				return
			else if(red_value < MODPAINT_MIN_SECTION_COLORS)
				balloon_alert(usr, "za mało czerwieni! ([red_value*100]%/[MODPAINT_MIN_SECTION_COLORS*100]%)")
				return
			if(green_value > MODPAINT_MAX_SECTION_COLORS)
				balloon_alert(usr, "za dużo zieleni! ([green_value*100]%/[MODPAINT_MAX_SECTION_COLORS*100]%)")
				return
			else if(green_value < MODPAINT_MIN_SECTION_COLORS)
				balloon_alert(usr, "za mało zieleni! ([green_value*100]%/[MODPAINT_MIN_SECTION_COLORS*100]%)")
				return
			if(blue_value > MODPAINT_MAX_SECTION_COLORS)
				balloon_alert(usr, "za dużo niebieskiego! ([blue_value*100]%/[MODPAINT_MAX_SECTION_COLORS*100]%)")
				return
			else if(blue_value < MODPAINT_MIN_SECTION_COLORS)
				balloon_alert(usr, "za mało niebieskiego! ([blue_value*100]%/[MODPAINT_MIN_SECTION_COLORS*100]%)")
				return
			for(var/color_value in total_colors)
				total_color_value += color_value
				if(color_value > MODPAINT_MAX_COLOR_VALUE)
					balloon_alert(usr, "jeden z kolorów za wysoko! ([color_value*100]%/[MODPAINT_MAX_COLOR_VALUE*100]%)")
					return
				else if(color_value < MODPAINT_MIN_COLOR_VALUE)
					balloon_alert(usr, "jeden z kolorów za nisko! ([color_value*100]%/[MODPAINT_MIN_COLOR_VALUE*100]%)")
					return
			if(total_color_value > MODPAINT_MAX_OVERALL_COLORS)
				balloon_alert(usr, "łącznie za dużo koloru! ([total_color_value*100]%/[MODPAINT_MAX_OVERALL_COLORS*100]%)")
				return
			else if(total_color_value < MODPAINT_MIN_OVERALL_COLORS)
				balloon_alert(usr, "łącznie za mało koloru! ([total_color_value*100]%/[MODPAINT_MIN_OVERALL_COLORS*100]%)")
				return
			editing_mod.set_mod_color(current_color)
			SStgui.close_uis(src)

/obj/item/mod/paint/proc/paint_skin(obj/item/mod/control/mod, mob/user)
	if(length(mod.theme.variants) <= 1)
		balloon_alert(user, "brak innych skórek!")
		return
	var/list/skins = list()
	for(var/mod_skin in mod.theme.variants)
		skins[mod_skin] = image(icon = mod.icon, icon_state = "[mod_skin]-control")
	var/pick = show_radial_menu(user, mod, skins, custom_check = CALLBACK(src, PROC_REF(check_menu), mod, user), require_near = TRUE)
	if(!pick)
		balloon_alert(user, "nie wybrano skórki!")
		return
	mod.theme.set_skin(mod, pick)

/obj/item/mod/paint/proc/check_menu(obj/item/mod/control/mod, mob/user)
	if(user.incapacitated() || !user.is_holding(src) || !mod || mod.active || mod.activating)
		return FALSE
	return TRUE

#undef MODPAINT_MAX_COLOR_VALUE
#undef MODPAINT_MIN_COLOR_VALUE
#undef MODPAINT_MAX_SECTION_COLORS
#undef MODPAINT_MIN_SECTION_COLORS
#undef MODPAINT_MAX_OVERALL_COLORS
#undef MODPAINT_MIN_OVERALL_COLORS

/obj/item/mod/skin_applier
	name = "aplikator skórki MOD"
	desc = "Ten jednorazowy aplikator nakłada skórkę na MODsuity określonego typu."
	icon = 'icons/obj/clothing/modsuit/mod_construction.dmi'
	icon_state = "skinapplier"
	var/skin = "civilian"

/obj/item/mod/skin_applier/Initialize(mapload)
	. = ..()
	name = "aplikator skórki MOD ([skin])"

/obj/item/mod/skin_applier/pre_attack(atom/attacked_atom, mob/living/user, params)
	if(!istype(attacked_atom, /obj/item/mod/control))
		return ..()
	var/obj/item/mod/control/mod = attacked_atom
	if(mod.active || mod.activating)
		balloon_alert(user, "jednostka aktywna!")
		return FALSE
	if(!(skin in mod.theme.variants))
		balloon_alert(user, "skórka nie pasuje do modelu!")
		return FALSE
	mod.theme.set_skin(mod, skin)
	balloon_alert(user, "skórka nałożona")
	qdel(src)
	return FALSE

/obj/item/mod/skin_applier/honkerative
	skin = "honkerative"
