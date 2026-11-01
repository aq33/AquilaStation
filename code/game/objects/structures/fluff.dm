//Fluff structures serve no purpose and exist only for enriching the environment. They can be destroyed with a wrench.

/obj/structure/fluff
	name = "struktura dekoracyjna"
	desc = "Puszystsza od owcy. To nie powinno istnieć."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "minibar"
	anchored = TRUE
	density = FALSE
	opacity = 0
	var/deconstructible = TRUE

/obj/structure/fluff/attackby(obj/item/I, mob/living/user, params)
	if(I.tool_behaviour == TOOL_WRENCH && deconstructible)
		user.visible_message("<span class='notice'>[user] zaczyna rozbierać [src]...</span>", "<span class='notice'>Zaczynasz rozbierać [src]...</span>")
		I.play_tool_sound(src)
		if(I.use_tool(src, user, 50))
			user.visible_message("<span class='notice'>[user] rozbiera [src]!</span>", "<span class='notice'>Rozbierasz [src] na złom.</span>")
			playsound(user, 'sound/items/deconstruct.ogg', 50, 1)
			new/obj/item/stack/sheet/iron(drop_location())
			qdel(src)
		return
	..()

/obj/structure/fluff/empty_terrarium //Empty terrariums are created when a preserved terrarium in a lavaland seed vault is activated.
	name = "puste terrarium"
	desc = "Prastara maszyna, która chyba służyła do przechowywania materii roślinnej. Jej klapa jest uchylona."
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "terrarium_open"
	density = TRUE

/obj/structure/fluff/empty_sleeper //Empty sleepers are created by a good few ghost roles in lavaland.
	name = "pusty sleeper"
	desc = "Otwarty sleeper. Wygląda, jakby czekał na kolejnego pacjenta, gdyby nie był zepsuty."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper-open"

/obj/structure/fluff/empty_sleeper/nanotrasen
	name = "zepsuta komora hipersnu"
	desc = "Komora hipersnu Nanotrasen – ta wygląda na zepsutą. \
		Ma odsłonięte śruby, więc łatwo ją rozebrać kluczem."
	icon_state = "sleeper-o"

/obj/structure/fluff/empty_sleeper/syndicate
	icon_state = "sleeper_s-open"

/obj/structure/fluff/empty_cryostasis_sleeper //Empty cryostasis sleepers are created when a malfunctioning cryostasis sleeper in a lavaland shelter is activated
	name = "pusty sleeper kriostazy"
	desc = "Choć jest wygodny, ten sleeper już nigdy nie posłuży za nic innego niż łóżko."
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "cryostasis_sleeper_open"

/obj/structure/fluff/broken_flooring
	name = "rozbite płytki"
	desc = "Fragment zniszczonej podłogi."
	icon = 'icons/obj/brokentiling.dmi'
	icon_state = "corner"

/obj/structure/fluff/drake_statue //Ash drake status spawn on either side of the necropolis gate in lavaland.
	name = "posąg smoka"
	desc = "Górująca bazaltowa rzeźba dumnego i dostojnego smoka. Jego oczy to sześć lśniących klejnotów."
	icon = 'icons/effects/64x64.dmi'
	icon_state = "drake_statue"
	pixel_x = -16
	density = TRUE
	deconstructible = FALSE
	layer = EDGED_TURF_LAYER

/obj/structure/fluff/drake_statue/falling //A variety of statue in disrepair; parts are broken off and a gemstone is missing
	desc = "Górująca bazaltowa rzeźba smoka. Jej powierzchnię przecinają pęknięcia, a niektóre części odpadły."
	icon_state = "drake_statue_falling"


/obj/structure/fluff/bus
	name = "autobus"
	desc = "IDŹ DO SZKOŁY. PRZECZYTAJ KSIĄŻKĘ."
	icon = 'icons/obj/bus.dmi'
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/bus/dense
	name = "autobus"
	icon_state = "backwall"

/obj/structure/fluff/bus/passable
	name = "autobus"
	icon_state = "frontwalltop"
	density = FALSE
	layer = ABOVE_ALL_MOB_LAYER //except for the stairs tile, which should be set to OBJ_LAYER aka 3.


/obj/structure/fluff/bus/passable/seat
	name = "siedzenie"
	desc = "Zapnij pasy! ...Jak to nie ma pasów?!"
	icon_state = "backseat"
	pixel_y = 17
	layer = OBJ_LAYER


/obj/structure/fluff/bus/passable/seat/driver
	name = "fotel kierowcy"
	desc = "Kosmiczny Jezus jest moim drugim pilotem."
	icon_state = "driverseat"

/obj/structure/fluff/bus/passable/seat/driver/attack_hand(mob/user)
	playsound(src, 'sound/items/carhorn.ogg', 50, 1)
	. = ..()

/obj/structure/fluff/paper
	name = "gęsta warstwa papierów"
	desc = "Warstwa papierów rozrzuconych u podstawy ściany."
	icon = 'icons/obj/fluff.dmi'
	icon_state = "paper"
	deconstructible = FALSE

/obj/structure/fluff/paper/corner
	icon_state = "papercorner"

/obj/structure/fluff/paper/stack
	name = "gruby stos papierów"
	desc = "Stos różnych papierów, na każdej kartce dziecięce bazgroły."
	icon_state = "paperstack"


/obj/structure/fluff/divine
	name = "Cud"
	icon = 'icons/obj/hand_of_god_structures.dmi'
	anchored = TRUE
	density = TRUE

/obj/structure/fluff/divine/nexus
	name = "nexus"
	desc = "Zakotwicza bóstwo w tym świecie. Promieniuje niezwykłą aurą. Wygląda na dobrze chroniony przed falą uderzeniową."
	icon_state = "nexus"

/obj/structure/fluff/divine/conduit
	name = "przekaźnik"
	desc = "Pozwala bóstwu poszerzyć zasięg. W pobliżu przekaźnika jego moce są równie silne jak przy nexusie."
	icon_state = "conduit"

/obj/structure/fluff/divine/convertaltar
	name = "ołtarz nawrócenia"
	desc = "Ołtarz poświęcony bóstwu."
	icon_state = "convertaltar"
	density = FALSE
	can_buckle = 1

/obj/structure/fluff/divine/powerpylon
	name = "pylon mocy"
	desc = "Pylon, który przyspiesza wpływ bóstwa na świat."
	icon_state = "powerpylon"
	can_buckle = 1

/obj/structure/fluff/divine/defensepylon
	name = "pylon obronny"
	desc = "Pobłogosławiony pylon, który wytrzymuje wiele ciosów i strzela silnymi pociskami w niewiernych. Bóg może go przełączać."
	icon_state = "defensepylon"

/obj/structure/fluff/divine/shrine
	name = "kapliczka"
	desc = "Kapliczka poświęcona bóstwu."
	icon_state = "shrine"

/obj/structure/fluff/fokoff_sign
	name = "prowizoryczna tablica"
	desc = "Topornie zrobiona tablica z napisem „spadaj” wymalowanym jakąś czerwoną farbą."
	icon = 'icons/obj/fluff.dmi'
	icon_state = "fokof"
