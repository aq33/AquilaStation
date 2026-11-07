// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Dawne get_turf_above/below: przesunięcie z cechy mapy
/proc/aquila_multiz_old_step(turf/T, trait)
	var/offset = SSmapping.level_trait(T.z, trait)
	if(!offset)
		return null
	return locate(T.x, T.y, T.z + offset)

/// Dawne get_zs_in_range: chodzenie po kafelkach od środka z-levelu
/proc/aquila_multiz_old_zs(z_level, max_z_range)
	. = list(z_level)
	if(max_z_range <= 0)
		return
	var/turf/center_turf = locate(world.maxx / 2, world.maxy / 2, z_level)
	var/turf/temp = aquila_multiz_old_step(center_turf, ZTRAIT_UP)
	var/i = 0
	while(isturf(temp))
		. += temp.z
		i++
		if(i >= max_z_range)
			break
		temp = aquila_multiz_old_step(temp, ZTRAIT_UP)
	temp = aquila_multiz_old_step(center_turf, ZTRAIT_DOWN)
	i = 0
	while(isturf(temp))
		. += temp.z
		i++
		if(i >= max_z_range)
			break
		temp = aquila_multiz_old_step(temp, ZTRAIT_DOWN)

/// AQUILA - multiz_levels (tgstation/tgstation#76248): na każdym z-levelu piętro wyżej i niżej wychodzi tak samo jak dawniej z level_trait()
/datum/unit_test/aquila_multiz_levels
	var/datum/space_level/lower_level
	var/datum/space_level/upper_level
	var/list/lower_traits
	var/list/upper_traits

/datum/unit_test/aquila_multiz_levels/Run()
	// Każdy z-level ma wpis, także te z add_new_zlevel() (rezerwacje, overmapa, szablony)
	for(var/datum/space_level/level as anything in SSmapping.z_list)
		TEST_ASSERT(level.z_value <= length(SSmapping.multiz_levels) && SSmapping.multiz_levels[level.z_value], "Z-level [level.z_value] ([level.name]) nie ma wpisu w multiz_levels")

	for(var/datum/space_level/level as anything in SSmapping.z_list)
		var/failure = check_level(level)
		if(failure)
			return Fail(failure)

	// Sztuczne połączenie dwóch sąsiednich z-leveli (działa też na mapie z jednym piętrem)
	TEST_ASSERT(length(SSmapping.z_list) >= 2, "Za mało z-leveli na sztuczne połączenie")
	lower_level = SSmapping.z_list[1]
	upper_level = SSmapping.z_list[2]
	lower_traits = lower_level.traits
	upper_traits = upper_level.traits
	// Kopie, bo kilka z-leveli może dzielić jedną listę cech
	lower_level.traits = lower_traits.Copy()
	upper_level.traits = upper_traits.Copy()
	lower_level.traits[ZTRAIT_UP] = TRUE
	upper_level.traits[ZTRAIT_DOWN] = -1
	SSmapping.generate_linkages_for_z_level(lower_level.z_value)
	SSmapping.generate_linkages_for_z_level(upper_level.z_value)
	var/turf/lower_center = locate(round(world.maxx / 2), round(world.maxy / 2), lower_level.z_value)
	var/turf/upper_center = locate(lower_center.x, lower_center.y, upper_level.z_value)
	TEST_ASSERT(GET_TURF_ABOVE(lower_center) == upper_center, "Sztuczne połączenie: GET_TURF_ABOVE nie wskazał z-levelu wyżej")
	TEST_ASSERT(GET_TURF_BELOW(upper_center) == lower_center, "Sztuczne połączenie: GET_TURF_BELOW nie wskazał z-levelu niżej")
	TEST_ASSERT(upper_level.z_value in get_zs_in_range(lower_level.z_value, 1), "Sztuczne połączenie: get_zs_in_range nie widzi z-levelu wyżej (nieaktualny stos pięter)")
	var/failure = check_level(lower_level) || check_level(upper_level)
	if(failure)
		return Fail("Sztuczne połączenie: [failure]")
	var/was_linked_up = lower_traits[ZTRAIT_UP]
	restore_levels()
	TEST_ASSERT(was_linked_up || !(upper_level.z_value in get_zs_in_range(lower_level.z_value, 1)), "Po przywróceniu cech get_zs_in_range dalej widzi sztuczne połączenie")

	// Przedmiot w pojemniku (z = 0) nie ma piętra wyżej ani niżej, jak dawniej
	var/obj/item/storage/box/box = allocate(/obj/item/storage/box, run_loc_floor_bottom_left)
	var/obj/item/toy/crayon/red/crayon = allocate(/obj/item/toy/crayon/red, box)
	TEST_ASSERT(isnull(SSmapping.get_turf_above(crayon)), "Przedmiot w pojemniku dostał kafelek nad sobą")
	TEST_ASSERT(isnull(SSmapping.get_turf_below(crayon)), "Przedmiot w pojemniku dostał kafelek pod sobą")

/// Porównuje nowe makra i helpery z dawną ścieżką na środku z-levelu; zwraca opis błędu albo null
/datum/unit_test/aquila_multiz_levels/proc/check_level(datum/space_level/level)
	var/z = level.z_value
	var/turf/center = locate(round(world.maxx / 2), round(world.maxy / 2), z)
	if(!center)
		return "Brak kafelka na środku z-levelu [z]"
	var/turf/old_above = aquila_multiz_old_step(center, ZTRAIT_UP)
	var/turf/old_below = aquila_multiz_old_step(center, ZTRAIT_DOWN)
	if(GET_TURF_ABOVE(center) != old_above)
		return "Z [z] ([level.name]): GET_TURF_ABOVE dał [GET_TURF_ABOVE(center)], dawniej [old_above]"
	if(GET_TURF_BELOW(center) != old_below)
		return "Z [z] ([level.name]): GET_TURF_BELOW dał [GET_TURF_BELOW(center)], dawniej [old_below]"
	if(SSmapping.get_turf_above(center) != old_above || SSmapping.get_turf_below(center) != old_below)
		return "Z [z] ([level.name]): get_turf_above/below różni się od dawnego wyniku"
	// Dawne turf.above()/below(): get_step(dawny kafelek, 0)
	if(center.above() != get_step(old_above, 0) || center.below() != get_step(old_below, 0))
		return "Z [z] ([level.name]): above()/below() różni się od dawnego get_step_multiz"
	if(get_step_multiz(center, UP|NORTH) != get_step(old_above, NORTH))
		return "Z [z] ([level.name]): get_step_multiz(UP|NORTH) różni się od dawnego"
	for(var/range in list(0, 0.5, 1, 2, 2.8, 5))
		var/list/new_zs = get_zs_in_range(z, range)
		var/list/old_zs = aquila_multiz_old_zs(z, range)
		if(jointext(new_zs, ",") != jointext(old_zs, ","))
			return "Z [z] ([level.name]): get_zs_in_range(z, [range]) dał [jointext(new_zs, ",")], dawniej [jointext(old_zs, ",")]"
	return null

/datum/unit_test/aquila_multiz_levels/proc/restore_levels()
	if(lower_level && lower_traits)
		lower_level.traits = lower_traits
		SSmapping.generate_linkages_for_z_level(lower_level.z_value)
		lower_traits = null
	if(upper_level && upper_traits)
		upper_level.traits = upper_traits
		SSmapping.generate_linkages_for_z_level(upper_level.z_value)
		upper_traits = null

/datum/unit_test/aquila_multiz_levels/Destroy()
	restore_levels()
	return ..()

#undef TEST_ASSERT
