// AQUILA - kalibracja pylonów FTL (rework systemów okrętu, etap C).
// Każdy pylon ma falę celu (częstotliwość i faza), która powoli dryfuje. Operator rdzenia FTL stroi falę pylonu
// na oscyloskopie, aż pokryje się z falą celu. Jakość kalibracji (średnia z aktywnych pylonów, 0-1) zmienia
// szybkość ładowania skoku (FTL_CAL_CHARGE_MIN-FTL_CAL_CHARGE_MAX) i szansę wypadku przy skoku
// (do FTL_CAL_MISHAP_MAX procent przy zupełnie złej kalibracji). Po każdym skoku fale celu losują się od nowa.

#define FTL_CAL_FREQ_MIN 1
#define FTL_CAL_FREQ_MAX 8
/// Odchyłka częstotliwości, przy której dopasowanie spada do zera
#define FTL_CAL_FREQ_TOLERANCE 1
/// Odchyłka fazy (stopnie), przy której dopasowanie spada do zera
#define FTL_CAL_PHASE_TOLERANCE 60
#define FTL_CAL_CHARGE_MIN 0.6
#define FTL_CAL_CHARGE_MAX 1.4
#define FTL_CAL_MISHAP_MAX 30

/obj/machinery/atmospherics/components/binary/drive_pylon
	/// Fala celu, do której trzeba dostroić pylon
	var/cal_target_freq = 4
	var/cal_target_phase = 0
	/// Fala ustawiona przez operatora
	var/cal_freq = 4.5
	var/cal_phase = 180

/obj/machinery/atmospherics/components/binary/drive_pylon/Initialize(mapload)
	. = ..()
	randomize_calibration()

/obj/machinery/atmospherics/components/binary/drive_pylon/proc/randomize_calibration()
	cal_target_freq = rand(FTL_CAL_FREQ_MIN * 10, FTL_CAL_FREQ_MAX * 10) / 10
	cal_target_phase = rand(0, 359)

/// Fala celu powoli dryfuje, więc kalibrację trzeba poprawiać w trakcie ładowania
/obj/machinery/atmospherics/components/binary/drive_pylon/proc/drift_calibration()
	cal_target_freq = clamp(cal_target_freq + rand(-4, 4) / 100, FTL_CAL_FREQ_MIN, FTL_CAL_FREQ_MAX)
	cal_target_phase = SIMPLIFY_DEGREES(cal_target_phase + rand(-3, 3))

/// Dopasowanie fali pylonu do fali celu, 0-1
/obj/machinery/atmospherics/components/binary/drive_pylon/proc/calibration_match()
	var/freq = max(0, 1 - abs(cal_freq - cal_target_freq) / FTL_CAL_FREQ_TOLERANCE)
	var/phase = max(0, 1 - abs(closer_angle_difference(cal_phase, cal_target_phase)) / FTL_CAL_PHASE_TOLERANCE)
	return freq * phase

/// Jakość kalibracji rdzenia: średnie dopasowanie aktywnych pylonów, 0-1
/obj/machinery/computer/ship/ftl_core/proc/calibration_quality()
	var/total = 0
	var/count = 0
	for(var/obj/machinery/atmospherics/components/binary/drive_pylon/P as anything in pylons)
		if(P.pylon_state != PYLON_STATE_ACTIVE)
			continue
		total += P.calibration_match()
		count++
	return count ? total / count : 0

/obj/machinery/computer/ship/ftl_core/proc/calibration_charge_mult(quality = calibration_quality())
	return FTL_CAL_CHARGE_MIN + (FTL_CAL_CHARGE_MAX - FTL_CAL_CHARGE_MIN) * quality

/// Szansa wypadku przy skoku w procentach
/obj/machinery/computer/ship/ftl_core/proc/calibration_mishap_chance(quality = calibration_quality())
	return FTL_CAL_MISHAP_MAX * (1 - quality) ** 2

/obj/machinery/computer/ship/ftl_core/process(delta_time)
	for(var/obj/machinery/atmospherics/components/binary/drive_pylon/P as anything in pylons)
		P.drift_calibration()
	charge_rate = initial(charge_rate) * calibration_charge_mult()
	return ..()

/obj/machinery/computer/ship/ftl_core/jump(datum/star_system/target_system, force = FALSE, misjump = FALSE)
	if(!force && !misjump && prob(calibration_mishap_chance()))
		misjump = TRUE
		radio.talk_into(src, "OSTRZEŻENIE: rozstrojone pylony. Translacja niestabilna.", radio_channel)
	. = ..(target_system, force, misjump)
	for(var/obj/machinery/atmospherics/components/binary/drive_pylon/P as anything in pylons)
		P.randomize_calibration()

/obj/machinery/computer/ship/ftl_core/ui_data(mob/user)
	. = ..()
	var/quality = calibration_quality()
	var/list/cal_pylons = list()
	var/count = 0
	for(var/obj/machinery/atmospherics/components/binary/drive_pylon/P as anything in pylons)
		count++
		cal_pylons += list(list(
			"id" = "\ref[P]",
			"name" = "Pylon [index2greek(count)]",
			"active" = P.pylon_state == PYLON_STATE_ACTIVE,
			"target_freq" = P.cal_target_freq,
			"target_phase" = P.cal_target_phase,
			"freq" = P.cal_freq,
			"phase" = P.cal_phase,
			"match" = round(P.calibration_match() * 100)
		))
	.["calibration"] = list(
		"pylons" = cal_pylons,
		"quality" = round(quality * 100),
		"charge_mult" = round(calibration_charge_mult(quality), 0.01),
		"mishap" = round(calibration_mishap_chance(quality), 0.1),
		"freq_min" = FTL_CAL_FREQ_MIN,
		"freq_max" = FTL_CAL_FREQ_MAX
	)

/obj/machinery/computer/ship/ftl_core/ui_act(action, params, datum/tgui/ui)
	if(action != "calibrate")
		return ..()
	if(!allowed(usr))
		to_chat(usr, "<span class='warning'>Brak dostępu.</span>")
		return TRUE
	var/obj/machinery/atmospherics/components/binary/drive_pylon/P = locate(params["id"]) in pylons
	if(!P)
		return TRUE
	var/freq = text2num(params["freq"])
	if(isnum_safe(freq))
		P.cal_freq = clamp(round(freq, 0.05), FTL_CAL_FREQ_MIN, FTL_CAL_FREQ_MAX)
	var/phase = text2num(params["phase"])
	if(isnum_safe(phase))
		P.cal_phase = SIMPLIFY_DEGREES(round(phase))
	return TRUE

#undef FTL_CAL_FREQ_MIN
#undef FTL_CAL_FREQ_MAX
#undef FTL_CAL_FREQ_TOLERANCE
#undef FTL_CAL_PHASE_TOLERANCE
#undef FTL_CAL_CHARGE_MIN
#undef FTL_CAL_CHARGE_MAX
#undef FTL_CAL_MISHAP_MAX
