// Plan maszynowni E14–E15: krystalizator i kondensator gazu

/datum/test_chamber_kit/pr_krystalizator
	name = "PR: krystalizator i kondensator gazu"
	pr = "aq33/AquilaStation#0"
	description = "Krystalizator ma już gaz na wlocie (zielona rura): tlen, plazmę, wodór i azot. Kondensator ma w rurze frezon i tryt. \
	1) Krystalizator: kliknij, wybierz Standardowy pellet paliwowy, ustaw wlot gazu na 50 mol/s i włącz. Ten przepis nie ma okna temperatury, więc po kilkunastu sekundach pod maszyną od południa leży pellet z przymiotnikiem jakości w nazwie. Okno pokazuje postęp, temperaturę i gazy we wnętrzu. \
	2) Kryształ amoniaku (wodór + azot, 200–240 K): podłącz zamrażarkę RPD do czerwonej rury, ustaw ją na około 220 K i wybierz recepturę. Poza oknem pasek postępu się cofa. Kryształy zmiel w młynku: dają amoniak. \
	3) Zmiana receptury oddaje gaz z wnętrza z powrotem na wlot (analizator na rurze wlotowej). \
	4) Kondensator: kliknij, żeby włączyć. W szybce przybywa niebieskiego płynu (frezon), tryt zostaje w rurze (analizator). Zlewką nabierzesz płyn, a hydraulika (konstruktor) wyprowadza go od strony przeciwnej do rury gazowej. \
	5) Odłamek supermaterii (hipernoblium, tryt, BZ, plazma, tlen w 10–20 K) jest bardzo drogi; to, że powstaje, ogłasza się adminom i nie da się go sprzedać w cargo, sprawdza test aquila_crystallizer."
	items = list(
		/obj/machinery/atmospherics/components/binary/crystallizer = 1,
		/obj/machinery/atmospherics/components/unary/gas_condenser = 1,
		/obj/machinery/atmospherics/components/unary/thermomachine/freezer = 1,
		/obj/item/pipe_dispenser = 1,
		/obj/item/construction/plumbing = 1,
		/obj/item/reagent_containers/glass/beaker/large = 1,
		/obj/item/analyzer = 1,
		/obj/item/wrench = 1,
		/obj/item/screwdriver = 1,
	)

/datum/test_chamber_kit/pr_krystalizator/setup(list/spawned, list/turfs, turf/center, mob/user)
	. = ..()
	for(var/obj/machinery/atmospherics/components/binary/crystallizer/crystallizer in spawned)
		var/datum/gas_mixture/inlet = crystallizer.airs[2]
		inlet.set_moles(GAS_O2, 1000)
		inlet.set_moles(GAS_PLASMA, 2000)
		inlet.set_moles(GAS_H2, 1000)
		inlet.set_moles(GAS_N2, 1000)
		inlet.set_temperature(T20C)
	for(var/obj/machinery/atmospherics/components/unary/gas_condenser/condenser in spawned)
		var/datum/gas_mixture/air = condenser.airs[1]
		air.set_moles(GAS_FREZON, 500)
		air.set_moles(GAS_TRITIUM, 200)
		air.set_temperature(T20C)
