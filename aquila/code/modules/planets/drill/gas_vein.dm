// AQUILA - złoża gazu na planetach i asteroidach. Pomysł z Frontiera (new-frontiers-14/frontier-station-14, GasDeposit:
// złoże z własną mieszanką 5-25 kmol i wiertło 50 mol/s do 1 kW), zrobione jako podtyp naszych żył z Shiptesta
// (vein.dm), więc wydobycie budzi faunę z wyrw tak jak wiertło na żyle rudy. Wydobywa je ekstraktor gazu
// (gas_extractor.dm). Kodu ani grafik Frontiera nie ma: ikona to nasz gejzer z icons/obj/lavaland/terrain.dmi.
// Zmiany względem Frontiera: bez skanera złóż (skład pokazuje nasz georadarowy skaner), bez punktów sprzedaży gazu
// (mamy eksport kanistrów), skład zależy od typu planety; tryt tylko na planecie wulkanicznej i w małych ilościach,
// bo karmi Stormdrive'a.
// Skład złoża to lista gaz -> list(min, max) moli, więc nowy gaz (np. wodór, metan) dopisuje się jednym wierszem.

/obj/structure/vein/gas
	name = "złoże gazu"
	desc = "Szczelina, z której sączy się gaz uwięziony pod powierzchnią. Wydobędzie go ekstraktor gazu podłączony do rur."
	icon_state = "geyser_soup"
	color = "#a9c4d6"
	ore_list = list()
	mining_charges = 0
	/// Skład złoża: identyfikator gazu (GAS_*) -> list(min, max) moli, losowane przy tworzeniu
	var/list/gas_preset = list(
		GAS_N2 = list(8000, 14000),
		GAS_O2 = list(2000, 4000),
	)
	/// Temperatura gazu w złożu (Frontier: wyjście 20°C)
	var/gas_temperature = T20C
	/// Gaz w złożu; maleje podczas wydobycia
	var/datum/gas_mixture/reserve
	/// Ekstraktor, który stoi na złożu
	var/obj/machinery/atmospherics/components/unary/gas_extractor/our_extractor

/obj/structure/vein/gas/Initialize(mapload)
	. = ..()
	reserve = new
	reserve.set_volume(CELL_VOLUME)
	for(var/gas_id in gas_preset)
		var/list/range = gas_preset[gas_id]
		var/amount = rand(range[1], range[2])
		if(amount > 0)
			reserve.set_moles(gas_id, amount)
	reserve.set_temperature(gas_temperature)

/obj/structure/vein/gas/Destroy()
	if(our_extractor)
		var/obj/machinery/atmospherics/components/unary/gas_extractor/extractor = our_extractor
		our_extractor = null
		extractor.on_vein_gone()
	QDEL_NULL(reserve)
	return ..()

/obj/structure/vein/gas/examine_summary()
	return span_notice("Złoże gazu klasy <b>[vein_class]</b>. Skład pokaże skaner gruntu przyłożony do złoża. Wydobycie, jak wiercenie, rozwściecza okoliczną faunę.")

/obj/structure/vein/gas/get_working_machine()
	if(our_extractor?.extracting)
		return our_extractor

/// Ile moli zostało w złożu
/obj/structure/vein/gas/proc/remaining_moles()
	return reserve ? reserve.total_moles() : 0

/// Zabiera ze złoża do `amount` moli (proporcjonalnie do składu)
/obj/structure/vein/gas/proc/take_gas(amount)
	if(!reserve || amount <= 0)
		return
	return reserve.remove(min(amount, reserve.total_moles()))

/// Odczyt dla georadarowego skanera
/obj/structure/vein/gas/proc/scan_report(mob/user)
	var/total = remaining_moles()
	if(total <= 0)
		to_chat(user, span_notice("Złoże jest puste."))
		return
	to_chat(user, span_notice("Złoże gazu klasy <b>[vein_class]</b>, łącznie <b>[round(total)]</b> moli."))
	to_chat(user, span_danger("Spodziewane wzburzenie fauny: <b>[threat_text()]</b>."))
	var/list/parts = list()
	for(var/gas_id in reserve.get_gases())
		var/moles = reserve.get_moles(gas_id)
		if(moles > 0)
			parts += "[GLOB.gas_data.names[gas_id]] [round(moles)] mol ([round(moles / total * 100)]%)"
	to_chat(user, span_notice("Skład: [english_list(parts)]."))

/// Złoże wyczerpane: zapada się jak żyła rudy
/obj/structure/vein/gas/collapse()
	playsound(loc, 'sound/effects/explosionfar.ogg', 200, TRUE)
	visible_message(span_boldannounce("Złoże gazu się wyczerpuje, a szczelina zapada!"))
	qdel(src)

// Złoża typów planet. Fauna jak w żyłach rud tej planety (veins_*.dm).

/// Planeta wulkaniczna: plazma i dwutlenek węgla, odrobina trytu (fauna z żył planety wulkanicznej, czyli z rodzica)
/obj/structure/vein/gas/lava
	color = "#d68aa9"
	gas_preset = list(
		GAS_PLASMA = list(6000, 12000),
		GAS_CO2 = list(3000, 6000),
		GAS_TRITIUM = list(0, 150),
	)

/// Planeta lodowa: zamrożone powietrze z dwutlenkiem węgla
/obj/structure/vein/gas/ice
	color = "#c8e6f5"
	gas_temperature = 250
	gas_preset = list(
		GAS_N2 = list(6000, 12000),
		GAS_O2 = list(3000, 6000),
		GAS_CO2 = list(1000, 3000),
	)
	mob_types = list(
		/mob/living/basic/mining/wolf = 40,
		/mob/living/basic/mining/polarbear = 40,
		/mob/living/basic/mining/legion/snow/spawner_made = 20,
		/mob/living/basic/mining/ice_demon = 5,
		/mob/living/basic/mining/ice_whelp = 1,
		/mob/living/basic/mining/lobstrosity = 25,
	)

/// Księżyc: podtlenek azotu z azotem i śladem BZ
/obj/structure/vein/gas/moon
	color = "#d9d0e8"
	gas_preset = list(
		GAS_NITROUS = list(4000, 8000),
		GAS_N2 = list(3000, 6000),
		GAS_BZ = list(50, 300),
	)
	mob_types = list(
		/mob/living/basic/mining/goliath = 5,
		/mob/living/basic/mining/basilisk = 30,
		/mob/living/basic/mining/hivelord = 30,
		/mob/living/basic/mining/brimdemon = 20,
		/mob/living/basic/carp = 20,
	)

/// Pole asteroid: dwutlenek węgla, plazma i azot z wnętrza bryły
/obj/structure/vein/gas/asteroid
	color = "#b5a98f"
	gas_preset = list(
		GAS_CO2 = list(4000, 8000),
		GAS_PLASMA = list(2000, 5000),
		GAS_N2 = list(1000, 3000),
	)
	mob_types = list(
		/mob/living/basic/mining/goliath = 60,
		/mob/living/basic/mining/basilisk = 30,
		/mob/living/basic/mining/hivelord = 30,
		/mob/living/basic/mining/brimdemon = 20,
		/mob/living/basic/carp = 20,
	)

/// Wysypisko: dwutlenek węgla, podtlenek azotu i para wodna z rozkładu odpadów
/obj/structure/vein/gas/waste
	color = "#a8b87a"
	gas_preset = list(
		GAS_CO2 = list(5000, 9000),
		GAS_NITROUS = list(1000, 3000),
		GAS_H2O = list(500, 2000),
	)
	faction = list("hivebot")
	mob_types = list(
		/mob/living/basic/hivebot = 40,
		/mob/living/basic/hivebot/range = 30,
		/mob/living/basic/automaton/walkmine/waste = 10,
	)

/// Planeta skalista: azot z dwutlenkiem węgla
/obj/structure/vein/gas/rock
	color = "#c4b09a"
	gas_preset = list(
		GAS_N2 = list(7000, 13000),
		GAS_CO2 = list(2000, 5000),
	)
	mob_types = list(
		/mob/living/basic/mining/goliath/rockplanet = 20,
		/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/rockplanet = 30,
		/mob/living/basic/migo = 10,
		/mob/living/basic/creature = 10,
	)
