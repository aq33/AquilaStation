// AQUILA - kursor pokazujący rozrzut (wzór: Eris update_cursor(), celownik z rozsuwanymi rogami) i obracanie postaci
// do kursora w combat mode (wzór: Nova/Monke face cursor).
// U nas kursor liczy rozrzut z odległości do kursora: rozrzut to kąt, więc na 10 kratek koło jest większe niż na 2.
// Pozycję kursora daje NSV13-owe /client/MouseMove (mousemove_intercept_objects), które i tak przychodzi z klienta.

/// Ile stanów ma aquila/icons/effects/gun_cursor.dmi (odstęp rogów od środka w pikselach: 4 + stan)
#define AQ_GUN_CURSOR_STATES 41
/// Rozrzut liczymy dla tej odległości, gdy nie znamy położenia kursora (piksele, ok. 6 kratek)
#define AQ_GUN_CURSOR_DEFAULT_DISTANCE 192
/// Co ile pikseli zmienia się rozmiar kursora. Każdy rozmiar to osobny plik kursora, który klient pobiera i podmienia,
/// więc kursor co piksel przy szybkim ruchu myszy dawał przycięcia
#define AQ_GUN_CURSOR_SIZE_STEP 4
/// Kształty celownika (pliki aquila/icons/effects/gun_cursor*.dmi, generator opisany w opisie PR-a)
#define AQ_CURSOR_STANDARD "standard"
#define AQ_CURSOR_SCOPE "scope"
#define AQ_CURSOR_PELLETS "pellets"
#define AQ_CURSOR_GRID "grid"
#define AQ_CURSOR_RING "ring"
#define AQ_CURSOR_DASHED "dashed"
#define AQ_CURSOR_CLOUD "cloud"
#define AQ_CURSOR_TOY "toy"

/// Kształt celownika -> plik z 41 stanami (polonium14/polonium-station#1231: kształt zależny od broni)
GLOBAL_LIST_INIT(aq_gun_cursor_files, list(
	AQ_CURSOR_STANDARD = 'aquila/icons/effects/gun_cursor.dmi',
	AQ_CURSOR_SCOPE = 'aquila/icons/effects/gun_cursor_scope.dmi',
	AQ_CURSOR_PELLETS = 'aquila/icons/effects/gun_cursor_pellets.dmi',
	AQ_CURSOR_GRID = 'aquila/icons/effects/gun_cursor_grid.dmi',
	AQ_CURSOR_RING = 'aquila/icons/effects/gun_cursor_ring.dmi',
	AQ_CURSOR_DASHED = 'aquila/icons/effects/gun_cursor_dashed.dmi',
	AQ_CURSOR_CLOUD = 'aquila/icons/effects/gun_cursor_cloud.dmi',
	AQ_CURSOR_TOY = 'aquila/icons/effects/gun_cursor_toy.dmi',
))

/// "kształt-rozmiar" -> ikona kursora z jednym stanem "" (BYOND bierze kursor ze stanu domyślnego)
GLOBAL_LIST_EMPTY(aq_gun_cursor_icons)

/proc/aq_get_gun_cursor_icon(size, shape = AQ_CURSOR_STANDARD)
	size = clamp(round(size), 0, AQ_GUN_CURSOR_STATES - 1)
	if(!GLOB.aq_gun_cursor_files[shape])
		shape = AQ_CURSOR_STANDARD
	var/key = "[shape]-[size]"
	var/icon/cached = GLOB.aq_gun_cursor_icons[key]
	if(cached)
		return cached
	var/icon/result = new
	result.Insert(icon(GLOB.aq_gun_cursor_files[shape], "[size]"), "")
	// Plik z cache zasobów: client.mouse_pointer_icon po przypisaniu /icon trzyma odnośnik do cache, więc porównanie
	// z obiektem /icon w update_gun_cursor() nigdy nie wychodziło i kursor przestawał się zmieniać
	var/cached_file = fcopy_rsc(result)
	GLOB.aq_gun_cursor_icons[key] = cached_file
	return cached_file

/obj/item/gun
	/// Kształt celownika tej broni (AQ_CURSOR_*)
	var/aq_cursor_shape = AQ_CURSOR_STANDARD
	/// Kształt z ostatniego naboju w komorze ("" = nabój bez własnego); pusta broń go zachowuje
	var/aq_last_ammo_cursor_shape

/// Kształt celownika: nabój z własnym kształtem (śrut, piankowe strzałki) wygrywa z kształtem broni
/obj/item/gun/proc/get_cursor_shape()
	if(chambered)
		aq_last_ammo_cursor_shape = chambered.get_cursor_shape() || ""
	return aq_last_ammo_cursor_shape || aq_cursor_shape

/// Własny kształt celownika naboju albo null
/obj/item/ammo_casing/proc/get_cursor_shape()
	if(pellets > 1)
		return AQ_CURSOR_PELLETS
	return null

/obj/item/ammo_casing/caseless/foam_dart/get_cursor_shape()
	return AQ_CURSOR_TOY

/// Nowy nabój w komorze (przeładowanie, obrót bębna, zmiana trybu): odśwież celownik trzymającego, jeśli zmienił się kształt
/obj/item/gun/proc/on_chamber_changed()
	var/old_shape = aq_last_ammo_cursor_shape
	get_cursor_shape()
	if(old_shape != aq_last_ammo_cursor_shape && isliving(loc))
		var/mob/living/holder = loc
		holder.update_gun_cursor()

/obj/item/gun/ballistic/chamber_round(keep_bullet = FALSE)
	. = ..()
	on_chamber_changed()

// Rewolwer i łuk mają własne chamber_round() bez ..()
/obj/item/gun/ballistic/revolver/chamber_round(spin_cylinder = TRUE)
	. = ..()
	on_chamber_changed()

/obj/item/gun/ballistic/bow/chamber_round()
	. = ..()
	on_chamber_changed()

/obj/item/gun/energy/select_fire(mob/living/user)
	. = ..()
	on_chamber_changed()

/obj/item/gun/ballistic/automatic/sniper_rifle
	aq_cursor_shape = AQ_CURSOR_SCOPE

/obj/item/gun/grenadelauncher
	aq_cursor_shape = AQ_CURSOR_GRID

/obj/item/gun/ballistic/revolver/grenadelauncher
	aq_cursor_shape = AQ_CURSOR_GRID

/obj/item/gun/ballistic/rocketlauncher
	aq_cursor_shape = AQ_CURSOR_GRID

/obj/item/gun/blastcannon
	aq_cursor_shape = AQ_CURSOR_GRID

/obj/item/gun/syringe
	aq_cursor_shape = AQ_CURSOR_GRID

/obj/item/gun/ballistic/bow
	aq_cursor_shape = AQ_CURSOR_RING

/obj/item/gun/energy/kinetic_accelerator/crossbow
	aq_cursor_shape = AQ_CURSOR_RING

/obj/item/gun/chem
	aq_cursor_shape = AQ_CURSOR_DASHED

/obj/item/gun/magic
	aq_cursor_shape = AQ_CURSOR_CLOUD

/obj/item/gun/ballistic/automatic/toy
	aq_cursor_shape = AQ_CURSOR_TOY

/obj/item/gun/ballistic/shotgun/toy
	aq_cursor_shape = AQ_CURSOR_TOY

/client
	/// Pokazujemy kursor rozrzutu (żeby nie nadpisać kursora czaru albo mecha)
	var/icon/aq_gun_cursor_shown

/mob/living
	/// Śledzi położenie kursora (rozrzut, obracanie do kursora)
	var/datum/aq_mouse_tracker/aq_mouse_tracker
	/// Położenie kursora względem środka widoku, w pikselach
	var/aq_cursor_dx = 0
	var/aq_cursor_dy = 0
	var/aq_cursor_known = FALSE

/mob/living/Login()
	. = ..()
	if(!aq_mouse_tracker)
		aq_mouse_tracker = new(src)
	LAZYOR(mousemove_intercept_objects, aq_mouse_tracker)

/mob/living/Logout()
	if(aq_mouse_tracker)
		LAZYREMOVE(mousemove_intercept_objects, aq_mouse_tracker)
	return ..()

/mob/living/Destroy()
	if(aq_mouse_tracker)
		LAZYREMOVE(mousemove_intercept_objects, aq_mouse_tracker)
		QDEL_NULL(aq_mouse_tracker)
	return ..()

/datum/aq_mouse_tracker
	var/mob/living/owner
	/// Kiedy ostatnio obrócono postać i przeliczono kursor (najwyżej raz na tick)
	var/last_update = -1
	/// Czeka timer z odświeżeniem po ostatnim ruchu w tym ticku
	var/update_pending = FALSE

/datum/aq_mouse_tracker/New(mob/living/new_owner)
	owner = new_owner

/datum/aq_mouse_tracker/Destroy(force, ...)
	owner = null
	return ..()

/datum/aq_mouse_tracker/onMouseMove(object, location, control, params)
	if(!owner?.client)
		return
	// Bez broni w ręku i poza trybem walki położenia kursora nic nie czyta: bez parsowania przy każdym ruchu myszy
	if(!owner.combat_mode && !istype(owner.get_active_held_item(), /obj/item/gun))
		return
	var/list/modifiers = params2list(params)
	var/screen_loc = modifiers["screen-loc"]
	if(!screen_loc)
		return
	var/list/offsets = aq_screen_loc_to_view_offset(owner.client, screen_loc)
	if(!offsets)
		return
	owner.aq_cursor_dx = offsets[1]
	owner.aq_cursor_dy = offsets[2]
	owner.aq_cursor_known = TRUE
	// Szybki ruch myszy to kilkanaście wywołań na tick: obrót, kursor rozrzutu i wiązka lasera liczą się raz na tick,
	// a ostatnia pozycja z ticku dochodzi timerem w następnym
	if(last_update == world.time)
		if(!update_pending)
			update_pending = TRUE
			addtimer(CALLBACK(src, PROC_REF(apply_cursor_update)), world.tick_lag)
		return
	apply_cursor_update()

/// Obraca postać do kursora i odświeża kursor rozrzutu według ostatniej znanej pozycji kursora
/datum/aq_mouse_tracker/proc/apply_cursor_update()
	update_pending = FALSE
	last_update = world.time
	if(QDELETED(owner) || !owner.client)
		return FALSE
	owner.face_cursor_if_needed()
	owner.update_gun_cursor()
	return TRUE

/// screen-loc kursora -> przesunięcie w pikselach od środka widoku (jak calculate_projectile_angle_and_pixel_offsets())
/proc/aq_screen_loc_to_view_offset(client/C, screen_loc)
	var/list/screen_loc_params = splittext(screen_loc, ",")
	if(length(screen_loc_params) < 2)
		return null
	var/list/screen_loc_X = splittext(screen_loc_params[1], ":")
	var/list/screen_loc_Y = splittext(screen_loc_params[2], ":")
	if(length(screen_loc_X) < 2 || length(screen_loc_Y) < 2)
		return null
	var/x = text2num(screen_loc_X[1]) * world.icon_size + text2num(screen_loc_X[2]) - world.icon_size
	var/y = text2num(screen_loc_Y[1]) * world.icon_size + text2num(screen_loc_Y[2]) - world.icon_size
	var/list/screenview = getviewsize(C.view)
	var/origin_x = round(screenview[1] * world.icon_size / 2) - C.pixel_x
	var/origin_y = round(screenview[2] * world.icon_size / 2) - C.pixel_y
	return list(x - origin_x, y - origin_y)

// --- Obracanie do kursora ---

/// Czy postać ma się obracać do kursora (combat mode albo intencja harm i włączone ustawienie)
/mob/living/proc/should_face_cursor()
	if(!client?.prefs?.face_cursor_combat || !combat_mode || !aq_cursor_known)
		return FALSE
	if(stat != CONSCIOUS || buckled || !(mobility_flags & MOBILITY_MOVE) || incapacitated())
		return FALSE
	if(abs(aq_cursor_dx) < world.icon_size / 2 && abs(aq_cursor_dy) < world.icon_size / 2)
		return FALSE // kursor na własnej postaci
	return TRUE

/// Kierunek (N/S/E/W) od postaci do kursora
/mob/living/proc/get_cursor_facing_dir()
	if(abs(aq_cursor_dx) > abs(aq_cursor_dy))
		return aq_cursor_dx > 0 ? EAST : WEST
	return aq_cursor_dy > 0 ? NORTH : SOUTH

/mob/living/proc/face_cursor_if_needed()
	if(!should_face_cursor())
		return
	var/new_dir = get_cursor_facing_dir()
	if(new_dir != dir)
		setDir(new_dir)

// W combat mode postać nie odwraca się w stronę ruchu: idzie bokiem albo tyłem, cały czas patrząc na kursor (Nova).
// Blokujemy zmianę kierunku u źródła, zamiast obracać postać z powrotem po kroku (to dawało migotanie).
/mob/living/setDir(newdir)
	if(client && aq_cursor_known && combat_mode && should_face_cursor())
		newdir = get_cursor_facing_dir()
	var/old_dir = dir
	. = ..(newdir)
	// Miniatura broni w ręku jest rysowana pod konkretny kierunek, więc po obrocie trzeba ją przerysować
	if(dir != old_dir && client)
		var/obj/item/gun/held_gun = get_active_held_item()
		if(istype(held_gun) && held_gun.is_aim_posed(src))
			update_inv_hands()

// --- Kursor rozrzutu ---

/// Połowa kąta stożka rozrzutu następnego strzału (tak jak liczy go process_fire(): ±0,55 × (rozrzut broni + dodatkowy))
/obj/item/gun/proc/get_spread_cone(mob/living/user)
	var/base_spread = max(spread, 0)
	var/extra_spread = get_dynamic_spread(user)
	if(aq_attachment_accuracy)
		var/from_base = min(aq_attachment_accuracy, base_spread)
		base_spread -= from_base
		extra_spread = max(extra_spread - (aq_attachment_accuracy - from_base), 0)
	if(requires_wielding && !is_wielded)
		extra_spread += spread_unwielded
	if(HAS_TRAIT(user, TRAIT_POOR_AIM))
		extra_spread += 25
	var/total = base_spread + extra_spread
	if(chambered)
		total += chambered.variance
	return max(total * 0.55, 0)

/// Ikona kursora dla trzymanej broni albo null
/mob/living/proc/get_gun_cursor_icon()
	if(!client?.prefs?.gun_cursor)
		return null
	var/obj/item/gun/held_gun = get_active_held_item()
	if(!istype(held_gun) || held_gun.aq_firemode == AQ_FIREMODE_SAFE)
		return null
	return aq_get_gun_cursor_icon(get_gun_cursor_size(held_gun), held_gun.get_cursor_shape())

/// Stan ikony kursora = promień stożka rozrzutu w pikselach przy kursorze. Stan 0 ma już 4 px odstępu od środka,
/// więc promień się do niego dodaje (odejmowanie 4 px chowało pojedyncze strzały i bieg, rósł tylko śrut)
/mob/living/proc/get_gun_cursor_size(obj/item/gun/held_gun)
	var/distance = aq_cursor_known ? sqrt(aq_cursor_dx ** 2 + aq_cursor_dy ** 2) : AQ_GUN_CURSOR_DEFAULT_DISTANCE
	var/half_angle = min(held_gun.get_spread_cone(src), 60)
	// zaokrąglenie co AQ_GUN_CURSOR_SIZE_STEP px: mniej plików kursora do podmiany przy szybkim ruchu myszy
	return round(tan(half_angle) * max(distance, world.icon_size), AQ_GUN_CURSOR_SIZE_STEP)


/mob/living/proc/update_gun_cursor()
	if(!client)
		return
	var/icon/wanted = get_gun_cursor_icon()
	var/current = client.mouse_pointer_icon
	if(wanted)
		// Zmieniamy tylko zwykły kursor albo nasz własny, nie kursor czaru, mecha czy podglądu
		if(current == initial(client.mouse_pointer_icon) || (client.aq_gun_cursor_shown && current == client.aq_gun_cursor_shown))
			if(current != wanted)
				client.mouse_pointer_icon = wanted
			client.aq_gun_cursor_shown = wanted
	else if(client.aq_gun_cursor_shown)
		if(current == client.aq_gun_cursor_shown)
			client.mouse_pointer_icon = initial(client.mouse_pointer_icon)
		client.aq_gun_cursor_shown = null

/mob/living/update_mouse_pointer()
	. = ..()
	if(client)
		client.aq_gun_cursor_shown = null
	update_gun_cursor()

/obj/item/gun/equipped(mob/living/user, slot)
	. = ..()
	if(istype(user))
		user.update_gun_cursor()

/obj/item/gun/dropped(mob/user)
	. = ..()
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.update_gun_cursor()

/obj/item/gun/set_firemode(new_mode, mob/user, silent = FALSE)
	. = ..()
	if(isliving(loc))
		var/mob/living/holder = loc
		holder.update_gun_cursor()

/obj/item/gun/wield()
	. = ..()
	if(isliving(loc))
		var/mob/living/holder = loc
		holder.update_gun_cursor()

/obj/item/gun/unwield()
	. = ..()
	if(isliving(loc))
		var/mob/living/holder = loc
		holder.update_gun_cursor()

#undef AQ_GUN_CURSOR_STATES
#undef AQ_CURSOR_STANDARD
#undef AQ_CURSOR_SCOPE
#undef AQ_CURSOR_PELLETS
#undef AQ_CURSOR_GRID
#undef AQ_CURSOR_RING
#undef AQ_CURSOR_DASHED
#undef AQ_CURSOR_CLOUD
#undef AQ_CURSOR_TOY
#undef AQ_GUN_CURSOR_DEFAULT_DISTANCE
#undef AQ_GUN_CURSOR_SIZE_STEP
