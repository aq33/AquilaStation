/datum/test_chamber_kit/pr_551
	name = "PR 551: plecaki na siatce kratek"
	pr = "aq33/AquilaStation#551"
	description = "Plecak (7×4), torba na ramię (7×4) i torba podróżna (10×4) oraz przedmioty każdej wielkości: długopisy 1×1, \
		latarki 1×2, pudełka 2×2. Załóż plecak, otwórz go i sprawdź: przeciągnięcie przedmiotu na inną kratkę go przesuwa, \
		a wciśnięcie E albo Q w trakcie przeciągania obraca tylko podgląd, a przedmiot w plecaku leży po staremu i obraca się dopiero po upuszczeniu (latarka kładzie się poziomo). W trakcie przeciągania \
		nad siatką widać podgląd: biały obrys i półprzezroczysta ikona tam, gdzie przedmiot wyląduje, czerwony obrys, gdy się nie zmieści. \
		Puszczenie myszy poza siatką kasuje wybrany obrót. Bez przeciągania E i Q działają jak zwykle. \
		Kliknięcie pustej kratki przedmiotem z ręki kładzie go w tym miejscu, złapanie pudełka za dowolną z jego 4 kratek działa. \
		Siódme pudełko nie wejdzie do plecaka (brak miejsca). Plecak „przepełniony” ma 8 apteczek włożonych siłą: nadmiar wisi \
		na czerwono nad siatką i wskakuje na siatkę, gdy coś wyjmiesz. Skrzynka z narzędziami, apteczka, aktówka i pudełka mają \
		siatkę z dawnym limitem sztuk: nagłówek pokazuje „szt.”, a po dojściu do limitu nic więcej nie wejdzie mimo wolnych kratek. \
		Użyj skrzynki na czymś (radial z narzędziami): ikony w radialu mają zwykły rozmiar i nie są obrócone. \
		Sprawdź w trybie walki i na intencjach."
	items = list(
		/obj/item/storage/backpack = 1,
		/obj/item/storage/backpack/satchel = 1,
		/obj/item/storage/backpack/duffelbag = 1,
		/obj/item/storage/backpack/explorer = 1,
		/obj/item/pen = 6,
		/obj/item/flashlight = 4,
		/obj/item/storage/box = 8,
		/obj/item/storage/toolbox/mechanical = 1,
		/obj/item/storage/firstaid/regular = 1,
		/obj/item/storage/briefcase = 1,
	)

/datum/test_chamber_kit/pr_551/setup(list/spawned, list/turfs, turf/center, mob/user)
	var/obj/item/storage/backpack/explorer/overfull = locate() in spawned
	if(!overfull)
		return
	overfull.name = "przepełniony plecak"
	// 8 apteczek 2x2 to 32 kratki na 28: dwie zostają w przepełnieniu
	for(var/i in 1 to 8)
		var/obj/item/storage/firstaid/kit = new(center)
		SEND_SIGNAL(overfull, COMSIG_TRY_STORAGE_INSERT, kit, null, TRUE, TRUE)
