// AQUILA - radial w stylu SS14: półprzezroczysta tarcza podzielona na sektory, podświetlony sektor pod myszą,
// nazwa (i opis z /datum/radial_menu_choice.info) nad tarczą, okrągły przycisk zamknięcia w środku.
// Grafika: aquila/icons/hud/radial_ss14.dmi (stany 128x128: sector_<kąt> i _focus dla każdej szerokości sektora,
// jaką daje update_screen_objects(), oraz radial_center). Menu z własną ikoną (kult krwi, radial_icon) zostają po staremu.
// Sektor to sam przycisk: obrócony transformem obiekt slice, więc klik i najechanie łapie cały wycinek tarczy,
// a ikona opcji siedzi w osobnym obiekcie (icon_holder), który przepuszcza mysz.

#define RADIAL_SS14_ICON 'aquila/icons/hud/radial_ss14.dmi'
/// Odległość ikon od środka przy skali 1 (sektory w .dmi mają promień 19-62 px)
#define RADIAL_SS14_RADIUS 40
/// Stan 128 px położony na kaflu 32 px: środek ikony na środku kafla
#define RADIAL_SS14_OFFSET -48
/// Najdłuższy opis opcji w podpisie nad tarczą (dłuższy jest pod przyciskiem informacji)
#define RADIAL_SS14_MAX_INFO 160

/datum/radial_menu
	/// Tarcza z sektorami zamiast kółek (wszystkie menu poza tymi z własną ikoną radial_icon)
	var/ss14_style = FALSE
	/// Podpis nad tarczą z nazwą opcji pod myszą
	var/atom/movable/screen/radial/title/title
	/// Sektor, którego nazwa jest teraz w podpisie
	var/atom/movable/screen/radial/slice/title_owner

/atom/movable/screen/radial/slice
	/// Stan sektora bez podświetlenia ("sector_60"), null w starym stylu
	var/sector_state
	/// Ikona opcji: osobny obiekt, bo sektor jest obrócony, a ikona ma stać prosto
	var/atom/movable/screen/radial/slice_icon/icon_holder

/atom/movable/screen/radial/slice/Destroy()
	QDEL_NULL(icon_holder)
	return ..()

/atom/movable/screen/radial/slice/MouseEntered(location, control, params)
	. = ..()
	if(sector_state && parent?.ss14_style)
		icon_state = "[sector_state]_focus"
		parent.show_title(src)

/atom/movable/screen/radial/slice/MouseExited(location, control, params)
	. = ..()
	if(sector_state && parent?.ss14_style)
		icon_state = sector_state
		parent.hide_title(src)

/atom/movable/screen/radial/slice_icon
	icon = null
	layer = RADIAL_CONTENT_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/radial/title
	icon = null
	layer = RADIAL_CONTENT_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	maptext_width = 256
	maptext_height = 48
	maptext_x = -112

/datum/radial_menu/setup_menu(use_tooltips)
	ss14_style = !radial_icon
	if(ss14_style)
		use_tooltips = FALSE // nazwa jest w podpisie nad tarczą, dymek by ją dublował
		close_button.icon = RADIAL_SS14_ICON
		close_button.pixel_x = RADIAL_SS14_OFFSET
		close_button.pixel_y = RADIAL_SS14_OFFSET + py_shift
		if(!title)
			title = new
			title.set_parent(src)
		var/scale = radial_ss14_scale()
		title.pixel_y = round(world.icon_size / 2 + 62 * scale) + 2 + py_shift
		title.maptext = null
	return ..(use_tooltips)

/// Skala tarczy: menu z większym promieniem (RCD, płytki, cyborgi) dostaje większą tarczę
/datum/radial_menu/proc/radial_ss14_scale()
	return max(radius, RADIAL_SS14_RADIUS) / RADIAL_SS14_RADIUS

/// Stan sektora o danej szerokości. W .dmi są wszystkie szerokości z update_screen_objects(); inna (zmieniony
/// min_angle albo restrict_to_dir) dostaje najbliższą
/datum/radial_menu/proc/radial_sector_state(width)
	var/static/list/widths = list(28, 32, 37, 45, 51, 56, 60, 72, 75, 90, 112, 120, 180, 225, 360)
	var/best = widths[1]
	for(var/candidate in widths)
		if(abs(candidate - width) < abs(best - width))
			best = candidate
	return "sector_[best]"

// Pełne nadpisanie w stylu SS14 (bez ..()): bazowa wersja kładzie kółko z ikoną w nakładce na pozycji opcji,
// a tu sektor zostaje na środku i obraca się transformem, ikona idzie do osobnego obiektu (LEGACY_OVERRIDES.md)
/datum/radial_menu/SetElement(atom/movable/screen/radial/slice/E, choice_id, angle, anim, anim_order)
	if(!ss14_style)
		return ..()
	var/scale = radial_ss14_scale()
	var/distance = RADIAL_SS14_RADIUS * scale
	var/py = round(cos(angle) * distance) + py_shift
	var/px = round(sin(angle) * distance)
	var/list/page_choices = page_data[current_page]

	E.icon = RADIAL_SS14_ICON
	E.sector_state = radial_sector_state(round(zone / length(page_choices)))
	// Sektor pod myszą (np. po „Następnej stronie”) zostaje podświetlony, bo MouseEntered nie przyjdzie drugi raz
	E.icon_state = title_owner == E ? "[E.sector_state]_focus" : E.sector_state
	E.pixel_x = RADIAL_SS14_OFFSET
	E.pixel_y = RADIAL_SS14_OFFSET + py_shift
	var/matrix/sector_matrix = matrix()
	sector_matrix.Scale(scale)
	sector_matrix.Turn(angle)

	var/atom/movable/screen/radial/slice_icon/holder = E.icon_holder
	if(!holder)
		holder = new
		holder.set_parent(src)
		E.icon_holder = holder
	if(menu_holder)
		menu_holder.vis_contents |= holder

	if(anim)
		var/timing = anim_order * 0.5
		var/matrix/sector_start = matrix()
		sector_start.Scale(0.1 * scale)
		sector_start.Turn(angle)
		E.transform = sector_start
		animate(E, transform = sector_matrix, time = timing)
		var/matrix/icon_start = matrix()
		icon_start.Scale(0.1)
		holder.pixel_x = 0
		holder.pixel_y = py_shift
		holder.transform = icon_start
		animate(holder, pixel_x = px, pixel_y = py, transform = matrix(), time = timing)
	else
		E.transform = sector_matrix
		holder.transform = null
		holder.pixel_x = px
		holder.pixel_y = py

	E.alpha = 255
	holder.alpha = 255
	E.mouse_opacity = MOUSE_OPACITY_ICON
	E.maptext = null
	E.cut_overlays()
	E.vis_contents.Cut()
	clear_icon_holder(holder)
	if(choice_id == NEXT_PAGE_ID)
		E.name = "Następna strona"
		E.next_page = TRUE
		E.choice = null
		holder.add_overlay(mutable_appearance('icons/mob/radial.dmi', "radial_next"))
	else
		var/value = choices_values[choice_id]
		if(istext(value))
			E.name = value
		else if(ispath(value, /atom))
			var/atom/path = value
			E.name = initial(path.name)
		else
			var/atom/movable/AM = value
			E.name = AM.name
		E.choice = choice_id
		E.next_page = FALSE
		if(choices_icons[choice_id])
			holder.add_overlay(choices_icons[choice_id])
		var/datum/radial_menu_choice/choice_datum = choice_datums[choice_id]
		if(choice_datum?.info)
			var/obj/effect/abstract/info/info_button = new(holder, choice_datum.info)
			info_button.layer = RADIAL_CONTENT_LAYER
			info_button.plane = ABOVE_HUD_PLANE
			info_button.mouse_opacity = MOUSE_OPACITY_ICON
			holder.vis_contents += info_button
	if(title_owner == E)
		show_title(E)

/datum/radial_menu/HideElement(atom/movable/screen/radial/slice/E)
	. = ..()
	if(E.icon_holder)
		clear_icon_holder(E.icon_holder)
		E.icon_holder.alpha = 0
	if(title_owner == E)
		hide_title(E)

/// Czyści ikonę opcji. Przyciski informacji leżą w contents holdera (new(holder)), więc samo vis_contents.Cut()
/// zostawiało je tam przy każdej zmianie strony albo opcji
/datum/radial_menu/proc/clear_icon_holder(atom/movable/screen/radial/slice_icon/holder)
	holder.cut_overlays()
	holder.vis_contents.Cut()
	for(var/obj/effect/abstract/info/old_info in holder)
		qdel(old_info)

/// Podpis nad tarczą: nazwa opcji i krótki opis, jeśli opcja go ma
/datum/radial_menu/proc/show_title(atom/movable/screen/radial/slice/E)
	if(!title)
		return
	title_owner = E
	var/text = "<b>[html_encode(E.name)]</b>"
	var/datum/radial_menu_choice/choice_datum = E.choice ? choice_datums[E.choice] : null
	if(istext(choice_datum?.info) && length_char(choice_datum.info) <= RADIAL_SS14_MAX_INFO)
		text += "<br><font color='#b9c0d8'>[choice_datum.info]</font>"
	title.maptext = MAPTEXT("<div align='center' valign='bottom' style='-dm-text-outline: 1px #0d1020'>[text]</div>")

/datum/radial_menu/proc/hide_title(atom/movable/screen/radial/slice/E)
	if(!title || title_owner != E)
		return
	title_owner = null
	title.maptext = null

/datum/radial_menu/show_to(mob/M)
	. = ..()
	if(!ss14_style || !menu_holder)
		return
	for(var/atom/movable/screen/radial/slice/E as anything in elements)
		if(E.icon_holder)
			menu_holder.vis_contents |= E.icon_holder
	if(title)
		menu_holder.vis_contents |= title

/datum/radial_menu/Destroy()
	title_owner = null
	if(menu_holder)
		menu_holder.vis_contents.Cut()
	QDEL_NULL(title)
	return ..()

#undef RADIAL_SS14_ICON
#undef RADIAL_SS14_RADIUS
#undef RADIAL_SS14_OFFSET
#undef RADIAL_SS14_MAX_INFO
