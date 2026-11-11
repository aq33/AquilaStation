// AQUILA - odrzut jako stan postaci (wzór: Eris code/modules/mob/living/living_recoil.dm i code/datums/recoil.dm).
// Każdy strzał dodaje odrzut zależny od kalibru naboju, a odrzut co 0,1 s spada: (odrzut - 0,5) × 0,85.
// Odrzut powiększa rozrzut kolejnych strzałów, więc seria się rozjeżdża, a krótkie serie są celniejsze.
// Kamera kopie w kierunku przeciwnym do strzału (tg recoil_camera()), siła zależy od kalibru i ustawienia gracza.
// Kara za ruch z TGMC, z tempem jak w Polonium (polonium14/polonium-station#1231): w 0,5 s po kroku +1,5° rozrzutu
// po chodzie, +2,5° po biegu; sprint daje +5°, które znika w ciągu sekundy. Broń trzymana jedną ręką: dwa razy tyle.

/// Kaliber -> przyrost odrzutu (stopnie) na strzał
GLOBAL_LIST_INIT(aq_caliber_recoil, list(
	"foam_force" = 0.3,
	"mime" = 0,
	"arrow" = 1,
	"energy" = 1,
	"laser" = 1,
	"3mm" = 1,
	"6mm" = 1.5,
	"4.6x30mm" = 2,
	"9mm" = 3,
	"10mm" = 3.5,
	"38" = 3.5,
	".45" = 3.5,
	"a556" = 4,
	"mm30" = 4,
	"mm30.12" = 4.5,
	"a762" = 6,
	"n762" = 6,
	"357" = 6,
	"75" = 5,
	"shotgun" = 8,
	"40mm" = 8,
	".50" = 15,
	"84mm" = 15,
	"mm71282" = 6, // L6 SAW, 7.12x82 mm
	".310 strilka" = 6, // karabin heretyka
	"foam force" = 0.3,
	"harpoon" = 4,
	"tentacle" = 0, // macka i hak to nie broń palna
	"hook" = 0,
))

/// Domyślny przyrost odrzutu dla nieznanego kalibru
#define AQ_DEFAULT_CALIBER_RECOIL 3
/// Przelicznik odrzutu (stopnie) na kopnięcie kamery (ułamek kafla)
#define AQ_RECOIL_CAMERA_PER_DEGREE 0.012
/// Kara za strzelanie w ruchu
#define AQ_MOVE_PENALTY_TIME (0.5 SECONDS)
#define AQ_MOVE_PENALTY_SPREAD_WALK 1.5
#define AQ_MOVE_PENALTY_SPREAD 2.5
#define AQ_MOVE_PENALTY_SPREAD_SPRINT 5
/// W tym czasie po kroku sprintu kara spada od pełnej do zera
#define AQ_SPRINT_PENALTY_TIME (1 SECONDS)

/mob/living
	/// Aktualny odrzut postaci w stopniach rozrzutu
	var/aq_recoil = 0
	/// Timer zaniku odrzutu
	var/aq_recoil_timer
	/// Czy ostatni krok był chodem (m_intent walk)
	var/aq_last_move_walking = FALSE
	/// Czas ostatniego kroku sprintu
	var/aq_last_sprint_time = -INFINITY

/mob/living/Moved(atom/OldLoc, Dir)
	. = ..()
	if(!buckled && isturf(loc) && isturf(OldLoc) && loc != OldLoc)
		last_move_time = world.time // zmienna z rdzenia (atoms_movable.dm), wcześniej nieużywana
		aq_last_move_walking = (m_intent == MOVE_INTENT_WALK)
		if(committed_sprint_step())
			aq_last_sprint_time = world.time
		if(client && istype(get_active_held_item(), /obj/item/gun))
			refresh_move_cursor()

/// Czy ten ruch był krokiem sprintu zatwierdzonym przez komponent (nie forceMove w sekundę po sprincie)
/mob/living/proc/committed_sprint_step()
	return FALSE

/mob/living/carbon/committed_sprint_step()
	var/datum/component/carbon_sprint/sprint = GetComponent(/datum/component/carbon_sprint)
	return sprint?.sprinting && sprint.last_sprint_step == world.time

/// Kursor rośnie po kroku i zwęża się, gdy kara za ruch mija, także przy nieruchomej myszy
/mob/living/proc/refresh_move_cursor()
	update_gun_cursor()
	if(get_move_spread_penalty() > 0)
		addtimer(CALLBACK(src, PROC_REF(refresh_move_cursor)), 0.2 SECONDS, TIMER_UNIQUE)

/obj/item/ammo_casing
	/// Przyrost odrzutu na strzał; null = z tabeli kalibrów
	var/recoil_strength

/obj/item/ammo_casing/proc/get_recoil_strength()
	if(!isnull(recoil_strength))
		return recoil_strength
	if(!caliber) // magia, strzałki, chemia: bez odrzutu (rdzeń: „Magic has no recoil”)
		return 0
	var/table_value = GLOB.aq_caliber_recoil[caliber]
	return isnull(table_value) ? AQ_DEFAULT_CALIBER_RECOIL : table_value

/obj/item/gun
	/// Mnożnik odrzutu broni (ciężka broń i kolba trzymają lepiej)
	var/recoil_multiplier = 1

/// Ile odrzutu dodaje jeden strzał tej broni tym nabojem
/obj/item/gun/proc/get_shot_recoil(obj/item/ammo_casing/casing, mob/living/user)
	var/base = casing ? casing.get_recoil_strength() : AQ_DEFAULT_CALIBER_RECOIL
	. = base * recoil_multiplier
	if(requires_wielding && !is_wielded)
		. *= 1.5
	if(istype(user) && (!(user.mobility_flags & MOBILITY_STAND) || world.time - user.last_move_time > AQ_MOVE_PENALTY_TIME * 2))
		. *= 0.8 // postawa: leżący albo stojący w miejscu lepiej trzyma broń

/// Dodatkowy rozrzut z odrzutu postaci i ruchu
/obj/item/gun/proc/get_dynamic_spread(mob/living/user)
	if(!istype(user))
		return 0
	. = user.aq_recoil
	var/move_penalty = user.get_move_spread_penalty()
	if(requires_wielding && !is_wielded)
		move_penalty *= 2
	. += move_penalty

/// Kara za ruch w stopniach rozrzutu, zależna od tempa ostatnich kroków
/mob/living/proc/get_move_spread_penalty()
	. = 0
	if(world.time - last_move_time < AQ_MOVE_PENALTY_TIME)
		. = aq_last_move_walking ? AQ_MOVE_PENALTY_SPREAD_WALK : AQ_MOVE_PENALTY_SPREAD
	var/since_sprint = world.time - aq_last_sprint_time
	if(since_sprint < AQ_SPRINT_PENALTY_TIME)
		. = max(., AQ_MOVE_PENALTY_SPREAD_SPRINT * (1 - since_sprint / AQ_SPRINT_PENALTY_TIME))

/obj/item/gun
	/// Celność z dodatków (celowniki, laser): zmniejsza rozrzut broni, a potem dodatkowy, nigdy poniżej zera.
	/// Odejmowanie wprost od `spread` dawało ujemny rozrzut, który w rdzeniu (rand(0, spread)) dodaje niecelności.
	var/aq_attachment_accuracy = 0

/obj/item/gun/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0, aimed = FALSE)
	var/extra_spread = get_dynamic_spread(user)
	var/base_spread = spread
	if(aq_attachment_accuracy)
		// Rdzeń czyta spread od razu na początku process_fire() (seria dostaje wylosowaną wartość), więc wystarczy na czas wywołania
		var/from_base = min(aq_attachment_accuracy, max(spread, 0))
		spread -= from_base
		extra_spread = max(extra_spread - (aq_attachment_accuracy - from_base), 0)
	. = ..(target, user, message, params, zone_override, bonus_spread + extra_spread, aimed)
	spread = base_spread

/obj/item/gun/shoot_live_shot(mob/living/user, pointblank = 0, atom/pbtarget = null, message = 1)
	get_cursor_shape() // zapamiętuje kształt wystrzelonego naboju także przy wyłączonym celowniku
	. = ..()
	if(!istype(user) || tk_firing(user))
		return
	var/shot_recoil = get_shot_recoil(chambered, user)
	user.add_recoil(shot_recoil)
	// Stara zmienna recoil (losowe trzęsienie, wyłączone w rdzeniu) dokłada się do kierunkowego kopnięcia.
	// Czytana przy każdym strzale, bo część broni zmienia ją w trakcie gry (kompaktowa strzelba, obrzyn)
	var/kick = shot_recoil * AQ_RECOIL_CAMERA_PER_DEGREE + recoil * 0.05
	if(kick > 0 && pbtarget)
		recoil_camera_kick(user, kick, get_angle(pbtarget, user) + rand(-20, 20))

/mob/living/proc/add_recoil(amount)
	if(amount <= 0)
		return
	aq_recoil = min(aq_recoil + amount, AQ_RECOIL_MAX)
	on_recoil_changed()
	if(!aq_recoil_timer)
		aq_recoil_timer = addtimer(CALLBACK(src, PROC_REF(decay_recoil)), AQ_RECOIL_DECAY_INTERVAL, TIMER_STOPPABLE | TIMER_LOOP)

/mob/living/proc/decay_recoil()
	if(aq_recoil <= 0.5)
		aq_recoil = 0
		deltimer(aq_recoil_timer)
		aq_recoil_timer = null
	else
		aq_recoil = (aq_recoil - 0.5) * 0.85
	on_recoil_changed()

/// Odrzut się zmienił: odśwież kursor rozrzutu
/mob/living/proc/on_recoil_changed()
	update_gun_cursor()

/mob/living/Destroy()
	if(aq_recoil_timer)
		deltimer(aq_recoil_timer)
		aq_recoil_timer = null
	return ..()

/// Kopnięcie kamery w podanym kierunku (kąt BYOND, 0 = północ), siła w kaflach (tg recoil_camera())
/proc/recoil_camera_kick(mob/M, strength, angle)
	var/client/C = M?.client
	if(!C)
		return
	var/multiplier = C.prefs ? C.prefs.recoil_camera_strength / 100 : 1
	if(multiplier <= 0)
		return
	var/pixels = min(strength * multiplier, 0.6) * world.icon_size
	var/kick_x = round(sin(angle) * pixels, 1) // round() z jednym argumentem to podłoga: kopnięcie byłoby niesymetryczne
	var/kick_y = round(cos(angle) * pixels, 1)
	if(!kick_x && !kick_y)
		return
	animate(C, pixel_x = kick_x, pixel_y = kick_y, time = 0.5, flags = ANIMATION_RELATIVE | ANIMATION_PARALLEL)
	animate(pixel_x = -kick_x, pixel_y = -kick_y, time = 2, easing = SINE_EASING | EASE_OUT, flags = ANIMATION_RELATIVE)

#undef AQ_DEFAULT_CALIBER_RECOIL
#undef AQ_RECOIL_CAMERA_PER_DEGREE
#undef AQ_MOVE_PENALTY_TIME
#undef AQ_MOVE_PENALTY_SPREAD
#undef AQ_MOVE_PENALTY_SPREAD_WALK
#undef AQ_MOVE_PENALTY_SPREAD_SPRINT
#undef AQ_SPRINT_PENALTY_TIME
