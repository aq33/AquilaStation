// AQUILA - taśma medyczna (AquilaMed 5), jak medical tape z Baystation12 (code/game/objects/items/weapons/policetape.dm).
// Korzysta z naszej taśmy policyjnej (detectivework/crime_scene/barrier_tape.dm): ten sam sposób rozciągania i przechodzenia,
// tylko unosi ją personel medyczny, a sprite'y to przemalowana taśma policyjna (biało-zielona).

/obj/item/barrier_tape_roll/medical
	name = "rolka taśmy medycznej"
	desc = "Rolka biało-zielonej taśmy do odgradzania kwarantanny albo miejsca wypadku. Użyj w ręce na początku i na końcu odcinka albo kliknij nią drzwi. Personel medyczny może ją unieść."
	icon_state = "medical_start"
	tape_type = /obj/structure/barrier_tape/medical
	icon_base = "medical"

/obj/structure/barrier_tape/medical
	name = "taśma medyczna"
	desc = "Biało-zielona taśma medyczna: KWARANTANNA - NIE PRZEKRACZAĆ. Personel medyczny może ją unieść, reszta zostawi na niej ślady."
	icon_state = "medical_h"
	icon_base = "medical"
	req_access = list(ACCESS_MEDICAL)
	scrap_type = /obj/item/barrier_tape_scrap/medical

/obj/item/barrier_tape_scrap/medical
	name = "strzęp taśmy medycznej"
	desc = "Strzęp zerwanej taśmy medycznej. Może mieć na sobie ślady tego, kto ją zerwał."
	icon_state = "medical_h_c"
