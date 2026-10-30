/obj/item/picket_sign
	icon_state = "picket"
	name = "pusta tabliczka protestacyjna"
	desc = "Nic na niej nie ma."
	force = 5
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("grzmoci","trzepie")
	resistance_flags = FLAMMABLE
	

	var/label = ""
	var/last_wave = 0

/obj/item/picket_sign/cyborg
	name = "metalowa nanotabliczka"
	desc = "Zaawansowana tabliczka protestacyjna używana przez syntetyków, która dowolnie przeprogramowuje swoją powierzchnię. Pewnie boli też, kiedy ktoś cię nią uderzy."
	force = 13
	resistance_flags = NONE
	actions_types = list(/datum/action/item_action/nano_picket_sign)

/obj/item/picket_sign/proc/retext(mob/user)
	if(!user.is_literate())
		to_chat(user, "<span class='notice'>Bazgrzesz nieczytelnie na [src]!</span>")
		return
	var/txt = stripped_input(user, "Co chcesz napisać na tabliczce?", "Napis na tabliczce", null , 30)
	if(txt && user.canUseTopic(src, BE_CLOSE))
		label = txt
		name = "tabliczka: [label]"
		desc =	"Napis: [label]"

/obj/item/picket_sign/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/pen) || istype(W, /obj/item/toy/crayon))
		retext(user)
	else
		return ..()

/obj/item/picket_sign/attack_self(mob/living/carbon/human/user)
	if( last_wave + 20 < world.time )
		last_wave = world.time
		if(label)
			user.visible_message("<span class='warning'>[user] wymachuje tabliczką z napisem \"[label]\".</span>")
		else
			user.visible_message("<span class='warning'>[user] wymachuje pustą tabliczką.</span>")
		user.changeNext_move(CLICK_CD_MELEE)

/datum/crafting_recipe/picket_sign
	name = "Tabliczka protestacyjna"
	result = /obj/item/picket_sign
	reqs = list(/obj/item/stack/rods = 1,
				/obj/item/stack/sheet/cardboard = 2)
	time = 80
	category = CAT_MISC
