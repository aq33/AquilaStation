/obj/item/clothing/under/plasmaman/security
	name = "policyjny kombinezon środowiskowy"
	desc = "Kombinezon ochronny plazmamana przeznaczony dla policjantów. Daje odrobinę dodatkowej ochrony."
	icon_state = "security_envirosuit"
	item_state = "security_envirosuit"
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 95, "acid" = 95, "stamina" = 20, "bleed" = 10)
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/plasmaman/security/warden
	name = "kombinezon środowiskowy naczelnika"
	desc = "Kombinezon ochronny plazmamana przeznaczony dla naczelnika. Dodano białe paski, by odróżnić go od reszty policji."
	icon_state = "warden_envirosuit"
	item_state = "warden_envirosuit"
//looking back at it now I probably coulda grouped the command suits together under one for less clutter.
/obj/item/clothing/under/plasmaman/security/hos
	name = "kombinezon środowiskowy komendanta"
	desc = "Czarny, wyściełany kombinezon środowiskowy przeznaczony dla komendanta. Złote paski i czarna kolorystyka budzą strach i szacunek."
	icon_state = "hos_envirosuit"
	item_state = "hos_envirosuit"

/obj/item/clothing/under/plasmaman/security/secmed
	name = "kombinezon środowiskowy lekarza więziennego"
	desc = "Kombinezon ochronny plazmamana przeznaczony dla lekarzy więziennych. Na piersi ma wymalowany czerwony krzyż."
	icon_state = "secmed_envirosuit"
	item_state = "secmed_envirosuit"
	armor = list("melee" = 5, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 95, "acid" = 95, "stamina" = 20, "bleed" = 10)
