/datum/export/large/crate
	cost = 500
	k_elasticity = 0
	unit_name = "skrzynia"
	export_types = list(/obj/structure/closet/crate)
	exclude_types = list(/obj/structure/closet/crate/large, /obj/structure/closet/crate/wooden, /obj/structure/closet/crate/mail)

/datum/export/large/crate/total_printout(datum/export_report/ex, notes = TRUE) // That's why a goddamn metal crate costs that much.
	. = ..()
	if(. && notes)
		. += " Dziękujemy za udział w Programie Recyklingu Skrzyń Nanotrasen."

/datum/export/large/crate/wooden
	cost = 100
	unit_name = "duża skrzynia"
	export_types = list(/obj/structure/closet/crate/large)
	exclude_types = list()

/datum/export/large/crate/wooden/ore
	unit_name = "skrzynia na rudę"
	export_types = list(/obj/structure/ore_box)

/datum/export/large/crate/wood
	cost = 240
	unit_name = "drewniana skrzynia"
	export_types = list(/obj/structure/closet/crate/wooden)
	exclude_types = list()

/datum/export/large/crate/coffin
	cost = 140 //50 wood costs 1700, makes 10 coffins, makes 1400 back. No free money allowed, considering they can be easlily stacked with disposal loops. Additionally you still get 600 credits from the box + manifest either way, for a total of 2000 back. Total of 300 profit for wasting your time building coffins.
	unit_name = "trumna"
	export_types = list(/obj/structure/closet/crate/coffin)

/datum/export/large/reagent_dispenser
	cost = 100 // +0-400 depending on amount of reagents left
	var/contents_cost = 400

/datum/export/large/reagent_dispenser/get_cost(obj/O)
	var/obj/structure/reagent_dispensers/D = O
	var/ratio = D.reagents.total_volume / D.reagents.maximum_volume

	return ..() + round(contents_cost * ratio)

/datum/export/large/reagent_dispenser/water
	unit_name = "zbiornik wody"
	export_types = list(/obj/structure/reagent_dispensers/watertank)
	contents_cost = 200

/datum/export/large/reagent_dispenser/fuel
	unit_name = "zbiornik paliwa"
	export_types = list(/obj/structure/reagent_dispensers/fueltank)

/datum/export/large/reagent_dispenser/beer
	unit_name = "beczka piwa"
	contents_cost = 700
	export_types = list(/obj/structure/reagent_dispensers/beerkeg)


/datum/export/large/pipedispenser
	cost = 500
	unit_name = "dozownik rur"
	export_types = list(/obj/machinery/pipedispenser)

/datum/export/large/emitter
	cost = 550
	unit_name = "emiter"
	export_types = list(/obj/machinery/power/emitter)

/datum/export/large/field_generator
	cost = 550
	unit_name = "generator pola"
	export_types = list(/obj/machinery/field/generator)

/datum/export/large/collector
	cost = 400
	unit_name = "kolektor promieniowania"
	export_types = list(/obj/machinery/power/rad_collector)

/datum/export/large/tesla_coil
	cost = 450
	unit_name = "cewka Tesli"
	export_types = list(/obj/machinery/power/tesla_coil)

/datum/export/large/pa
	cost = 350
	unit_name = "część akceleratora cząstek"
	export_types = list(/obj/structure/particle_accelerator)

/datum/export/large/pa/controls
	cost = 500
	unit_name = "konsola sterowania akceleratorem cząstek"
	export_types = list(/obj/machinery/particle_accelerator/control_box)

/datum/export/large/supermatter
	cost = 8000
	unit_name = "odłamek supermaterii"
	export_types = list(/obj/machinery/power/supermatter_crystal/shard)

/datum/export/large/grounding_rod
	cost = 350
	unit_name = "pręt uziemiający"
	export_types = list(/obj/machinery/power/grounding_rod)

/datum/export/large/tesla_gen
	cost = 4000
	unit_name = "generator kuli energii"
	export_types = list(/obj/machinery/the_singularitygen/tesla)

/datum/export/large/singulo_gen
	cost = 4000
	unit_name = "generator osobliwości grawitacyjnej"
	export_types = list(/obj/machinery/the_singularitygen)
	include_subtypes = FALSE

/datum/export/large/am_control_unit
	cost = 4000
	unit_name = "jednostka sterująca antymaterią"
	export_types = list(/obj/machinery/power/am_control_unit)

/datum/export/large/am_shielding_container
	cost = 150
	unit_name = "spakowana sekcja reaktora antymaterii"
	export_types = list(/obj/item/am_shielding_container)


/datum/export/large/iv
	cost = 50
	unit_name = "kroplówka"
	export_types = list(/obj/machinery/iv_drip)

/datum/export/large/barrier
	cost = 25
	unit_name = "bariera ochrony"
	export_types = list(/obj/item/grenade/barrier, /obj/structure/barricade/security)

/datum/export/large/gas_canister
	cost = 10 //Base cost of canister. You get more for nice gases inside.
	unit_name = "kanister"
	export_types = list(/obj/machinery/portable_atmospherics/canister)
/datum/export/large/gas_canister/get_cost(obj/O)
	var/obj/machinery/portable_atmospherics/canister/C = O
	var/worth = 10

	worth += C.air_contents.get_moles(GAS_BZ)*4
	worth += C.air_contents.get_moles(GAS_STIMULUM)*100
	worth += C.air_contents.get_moles(GAS_HYPERNOB)*1000
	worth += C.air_contents.get_moles(GAS_TRITIUM)*5
	worth += C.air_contents.get_moles(GAS_PLUOXIUM)*5
	worth += C.air_contents.get_moles(GAS_CONSTRICTED_PLASMA)*2 //NSV13 - Constricted plasma export.
	worth += C.air_contents.get_moles(GAS_NUCLEIUM)*50 //NSV13
	return worth
