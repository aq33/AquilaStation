/*
Slimecrossing Potions
	Potions added by the slimecrossing system.
	Collected here for clarity.
*/

//Extract cloner - Charged Grey
/obj/item/slimepotion/extract_cloner
	name = "mikstura klonowania ekstraktów"
	desc = "Silniejsza wersja wzmacniacza ekstraktów, która potrafi klonować zwykłe ekstrakty szlamu."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potpurple"

/obj/item/slimepotion/extract_cloner/afterattack(obj/item/target, mob/user , proximity)
	if(!proximity)
		return
	if(istype(target, /obj/item/reagent_containers))
		return ..(target, user, proximity)
	if(istype(target, /obj/item/slimecross))
		to_chat(user, "<span class='warning'>[target] jest zbyt złożony, by mikstura go sklonowała!</span>")
		return
	if(!istype(target, /obj/item/slime_extract))
		return
	var/obj/item/slime_extract/S = target
	if(S.recurring)
		to_chat(user, "<span class='warning'>[target] jest zbyt złożony, by mikstura go sklonowała!</span>")
		return
	var/path = S.type
	var/obj/item/slime_extract/C = new path(get_turf(target))
	C.Uses = S.Uses
	to_chat(user, "<span class='notice'>Wylewasz miksturę na [target], a płyn zestala się w jego kopię!</span>")
	qdel(src)
	return

//Peace potion - Charged Light Pink
/obj/item/slimepotion/peacepotion
	name = "mikstura pacyfikująca"
	desc = "Jasnoróżowy roztwór chemikaliów pachnący płynnym spokojem. I solami rtęci."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potlightpink"

/obj/item/slimepotion/peacepotion/attack(mob/living/M, mob/user)
	if(!isliving(M) || M.stat == DEAD)
		to_chat(user, "<span class='warning'>[src] działa tylko na żywe istoty.</span>")
		return ..()
	if(istype(M, /mob/living/simple_animal/hostile/megafauna))
		to_chat(user, "<span class='warning'>[src] nie działa na istoty czystego zła!</span>")
		return ..()
	if(M != user)
		M.visible_message("<span class='danger'>[user] zaczyna podawać [M] miksturę uspokajającą!</span>",
			"<span class='userdanger'>[user] zaczyna podawać ci miksturę uspokajającą!</span>")
	else
		M.visible_message("<span class='danger'>[user] zaczyna pić [src]!</span>",
			"<span class='danger'>Zaczynasz pić [src]!</span>")

	if(!do_after(user, 100, target = M))
		return
	if(M != user)
		to_chat(user, "<span class='notice'>Podajesz [M] [src]!</span>")
	else
		to_chat(user, "<span class='warning'>Wypijasz [src]!</span>")
	if(isanimal(M))
		ADD_TRAIT(M, TRAIT_PACIFISM, MAGIC_TRAIT)
	else if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.gain_trauma(/datum/brain_trauma/severe/pacifism, TRAUMA_RESILIENCE_SURGERY)
	qdel(src)

//Love potion - Charged Pink
/obj/item/slimepotion/lovepotion
	name = "eliksir miłości"
	desc = "Różowa mieszanka chemiczna, która podobno budzi uczucie miłości."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potpink"

/obj/item/slimepotion/lovepotion/attack(mob/living/M, mob/user)
	if(!isliving(M) || M.stat == DEAD)
		to_chat(user, "<span class='warning'>Eliksir miłosny działa tylko na żywe istoty, zboczeńcu!</span>")
		return ..()
	if(istype(M, /mob/living/simple_animal/hostile/megafauna) || isknpc(M)) //NSV13 - knpcs are evil.
		to_chat(user, "<span class='warning'>Eliksir miłosny nie działa na istoty czystego zła!</span>")
		return ..()
	if(user == M)
		to_chat(user, "<span class='warning'>Nie możesz wypić eliksiru miłosnego. Co ty, narcyz?</span>")
		return ..()
	if(M.has_status_effect(STATUS_EFFECT_INLOVE))
		to_chat(user, "<span class='warning'>[M] jest już zakochany!</span>")
		return ..()

	M.visible_message("<span class='danger'>[user] zaczyna podawać [M] eliksir miłosny!</span>",
		"<span class='userdanger'>[user] zaczyna podawać ci eliksir miłosny!</span>")

	if(!do_after(user, 50, target = M))
		return
	to_chat(user, "<span class='notice'>Podajesz [M] eliksir miłosny!</span>")
	to_chat(M, "<span class='notice'>Zaczynasz czuć coś do [user] i do każdego, kogo on lubi.</span>")
	if(M.mind)
		M.mind.store_memory("Jesteś zakochany w [user].")
	M.faction |= "[REF(user)]"
	M.apply_status_effect(STATUS_EFFECT_INLOVE, user)
	qdel(src)

//Pressure potion - Charged Dark Blue
/obj/item/slimepotion/spaceproof
	name = "szlamowa mikstura ciśnieniowa"
	desc = "Silny chemiczny uszczelniacz, który czyni dowolne ubranie szczelnym. Wystarcza na dwa użycia."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potblue"
	var/uses = 2

/obj/item/slimepotion/spaceproof/pre_attack(obj/item/clothing/C, mob/user, proximity)
	. = ..()
	if(!uses)
		qdel(src)
		return
	if(!proximity)
		return
	if(!istype(C))
		to_chat(user, "<span class='warning'>Mikstury można użyć tylko na ubraniach!</span>")
		return
	if(C.min_cold_protection_temperature == SPACE_SUIT_MIN_TEMP_PROTECT && C.clothing_flags & STOPSPRESSUREDAMAGE)
		to_chat(user, "<span class='warning'>[C] jest już odporny na ciśnienie!</span>")
		return ..()
	to_chat(user, "<span class='notice'>Smarujesz [C] niebieską mazią, czyniąc go szczelnym.</span>")
	C.name = "[C.name] (odporność na ciśnienie)"
	C.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	C.add_atom_colour("#000080", FIXED_COLOUR_PRIORITY)
	C.min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	C.cold_protection = C.body_parts_covered
	C.clothing_flags |= STOPSPRESSUREDAMAGE
	uses--
	if(!uses)
		qdel(src)
	return FALSE

//Enhancer potion - Charged Cerulean
/obj/item/slimepotion/enhancer/max
	name = "maksymalizator ekstraktów"
	desc = "Niezwykle silna mieszanka chemiczna, która maksymalizuje liczbę użyć ekstraktu szlamu."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potpurple"

//Lavaproofing potion - Charged Red
/obj/item/slimepotion/lavaproof
	name = "szlamowa mikstura lawoodporna"
	desc = "Dziwna, czerwonawa maź, która podobno odpycha lawę jak wodę, choć nie zmniejsza palności. Wystarcza na dwa użycia."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potred"
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	var/uses = 2

/obj/item/slimepotion/lavaproof/pre_attack(obj/item/C, mob/user, proximity)
	. = ..()
	if(!uses)
		qdel(src)
		return ..()
	if(!proximity)
		return ..()
	if(!istype(C))
		to_chat(user, "<span class='warning'>Nie możesz pokryć tego płynem chroniącym przed lawą!</span>")
		return ..()
	to_chat(user, "<span class='notice'>Smarujesz [C] czerwoną mazią, czyniąc go odpornym na lawę.</span>")
	C.name = "[C.name] (odporność na lawę)"
	C.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	C.add_atom_colour("#800000", FIXED_COLOUR_PRIORITY)
	C.resistance_flags |= LAVA_PROOF
	if (isclothing(C))
		var/obj/item/clothing/CL = C
		CL.clothing_flags |= LAVAPROTECT
	uses--
	if(!uses)
		qdel(src)
	return FALSE

//Revival potion - Charged Grey
/obj/item/slimepotion/slime_reviver
	name = "szlamowa mikstura ożywiająca"
	desc = "Nasycona plazmą i sprężonym żelem, przywraca martwe szlamy do życia."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potsilver"

/obj/item/slimepotion/slime_reviver/attack(mob/living/simple_animal/slime/M, mob/user)
	if(!isslime(M))
		to_chat(user, "<span class='warning'>Mikstura działa tylko na szlamy!</span>")
		return ..()
	if(M.stat != DEAD)
		to_chat(user, "<span class='warning'>Szlam wciąż żyje!</span>")
		return
	if(M.maxHealth <= 0)
		to_chat(user, "<span class='warning'>Szlam jest zbyt niestabilny, by go przywrócić!</span>")
	M.revive(full_heal = 1)
	M.set_stat(CONSCIOUS)
	M.visible_message("<span class='notice'>[M] napełnia się nowym wigorem i budzi się, mrugając!</span>")
	M.maxHealth -= 10 //Revival isn't healthy.
	M.health -= 10
	M.regenerate_icons()
	qdel(src)

//Stabilizer potion - Charged Blue
/obj/item/slimepotion/slime/chargedstabilizer
	name = "omnistabilizator szlamów"
	desc = "Niezwykle silna mieszanka chemiczna, która całkowicie powstrzymuje mutacje szlamu."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potcyan"

/obj/item/slimepotion/slime/chargedstabilizer/attack(mob/living/simple_animal/slime/M, mob/user)
	if(!isslime(M))
		to_chat(user, "<span class='warning'>Stabilizator działa tylko na szlamy!</span>")
		return ..()
	if(M.stat)
		to_chat(user, "<span class='warning'>Szlam nie żyje!</span>")
		return
	if(M.mutation_chance == 0)
		to_chat(user, "<span class='warning'>Szlam już nie ma szans na mutację!</span>")
		return

	to_chat(user, "<span class='notice'>Podajesz szlamowi omnistabilizator. W tym cyklu nie zmutuje!</span>")
	M.mutation_chance = 0
	qdel(src)
