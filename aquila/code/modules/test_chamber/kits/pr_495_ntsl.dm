/datum/test_chamber_kit/pr_495
	name = "NTSL: konsola kontroli ruchu"
	pr = "aq33/AquilaStation#495"
	description = "Konsola widzi serwery całej stacji (sieć tcommsat). Zaloguj się kartą, w edytorze wpisz skrypt, Ctrl+S i Skompiluj, \
		potem mów przez słuchawkę: np. sig.source = sig.source + \" (\" + sig.job + \")\"; albo sig.pass = false; dla jednej pracy. \
		Sprawdź polskie litery w tekstach skryptu, broadcast(signal(\"Cześć\", channels.common, \"Bot\", \"Bot\")); (max 3 na wiadomość), \
		błędy kompilacji po polsku, zakładki Sieć/Log/Pomoc, emag (zostaje System Administrator) i przycisk admina na górze. \
		Na koniec admin reset, żeby przywrócić domyślny skrypt na serwerach stacji."
	items = list(
		/obj/machinery/computer/telecomms/traffic = 1,
		/obj/item/card/id/captains_spare = 1,
		/obj/item/radio/headset/heads/chief_engineer = 1,
		/obj/item/card/emag = 1,
		/obj/item/circuitboard/computer/comm_traffic = 1,
	)

/// The chamber sits in the reservation, so the console needs the mapped console's range to reach the station servers
/datum/test_chamber_kit/pr_495/setup(list/spawned, list/turfs, turf/center, mob/user)
	for(var/obj/machinery/computer/telecomms/traffic/console in spawned)
		console.unlimited_range = TRUE
		console.refresh_servers()
