/obj/item/clothing/neck
	name = "naszyjnik"
	icon = 'icons/obj/clothing/neck.dmi'
	body_parts_covered = NECK
	slot_flags = ITEM_SLOT_NECK
	strip_delay = 40
	equip_delay_other = 40

/obj/item/clothing/neck/worn_overlays(mutable_appearance/standing, isinhands = FALSE)
	. = list()
	if(!isinhands)
		if(body_parts_covered & HEAD)
			if(damaged_clothes)
				. += mutable_appearance('icons/effects/item_damage.dmi', "damagedmask")
			if(HAS_BLOOD_DNA(src))
				var/mutable_appearance/bloody_neck = mutable_appearance('icons/effects/blood.dmi', "maskblood")
				bloody_neck.color = get_blood_dna_color(return_blood_DNA())
				. += bloody_neck

/obj/item/clothing/neck/tie
	name = "krawat"
	desc = "Krawat na klips z neojedwabiu."
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "bluetie"
	item_state = ""	//no inhands
	w_class = WEIGHT_CLASS_SMALL
	custom_price = 15

/obj/item/clothing/neck/tie/blue
	name = "niebieski krawat"
	icon_state = "bluetie"

/obj/item/clothing/neck/tie/red
	name = "czerwony krawat"
	icon_state = "redtie"

/obj/item/clothing/neck/tie/black
	name = "czarny krawat"
	icon_state = "blacktie"

/obj/item/clothing/neck/tie/horrible
	name = "okropny krawat"
	desc = "Krawat na klips z neojedwabiu. Ten jest obrzydliwy."
	icon_state = "horribletie"

/obj/item/clothing/neck/tie/detective
	name = "poluzowany krawat"
	desc = "Luźno zawiązany krawat, idealny dodatek dla przepracowanego detektywa."
	icon_state = "detective"

/obj/item/clothing/neck/maid
	name = "kołnierzyk pokojówki"
	desc = "Kołnierzyk do stroju pokojówki. Pachnie lekko rozczarowaniem."
	icon_state = "maid_neck"

/obj/item/clothing/neck/stethoscope
	name = "stetoskop"
	desc = "Przestarzały przyrząd medyczny do osłuchiwania dźwięków ludzkiego ciała. Do tego sprawia, że wyglądasz, jakbyś wiedział, co robisz."
	icon_state = "stethoscope"

/obj/item/clothing/neck/stethoscope/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] przykłada [src] do swojej klatki piersiowej! Wygląda na to, że niewiele usłyszy!</span>")
	return OXYLOSS

/obj/item/clothing/neck/stethoscope/attack(mob/living/carbon/human/M, mob/living/user)
	if(ishuman(M) && isliving(user))
		if(!user.combat_mode)
			var/body_part = parse_zone(user.zone_selected)

			var/heart_strength = "<span class='danger'>brak</span>"
			var/lung_strength = "<span class='danger'>brak</span>"

			var/obj/item/organ/heart/heart = M.getorganslot(ORGAN_SLOT_HEART)
			var/obj/item/organ/lungs/lungs = M.getorganslot(ORGAN_SLOT_LUNGS)

			if(!(M.stat == DEAD || (HAS_TRAIT(M, TRAIT_FAKEDEATH))))
				if(heart && istype(heart))
					heart_strength = "<span class='danger'>niestabilny</span>"
					if(heart.beating)
						heart_strength = "zdrowy"
				if(lungs && istype(lungs))
					lung_strength = "<span class='danger'>utrudniony</span>"
					if(!(M.failed_last_breath || M.losebreath))
						lung_strength = "zdrowy"

			if(M.stat == DEAD && heart && !(heart.organ_flags & ORGAN_FAILING)) // AQ EDIT - no defib time limit
				heart_strength = "<span class='boldannounce'>słaby, trzepoczący</span>"

			var/diagnosis = (body_part == BODY_ZONE_CHEST ? "Puls: [heart_strength], oddech: [lung_strength]." : "Słabo słyszysz puls: [heart_strength].")
			user.visible_message("[user] przykłada [src] do ciała [M] ([strefa_pl(body_part)]) i uważnie nasłuchuje.", "<span class='notice'>Przykładasz [src] do ciała [M] ([strefa_pl(body_part)]). [diagnosis]</span>")
			return
	return ..(M,user)

///////////
//SCARVES//
///////////

/obj/item/clothing/neck/scarf //Default white color, same functionality as beanies.
	name = "biały szalik"
	icon_state = "scarf"
	desc = "Stylowy szalik. Idealny zimowy dodatek dla osób z wyczuciem mody i dla tych, którzy po prostu nie znoszą zimnego wiatru na szyi."
	dog_fashion = /datum/dog_fashion/head
	custom_price = 10

/obj/item/clothing/neck/scarf/black
	name = "czarny szalik"
	icon_state = "scarf"
	color = "#4A4A4B" //Grey but it looks black

/obj/item/clothing/neck/scarf/pink
	name = "różowy szalik"
	icon_state = "scarf"
	color = "#F699CD" //Pink

/obj/item/clothing/neck/scarf/red
	name = "czerwony szalik"
	icon_state = "scarf"
	color = "#D91414" //Red

/obj/item/clothing/neck/scarf/green
	name = "zielony szalik"
	icon_state = "scarf"
	color = "#5C9E54" //Green

/obj/item/clothing/neck/scarf/darkblue
	name = "granatowy szalik"
	icon_state = "scarf"
	color = "#1E85BC" //Blue

/obj/item/clothing/neck/scarf/purple
	name = "fioletowy szalik"
	icon_state = "scarf"
	color = "#9557C5" //Purple

/obj/item/clothing/neck/scarf/yellow
	name = "żółty szalik"
	icon_state = "scarf"
	color = "#E0C14F" //Yellow

/obj/item/clothing/neck/scarf/orange
	name = "pomarańczowy szalik"
	icon_state = "scarf"
	color = "#C67A4B" //Orange

/obj/item/clothing/neck/scarf/cyan
	name = "błękitny szalik"
	icon_state = "scarf"
	color = "#54A3CE" //Cyan


//Striped scarves get their own icons

/obj/item/clothing/neck/scarf/zebra
	name = "szalik w zebrę"
	icon_state = "zebrascarf"

/obj/item/clothing/neck/scarf/christmas
	name = "świąteczny szalik"
	icon_state = "christmasscarf"

//The three following scarves don't have the scarf subtype
//This is because Ian can equip anything from that subtype
//However, these 3 don't have corgi versions of their sprites
/obj/item/clothing/neck/stripedredscarf
	name = "szalik w czerwone paski"
	icon_state = "stripedredscarf"
	custom_price = 10

/obj/item/clothing/neck/stripedgreenscarf
	name = "szalik w zielone paski"
	icon_state = "stripedgreenscarf"
	custom_price = 10

/obj/item/clothing/neck/stripedbluescarf
	name = "szalik w niebieskie paski"
	icon_state = "stripedbluescarf"
	custom_price = 10

/obj/item/clothing/neck/petcollar  // adding an OOC restriction to an IC action, like wearing a collar, is gay.
	name = "obroża dla zwierzaka"
	desc = "Jest dla zwierzaków. Raczej nie powinno się jej nosić samemu, chyba że chcesz się ośmieszyć."
	icon_state = "petcollar"
	var/tagname = null

/obj/item/clothing/neck/petcollar/attack_self(mob/user)
	tagname = stripped_input(user, "Czy chcesz zmienić imię na zawieszce?", "Nazwij swojego nowego zwierzaka", "Spot", MAX_NAME_LEN)
	name = "[initial(name)] - [tagname]"

//////////////
//DOPE BLING//
//////////////

/obj/item/clothing/neck/necklace/dope
	name = "złoty naszyjnik"
	desc = "Kurczę, dobrze być gangsterem."
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "bling"

/obj/item/clothing/neck/neckerchief
	icon = 'icons/obj/clothing/masks.dmi' //In order to reuse the bandana sprite
	w_class = WEIGHT_CLASS_TINY
	var/sourceBandanaType

/obj/item/clothing/neck/neckerchief/worn_overlays(mutable_appearance/standing, isinhands)
	. = ..()
	if(!isinhands)
		var/mutable_appearance/realOverlay = mutable_appearance('icons/mob/mask.dmi', icon_state)
		realOverlay.pixel_y = -3
		. += realOverlay

/obj/item/clothing/neck/neckerchief/AltClick(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.get_item_by_slot(ITEM_SLOT_NECK) == src)
			to_chat(user, "<span class='warning'>Nie możesz rozwiązać [src], gdy ją nosisz!</span>")
			return
		if(user.is_holding(src))
			var/obj/item/clothing/mask/bandana/newBand = new sourceBandanaType(user)
			var/currentHandIndex = user.get_held_index_of_item(src)
			var/oldName = src.name
			qdel(src)
			user.put_in_hand(newBand, currentHandIndex)
			user.visible_message("[user] rozwiązuje [oldName], przywracając postać: [newBand.name]", "Rozwiązujesz [oldName], przywracając postać: [newBand.name]")
		else
			to_chat(user, "<span class='warning'>Musisz trzymać [src], by ją rozwiązać!")

/////////////////
//DONATOR ITEMS//
/////////////////

/obj/item/clothing/neck/bizzarescarf
	name = "dziwaczny szalik"
	desc = "Twoja następna kwestia brzmi:"
	icon_state = "bizzare"

/obj/item/clothing/neck/conductivescarf
	name = "przewodzący szalik"
	desc = "Zrobiony z 30 000 skarabeuszy. Używać ostrożnie."
	icon_state = "conductive"
