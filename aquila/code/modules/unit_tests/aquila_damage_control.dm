/// AQUILA - konsola kontroli uszkodzeń (aquila/code/modules/overmap/damage_control/dc_console.dm): stan przedziału z ciśnienia
/// i alarmu pożarowego, obrys obszaru z polami pomiarowymi i najniższe ciśnienie w przedziale.
/datum/unit_test/aquila_damage_control

/datum/unit_test/aquila_damage_control/Run()
	var/area/test_area = get_area(run_loc_floor_bottom_left)
	if(dc_area_state(test_area, 5) != "breach")
		return Fail("Ciśnienie 5 kPa nie dało wyłomu")
	if(dc_area_state(test_area, 50) != "low" && !test_area.fire)
		return Fail("Ciśnienie 50 kPa nie dało stanu „mało powietrza”")
	var/old_fire = test_area.fire
	test_area.fire = TRUE
	if(dc_area_state(test_area, 101) != "fire")
		test_area.fire = old_fire
		return Fail("Alarm pożarowy nie dał stanu „pożar”")
	test_area.fire = old_fire
	if(!old_fire && dc_area_state(test_area, 101) != "ok")
		return Fail("Szczelny przedział bez pożaru nie jest w porządku")
	var/list/bounds = dc_area_bounds(test_area)
	if(!bounds || bounds[1] != run_loc_floor_bottom_left.z || !length(bounds[6]))
		return Fail("Obrys obszaru testowego bez poziomu albo pól pomiarowych")
	if(dc_area_pressure(bounds) <= 0)
		return Fail("Przedział testowy z powietrzem ma ciśnienie [dc_area_pressure(bounds)]")
