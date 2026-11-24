/// AQUILA - skala wizualna overmapy.
/// Okręty na poziomach overmapy rysują się mniejsze: OVERMAP_VISUAL_SCALE × proporcja typu (proporcje ze zrzutów: stare duże
/// sprite'y i Padalec 1, Atlas i Von Neumann 1,5, myśliwce 0,5). Odległości, prędkości, zasięgi, AI i hitboksy zostają jak
/// dawniej: zmienia się tylko macierz rysowania (hook w /obj/structure/overmap/process(), physics.dm).
/// Okręty z nowymi sprite'ami (ship_sprites.dm) rysują się 1:1 ze swoich pikseli i proporcji nie mają.
/// Aspala dostaje z powrotem dawny duży sprite; hitbox liczy się wtedy z dzisiejszego sprite'a (overmap_hitbox_icon),
/// a środek rysunku stoi tam, gdzie był środek dzisiejszego sprite'a.
/// Efekt trafienia pocisku rysuje się na obrysie kadłuba, a nie przy rogu hitboksu.
/// Obrysy sprite'ów: tools/overmap_scale/sprite_bounds.py -> overmap_sprite_bounds.dm
/// Myśliwce na pokładzie (hangar, doki) rysują się dwa razy większe, żeby w kabinie zmieścił się człowiek; hitbox na
/// pokładzie (2×2 pola) zostaje, więc myśliwiec dalej mieści się w wyrzutniach i drzwiach hangaru.

/obj/structure/overmap
	/// AQUILA - rozmiar na mapie względem proporcji ze zrzutów; null = 1, a dla MASS_TINY OVERMAP_TINY_PROPORTION
	var/overmap_display_proportion
	/// AQUILA - sprite, z którego liczony jest hitbox, gdy okręt rysuje się innym (starym, dużym) sprite'em
	var/overmap_hitbox_icon
	var/overmap_hitbox_state
	/// AQUILA - rozmiar poza overmapą (na pokładzie okrętu)
	var/deck_display_proportion = 1

/obj/structure/overmap/small_craft/combat
	deck_display_proportion = 2

// Myśliwce Syndykatu zostają ×1: stoją w zatokach map PvP i we wnętrzach abordażu lotniskowców, które nie mają miejsca na ×2
/obj/structure/overmap/small_craft/combat/light/syndicate
	deck_display_proportion = 1

/// Obrys stanu ikony z tabeli generowanej: list(klatka x, klatka y, kadłub x, kadłub y, przesunięcie środka x, y) albo null
/proc/overmap_sprite_bounds_of(icon_file, state)
	return GLOB.overmap_sprite_bounds["[icon_file]|[state]"]

/// Łączna skala rysowania w tym miejscu: poza poziomami overmapy deck_display_proportion (promy w dokach 1, myśliwce 2)
/obj/structure/overmap/proc/overmap_display_scale()
	if(!z || !SSmapping.level_trait(z, ZTRAIT_OVERMAP))
		return deck_display_proportion
	if(uses_native_sprite())
		return 1
	var/proportion = overmap_display_proportion
	if(isnull(proportion))
		proportion = (mass <= MASS_TINY) ? OVERMAP_TINY_PROPORTION : 1
	return OVERMAP_VISUAL_SCALE * proportion

/// Obrys sprite'a, którym okręt się rysuje
/obj/structure/overmap/proc/overmap_display_bounds()
	// nowe sprite'y nie mają stanów uszkodzeń, a frachtowce i małe jednostki zmieniają stan w grze
	return overmap_sprite_bounds_of(icon, uses_native_sprite() ? icon_state : initial(icon_state))

/// Obrys sprite'a, z którego liczony jest hitbox (dzisiejszy wygląd)
/obj/structure/overmap/proc/overmap_hitbox_bounds()
	if(overmap_hitbox_icon)
		return overmap_sprite_bounds_of(overmap_hitbox_icon, overmap_hitbox_state)
	return overmap_display_bounds()

/// Dokłada do macierzy obrotu skalę wizualną i przesunięcie, które trzyma środek kadłuba w środku dzisiejszego sprite'a.
/// BYOND obraca i skaluje wokół środka klatki ikony, więc bez przesunięcia stary sprite w większej klatce albo kadłub
/// przesunięty w klatce odjechałby od hitboksu.
/obj/structure/overmap/proc/apply_overmap_display(matrix/M, rot_angle)
	var/k = overmap_display_scale()
	var/list/disp = overmap_display_bounds()
	var/list/ref = overmap_hitbox_bounds()
	if(k == 1 && !overmap_hitbox_icon)
		return
	M.Scale(k, k)
	if(!disp || !ref)
		return
	// środek kadłuba = środek klatki + obrócone przesunięcie środka; dzisiejszy sprite rysował się bez skali
	var/off_x = ref[5] - k * disp[5]
	var/off_y = ref[6] - k * disp[6]
	var/c = cos(rot_angle)
	var/s = sin(rot_angle)
	M.Translate((ref[1] - disp[1]) / 2 + off_x * c + off_y * s, (ref[2] - disp[2]) / 2 - off_x * s + off_y * c)

/// Ustawia hitbox z dzisiejszego sprite'a i od razu rysuje okręt w skali (zanim fizyka zrobi pierwszy tik)
/obj/structure/overmap/proc/apply_overmap_hitbox()
	var/list/ref = overmap_hitbox_bounds()
	if(overmap_hitbox_icon && ref)
		pixel_collision_size_x = ref[1]
		pixel_collision_size_y = ref[2]
	var/matrix/M = matrix()
	M.Turn(angle)
	apply_overmap_display(M, angle)
	transform = M

/obj/structure/overmap/Initialize(mapload)
	. = ..()
	apply_overmap_hitbox()

/// Punkt na obrysie kadłuba najbliższy kierunkowi, z którego przyleciał pocisk, w pikselach względem lewego dolnego
/// rogu pola okrętu. Kadłub przybliżony elipsą o półosiach z obrysu sprite'a; pocisk już w środku zostaje na miejscu.
/obj/structure/overmap/proc/overmap_hull_point(px, py)
	var/list/local = overmap_hull_local(px, py)
	if(!local)
		return null
	var/c = cos(angle)
	var/s = sin(angle)
	return list(local[5] + local[1] * c + local[2] * s, local[6] - local[1] * s + local[2] * c)

/// Ten sam punkt obrysu w układzie okrętu (dziób = +y, prawa burta = +x):
/// list(x, y, półoś szerokości, półoś długości, środek kadłuba x, środek kadłuba y)
/obj/structure/overmap/proc/overmap_hull_local(px, py)
	var/list/disp = overmap_display_bounds()
	var/list/ref = overmap_hitbox_bounds()
	if(!disp || !ref)
		return null
	var/k = overmap_display_scale()
	var/c = cos(angle)
	var/s = sin(angle)
	var/cx = ref[1] / 2 + ref[5] * c + ref[6] * s + pixel_x
	var/cy = ref[2] / 2 - ref[5] * s + ref[6] * c + pixel_y
	var/dx = px - cx
	var/dy = py - cy
	var/lx = dx * c - dy * s
	var/ly = dx * s + dy * c
	var/a = max(4, disp[3] * k / 2)
	var/b = max(4, disp[4] * k / 2)
	var/r = sqrt((lx / a) ** 2 + (ly / b) ** 2)
	if(r > 1)
		lx /= r
		ly /= r
	return list(lx, ly, a, b, cx, cy)

/obj/structure/overmap/bullet_act(obj/item/projectile/P)
	. = ..()
	if(QDELETED(src) || QDELETED(P) || !P.impact_effect_type)
		return
	if(. == BULLET_ACT_FORCE_PIERCE || (!isnull(.) && !.)) // tarcza wchłonęła albo odbiła pocisk
		return
	if(overmap_display_scale() == 1 && !overmap_hitbox_icon)
		return
	var/list/point = overmap_hull_point((P.x - x) * 32 + P.pixel_x + 16, (P.y - y) * 32 + P.pixel_y + 16)
	if(!point)
		return
	new P.impact_effect_type(get_turf(src), point[1] - 16, point[2] - 16)
	P.impact_effect_type = null // projectile/on_hit narysowałby drugi efekt przy rogu hitboksu

// Proporcje ze zrzutów: Von Neumann jest na nich półtora raza większy od dzisiejszego sprite'a
/obj/structure/overmap/nanotrasen/solgov/vnc
	overmap_display_proportion = 1.5

// Stary duży sprite dla Aspali (okręt bez nowego sprite'a)

/obj/structure/overmap/syndicate/ai/submarine
	icon = 'nsv13/icons/overmap/syndicate/submarine.dmi'
	icon_state = "submarine"
	damage_states = TRUE
	overmap_hitbox_icon = 'nsv13/icons/overmap/new/syndicate/cruiser.dmi'
	overmap_hitbox_state = "aspala"

/obj/structure/overmap/syndicate/ai/submarine/elite
	icon_state = "submarine"
	overmap_hitbox_state = "aspala_elite"
