// aq33/AquilaStation#714 - turbina gazowa z wymiennymi łopatkami i statorem (plan maszynowni E16, port Goona)

/datum/test_chamber_kit/pr_714
	name = "Maszynownia: turbina gazowa"
	pr = "aq33/AquilaStation#714"
	description = "1) Na środku stoi turbina (3×5 pól). Z zachodu podpięty jest kanister gorącego azotu (ok. 1200 K), na wschodzie pusty kanister odbiera schłodzony gaz. \
		2) Otwórz okno turbiny (klik w obudowę z dowolnego pola obok): wirnik rusza, rośnie moc. Ustaw obciążenie statora tak, żeby obroty trzymały się koło 600 obr./min (najwięcej mocy). \
		3) Zmniejsz obciążenie prawie do zera: wirnik wchodzi na nadobroty, łopatki tracą wytrzymałość (iskry, dym), a przy zerze turbina rozpada się i sypie odłamkami. Za duże obciążenie dławi wirnik do zera. \
		4) Zespawaj obudowę i załóż nowe łopatki, gdy wirnik stoi (4 s). Złote łopatki są cięższe, diamentowe wytrzymalsze, srebrny stator daje więcej prądu. Opis części pokazuje masę, wytrzymałość i mnożnik. \
		5) Autolathe w „Construction”: łopatki (5 arkuszy) i stator (3 arkusze) z wybranego materiału. Płytka turbiny jest w protolacie inżynierii po „Zaawansowanej manipulacji energią”, obok TEG. \
		6) Zbuduj turbinę z ramy w ciasnym miejscu: rama odmówi, dopóki nie ma wolnych 3×5 pól."
	items = list(
		/obj/item/weldingtool/largetank = 1,
		/obj/item/crowbar = 1,
		/obj/item/screwdriver = 1,
		/obj/item/analyzer = 1,
		/obj/item/circuitboard/machine/blade_turbine = 1,
		/obj/item/stack/sheet/plasteel/twenty = 1,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stack/cable_coil = 1,
	)

/datum/test_chamber_kit/pr_714/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	if(!center || aq_turbine_blocked_turf(center))
		to_chat(user, "<span class='warning'>Brak wolnego miejsca 3×5 na turbinę wokół środka komory.</span>")
		return
	var/obj/machinery/atmospherics/components/binary/blade_turbine/turbine = new(center)
	spawned += turbine
	for(var/obj/item/turbine_part/part as anything in list(/obj/item/turbine_part/blade, /obj/item/turbine_part/blade, /obj/item/turbine_part/stator))
		spawned += new part(get_step(center, SOUTH))
	var/list/materials = list(
		/datum/material/gold = MINERAL_MATERIAL_AMOUNT * 5,
		/datum/material/diamond = MINERAL_MATERIAL_AMOUNT * 5,
		/datum/material/silver = MINERAL_MATERIAL_AMOUNT * 3,
	)
	var/i = 0
	for(var/obj/item/turbine_part/part in get_step(center, SOUTH))
		i++
		var/list/part_material = list()
		part_material[materials[i]] = materials[materials[i]]
		part.set_custom_materials(part_material)
	// Wejście: kanister → złącze → rura → turbina; wyjście: turbina → rura → złącze → pusty kanister
	var/turf/west = locate(center.x - 2, center.y, center.z)
	var/turf/east = locate(center.x + 2, center.y, center.z)
	var/list/atmos = list(
		new /obj/machinery/atmospherics/pipe/simple/general/visible(get_step(center, WEST), TRUE, EAST),
		new /obj/machinery/atmospherics/pipe/simple/general/visible(get_step(center, EAST), TRUE, EAST),
		new /obj/machinery/atmospherics/components/unary/portables_connector/visible(west, TRUE, EAST),
		new /obj/machinery/atmospherics/components/unary/portables_connector/visible(east, TRUE, WEST),
	)
	for(var/obj/machinery/atmospherics/A as anything in atmos)
		spawned += A
	turbine.on_construction()
	for(var/obj/machinery/atmospherics/A as anything in atmos)
		A.on_construction(null, PIPING_LAYER_DEFAULT)
	var/obj/machinery/portable_atmospherics/canister/hot = new /obj/machinery/portable_atmospherics/canister(west)
	var/datum/gas_mixture/hot_air = hot.return_air()
	hot_air.set_temperature(1200)
	hot_air.set_moles(GAS_N2, 4000 * hot_air.return_volume() / (R_IDEAL_GAS_EQUATION * 1200))
	var/obj/machinery/portable_atmospherics/canister/empty = new /obj/machinery/portable_atmospherics/canister(east)
	spawned += hot
	spawned += empty
	hot.connect(locate(/obj/machinery/atmospherics/components/unary/portables_connector) in west)
	empty.connect(locate(/obj/machinery/atmospherics/components/unary/portables_connector) in east)
