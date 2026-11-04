// aq33/AquilaStation#402 - fabrykator swarmerów znów produkuje skorupy

/datum/test_chamber_kit/pr_402
	name = "PR 402: fabrykator swarmerów"
	pr = "aq33/AquilaStation#402"
	description = "Fabrykator swarmerów (bez kosztów materiałów) ma co ok. 30 s wytwarzać skorupę swarmera (ghost spawner), zamiast stać w nieskończoność. \
	Na swoim kafelku trzyma najwyżej jedną skorupę albo swarmera: kolejna pojawi się dopiero, gdy kafelek się zwolni."
	items = list(
		/obj/machinery/droneDispenser/swarmer = 1,
	)
