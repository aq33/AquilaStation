/// AQUILA - dwa bazowe błędy ruchu, przez które okręty AI stały w miejscu (raport/sensory_06_dlaczego_stoja.md).
///
/// 1. Ciąg tylko w co piątym kroku fizyki. process() (physics.dm) liczy fizykę co 0,15 s i na końcu zeruje
///    user_thrust_dir. AI ustawia go z move_mode tylko w ai_process(), czyli w slowprocess() co 0,7 s.
///    Gracz ustawia ciąg przez relaymove() przy każdym ruchu klawiszem, więc go to nie dotyczy.
///    Zmierzone: lotniskowiec rozpędzał się 0,057 pola/s² zamiast 0,25 z parametrów (×0,5 skali overmapy).
///    Przy okazji silniki AI były zimne dla termiki: update_sensor_signature() próbkuje ciąg z poprzedniego
///    kroku, a w 4 na 5 kroków ciągu nie było.
///
/// 2. Omijanie przeszkód hamowało okręty w tłoku. Bazowe move_toward() uznaje za przeszkodę każdy duży okręt
///    w promieniu 5 pól od toru, a tor zaczyna się od kafelka samego okrętu - więc także okręt za rufą i własną
///    eskortę. Okręt dostawał wtedy tylko ciąg boczny. Teraz omija tylko to, co ma przed sobą na kursie.

/// Debug > Toggle AI continuous thrust
GLOBAL_VAR_INIT(ai_continuous_thrust_enabled, TRUE)
/// Debug > Toggle AI forward avoidance
GLOBAL_VAR_INIT(ai_forward_avoidance_enabled, TRUE)

/// Ciąg AI w każdym kroku fizyki: move_mode to zamiar okrętu ("lecę naprzód"), a nie jednorazowy impuls
/obj/structure/overmap/proc/apply_ai_thrust()
	if(!GLOB.ai_continuous_thrust_enabled || !ai_controlled || !move_mode || brakes || ai_running_silent)
		return
	user_thrust_dir = move_mode

/obj/structure/overmap/process()
	apply_ai_thrust() // process() zeruje user_thrust_dir na końcu poprzedniego kroku
	return ..()

/// Hak w pętli omijania przeszkód bazowego move_toward() (ai-skynet.dm, AQ EDIT).
/// TRUE: ten okręt może nam wejść w drogę, bo jest przed nami na kursie do celu.
/obj/structure/overmap/proc/ai_should_avoid(obj/structure/overmap/other, atom/goal)
	if(!GLOB.ai_forward_avoidance_enabled || !ai_controlled || !goal)
		return TRUE
	var/course = overmap_angle(src, goal)
	var/to_other = overmap_angle(src, other)
	if(isnull(course) || isnull(to_other))
		return TRUE // na tym samym kafelku albo cel pod nami: ostrożnie, jak dotąd
	return abs(closer_angle_difference(course, to_other)) < 90

/world/AVerbsDebug()
	. = ..()
	. += /client/proc/toggle_ai_continuous_thrust
	. += /client/proc/toggle_ai_forward_avoidance

/client/proc/toggle_ai_continuous_thrust()
	set category = "Debug"
	set name = "Toggle AI continuous thrust"
	set desc = "Włącza lub wyłącza ciąg okrętów AI w każdym kroku fizyki (wyłączony: ciąg co 0,7 s jak w bazowym NSV13)."
	if(!check_rights(R_DEBUG))
		return
	GLOB.ai_continuous_thrust_enabled = !GLOB.ai_continuous_thrust_enabled
	var/state = GLOB.ai_continuous_thrust_enabled ? "włączył" : "wyłączył"
	message_admins("[key_name_admin(usr)] [state] ciągły ciąg okrętów AI.")
	log_admin("[key_name(usr)] toggled AI continuous thrust to [GLOB.ai_continuous_thrust_enabled].")

/client/proc/toggle_ai_forward_avoidance()
	set category = "Debug"
	set name = "Toggle AI forward avoidance"
	set desc = "Włącza lub wyłącza omijanie tylko okrętów przed dziobem (wyłączony: każdy duży okręt w 5 polach jest przeszkodą)."
	if(!check_rights(R_DEBUG))
		return
	GLOB.ai_forward_avoidance_enabled = !GLOB.ai_forward_avoidance_enabled
	var/state = GLOB.ai_forward_avoidance_enabled ? "włączył" : "wyłączył"
	message_admins("[key_name_admin(usr)] [state] omijanie przeszkód tylko przed dziobem u AI.")
	log_admin("[key_name(usr)] toggled AI forward avoidance to [GLOB.ai_forward_avoidance_enabled].")
