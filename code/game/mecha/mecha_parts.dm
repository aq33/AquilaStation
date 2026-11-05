/////////////////////////
////// Mecha Parts //////
/////////////////////////

/obj/item/mecha_parts
	name = "część mecha"
	icon = 'icons/mecha/mech_construct.dmi'
	icon_state = "blank"
	w_class = WEIGHT_CLASS_GIGANTIC
	flags_1 = CONDUCT_1
	block_upgrade_walk = 1

/obj/item/mecha_parts/proc/try_attach_part(mob/user, obj/mecha/M) //For attaching parts to a finished mech
	if(!user.transferItemToLoc(src, M))
		to_chat(user, "<span class='warning'>[src] przykleił ci się do ręki, nie możesz włożyć go do [M]!</span>")
		return FALSE
	user.visible_message("[user] mocuje [src] do [M].", "<span class='notice'>Mocujesz [src] do [M].</span>")
	return TRUE

/obj/item/mecha_parts/part/try_attach_part(mob/user, obj/mecha/M)
	return

/obj/item/mecha_parts/chassis
	name = "rama mecha"
	icon_state = "backbone"
	interaction_flags_item = NONE			//Don't pick us up!!
	var/construct_type

/obj/item/mecha_parts/chassis/Initialize(mapload)
	. = ..()
	if(construct_type)
		AddComponent(construct_type)

/////////// Ripley

/obj/item/mecha_parts/chassis/ripley
	name = "\improper rama Ripley"
	construct_type = /datum/component/construction/unordered/mecha_chassis/ripley

/obj/item/mecha_parts/part/ripley_torso
	name = "\improper tors Ripley"
	desc = "Tors APLU Ripley. Mieści jednostkę zasilania, rdzeń obliczeniowy i systemy podtrzymywania życia."
	icon_state = "ripley_harness"

/obj/item/mecha_parts/part/ripley_left_arm
	name = "\improper lewe ramię Ripley"
	desc = "Lewe ramię APLU Ripley. Gniazda danych i zasilania pasują do większości narzędzi egzoszkieletów."
	icon_state = "ripley_l_arm"

/obj/item/mecha_parts/part/ripley_right_arm
	name = "\improper prawe ramię Ripley"
	desc = "Prawe ramię APLU Ripley. Gniazda danych i zasilania pasują do większości narzędzi egzoszkieletów."
	icon_state = "ripley_r_arm"

/obj/item/mecha_parts/part/ripley_left_leg
	name = "\improper lewa noga Ripley"
	desc = "Lewa noga APLU Ripley. Mieści dość złożone serwonapędy i systemy utrzymywania równowagi."
	icon_state = "ripley_l_leg"

/obj/item/mecha_parts/part/ripley_right_leg
	name = "\improper prawa noga Ripley"
	desc = "Prawa noga APLU Ripley. Mieści dość złożone serwonapędy i systemy utrzymywania równowagi."
	icon_state = "ripley_r_leg"

///////// Odysseus

/obj/item/mecha_parts/chassis/odysseus
	name = "\improper rama Odysseus"
	construct_type = /datum/component/construction/unordered/mecha_chassis/odysseus

/obj/item/mecha_parts/part/odysseus_head
	name = "\improper głowa Odysseus"
	desc = "Głowa Odysseusa. Mieści zintegrowany skaner HUD medycznego."
	icon_state = "odysseus_head"

/obj/item/mecha_parts/part/odysseus_torso
	name = "\improper tors Odysseus"
	desc="Tors Odysseusa. Mieści jednostkę zasilania, rdzeń obliczeniowy i systemy podtrzymywania życia, a także złącze do montowanego sleepera."
	icon_state = "odysseus_torso"

/obj/item/mecha_parts/part/odysseus_left_arm
	name = "\improper lewe ramię Odysseus"
	desc = "Lewe ramię Odysseusa. Gniazda danych i zasilania pasują do specjalistycznego sprzętu medycznego."
	icon_state = "odysseus_l_arm"

/obj/item/mecha_parts/part/odysseus_right_arm
	name = "\improper prawe ramię Odysseus"
	desc = "Prawe ramię Odysseusa. Gniazda danych i zasilania pasują do specjalistycznego sprzętu medycznego."
	icon_state = "odysseus_r_arm"

/obj/item/mecha_parts/part/odysseus_left_leg
	name = "\improper lewa noga Odysseus"
	desc = "Lewa noga Odysseusa. Mieści złożone serwonapędy i systemy utrzymywania równowagi, które zapewniają stabilność pacjentom w stanie krytycznym."
	icon_state = "odysseus_l_leg"

/obj/item/mecha_parts/part/odysseus_right_leg
	name = "\improper prawa noga Odysseus"
	desc = "Prawa noga Odysseusa. Mieści złożone serwonapędy i systemy utrzymywania równowagi, które zapewniają stabilność pacjentom w stanie krytycznym."
	icon_state = "odysseus_r_leg"

///////// Gygax

/obj/item/mecha_parts/chassis/gygax
	name = "\improper rama Gygax"
	construct_type = /datum/component/construction/unordered/mecha_chassis/gygax

/obj/item/mecha_parts/part/gygax_torso
	name = "\improper tors Gygax"
	desc = "Tors Gygaxa. Mieści jednostkę zasilania, rdzeń obliczeniowy i systemy podtrzymywania życia."
	icon_state = "gygax_harness"

/obj/item/mecha_parts/part/gygax_head
	name = "\improper głowa Gygax"
	desc = "Głowa Gygaxa. Mieści zaawansowane czujniki obserwacyjne i celownicze."
	icon_state = "gygax_head"

/obj/item/mecha_parts/part/gygax_left_arm
	name = "\improper lewe ramię Gygax"
	desc = "Lewe ramię Gygaxa. Gniazda danych i zasilania pasują do większości narzędzi i broni egzoszkieletów."
	icon_state = "gygax_l_arm"

/obj/item/mecha_parts/part/gygax_right_arm
	name = "\improper prawe ramię Gygax"
	desc = "Prawe ramię Gygaxa. Gniazda danych i zasilania pasują do większości narzędzi i broni egzoszkieletów."
	icon_state = "gygax_r_arm"

/obj/item/mecha_parts/part/gygax_left_leg
	name = "\improper lewa noga Gygax"
	desc = "Lewa noga Gygaxa. Zbudowana z zaawansowanych serwomechanizmów i siłowników, które pozwalają na szybszy ruch."
	icon_state = "gygax_l_leg"

/obj/item/mecha_parts/part/gygax_right_leg
	name = "\improper prawa noga Gygax"
	desc = "Prawa noga Gygaxa. Zbudowana z zaawansowanych serwomechanizmów i siłowników, które pozwalają na szybszy ruch."
	icon_state = "gygax_r_leg"

/obj/item/mecha_parts/part/gygax_armor
	gender = PLURAL
	name = "\improper płyty pancerza Gygax"
	desc = "Zestaw płyt pancerza dla Gygaxa. Lekka konstrukcja skutecznie odbija obrażenia."
	icon_state = "gygax_armor"


//////////// Durand

/obj/item/mecha_parts/chassis/durand
	name = "\improper rama Durand"
	construct_type = /datum/component/construction/unordered/mecha_chassis/durand

/obj/item/mecha_parts/part/durand_torso
	name = "\improper tors Durand"
	desc = "Tors Duranda. W wytrzymałej ochronnej ramie mieści jednostkę zasilania, rdzeń obliczeniowy i systemy podtrzymywania życia."
	icon_state = "durand_harness"

/obj/item/mecha_parts/part/durand_head
	name = "\improper głowa Durand"
	desc = "Głowa Duranda. Mieści zaawansowane czujniki obserwacyjne i celownicze."
	icon_state = "durand_head"

/obj/item/mecha_parts/part/durand_left_arm
	name = "\improper lewe ramię Durand"
	desc = "Lewe ramię Duranda. Gniazda danych i zasilania pasują do większości narzędzi i broni egzoszkieletów. Do tego potrafi porządnie przywalić."
	icon_state = "durand_l_arm"

/obj/item/mecha_parts/part/durand_right_arm
	name = "\improper prawe ramię Durand"
	desc = "Prawe ramię Duranda. Gniazda danych i zasilania pasują do większości narzędzi i broni egzoszkieletów. Do tego potrafi porządnie przywalić."
	icon_state = "durand_r_arm"

/obj/item/mecha_parts/part/durand_left_leg
	name = "\improper lewa noga Durand"
	desc = "Lewa noga Duranda. Wyjątkowo solidna, by unieść ciężar Duranda i sprostać jego potrzebom obronnym."
	icon_state = "durand_l_leg"

/obj/item/mecha_parts/part/durand_right_leg
	name = "\improper prawa noga Durand"
	desc = "Prawa noga Duranda. Wyjątkowo solidna, by unieść ciężar Duranda i sprostać jego potrzebom obronnym."
	icon_state = "durand_r_leg"

/obj/item/mecha_parts/part/durand_armor
	gender = PLURAL
	name = "\improper płyty pancerza Durand"
	desc = "Zestaw płyt pancerza dla Duranda. Ciężka konstrukcja wytrzymuje niewiarygodnie silne uderzenia."
	icon_state = "durand_armor"

////////// Firefighter

/obj/item/mecha_parts/chassis/firefighter
	name = "\improper rama Firefighter"
	construct_type = /datum/component/construction/unordered/mecha_chassis/firefighter


////////// HONK

/obj/item/mecha_parts/chassis/honker
	name = "\improper rama H.O.N.K"
	construct_type = /datum/component/construction/unordered/mecha_chassis/honker

/obj/item/mecha_parts/part/honker_torso
	name = "\improper tors H.O.N.K"
	desc = "Tors H.O.N.K. Mieści jednostkę chichotu, rdzeń z bananium i systemy podtrzymywania honkania."
	icon_state = "honker_harness"

/obj/item/mecha_parts/part/honker_head
	name = "\improper głowa H.O.N.K"
	desc = "Głowa H.O.N.K. Chyba brakuje jej płyty twarzowej."
	icon_state = "honker_head"

/obj/item/mecha_parts/part/honker_left_arm
	name = "\improper lewe ramię H.O.N.K"
	desc = "Lewe ramię H.O.N.K. Ma unikalne gniazda na dziwaczną broń projektowaną przez klownich naukowców."
	icon_state = "honker_l_arm"

/obj/item/mecha_parts/part/honker_right_arm
	name = "\improper prawe ramię H.O.N.K"
	desc = "Prawe ramię H.O.N.K. Ma unikalne gniazda na dziwaczną broń projektowaną przez klownich naukowców."
	icon_state = "honker_r_arm"

/obj/item/mecha_parts/part/honker_left_leg
	name = "\improper lewa noga H.O.N.K"
	desc = "Lewa noga H.O.N.K. Stopa wygląda na dokładnie tak dużą, by zmieścić but klauna."
	icon_state = "honker_l_leg"

/obj/item/mecha_parts/part/honker_right_leg
	name = "\improper prawa noga H.O.N.K"
	desc = "Prawa noga H.O.N.K. Stopa wygląda na dokładnie tak dużą, by zmieścić but klauna."
	icon_state = "honker_r_leg"


////////// Phazon

/obj/item/mecha_parts/chassis/phazon
	name = "\improper rama Phazon"
	construct_type = /datum/component/construction/unordered/mecha_chassis/phazon

/obj/item/mecha_parts/part/phazon_torso
	name="\improper tors Phazon"
	desc="Tors Phazona. Pośrodku znajduje się gniazdo na rdzeń bluespace, który zasila unikalne napędy fazowe egzoszkieletu."
	icon_state = "phazon_harness"

/obj/item/mecha_parts/part/phazon_head
	name="\improper głowa Phazon"
	desc="Głowa Phazona. Czujniki są starannie skalibrowane, by zapewniać obraz i dane nawet podczas przenikania egzoszkieletu."
	icon_state = "phazon_head"

/obj/item/mecha_parts/part/phazon_left_arm
	name="\improper lewe ramię Phazon"
	desc="Lewe ramię Phazona. Pod płytami pancerza kryje się kilka zestawów mikronarzędzi, które można dopasować do sytuacji."
	icon_state = "phazon_l_arm"

/obj/item/mecha_parts/part/phazon_right_arm
	name="\improper prawe ramię Phazon"
	desc="Prawe ramię Phazona. Pod płytami pancerza kryje się kilka zestawów mikronarzędzi, które można dopasować do sytuacji."
	icon_state = "phazon_r_arm"

/obj/item/mecha_parts/part/phazon_left_leg
	name="\improper lewa noga Phazon"
	desc="Lewa noga Phazona. Mieści unikalne napędy fazowe, które po włączeniu pozwalają egzoszkieletowi przenikać przez litą materię."
	icon_state = "phazon_l_leg"

/obj/item/mecha_parts/part/phazon_right_leg
	name="\improper prawa noga Phazon"
	desc="Prawa noga Phazona. Mieści unikalne napędy fazowe, które po włączeniu pozwalają egzoszkieletowi przenikać przez litą materię."
	icon_state = "phazon_r_leg"

/obj/item/mecha_parts/part/phazon_armor
	name="\improper pancerz Phazon"
	desc="Płyty pancerza Phazona. Są przekładane warstwami plazmy, które chronią pilota przed obciążeniem przenikania, i mają niezwykłe właściwości."
	icon_state = "phazon_armor"


///////// Circuitboards

/obj/item/circuitboard/mecha
	name = "płytka egzoszkieletu"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 7

/obj/item/circuitboard/mecha/ripley/peripherals
	name = "moduł sterowania peryferiami Ripley (płytka egzoszkieletu)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/ripley/main
	name = "centralny moduł sterowania Ripley (płytka egzoszkieletu)"
	icon_state = "mainboard"


/obj/item/circuitboard/mecha/gygax/peripherals
	name = "moduł sterowania peryferiami Gygax (płytka egzoszkieletu)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/gygax/targeting
	name = "moduł sterowania uzbrojeniem i celowaniem Gygax (płytka egzoszkieletu)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/gygax/main
	name = "centralny moduł sterowania Gygax (płytka egzoszkieletu)"
	icon_state = "mainboard"

/obj/item/circuitboard/mecha/durand/peripherals
	name = "moduł sterowania peryferiami Durand (płytka egzoszkieletu)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/durand/targeting
	name = "moduł sterowania uzbrojeniem i celowaniem Durand (płytka egzoszkieletu)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/durand/main
	name = "centralny moduł sterowania Durand (płytka egzoszkieletu)"
	icon_state = "mainboard"

/obj/item/circuitboard/mecha/honker/peripherals
	name = "moduł sterowania peryferiami H.O.N.K (płytka egzoszkieletu)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/honker/targeting
	name = "moduł sterowania uzbrojeniem i celowaniem H.O.N.K (płytka egzoszkieletu)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/honker/main
	name = "centralny moduł sterowania H.O.N.K (płytka egzoszkieletu)"
	icon_state = "mainboard"

/obj/item/circuitboard/mecha/odysseus/peripherals
	name = "moduł sterowania peryferiami Odysseus (płytka egzoszkieletu)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/odysseus/main
	name = "centralny moduł sterowania Odysseus (płytka egzoszkieletu)"
	icon_state = "mainboard"

/obj/item/circuitboard/mecha/phazon/peripherals
	name = "moduł sterowania peryferiami Phazon (płytka egzoszkieletu)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/phazon/targeting
	name = "moduł sterowania uzbrojeniem i celowaniem Phazon (płytka egzoszkieletu)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/phazon/main
	name = "centralny moduł sterowania Phazon (płytka egzoszkieletu)"
