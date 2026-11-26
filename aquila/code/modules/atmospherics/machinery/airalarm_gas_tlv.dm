// AQUILA - Alarm powietrza zna każdy gaz. Listy TLV w code/modules/atmospherics/machinery/airalarm.dm są wpisane na sztywno,
// a gaz spoza listy alarm pomijał po cichu (niebezpieczny wodór czy metan nie wywoływał alarmu).
// Brakujące gazy dostają progi z danych gazu (/datum/gas/proc/generate_TLV(), GLOB.gas_data.TLVs).
// Alarm bez sprawdzania (serwerownia) dostaje dla nich no_checks. Wpisy na sztywno wygrywają.

/obj/machinery/airalarm/Initialize(mapload, ndir, nbuild)
	. = ..()
	fill_gas_tlv()

/// Dopisuje do TLV gazy, których alarm nie zna, z progami z danych gazu
/obj/machinery/airalarm/proc/fill_gas_tlv()
	var/no_checks = istype(TLV["pressure"], /datum/tlv/no_checks)
	var/list/gas_tlvs = GLOB.gas_data.TLVs
	for(var/gas in gas_tlvs)
		if(TLV[gas])
			continue
		if(no_checks)
			TLV[gas] = new /datum/tlv/no_checks
			continue
		var/datum/tlv/source = gas_tlvs[gas]
		TLV[gas] = new source.type(source.min2, source.min1, source.max1, source.max2)
