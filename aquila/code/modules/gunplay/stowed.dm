// AQUILA - broń widoczna na postaci, gdy wisi na pasie, w slocie pancerza albo na plecach.
// Pliki ubrań (belt.dmi, belt_mirror.dmi, back.dmi) mają stany tylko dla kilku strzelb, więc reszta broni była
// niewidoczna. Gdy stanu brakuje, sprite składamy z ikony samej broni (pomniejszonej i obróconej, osobno dla każdego
// kierunku) i trzymamy w pamięci na typ ikony. Broń, która ma własny sprite w pliku ubrań, rysuje się po staremu.
// - pas: mała broń na prawym biodrze, lufą w dół;
// - slot pancerza: mała broń na lewym biodrze, większa przewieszona przez plecy;
// - plecy: przewieszona po skosie; z przodu widać wylot nad ramieniem i kolbę przy biodrze.
// Pozy sprawdzone w Dream Seeker 516 na pistolecie, C-20r, karabinie laserowym i strzelbie.

/// Poza -> list(skala, list("kierunek" = list(obrót, odbicie, środek x, środek y, [wytnij tułów])))
GLOBAL_LIST_INIT(aq_stowed_gun_poses, list(
	"hip" = list(0.5, list("[SOUTH]" = list(90, FALSE, 10, 12), "[NORTH]" = list(90, TRUE, 23, 12), "[EAST]" = list(110, FALSE, 15, 12))),
	"hip_left" = list(0.5, list("[SOUTH]" = list(90, TRUE, 23, 12), "[NORTH]" = list(90, FALSE, 10, 12), "[WEST]" = list(110, TRUE, 17, 12))),
	"sling" = list(0.65, list("[NORTH]" = list(-45, FALSE, 16, 17), "[SOUTH]" = list(-45, TRUE, 16, 17, TRUE), "[EAST]" = list(-75, FALSE, 10, 17), "[WEST]" = list(-75, TRUE, 23, 17))),
))

/// "ikona|stan|poza" -> złożona ikona z czterema kierunkami
GLOBAL_LIST_EMPTY(aq_stowed_gun_icons)
/// "plik|stan" -> czy plik ubrań ma ten stan (icon_states() jest drogie)
GLOBAL_LIST_EMPTY(aq_worn_state_cache)

/proc/aq_worn_state_exists(file, state)
	if(!file || isnull(state))
		return FALSE
	var/key = "[file]|[state]"
	. = GLOB.aq_worn_state_cache[key]
	if(isnull(.))
		. = icon_exists(file, state) ? TRUE : FALSE
		GLOB.aq_worn_state_cache[key] = .

/proc/aq_build_stowed_gun_icon(gun_icon, gun_state, pose)
	var/list/definition = GLOB.aq_stowed_gun_poses[pose]
	var/scale = definition[1]
	var/list/directions = definition[2]
	var/icon/result = new
	for(var/direction in GLOB.cardinals)
		var/icon/canvas = icon('icons/effects/effects.dmi', "nothing")
		var/list/placement = directions["[direction]"]
		if(placement)
			var/icon/part = icon(gun_icon, gun_state, SOUTH, 1)
			part.Scale(max(round(part.Width() * scale), 1), max(round(part.Height() * scale), 1))
			if(placement[2])
				part.Flip(EAST)
			part.Turn(placement[1])
			canvas.Blend(part, ICON_OVERLAY, placement[3] - round(part.Width() / 2) + 1, placement[4] - round(part.Height() / 2) + 1)
			if(length(placement) >= 5 && placement[5])
				canvas.DrawBox(null, 11, 4, 21, 24) // przód: broń jest za tułowiem, widać tylko końce
		result.Insert(canvas, "", direction)
	return result

/// Mała broń wisi przy biodrze, większa na plecach
/obj/item/gun/proc/get_stow_pose(slot_layer)
	if(slot_layer == BELT_LAYER)
		return "hip"
	var/small = weapon_weight <= WEAPON_LIGHT && w_class <= WEIGHT_CLASS_NORMAL
	if(slot_layer == SUIT_STORE_LAYER && small)
		return "hip_left"
	return "sling"

/obj/item/gun/proc/get_stowed_appearance(slot_layer)
	var/pose = get_stow_pose(slot_layer)
	var/key = "[icon]|[icon_state]|[pose]"
	var/icon/stowed_icon = GLOB.aq_stowed_gun_icons[key]
	if(!stowed_icon)
		stowed_icon = aq_build_stowed_gun_icon(icon, icon_state, pose)
		GLOB.aq_stowed_gun_icons[key] = stowed_icon
	var/mutable_appearance/stowed = mutable_appearance(stowed_icon, "", -slot_layer)
	stowed.alpha = alpha
	stowed.color = color
	return stowed

// Pas i plecy idą przez build_worn_icon() (feel.dm dokłada w nim pozę broni w dłoni)
/obj/item/gun/build_worn_icon(default_layer = 0, default_icon_file = null, isinhands = FALSE, femaleuniform = NO_FEMALE_UNIFORM, override_state = null, special_override_flags = NONE)
	if(!isinhands && !override_state && (default_layer == BELT_LAYER || default_layer == BACK_LAYER))
		var/worn_state = worn_icon_state || icon_state
		var/worn_file = worn_icon || default_icon_file
		if(!aq_worn_state_exists(worn_file, worn_state))
			return get_stowed_appearance(default_layer)
	return ..()

// Slot pancerza rysuje się wprost z belt_mirror.dmi, bez build_worn_icon()
/mob/living/carbon/human/update_inv_s_store()
	. = ..()
	var/obj/item/gun/stored_gun = s_store
	if(!istype(stored_gun))
		return
	if(aq_worn_state_exists('icons/mob/clothing/belt_mirror.dmi', stored_gun.item_state || stored_gun.icon_state))
		return
	remove_overlay(SUIT_STORE_LAYER)
	var/mutable_appearance/stowed = stored_gun.get_stowed_appearance(SUIT_STORE_LAYER)
	if(OFFSET_S_STORE in dna?.species.offset_features)
		stowed.pixel_x += dna.species.offset_features[OFFSET_S_STORE][1]
		stowed.pixel_y += dna.species.offset_features[OFFSET_S_STORE][2]
	overlays_standing[SUIT_STORE_LAYER] = stowed
	apply_overlay(SUIT_STORE_LAYER)
