// AQUILA - lornetka taktyczna, na wzór tactical binoculars z TGMC (tgstation/TerraGov-Marine-Corps, AGPLv3), tylko tryb
// ostrzału orbitalnego. Przyłożona do oczu (oburącz) przechwytuje kliknięcia: kliknięcie pola na powierzchni planety
// i kilka sekund bez ruchu stawia znacznik celu, w którego okolicy spadają pociski okrętu. Znacznik gaśnie po
// czasie albo kiedy postawi się nowy. Shift i inne kliknięcia z modyfikatorem działają normalnie (oględziny).

/// Ile trwa namierzanie i ile świeci znacznik
#define TACTICAL_BINOCULARS_LASE_TIME (4 SECONDS)
#define TACTICAL_BINOCULARS_TARGET_TIME (90 SECONDS)

/obj/item/binoculars/tactical
	name = "lornetka taktyczna"
	desc = "Lornetka z dalmierzem i laserowym wskaźnikiem celu. Przyłóż ją do oczu i kliknij pole na powierzchni planety, żeby wskazać cel ostrzału z orbity."
	color = "#9fb39a"
	/// Ostatni postawiony znacznik (jeden na lornetkę)
	var/obj/effect/planet_laser_target/laser
	var/lasing = FALSE

/obj/item/binoculars/tactical/Destroy()
	QDEL_NULL(laser)
	return ..()

/obj/item/binoculars/tactical/examine(mob/user)
	. = ..()
	. += span_notice("Przyłożona do oczu: kliknięcie pola na powierzchni planety i [DisplayTimeText(TACTICAL_BINOCULARS_LASE_TIME)] bez ruchu stawia znacznik celu na [DisplayTimeText(TACTICAL_BINOCULARS_TARGET_TIME)].")

/obj/item/binoculars/tactical/on_wield(obj/item/source, mob/user)
	. = ..()
	if(user)
		user.click_intercept = src

/obj/item/binoculars/tactical/unwield(mob/user)
	if(user?.click_intercept == src)
		user.click_intercept = null
	return ..()

/obj/item/binoculars/tactical/proc/InterceptClickOn(mob/living/clicker, params, atom/clicked)
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, SHIFT_CLICK) || LAZYACCESS(modifiers, ALT_CLICK) || LAZYACCESS(modifiers, CTRL_CLICK))
		return FALSE
	if(clicker.get_active_held_item() != src && clicker.get_inactive_held_item() != src)
		clicker.click_intercept = null
		return FALSE
	var/turf/target_turf = get_turf(clicked)
	if(!target_turf)
		return TRUE
	INVOKE_ASYNC(src, PROC_REF(lase), clicker, target_turf)
	return TRUE

/// Namierza pole: sprawdza, czy to powierzchnia planety w zasięgu wzroku, i po chwili stawia znacznik
/obj/item/binoculars/tactical/proc/lase(mob/living/user, turf/target_turf)
	if(lasing)
		return
	var/obj/structure/overmap/planet/planet = get_planet_of(target_turf)
	if(!planet)
		to_chat(user, span_warning("Wskaźnik celu działa tylko na powierzchni planety, pod otwartym niebem."))
		return
	if(!(target_turf in view(user.client?.view || world.view, user)))
		to_chat(user, span_warning("Musisz widzieć to miejsce."))
		return
	if(isclosedturf(target_turf))
		to_chat(user, span_warning("Laser odbija się od skały. Wskaż otwarty teren."))
		return
	lasing = TRUE
	to_chat(user, span_notice("Namierzasz cel, nie ruszaj się..."))
	playsound(user, 'sound/machines/beep.ogg', 30, TRUE)
	var/success = do_after(user, TACTICAL_BINOCULARS_LASE_TIME, TRUE, target_turf)
	lasing = FALSE
	if(!success || QDELETED(src))
		return
	QDEL_NULL(laser)
	laser = new(target_turf, user.real_name)
	QDEL_IN(laser, TACTICAL_BINOCULARS_TARGET_TIME)
	to_chat(user, span_notice("Cel oznaczony. Pociski wystrzelone w [planet] spadną w jego okolicy przez najbliższe [DisplayTimeText(TACTICAL_BINOCULARS_TARGET_TIME)]."))
	log_game("[key_name(user)] lased an orbital bombardment target on [planet] at [AREACOORD(target_turf)]")
	var/obj/structure/overmap/main_ship = SSstar_system.find_main_overmap()
	main_ship?.relay(message = span_notice("Łączność z powierzchni: [user.real_name] oznacza cel ostrzału orbitalnego na [planet]."))

/// Planeta, na której powierzchni leży pole (tylko teren pod niebem planety, nie wnętrza ruin)
/proc/get_planet_of(turf/T)
	if(!T)
		return
	var/datum/turf_reservation/reservation = SSmapping.used_turfs[T]
	var/obj/structure/overmap/planet/planet = reservation?.overmap_fallback
	if(!istype(planet) || planet.surface?.reservation != reservation)
		return
	var/area/A = T.loc
	if(!A.outdoors)
		return
	return planet

#undef TACTICAL_BINOCULARS_LASE_TIME
#undef TACTICAL_BINOCULARS_TARGET_TIME
