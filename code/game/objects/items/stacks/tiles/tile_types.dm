/obj/item/stack/tile
	name = "zepsuta płytka"
	singular_name = "zepsuta płytka"
	desc = "Zepsuta płytka. To nie powinno istnieć."
	lefthand_file = 'icons/mob/inhands/misc/tiles_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/tiles_righthand.dmi'
	icon = 'icons/obj/tiles.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	force = 1
	throwforce = 1
	throw_speed = 3
	throw_range = 7
	max_amount = 60
	novariants = TRUE
	/// What type of turf does this tile produce.
	var/turf_type = null
	/// Determines certain welder interactions.
	var/mineralType = null
	/// Cached associative lazy list to hold the radial options for tile reskinning. See tile_reskinning.dm for more information. Pattern: list[type] -> image
	var/list/tile_reskin_types

/obj/item/stack/tile/Initialize(mapload, new_amount, merge = TRUE, mob/user = null)
	. = ..()
	pixel_x = rand(-3, 3)
	pixel_y = rand(-3, 3) //randomize a little
	if(tile_reskin_types)
		tile_reskin_types = tile_reskin_list(tile_reskin_types)


/obj/item/stack/tile/attackby(obj/item/W, mob/user, params)

	if (W.tool_behaviour == TOOL_WELDER)
		if(get_amount() < 4)
			to_chat(user, "<span class='warning'>Aby to zrobić, potrzebujesz co najmniej czterech płytek!</span>")
			return

		if(!mineralType)
			to_chat(user, "<span class='warning'>Nie możesz tego przekształcić!</span>")
			return

		if(W.use_tool(src, user, 0, volume=40))
			if(mineralType == "plasma")
				atmos_spawn_air("plasma=5;TEMP=1000")
				user.visible_message("<span class='warning'>[user.name] podpala płytki plazmowe!</span>", \
									"<span class='warning'>Podpalasz płytki plazmowe!</span>")
				qdel(src)
				return

			if (mineralType == "iron")
				var/obj/item/stack/sheet/iron/new_item = new(user.loc)
				user.visible_message("[user.name] przetapia [src] w żelazo za pomocą spawarki.", \
							 "<span class='notice'>Przetapiasz [src] w żelazo za pomocą spawarki.</span>", \
							 "<span class='italics'>Słyszysz spawanie.</span>")
				var/obj/item/stack/rods/R = src
				src = null
				var/replace = (user.get_inactive_held_item()==R)
				R.use(4)
				if (!R && replace)
					user.put_in_hands(new_item)
			if(mineralType == "durasteel") //NSV13 added durasteel
				var/obj/item/stack/sheet/durasteel/new_item = new(user.loc)
				user.visible_message("[user.name] przetapia [src] w durastal za pomocą spawarki.", \
							 "<span class='notice'>Przetapiasz [src] w durastal za pomocą spawarki.</span>", \
							 "<span class='italics'>Słyszysz spawanie.</span>")
				var/obj/item/stack/rods/R = src
				src = null
				var/replace = (user.get_inactive_held_item()==R)
				R.use(4)
				if (!R && replace)
					user.put_in_hands(new_item)
			else
				var/sheet_type = text2path("/obj/item/stack/sheet/mineral/[mineralType]")
				var/obj/item/stack/sheet/mineral/new_item = new sheet_type(user.loc)
				user.visible_message("[user.name] przetapia [src] w arkusz za pomocą spawarki.", \
							 "<span class='notice'>Przetapiasz [src] w arkusz za pomocą spawarki.</span>", \
							 "<span class='italics'>Słyszysz spawanie.</span>")
				var/obj/item/stack/rods/R = src
				src = null
				var/replace = (user.get_inactive_held_item()==R)
				R.use(4)
				if (!R && replace)
					user.put_in_hands(new_item)
	else
		return ..()

//Grass
/obj/item/stack/tile/grass
	name = "płytka trawy"
	singular_name = "płytka podłogowa z trawą"
	desc = "Kawałek trawy, jakiej używa się na kosmicznych polach golfowych."
	icon_state = "tile_grass"
	item_state = "tile-grass"
	turf_type = /turf/open/floor/grass
	resistance_flags = FLAMMABLE

/obj/item/stack/tile/grass/attackby(obj/item/W, mob/user, params)
	if((W.tool_behaviour == TOOL_SHOVEL) && params)
		to_chat(user, "<span class='notice'>Zaczynasz wykopywać [src].</span>")
		playsound(src, 'sound/effects/shovel_dig.ogg', 50, 1)
		if(do_after(user, 2 * get_amount(), target = src))
			new /obj/item/stack/ore/glass(get_turf(src), 2 * get_amount())
			user.visible_message("<span class='notice'>[user] wykopuje [src].</span>", "<span class='notice'>Wyrywasz [src] z korzeniami.</span>")
			playsound(src, 'sound/effects/shovel_dig.ogg', 50, 1)
			qdel(src)
	else
		return ..()

//Fairygrass
/obj/item/stack/tile/fairygrass
	name = "płytka trawy wróżek"
	singular_name = "płytka podłogowa z trawą wróżek"
	desc = "Kawałek dziwnej, świecącej niebieskiej trawy."
	icon_state = "tile_fairygrass"
	item_state = "tile-fairygrass"
	turf_type = /turf/open/floor/grass/fairy
	resistance_flags = FLAMMABLE
	color = "#33CCFF"

/obj/item/stack/tile/fairygrass/white
	name = "biała płytka trawy wróżek"
	singular_name = "biała płytka podłogowa z trawą wróżek"
	desc = "Kawałek dziwnej, świecącej białej trawy."
	turf_type = /turf/open/floor/grass/fairy/white
	color = "#FFFFFF"

/obj/item/stack/tile/fairygrass/red
	name = "czerwona płytka trawy wróżek"
	singular_name = "czerwona płytka podłogowa z trawą wróżek"
	desc = "Kawałek dziwnej, świecącej czerwonej trawy."
	turf_type = /turf/open/floor/grass/fairy/red
	color = "#FF3333"

/obj/item/stack/tile/fairygrass/yellow
	name = "żółta płytka trawy wróżek"
	singular_name = "żółta płytka podłogowa z trawą wróżek"
	desc = "Kawałek dziwnej, świecącej żółtej trawy."
	turf_type = /turf/open/floor/grass/fairy/yellow
	color = "#FFFF66"

/obj/item/stack/tile/fairygrass/green
	name = "zielona płytka trawy wróżek"
	singular_name = "zielona płytka podłogowa z trawą wróżek"
	desc = "Kawałek dziwnej, świecącej zielonej trawy."
	turf_type = /turf/open/floor/grass/fairy/green
	color = "#99FF99"

/obj/item/stack/tile/fairygrass/blue
	name = "niebieska płytka trawy wróżek"
	singular_name = "niebieska płytka podłogowa z trawą wróżek"
	desc = "Kawałek dziwnej, świecącej niebieskiej trawy."
	turf_type = /turf/open/floor/grass/fairy/blue

/obj/item/stack/tile/fairygrass/purple
	name = "fioletowa płytka trawy wróżek"
	singular_name = "fioletowa płytka podłogowa z trawą wróżek"
	desc = "Kawałek dziwnej, świecącej fioletowej trawy."
	turf_type = /turf/open/floor/grass/fairy/purple
	color = "#D966FF"

/obj/item/stack/tile/fairygrass/pink
	name = "różowa płytka trawy wróżek"
	singular_name = "różowa płytka podłogowa z trawą wróżek"
	desc = "Kawałek dziwnej, świecącej różowej trawy."
	turf_type = /turf/open/floor/grass/fairy/pink
	color = "#FFB3DA"

/obj/item/stack/tile/fairygrass/dark
	name = "ciemna płytka trawy wróżek"
	singular_name = "ciemna płytka podłogowa z trawą wróżek"
	desc = "Kawałek dziwnej trawy pochłaniającej światło."
	turf_type = /turf/open/floor/grass/fairy/dark
	color = "#410096"

//Wood
/obj/item/stack/tile/wood
	name = "drewniana płytka podłogowa"
	singular_name = "drewniana płytka podłogowa"
	desc = "Łatwa w montażu drewniana płytka podłogowa."
	icon_state = "tile-wood"
	item_state = "tile-wood"
	turf_type = /turf/open/floor/wood
	resistance_flags = FLAMMABLE

//Bamboo
/obj/item/stack/tile/bamboo
	name = "kawałki bambusowej maty"
	singular_name = "kawałek bambusowej maty"
	desc = "Kawałek bambusowej maty z ozdobnym obszyciem."
	icon_state = "tile-bamboo"
	item_state = "tile-bamboo"
	turf_type = /turf/open/floor/bamboo
	resistance_flags = FLAMMABLE

//Basalt
/obj/item/stack/tile/basalt
	name = "płytka bazaltowa"
	singular_name = "bazaltowa płytka podłogowa"
	desc = "Sztucznie wytworzona popielata gleba, stylizowana na wrogie środowisko."
	icon_state = "tile_basalt"
	item_state = "tile-basalt"
	turf_type = /turf/open/floor/grass/fakebasalt

//Carpets
/obj/item/stack/tile/carpet
	name = "wykładzina"
	singular_name = "płytka wykładziny"
	desc = "Kawałek wykładziny wielkości płytki podłogowej."
	icon_state = "tile-carpet"
	item_state = "tile-carpet"
	turf_type = /turf/open/floor/carpet
	resistance_flags = FLAMMABLE
	tableVariant = /obj/structure/table/wood/fancy

/obj/item/stack/tile/carpet/black
	name = "czarna wykładzina"
	icon_state = "tile-carpet-black"
	item_state = "tile-carpet-black"
	merge_type = /obj/item/stack/tile/carpet/black
	turf_type = /turf/open/floor/carpet/black
	tableVariant = /obj/structure/table/wood/fancy/black

/obj/item/stack/tile/carpet/blue
	name = "niebieska wykładzina"
	icon_state = "tile-carpet-blue"
	item_state = "tile-carpet-blue"
	merge_type = /obj/item/stack/tile/carpet/blue
	turf_type = /turf/open/floor/carpet/blue
	tableVariant = /obj/structure/table/wood/fancy/blue

/obj/item/stack/tile/carpet/blue/thirtytwo
	amount = 32

/obj/item/stack/tile/carpet/cyan
	name = "cyjanowa wykładzina"
	icon_state = "tile-carpet-cyan"
	item_state = "tile-carpet-cyan"
	merge_type = /obj/item/stack/tile/carpet/cyan
	turf_type = /turf/open/floor/carpet/cyan
	tableVariant = /obj/structure/table/wood/fancy/cyan

/obj/item/stack/tile/carpet/cyan/thirtytwo
	amount = 32

/obj/item/stack/tile/carpet/green
	name = "zielona wykładzina"
	icon_state = "tile-carpet-green"
	item_state = "tile-carpet-green"
	merge_type = /obj/item/stack/tile/carpet/green
	turf_type = /turf/open/floor/carpet/green
	tableVariant = /obj/structure/table/wood/fancy/green

/obj/item/stack/tile/carpet/orange
	name = "pomarańczowa wykładzina"
	icon_state = "tile-carpet-orange"
	item_state = "tile-carpet-orange"
	merge_type = /obj/item/stack/tile/carpet/orange
	turf_type = /turf/open/floor/carpet/orange
	tableVariant = /obj/structure/table/wood/fancy/orange

/obj/item/stack/tile/carpet/purple
	name = "fioletowa wykładzina"
	icon_state = "tile-carpet-purple"
	item_state = "tile-carpet-purple"
	merge_type = /obj/item/stack/tile/carpet/purple
	turf_type = /turf/open/floor/carpet/purple
	tableVariant = /obj/structure/table/wood/fancy/purple

/obj/item/stack/tile/carpet/red
	name = "czerwona wykładzina"
	icon_state = "tile-carpet-red"
	item_state = "tile-carpet-red"
	merge_type = /obj/item/stack/tile/carpet/red
	turf_type = /turf/open/floor/carpet/red
	tableVariant = /obj/structure/table/wood/fancy/red

/obj/item/stack/tile/carpet/royalblack
	name = "królewska czarna wykładzina"
	icon_state = "tile-carpet-royalblack"
	item_state = "tile-carpet-royalblack"
	merge_type = /obj/item/stack/tile/carpet/royalblack
	turf_type = /turf/open/floor/carpet/royalblack
	tableVariant = /obj/structure/table/wood/fancy/royalblack

/obj/item/stack/tile/carpet/royalblue
	name = "królewska niebieska wykładzina"
	icon_state = "tile-carpet-royalblue"
	item_state = "tile-carpet-royalblue"
	merge_type = /obj/item/stack/tile/carpet/royalblue
	turf_type = /turf/open/floor/carpet/royalblue
	tableVariant = /obj/structure/table/wood/fancy/royalblue

/obj/item/stack/tile/carpet/grimy
	name = "brudna wykładzina"
	singular_name = "płytka brudnej wykładziny"
	desc = "Kawałek wykładziny, który bardziej przypomina płytki podłogowe. Jak na wykładzinę jest zdecydowanie zbyt twardy w dotyku..."
	icon_state = "tile-carpet-grimy"
	item_state = "tile-carpet-grimy"
	merge_type = /obj/item/stack/tile/carpet/grimy
	turf_type = /turf/open/floor/carpet/grimy

/obj/item/stack/tile/eighties
	name = "płytka retro"
	singular_name = "płytka podłogowa retro"
	desc = "Stos płytek podłogowych, które przypominają ci prostsze czasy.."
	icon_state = "tile_eighties"
	merge_type = /obj/item/stack/tile/eighties
	turf_type = /turf/open/floor/eighties

/obj/item/stack/tile/carpet/fifty
	amount = 50

/obj/item/stack/tile/carpet/black/fifty
	amount = 50

/obj/item/stack/tile/carpet/blue/fifty
	amount = 50

/obj/item/stack/tile/carpet/cyan/fifty
	amount = 50

/obj/item/stack/tile/carpet/green/fifty
	amount = 50

/obj/item/stack/tile/carpet/orange/fifty
	amount = 50

/obj/item/stack/tile/carpet/purple/fifty
	amount = 50

/obj/item/stack/tile/carpet/red/fifty
	amount = 50

/obj/item/stack/tile/carpet/royalblack/fifty
	amount = 50

/obj/item/stack/tile/carpet/royalblue/fifty
	amount = 50

/obj/item/stack/tile/carpet/grimy/fifty
	amount = 50

/obj/item/stack/tile/eighties/fifty
	amount = 50

/obj/item/stack/tile/eighties/loaded
	amount = 30

/obj/item/stack/tile/fakespace
	name = "astralna wykładzina"
	singular_name = "płytka astralnej wykładziny"
	desc = "Kawałek wykładziny z przekonującym wzorem gwiazd."
	icon_state = "tile_space"
	item_state = "tile-space"
	turf_type = /turf/open/floor/fakespace
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/tile/fakespace

/obj/item/stack/tile/fakespace/loaded
	amount = 30

/obj/item/stack/tile/fakepit
	name = "fałszywe doły"
	singular_name = "fałszywy dół"
	desc = "Kawałek wykładziny z iluzją dołu w wymuszonej perspektywie. Nikt się na to nie nabierze!"
	icon_state = "tile_pit"
	item_state = "tile-basalt"
	turf_type = /turf/open/floor/fakepit
	resistance_flags = FLAMMABLE
	merge_type = /obj/item/stack/tile/fakepit

/obj/item/stack/tile/fakepit/loaded
	amount = 30

//High-traction
/obj/item/stack/tile/noslip
	name = "antypoślizgowa płytka podłogowa"
	singular_name = "antypoślizgowa płytka podłogowa"
	desc = "Antypoślizgowa płytka podłogowa. W dłoni wydaje się gumowa."
	icon_state = "tile_noslip"
	item_state = "tile-noslip"
	turf_type = /turf/open/floor/noslip
	merge_type = /obj/item/stack/tile/noslip

/obj/item/stack/tile/noslip/standard
	name = "antypoślizgowa płytka podłogowa"
	singular_name = "antypoślizgowa płytka podłogowa"
	desc = "Antypoślizgowa płytka podłogowa. W dłoni wydaje się gumowa."
	icon_state = "tile_noslip_standard"
	turf_type = /turf/open/floor/noslip/standard
	merge_type = /obj/item/stack/tile/noslip/standard

/obj/item/stack/tile/noslip/white
	name = "antypoślizgowa płytka podłogowa"
	singular_name = "antypoślizgowa płytka podłogowa"
	desc = "Antypoślizgowa płytka podłogowa. W dłoni wydaje się gumowa."
	icon_state = "tile_noslip_white"
	turf_type = /turf/open/floor/noslip/white
	merge_type = /obj/item/stack/tile/noslip/white

/obj/item/stack/tile/noslip/blue
	name = "antypoślizgowa płytka podłogowa"
	singular_name = "antypoślizgowa płytka podłogowa"
	desc = "Antypoślizgowa płytka podłogowa. W dłoni wydaje się gumowa."
	icon_state = "tile_noslip_blue"
	turf_type = /turf/open/floor/noslip/blue
	merge_type = /obj/item/stack/tile/noslip/blue

/obj/item/stack/tile/noslip/darkblue
	name = "antypoślizgowa płytka podłogowa"
	singular_name = "antypoślizgowa płytka podłogowa"
	desc = "Antypoślizgowa płytka podłogowa. W dłoni wydaje się gumowa."
	icon_state = "tile_noslip_darkblue"
	turf_type = /turf/open/floor/noslip/darkblue
	merge_type = /obj/item/stack/tile/noslip/darkblue

/obj/item/stack/tile/noslip/dark
	name = "antypoślizgowa płytka podłogowa"
	singular_name = "antypoślizgowa płytka podłogowa"
	desc = "Antypoślizgowa płytka podłogowa. W dłoni wydaje się gumowa."
	icon_state = "tile_noslip_dark"
	turf_type = /turf/open/floor/noslip/dark
	merge_type = /obj/item/stack/tile/noslip/dark

/obj/item/stack/tile/noslip/vaporwave
	name = "antypoślizgowa płytka podłogowa"
	singular_name = "antypoślizgowa płytka podłogowa"
	desc = "Antypoślizgowa płytka podłogowa. W dłoni wydaje się gumowa."
	icon_state = "tile_noslip_pinkblack"
	turf_type = /turf/open/floor/noslip/vaporwave
	merge_type = /obj/item/stack/tile/noslip/vaporwave

/obj/item/stack/tile/noslip/thirty
	amount = 30

//Circuit
/obj/item/stack/tile/circuit
	name = "niebieska płytka z obwodami"
	singular_name = "niebieska płytka z obwodami"
	desc = "Niebieska płytka z obwodami."
	icon_state = "tile_bcircuit"
	item_state = "tile-bcircuit"
	turf_type = /turf/open/floor/circuit

/obj/item/stack/tile/circuit/green
	name = "zielona płytka z obwodami"
	singular_name = "zielona płytka z obwodami"
	desc = "Zielona płytka z obwodami."
	icon_state = "tile_gcircuit"
	item_state = "tile-gcircuit"
	turf_type = /turf/open/floor/circuit/green

/obj/item/stack/tile/circuit/green/anim
	turf_type = /turf/open/floor/circuit/green/anim

/obj/item/stack/tile/circuit/red
	name = "czerwona płytka z obwodami"
	singular_name = "czerwona płytka z obwodami"
	desc = "Czerwona płytka z obwodami."
	icon_state = "tile_rcircuit"
	item_state = "tile-rcircuit"
	turf_type = /turf/open/floor/circuit/red

/obj/item/stack/tile/circuit/red/anim
	turf_type = /turf/open/floor/circuit/red/anim

//Pod floor
/obj/item/stack/tile/pod
	name = "płytka podłogowa kapsuły"
	singular_name = "płytka podłogowa kapsuły"
	desc = "Żłobkowana płytka podłogowa."
	icon_state = "tile_pod"
	item_state = "tile-pod"
	turf_type = /turf/open/floor/pod

/obj/item/stack/tile/pod/light
	name = "jasna płytka podłogowa kapsuły"
	singular_name = "jasna płytka podłogowa kapsuły"
	desc = "Jasna żłobkowana płytka podłogowa."
	icon_state = "tile_podlight"
	turf_type = /turf/open/floor/pod/light

/obj/item/stack/tile/pod/dark
	name = "ciemna płytka podłogowa kapsuły"
	singular_name = "ciemna płytka podłogowa kapsuły"
	desc = "Ciemna żłobkowana płytka podłogowa."
	icon_state = "tile_poddark"
	turf_type = /turf/open/floor/pod/dark

//Plasteel (normal)
/obj/item/stack/tile/plasteel
	name = "płytka podłogowa"
	singular_name = "płytka podłogowa"
	desc = "Te mogłyby całkiem nieźle posłużyć za broń miotaną."
	icon_state = "tile"
	item_state = "tile"
	force = 6
	materials = list(/datum/material/iron=500)
	throwforce = 10
	flags_1 = CONDUCT_1
	turf_type = /turf/open/floor/plasteel
	mineralType = "iron"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 70, "stamina" = 0)
	resistance_flags = FIRE_PROOF

/obj/item/stack/tile/plasteel/cyborg
	desc = "Grunt, po którym chodzisz." //Not the usual floor tile desc as that refers to throwing, Cyborgs can't do that - RR
	materials = list() // All other Borg versions of items have no Iron or Glass - RR
	is_cyborg = 1
	cost = 125

//Bay grids
/obj/item/stack/tile/grid
	name = "szara płytka kratkowana"
	singular_name = "szara płytka kratkowana"
	desc = "Kratkowana wersja standardowych płytek stacji."
	icon_state = "tile_grid"
	materials = list(/datum/material/iron=500)
	turf_type = /turf/open/floor/plasteel/grid

/obj/item/stack/tile/ridge
	name = "szara płytka żebrowana"
	singular_name = "szara płytka żebrowana"
	desc = "Żebrowana wersja standardowych płytek stacji."
	icon_state = "tile_ridged"
	materials = list(/datum/material/iron=500)
	turf_type = /turf/open/floor/plasteel/ridged

//Techtiles
/obj/item/stack/tile/techgrey
	name = "szara płytka techniczna"
	singular_name = "szara płytka techniczna"
	desc = "Elegancka płytka, spotykana zwykle w strzeżonych strefach i warsztatach inżynierii."
	icon_state = "tile_tech_grey"
	materials = list(/datum/material/iron=500)
	turf_type = /turf/open/floor/plasteel/tech

/obj/item/stack/tile/techgrid
	name = "kratkowana płytka techniczna"
	singular_name = "kratkowana płytka techniczna"
	desc = "Elegancka płytka, spotykana zwykle w strzeżonych strefach i warsztatach inżynierii. Ta ma wzór kratki."
	icon_state = "tile_tech_grid"
	materials = list(/datum/material/iron=500)
	turf_type = /turf/open/floor/plasteel/tech/grid

/obj/item/stack/tile/techmaint
	name = "ciemna płytka techniczna"
	singular_name = "ciemna płytka techniczna"
	desc = "Elegancka płytka, spotykana zwykle w strzeżonych strefach i warsztatach inżynierii. Ta jest ciemna."
	icon_state = "tile_tech_maint"
	materials = list(/datum/material/iron=500)
	turf_type = /turf/open/floor/plasteel/techmaint //NSV13 End

/obj/item/stack/tile/dock
	name = "płytka dokowa"
	singular_name = "płytka dokowa"
	desc = "Masywny fragment podłogi, który utrzyma ciężar promu."
	icon_state = "tile_dock"
	materials = list(/datum/material/iron=500, /datum/material/plasma=500)
	turf_type = /turf/open/floor/dock

/obj/item/stack/tile/drydock
	name = "płytka suchego doku"
	singular_name = "płytka suchego doku"
	desc = "Wyjątkowo masywny fragment podłogi, na którym można budować promy."
	icon_state = "tile_drydock"
	materials = list(/datum/material/iron=1000, /datum/material/plasma=1000)
	turf_type = /turf/open/floor/dock/drydock
