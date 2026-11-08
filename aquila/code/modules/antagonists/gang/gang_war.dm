// Wojna gangów Aquili: zawsze dwa gangi, limit członków rosnący z załogą (jak w kulcie i rewolucji),
// cel ostateczny - przejęcie stacji Dominatorem (aquila/code/game/gamemodes/gangs/dominator.dm).
// Wzory: FTL13 (stary tg) code/game/gamemodes/gang/, panel i limit jak aquila/code/modules/antagonists/revolution/revolution_panel.dm.

/// Każdy gang: ilu żywych członków (z szefami) może mieć naraz
#define GANG_MIN_CAP 3
#define GANG_MAX_CAP 8
/// Ile otwartych kafelków w promieniu 3 potrzebuje dominator
#define DOM_REQUIRED_TURFS 30

/datum/game_mode/gang
	required_enemies = 2
	recommended_enemies = 2

/datum/team/gang
	/// world.time końca przejęcia albo NOT_DOMINATING
	var/domination_time = NOT_DOMINATING
	/// Ile razy gang może jeszcze włączyć dominator
	var/dom_attempts = INITIAL_DOM_ATTEMPTS
	/// Gang przejął stację dominatorem
	var/dominated = FALSE
	/// Limit żywych członków gangu; rośnie z liczbą żywej załogi, nigdy nie spada
	var/gang_cap = 0

/datum/team/gang/New(starting_members)
	. = ..()
	var/datum/objective/gang_dominate/objective = new
	objective.team = src
	objectives += objective
	update_gang_cap()

// Podczas przejęcia gang nie zdobywa wpływów (ostrzeżenie przy włączaniu dominatora)
/datum/team/gang/update_influence()
	if(domination_time != NOT_DOMINATING)
		return 0
	return ..()

/// Liczba terenów do zajęcia na stacji; liczona raz na 10 s, bo panel i okno pytają co chwilę
/datum/team/gang/proc/claimable_territories_cached()
	var/static/cached_total = 0
	var/static/cached_at = -INFINITY
	if(world.time - cached_at > 10 SECONDS)
		cached_total = total_claimable_territories()
		cached_at = world.time
	return max(1, cached_total)

/// Procent terenu stacji pod kontrolą gangu
/datum/team/gang/proc/territory_percent()
	return round(LAZYLEN(territories) / claimable_territories_cached() * 100, 1)

/// Czas przejęcia w sekundach: im więcej terenu gang kontroluje, tym krócej (3-8 minut)
/datum/team/gang/proc/determine_domination_time()
	var/total = claimable_territories_cached()
	return max(180, 480 - round(LAZYLEN(territories) / total * 100, 1) * 9)

/datum/team/gang/proc/domination(modifier = 1)
	domination_time = world.time + determine_domination_time() * modifier * 10
	set_security_level("delta")

/// Sekundy do końca przejęcia
/datum/team/gang/proc/domination_time_remaining()
	return max(0, (domination_time - world.time) / 10)

/// Przelicza limit jak w rewolucji (1/3 żywych graczy), ale na dwa gangi: 1/6 żywych na gang, w granicach min-max, tylko w górę
/datum/team/gang/proc/update_gang_cap()
	var/living_players = 0
	for(var/mob/M in GLOB.player_list)
		if(!M.client || isnewplayer(M) || M.stat == DEAD)
			continue
		living_players++
	var/new_cap = clamp(round(living_players / 6), GANG_MIN_CAP, GANG_MAX_CAP)
	if(new_cap <= gang_cap)
		return
	var/announce = gang_cap > 0
	gang_cap = new_cap
	if(!announce)
		return
	for(var/datum/mind/member in members)
		to_chat(member.current, "<span class='danger'>Załoga jest teraz na tyle liczna, że gang [name] może liczyć <span class='userdanger'>[gang_cap]</span> członków.</span>")

/// Żywi członkowie gangu, szefowie pierwsi
/datum/team/gang/proc/living_members()
	. = list()
	for(var/datum/mind/member in leaders + (members - leaders))
		if(member.current && member.current.stat != DEAD && member.has_antag_datum(/datum/antagonist/gang))
			. += member

/datum/team/gang/proc/can_recruit()
	update_gang_cap()
	return length(living_members()) < gang_cap

/// Komunikat dla werbującego, gdy gang jest pełny
/datum/team/gang/proc/cap_reached_message(mob/user)
	to_chat(user, "<span class='warning'>Gang [name] osiągnął limit [gang_cap] członków. Kolejne miejsca zwolnią się, gdy załoga się powiększy albo ktoś z was zginie.</span>")

// Werbunek długopisem i implantem sprawdza limit (admini i tryb gry dodają bez ograniczeń)
/obj/item/pen/gang/add_gangster(mob/user, datum/team/gang/gang, datum/mind/gangster_mind, check = TRUE)
	if(check && gang && !gang.can_recruit())
		gang.cap_reached_message(user)
		return FALSE
	return ..()

/obj/item/implant/gang/implant(mob/living/target, mob/user, silent = 0)
	if(gang && !gang.can_recruit())
		if(user)
			gang.cap_reached_message(user)
		return FALSE
	return ..()

/datum/antagonist/gang/on_gain()
	. = ..()
	if(gang)
		objectives |= gang.objectives
		gang.update_gang_cap()

// Okno roli jak w rewolucji i kulcie: stan gangu zmienia się w trakcie rundy, więc jest w ui_data z autoodświeżaniem
/datum/antagonist/gang
	ui_name = "AntagInfoGang"

// Przycisk okna roli z kapeluszem gangstera zamiast ogólnej ikony
/datum/action/antag_info/New(Target)
	. = ..()
	if(istype(target, /datum/antagonist/gang))
		name = "Gang"
		icon_icon = 'aquila/icons/hud/gang_button.dmi'
		button_icon_state = "gang"

/datum/antagonist/gang/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, ui_name, name)
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/antagonist/gang/ui_data(mob/user)
	var/list/data = list()
	if(!gang)
		return data
	gang.update_gang_cap()
	var/list/living = gang.living_members()
	data["gang_name"] = gang.name
	data["gang_color"] = gang.color
	data["leader"] = istype(src, /datum/antagonist/gang/boss)
	data["members"] = length(living)
	data["cap"] = gang.gang_cap
	data["leaders"] = length(gang.leaders & living)
	data["territory"] = gang.territory_percent()
	data["influence"] = gang.influence
	data["dom_attempts"] = gang.dom_attempts
	data["dominating"] = gang.domination_time != NOT_DOMINATING
	data["dom_remaining"] = gang.domination_time_remaining()
	data["dom_estimate"] = gang.determine_domination_time()
	var/list/rivals = list()
	for(var/datum/team/gang/rival in GLOB.gangs)
		if(rival == gang)
			continue
		rivals += list(list("name" = rival.name, "color" = rival.color, "territory" = rival.territory_percent(), "dominating" = rival.domination_time != NOT_DOMINATING))
	data["rivals"] = rivals
	var/list/member_list = list()
	for(var/datum/mind/member as anything in living)
		var/rank = "Gangster"
		if(member.has_antag_datum(/datum/antagonist/gang/boss/lieutenant))
			rank = "Porucznik"
		else if(member.has_antag_datum(/datum/antagonist/gang/boss))
			rank = "Szef"
		member_list += list(list("name" = member.name, "rank" = rank, "job" = member.assigned_role, "you" = member == owner))
	data["member_list"] = member_list
	return data

/datum/game_mode/gang/set_round_result()
	. = ..()
	// Przejęcie dominatorem wygrywa niezależnie od terenu
	for(var/datum/team/gang/G in GLOB.gangs)
		if(G.dominated)
			for(var/datum/team/gang/other in GLOB.gangs)
				other.winner = (other == G)
			return

/datum/objective/gang_dominate
	name = "przejęcie stacji"
	explanation_text = "Przejmijcie stację Dominatorem: kupcie go w gangtoolu, postawcie na swoim terenie i brońcie, aż skończy przejęcie."
	martyr_compatible = TRUE

/datum/objective/gang_dominate/check_completion()
	var/datum/team/gang/G = team
	return istype(G) && G.dominated

// Dominator w sklepie gangtoola
/datum/gang_item/equipment/dominator
	name = "Dominator stacji"
	id = "dominator"
	cost = 30
	item_path = /obj/machinery/dominator
	spawn_msg = "<span class='notice'><b>Dominator</b> zapewni twojemu gangowi władzę nad stacją. Włącz go, kiedy będziecie gotowi go bronić.</span>"

/datum/gang_item/equipment/dominator/can_buy(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	if(!gang || !gang.dom_attempts || gang.domination_time != NOT_DOMINATING)
		return FALSE
	return ..()

/datum/gang_item/equipment/dominator/get_name_display(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	if(!gang || !gang.dom_attempts)
		return ..()
	return "<b>[..()]</b>"

/datum/gang_item/equipment/dominator/get_cost_display(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	if(!gang || !gang.dom_attempts)
		return "(brak w magazynie)"
	return ..()

/datum/gang_item/equipment/dominator/get_extra_info(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	if(gang)
		return "(szacowany czas przejęcia: [round(gang.determine_domination_time() / 60, 0.1)] min)"

/datum/gang_item/equipment/dominator/purchase(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool, check_canbuy = TRUE)
	var/area/user_area = get_area(user)
	var/turf/user_turf = get_turf(user)
	if(!user_turf || isspaceturf(user_turf) || !is_station_level(user_turf.z))
		to_chat(user, "<span class='warning'>Dominator działa tylko na stacji!</span>")
		return FALSE
	for(var/obj/thing in user_turf)
		if(thing.density)
			to_chat(user, "<span class='warning'>Tu nie ma dość miejsca!</span>")
			return FALSE
	if(aq_dominator_walls_check(user_turf))
		to_chat(user, "<span class='warning'><b>Dominator</b> tu nie zadziała! W promieniu trzech jednostek potrzebuje sporo otwartej przestrzeni, żeby ściany nie zagłuszały sygnału.</span>")
		return FALSE
	if(!gang || !(user_area.type in (gang.territories | gang.new_territories)))
		to_chat(user, "<span class='warning'><b>Dominator</b> można postawić tylko na terenie kontrolowanym przez twój gang!</span>")
		return FALSE
	return ..()

/datum/gang_item/equipment/dominator/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	new item_path(get_turf(user))
	to_chat(user, spawn_msg)

/// Te same zasady co sprawdzanie ścian działającego dominatora: za mało otwartych kafelków w promieniu 3
/proc/aq_dominator_walls_check(turf/center)
	if(isclosedturf(center))
		return TRUE
	var/open = 0
	for(var/turf/open/T in view(3, center))
		open++
	return open < DOM_REQUIRED_TURFS

/obj/effect/countdown/dominator
	name = "odliczanie dominatora"
	text_size = 1
	color = "#ff00ff" // nadpisywany kolorem gangu przy starcie

/obj/effect/countdown/dominator/get_value()
	var/obj/machinery/dominator/D = attached_to
	if(!istype(D))
		return
	if(D.gang && D.gang.domination_time != NOT_DOMINATING)
		return round(D.gang.domination_time_remaining())
	return "WYŁ."

#undef GANG_MIN_CAP
#undef GANG_MAX_CAP
#undef DOM_REQUIRED_TURFS
