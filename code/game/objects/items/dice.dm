/obj/item/storage/pill_bottle/dice
	name = "worek kości"
	desc = "Mieści całe szczęście, jakiego kiedykolwiek będziesz potrzebować."
	icon = 'icons/obj/dice.dmi'
	icon_state = "dicebag"
	pill_variance = 0

/obj/item/storage/pill_bottle/dice/Initialize(mapload)
	. = ..()
	var/special_die = pick("1","2","fudge","space","00","8bd20","4dd6","100")
	if(special_die == "1")
		new /obj/item/dice/d1(src)
	if(special_die == "2")
		new /obj/item/dice/d2(src)
	new /obj/item/dice/d4(src)
	new /obj/item/dice/d6(src)
	if(special_die == "fudge")
		new /obj/item/dice/fudge(src)
	if(special_die == "space")
		new /obj/item/dice/d6/space(src)
	new /obj/item/dice/d8(src)
	new /obj/item/dice/d10(src)
	if(special_die == "00")
		new /obj/item/dice/d00(src)
	new /obj/item/dice/d12(src)
	new /obj/item/dice/d20(src)
	if(special_die == "8bd20")
		new /obj/item/dice/eightbd20(src)
	if(special_die == "4dd6")
		new /obj/item/dice/fourdd6(src)
	if(special_die == "100")
		new /obj/item/dice/d100(src)

/obj/item/storage/pill_bottle/dice/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] gra ze śmiercią w kości! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return (OXYLOSS)

/obj/item/storage/pill_bottle/dice_cup
	name = "kubek do kości"
	desc = "Do rzucania kilkoma kośćmi naraz. Ulubieniec ulicznych urwisów."
	icon = 'icons/obj/dice.dmi'
	icon_state = "dicecup"
	pill_variance = 0

/obj/item/storage/pill_bottle/dice_cup/attack_self(mob/user)
	var/turf/throw_target = get_step(loc,user.dir) //with telekinesis, throws the direction the user is facing
	for(var/obj/item/dice/die in src)
		die.forceMove(drop_location())
		die.throw_at(throw_target,1,1,user)

/obj/item/dice //depreciated d6, use /obj/item/dice/d6 if you actually want a d6
	name = "kość"
	desc = "Kość o sześciu ściankach. Prosta i niezawodna."
	icon = 'icons/obj/dice.dmi'
	icon_state = "d6"
	w_class = WEIGHT_CLASS_TINY
	var/sides = 6
	var/result = null
	var/list/special_faces = list() //entries should match up to sides var if used
	var/microwave_riggable = TRUE

	var/rigged = DICE_NOT_RIGGED
	var/rigged_value

/obj/item/dice/Initialize(mapload)
	. = ..()
	if(!result)
		result = roll(sides)
	update_icon()

/obj/item/dice/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Na wierzchu jest [result].</span>"

/obj/item/dice/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] gra ze śmiercią w kości! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return (OXYLOSS)

/obj/item/dice/d1
	name = "d1"
	desc = "Kość o tylko jednej ściance. Deterministyczna!"
	icon_state = "d1"
	sides = 1

/obj/item/dice/d2
	name = "d2"
	desc = "Kość o dwóch ściankach. Monety są poniżej godności!"
	icon_state = "d2"
	sides = 2

/obj/item/dice/d4
	name = "d4"
	desc = "Kość o czterech ściankach. Kolczatka nerda."
	icon_state = "d4"
	sides = 4

/obj/item/dice/d4/Initialize(mapload)
	. = ..()
	// 1d4 damage
	AddComponent(/datum/component/caltrop, min_damage = 1, max_damage = 4)

/obj/item/dice/d6
	name = "d6"

/obj/item/dice/d6/space
	name = "kosmiczna kostka"
	desc = "Kość o sześciu ściankach. 6 RAZY 255 RAZY 255 PÓL CAŁEGO ISTNIENIA, UKWADRATOWIJ SWÓJ UMYSŁ WYKSZTAŁCONEJ GŁUPOTY: 2 NIE ISTNIEJE."
	icon_state = "spaced6"

/obj/item/dice/d6/space/Initialize(mapload)
	. = ..()
	if(prob(10))
		name = "kosmiczna kosteczka"

/obj/item/dice/fudge
	name = "kość fudge"
	desc = "Kość o sześciu ściankach, ale tylko trzech wynikach. Plus czy minus? W głowie masz pustkę..."
	sides = 3 //shhh
	icon_state = "fudge"
	special_faces = list("minus","blank","plus")

/obj/item/dice/d8
	name = "d8"
	desc = "Kość o ośmiu ściankach. Wydaje się... szczęśliwa."
	icon_state = "d8"
	sides = 8

/obj/item/dice/d10
	name = "d10"
	desc = "Kość o dziesięciu ściankach. Przydatna do procentów."
	icon_state = "d10"
	sides = 10

/obj/item/dice/d00
	name = "d00"
	desc = "Kość o dziesięciu ściankach. Do rzutów d100 nadaje się lepiej niż piłka golfowa."
	icon_state = "d00"
	sides = 10

/obj/item/dice/d12
	name = "d12"
	desc = "Kość o dwunastu ściankach. Unosi się wokół niej aura zapomnienia."
	icon_state = "d12"
	sides = 12

/obj/item/dice/d20
	name = "d20"
	desc = "Kość o dwudziestu ściankach. Ulubiona kość do rzucania w mistrza gry."
	icon_state = "d20"
	sides = 20

/obj/item/dice/d100
	name = "d100"
	desc = "Kość o stu ściankach! Pewnie nie jest uczciwie wyważona..."
	icon_state = "d100"
	w_class = WEIGHT_CLASS_SMALL
	sides = 100

/obj/item/dice/d100/update_icon()
	return

/obj/item/dice/eightbd20
	name = "dziwna d20"
	desc = "Dziwna kość z wypukłym napisem na ściankach. Wszystko jest białe na białym, więc odczytanie tego to męka. Co za kiepski projekt!"
	icon_state = "8bd20"
	sides = 20
	special_faces = list("To pewne","Zdecydowanie tak","Bez wątpienia","Tak, zdecydowanie","Możesz na tym polegać","Jak ja to widzę, tak","Najprawdopodobniej","Perspektywy są dobre","Tak","Znaki wskazują, że tak","Odpowiedź niejasna, spróbuj ponownie","Zapytaj później","Lepiej, żebym teraz nie mówiła","Nie mogę teraz przewidzieć","Skup się i zapytaj ponownie","Nie licz na to","Moja odpowiedź brzmi: nie","Moje źródła mówią, że nie","Perspektywy nie są zbyt dobre","Bardzo wątpliwe")

/obj/item/dice/eightbd20/update_icon()
	return

/obj/item/dice/fourdd6
	name = "d6 4D"
	desc = "Kość istniejąca w przestrzeni czterowymiarowej. Prawidłowo odczytać ją można tylko z pomocą matematyka, fizyka i kapłana."
	icon_state = "4dd6"
	sides = 48
	special_faces = list("Ściana kostki: 1-1","Ściana kostki: 1-2","Ściana kostki: 1-3","Ściana kostki: 1-4","Ściana kostki: 1-5","Ściana kostki: 1-6","Ściana kostki: 2-1","Ściana kostki: 2-2","Ściana kostki: 2-3","Ściana kostki: 2-4","Ściana kostki: 2-5","Ściana kostki: 2-6","Ściana kostki: 3-1","Ściana kostki: 3-2","Ściana kostki: 3-3","Ściana kostki: 3-4","Ściana kostki: 3-5","Ściana kostki: 3-6","Ściana kostki: 4-1","Ściana kostki: 4-2","Ściana kostki: 4-3","Ściana kostki: 4-4","Ściana kostki: 4-5","Ściana kostki: 4-6","Ściana kostki: 5-1","Ściana kostki: 5-2","Ściana kostki: 5-3","Ściana kostki: 5-4","Ściana kostki: 5-5","Ściana kostki: 5-6","Ściana kostki: 6-1","Ściana kostki: 6-2","Ściana kostki: 6-3","Ściana kostki: 6-4","Ściana kostki: 6-5","Ściana kostki: 6-6","Ściana kostki: 7-1","Ściana kostki: 7-2","Ściana kostki: 7-3","Ściana kostki: 7-4","Ściana kostki: 7-5","Ściana kostki: 7-6","Ściana kostki: 8-1","Ściana kostki: 8-2","Ściana kostki: 8-3","Ściana kostki: 8-4","Ściana kostki: 8-5","Ściana kostki: 8-6")

/obj/item/dice/fourdd6/update_icon()
	return

/obj/item/dice/attack_self(mob/user)
	diceroll(user)

/obj/item/dice/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/mob/thrown_by = thrownby?.resolve()
	if(thrown_by)
		diceroll(thrown_by)
	return ..()

/obj/item/dice/proc/diceroll(mob/user)
	result = roll(sides)
	if(rigged != DICE_NOT_RIGGED && result != rigged_value)
		if(rigged == DICE_BASICALLY_RIGGED && prob(CLAMP(1/(sides - 1) * 100, 25, 80)))
			result = rigged_value
		else if(rigged == DICE_TOTALLY_RIGGED)
			result = rigged_value

	. = result

	var/fake_result = roll(sides)//Daredevil isn't as good as he used to be
	var/comment = ""
	if(sides == 20 && result == 20)
		comment = "NAT 20!"
	else if(sides == 20 && result == 1)
		comment = "Auć, pech."
	update_icon()
	if(initial(icon_state) == "d00")
		result = (result - 1)*10
	if(special_faces.len == sides)
		result = special_faces[result]
	if(user != null) //Dice was rolled in someone's hand
		user.visible_message("[user] rzuca [src]. Wypada [result]. [comment]", \
							 "<span class='notice'>Rzucasz [src]. Wypada [result]. [comment]</span>", \
							 "<span class='italics'>Słyszysz, jak [src] się toczy, brzmi to jak [fake_result].</span>")
	else if(!src.throwing) //Dice was thrown and is coming to rest
		visible_message("<span class='notice'>[src] toczy się i zatrzymuje. Wypada [result]. [comment]</span>")

/obj/item/dice/update_icon()
	cut_overlays()
	add_overlay("[src.icon_state]-[src.result]")

/obj/item/dice/microwave_act(obj/machinery/microwave/M)
	if(microwave_riggable)
		rigged = DICE_BASICALLY_RIGGED
		rigged_value = result
	..(M)
