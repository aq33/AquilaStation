#define PAGE_FOREWORD		0
#define PAGE_LORE1			101
#define PAGE_LORE2			102
#define PAGE_LORE3			103

GLOBAL_LIST_INIT(arcane_tomes, list())

///////////////////////////////////////ARCANE TOME////////////////////////////////////////////////
/obj/item/tome
	name = "tajemna księga"
	desc = "Ciemna, zakurzona księga o postrzępionych brzegach i złowrogiej okładce. W dotyku jest twarda i zimna."
	icon = 'aquila/icons/bloodcult/cult.dmi'
	icon_state = "tome"
	worn_icon = null
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	var/state = TOME_CLOSED
	var/can_flick = 1
	var/list/talismans = list()
	var/current_page = PAGE_FOREWORD

/obj/item/tome/New()
	..()
	GLOB.arcane_tomes.Add(src)

/obj/item/tome/salt_act()
	fire_act(1000, 200)

/obj/item/tome/Destroy()
	GLOB.arcane_tomes.Remove(src)
	for(var/obj/O in talismans)
		talismans.Remove(O)
		qdel(O)
	talismans=list()
	..()

/obj/item/tome/suicide_act(mob/living/user)
	var/datum/antagonist/cult/cult_datum=user.mind?.has_antag_datum(/datum/antagonist/cult)
	if (cult_datum)
		playsound(get_turf(user), 'aquila/sound/bloodcult/edibles.ogg', 75, 0)
		anim(target=user, a_icon='aquila/icons/bloodcult/cult.dmi', a_icon_state="build", lay=BELOW_OBJ_LAYER, plane=GAME_PLANE, sleeptime=20)
		user.Stun(10)
		icon_state="tome-open"
		flick("tome-flickopen", src)
		playsound(user, "pageturn", 50, 1, -2)
		state=TOME_OPEN
		user.visible_message(span_danger("[user] zaczyna powtarzać tajemne słowa nad otwartą [src]. Krew zaczyna płynąć z nosa, oczu, uszu i wszystkich innych otworów! Wygląda na to, że próbuje popełnić samobójstwo.") )
		sleep(10)
		cult_datum.gain_devotion(500, DEVOTION_TIER_4, "suicide_tome", user)
		anim(target=user, a_icon='icons/effects/effects.dmi', flick_anim="rune_sac", lay=ABOVE_MOB_LAYER, plane=GAME_PLANE_UPPER)
		to_chat(user, span_cult("Ofiarowujesz tę skorupę z ciała Nar-Sie.") )
		sleep(4)
		user.gib()
	else
		return ..()


/obj/item/tome/proc/tome_text()
	var/page_data=null
	var/dat={"<html><head><meta charset='UTF-8'><title>tajemna księga</title></head><body style="color:#FFFFFF" bgcolor="#110000">

			<style>
				label {display: inline-block; width: 50px;text-align: right;float: left;margin: 0 0 0 10px;}
				ul {list-style-type: none;}
				li:before {content: "-";padding-left: 4px;}
				a {text-decoration: none; color:#FFEC66}
				.column {float: left; width: 400px; padding: 0px; height: 300px;}
				.row:after {content: ""; display: table; clear: both;}
			</style>

			<div class="row">
			<div class="column" style="font-size:18px">
			<div align="center" style="margin: 0 0 0 -10px;"><div style="font-size:30px"><b>Pisma <font color=#FF250F>Nar-Sie</b></font></div>Geometra Krwi</div>
			<ul>
			<a href='byond://?src=\ref[src];page=[PAGE_FOREWORD]'><label> * </label> <li> Przedmowa</a> </li>"}

	var i=1
	for(var/subtype in subtypesof(/datum/rune_spell))
		var/datum/rune_spell/instance=subtype
		if (initial(instance.secret))
			continue
		dat += "<a href='byond://?src=\ref[src];page=[i]'><label> \Roman[i] </label> <li>  [initial(instance.name)] </li></a>"
		if (i == current_page)
			var/datum/rune_word/word1=initial(instance.word1)
			var/datum/rune_word/word2=initial(instance.word2)
			var/datum/rune_word/word3=initial(instance.word3)
			page_data={"<div align="center"><b>\Roman[i]<br>[initial(instance.name)]</b><br><i>[initial(word1.display_name)], [initial(word2.display_name)], [word3 ? "[initial(word3.display_name)]" : "(dowolne)"]</i></div><br>"}
			page_data += initial(instance.page)
		i++

	dat += {"<a href='byond://?src=\ref[src];page=[PAGE_LORE1]'><label> * </label> <li>  Dodatek I </li></a>
			<a href='byond://?src=\ref[src];page=[PAGE_LORE2]'><label> * </label> <li>  Dodatek II </li></a>
			<a href='byond://?src=\ref[src];page=[PAGE_LORE3]'><label> * </label> <li>  Dodatek III </li></a>
			</ul></div>
			<div style="font-size:18px" class="column">      <div align="left">      <b><ul>"}

	for (var/obj/item/talisman/T in talismans)
		dat += {"<label> * </label><li>  <a style="color:#FFEC66" href='byond://?src=\ref[src];talisman=\ref[T]'>[T.talisman_name()][(T.uses > 1) ? " (użycia: [T.uses])" : ""]</a> <a style="color:#AE250F" href='byond://?src=\ref[src];remove=\ref[T]'>(x)</a> </li>"}

	dat += {"</ul></b></div><div align="justify">"}

	if (page_data)
		dat += page_data
	else
		dat += page_special()

	dat += {"</div></div></div></body>"}

	return dat

/obj/item/tome/proc/page_special()
	var/dat=null
	switch (current_page)
		if (PAGE_FOREWORD)
			dat={"<div align="center"><b>Przedmowa</b></div><br>"}
			dat += "<i>Spisywana przez wieki przez grono arcykultystów pod przewodnictwem samego Geometry.</i>\
				<br><br>Dotknij rozdziału, by go przeczytać."
		if (PAGE_LORE1)
			dat={"<div align="center"><b>Dodatek I: „Z drugiej strony zasłony”</b></div><br>"}
			dat += "<i>Ludzkość natrafiła na królestwo Nar-Sie przypadkiem, kilka stuleci temu. \
					Choć niektórzy z tak zwanych czarodziejów nazwali to szczęśliwym trafem, niewielu z nich wie, że kości były obciążone od samego początku.\
					<br><br>Nar-Sie porzucił w bluespace kilka artefaktów i czekał, aż jakaś inteligentna istota je podniesie i odnajdzie po nich drogę do niego. \
					Widzisz, Nar-Sie kocha w ludziach dwie rzeczy: krew płynącą w ich żyłach i dramatyczne okoliczności, w których ta krew w końcu wypływa z ich ziejących ran.\
					<br><br>Skąd wiedział o istnieniu ludzkości, zanim ta w ogóle do niego dotarła? To proste: słyszał bicie naszych serc aż z drugiej strony zasłony.</i>"
		if (PAGE_LORE2)
			dat={"<div align="center"><b>Dodatek II: „Z kogo płynie krew”</b></div><br>"}
			dat += "<i>Gdy płaszczyzny się zetknęły, było tylko kwestią czasu, aż pojawią się ludzie, którzy zaczną Nar-Sie szukać.\
					<br><br>Jedni dlatego, że jego miłość do dramatu i chaosu znalazła w nich oddźwięk i zapragnęli zostać jego heroldami, składając ofiary dla jego uciechy, \
					inni z zachwytu nad jego... „nieziemskością”? Ludzie, którzy dotąd twardo stąpali po ziemi, zafascynowali się czymś mistycznym, a zarazem namacalnym.\
					<br><br>I oczywiście przyszli też ci, którzy chcieli mu się przeciwstawić, w imię własnych bogów albo z własnego poczucia moralności. Mało który z nich wie, \
					że Nar-Sie kocha ich tak samo i niewiele go obchodzi, z kogo płynie krew.</i>"
		if (PAGE_LORE3)
			dat={"<div align="center"><b>Dodatek III: „Wizytówka Geometry”</b></div><br>"}
			dat += "<i>Częstym nieporozumieniem jest tytuł Nar-Sie: dlaczego właściwie jest Geometrą Krwi? Nikt nie śmiał zapytać go wprost, by go nie urazić, więc przez długi czas \
					wielu kultystów po prostu zakładało, że naprawdę pasjonuje się geometrią, a to, że jego moc objawia się przez krwawe rysunki o precyzyjnych wzorach, zdawało się to potwierdzać.\
					<br><br>W końcu kilku kultystów postanowiło nawiązać z nim kontakt i poznać odpowiedź, dla pewności składając wcześniej parę ofiar. Odpowiedź była zaskakująca i rzuciła nowe światło na początki kultu. \
					Dowiedzieli się, że gdy czarodzieje przebili się do jego płaszczyzny, minęło trochę czasu, zanim na niego trafili, tak jak ludzie nie wiedzą o każdej mrówce w swoim ogrodzie. \
					Kiedy jednak na niego natrafili, jego olbrzymia postać rozpięta na tle krajobrazu przypominała ćmę miernikowca.\
					<br><br>A tak jak ćmy lgną do światła, tak Nar-Sie lgnął do krwi, więc nazwali go Geometrą Krwi, a ten tytuł bardzo przypadł mu do gustu.\
					<br><br>Im głębiej ludzkość zapuszcza się w ciemność kosmosu i igra z mocami, które rozumie coraz mniej, tym wyraźniej Nar-Sie czuje, że jest coraz bliżej, i chce teraz ten proces przyspieszyć. \
					Jego kult wysyła heroldów, by dali ludzkości znać, jak bardzo ją lubi (głównie jej krew), a dopóki nie będzie gotów zaprosić jej do swojego królestwa, zostawiają wśród gwiazd zbryzgane krwią stacje kosmiczne jako jego wizytówkę.</i>"
	return dat

/obj/item/tome/Topic(href, href_list)
	if (..())
		return
	if(!usr.held_items.Find(src))
		return
	if(href_list["page"])
		current_page=text2num(href_list["page"])
		flick("tome-flick", src)
		playsound(usr, "pageturn", 50, 1, -5)

	if(href_list["talisman"])
		var/obj/item/talisman/T=locate(href_list["talisman"])
		if(!talismans.Find(T))
			return
		T.trigger(usr)

	if(href_list["remove"])
		var/obj/item/talisman/T=locate(href_list["remove"])
		if(!talismans.Find(T))
			return
		talismans.Remove(T)
		usr.put_in_hands(T)

	usr << browse(tome_text(), "window=arcanetome;size=900x600")

/obj/item/tome/attack(mob/living/M, mob/living/user)
	/*
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had the [name] used on him by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used [name] on [M.name] ([M.ckey])</font>")
	msg_admin_attack("[user.name] ([user.ckey]) used [name] on [M.name] ([M.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

	M.assaulted_by(user)
	*/

	if(!istype(M))
		return

	if(IS_CULTIST(M))//don't want to harm our team mates using tomes
		return

	..()

	if (!M.stat == DEAD)
		M.adjustOrganLoss(ORGAN_SLOT_STOMACH, rand(1, 10))
		to_chat(M, span_warning("Czujesz palący żar w swoim wnętrzu!") )
		var/datum/antagonist/cult/cult_datum=user.mind.has_antag_datum(/datum/antagonist/cult)
		if (cult_datum)
			if (M.mind)
				cult_datum.gain_devotion(30, DEVOTION_TIER_3, "attack_tome", M)
			else
				cult_datum.gain_devotion(30, DEVOTION_TIER_2, "attack_tome_nomind", M)

/obj/item/tome/attack_hand(mob/living/user)
	if(!IS_CULTIST(user) && state == TOME_OPEN)
		to_chat(user, span_warning("Gdy sięgasz po [src], czujesz palący żar w swoim wnętrzu!") )
		playsound(loc, 'sound/effects/sparks2.ogg', 50, 1, 0, 0, 0)
		user.Knockdown(5)
		user.Stun(5)
		flick("tome-stun", src)
		state=TOME_CLOSED
		return
	..()

/obj/item/tome/pickup(mob/user)
	.=..()
	if(IS_CULTIST(user) && state == TOME_OPEN)
		usr << browse(tome_text(), "window=arcanetome;size=900x600")

/obj/item/tome/dropped(mob/user)
	.=..()
	usr << browse(null, "window=arcanetome")

/obj/item/tome/attack_self(mob/living/user)
	if(!IS_CULTIST(user))//Too dumb to live.
		to_chat(user, span_warning("Próbujesz zajrzeć do [src], ale czujesz tylko wyładowanie energii i palący żar w swoim wnętrzu!") )
		playsound(loc, 'sound/effects/sparks2.ogg', 50, 1, 0, 0, 0)
		user.Knockdown(5)
		user.Stun(5)
		if (state == TOME_OPEN)
			icon_state="tome"
			flick("tome-stun", src)
			state=TOME_CLOSED
		else
			flick("tome-stun2", src)
		return
	else
		if (state == TOME_CLOSED)
			icon_state="tome-open"
			flick("tome-flickopen", src)
			playsound(user, "pageturn", 50, 1, -5)
			state=TOME_OPEN
			usr << browse(tome_text(), "window=arcanetome;size=900x600")
		else
			icon_state="tome"
			flick("tome-flickclose", src)
			state=TOME_CLOSED
			usr << browse(null, "window=arcanetome")

//absolutely no use except letting cultists know that you're here.
/obj/item/tome/attack_ghost(mob/dead/observer/user)
	if (state == TOME_OPEN && can_flick)
		if (Adjacent(user))
			to_chat(user, "Przewracasz stronę.")
			flick("tome-flick", src)
			playsound(user, "pageturn", 50, 1, -3)
			can_flick=0
			addtimer(VARSET_CALLBACK(src, can_flick, 1), 5)
		else
			to_chat(user, span_warning("Musisz podejść bliżej, by poruszyć stronami.") )

/obj/item/tome/attackby(obj/item/I, mob/user)
	if (..())
		return
	if (istype(I, /obj/item/talisman))
		if (talismans.len < MAX_TALISMAN_PER_TOME)
			if(user.dropItemToGround(I))
				talismans.Add(I)
				I.forceMove(src)
				to_chat(user, span_notice("Wsuwasz [I] do [src].") )
				if (state == TOME_OPEN)
					usr << browse(tome_text(), "window=arcanetome;size=900x600")
		else
			to_chat(user, span_warning("Ta księga nie pomieści więcej talizmanów. Najpierw jakieś zużyj albo wyjmij.") )

/obj/item/tome/AltClick(mob/user)
	var/list/choices=list()
	var/datum/rune_spell/instance
	var/list/choice_to_talisman=list()
	var/image/talisman_image
	var/blood_messages=0
	var/blanks=0
	for(var/obj/item/talisman/T in talismans)
		talisman_image=new(T)
		if (T.blood_text)
			choices += list(list("Krwawa wiadomość[blood_messages ? " #[blood_messages+1]" : ""]", talisman_image, "Duch nabazgrał na tym talizmanie wiadomość."))
			choice_to_talisman["Krwawa wiadomość[blood_messages ? " #[blood_messages+1]" : ""]"]=T
			blood_messages++
		else if (T.spell_type)
			instance=T.spell_type
			choices += list(list(T.talisman_name(), talisman_image, initial(instance.desc_talisman)))
			choice_to_talisman[T.talisman_name()]=T
		else
			choices += list(list("Pusty talizman[blanks ? " #[blanks+1]" : ""]", talisman_image, "Zwykły pusty talizman."))
			choice_to_talisman["Pusty talizman[blanks ? " #[blanks+1]" : ""]"]=T
			blanks++


	var/list/made_choices=list()
	for(var/list/choice in choices)
		var/datum/radial_menu_choice/option=new
		option.image=image(choice[2])
		option.info=span_boldnotice(choice[3])
		made_choices[choice[1]]=option

	if (state == TOME_CLOSED)
		icon_state="tome-open"
		flick("tome-flickopen", src)
		playsound(user, "pageturn", 50, 1, -5)
		state=TOME_OPEN

	var/choice=show_radial_menu(user, loc, made_choices, tooltips=TRUE, radial_icon='aquila/icons/bloodcult/cult_radial3.dmi')
	if(!choice)
		return
	var/obj/item/talisman/chosen_talisman=choice_to_talisman[choice]
	if(!usr.held_items.Find(src))
		return
	if (state == TOME_OPEN)
		icon_state="tome"
		flick("tome-stun", src)
		state=TOME_CLOSED
	talismans.Remove(chosen_talisman)
	usr.put_in_hands(chosen_talisman)

#undef PAGE_FOREWORD
#undef PAGE_LORE1
#undef PAGE_LORE2
#undef PAGE_LORE3
