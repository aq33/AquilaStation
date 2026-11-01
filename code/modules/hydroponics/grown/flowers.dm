/obj/item/food/grown/poppy
	seed = /obj/item/plant_seeds/preset/poppy
	name = "mak"
	desc = "Od dawna symbol odpoczynku, pokoju i śmierci."
	icon_state = "poppy"
	slot_flags = ITEM_SLOT_HEAD
	filling_color = "#FF6347"
	bite_consumption_mod = 3
	foodtypes = VEGETABLES | GROSS
	distill_reagent = /datum/reagent/consumable/ethanol/vermouth

/obj/item/food/grown/poppy/lily
	seed = /obj/item/plant_seeds/preset/lily
	name = "lilia"
	desc = "Piękny biały kwiat o bogatej symbolice. W niektórych kulturach lilia oznacza miłość i czułość, a także czystość i niewinność."
	icon_state = "lily"
	discovery_points = 300

/obj/item/food/grown/trumpet
	seed = /obj/item/plant_seeds/preset/trumpet
	name = "trąbka kosmonauty"
	desc = "Jaskrawy kwiat o delikatnym zapachu świeżo skoszonej trawy. Dotknięcie go po jakimś czasie barwi skórę, choć większość innych powierzchni temu nie ulega."
	icon_state = "spacemanstrumpet"
	filling_color = "#8324f0"
	bite_consumption_mod = 3
	foodtypes = VEGETABLES

/obj/item/food/grown/poppy/geranium
	seed = /obj/item/plant_seeds/preset/geranium
	name = "pelargonia"
	desc = "Kępka małych fioletowych kwiatów pelargonii. Symbolizują szczęście, zdrowie, życzenia i przyjaźń i kojarzą się raczej z pozytywnymi emocjami."
	icon_state = "geranium"
	discovery_points = 300

/obj/item/food/grown/poppy/geranium/forgetmenot
	seed = /obj/item/plant_seeds/preset/forget
	name = "niezapominajka"
	desc = "Kępka małych niebieskich kwiatów, kojarzonych przede wszystkim z pamięcią, szacunkiem i wiernością."
	icon_state = "forget_me_not"
	discovery_points = 300

/obj/item/food/grown/harebell
	seed = /obj/item/plant_seeds/preset/harebell
	name = "dzwonek"
	desc = "„Osłodzę ci smutny grób: nie zbraknie ci kwiatu podobnego twej twarzy, bladej pierwiosnki, ani lazurowego dzwonka, jak twe żyły; ani liścia dzikiej róży, który – nie ujmując mu – nie był słodszy od twego oddechu.”"
	icon_state = "harebell"
	slot_flags = ITEM_SLOT_HEAD
	filling_color = "#E6E6FA"
	bite_consumption_mod = 3
	distill_reagent = /datum/reagent/consumable/ethanol/vermouth

// Sunflower
/obj/item/grown/sunflower // FLOWER POWER!
	seed = /obj/item/plant_seeds/preset/sunflower
	name = "słonecznik"
	desc = "Jest piękny! Pewna osoba mogłaby cię zatłuc na śmierć, gdybyś je podeptał."
	icon_state = "sunflower"
	lefthand_file = 'icons/mob/inhands/weapons/plants_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/plants_righthand.dmi'
	damtype = "fire"
	force = 0
	slot_flags = ITEM_SLOT_HEAD
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 3

/obj/item/grown/sunflower/attack(mob/M, mob/user)
	to_chat(M, "<font color='green'><b> [user] uderza cię słonecznikiem!</font><font color='yellow'><b>MOC KWIATÓW<b></font>")
	to_chat(user, "<font color='green'></font><font color='yellow'><b>MOC KWIATÓW</b></font><font color='green'> twojego słonecznika uderza w [M]</font>")

/obj/item/food/grown/moonflower
	seed = /obj/item/plant_seeds/preset/moonflower
	name = "kwiat księżycowy"
	desc = "Przechowywać co najmniej 50 metrów od wilkołaków."
	icon_state = "moonflower"
	slot_flags = ITEM_SLOT_HEAD
	filling_color = "#E6E6FA"
	bite_consumption_mod = 2
	distill_reagent = /datum/reagent/consumable/ethanol/absinthe //It's made from flowers.
	discovery_points = 300

// Novaflower
/obj/item/grown/novaflower
	seed = /obj/item/plant_seeds/preset/novaflower
	name = "kwiat supernowej"
	desc = "Te piękne kwiaty mają wyrazisty, dymny zapach, jak letnie ognisko."
	icon_state = "novaflower"
	lefthand_file = 'icons/mob/inhands/weapons/plants_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/plants_righthand.dmi'
	damtype = "fire"
	force = 0
	slot_flags = ITEM_SLOT_HEAD
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 3
	attack_verb = list("piecze", "przypieka", "parzy")
	grind_results = list(/datum/reagent/consumable/capsaicin = 0, /datum/reagent/consumable/condensedcapsaicin = 0)
	discovery_points = 300

/obj/item/grown/novaflower/Initialize(mapload)
	..()
	force = round((5 + (get_fruit_trait_power(src) * 8)), 1)

/obj/item/grown/novaflower/attack(mob/living/carbon/M, mob/user)
	if(!..())
		return
	if(isliving(M))
		to_chat(M, "<span class='danger'>Intensywny żar [name] cię podpala!</span>")
		M.adjust_fire_stacks(get_fruit_trait_power(src)+1)
		if(M.IgniteMob())
			message_admins("[ADMIN_LOOKUPFLW(user)] podpala [ADMIN_LOOKUPFLW(M)] za pomocą [src] w [AREACOORD(user)]")
			log_game("[key_name(user)] set [key_name(M)] on fire with [src] at [AREACOORD(user)]")

/obj/item/grown/novaflower/afterattack(atom/A as mob|obj, mob/user,proximity)
	. = ..()
	if(!proximity)
		return
	if(force > 0)
		force -= rand(1, (force / 3) + 1)
	else
		to_chat(usr, "<span class='warning'>Wszystkie płatki odpadły z [name] od gwałtownego machania!</span>")
		qdel(src)

/obj/item/grown/novaflower/pickup(mob/living/carbon/human/user)
	..()
	if(!user.gloves)
		to_chat(user, "<span class='danger'>[name] parzy twoją gołą dłoń!</span>")
		user.adjustFireLoss(rand(1, 5))
