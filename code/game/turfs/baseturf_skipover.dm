// This is a typepath to just sit in baseturfs and act as a marker for other things.
/turf/baseturf_skipover
	name = "zaślepka pomijania baseturfu"
	desc = "To nie powinno istnieć."

/turf/baseturf_skipover/Initialize(mapload)
	. = ..()
	stack_trace("[src]([type]) was instanced which should never happen. Changing into the next baseturf down...")
	ScrapeAway()

/turf/baseturf_skipover/shuttle
	name = "pomijanie baseturfu promu"
	desc = "Służy za dno promu. Bez tego podłoga promu zostaje przebita."

/turf/baseturf_bottom
	name = "zaślepka baseturfu poziomu Z"
	desc = "Znacznik baseturfu poziomu Z, zwykle zamienia się w kosmos."
	baseturfs = /turf/baseturf_bottom
