
//BeanieStation13 Redux

//Plus a bobble hat, lets be inclusive!!

/*
	Contents: 

		White, black, red, green, dark blue, purple, yellow, orange and cyan beanies.

		Christmas, striped, red striped, blue striped, green striped, durathread beanies.

		Red striped bobble hat (waldo hat), rastacap.

*/

/obj/item/clothing/head/beanie //Default is white, this is meant to be seen
	name = "biała czapka zimowa"
	desc = "Stylowa czapka zimowa. Idealny zimowy dodatek dla osób z wyczuciem mody i dla tych, którzy po prostu nie znoszą zimnego wiatru na głowie."
	icon_state = "beanie" //Default white
	custom_price = 10
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/head/beanie/black
	name = "czarna czapka zimowa"
	icon_state = "beanie"
	color = "#4A4A4B" //Grey but it looks black

/obj/item/clothing/head/beanie/red
	name = "czerwona czapka zimowa"
	icon_state = "beanie"
	color = "#D91414" //Red

/obj/item/clothing/head/beanie/green
	name = "zielona czapka zimowa"
	icon_state = "beanie"
	color = "#5C9E54" //Green

/obj/item/clothing/head/beanie/darkblue
	name = "granatowa czapka zimowa"
	icon_state = "beanie"
	color = "#1E85BC" //Blue

/obj/item/clothing/head/beanie/purple
	name = "fioletowa czapka zimowa"
	icon_state = "beanie"
	color = "#9557C5" //purple

/obj/item/clothing/head/beanie/yellow
	name = "żółta czapka zimowa"
	icon_state = "beanie"
	color = "#E0C14F" //Yellow

/obj/item/clothing/head/beanie/orange
	name = "pomarańczowa czapka zimowa"
	icon_state = "beanie"
	color = "#C67A4B" //orange

/obj/item/clothing/head/beanie/cyan
	name = "błękitna czapka zimowa"
	icon_state = "beanie"
	color = "#54A3CE" //Cyan (Or close to it)

//Striped Beanies have unique sprites

/obj/item/clothing/head/beanie/christmas
	name = "świąteczna czapka zimowa"
	icon_state = "beaniechristmas"

/obj/item/clothing/head/beanie/striped
	name = "czapka zimowa w paski"
	icon_state = "beaniestriped"

/obj/item/clothing/head/beanie/stripedred
	name = "czapka zimowa w czerwone paski"
	icon_state = "beaniestripedred"

/obj/item/clothing/head/beanie/stripedblue
	name = "czapka zimowa w niebieskie paski"
	icon_state = "beaniestripedblue"

/obj/item/clothing/head/beanie/stripedgreen
	name = "czapka zimowa w zielone paski"
	icon_state = "beaniestripedgreen"

/obj/item/clothing/head/beanie/durathread
	name = "czapka zimowa z duranici"
	desc = "Czapka zimowa z duranici. Jej wytrzymałe włókna zapewniają noszącemu pewną ochronę."
	icon_state = "beaniedurathread"
	armor = list("melee" = 15, "bullet" = 5, "laser" = 15, "energy" = 5, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 5, "stamina" = 20, "bleed" = 40)

/obj/item/clothing/head/beanie/waldo
	name = "czapka z pomponem w czerwone paski"
	desc = "Jeśli wybierasz się na wędrówkę dookoła świata, przyda ci się ochrona przed zimnem."
	icon_state = "waldo_hat"

/obj/item/clothing/head/beanie/rasta
	name = "czapka rasta"
	desc = "Idealna do upchnięcia dredów."
	icon_state = "beanierasta"
