/// AQUILA - poprawki ruchu AI (aquila/code/modules/overmap/ai_steering.dm): ciąg w każdym kroku fizyki
/// i omijanie tylko okrętów przed dziobem. Test regresji puszcza prawdziwe process(), tak jak w grze.

/// Podtyp testowy: myśliwiec rusza się tylko z działającymi silnikami (paliwo, części), a tu chodzi o samą fizykę
/obj/structure/overmap/small_craft/combat/light/steering_test

/obj/structure/overmap/small_craft/combat/light/steering_test/can_move()
	return TRUE

/datum/unit_test/aquila_ai_steering
	var/obj/structure/overmap/small_craft/combat/light/steering_test/ship
	var/obj/structure/overmap/small_craft/combat/light/steering_test/other

/datum/unit_test/aquila_ai_steering/Run()
	var/was_thrust = GLOB.ai_continuous_thrust_enabled
	var/was_avoid = GLOB.ai_forward_avoidance_enabled
	GLOB.ai_continuous_thrust_enabled = TRUE
	GLOB.ai_forward_avoidance_enabled = TRUE
	ship = allocate(/obj/structure/overmap/small_craft/combat/light/steering_test)
	other = allocate(/obj/structure/overmap/small_craft/combat/light/steering_test)
	ship.ai_controlled = TRUE
	var/fail = check_thrust() || check_no_thrust() || check_avoid()
	ship.ai_controlled = FALSE
	GLOB.ai_continuous_thrust_enabled = was_thrust
	GLOB.ai_forward_avoidance_enabled = was_avoid
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

/// Hamulce, cichy bieg i okręt gracza: brak ciągu z move_mode
/datum/unit_test/aquila_ai_steering/proc/check_no_thrust()
	ship.move_mode = NORTH
	ship.user_thrust_dir = 0
	ship.brakes = TRUE
	ship.apply_ai_thrust()
	ship.brakes = FALSE
	if(ship.user_thrust_dir)
		return "Okręt z zaciągniętymi hamulcami dostał ciąg"
	ship.ai_running_silent = TRUE
	ship.apply_ai_thrust()
	ship.ai_running_silent = FALSE
	if(ship.user_thrust_dir)
		return "Okręt w cichym biegu dostał ciąg"
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
