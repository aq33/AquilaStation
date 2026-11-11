/// AQUILA - AI combat numbers an admin can change during the round (Debug > Strojenie AI).
/// Defaults come from the AI sandbox battles; nothing here survives a restart.

/// Damage of hits between two AI ships (overmap_scale.dm)
GLOBAL_VAR_INIT(ai_vs_ai_damage_mult, 0.4)
/// Scales every AI ship's fear (ai_morale.dm)
GLOBAL_VAR_INIT(ai_fear_mult, 1.15)
/// Fear from which a ship rolls to break off (ai_morale.dm)
GLOBAL_VAR_INIT(ai_fear_retreat, 55)
/// Fear from which a ship always runs (ai_morale.dm)
GLOBAL_VAR_INIT(ai_fear_panic, 85)
/// Gun spread in degrees of a panicking AI ship (ai_morale.dm)
GLOBAL_VAR_INIT(ai_fear_max_spread, 20)
/// Chance that a fleet coordinates its next torpedo salvo (ai_torpedo_tactics.dm)
GLOBAL_VAR_INIT(ai_salvo_chance, 60)
/// Chance that a losing fleet calls for help (fleet_distress.dm)
GLOBAL_VAR_INIT(ai_distress_chance, 65)

/// list(global var name, label, min, max)
GLOBAL_LIST_INIT(ai_tuning_settings, list(
	list("ai_vs_ai_damage_mult", "Obrażenia AI w AI (mnożnik)", 0, 2),
	list("ai_fear_mult", "Strach okrętów AI (mnożnik)", 0, 3),
	list("ai_fear_retreat", "Próg strachu: może przerwać walkę", 0, 100),
	list("ai_fear_panic", "Próg strachu: ucieka na pewno", 0, 100),
	list("ai_fear_max_spread", "Rozrzut dział w panice (stopnie)", 0, 60),
	list("ai_salvo_chance", "Szansa na salwę torped (%)", 0, 100),
	list("ai_distress_chance", "Szansa na wezwanie pomocy (%)", 0, 100),
))

/world/AVerbsDebug()
	. = ..()
	. += /client/proc/ai_tuning

/client/proc/ai_tuning()
	set category = "Debug"
	set name = "Strojenie AI"
	set desc = "Zmienia na żywo liczby walki AI: obrażenia AI w AI, strach, progi odwrotu, rozrzut, szanse salwy i wezwania pomocy."
	if(!check_rights(R_DEBUG))
		return
	var/list/choices = list()
	for(var/list/setting as anything in GLOB.ai_tuning_settings)
		choices["[setting[2]]: [GLOB.vars[setting[1]]]"] = setting
	var/picked = tgui_input_list(usr, "Którą wartość zmienić?", "Strojenie AI", choices)
	if(!picked || !check_rights(R_DEBUG))
		return
	var/list/setting = choices[picked]
	var/value = tgui_input_number(usr, "[setting[2]], od [setting[3]] do [setting[4]]:", "Strojenie AI", GLOB.vars[setting[1]], setting[4], setting[3], round_value = FALSE)
	if(isnull(value) || !check_rights(R_DEBUG))
		return
	value = clamp(value, setting[3], setting[4])
	var/old_value = GLOB.vars[setting[1]]
	GLOB.vars[setting[1]] = value
	message_admins("[key_name_admin(usr)] zmienił strojenie AI: [setting[2]] [old_value] → [value].")
	// "May break off" above "always runs" would leave no roll band at all
	if(GLOB.ai_fear_retreat > GLOB.ai_fear_panic)
		if(setting[1] == "ai_fear_panic")
			GLOB.ai_fear_retreat = GLOB.ai_fear_panic
		else
			GLOB.ai_fear_panic = GLOB.ai_fear_retreat
		message_admins("Strojenie AI: próg „może przerwać walkę” ([GLOB.ai_fear_retreat]) nie może być wyżej niż „ucieka na pewno” ([GLOB.ai_fear_panic]), drugi próg wyrównany.")
	log_admin("[key_name(usr)] set AI tuning [setting[1]] from [old_value] to [value].")
