/// AQUILA - „Swiss Cheese” (aquila/code/modules/overmap/modules/swiss_cheese.dm): trafienie od dziobu ląduje na dziobie
/// mapy pokładu, lewa burta na północy, pełny pancerz nie robi wyłomu, a dziura pogłębia następne trafienie.
/datum/unit_test/aquila_swiss_cheese
	var/obj/structure/overmap/small_craft/ship

/datum/unit_test/aquila_swiss_cheese/Run()
	ship = allocate(/obj/structure/overmap/small_craft/combat/light)
	var/fail = check_deck_point() || check_depth()
	if(fail)
		return Fail(fail)

/datum/unit_test/aquila_swiss_cheese/proc/check_deck_point()
	var/list/bounds = list(50, 100, 150, 140) // pokład: x 50..150 (rufa..dziób), y 100..140 (prawa..lewa burta)
	// trafienie w dziób, pocisk leci ku rufie (w układzie okrętu: -y)
	var/list/point = swiss_cheese_deck_point(bounds, 1, 0, 0, -1)
	if(point[1] != 150 || point[2] != 120 || point[3] != -1 || point[4] != 0)
		return "Trafienie w dziób wylądowało w [point[1]],[point[2]] z kierunkiem [point[3]],[point[4]] zamiast 150,120 i -1,0"
	// trafienie w lewą burtę na śródokręciu, pocisk leci ku prawej burcie (+x)
	point = swiss_cheese_deck_point(bounds, 0, -1, 1, 0)
	if(point[1] != 100 || point[2] != 140 || point[3] != 0 || point[4] != -1)
		return "Trafienie w lewą burtę wylądowało w [point[1]],[point[2]] z kierunkiem [point[3]],[point[4]] zamiast 100,140 i 0,-1"

/datum/unit_test/aquila_swiss_cheese/proc/check_depth()
	var/turf/hit = locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y + 1, run_loc_floor_bottom_left.z)
	if(ship.deck_hole_depth(hit, 1) != 0)
		return "Pełny pancerz dał głębokość [ship.deck_hole_depth(hit, 1)] zamiast 0 (samo wgniecenie)"
	var/broken = ship.deck_hole_depth(hit, 0)
	if(broken <= 0)
		return "Zbity pancerz nie dał wyłomu"
	ship.add_deck_hole(hit, broken)
	if(ship.deck_hole_depth(hit, 0) <= broken)
		return "Trafienie w starą dziurę nie weszło głębiej"
	if(ship.deck_hole_depth(hit, 1) <= 0)
		return "Przy pełnym pancerzu stara dziura nie przepuściła trafienia głębiej"
