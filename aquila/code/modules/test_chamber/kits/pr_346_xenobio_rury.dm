// aq33/AquilaStation#346 - ksenobiologia: rury zamiast teleportacji, HUD konsoli, paski recyklera

/datum/test_chamber_kit/pr_346
	name = "PR 346: konsola xenobio - rury i HUD"
	pr = "aq33/AquilaStation#346"
	description = "Recykler małp jest połączony z konsolą (ta sama strefa). Wrzuć małpy do recyklera - ma mieć fioletowe paski, a HUD konsoli pokazać liczbę małp. \
	Włóż do konsoli miksturę (klik miksturą) - HUD pokazuje załadowaną miksturę. Usiądź przy konsoli: wciągnij szlam (shift-klik), wypluj go (klik na podłogę), \
	nakarm małpą - obiekty mają lecieć rurą z animacją i dźwiękiem sprężonego powietrza zamiast znikać. Kamera zapewnia podgląd areny. HUD znika po wstaniu od konsoli."
	items = list(
		/obj/machinery/monkey_recycler = 1,
		/obj/machinery/computer/camera_advanced/xenobio = 1,
		/obj/machinery/camera = 1,
		/mob/living/simple_animal/slime = 3,
		/mob/living/carbon/monkey = 3,
		/obj/item/food/monkeycube = 3,
		/obj/item/slimepotion/slime/steroid = 1,
	)
