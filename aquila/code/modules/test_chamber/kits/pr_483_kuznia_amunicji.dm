/datum/test_chamber_kit/pr_483
	name = "PR 483: kuźnia amunicji"
	pr = "aq33/AquilaStation#483"
	description = "Piec łukowy ma własny zapas materiałów. Kliknij go ręką: w oknie wybierz wyrób, materiał albo stop dwóch materiałów (koszt po połowie) i klasę, potem Odlej. Gołą ręką odlew parzy, w czarnych rękawicach nie. Gorącą część połóż pod młotem mechanicznym i kliknij: klasę I młot wykuje sam (animacja, bez okna), wyższa klasa otwiera kucie ręczne z nutami (Spacja, przy wyższej klasie też Q i E). Celowo spudłuj kilka razy na klasie III+ i sprawdź, że klasa spadła, a część ma rysy. Zimną część dogrzej w piecu (włóż ją, w oknie Dogrzej). Obudowy głowic są zablokowane do zbadania głowic torped w R&D. Stół montażowy: korpus + zapalnik (+ wypełnienie) -> wyrób; klasa IV/V błyszczy. Analizatorem zeskanuj piec, część i wyrób. Galwanizer: włóż zwykłe pudełko 10mm, wybierz srebro, po 10 s ma cechę srebra i brak klasy w nazwie. Łuski 10mm klasy I przełóż do magazynka stechkina i postrzelaj: broń zużywa się szybciej (examine) i czasem się zacina (użyj jej w ręce, żeby odblokować). Obudowę głowicy torpedy włóż w kadłub torpedy z zestawu i dokończ budowę: torpeda ma mieć materiał w nazwie."
	items = list(
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
