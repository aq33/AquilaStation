/// AQUILA - zlecenia szpiega na zdjęcia (pomysł z Goona: BOUNTY_TYPE_PHOTO w code/datums/gamemodes/spy_theft.dm).
/// Szpieg robi aparatem zdjęcie wskazanej osoby (żywej), w trudniejszej wersji w jej dziale, i przykłada je do uplinku.
/// W Goonie miejsce wskazywało, gdzie oddać zdjęcie; u nas zdjęcie ma pokazywać osobę w tym miejscu.

/// Gdzie stały osoby na zdjęciu: REF(mob) -> typ obszaru w chwili zrobienia zdjęcia
/datum/picture/var/list/aquila_seen_areas

/obj/item/camera/after_picture(mob/user, datum/picture/picture, proximity_flag)
	if(picture)
		picture.aquila_seen_areas = list()
		for(var/mob/seen as anything in picture.mobs_seen)
			var/area/seen_area = get_area(seen)
			if(seen_area)
				picture.aquila_seen_areas[REF(seen)] = seen_area.type
	return ..()

/// Zdjęcie żywej osoby
/datum/spy_bounty/targets_person/photo
	difficulty = SPY_DIFFICULTY_EASY
	theft_time = 2 SECONDS
	black_market_prob = 0
	weight = 2
	/// Typ obszaru, w którym osoba ma być na zdjęciu; null, gdy wszędzie
	var/area/required_area
	/// Opis miejsca do nazwy zlecenia („na mostku”)
	var/required_area_text

/datum/spy_bounty/targets_person/photo/is_valid_crewmember(mob/living/carbon/human/crewmember)
	return istype(crewmember) && crewmember.stat != DEAD

/datum/spy_bounty/targets_person/photo/target_found(mob/crewmember)
	name = "Zdjęcie: [crewmember.real_name]"
	help = "Zrób aparatem zdjęcie osoby [crewmember.real_name], póki żyje, i przyłóż je do uplinku."
	return TRUE

/datum/spy_bounty/targets_person/photo/is_stealable(atom/movable/stealing)
	var/obj/item/photo/photo = stealing
	if(!istype(photo) || !photo.picture)
		return FALSE
	var/mob/living/target = target_ref?.resolve()
	if(!target || !(target in photo.picture.mobs_seen) || (target in photo.picture.dead_seen))
		return FALSE
	if(!required_area)
		return TRUE
	return ispath(photo.picture.aquila_seen_areas?[REF(target)], required_area)

/// Zdjęcie osoby w jej dziale (szef ochrony w ochronie, kapitan na mostku)
/datum/spy_bounty/targets_person/photo/location
	difficulty = SPY_DIFFICULTY_MEDIUM
	/// Działy: lista stanowisk -> obszar i opis miejsca; pierwsze pasujące wygrywa, więc dowództwo jest pierwsze
	var/static/list/department_areas

/datum/spy_bounty/targets_person/photo/location/proc/get_department_areas()
	if(!department_areas)
		department_areas = list(
			list(GLOB.command_positions, /area/bridge, "na mostku"),
			list(GLOB.security_positions, /area/security, "w dziale ochrony"),
			list(GLOB.engineering_positions, /area/engine, "w inżynierii"),
			list(GLOB.medical_positions, /area/medical, "w dziale medycznym"),
			list(GLOB.science_positions, /area/science, "w dziale naukowym"),
			list(GLOB.supply_positions, /area/quartermaster, "w dziale zaopatrzenia"),
			list(GLOB.munitions_positions, /area/nsv/weapons, "w dziale uzbrojenia"),
		)
	return department_areas

/// Obszar i opis miejsca dla stanowiska osoby albo null, gdy jej działu nie ma na okręcie
/datum/spy_bounty/targets_person/photo/location/proc/department_of(mob/crewmember)
	var/role = crewmember.mind?.assigned_role
	if(!role)
		return null
	for(var/list/department as anything in get_department_areas())
		if(!(role in department[1]))
			continue
		if(!area_type_on_station(department[2]))
			return null
		return department
	return null

/// Czy na poziomie okrętu jest jakiś obszar tego typu (albo podtypu)
/datum/spy_bounty/targets_person/photo/location/proc/area_type_on_station(area_type)
	for(var/area/candidate as anything in GLOB.sortedAreas)
		if(istype(candidate, area_type) && candidate.z && is_station_level(candidate.z))
			return TRUE
	return FALSE

/datum/spy_bounty/targets_person/photo/location/is_valid_crewmember(mob/living/carbon/human/crewmember)
	return ..() && department_of(crewmember)

/datum/spy_bounty/targets_person/photo/location/target_found(mob/crewmember)
	var/list/department = department_of(crewmember)
	if(!department)
		return FALSE
	required_area = department[2]
	required_area_text = department[3]
	name = "Zdjęcie: [crewmember.real_name] [required_area_text]"
	help = "Zrób aparatem zdjęcie osoby [crewmember.real_name], póki żyje, kiedy jest [required_area_text], i przyłóż je do uplinku."
	return TRUE

// PDA skanuje zdjęcie do komunikatora, zanim attackby dojdzie do sygnału, więc uplink w PDA sprawdza zdjęcie tutaj
/obj/item/modular_computer/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/photo))
		var/datum/component/spy_uplink/uplink = GetComponent(/datum/component/spy_uplink)
		if(uplink?.try_photo(attacking_item, user))
			return
	return ..()
