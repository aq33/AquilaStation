// Kolektory promieniowania zostają po porcie BeeStation/BeeStation-Hornet#13442 (w Bee usunięte).
// Impulsy z `collector_power` (SM, osobliwość, pożar trytu, fuzja, stormdrive) karmią kolektory przez SSradiation.feed_collectors().

/// Wszystkie kolektory, które mogą odbierać impulsy
GLOBAL_LIST_EMPTY(rad_collectors)

/obj/machinery/power/rad_collector/Initialize(mapload)
	. = ..()
	GLOB.rad_collectors += src

/obj/machinery/power/rad_collector/Destroy()
	GLOB.rad_collectors -= src
	return ..()
