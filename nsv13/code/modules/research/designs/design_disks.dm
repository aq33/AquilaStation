/obj/item/disk/design_disk/deck_gun_autoelevator
	name = "projekt autopodnośnika działa artylerii okrętowej"
	desc = "Schematy szybciej ładowanego działa artylerii okrętowej."
	icon_state = "datadisk2"
	max_blueprints = 1

/obj/item/disk/design_disk/deck_gun_autoelevator/Initialize(mapload)
	. = ..()
	blueprints[1] = new /datum/design/board/deck_gun_autoelevator

/obj/item/disk/design_disk/deck_gun_autorepair
	name = "projekt autonaprawy działa artylerii okrętowej"
	desc = "Schematy samonaprawiającego się działa artylerii okrętowej."
	icon_state = "datadisk0"
	max_blueprints = 1

/obj/item/disk/design_disk/deck_gun_autorepair/Initialize(mapload)
	. = ..()
	blueprints[1] = new /datum/design/board/deck_gun_autorepair
