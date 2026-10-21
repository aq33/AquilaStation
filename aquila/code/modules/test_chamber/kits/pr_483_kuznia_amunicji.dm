/datum/test_chamber_kit/pr_483
	name = "PR 483: kuźnia amunicji"
	pr = "aq33/AquilaStation#483"
	description = "Tygiel ma własny zapas materiałów. W basenie odlej korpus (wybór materiału), wypełnienie i zapalnik; gołą ręką odlew parzy, w czarnych rękawicach nie. \
	Kuj pod młotem (multitool = tryb automatyczny), zimne części dogrzej w piecu. Monter: korpus + zapalnik (+ wypełnienie) -> wyrób, sprawdź examine. \
	Łuski 10mm przełóż do magazynka stechkina i strzel w cel (np. uran/plazma/bananium). Obudowę głowicy torpedy włóż w kadłub torpedy z zestawu i dokończ budowę: torpeda ma mieć materiał w nazwie. \
	Kliknij w tygiel, młot i piec z różnych stron (wielokaflowe)."
	items = list(
		/obj/item/munition_cast/casings = 1,
		/obj/item/munition_cast/shell = 1,
		/obj/item/munition_cast/warhead = 1,
		/obj/item/munition_cast/filler = 1,
		/obj/item/munition_cast/fuze = 1,
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
	var/obj/machinery/munitions_forge/crucible/crucible = new(locate(center.x - 4, center.y + 1, center.z))
	new /obj/machinery/munitions_forge/basin(locate(center.x - 1, center.y + 2, center.z))
	new /obj/machinery/munitions_forge/hammer(locate(center.x + 2, center.y + 2, center.z))
	new /obj/machinery/munitions_forge/furnace(locate(center.x + 2, center.y - 3, center.z))
	new /obj/machinery/munitions_forge/assembler(locate(center.x - 1, center.y - 3, center.z))
	var/datum/component/material_container/container = crucible.get_container()
	for(var/key in GLOB.munition_materials)
		var/datum/munition_material/M = GLOB.munition_materials[key]
		container?.insert_amount_mat(MINERAL_MATERIAL_AMOUNT * 50, M.material_type)
