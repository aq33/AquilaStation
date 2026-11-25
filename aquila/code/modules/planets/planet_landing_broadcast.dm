// AQUILA - transmisja lądowania promu na planecie do Spess.tv i telewizorów rozrywkowych. Na czas zejścia na lądowisku
// staje niewidzialna kamera tuż przy obrysie kadłuba: widać z niej cień, spadający prom, kurz od dysz i przyziemienie
// (widok z ziemi z planet_landing_view.dm). Niebo i chmury z pokładu to efekt na ekranie załogi, kamera ich nie pokaże.
// Po przyziemieniu transmisja trwa jeszcze chwilę (wyjście załogi), przerwane zejście kończy ją od razu.

/// O ile pól od dolnej krawędzi obrysu kadłuba stoi kamera
#define PLANET_LANDING_BROADCAST_OFFSET 3

/// Jedna transmisja lądowania: kamera na lądowisku i nadawca w sieci CAMERANET_NETWORK_LANDING
/datum/planet_landing_broadcast
	var/obj/machinery/camera/planet_landing/camera
	var/stop_timer

/datum/planet_landing_broadcast/New(list/berth, craft_name, planet_name)
	var/turf/spot = planet_landing_broadcast_spot(berth)
	if(!spot)
		return
	camera = new(spot)
	camera.c_tag = unique_broadcast_tag("NA ŻYWO: [craft_name] ląduje na [planet_name]", camera)
	RegisterSignal(camera, COMSIG_PARENT_QDELETING, PROC_REF(camera_deleted))
	start_broadcasting_network(CAMERANET_NETWORK_LANDING, "[craft_name] ląduje na [planet_name]. Transmisja NA ŻYWO w Spess.tv!", src)

/datum/planet_landing_broadcast/Destroy()
	if(stop_timer)
		deltimer(stop_timer)
		stop_timer = null
	if(camera)
		UnregisterSignal(camera, COMSIG_PARENT_QDELETING)
		stop_broadcasting_network(CAMERANET_NETWORK_LANDING, null, src)
	QDEL_NULL(camera)
	return ..()

/// Kamerę usunęło coś innego (zwolnienie powierzchni planety): transmisja kończy się od razu
/datum/planet_landing_broadcast/proc/camera_deleted(datum/source)
	SIGNAL_HANDLER
	stop_broadcasting_network(CAMERANET_NETWORK_LANDING, null, src)
	camera = null
	qdel(src)

/// Kończy transmisję po delay (0 = od razu)
/datum/planet_landing_broadcast/proc/finish(delay = 0)
	if(!delay)
		qdel(src)
		return
	stop_timer = addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), delay, TIMER_STOPPABLE)

/// Pole kamery: na środku pod obrysem kadłuba, kilka pól od jego krawędzi (na obrysie zmiażdżyłby ją kadłub)
/proc/planet_landing_broadcast_spot(list/berth)
	if(!length(berth))
		return
	var/turf/center = planet_landing_center(berth)
	var/min_y = INFINITY
	for(var/turf/T as anything in berth)
		min_y = min(min_y, T.y)
	return locate(center.x, max(1, min_y - PLANET_LANDING_BROADCAST_OFFSET), center.z) || center

/// Kamera transmisji lądowania: niewidzialna, nie do zniszczenia, bez światła
/obj/machinery/camera/planet_landing
	name = "kamera lądowiska"
	invisibility = INVISIBILITY_ABSTRACT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	internal_light = FALSE
	network = list(CAMERANET_NETWORK_LANDING)
	use_power = NO_POWER_USE
	start_active = TRUE

#undef PLANET_LANDING_BROADCAST_OFFSET
