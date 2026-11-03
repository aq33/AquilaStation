// AQUILA - zewnętrzny openspace (próżnia nad statkiem) przyjmuje powietrze tylko z góry, jak zwykły kosmos.
// Inaczej każda podłoga pod nim (np. zadokowany prom ewakuacyjny na Atlasie) wietrzy się w górę.
/turf/open/openspace/airless/zAirIn(direction, turf/source)
	return (direction == DOWN)
