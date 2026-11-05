// AQUILA - zewnętrzny openspace (próżnia nad statkiem) wymienia powietrze w pionie tak jak zwykły kosmos.
// Inaczej każda podłoga pod nim (np. zadokowany prom ewakuacyjny na Atlasie) wietrzy się w górę.
// Obie procki są potrzebne: sąsiedztwo atmosu liczy każdy z dwóch kafli osobno (kafel pod spodem pyta o zAirOut(DOWN),
// openspace o zAirIn(UP)), a para łączy się, gdy przepuści którakolwiek strona.
/turf/open/openspace/airless/zAirIn(direction, turf/source)
	return (direction == DOWN)

/turf/open/openspace/airless/zAirOut(direction, turf/source)
	return (direction == UP)
