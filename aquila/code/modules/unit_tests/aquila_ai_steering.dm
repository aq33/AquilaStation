/// AQUILA - poprawki ruchu AI (aquila/code/modules/overmap/ai_steering.dm): ciąg w każdym kroku fizyki
/// i omijanie tylko okrętów przed dziobem. Test regresji puszcza prawdziwe process(), tak jak w grze.

/// Podtyp testowy: myśliwiec rusza się tylko z działającymi silnikami (paliwo, części), a tu chodzi o samą fizykę
/obj/structure/overmap/small_craft/combat/light/steering_test

/obj/structure/overmap/small_craft/combat/light/steering_test
	/// Dystans, który okręt "chce trzymać" od celu; podstawiany, bo prawdziwy zależy od uzbrojenia myśliwca
	var/test_standoff = 0

/obj/structure/overmap/small_craft/combat/light/steering_test/can_move()
	return TRUE

/obj/structure/overmap/small_craft/combat/light/steering_test/get_ai_standoff_range(atom/target)
	return test_standoff

/datum/unit_test/aquila_ai_steering
	var/obj/structure/overmap/small_craft/combat/light/steering_test/ship
	var/obj/structure/overmap/small_craft/combat/light/steering_test/other

/datum/unit_test/aquila_ai_steering/Run()
	var/was_thrust = GLOB.ai_continuous_thrust_enabled
	var/was_avoid = GLOB.ai_forward_avoidance_enabled
	var/was_discipline = GLOB.ai_engine_discipline_enabled
	var/was_tactics = GLOB.ai_sensor_tactics_enabled
	GLOB.ai_continuous_thrust_enabled = TRUE
	GLOB.ai_forward_avoidance_enabled = TRUE
	GLOB.ai_engine_discipline_enabled = TRUE
	GLOB.ai_sensor_tactics_enabled = TRUE
	ship = allocate(/obj/structure/overmap/small_craft/combat/light/steering_test)
	other = allocate(/obj/structure/overmap/small_craft/combat/light/steering_test)
	ship.ai_controlled = TRUE
	other.faction = "syndicate"
	var/fail = check_thrust() || check_no_thrust() || check_avoid() || check_throttle() || check_boost() || check_sneak()
	ship.ai_controlled = FALSE
	ship.ai_running_silent = FALSE
	ship.ai_fleeing = FALSE
	ship.last_target = null
	GLOB.ai_continuous_thrust_enabled = was_thrust
	GLOB.ai_forward_avoidance_enabled = was_avoid
	GLOB.ai_engine_discipline_enabled = was_discipline
	GLOB.ai_sensor_tactics_enabled = was_tactics
	if(fail)
		return Fail(fail)

/// Kilka kroków fizyki bez tiku AI (slowprocess co 0,7 s), z move_mode = NORTH; zwraca prędkość po nich
/datum/unit_test/aquila_ai_steering/proc/run_physics(steps)
	// Kafelek kosmosu: w pokoju testowym jest powietrze i grawitacja, czyli opór
	ship.forceMove(locate(100, 60, run_loc_floor_bottom_left.z))
	ship.velocity.a = 0
	ship.velocity.e = 0
	ship.brakes = FALSE
	ship.angle = 0
	ship.desired_angle = 0
	ship.move_mode = NORTH
	for(var/i in 1 to steps)
		ship.last_process = world.time - 1.5 // jeden krok SSphysics_processing
		ship.last_slowprocess = world.time // bez tiku AI: to on dotąd jako jedyny ustawiał ciąg
		ship.process()
	return ship.velocity.ln()

/// Zgłoszony przypadek: między tikami AI okręt nie ciągnął wcale
/datum/unit_test/aquila_ai_steering/proc/check_thrust()
	var/z_poprawka = run_physics(4)
	if(z_poprawka <= 0)
		return "Okręt AI z move_mode = NORTH nie przyspieszył przez 4 kroki fizyki bez tiku AI"
	GLOB.ai_continuous_thrust_enabled = FALSE
	var/bez_poprawki = run_physics(4)
	GLOB.ai_continuous_thrust_enabled = TRUE
	if(bez_poprawki > 0)
		return "Z wyłączonym przełącznikiem okręt przyspieszał bez tiku AI ([bez_poprawki]), test nic nie sprawdza"

/// Hamulce i okręt gracza: brak ciągu z move_mode
/datum/unit_test/aquila_ai_steering/proc/check_no_thrust()
	ship.move_mode = NORTH
	ship.user_thrust_dir = 0
	ship.velocity.a = 0
	ship.velocity.e = 0
	ship.brakes = TRUE
	ship.apply_ai_thrust()
	ship.brakes = FALSE
	if(ship.user_thrust_dir)
		return "Okręt z zaciągniętymi hamulcami dostał ciąg"
	ship.ai_controlled = FALSE
	ship.apply_ai_thrust()
	ship.ai_controlled = TRUE
	if(ship.user_thrust_dir)
		return "Okręt gracza dostał ciąg z move_mode AI"

/// Przeszkodą jest okręt przed nami na kursie, nie za rufą
/datum/unit_test/aquila_ai_steering/proc/check_avoid()
	var/z = run_loc_floor_bottom_left.z
	ship.forceMove(locate(100, 60, z))
	var/turf/cel = locate(140, 60, z) // lecimy na wschód
	other.forceMove(locate(104, 60, z))
	if(!ship.ai_should_avoid(other, cel))
		return "Okręt nie omijał okrętu przed dziobem na kursie"
	other.forceMove(locate(96, 60, z))
	if(ship.ai_should_avoid(other, cel))
		return "Okręt omijał okręt za rufą"
	GLOB.ai_forward_avoidance_enabled = FALSE
	var/bazowo = ship.ai_should_avoid(other, cel)
	GLOB.ai_forward_avoidance_enabled = TRUE
	if(!bazowo)
		return "Z wyłączonym przełącznikiem okręt za rufą przestał być przeszkodą"

/// Przepustnica: przy prędkości maksymalnej wzdłuż dziobu okręt dryfuje, poniżej ciągnie
/datum/unit_test/aquila_ai_steering/proc/check_throttle()
	ship.forceMove(locate(100, 60, run_loc_floor_bottom_left.z))
	ship.ai_running_silent = FALSE
	ship.brakes = FALSE
	ship.move_mode = NORTH
	ship.angle = 0
	var/limit = ship.speed_limit * ship.get_overmap_speed_mult()
	// Kąt 0 to dziób na północ: cała prędkość w składowej e (physics.dm: fy = sin(90 - angle))
	ship.velocity.a = 0
	ship.velocity.e = limit
	ship.user_thrust_dir = 0
	ship.apply_ai_thrust()
	if(ship.user_thrust_dir)
		return "Okręt lecący z prędkością maksymalną dalej ciągnął silnikiem"
	ship.velocity.e = limit * 0.5
	ship.apply_ai_thrust()
	if(ship.user_thrust_dir != NORTH)
		return "Okręt lecący z połową prędkości maksymalnej przestał ciągnąć"
	// Prędkość maksymalna, ale bokiem: dziób trzeba dopiero rozpędzić
	ship.user_thrust_dir = 0
	ship.velocity.a = limit
	ship.velocity.e = 0
	ship.apply_ai_thrust()
	if(ship.user_thrust_dir != NORTH)
		return "Okręt lecący bokiem z prędkością maksymalną nie ciągnął wzdłuż dziobu"
	GLOB.ai_engine_discipline_enabled = FALSE
	ship.user_thrust_dir = 0
	ship.velocity.a = 0
	ship.velocity.e = limit
	ship.apply_ai_thrust()
	GLOB.ai_engine_discipline_enabled = TRUE
	if(ship.user_thrust_dir != NORTH)
		return "Z wyłączonym przełącznikiem przepustnica dalej działała"
	ship.user_thrust_dir = 0
	ship.velocity.a = 0
	ship.velocity.e = 0

/// Boost tylko jako zryw: ucieczka albo pościg za celem poza zasięgiem broni
/datum/unit_test/aquila_ai_steering/proc/check_boost()
	var/z = run_loc_floor_bottom_left.z
	ship.forceMove(locate(100, 60, z))
	ship.ai_running_silent = FALSE
	ship.ai_fleeing = FALSE
	ship.test_standoff = 0
	ship.last_target = null
	if(ship.ai_wants_boost())
		return "Okręt bez celu chciał boostu"
	ship.last_target = other
	other.forceMove(locate(100 + ship.max_weapon_range + 10, 60, z))
	if(!ship.ai_wants_boost())
		return "Okręt goniący cel poza zasięgiem broni nie chciał boostu"
	ship.test_standoff = 40
	if(ship.ai_wants_boost())
		return "Okręt trzymający dystans od celu chciał boostu"
	ship.test_standoff = 0
	other.forceMove(locate(110, 60, z))
	if(ship.ai_wants_boost())
		return "Okręt z celem w zasięgu broni chciał boostu"
	ship.ai_fleeing = TRUE
	if(!ship.ai_wants_boost())
		return "Uciekający okręt nie chciał boostu"
	ship.ai_running_silent = TRUE
	if(ship.ai_wants_boost())
		return "Okręt w cichym biegu chciał boostu"
	ship.ai_running_silent = FALSE
	ship.ai_fleeing = FALSE
	// Prawdziwe boost(): okręt AI, który go nie chce, nie dostaje wyższego limitu prędkości
	var/limit = ship.speed_limit
	ship.next_maneuvre = 0
	ship.boost(NORTH)
	if(ship.speed_limit != limit)
		return "Boost zadziałał na okręcie AI, który go nie chciał (limit [limit] -> [ship.speed_limit])"
	ship.last_target = null

/// Skradanie: bez radaru, silnik tylko w granicach budżetu ciepła; dziobem do wroga wolno grzać więcej
/datum/unit_test/aquila_ai_steering/proc/check_sneak()
	var/z = run_loc_floor_bottom_left.z
	ship.forceMove(locate(100, 60, z))
	ship.ai_fleeing = FALSE
	ship.ai_running_silent = TRUE
	ship.last_target = other
	ship.brakes = FALSE
	ship.move_mode = NORTH
	ship.velocity.a = 0
	ship.velocity.e = 0
	ship.inertial_dampeners = FALSE
	ship.hullburn = 0
	ship.last_weapon_fire = -INFINITY
	ship.obj_integrity = ship.max_integrity
	if(ship.try_ai_radar_pulse())
		return "Skradający się okręt odpalił radar"
	// Daleko od wroga, zimny silnik: wolno ciągnąć
	other.forceMove(locate(100 + 60, 60, z))
	ship.thrust_heat = 0
	ship.user_thrust_dir = 0
	ship.apply_ai_thrust()
	if(ship.user_thrust_dir != NORTH)
		return "Skradający się okręt daleko od wroga nie odpalił silnika przy zimnym napędzie"
	// Blisko wroga i gorący napęd: silnik zostaje wyłączony
	other.forceMove(locate(108, 60, z))
	ship.thrust_heat = 1
	ship.user_thrust_dir = 0
	ship.apply_ai_thrust()
	if(ship.user_thrust_dir)
		return "Skradający się okręt grzał silnikiem tuż obok wroga"
	// Budżet rośnie z odległością i jest większy, gdy idziemy do wroga dziobem
	other.forceMove(locate(130, 60, z))
	ship.angle = overmap_angle(ship, other) // dziobem do wroga
	var/dziobem = ship.get_ai_engine_heat_budget(other)
	ship.angle = overmap_angle(ship, other) + 180 // dyszami do wroga
	var/dyszami = ship.get_ai_engine_heat_budget(other)
	if(dziobem <= dyszami)
		return "Budżet ciepła dziobem do wroga ([dziobem]) nie był większy niż dyszami ([dyszami])"
	ship.angle = overmap_angle(ship, other)
	other.forceMove(locate(115, 60, z))
	var/blizej = ship.get_ai_engine_heat_budget(other)
	if(blizej >= dziobem)
		return "Budżet ciepła nie zmalał, gdy wróg był bliżej ([blizej] i [dziobem])"
	ship.ai_running_silent = FALSE
	ship.thrust_heat = 0
	ship.user_thrust_dir = 0
	ship.last_target = null
