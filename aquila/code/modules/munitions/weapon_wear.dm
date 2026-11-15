/// AQUILA - kalibracja i zużycie dział okrętowych z ręczną obsługą (MAC, działo szynowe NT-STC4, działo pokładowe),
/// obok konserwacji z ship_weapon_maintenance.dm (maint_req, awaria, oliwienie). Wzory: MAC z FTL13
/// (code/game/machinery/mac_cannon.dm) i kalibracja Obstruction Field Dispersera z Baya (disperser_console.dm).
/// - Kalibracja 0–100%: po strzale z szansą calibration_drop_chance spada o calibration_drop. Niższa kalibracja
///   dokłada rozrzut pociskom niekierowanym na overmapie (kąt w fire_projectile).
///   Przy 0% strzał kończy się wybuchem w zamku.
/// - Przywrócenie: multitool przy odkręconym panelu, mini-gra „Mastermind” (4 cyfry 0–9, cyfra na swoim miejscu
///   2 pkt, cyfra z kodu na złym miejscu 1 pkt, wynik = punkty/8). Próba może przepalić aktuator.
/// - Aktuator zamka: przy strzale może się przepalić i wtedy działo nie strzela, dopóki obsługa go nie wymieni
///   (odkręcony panel, łom wyjmuje spalony, wkłada się manipulator).
/// - Strzał przy odkręconym panelu poraża prądem obsługę przy dziale.
/// „Strzał na gorąco” z Baya pominięty: datum broni blokuje strzał do końca fire_delay (firing_checks.dm), więc
/// nie da się strzelić przed końcem chłodzenia.

#define WEAPON_ACTUATOR_OK 0
#define WEAPON_ACTUATOR_BURNT 1
#define WEAPON_ACTUATOR_MISSING 2

/// Liczba cyfr kodu kalibracji (jak w Bayu), maksimum punktów to dwa razy tyle
#define WEAPON_CALIBRATION_DIGITS 4
/// Od tej kalibracji (włącznie) działo ostrzega obsługę
#define WEAPON_CALIBRATION_WARNING 20

/obj/machinery/ship_weapon
	/// Czy działo ma kalibrację i aktuator (tylko działa z ręczną obsługą)
	var/wear_enabled = FALSE
	/// Kalibracja układu celowniczego w procentach
	var/calibration = 100
	/// Stan aktuatora zamka: WEAPON_ACTUATOR_OK, _BURNT albo _MISSING
	var/actuator_state = WEAPON_ACTUATOR_OK
	/// Trwa mini-gra kalibracji
	var/calibrating = FALSE
	/// Szansa (%) na spadek kalibracji po strzale
	var/calibration_drop_chance = 20
	/// O ile punktów procentowych spada kalibracja
	var/calibration_drop = 10
	/// Rozrzut (stopnie, pełna szerokość) przy kalibracji 0%; liniowo do 0 przy 100%
	var/calibration_max_spread = 16
	/// Szansa (%) na przepalenie aktuatora przy strzale
	var/actuator_burn_chance = 5
	/// Szansa (%) na przepalenie aktuatora przy próbie kalibracji multitoolem
	var/calibration_actuator_burn_chance = 10
	/// Liczba prób w jednej kalibracji
	var/calibration_attempts = 6
	/// Obrażenia od porażenia przy strzale z odkręconym panelem
	var/open_panel_shock_damage = 25

/obj/machinery/ship_weapon/mac
	wear_enabled = TRUE

/obj/machinery/ship_weapon/railgun
	wear_enabled = TRUE

/obj/machinery/ship_weapon/deck_turret
	wear_enabled = TRUE

/obj/structure/overmap
	/// Dodatkowy rozrzut dla najbliższego fire_projectile(), ustawiany przez działo tuż przed strzałem
	var/pending_weapon_spread = 0

/obj/structure/overmap/fire_projectile(proj_type, atom/target, pixel_speed = null, user_override = null, firing_flags = NONE, ai_aim = FALSE, miss_chance = 5, max_miss_distance = 5, spread_override = null, projectile_speed = null)
	var/extra = pending_weapon_spread
	pending_weapon_spread = 0
	// pociski dział (też samonaprowadzające MAC, które rozrzut potem częściowo korygują), bez torped i rakiet
	if(extra > 0 && ispath(proj_type, /obj/item/projectile) && !ispath(proj_type, /obj/item/projectile/guided_munition))
		if(isnull(spread_override))
			var/obj/item/projectile/proj = proj_type
			spread_override = initial(proj.spread)
		spread_override += extra
	return ..(proj_type, target, pixel_speed, user_override, firing_flags, ai_aim, miss_chance, max_miss_distance, spread_override, projectile_speed)

/// Rozrzut pocisku (stopnie) za niepełną kalibrację
/obj/machinery/ship_weapon/proc/calibration_spread()
	return calibration_max_spread * (100 - clamp(calibration, 0, 100)) / 100

/obj/machinery/ship_weapon/proc/prepare_calibration_spread()
	if(wear_enabled && linked)
		linked.pending_weapon_spread = calibration_spread()

/obj/machinery/ship_weapon/proc/clear_calibration_spread()
	if(linked)
		linked.pending_weapon_spread = 0

/obj/machinery/ship_weapon/animate_projectile(atom/target)
	prepare_calibration_spread()
	. = ..()
	clear_calibration_spread()

/obj/machinery/ship_weapon/deck_turret/animate_projectile(atom/target, lateral = TRUE)
	prepare_calibration_spread()
	. = ..()
	clear_calibration_spread()

/obj/machinery/ship_weapon/proc/actuator_working()
	return !wear_enabled || actuator_state == WEAPON_ACTUATOR_OK

/obj/machinery/ship_weapon/can_fire(atom/target, shots = linked_overmap_ship_weapon.burst_size)
	if(!actuator_working())
		return FALSE
	return ..(target, shots)

/obj/machinery/ship_weapon/update()
	. = ..()
	if(!actuator_working() && linked_overmap_ship_weapon)
		linked_overmap_ship_weapon.mark_physical_weapon_unloaded(src)

/obj/machinery/ship_weapon/fire(atom/target, shots = linked_overmap_ship_weapon.burst_size, manual = TRUE)
	set waitfor = FALSE // jak w procedurze bazowej: fire_proc_chain nie może spać
	if(wear_enabled && can_fire(target, shots))
		if(maint_state == MSTATE_UNSCREWED)
			open_panel_shock()
		if(calibration <= 0)
			breech_explosion()
			return FALSE
	return ..(target, shots, manual)

/obj/machinery/ship_weapon/local_fire()
	. = ..()
	if(wear_enabled)
		wear_after_shot()

/// Zużycie po jednym strzale: spadek kalibracji i przepalenie aktuatora
/obj/machinery/ship_weapon/proc/wear_after_shot()
	if(prob(calibration_drop_chance) && calibration > 0)
		calibration = max(0, calibration - calibration_drop)
		if(calibration <= 0)
			say("Kalibracja układu celowniczego: 0%. Kolejny strzał grozi wybuchem w zamku!")
		else if(calibration <= WEAPON_CALIBRATION_WARNING)
			say("Ostrzeżenie: kalibracja układu celowniczego spadła do [calibration]%.")
	if(prob(actuator_burn_chance))
		burn_actuator()
	update_cycle_stage_uis()

/obj/machinery/ship_weapon/proc/burn_actuator()
	if(!wear_enabled || actuator_state != WEAPON_ACTUATOR_OK)
		return FALSE
	actuator_state = WEAPON_ACTUATOR_BURNT
	do_sparks(4, TRUE, src)
	visible_message("<span class='warning'>Z [src] bucha dym, aktuator zamka się przepalił!</span>")
	say("Awaria aktuatora zamka. Strzał zablokowany do czasu wymiany.")
	update()
	update_cycle_stage_uis()
	return TRUE

/obj/machinery/ship_weapon/proc/remove_actuator()
	if(actuator_state != WEAPON_ACTUATOR_BURNT)
		return FALSE
	actuator_state = WEAPON_ACTUATOR_MISSING
	update_cycle_stage_uis()
	return TRUE

/obj/machinery/ship_weapon/proc/install_actuator()
	if(actuator_state != WEAPON_ACTUATOR_MISSING)
		return FALSE
	actuator_state = WEAPON_ACTUATOR_OK
	update()
	update_cycle_stage_uis()
	return TRUE

/// Strzał przy odkręconym panelu: odsłonięte przewody porażają każdego przy dziale
/obj/machinery/ship_weapon/proc/open_panel_shock()
	do_sparks(5, TRUE, src)
	for(var/mob/living/victim in obounds(src, world.icon_size))
		if(victim.electrocute_act(open_panel_shock_damage, src))
			to_chat(victim, "<span class='userdanger'>Odsłonięte przewody [src] porażają cię przy strzale!</span>")

/// Kalibracja 0%: pocisk rozrywa się w zamku zamiast wylecieć
/obj/machinery/ship_weapon/proc/breech_explosion()
	var/obj/item/round = chambered
	if(round)
		ammo -= round
		chambered = null
		qdel(round)
	state = length(ammo) ? STATE_FED : STATE_NOTLOADED
	icon_state = initial(icon_state)
	visible_message("<span class='userdanger'>Rozkalibrowany zamek [src] eksploduje przy próbie strzału!</span>")
	log_game("[src] wybuchło w zamku przy kalibracji 0% w [AREACOORD(src)]")
	explosion(get_turf(src), 0, 0, 3, 4, flame_range = 2)
	if(!QDELETED(src))
		take_damage(100, BRUTE, "bomb", FALSE)
	if(!QDELETED(src))
		update()

// ---------------------------------------------------------------- kalibracja (mini-gra)

/// Zamienia wpis gracza na listę cyfr albo null, gdy to nie są dokładnie 4 cyfry (spacje pomijane)
/proc/weapon_calibration_parse(text)
	if(!istext(text))
		return null
	var/list/digits = list()
	for(var/i in 1 to length(text))
		var/character = copytext(text, i, i + 1)
		if(character == " ")
			continue
		if(!findtext("0123456789", character))
			return null
		digits += text2num(character)
	if(length(digits) != WEAPON_CALIBRATION_DIGITS)
		return null
	return digits

/// Ocena próby jak w Mastermindzie: list(cyfry na swoim miejscu, cyfry z kodu na złym miejscu).
/// Każda cyfra kodu liczy się raz, więc „1111” nie zbiera punktów za jedną jedynkę w kodzie.
/proc/weapon_calibration_check(list/guess, list/code)
	var/exact = 0
	var/list/code_left = list()
	var/list/guess_left = list()
	for(var/i in 1 to length(code))
		if(guess[i] == code[i])
			exact++
			continue
		code_left["[code[i]]"] = (code_left["[code[i]]"] || 0) + 1
		guess_left += guess[i]
	var/misplaced = 0
	for(var/digit in guess_left)
		if(code_left["[digit]"] > 0)
			code_left["[digit]"]--
			misplaced++
	return list(exact, misplaced)

/// Kalibracja (%) z wyniku próby: punkty/8·100
/proc/weapon_calibration_percent(exact, misplaced)
	return round((exact * 2 + misplaced) * 100 / (WEAPON_CALIBRATION_DIGITS * 2), 1)

/obj/machinery/ship_weapon/proc/user_near_weapon(mob/user)
	return user && !QDELETED(user) && (user.Adjacent(src) || (user in obounds(src, world.icon_size)))

/// Czy user może teraz kalibrować działo narzędziem tool; feedback = komunikat o przyczynie
/obj/machinery/ship_weapon/proc/can_calibrate(mob/living/user, obj/item/tool, feedback = FALSE)
	if(QDELETED(src) || !wear_enabled || !istype(user) || user.incapacitated())
		return FALSE
	if(!tool || !user.is_holding(tool) || !user_near_weapon(user))
		return FALSE
	if(maint_state != MSTATE_UNSCREWED)
		if(feedback)
			to_chat(user, "<span class='warning'>Do kalibracji panel serwisowy [src] musi być odkręcony, a obudowa wewnętrzna na miejscu.</span>")
		return FALSE
	if(actuator_state != WEAPON_ACTUATOR_OK)
		if(feedback)
			to_chat(user, "<span class='warning'>Najpierw wymień aktuator zamka [src].</span>")
		return FALSE
	if(state == STATE_FIRING)
		if(feedback)
			to_chat(user, "<span class='warning'>Nie możesz kalibrować [src] w trakcie strzału!</span>")
		return FALSE
	return TRUE

/obj/machinery/ship_weapon/proc/calibration_minigame(mob/living/user, obj/item/tool)
	if(calibrating)
		to_chat(user, "<span class='warning'>Ktoś już kalibruje [src].</span>")
		return
	if(!can_calibrate(user, tool, TRUE))
		return
	calibrating = TRUE
	to_chat(user, "<span class='notice'>Podłączasz [tool] do układu celowniczego [src]...</span>")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 50) || !can_calibrate(user, tool, TRUE))
		calibrating = FALSE
		return
	if(prob(calibration_actuator_burn_chance))
		calibrating = FALSE
		to_chat(user, "<span class='warning'>Impuls z [tool] przepala aktuator zamka [src]!</span>")
		burn_actuator()
		return
	var/list/code = list()
	for(var/i in 1 to WEAPON_CALIBRATION_DIGITS)
		code += rand(0, 9)
	to_chat(user, "<span class='notice'>Ustaw cztery cyfry (0–9) układu celowniczego. Cyfra na swoim miejscu daje 2 punkty, cyfra z kodu na złym miejscu 1 punkt. Kalibracja to najlepszy wynik z [calibration_attempts] prób.</span>")
	var/best = -1
	var/attempt = 0
	while(attempt < calibration_attempts)
		var/text = tgui_input_text(user, "Próba [attempt + 1] z [calibration_attempts]: wpisz 4 cyfry (0–9).", "Kalibracja działa", max_length = 8, timeout = 2 MINUTES)
		if(isnull(text) || !can_calibrate(user, tool, TRUE))
			break
		var/list/guess = weapon_calibration_parse(text)
		if(!guess)
			to_chat(user, "<span class='warning'>Kod musi mieć dokładnie 4 cyfry od 0 do 9.</span>")
			continue
		if(!do_after(user, 1 SECONDS, target = src) || !can_calibrate(user, tool, TRUE))
			break
		attempt++
		var/list/result = weapon_calibration_check(guess, code)
		var/percent = weapon_calibration_percent(result[1], result[2])
		best = max(best, percent)
		var/guess_text = jointext(guess, "")
		to_chat(user, "<span class='notice'>Próba [attempt] z [calibration_attempts]: [guess_text]. Na swoim miejscu: [result[1]], na złym miejscu: [result[2]] (dopasowanie [percent]%).</span>")
		if(percent >= 100)
			break
	calibrating = FALSE
	if(QDELETED(src))
		return
	if(best < 0)
		to_chat(user, "<span class='notice'>Przerywasz kalibrację [src].</span>")
		return
	if(best > calibration)
		calibration = best
		to_chat(user, "<span class='notice'>Kalibracja układu celowniczego [src] wynosi teraz [calibration]%.</span>")
		update_cycle_stage_uis()
	else
		to_chat(user, "<span class='notice'>Wynik [best]% nie jest lepszy od obecnej kalibracji ([calibration]%), ustawienia zostają bez zmian.</span>")

// ---------------------------------------------------------------- narzędzia

/obj/machinery/ship_weapon/multitool_act(mob/living/user, obj/item/I)
	if(wear_enabled && maint_state == MSTATE_UNSCREWED)
		INVOKE_ASYNC(src, PROC_REF(calibration_minigame), user, I)
		return TRUE
	return ..()

/// Działo pokładowe łączy multitoolem rdzeń pod pokładem; przy odkręconym panelu multitool kalibruje
/obj/machinery/ship_weapon/deck_turret/multitool_act(mob/living/user, obj/item/I)
	if(wear_enabled && maint_state == MSTATE_UNSCREWED)
		INVOKE_ASYNC(src, PROC_REF(calibration_minigame), user, I)
		return TRUE
	return ..()

/obj/machinery/ship_weapon/proc/pry_actuator(mob/user, obj/item/tool)
	to_chat(user, "<span class='notice'>Zaczynasz wyważać przepalony aktuator z [src]...</span>")
	if(!tool.use_tool(src, user, 3 SECONDS, volume = 50))
		return TRUE
	if(maint_state != MSTATE_UNSCREWED || !remove_actuator())
		return TRUE
	new /obj/item/burnt_actuator(get_turf(user))
	to_chat(user, "<span class='notice'>Wyważasz przepalony aktuator z [src]. Włóż nowy manipulator.</span>")
	return TRUE

/obj/machinery/ship_weapon/crowbar_act(mob/user, obj/item/tool)
	if(wear_enabled && maint_state == MSTATE_UNSCREWED && actuator_state == WEAPON_ACTUATOR_BURNT)
		return pry_actuator(user, tool)
	return ..()

/obj/machinery/ship_weapon/deck_turret/crowbar_act(mob/user, obj/item/tool)
	if(wear_enabled && maint_state == MSTATE_UNSCREWED && actuator_state == WEAPON_ACTUATOR_BURNT)
		return pry_actuator(user, tool)
	return ..()

/obj/machinery/ship_weapon/attackby(obj/item/I, mob/user)
	if(wear_enabled && istype(I, /obj/item/stock_parts/manipulator) && actuator_state == WEAPON_ACTUATOR_MISSING)
		insert_actuator(I, user)
		return TRUE
	return ..()

/obj/machinery/ship_weapon/proc/insert_actuator(obj/item/stock_parts/manipulator/part, mob/user)
	if(maint_state != MSTATE_UNSCREWED)
		to_chat(user, "<span class='warning'>Aktuator wkłada się przy odkręconym panelu serwisowym [src].</span>")
		return
	to_chat(user, "<span class='notice'>Zaczynasz wkładać [part] jako aktuator zamka [src]...</span>")
	if(!do_after(user, 2 SECONDS, target = src))
		return
	if(maint_state != MSTATE_UNSCREWED || actuator_state != WEAPON_ACTUATOR_MISSING || !user.is_holding(part))
		return
	if(!user.temporarilyRemoveItemFromInventory(part))
		return
	qdel(part)
	install_actuator()
	to_chat(user, "<span class='notice'>Wkładasz nowy aktuator zamka do [src].</span>")

// ---------------------------------------------------------------- oględziny i okno broni

/obj/machinery/ship_weapon/proc/wear_examine_lines()
	. = list()
	if(!wear_enabled)
		return
	if(calibration <= WEAPON_CALIBRATION_WARNING)
		. += "<span class='warning'>Kalibracja układu celowniczego: [calibration]%.</span>"
	else
		. += "Kalibracja układu celowniczego: [calibration]%."
	switch(actuator_state)
		if(WEAPON_ACTUATOR_BURNT)
			. += "<span class='warning'>Aktuator zamka jest przepalony. Przy odkręconym panelu wyważ go <i>łomem</i>.</span>"
		if(WEAPON_ACTUATOR_MISSING)
			. += "<span class='warning'>Brakuje aktuatora zamka. Przy odkręconym panelu włóż <i>manipulator</i>.</span>"
	if(maint_state == MSTATE_UNSCREWED && actuator_state == WEAPON_ACTUATOR_OK)
		. += "Przy odkręconym panelu działo można skalibrować <i>multitoolem</i>. Strzał przy odkręconym panelu grozi porażeniem."

/obj/machinery/ship_weapon/mac/examine(mob/user)
	. = ..()
	. += wear_examine_lines()

/obj/machinery/ship_weapon/railgun/examine(mob/user)
	. = ..()
	. += wear_examine_lines()

/obj/machinery/ship_weapon/deck_turret/examine(mob/user)
	. = ..()
	. += wear_examine_lines()

/obj/machinery/computer/ship/munitions_computer/ui_data(mob/user)
	. = ..()
	.["wear_enabled"] = SW?.wear_enabled ? TRUE : FALSE
	.["calibration"] = SW ? SW.calibration : 0
	.["actuator"] = SW ? SW.actuator_state : WEAPON_ACTUATOR_OK

/// Spalony aktuator wyjęty z działa
/obj/item/burnt_actuator
	name = "przepalony aktuator"
	desc = "Spalony aktuator zamka działa okrętowego. Nadaje się już tylko na złom."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "micro_mani"
	color = "#5c4a3c"
	w_class = WEIGHT_CLASS_SMALL

#undef WEAPON_ACTUATOR_OK
#undef WEAPON_ACTUATOR_BURNT
#undef WEAPON_ACTUATOR_MISSING
#undef WEAPON_CALIBRATION_DIGITS
#undef WEAPON_CALIBRATION_WARNING
