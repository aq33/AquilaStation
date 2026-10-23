// aq33/AquilaStation#327 - bluespace pipes, teleportujące gaz rurki (port aq33/tgstation#479)

/datum/test_chamber_kit/pr_327
	name = "PR 327: rurki bluespace"
	pr = "aq33/AquilaStation#327"
	description = "Użyj rurki bluespace w ręce, żeby zmienić nazwę sieci (domyślnie default). RPD postaw dwa porty konektora w różnych miejscach areny, \
	przykręć do każdego rurkę bluespace z tą samą nazwą sieci, podłącz kanister tlenu do jednego i pusty do drugiego - gaz ma przepłynąć (sprawdź analizatorem). \
	Odkręcona rurka zachowuje nazwę (examine). RPD i dyspenser rur nie mogą jej zniszczyć. W R&D węzeł Bluespace Travel odblokowuje projekt w protolathe."
	items = list(
		/obj/item/pipe/bluespace = 3,
		/obj/item/pipe_dispenser = 1,
		/obj/item/wrench = 1,
		/obj/item/analyzer = 1,
		/obj/machinery/portable_atmospherics/canister/oxygen = 1,
		/obj/machinery/portable_atmospherics/canister = 1,
	)
