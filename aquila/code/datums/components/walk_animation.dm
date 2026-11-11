/**
 * Animacja chodu: ręce i nogi ruszają się przy każdym kroku, niezależnie od stroju.
 *
 * Mob rysuje się tylko do bufora (render_target z "*"), a pięć fragmentów w jego vis_contents
 * pokazuje ten obraz przycięty maskami alfa: tułów, dwie ręce i dwie nogi. Ubranie i nakładki
 * są więc cięte razem z ciałem. Przedmioty w dłoniach są kopiowane na osobne fragmenty ("hand_1" lewa,
 * "hand_2" prawa) i pokazywane w całości, ruszając się razem ze swoją ręką.
 * Maski są kierunkowe (aquila/icons/mob/walk_masks.dmi) i wspólne dla wszystkich mobów: 20 obiektów ekranu
 * (5 masek x 4 kierunki, /atom/movable/screen/walk_mask) dokładanych każdemu klientowi razem z plane masterami.
 * Fragment ciała wskazuje filtrem maskę dla bieżącego kierunku moba (update_mask_dir).
 * Klient bez tych obiektów na ekranie widzi całe ciało (tułów z MASK_INVERSE i pustą maską), tylko bez ruchu kończyn.
 * "arm_a"/"leg_a" to strona lewa na ekranie przy widoku z przodu i z tyłu; w widoku z boku
 * "arm_a" to ręka bliżej patrzącego, a "leg_a" i "leg_b" pokazują obie nogi w pełnej szerokości.
 * Z boku "leg_b" jest widoczna tylko w trakcie kroku, żeby w spoczynku nogi nie były rysowane podwójnie.
 * Z boku "arm_b" jest pusta: dalsza dłoń, która w sprite'ach wystaje 1 px przed brzuch, jest wycięta na stałe.
 * Części mutanckie z warstw BODY_BEHIND_LAYER i BODY_FRONT_LAYER (ogony, skrzydła, czułki, uszy, kolce) oraz skrzydła
 * z BODY_ADJ_LAYER też są przenoszone na osobne fragmenty bez masek ("parts_behind" pod ciałem, "parts_front" nad nim),
 * bo maski rąk i nóg wycinały z nich kawałki i ruszały nimi razem z kończynami. Reszta BODY_ADJ_LAYER (znaczenia
 * na ciele) zostaje w buforze, bo leży na kończynach i ma się z nimi ruszać. Każdy z tych fragmentów ma własną
 * blokadę emisji, bo blokada ciała widzi tylko bufor.
 *
 * Bufor i filtry masek kosztują klienta w każdej klatce (pomiar: raport/perf_02_przyciecia_animacja_chodu.md),
 * więc są podpięte tylko w ruchu. W spoczynku mob rysuje się zwykle, a fragmenty i maski są zdjęte z vis_contents.
 * Pierwszy krok je podpina (activate), a po WALK_ANIMATION_IDLE_DELAY bez kroku są zdejmowane (deactivate).
 */

/// Ile po ostatnim kroku (ponad czas jego animacji) fragmenty zostają podpięte. Krótsza przerwa w marszu ich nie zdejmuje.
#define WALK_ANIMATION_IDLE_DELAY (1 SECONDS)

/datum/component/walk_animation
	/// Bufor, do którego rysuje się mob
	var/body_target
	/// render_target moba sprzed podpięcia komponentu (blokada emisji)
	var/old_render_target
	/// Nazwa maski -> fragment ciała, który ją pokazuje
	var/list/limbs = list()
	/// Nazwa maski -> flagi filtra alpha_mask
	var/list/mask_flags = list()
	/// Kierunek, dla którego fragmenty wskazują teraz maski
	var/mask_dir
	/// Blokada emisji dla nowego bufora; stara czyta render_target, który tu podmieniamy
	var/atom/movable/emissive_blocker/em_block
	/// Która para ręka/noga rusza się przy tym kroku
	var/phase = FALSE
	/// Czy przedmioty w dłoniach są teraz za ciałem (widok z tyłu)
	var/held_behind = FALSE
	/// Kotwice bufora ciała (nakładki moba, podpinane razem z buforem)
	var/list/body_anchors
	/// Czy bufor, maski i fragmenty są teraz podpięte do moba
	var/active = FALSE
	/// world.time, po którym fragmenty można zdjąć
	var/idle_after = 0
	/// Czy czeka już timer sprawdzający bezruch
	var/idle_check_pending = FALSE
	/// Warstwa moba -> nakładki części mutanckich zdjęte z niej na czas ruchu (oddawane w deactivate)
	var/list/detached_parts = list()
	/// Blokady emisji fragmentów "parts_behind" i "parts_front"
	var/list/part_em_blocks = list()

/datum/component/walk_animation/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/carbon/human/H = parent

	body_target = "*walk_body[REF(H)]"
	body_anchors = walk_animation_bounds_anchors()
	em_block = new(null, body_target)

	// Nogi pod tułowiem (wysuwana z boku nad tylną), ręce nad nim
	add_limb(H, "leg_a", FLOAT_LAYER - 0.2)
	add_limb(H, "leg_b", FLOAT_LAYER - 0.15)
	add_limb(H, "torso_cut", FLOAT_LAYER - 0.1, MASK_INVERSE)
	add_limb(H, "arm_a", FLOAT_LAYER - 0.05)
	add_limb(H, "arm_b", FLOAT_LAYER - 0.05)
	// Przedmioty w dłoniach nad wszystkim, jak HANDS_LAYER; tyłem pod ciałem (update_held_dir)
	for(var/index in 1 to 2)
		var/obj/effect/overlay/walk_held/held = new
		limbs["hand_[index]"] = held
	// Części mutanckie bez masek: tylne pod wszystkimi fragmentami ciała, przednie nad nimi (jak BODY_BEHIND_LAYER i BODY_FRONT_LAYER)
	var/obj/effect/overlay/walk_held/parts_behind = new
	parts_behind.layer = H.layer - 0.002
	limbs["parts_behind"] = parts_behind
	var/obj/effect/overlay/walk_held/parts_front = new
	parts_front.layer = FLOAT_LAYER + 0.01
	limbs["parts_front"] = parts_front
	for(var/state in list("parts_behind", "parts_front"))
		var/obj/effect/overlay/walk_held/fragment = limbs[state]
		fragment.render_target = "walk_[state][REF(H)]" // bez "*": fragment rysuje się normalnie, a blokada emisji go kopiuje
		part_em_blocks += new /atom/movable/emissive_blocker(null, fragment.render_target)

	RegisterSignal(H, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(H, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_dir_change))

/datum/component/walk_animation/Destroy()
	var/mob/living/carbon/human/H = parent
	if(H)
		UnregisterSignal(H, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE))
		deactivate()
	QDEL_NULL(em_block)
	QDEL_LIST(part_em_blocks)
	QDEL_LIST_ASSOC_VAL(limbs)
	return ..()

/// Podpina bufor ciała, maski i fragmenty. Wołane przy pierwszym kroku po spoczynku.
/datum/component/walk_animation/proc/activate()
	if(active)
		return
	var/mob/living/carbon/human/H = parent
	active = TRUE
	old_render_target = H.render_target
	H.render_target = body_target
	H.add_overlay(body_anchors)
	var/list/attached = list(em_block) + part_em_blocks
	for(var/state in limbs)
		attached += limbs[state]
	H.vis_contents += attached
	update_mask_dir(H.dir)
	update_side_leg(H.dir)
	update_held_dir(H.dir)
	detach_held_items()
	detach_mutant_parts()

/// Zdejmuje bufor, maski i fragmenty; mob znowu rysuje się zwykle, z przedmiotami w dłoniach jako nakładkami.
/datum/component/walk_animation/proc/deactivate()
	if(!active)
		return
	var/mob/living/carbon/human/H = parent
	active = FALSE
	if(H.render_target == body_target)
		H.render_target = old_render_target
	H.cut_overlay(body_anchors)
	var/list/attached = list(em_block) + part_em_blocks
	for(var/state in limbs)
		var/obj/effect/overlay/limb = limbs[state]
		animate(limb, pixel_w = 0, pixel_z = 0, time = 0) // przerwany krok nie może zostać wychylony na następny raz
		attached += limb
	H.vis_contents -= attached
	for(var/index in 1 to 2)
		var/obj/effect/overlay/walk_held/held = limbs["hand_[index]"]
		held.cut_overlays()
	restore_mutant_parts()
	// Przedmioty w dłoniach były zdjęte z moba, więc budujemy je od nowa
	if(!QDELETED(H))
		H.update_inv_hands()

/// Zdejmuje fragmenty, gdy od ostatniego kroku minęło dość czasu; inaczej sprawdza ponownie później.
/datum/component/walk_animation/proc/check_idle()
	idle_check_pending = FALSE
	if(!active || QDELING(src))
		return
	if(world.time < idle_after)
		idle_check_pending = TRUE
		addtimer(CALLBACK(src, PROC_REF(check_idle)), idle_after - world.time)
		return
	deactivate()

/datum/component/walk_animation/proc/add_limb(mob/living/carbon/human/H, state, layer, flags)
	var/obj/effect/overlay/walk_limb/limb = new
	limb.layer = layer
	limb.render_source = body_target
	limbs[state] = limb
	mask_flags[state] = flags

/// Ustawia fragmentom ciała wspólne maski dla kierunku moba. Ukośne kierunki rysują się jak wschód/zachód.
/datum/component/walk_animation/proc/update_mask_dir(new_dir)
	var/key = walk_mask_dir(new_dir)
	if(key == mask_dir)
		return
	mask_dir = key
	for(var/state in mask_flags)
		var/obj/effect/overlay/walk_limb/limb = limbs[state]
		limb.add_filter("walk_mask", 1, alpha_mask_filter(render_source = "*walk_mask_[state]_[key]", flags = mask_flags[state]))

/// BYOND 516 (1648) zmienił kotwiczenie obrazu z render_source, a bufor jest przycinany do tego, co się
/// w nim narysowało. Bez wystających nakładek obraz ciała rozjeżdżał się z maskami (zostawał wąski pasek).
/// Dwa prawie przezroczyste piksele w rogach obszaru 96x96 wokół kafla dają buforom ciała i masek stały
/// rozmiar; sprawdzone w Dream Seeker 516 dla zwykłego i zmienionego wzrostu oraz leżenia, bez przesunięć.
/proc/walk_animation_bounds_anchors()
	var/mutable_appearance/lower_left = mutable_appearance('aquila/icons/mob/walk_masks.dmi', "anchor_ll")
	lower_left.pixel_x = -world.icon_size
	lower_left.pixel_y = -world.icon_size
	var/mutable_appearance/upper_right = mutable_appearance('aquila/icons/mob/walk_masks.dmi', "anchor_ur")
	upper_right.pixel_x = world.icon_size
	upper_right.pixel_y = world.icon_size
	return list(lower_left, upper_right)

/// Przenosi przedmioty z dłoni 1 i 2 na fragmenty "hand_1"/"hand_2", żeby maski ich nie cięły.
/// Fragment dostaje kopię nakładki, a kierunek ustawia mu update_held_dir(), więc sprite obraca się z postacią.
/// Oryginał jest zdejmowany z moba: nakładka z render_target "*" nie znikała z bufora ciała i rysowała się drugi raz.
/// Wołane po każdym update_inv_hands().
/datum/component/walk_animation/proc/detach_held_items()
	if(!active || QDELING(src)) // w spoczynku i przy usuwaniu przedmioty zostają zwykłymi nakładkami
		return
	var/mob/living/carbon/human/H = parent
	for(var/index in 1 to 2)
		var/obj/effect/overlay/walk_held/held = limbs["hand_[index]"]
		held.cut_overlays()
	var/list/hand_overlays = H.overlays_standing[HANDS_LAYER]
	if(!length(hand_overlays))
		return
	H.remove_overlay(HANDS_LAYER)
	// update_inv_hands() buduje listę w kolejności held_items, pomijając puste dłonie
	var/list/kept_overlays = list()
	var/overlay_index = 0
	for(var/obj/item/I in H.held_items)
		overlay_index++
		if(overlay_index > length(hand_overlays))
			break
		var/hand_index = H.get_held_index_of_item(I)
		var/mutable_appearance/hand_overlay = hand_overlays[overlay_index]
		if(hand_index > 2 || !istype(hand_overlay))
			kept_overlays += hand_overlay
			continue
		var/obj/effect/overlay/walk_held/held = limbs["hand_[hand_index]"]
		held.add_overlay(hand_overlay)
	H.overlays_standing[HANDS_LAYER] = kept_overlays
	H.apply_overlay(HANDS_LAYER)

/// Przenosi części mutanckie na fragmenty "parts_behind"/"parts_front", żeby maski ich nie cięły:
/// całe BODY_BEHIND_LAYER i BODY_FRONT_LAYER oraz skrzydła z BODY_ADJ_LAYER (reszta tej warstwy leży na kończynach).
/// Wołane przy podpięciu i po każdym handle_mutant_bodyparts(), które buduje te warstwy od nowa.
/datum/component/walk_animation/proc/detach_mutant_parts()
	if(!active || QDELING(src))
		return
	var/mob/living/carbon/human/H = parent
	var/obj/effect/overlay/walk_held/parts_behind = limbs["parts_behind"]
	var/obj/effect/overlay/walk_held/parts_front = limbs["parts_front"]
	parts_behind.cut_overlays()
	parts_front.cut_overlays()
	// Kotwice jak w buforze ciała: bufor fragmentu jest przycinany do narysowanej zawartości, a blokada emisji ma do niego pasować
	parts_behind.add_overlay(body_anchors)
	parts_front.add_overlay(body_anchors)
	detached_parts.Cut()
	for(var/layer in list(BODY_BEHIND_LAYER, BODY_ADJ_LAYER, BODY_FRONT_LAYER))
		var/list/layer_overlays = H.overlays_standing[layer]
		if(!length(layer_overlays))
			continue
		var/list/moved = list()
		var/list/kept_overlays = list()
		for(var/mutable_appearance/part as anything in layer_overlays)
			if(layer != BODY_ADJ_LAYER || (istype(part) && findtext(part.icon_state, "wings")))
				moved += part
			else
				kept_overlays += part
		if(!length(moved))
			continue
		H.remove_overlay(layer)
		H.overlays_standing[layer] = kept_overlays
		H.apply_overlay(layer)
		detached_parts["[layer]"] = moved
		var/obj/effect/overlay/walk_held/fragment = (layer == BODY_BEHIND_LAYER) ? parts_behind : parts_front
		fragment.add_overlay(moved)

/// Oddaje części mutanckie z fragmentów na ich warstwy moba.
/datum/component/walk_animation/proc/restore_mutant_parts()
	var/obj/effect/overlay/walk_held/parts_behind = limbs["parts_behind"]
	var/obj/effect/overlay/walk_held/parts_front = limbs["parts_front"]
	parts_behind.cut_overlays()
	parts_front.cut_overlays()
	var/mob/living/carbon/human/H = parent
	if(!QDELETED(H))
		for(var/layer_key in detached_parts)
			var/layer = text2num(layer_key)
			var/list/layer_overlays = H.overlays_standing[layer]
			H.remove_overlay(layer)
			H.overlays_standing[layer] = (layer_overlays || list()) + detached_parts[layer_key]
			H.apply_overlay(layer)
	detached_parts.Cut()

/datum/component/walk_animation/proc/on_moved(mob/living/carbon/human/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	if(forced || !isturf(old_loc) || get_dist(old_loc, source) != 1)
		return
	if(source.buckled || source.lying || source.throwing || !(source.mobility_flags & MOBILITY_STAND))
		return
	if(source.movement_type & (FLYING|FLOATING|VENTCRAWLING) || !source.has_gravity())
		return

	// Czas jednego kroku w decysekundach, odtworzony z glide_size (odwrotność DELAY_TO_GLIDE_SIZE).
	var/half_step = (world.icon_size / max(source.glide_size, 1)) * world.tick_lag / 2
	activate()
	idle_after = world.time + half_step * 2 + WALK_ANIMATION_IDLE_DELAY
	if(!idle_check_pending)
		idle_check_pending = TRUE
		addtimer(CALLBACK(src, PROC_REF(check_idle)), idle_after - world.time)
	phase = !phase
	update_side_leg(source.dir)

	if(source.dir & (EAST|WEST))
		// Z boku: tylna noga cofa się, a pełna kopia nóg wysuwa się w przód.
		// Ręka wisi przy samych plecach, więc wychyla się tylko w przód (co drugi krok), żeby nie wystawać za obrys.
		// Dalsza dłoń jest ukryta za ciałem; przedmiot w niej cofa się o 1 px, gdy bliższa ręka idzie w przód.
		var/forward = (source.dir & EAST) ? 1 : -1
		swing("leg_a", -forward, 0, half_step)
		var/obj/effect/overlay/walk_limb/front_leg = limbs["leg_b"]
		animate(front_leg, alpha = 255, time = 0)
		animate(pixel_w = forward, time = half_step, easing = SINE_EASING | EASE_OUT)
		animate(pixel_w = 0, time = half_step, easing = SINE_EASING | EASE_IN)
		animate(alpha = 0, time = 0)
		if(phase)
			swing_arm("arm_a", forward, 0, half_step)
			swing(held_item_of("arm_b", source.dir), -forward, 0, half_step)
	else
		// Z przodu i z tyłu: unosi się jedna noga i ręka po przeciwnej stronie
		swing(phase ? "leg_a" : "leg_b", 0, 1, half_step)
		swing_arm(phase ? "arm_b" : "arm_a", 0, 1, half_step)

/datum/component/walk_animation/proc/on_dir_change(mob/living/carbon/human/source, old_dir, new_dir)
	SIGNAL_HANDLER

	if(!active) // activate() ustawi kierunek przy następnym kroku
		return
	update_mask_dir(new_dir)
	update_side_leg(new_dir)
	update_held_dir(new_dir)

/// Nakładki na fragmentach przedmiotów biorą kierunek z samego fragmentu, a VIS_INHERIT_DIR go nie zmienia,
/// więc ustawiamy go wprost. Tyłem fragment z przedmiotem dostaje zwykłą (dodatnią) warstwę tuż pod
/// warstwą moba, więc rysuje się pod wszystkimi fragmentami ciała.
/datum/component/walk_animation/proc/update_held_dir(new_dir)
	var/mob/living/carbon/human/H = parent
	var/behind = (new_dir == NORTH)
	for(var/index in 1 to 2)
		var/obj/effect/overlay/walk_held/held = limbs["hand_[index]"]
		held.dir = new_dir
		if(behind || held_behind)
			held.layer = behind ? H.layer - 0.001 : FLOAT_LAYER
	held_behind = behind
	for(var/state in list("parts_behind", "parts_front"))
		var/obj/effect/overlay/walk_held/parts = limbs[state]
		parts.dir = new_dir

/// Z boku maska "leg_b" pokrywa się z "leg_a", więc w spoczynku ta noga jest ukryta; z przodu i z tyłu zawsze widoczna.
/datum/component/walk_animation/proc/update_side_leg(new_dir)
	var/obj/effect/overlay/walk_limb/leg = limbs["leg_b"]
	var/target_alpha = (new_dir & (EAST|WEST)) ? 0 : 255
	if(leg.alpha != target_alpha)
		animate(leg, alpha = target_alpha, pixel_w = 0, pixel_z = 0, time = 0)

/// Fragment z przedmiotem z dłoni, która w danym widoku należy do ręki "arm_a" lub "arm_b".
/// Prawa dłoń to "arm_a" przy widoku z przodu (lewa strona ekranu) i na wschód (ręka bliżej patrzącego).
/datum/component/walk_animation/proc/held_item_of(arm, facing)
	var/right_is_a = (facing & (EAST|WEST)) ? (facing & EAST) : (facing & SOUTH)
	return ((arm == "arm_a") == !!right_is_a) ? "hand_2" : "hand_1"

/// Rusza ręką razem z trzymanym w niej przedmiotem.
/datum/component/walk_animation/proc/swing_arm(arm, x, y, half_step)
	var/mob/living/carbon/human/H = parent
	swing(arm, x, y, half_step)
	swing(held_item_of(arm, H.dir), x, y, half_step)

/// Przesuwa fragment o (x, y) pikseli i wraca na miejsce w czasie jednego kroku.
/datum/component/walk_animation/proc/swing(state, x, y, half_step)
	var/obj/effect/overlay/limb = limbs[state]
	animate(limb, pixel_w = x, pixel_z = y, time = half_step, easing = SINE_EASING | EASE_OUT)
	animate(pixel_w = 0, pixel_z = 0, time = half_step, easing = SINE_EASING | EASE_IN)

/// Czy ktoś widzi zamiast tego atomu obraz z override (przebranie za kwiatek, mały sprite).
/// Taki obraz podmienia appearance, ale nie vis_contents, więc fragmenty animacji chodu rysowałyby się na nim.
/atom/proc/has_override_alt_appearance()
	for(var/key in alternate_appearances)
		var/datum/atom_hud/alternate_appearance/basic/appearance = alternate_appearances[key]
		if(istype(appearance) && appearance.theImage?.override)
			return TRUE
	return FALSE

/datum/atom_hud/alternate_appearance/basic/add_to_hud(atom/A)
	. = ..()
	if(. && theImage?.override && ishuman(A))
		var/mob/living/carbon/human/H = A
		H.update_walk_animation()

/datum/atom_hud/alternate_appearance/basic/remove_from_hud(atom/A)
	var/had_override = theImage?.override
	. = ..()
	if(. && had_override && ishuman(A) && !QDELETED(A))
		var/mob/living/carbon/human/H = A
		H.update_walk_animation()

/// Fragment ciała: obraz moba z bufora przycięty maską.
/// Bufor zawiera już kolor, przezroczystość i obrót moba, więc nie dziedziczymy ich drugi raz.
/obj/effect/overlay/walk_limb
	name = ""
	plane = FLOAT_PLANE
	layer = FLOAT_LAYER
	appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART | PIXEL_SCALE | TILE_BOUND
	vis_flags = VIS_INHERIT_ID

/// Przedmiot z jednej dłoni jako nakładka, bez przycinania maskami ciała.
/// Dziedziczy kolor, przezroczystość i obrót moba, tak jak zwykła nakładka; kierunek z update_held_dir().
/obj/effect/overlay/walk_held
	name = ""
	plane = FLOAT_PLANE
	layer = FLOAT_LAYER
	appearance_flags = KEEP_APART | PIXEL_SCALE | TILE_BOUND
	vis_flags = VIS_INHERIT_ID

/datum/species/handle_mutant_bodyparts(mob/living/carbon/human/H, forced_colour)
	. = ..()
	var/datum/component/walk_animation/walk_animation = H.GetComponent(/datum/component/walk_animation)
	walk_animation?.detach_mutant_parts()

/// Kierunek wspólnej maski dla kierunku moba (ikona masek ma 4 kierunki).
/proc/walk_mask_dir(dir)
	if(dir & EAST)
		return EAST
	if(dir & WEST)
		return WEST
	if(dir & NORTH)
		return NORTH
	return SOUTH

GLOBAL_LIST_EMPTY(walk_mask_screens)

/// Wspólne maski fragmentów ciała, po jednej na maskę i kierunek. Tworzone raz, przy pierwszym kliencie.
/proc/get_walk_mask_screens()
	if(!length(GLOB.walk_mask_screens))
		for(var/state in list("leg_a", "leg_b", "torso_cut", "arm_a", "arm_b"))
			for(var/mask_dir in GLOB.cardinals)
				GLOB.walk_mask_screens += new /atom/movable/screen/walk_mask(null, state, mask_dir)
	return GLOB.walk_mask_screens

/// Maska fragmentu ciała na ekranie klienta. Niewidoczna, rysuje się tylko do własnego bufora,
/// z którego czytają filtry fragmentów wszystkich mobów idących w tym kierunku.
/// Inicjalizacja od razu: maski powstają przy pierwszym kliencie, także w trakcie startu serwera, a obiektu
/// w nullspace SSatoms potem nie inicjalizuje (bez render_target chód nie działał nikomu do końca rundy).
INITIALIZE_IMMEDIATE(/atom/movable/screen/walk_mask)

/atom/movable/screen/walk_mask
	name = ""
	icon = 'aquila/icons/mob/walk_masks.dmi'
	screen_loc = "CENTER"
	appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/walk_mask/Initialize(mapload, state, mask_dir)
	. = ..()
	icon_state = state
	dir = mask_dir
	render_target = "*walk_mask_[state]_[mask_dir]"
	add_overlay(walk_animation_bounds_anchors()) // ten sam obszar co bufor ciała, niezależnie od tego, jak filtr kotwiczy maskę

/datum/hud/plane_masters_update()
	. = ..()
	mymob.client.screen |= get_walk_mask_screens()

#undef WALK_ANIMATION_IDLE_DELAY
