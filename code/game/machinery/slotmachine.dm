/*******************************\
|		  Slot Machines		  	|
|	  Original code by Glloyd	|
|	  Tgstation port by Miauw	|
\*******************************/

#define SPIN_PRICE 5
#define SMALL_PRIZE 400
#define BIG_PRIZE 1000
#define JACKPOT 10000
#define SPIN_TIME 4 SECONDS
#define SEVEN "7"
#define HOLOCHIP 1
#define COIN 2

/obj/machinery/computer/slot_machine
	name = "jednoręki bandyta"
	desc = "Hazard dla aspołecznych."
	icon = 'icons/obj/economy.dmi'
	icon_state = "slots1"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	circuit = /obj/item/circuitboard/computer/slot_machine
	var/money = 3000 //How much money it has CONSUMED
	var/plays = 0
	var/working = 0
	var/balance = 0 //How much money is in the machine, ready to be CONSUMED.
	var/jackpots = 0
	var/paymode = HOLOCHIP //toggles between HOLOCHIP/COIN, defined above
	var/cointype = /obj/item/coin/iron //default cointype
	var/list/coinvalues = list()
	var/list/reels = list(list("", "", "") = 0, list("", "", "") = 0, list("", "", "") = 0, list("", "", "") = 0, list("", "", "") = 0)
	var/list/symbols = list(SEVEN = 1, "&" = 2, "@" = 2, "$" = 2, "?" = 2, "#" = 2, "!" = 2, "%" = 2) //if people are winning too much, multiply every number in this list by 2 and see if they are still winning too much.
	/// AQUILA: kolory symboli w oknie TGUI
	var/static/list/symbol_colors = list(SEVEN = "red", "&" = "orange", "@" = "yellow", "$" = "green", "?" = "blue", "#" = "grey", "!" = "white", "%" = "fuchsia")
	/// Wynik ostatniej gry dla okna: 0 nic, 1 darmowe gry, 2 wygrana, 3 wielka wygrana, 4 jackpot
	var/winning = 0

	light_color = LIGHT_COLOR_BROWN

/obj/machinery/computer/slot_machine/Initialize(mapload)
	. = ..()
	jackpots = rand(1, 4) //false hope
	plays = rand(75, 200)

	toggle_reel_spin(1) //The reels won't spin unless we activate them

	var/list/reel = reels[1]
	for(var/i = 0, i < reel.len, i++) //Populate the reels.
		randomize_reels()

	toggle_reel_spin(0)

	for(cointype in typesof(/obj/item/coin))
		var/obj/item/coin/C = new cointype
		coinvalues["[cointype]"] = C.get_item_credit_value()

/obj/machinery/computer/slot_machine/Destroy()
	if(balance)
		give_payout(balance)
	return ..()

/obj/machinery/computer/slot_machine/process(delta_time)
	. = ..() //Sanity checks.
	if(!.)
		return .

	money += round(delta_time / 2) //SPESSH MAJICKS

/obj/machinery/computer/slot_machine/update_icon()
	if(machine_stat & NOPOWER)
		icon_state = "slots0"

	else if(machine_stat & BROKEN)
		icon_state = "slotsb"

	else if(working)
		icon_state = "slots2"

	else
		icon_state = "slots1"

/obj/machinery/computer/slot_machine/power_change()
	..()
	update_icon()

/obj/machinery/computer/slot_machine/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/coin))
		var/obj/item/coin/C = I
		if(paymode == COIN)
			if(prob(2))
				if(!user.transferItemToLoc(C, drop_location(), silent = FALSE))
					return
				C.throw_at(user, 3, 10)
				if(prob(10))
					balance = max(balance - SPIN_PRICE, 0)
				to_chat(user, "<span class='warning'>[src] wypluwa twoją monetę!</span>")

			else
				if(!user.temporarilyRemoveItemFromInventory(C))
					return
				to_chat(user, "<span class='notice'>Wrzucasz monetę ([C.cmineral]) do szczeliny [src]!</span>")
				balance += C.value
				qdel(C)
		else
			to_chat(user, "<span class='warning'>Ta maszyna przyjmuje tylko holożetony!</span>")
	else if(istype(I, /obj/item/holochip))
		if(paymode == HOLOCHIP)
			var/obj/item/holochip/H = I
			if(!user.temporarilyRemoveItemFromInventory(H))
				return
			to_chat(user, "<span class='notice'>Wkładasz [H.credits] holokredytów do szczeliny [src]!</span>")
			balance += H.credits
			qdel(H)
		else
			to_chat(user, "<span class='warning'>Ta maszyna przyjmuje tylko monety!</span>")
	else if(I.tool_behaviour == TOOL_MULTITOOL)
		if(balance > 0)
			visible_message("<b>[src]</b> mówi: 'BŁĄD! Przed zmianą trybu płatności opróżnij saldo maszyny'") //Prevents converting coins into holocredits and vice versa
		else
			if(paymode == HOLOCHIP)
				paymode = COIN
				visible_message("<b>[src]</b> mówi: 'Ta maszyna działa teraz na MONETY!'")
			else
				paymode = HOLOCHIP
				visible_message("<b>[src]</b> mówi: 'Ta maszyna działa teraz na HOLOŻETONY!'")
	else
		return ..()

/obj/machinery/computer/slot_machine/emag_act()
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(4, 0, src.loc)
	spark_system.start()
	playsound(src, "sparks", 50, 1)

/obj/machinery/computer/slot_machine/ui_interact(mob/living/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SlotMachine", name)
		ui.open()

/obj/machinery/computer/slot_machine/ui_static_data(mob/user)
	var/list/data = list()
	var/list/symbol_data = list()
	for(var/symbol in symbols)
		symbol_data += list(list("id" = symbol, "color" = symbol_colors[symbol]))
	data["symbols"] = symbol_data
	data["cost"] = SPIN_PRICE
	data["jackpot"] = JACKPOT
	data["jackpot_id"] = SEVEN
	return data

/obj/machinery/computer/slot_machine/ui_data(mob/user)
	var/list/data = list()
	var/list/_reels = list()
	for(var/reel in reels)
		_reels += list(list("symbols" = reel))
	data["reels"] = _reels
	data["balance"] = balance
	data["working"] = working
	data["winning"] = winning
	data["money"] = money
	data["plays"] = plays
	data["jackpots"] = jackpots
	data["paymode"] = paymode
	return data

/obj/machinery/computer/slot_machine/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("spin")
			spin(usr)
			return TRUE
		if("payout")
			if(balance > 0)
				give_payout(balance)
				balance = 0
			return TRUE

/obj/machinery/computer/slot_machine/emp_act(severity)
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN) || . & EMP_PROTECT_SELF)
		return
	if(prob(15 * severity))
		return
	if(prob(1)) // :^)
		obj_flags |= EMAGGED
	var/severity_ascending = 4 - severity
	money = max(rand(money - (200 * severity_ascending), money + (200 * severity_ascending)), 0)
	balance = max(rand(balance - (50 * severity_ascending), balance + (50 * severity_ascending)), 0)
	money -= max(0, give_payout(min(rand(-50, 100 * severity_ascending)), money)) //This starts at -50 because it shouldn't always dispense coins yo
	spin()

/obj/machinery/computer/slot_machine/proc/spin(mob/user)
	if(!can_spin(user))
		return

	var/the_name
	if(user)
		the_name = user.real_name
		visible_message("<span class='notice'>[user] pociąga za dźwignię, a automat zaczyna się kręcić!</span>")
	else
		the_name = "Exaybachay"

	balance -= SPIN_PRICE
	money += SPIN_PRICE
	plays += 1
	working = 1
	winning = 0

	update_icon()

	// Wynik losujemy od razu; okno animuje bębny i zatrzymuje je na nowym stanie
	toggle_reel_spin(1)
	for(var/i in 1 to 3)
		randomize_reels()
	toggle_reel_spin(0)
	SStgui.update_uis(src)

	addtimer(CALLBACK(src, PROC_REF(finish_spinning), user, the_name), SPIN_TIME)

/obj/machinery/computer/slot_machine/proc/finish_spinning(mob/user, the_name)
	working = 0
	give_prizes(the_name, user)
	update_icon()
	SStgui.update_uis(src)

/obj/machinery/computer/slot_machine/proc/can_spin(mob/user)
	if(machine_stat & NOPOWER)
		to_chat(user, "<span class='warning'>Automat nie ma zasilania!</span>")
	if(machine_stat & BROKEN)
		to_chat(user, "<span class='warning'>Automat jest zepsuty!</span>")
	if(working)
		to_chat(user, "<span class='warning'>Musisz zaczekać, aż automat przestanie się kręcić, zanim znów zagrasz!</span>")
		return 0
	if(balance < SPIN_PRICE)
		to_chat(user, "<span class='warning'>Za mało pieniędzy, by zagrać!</span>")
		return 0
	return 1

/obj/machinery/computer/slot_machine/proc/toggle_reel_spin(value, delay = 0) //value is 1 or 0 aka on or off
	for(var/list/reel in reels)
		reels[reel] = value
		sleep(delay)

/obj/machinery/computer/slot_machine/proc/randomize_reels()

	for(var/reel in reels)
		if(reels[reel])
			reel[3] = reel[2]
			reel[2] = reel[1]
			reel[1] = pick(symbols)

/obj/machinery/computer/slot_machine/proc/give_prizes(usrname, mob/user)
	var/linelength = get_lines()

	if(reels[1][2] + reels[2][2] + reels[3][2] + reels[4][2] + reels[5][2] == "[SEVEN][SEVEN][SEVEN][SEVEN][SEVEN]")
		visible_message("<b>[src]</b> mówi: 'JACKPOT! Wygrywasz [money] kredytów!'")
		priority_announce("Gratulacje dla [user ? user.real_name : usrname] za wygranie jackpota na automacie w [get_area(src)]!", sound = SSstation.announcer.get_rand_alert_sound())
		jackpots += 1
		winning = 4
		balance += money - give_payout(JACKPOT)
		money = 0
		if(paymode == HOLOCHIP)
			new /obj/item/holochip(loc,JACKPOT)
		else
			for(var/i = 0, i < 5, i++)
				cointype = pick(subtypesof(/obj/item/coin))
				var/obj/item/coin/C = new cointype(loc)
				random_step(C, 2, 50)

	else if(linelength == 5)
		visible_message("<b>[src]</b> mówi: 'Wielka wygrana! Wygrywasz tysiąc kredytów!'")
		winning = 3
		give_money(BIG_PRIZE)

	else if(linelength == 4)
		visible_message("<b>[src]</b> mówi: 'Wygrana! Wygrywasz czterysta kredytów!'")
		winning = 2
		give_money(SMALL_PRIZE)

	else if(linelength == 3)
		to_chat(user, "<span class='notice'>Wygrywasz trzy darmowe gry!</span>")
		winning = 1
		balance += SPIN_PRICE * 4
		money = max(money - SPIN_PRICE * 4, money)

	else
		to_chat(user, "<span class='warning'>Pech!</span>")

/obj/machinery/computer/slot_machine/proc/get_lines()
	var/amountthesame

	for(var/i = 1, i <= 3, i++)
		var/inputtext = reels[1][i] + reels[2][i] + reels[3][i] + reels[4][i] + reels[5][i]
		for(var/symbol in symbols)
			var/j = 3 //The lowest value we have to check for.
			var/symboltext = symbol + symbol + symbol
			while(j <= 5)
				if(findtext(inputtext, symboltext))
					amountthesame = max(j, amountthesame)
				j++
				symboltext += symbol

			if(amountthesame)
				break

	return amountthesame

/obj/machinery/computer/slot_machine/proc/give_money(amount)
	var/amount_to_give = money >= amount ? amount : money
	var/surplus = amount_to_give - give_payout(amount_to_give)
	money = max(0, money - amount)
	balance += surplus

/obj/machinery/computer/slot_machine/proc/give_payout(amount)
	if(paymode == HOLOCHIP)
		cointype = /obj/item/holochip
	else
		cointype = obj_flags & EMAGGED ? /obj/item/coin/iron : /obj/item/coin/silver

	if(!(obj_flags & EMAGGED))
		amount = dispense(amount, cointype, null, 0)

	else
		var/mob/living/target = locate() in hearers(2, src)

		amount = dispense(amount, cointype, target, 1)

	return amount

/obj/machinery/computer/slot_machine/proc/dispense(amount = 0, cointype = /obj/item/coin/silver, mob/living/target, throwit = 0)
	if(paymode == HOLOCHIP)
		var/obj/item/holochip/H = new /obj/item/holochip(loc,amount)

		if(throwit && target)
			H.throw_at(target, 3, 10)
	else
		var/value = coinvalues["[cointype]"]
		if(value <= 0)
			CRASH("Coin value of zero, refusing to payout in dispenser")
		while(amount >= value)
			var/obj/item/coin/C = new cointype(loc) //DOUBLE THE PAIN
			amount -= value
			if(throwit && target)
				C.throw_at(target, 3, 10)
			else
				random_step(C, 2, 40)

	return amount

#undef SEVEN
#undef SPIN_TIME
#undef JACKPOT
#undef BIG_PRIZE
#undef SMALL_PRIZE
#undef SPIN_PRICE
#undef HOLOCHIP
#undef COIN
