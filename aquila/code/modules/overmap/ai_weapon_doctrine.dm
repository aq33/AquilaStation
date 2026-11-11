/// AQUILA - działa jako ostateczność dla okrętów AI.
///
/// W piaskownicy działa i obrona punktowa dawały 95% strzałów AI, a rakiety i torpedy leciały średnio z 23-25 pól,
/// czyli z zasięgu dział: AI strzelało tym, co akurat było gotowe, a działa są gotowe zawsze. Teraz okręt AI,
/// który ma amunicję kierowaną pasującą do celu, strzela do niego dalej niż AI_GUNS_CLOSE_RANGE tylko nią;
/// gdy wyrzutnia się przeładowuje albo czeka na salwę floty (ai_torpedo_tactics.dm), nie strzela wcale.
/// Działa wracają z bliska, po wyczerpaniu rakiet i torped albo gdy cel nie pasuje do żadnej amunicji kierowanej
/// (torpedy tylko na cele od MASS_SMALL, rakiety tylko na mniejsze). Przy skończonych zapasach na lotniskowcach
/// (ai_supply.dm) bitwa zaczyna się salwami z dystansu, a kończy działami z bliska.

/// Debug > Toggle AI guns last resort
GLOBAL_VAR_INIT(ai_guns_last_resort_enabled, TRUE)

/// Bliżej działa wolno zawsze
#define AI_GUNS_CLOSE_RANGE 12

/// Broń kierowana z amunicją, która pasuje do celu (przeładowanie i salwa nie mają tu znaczenia)
/obj/structure/overmap/proc/has_ai_guided_option(obj/structure/overmap/target)
	for(var/datum/overmap_ship_weapon/weapon as anything in overmap_weapon_datums)
		if(!(weapon.weapon_control_flags & OSW_CONTROL_AI) || !weapon.is_guided_weapon() || !weapon.get_ammo())
			continue
		if(weapon.is_target_size_valid(target))
			return TRUE
	return FALSE

/// TRUE, gdy okręt AI ma trzymać działa i strzelać do target tylko bronią kierowaną
/obj/structure/overmap/proc/ai_holds_guns_for(obj/structure/overmap/target)
	if(!GLOB.ai_guns_last_resort_enabled || !ai_controlled || !istype(target) || QDELETED(target))
		return FALSE
	if(target.z != z || overmap_dist(src, target) <= AI_GUNS_CLOSE_RANGE)
		return FALSE
	return has_ai_guided_option(target)

/datum/overmap_ship_weapon/can_fire(atom/target, list/inplace_report)
	if(linked_overmap?.ai_controlled && isovermap(target) && !is_guided_weapon() && linked_overmap.ai_holds_guns_for(target))
		return FALSE
	return ..()

/world/AVerbsDebug()
	. = ..()
	. += /client/proc/toggle_ai_guns_last_resort

/client/proc/toggle_ai_guns_last_resort()
	set category = "Debug"
	set name = "Toggle AI guns last resort"
	set desc = "Włącza lub wyłącza zasadę, że AI z amunicją kierowaną strzela z dystansu tylko rakietami i torpedami, a działami z bliska."
	if(!check_rights(R_DEBUG))
		return
	GLOB.ai_guns_last_resort_enabled = !GLOB.ai_guns_last_resort_enabled
	var/state = GLOB.ai_guns_last_resort_enabled ? "włączył" : "wyłączył"
	message_admins("[key_name_admin(usr)] [state] działa jako ostateczność u AI.")
	log_admin("[key_name(usr)] toggled AI guns last resort to [GLOB.ai_guns_last_resort_enabled].")

#undef AI_GUNS_CLOSE_RANGE
