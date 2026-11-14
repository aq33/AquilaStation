/// AQUILA - „Swiss Cheese” (aquila/code/modules/overmap/modules/swiss_cheese.dm) i rozrzut od prędkości poprzecznej
/// (transverse_spread.dm): trafienie od dziobu ląduje na dziobie mapy pokładu, lewa burta na północy, pełny pancerz nie robi
/// wyłomu, dziura pogłębia następne trafienie, a okręt płynący w poprzek linii strzału dostaje większy rozrzut niż stojący.
/datum/unit_test/aquila_swiss_cheese
	var/obj/structure/overmap/small_craft/ship
	var/obj/structure/overmap/small_craft/target

/datum/unit_test/aquila_swiss_cheese/Run()
	ship = allocate(/obj/structure/overmap/small_craft/combat/light)
	target = allocate(/obj/structure/overmap/small_craft/combat/light)
	var/fail = check_deck_point() || check_depth() || check_spread()
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

/datum/unit_test/aquila_swiss_cheese/proc/check_spread()
	ship.forceMove(locate(10, 10, run_loc_floor_bottom_left.z))
	target.forceMove(locate(10, 20, run_loc_floor_bottom_left.z))
	ship.velocity.a = 0
	ship.velocity.e = 0
	target.velocity.a = 0
	target.velocity.e = 0
	var/projectile = /obj/item/projectile/bullet/pdc_round
	if(ship.transverse_spread(target, projectile) != 0)
		return "Stojący cel dał rozrzut [ship.transverse_spread(target, projectile)]"
	target.velocity.e = -2 // leci prosto na strzelca
	if(ship.transverse_spread(target, projectile) > 0.01)
		return "Cel lecący prosto na strzelca dał rozrzut [ship.transverse_spread(target, projectile)]"
	target.velocity.e = 0
	target.velocity.a = 2 // w poprzek linii strzału
	if(ship.transverse_spread(target, projectile) <= 1)
		return "Cel płynący w poprzek dał za mały rozrzut [ship.transverse_spread(target, projectile)]"
