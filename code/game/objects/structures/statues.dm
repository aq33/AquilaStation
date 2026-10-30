/obj/structure/statue
	name = "posąg"
	desc = "Zaślepka. Nakrzycz na Qwerty'ego, jeśli JAKIMŚ CUDEM to widzisz."
	icon = 'icons/obj/statue.dmi'
	icon_state = ""
	density = TRUE
	anchored = FALSE
	max_integrity = 100
	var/oreAmount = 5
	var/material_drop_type = /obj/item/stack/sheet/iron
	CanAtmosPass = ATMOS_PASS_DENSITY

/obj/structure/statue/attackby(obj/item/W, mob/living/user, params)
	add_fingerprint(user)
	user.changeNext_move(CLICK_CD_MELEE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(default_unfasten_wrench(user, W))
			return
		if(W.tool_behaviour == TOOL_WELDER)
			if(!W.tool_start_check(user, amount=0))
				return FALSE

			user.visible_message("[user] rozcina [name].", \
								"<span class='notice'>Rozcinasz [name]...</span>")
			if(W.use_tool(src, user, 40, volume=50))
				user.visible_message("[user] rozcina [name].", \
									"<span class='notice'>Rozcinasz [name]!</span>")
				deconstruct(TRUE)
			return
	return ..()

/obj/structure/statue/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)
	user.visible_message("[user] ściera trochę kurzu z powierzchni [name].", \
						 "<span class='notice'>Ścierasz trochę kurzu z powierzchni [name].</span>")

/obj/structure/statue/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(material_drop_type)
			var/drop_amt = oreAmount
			if(!disassembled)
				drop_amt -= 2
			if(drop_amt > 0)
				new material_drop_type(get_turf(src), drop_amt)
	qdel(src)

//////////////////////////////////////STATUES/////////////////////////////////////////////////////////////
////////////////////////uranium///////////////////////////////////

/obj/structure/statue/uranium
	max_integrity = 300
	light_range = 2
	material_drop_type = /obj/item/stack/sheet/mineral/uranium
	var/last_event = 0
	var/active = null

/obj/structure/statue/uranium/nuke
	name = "posąg bomby atomowej"
	desc = "Okazały posąg bomby atomowej. Ma obrzydliwie zielony kolor."
	icon_state = "nuke"

/obj/structure/statue/uranium/eng
	name = "posąg inżyniera"
	desc = "Ten posąg ma obrzydliwie zielony kolor."
	icon_state = "eng"

/obj/structure/statue/uranium/attackby(obj/item/W, mob/user, params)
	radiate()
	return ..()

/obj/structure/statue/uranium/Bumped(atom/movable/AM)
	radiate()
	..()

/obj/structure/statue/uranium/attack_hand(mob/user, list/modifiers)
	radiate()
	. = ..()

/obj/structure/statue/uranium/attack_paw(mob/user)
	radiate()
	. = ..()

/obj/structure/statue/uranium/proc/radiate()
	if(!active)
		if(world.time > last_event+15)
			active = 1
			radiation_pulse(src, 30)
			last_event = world.time
			active = null
			return
	return

////////////////////////////plasma///////////////////////////////////////////////////////////////////////

/obj/structure/statue/plasma
	max_integrity = 200
	material_drop_type = /obj/item/stack/sheet/mineral/plasma
	desc = "Ten posąg jest, jak przystało, z plazmy."

/obj/structure/statue/plasma/scientist
	name = "posąg naukowca"
	icon_state = "sci"

/obj/structure/statue/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)


/obj/structure/statue/plasma/bullet_act(obj/item/projectile/Proj)
	var/burn = FALSE
	if(!(Proj.nodamage) && Proj.damage_type == BURN && !QDELETED(src))
		burn = TRUE
	if(burn)
		var/turf/T = get_turf(src)
		if(Proj.firer)
			message_admins("Plazmowy posąg podpalony przez [ADMIN_LOOKUPFLW(Proj.firer)] w [ADMIN_VERBOSEJMP(T)]")
			log_game("Plasma statue ignited by [key_name(Proj.firer)] in [AREACOORD(T)]")
		else
			message_admins("Plazmowy posąg podpalony przez [Proj]. Strzelec nieznany, w [ADMIN_VERBOSEJMP(T)]")
			log_game("Plasma statue ignited by [Proj] in [AREACOORD(T)]. No known firer.")
		PlasmaBurn(2500)
	. = ..()

/obj/structure/statue/plasma/attackby(obj/item/W, mob/user, params)
	if(W.is_hot() > 300 && !QDELETED(src))//If the temperature of the object is over 300, then ignite
		var/turf/T = get_turf(src)
		message_admins("Plazmowy posąg podpalony przez [ADMIN_LOOKUPFLW(user)] w [ADMIN_VERBOSEJMP(T)]")
		log_game("Plasma statue ignited by [key_name(user)] in [AREACOORD(T)]")
		ignite(W.is_hot())
	else
		return ..()

/obj/structure/statue/plasma/proc/PlasmaBurn(exposed_temperature)
	if(QDELETED(src))
		return
	atmos_spawn_air("plasma=[oreAmount*10];TEMP=[exposed_temperature]")
	deconstruct(FALSE)

/obj/structure/statue/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

//////////////////////gold///////////////////////////////////////

/obj/structure/statue/gold
	max_integrity = 300
	material_drop_type = /obj/item/stack/sheet/mineral/gold
	desc = "Niezwykle cenny posąg ze złota."

/obj/structure/statue/gold/hos
	name = "posąg Komendanta"
	icon_state = "hos"

/obj/structure/statue/gold/hop
	name = "posąg Starszego Oficera"
	icon_state = "hop"

/obj/structure/statue/gold/cmo
	name = "posąg Ordynatora"
	icon_state = "cmo"

/obj/structure/statue/gold/ce
	name = "posąg Głównego Inżyniera"
	icon_state = "ce"

/obj/structure/statue/gold/rd
	name = "posąg Dyrektora Naukowego"
	icon_state = "rd"

//////////////////////////silver///////////////////////////////////////

/obj/structure/statue/silver
	max_integrity = 300
	material_drop_type = /obj/item/stack/sheet/mineral/silver
	desc = "Cenny posąg ze srebra."

/obj/structure/statue/silver/md
	name = "posąg lekarza"
	icon_state = "md"

/obj/structure/statue/silver/janitor
	name = "posąg woźnego"
	icon_state = "jani"

/obj/structure/statue/silver/sec
	name = "posąg policjanta"
	icon_state = "sec"

/obj/structure/statue/silver/secborg
	name = "posąg cyborga ochrony"
	icon_state = "secborg"

/obj/structure/statue/silver/medborg
	name = "posąg cyborga medycznego"
	icon_state = "medborg"

/////////////////////////diamond/////////////////////////////////////////

/obj/structure/statue/diamond
	max_integrity = 1000
	material_drop_type = /obj/item/stack/sheet/mineral/diamond
	desc = "Bardzo drogi diamentowy posąg."

/obj/structure/statue/diamond/captain
	name = "posąg TEGO Kapitana."
	icon_state = "cap"

/obj/structure/statue/diamond/ai1
	name = "posąg hologramu SI."
	icon_state = "ai1"

/obj/structure/statue/diamond/ai2
	name = "posąg rdzenia SI."
	icon_state = "ai2"

////////////////////////bananium///////////////////////////////////////

/obj/structure/statue/bananium
	max_integrity = 300
	material_drop_type = /obj/item/stack/sheet/mineral/bananium
	desc = "Posąg z bananium z małym grawerunkiem: „HOOOOOOONK”."
	var/spam_flag = FALSE

/obj/structure/statue/bananium/clown
	name = "posąg klauna"
	icon_state = "clown"

/obj/structure/statue/bananium/Bumped(atom/movable/AM)
	honk()
	..()

/obj/structure/statue/bananium/attackby(obj/item/W, mob/user, params)
	honk()
	return ..()

/obj/structure/statue/bananium/attack_hand(mob/user, list/modifiers)
	honk()
	. = ..()

/obj/structure/statue/bananium/attack_paw(mob/user)
	honk()
	..()

/obj/structure/statue/bananium/proc/honk()
	if(!spam_flag)
		spam_flag = TRUE
		playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)
		addtimer(VARSET_CALLBACK(src, spam_flag, FALSE), 2 SECONDS)

/////////////////////sandstone/////////////////////////////////////////

/obj/structure/statue/sandstone
	max_integrity = 50
	material_drop_type = /obj/item/stack/sheet/mineral/sandstone

/obj/structure/statue/sandstone/assistant
	name = "posąg asystenta"
	desc = "Tani posąg z piaskowca dla szarego pracownika."
	icon_state = "assist"


/obj/structure/statue/sandstone/venus //call me when we add marble i guess
	name = "posąg czystej dziewicy"
	desc = "Starożytny marmurowy posąg. Postać ma warkocz do samej ziemi i dzierży skrzynkę z narzędziami. Na Jowisza, to bez wątpienia najpiękniejsze przedstawienie kobiety, jakie w życiu widziałeś. Artysta musiał być prawdziwym mistrzem swojego fachu. Szkoda tylko tej złamanej ręki."
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "venus"

/////////////////////snow/////////////////////////////////////////

/obj/structure/statue/snow
	max_integrity = 50
	material_drop_type = /obj/item/stack/sheet/mineral/snow

/obj/structure/statue/snow/snowman
	name = "bałwan"
	desc = "Kilka kul śniegu złożonych w bałwana."
	icon_state = "snowman"

/obj/structure/statue/snow/snowlegion
    name = "śnieżny legion"
    desc = "Wygląda na to, że ten dziwny dzieciak z pluszowym tygrysem znów tu był."
    icon_state = "snowlegion"

//////////////////////////copper///////////////////////////////////////

/obj/structure/statue/copper
	max_integrity = 350
	material_drop_type = /obj/item/stack/sheet/mineral/copper
	desc = "Posąg z miedzi."

/obj/structure/statue/copper/dimas
	name = "posąg Kwatermistrza"
	desc = "Posąg legendarnego Kwatermistrza, władcy Cargonii, krainy kradzionych rzeczy. Czujesz potrzebę, by się przed nim pokłonić."
	max_integrity = 400
	icon_state = "dimas"
	oreAmount = 10 //dimas b dense

////////////////////cheese/////////////////////////////////////////

/obj/structure/statue/cheese
	max_integrity = 100
	material_drop_type = /obj/item/stack/sheet/cheese

/obj/structure/statue/cheese/cheesus
	name = "posąg Serusa"
	desc = "Ser mistrzowsko wyrzeźbiony na podobieństwo naszego potężnego pana i zbawiciela."
	icon_state = "cheesus1"

/obj/structure/statue/cheese/cheesus/attackby(obj/item/W, mob/user, params)
	if(obj_integrity <= 20)
		icon_state = "cheesus4"
		return ..()
	if(obj_integrity <= 40)
		icon_state = "cheesus3"
		return ..()
	if(obj_integrity <= 60)
		icon_state = "cheesus2"
		return ..()
	return ..()
