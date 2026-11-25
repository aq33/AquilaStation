// AQUILA - resprite dowództwa: Kapitan, Starszy Oficer i Oficerowie Pokładowi.
// Sprite'y w aquila/icons/dowodztwo/ mają te same nazwy stanów co oryginały, więc podmieniamy tylko pliki ikon.
// Podtypy bez nowego sprite'a wracają do starych plików.

// ---- Mundury (stan na postaci = icon_state, podwinięty z "_d") ----
/obj/item/clothing/under/rank/captain
	icon = 'aquila/icons/dowodztwo/uniform_obj.dmi'
	worn_icon = 'aquila/icons/dowodztwo/uniform_mob.dmi'

/obj/item/clothing/under/rank/captain/skirt
	icon = 'icons/obj/clothing/uniforms.dmi'
	worn_icon = null

/obj/item/clothing/under/rank/captain/parade
	icon = 'icons/obj/clothing/uniforms.dmi'
	worn_icon = null

/obj/item/clothing/under/rank/captain/suit
	can_adjust = TRUE

/obj/item/clothing/under/rank/civilian/head_of_personnel
	icon = 'aquila/icons/dowodztwo/uniform_obj.dmi'
	worn_icon = 'aquila/icons/dowodztwo/uniform_mob.dmi'
	can_adjust = TRUE
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/civilian/head_of_personnel/skirt
	icon = 'icons/obj/clothing/uniforms.dmi'
	worn_icon = null
	can_adjust = FALSE
	sensor_mode = NO_SENSORS
	random_sensor = TRUE

/obj/item/clothing/under/rank/civilian/head_of_personnel/alt
	icon = 'icons/obj/clothing/uniforms.dmi'
	worn_icon = null
	sensor_mode = NO_SENSORS
	random_sensor = TRUE

/obj/item/clothing/under/ship/officer
	icon = 'aquila/icons/dowodztwo/uniform_obj.dmi'
	worn_icon = 'aquila/icons/dowodztwo/uniform_mob.dmi'

/obj/item/clothing/under/ship/officer/admiral
	icon = 'nsv13/icons/obj/clothing/uniforms.dmi'
	worn_icon = 'nsv13/icons/mob/uniform.dmi'

// ---- Odzież wierzchnia ----
/obj/item/clothing/suit/captunic
	name = "galowa kurtka kapitana"
	icon = 'aquila/icons/dowodztwo/suit_obj.dmi'
	worn_icon = 'aquila/icons/dowodztwo/suit_mob.dmi'

/obj/item/clothing/suit/armor/vest/capcarapace
	icon = 'aquila/icons/dowodztwo/suit_obj.dmi'
	worn_icon = 'aquila/icons/dowodztwo/suit_mob.dmi'

/obj/item/clothing/suit/armor/vest/capcarapace/alt
	name = "fikuśna kurtka kapitana"

/obj/item/clothing/suit/armor/vest/capcarapace/jacket
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = null

/obj/item/clothing/suit/armor/vest/capcarapace/syndicate
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = null

/obj/item/clothing/suit/space/hardsuit/swat/captain
	icon = 'aquila/icons/dowodztwo/suit_obj.dmi'
	worn_icon = 'aquila/icons/dowodztwo/suit_mob.dmi'

/obj/item/clothing/suit/ship/officer/xo
	name = "kurtka galowa Starszego Oficera"
	icon = 'aquila/icons/dowodztwo/suit_obj.dmi'
	worn_icon = 'aquila/icons/dowodztwo/suit_mob.dmi'
	icon_state = "xo_jacket"

// Kurtki zimowe z zapięciem na Alt+klik (wintercoat_zip.dm): "[icon_state]" zapięta, "_t" rozpięta, opuszczony kaptur jako nakładka
/obj/item/clothing/suit/hooded/wintercoat/captain
	icon = 'aquila/icons/dowodztwo/suit_obj.dmi'
	worn_icon = 'aquila/icons/dowodztwo/suit_mob.dmi'
	hood_down_state = "winterhood_captain_down"
	hood_down_icon = 'aquila/icons/dowodztwo/head_mob.dmi'

/obj/item/clothing/head/hooded/winterhood/captain
	icon = 'aquila/icons/dowodztwo/head_obj.dmi'
	worn_icon = 'aquila/icons/dowodztwo/head_mob.dmi'

/obj/item/clothing/suit/hooded/wintercoat/xo
	name = "kurtka zimowa Starszego Oficera"
	icon = 'aquila/icons/dowodztwo/suit_obj.dmi'
	worn_icon = 'aquila/icons/dowodztwo/suit_mob.dmi'
	icon_state = "coatxo"
	hood_down_state = "winterhood_captain_down"
	hood_down_icon = 'aquila/icons/dowodztwo/head_mob.dmi'
	hoodtype = /obj/item/clothing/head/hooded/winterhood/captain

/obj/item/clothing/suit/hooded/wintercoat/bridge
	name = "kurtka zimowa Oficera Pokładowego"
	icon = 'aquila/icons/dowodztwo/suit_obj.dmi'
	worn_icon = 'aquila/icons/dowodztwo/suit_mob.dmi'
	icon_state = "coatbridge"
	hood_down_state = "winterhood_bridge_down"
	hood_down_icon = 'aquila/icons/dowodztwo/head_mob.dmi'
	hoodtype = /obj/item/clothing/head/hooded/winterhood/bridge

/obj/item/clothing/head/hooded/winterhood/bridge
	icon = 'aquila/icons/dowodztwo/head_obj.dmi'
	worn_icon = 'aquila/icons/dowodztwo/head_mob.dmi'
	icon_state = "winterhood_bridge"

// ---- Nakrycia głowy ----
/obj/item/clothing/head/caphat
	icon = 'aquila/icons/dowodztwo/head_obj.dmi'
	worn_icon = 'aquila/icons/dowodztwo/head_mob.dmi'

/obj/item/clothing/head/beret/captain
	icon = 'aquila/icons/dowodztwo/head_obj.dmi'
	worn_icon = 'aquila/icons/dowodztwo/head_mob.dmi'

/obj/item/clothing/head/beret/ship/captain
	icon = 'aquila/icons/dowodztwo/head_obj.dmi'
	worn_icon = 'aquila/icons/dowodztwo/head_mob.dmi'
	icon_state = "beret_captain"

/obj/item/clothing/head/beret/ship/xo
	icon = 'aquila/icons/dowodztwo/head_obj.dmi'
	worn_icon = 'aquila/icons/dowodztwo/head_mob.dmi'

/obj/item/clothing/head/hopcap
	icon = 'aquila/icons/dowodztwo/head_obj.dmi'
	worn_icon = 'aquila/icons/dowodztwo/head_mob.dmi'

/obj/item/clothing/head/helmet/space/hardsuit/swat/captain
	icon = 'aquila/icons/dowodztwo/head_obj.dmi'
	worn_icon = 'aquila/icons/dowodztwo/head_mob.dmi'

/obj/item/clothing/head/beret/durathread/bridge
	name = "beret Oficera Pokładowego"
	icon = 'aquila/icons/dowodztwo/head_obj.dmi'
	worn_icon = 'aquila/icons/dowodztwo/head_mob.dmi'
	icon_state = "bridge_beret"

/obj/item/clothing/head/caphat/officer
	name = "oficerska czapka kapitana"
	icon_state = "captain_officer"

// ---- Rękawice, peleryny, torba ----
/obj/item/clothing/gloves/color/captain
	icon = 'aquila/icons/dowodztwo/hands_obj.dmi'
	worn_icon = 'aquila/icons/dowodztwo/hands_mob.dmi'

// Peleryna nad plecakiem i torbą (BACK_LAYER), ale pod włosami (HAIR_LAYER), żeby plecak nie wystawał spod peleryny
/obj/item/clothing/neck/cloak
	alternate_worn_layer = BACK_LAYER - 0.5

/obj/item/clothing/neck/cloak/cap
	icon = 'aquila/icons/dowodztwo/neck_obj.dmi'
	worn_icon = 'aquila/icons/dowodztwo/neck_mob.dmi'

/obj/item/clothing/neck/cloak/hop
	icon = 'aquila/icons/dowodztwo/neck_obj.dmi'
	worn_icon = 'aquila/icons/dowodztwo/neck_mob.dmi'

/obj/item/clothing/neck/cloak/cmo
	icon = 'aquila/icons/dowodztwo/neck_obj.dmi'
	worn_icon = 'aquila/icons/dowodztwo/neck_mob.dmi'

/obj/item/storage/backpack/satchel/cap
	icon = 'aquila/icons/dowodztwo/back_obj.dmi'
	worn_icon = 'aquila/icons/dowodztwo/back_mob.dmi'

// ---- Karty ID (na postaci dalej aquila/icons/mob/clothing/id.dmi po icon_state) ----
/obj/item/card/id/job/captain
	icon = 'aquila/icons/dowodztwo/karty.dmi'

/obj/item/card/id/job/head_of_personnel
	icon = 'aquila/icons/dowodztwo/karty.dmi'

/obj/item/card/id/job/bridge_staff
	icon = 'aquila/icons/dowodztwo/karty.dmi'

/obj/item/card/id/captains_spare
	icon = 'aquila/icons/dowodztwo/karty.dmi'

// ---- PDA (ekran jest narysowany na sprite'cie, nakładki ekranu ze starego pliku tu nie pasują) ----
/obj/item/modular_computer/tablet/pda/heads/captain
	icon = 'aquila/icons/dowodztwo/pda.dmi'

/obj/item/modular_computer/tablet/pda/heads/head_of_personnel
	icon = 'aquila/icons/dowodztwo/pda.dmi'

// ---- Szafki ----
/obj/structure/closet/secure_closet/captains
	icon = 'aquila/icons/dowodztwo/szafki.dmi'

/obj/structure/closet/secure_closet/hop
	icon = 'aquila/icons/dowodztwo/szafki.dmi'

/obj/structure/closet/secure_closet/bridge
	icon = 'aquila/icons/dowodztwo/szafki.dmi'

/obj/structure/closet/secure_closet/bridge/PopulateContents()
	..()
	for(var/obj/item/clothing/head/beret/durathread/beret in src)
		if(beret.type == /obj/item/clothing/head/beret/durathread)
			qdel(beret)
	new /obj/item/clothing/head/beret/durathread/bridge(src)
	new /obj/item/clothing/suit/hooded/wintercoat/bridge(src)

// ---- Pudełka kompresyjne (pełne nadpisania, wpis w LEGACY_OVERRIDES.md) ----
// Buty wojskowe i kurtki mają kieszenie (storage), a takich rzeczy nie wkładamy do pudełka kompresyjnego
// (komentarz przy /obj/item/storage/box/suitbox), więc leżą w szafce obok pudełka.
/obj/item/storage/box/suitbox/cap/PopulateContents()
	new /obj/item/clothing/under/rank/captain(src)
	new /obj/item/clothing/under/rank/captain/suit(src)
	new /obj/item/clothing/head/caphat(src)
	new /obj/item/clothing/head/caphat/parade(src)
	new /obj/item/clothing/head/caphat/officer(src)
	new /obj/item/clothing/head/beret/captain(src)

/obj/item/storage/box/suitbox/hop/PopulateContents()
	new /obj/item/clothing/under/rank/civilian/head_of_personnel(src)
	new /obj/item/clothing/head/hopcap(src)
	new /obj/item/clothing/head/beret/ship/xo(src)

// Mundur galowy Komendanta (head_of_security/parade) nie ma własnej definicji, był drugim zwykłym mundurem
/obj/item/storage/box/suitbox/hos/PopulateContents()
	new /obj/item/clothing/under/rank/security/head_of_security(src)
	new /obj/item/clothing/under/rank/security/head_of_security/alt(src)
	new /obj/item/clothing/head/HoS(src)
	new /obj/item/clothing/head/HoS/beret(src)
	new /obj/item/clothing/head/beret/sec/navyhos(src)

/obj/structure/closet/secure_closet/captains/PopulateContents()
	..()
	new /obj/item/clothing/shoes/jackboots(src)

/obj/structure/closet/secure_closet/hop/PopulateContents()
	..()
	new /obj/item/clothing/shoes/jackboots(src)
	new /obj/item/clothing/suit/ship/officer/xo(src)
	new /obj/item/clothing/suit/hooded/wintercoat/xo(src)

// ---- Stroje startowe ----
/datum/outfit/job/captain
	uniform = /obj/item/clothing/under/rank/captain
	suit = /obj/item/clothing/suit/armor/vest/capcarapace
	head = /obj/item/clothing/head/caphat

/datum/outfit/job/head_of_personnel
	uniform = /obj/item/clothing/under/rank/civilian/head_of_personnel
	suit = /obj/item/clothing/suit/ship/officer/xo

/datum/outfit/job/bridge
	head = /obj/item/clothing/head/beret/durathread/bridge
