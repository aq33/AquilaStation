// Sprint z BeeStation/BeeStation-Hornet#14750 + wywrotka na ścianie i potknięcie na schodach

/datum/test_chamber_kit/pr_512
	name = "PR 512: stamina i sprint"
	pr = "aq33/AquilaStation#512"
	description = "Jedna pula staminy (250) jak w Bee#14750, błyskawica na HUD-zie (kliknij = wartość). W trybie biegu trzymaj Shift: sprint (SPRINT_DELAY 1.5), 	6.25 staminy za kratkę, chmurka kurzu przy starcie. Poniżej 40% wyczerpanie: bez sprintu, spowolnienie, tylko szept; mija przy 70%. Poniżej 20% każda utrata może dać stamcrit (3 s). 	Zamach przedmiotem kosztuje staminę, dopóki zostaje ponad 100; skrzynka z narzędziami zabiera 47 staminy na trafienie. 	Pałka, policyjna pałka i disabler: dezorientacja (spowolnienie, drgawki), powalają dopiero wyczerpany cel. 	Wbiegnij sprintem z zachodu w kolumnę przeszkód po wschodniej stronie: ściana, okno, zaryglowane drzwi i stół przewracają, człowiek i luźna skrzynia nie. 	Schody sprawdź na mapie z wieloma poziomami (Atlas, Snake, Serendipity albo debugowa multiz)."
	items = list(
		/obj/structure/window/fulltile = 1,
		/obj/structure/table = 1,
		/obj/machinery/door/airlock = 1,
		/obj/structure/closet/crate = 1,
		/mob/living/carbon/human = 1,
		/obj/item/storage/toolbox/mechanical = 1,
		/obj/item/melee/classic_baton/police = 1,
		/obj/item/melee/baton/loaded = 1,
		/obj/item/gun/energy/disabler = 1,
	)

/datum/test_chamber_kit/pr_512/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	var/column_x = center.x + 4
	var/list/obstacles = list(
		locate(/obj/structure/window/fulltile) in spawned,
		locate(/obj/structure/table) in spawned,
		locate(/obj/machinery/door/airlock) in spawned,
		locate(/obj/structure/closet/crate) in spawned,
		locate(/mob/living/carbon/human) in spawned,
	)
	var/y = center.y - 2
	for(var/atom/movable/thing as anything in obstacles)
		var/turf/T = locate(column_x, y, center.z)
		y++
		if(!T || !istype(T.loc, /area/test_chamber/arena) || !thing)
			continue
		thing.forceMove(T)
	// Kawałek ściany nad kolumną (reset komory ją usunie)
	var/turf/wall_turf = locate(column_x, y, center.z)
	if(wall_turf && istype(wall_turf.loc, /area/test_chamber/arena) && !is_blocked_turf(wall_turf, TRUE))
		wall_turf.ChangeTurf(/turf/closed/wall)
	var/obj/machinery/door/airlock/door = locate() in spawned
	door?.bolt()
