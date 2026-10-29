#define SHOWCASE_CONSTRUCTED 1
#define SHOWCASE_SCREWDRIVERED 2

/*Completely generic structures for use by mappers to create fake objects, i.e. display rooms*/
/obj/structure/showcase
	name = "gablota"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "showcase_1"
	desc = "Stojak z przykręconym pustym korpusem cyborga."
	density = TRUE
	anchored = TRUE
	var/deconstruction_state = SHOWCASE_CONSTRUCTED

/obj/structure/showcase/fakeid
	name = "\improper konsola identyfikacyjna Centrali"
	desc = "Służy do zmiany kart ID."
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"

/obj/structure/showcase/fakeid/Initialize(mapload)
	. = ..()
	add_overlay("id")
	add_overlay("id_key")

/obj/structure/showcase/fakesec
	name = "\improper akta ochrony Centrali"
	desc = "Służą do przeglądania i edycji akt personelu prowadzonych przez ochronę."
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"

/obj/structure/showcase/fakesec/Initialize(mapload)
	. = ..()
	add_overlay("security")
	add_overlay("security_key")

/obj/structure/showcase/horrific_experiment
	name = "przerażający eksperyment"
	desc = "Jakaś kapsuła pełna krwi i wnętrzności. Dałbyś głowę, że widzisz, jak coś się w niej rusza..."
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "pod_g"

/obj/structure/showcase/machinery/oldpod
	name = "uszkodzona kapsuła kriogeniczna"
	desc = "Uszkodzona kapsuła kriogeniczna dawno zapomniana przez czas, podobnie jak ten, kto w niej był..."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper-open"

/obj/structure/showcase/machinery/oldpod/used
	name = "otwarta kapsuła kriogeniczna"
	desc = "Kapsuła kriogeniczna, która niedawno wypuściła swojego lokatora. Wygląda na niesprawną."

/obj/structure/showcase/cyborg/old
	name = "posąg cyborga"
	desc = "Stary, wyłączony cyborg. Kiedyś strzegł przed intruzami, dziś tylko onieśmiela ich zimnym, stalowym spojrzeniem."
	icon = 'icons/mob/robots.dmi'
	icon_state = "robot_old"
	density = FALSE

/obj/structure/showcase/mecha/marauder
	name = "eksponat: mech bojowy"
	desc = "Stojak z przykręconym pustym, starym mechem bojowym Korporacji Nanotrasen. Opis przedstawia go jako czołową jednostkę broniącą interesów korporacji i jej pracowników."
	icon = 'icons/mecha/mecha.dmi'
	icon_state = "marauder"

/obj/structure/showcase/mecha/ripley
	name = "eksponat: mech budowlany"
	desc = "Stojak z przykręconym, wycofanym z użytku mechem budowlanym. Kleszcze mają nacisk 9300 PSI. Wygląda, jakby się rozpadał."
	icon = 'icons/mecha/mecha.dmi'
	icon_state = "firefighter"

/obj/structure/showcase/machinery/implanter
	name = "\improper eksponat: automatyczny wszczepiacz mindshieldów Nanotrasen"
	desc = "Wątły model standardowej automatycznej maszyny Nanotrasen do wszczepiania implantów mindshield. Dzięki pewnym pasom stabilizującym i zrobotyzowanemu wstrzykiwaczowi chirurgicznemu uszkodzenia mózgu i inne poważne powikłania są teraz nawet o 60% mniej prawdopodobne!"
	icon = 'icons/obj/machines/implantchair.dmi'
	icon_state = "implantchair"

/obj/structure/showcase/machinery/microwave
	name = "\improper mikrofalówka marki Nanotrasen"
	desc = "Słynna mikrofalówka marki Nanotrasen, wielofunkcyjne urządzenie kuchenne, którego potrzebuje każda stacja! Ta wygląda na narysowaną na kartonowym pudle."
	icon = 'icons/obj/machines/microwave.dmi'
	icon_state = "map_icon"

/obj/structure/showcase/machinery/cloning_pod
	name = "eksponat: kapsuła klonująca"
	desc = "Tabliczki wyjaśniają, jak takie kapsuły klonujące pozwalają każdemu pracownikowi Nanotrasen wypełnić kontrakt w całości, nawet w mało prawdopodobnym wypadku katastrofalnej śmierci. Oby nie wszystkie były z kartonu, jak ta."
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "pod_0"

/obj/structure/showcase/perfect_employee
	name = "eksponat: pracownik „Człowiek Idealny”"
	desc = "Stojak z przykręconym modelem idealnego pracownika Nanotrasen. Według tabliczek jest solidnie zmodyfikowany genetycznie i bezwzględnie lojalny."

/obj/structure/showcase/machinery/tv
	name = "\improper korporacyjny serwis informacyjny Nanotrasen"
	desc = "Nieco poobijany telewizor. W pętli lecą różne reklamy Nanotrasen przy wtórze wesołej melodyjki."
	icon = 'icons/obj/computer.dmi'
	icon_state = "television"

/obj/structure/showcase/machinery/signal_decrypter
	name = "deszyfrator sygnałów podsystemu"
	desc = "Dziwna maszyna, która podobno pomaga odbierać i deszyfrować sygnały radiowe."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "processor"



//Deconstructing
//Showcases can be any sprite, so it makes sense that they can't be constructed.
//However if a player wants to move an existing showcase or remove one, this is for that.

/obj/structure/showcase/attackby(obj/item/W, mob/user)
	if(W.tool_behaviour == TOOL_SCREWDRIVER && !anchored)
		if(deconstruction_state == SHOWCASE_SCREWDRIVERED)
			to_chat(user, "<span class='notice'>Wkręcasz z powrotem wkręty w gablotę.</span>")
			W.play_tool_sound(src, 100)
			deconstruction_state = SHOWCASE_CONSTRUCTED
		else if (deconstruction_state == SHOWCASE_CONSTRUCTED)
			to_chat(user, "<span class='notice'>Wykręcasz wkręty.</span>")
			W.play_tool_sound(src, 100)
			deconstruction_state = SHOWCASE_SCREWDRIVERED

	if(W.tool_behaviour == TOOL_CROWBAR && deconstruction_state == SHOWCASE_SCREWDRIVERED)
		if(W.use_tool(src, user, 20, volume=100))
			to_chat(user, "<span class='notice'>Zaczynasz rozbierać gablotę łomem...</span>")
			new /obj/item/stack/sheet/iron(drop_location(), 4)
			qdel(src)

	if(deconstruction_state == SHOWCASE_CONSTRUCTED && default_unfasten_wrench(user, W))
		return

//Feedback is given in examine because showcases can basically have any sprite assigned to them

/obj/structure/showcase/examine(mob/user)
	. = ..()

	switch(deconstruction_state)
		if(SHOWCASE_CONSTRUCTED)
			. += "Gablota jest w pełni złożona."
		if(SHOWCASE_SCREWDRIVERED)
			. += "Gablota ma poluzowane wkręty."
		else
			. += "Jeśli to widzisz, coś jest nie tak."
