/datum/test_chamber_kit/pr_483
	name = "PR 483: kuźnia amunicji"
	pr = "aq33/AquilaStation#483"
	description = "Piec łukowy ma własny zapas materiałów. Włóż formę i kliknij ręką: korpus z materiału albo stopu dwóch materiałów (sprawdź koszt po połowie), wypełnienie i zapalnik. Gołą ręką odlew parzy, w czarnych rękawicach nie. Gorącą część połóż na kowadle i kliknij: okno z nutami (Spacja, przy wyższej klasie też Q i E). Celowo spudłuj kilka razy na klasie III+ i sprawdź, że klasa spadła, a część ma rysy. Zimną część dogrzej w piecu łukowym (włóż ją i kliknij). Stół montażowy: korpus + zapalnik (+ wypełnienie) -> wyrób; klasa IV/V błyszczy. Analizatorem zeskanuj piec, część i wyrób, w ręce wydrukuj raport. Galwanizer: włóż zwykłe pudełko 10mm, wybierz srebro, po 10 s ma cechę srebra i brak klasy w nazwie. Łuski 10mm przełóż do magazynka stechkina i strzel w cel. Obudowę głowicy torpedy włóż w kadłub torpedy z zestawu i dokończ budowę: torpeda ma mieć materiał w nazwie. Ceny eksportu: zeskanuj wyroby skanerem eksportu."
	items = list(
		/obj/item/munition_cast/casings = 1,
		/obj/item/munition_cast/shell = 1,
		/obj/item/munition_cast/warhead = 1,
		/obj/item/munition_cast/filler = 1,
		/obj/item/munition_cast/fuze = 1,
		/obj/item/munitions_analyzer = 1,
		/obj/item/export_scanner = 1,
		/obj/item/ammo_box/c10mm = 2,
		/obj/item/clothing/gloves/color/black = 1,
		/obj/item/multitool = 1,
		/obj/item/gun/ballistic/automatic/pistol = 1,
		/obj/item/target = 1,
		/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing = 1,
		/obj/item/ship_weapon/parts/missile/guidance_system = 1,
		/obj/item/ship_weapon/parts/missile/propulsion_system = 1,
		/obj/item/ship_weapon/parts/missile/iff_card = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/wrench = 1,
		/obj/item/screwdriver = 1,
		/obj/item/weldingtool/largetank = 1,
	)

/datum/test_chamber_kit/pr_483/setup(list/spawned, list/turfs, turf/center, mob/user)
	// Maszyny wielokaflowe stawiamy osobno, żeby nie lądowały na sobie
	var/obj/machinery/munitions_forge/arc_forge/forge = new(locate(center.x - 4, center.y + 1, center.z))
	new /obj/machinery/munitions_forge/anvil(locate(center.x, center.y + 2, center.z))
	new /obj/machinery/munitions_forge/assembly_bench(locate(center.x + 2, center.y + 2, center.z))
	new /obj/machinery/munitions_forge/electroplater(locate(center.x - 1, center.y + 3, center.z))
	var/datum/component/material_container/container = forge.get_container()
	for(var/key in GLOB.munition_materials)
		var/datum/munition_material/M = GLOB.munition_materials[key]
		container?.insert_amount_mat(MINERAL_MATERIAL_AMOUNT * 50, M.material_type)
