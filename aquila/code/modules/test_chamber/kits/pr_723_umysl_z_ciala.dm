// aq33/AquilaStation#723 - Umysł z ciała (Fleshmind), etap E9 eventów mapy FTL (aquila/code/modules/events/hexmap/fleshmind/)
// Rój rośnie tylko na obszarach okrętu, a komora jest rezerwacją poza okrętem, więc zestaw (jak zestawy aq33/AquilaStation#720)
// kładzie narzędzia w komorze i po potwierdzeniu odpala event na okręcie.

/datum/test_chamber_kit/pr_720_eventy/pr_723
	name = "PR 723: Umysł z ciała"
	pr = "aq33/AquilaStation#723"
	description = "Odpala event Umysł z ciała na okręcie (nie w komorze). \
	1) Ankieta roli „Kapłan przewodów” trafia do duchów z tą preferencją. Zgłoś się z drugiego konta albo bez zgłoszeń rdzeń wyrośnie sam w tunelach technicznych. \
	2) Jako oko: ruch po okręcie, akcja Wykiełkuj rdzeń odmawia brygu, mostka, maszynowni, kosmosu i pola obok załogi. Po 3 min rdzeń wyrasta sam, a kapłan w szacie z laską rodzi się obok. \
	3) Przewody rosną od rdzenia, ale nie przez ściany, okna i zamknięte drzwi ani do zamkniętych pomieszczeń (najwyżej 200 kawałków w promieniu 20 pól). Przecinak je tnie, EMP wypala je z maszyn. Zwykłe maszyny dostają przewody, fabrykatory zmieniają się w montownie, krytyczne konsole (sterowanie, broń, reaktor, FTL) nigdy. \
	4) Kapłan: akcje struktury, ściana albo drzwi przed sobą, sadzenie przewodów, wezwanie mobów, czat roju; po zniszczeniu rdzenia traci łącze i dostaje obrażenia. \
	5) Ogłoszenie dla załogi po 3 min, poziomy 2 i 3 w ogłoszeniach (VV: our_controller.level_up() na rdzeniu), Mięsonapęd na trzecim poziomie. Mechiwer połyka słabą ofiarę, a martwe ciało oddaje nowy mob roju po śmierci. \
	6) Zniszcz rdzeń (800 wytrzymałości, rośnie z poziomem): struktury znikają, moby się rozpadają, przewody usychają po trochu. \
	7) Przełącz język na angielski: teksty roju i kapłana mają być po angielsku."
	items = list(
		/obj/item/wirecutters = 1,
		/obj/item/grenade/empgrenade = 3,
		/obj/item/gun/energy/ionrifle = 1,
		/obj/item/fireaxe = 1,
		/obj/item/clothing/suit/armor/vest = 1,
		/obj/item/gps = 1,
	)
	events = list(
		/datum/round_event_control/aquila_hex_fleshmind,
	)
