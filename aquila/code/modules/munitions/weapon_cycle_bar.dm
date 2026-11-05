/**
 * Pasek postępu nad bronią statkową na czas jej własnych etapów: podawania, komorowania,
 * wyjmowania z komory i rozładunku. Ręczne ładowanie ma pasek do_after tylko u ładującego,
 * a dalsze etapy broń robi sama, więc dotąd nic nie pokazywało, ile jeszcze potrwają.
 * Pasek widzi każdy, kto widzi broń. Grafika ta sama co w do_after (icons/effects/progessbar.dmi).
 */

/// Krótszych etapów (np. szybkie komorowanie railguna) nie pokazujemy, pasek tylko by mignął.
#define WEAPON_CYCLE_BAR_MIN_DELAY 5
/// Na ile kroków dzielimy etap. Grafika ma stany co 5%, więc 20 kroków wystarcza na płynny pasek.
#define WEAPON_CYCLE_BAR_STEPS 20
/// Czas pojawiania się i znikania paska, jak w /datum/progressbar.
#define WEAPON_CYCLE_BAR_FADE 5

/obj/machinery/ship_weapon
	/// Pasek etapu w vis_contents, tworzony przy pierwszym etapie
	var/obj/effect/overlay/weapon_cycle_bar/cycle_bar
	/// Ile etapów pokazuje teraz pasek (etapy mogą się nakładać)
	var/cycle_bar_users = 0
	/// Numer najnowszego etapu. Starszy, nakładający się etap (np. unload() i feed()) nie zapisuje już postępu do paska.
	var/cycle_bar_stage = 0

/obj/machinery/ship_weapon/Destroy(force=FALSE)
	if(cycle_bar)
		vis_contents -= cycle_bar
		QDEL_NULL(cycle_bar)
	return ..()

/// Czeka delay jak sleep(), pokazując nad bronią pasek postępu. Krótkie etapy czekają bez paska.
/obj/machinery/ship_weapon/proc/cycle_sleep(delay)
	if(delay < WEAPON_CYCLE_BAR_MIN_DELAY)
		sleep(delay)
		return
	var/stage = show_cycle_bar()
	var/step = delay / WEAPON_CYCLE_BAR_STEPS
	var/waited = 0
	for(var/i in 1 to WEAPON_CYCLE_BAR_STEPS)
		var/next = round(step * i, world.tick_lag)
		sleep(next - waited)
		waited = next
		if(QDELETED(src))
			return
		if(stage == cycle_bar_stage)
			cycle_bar.icon_state = "prog_bar_[round(i * 100 / WEAPON_CYCLE_BAR_STEPS, 5)]"
	hide_cycle_bar()

/// Pokazuje pasek od zera i zwraca numer etapu, który od teraz go prowadzi.
/obj/machinery/ship_weapon/proc/show_cycle_bar()
	cycle_bar_stage++
	if(!cycle_bar)
		cycle_bar = new
		var/icon/sprite = icon(icon, icon_state)
		// Nad środkiem zajmowanych kafelków i nad górną krawędzią sprite'a, jak pasek do_after nad zwykłym kafelkiem.
		// Szerokość bierzemy z bound_width, bo ikona bywa szersza od narysowanej broni (VLS: 64 px, sprite w lewej połowie).
		cycle_bar.pixel_x = round((bound_width - world.icon_size) / 2, 1)
		cycle_bar.pixel_y = sprite.Height()
	cycle_bar_users++
	cycle_bar.icon_state = "prog_bar_0"
	if(cycle_bar_users == 1)
		vis_contents += cycle_bar
		cycle_bar.alpha = 0
		animate(cycle_bar, alpha = 255, time = WEAPON_CYCLE_BAR_FADE)
	return cycle_bar_stage

/obj/machinery/ship_weapon/proc/hide_cycle_bar()
	cycle_bar_users = max(cycle_bar_users - 1, 0)
	if(cycle_bar_users)
		return
	animate(cycle_bar, alpha = 0, time = WEAPON_CYCLE_BAR_FADE)
	addtimer(CALLBACK(src, PROC_REF(remove_cycle_bar)), WEAPON_CYCLE_BAR_FADE)

/obj/machinery/ship_weapon/proc/remove_cycle_bar()
	if(cycle_bar_users || !cycle_bar)
		return
	vis_contents -= cycle_bar

/// Pasek etapu broni. Nie dziedziczy obrotu, koloru ani przezroczystości broni i nie łapie kliknięć.
/obj/effect/overlay/weapon_cycle_bar
	name = ""
	icon = 'icons/effects/progessbar.dmi'
	icon_state = "prog_bar_0"
	plane = ABOVE_HUD_PLANE
	layer = HUD_LAYER
	appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART | TILE_BOUND
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = NONE

#undef WEAPON_CYCLE_BAR_MIN_DELAY
#undef WEAPON_CYCLE_BAR_STEPS
#undef WEAPON_CYCLE_BAR_FADE
