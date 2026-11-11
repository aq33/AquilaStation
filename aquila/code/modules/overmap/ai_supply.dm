/// AQUILA - skończone zapasy rakiet i torped na lotniskowcach AI (raport/sensory_06_dlaczego_stoja.md, „Uzbrojenie”).
///
/// Bazowe resupply() (ai-skynet.dm) co 5 s dawało okrętowi w promieniu 15 pól od lotniskowca pełny magazyn rakiet
/// i torped. Amunicja kierowana była więc nieskończona: okręt torpedowy mógł stać przy lotniskowcu i strzelać
/// do końca bitwy. Teraz lotniskowiec ma ograniczony zapas i przy jednym podejściu oddaje tylko kilka sztuk.
/// Amunicja do dział i naprawa kadłuba zostają jak w bazie.

/// Debug > Toggle AI finite supply
GLOBAL_VAR_INIT(ai_finite_supply_enabled, TRUE)

/// Ile rakiet i torped lotniskowiec ma do rozdania przez całą bitwę
#define AI_SUPPLY_TORPEDOES 20
#define AI_SUPPLY_MISSILES 40
/// Ile oddaje przy jednym cyklu uzupełniania (bazowo co 5 s)
#define AI_SUPPLY_TORPEDOES_PER_CYCLE 2
#define AI_SUPPLY_MISSILES_PER_CYCLE 4

/obj/structure/overmap
	/// AQUILA - torpedy do rozdania; -1 dopóki lotniskowiec nie zacznie uzupełniać
	var/ai_supply_torpedoes = -1
	/// AQUILA - rakiety do rozdania; -1 dopóki lotniskowiec nie zacznie uzupełniać
	var/ai_supply_missiles = -1

/obj/structure/overmap/proc/stock_ai_supply()
	if(ai_supply_torpedoes < 0)
		ai_supply_torpedoes = AI_SUPPLY_TORPEDOES
	if(ai_supply_missiles < 0)
		ai_supply_missiles = AI_SUPPLY_MISSILES

/// Czy ten okręt zaopatrzenia ma jeszcze torpedy do oddania (nieruszony zapas też się liczy)
/obj/structure/overmap/proc/has_ai_torpedo_stock()
	return ai_supply_torpedoes != 0

/// Pełne nadpisanie bazowego resupply() przy włączonym przełączniku (klasa C, LEGACY_OVERRIDES.md):
/// to samo co w bazie, tylko rakiety i torpedy z zapasu lotniskowca i po kilka naraz.
/obj/structure/overmap/resupply()
	if(!GLOB.ai_finite_supply_enabled || !ai_controlled)
		return ..()
	resupplying--
	var/obj/structure/overmap/target = resupply_target
	resupply_target = null
	if(!target || QDELETED(target) || overmap_dist(src, target) > resupply_range)
		return
	stock_ai_supply()
	if(target.max_torpedoes > 0)
		var/torpedy = clamp(target.max_torpedoes - target.torpedoes, 0, min(AI_SUPPLY_TORPEDOES_PER_CYCLE, ai_supply_torpedoes))
		target.torpedoes += torpedy
		ai_supply_torpedoes -= torpedy
	if(target.max_missiles > 0)
		var/rakiety = clamp(target.max_missiles - target.missiles, 0, min(AI_SUPPLY_MISSILES_PER_CYCLE, ai_supply_missiles))
		target.missiles += rakiety
		ai_supply_missiles -= rakiety
	target.shots_left = target.max_shots_left
	target.try_repair(target.max_integrity * 0.1)

/// Bazowy cel "Re-arm at supply ship" wysyłał okręt bez torped do lotniskowca zawsze. Przy pustych zapasach
/// floty taki okręt stałby przy lotniskowcu do końca bitwy; teraz walczy dalej tym, co ma.
/datum/ai_goal/rearm/check_score(obj/structure/overmap/OM)
	. = ..()
	if(. != AI_SCORE_PRIORITY || !GLOB.ai_finite_supply_enabled)
		return
	// Działa i kadłub mają pierwszeństwo, ich bazowy powód zostaje
	if(OM.max_shots_left && OM.shots_left < OM.max_shots_left / 3)
		return
	for(var/obj/structure/overmap/supply as anything in OM.fleet?.taskforces["supply"])
		if(!QDELETED(supply) && supply != OM && supply.has_ai_torpedo_stock())
			return
	return 0

/world/AVerbsDebug()
	. = ..()
	. += /client/proc/toggle_ai_finite_supply

/client/proc/toggle_ai_finite_supply()
	set category = "Debug"
	set name = "Toggle AI finite supply"
	set desc = "Włącza lub wyłącza skończone zapasy rakiet i torped na lotniskowcach AI (wyłączone: pełny magazyn co 5 s jak w bazowym NSV13)."
	if(!check_rights(R_DEBUG))
		return
	GLOB.ai_finite_supply_enabled = !GLOB.ai_finite_supply_enabled
	var/state = GLOB.ai_finite_supply_enabled ? "włączył" : "wyłączył"
	message_admins("[key_name_admin(usr)] [state] skończone zapasy rakiet i torped u AI.")
	log_admin("[key_name(usr)] toggled AI finite supply to [GLOB.ai_finite_supply_enabled].")

#undef AI_SUPPLY_TORPEDOES
#undef AI_SUPPLY_MISSILES
#undef AI_SUPPLY_TORPEDOES_PER_CYCLE
#undef AI_SUPPLY_MISSILES_PER_CYCLE
