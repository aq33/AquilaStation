// aq33/AquilaStation#402 - fabrykator swarmerów znów produkuje skorupy

/datum/test_chamber_kit/pr_402
	name = "PR 402: fabrykator swarmerów"
	pr = "aq33/AquilaStation#402"
	description = "Fabrykator swarmerów (bez kosztów materiałów) ma co ok. 30 s wytwarzać skorupę swarmera (ghost spawner), zamiast stać w nieskończoność. \
	Produkuje bez limitu - zresetuj komorę po sprawdzeniu."
	items = list(
		/obj/machinery/droneDispenser/swarmer = 1,
	)
