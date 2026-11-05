/datum/buildmode_mode/boom
	key = "boom"
	
	var/devastation = -1
	var/heavy = -1
	var/light = -1
	var/flash = -1
	var/flames = -1

/datum/buildmode_mode/boom/show_help(client/c)
	to_chat(c, "<span class='notice'>***********************************************************</span>")
	to_chat(c, "<span class='notice'>Przycisk myszy na obiekcie  = Bum</span>")
	to_chat(c, "<span class='notice'>UWAGA: verb „Config/Launch Supplypod” pozwala zrobić to w sposób IC (np. pocisk manewrujący spada z nieba i wybucha tam, gdzie klikniesz!)</span>")
	to_chat(c, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/boom/change_settings(client/c)
	devastation = input(c, "Zasięg całkowitego zniszczenia. -1 = brak", text("Wartość")) as num|null
	if(devastation == null) 
		devastation = -1
	heavy = input(c, "Zasięg ciężkich zniszczeń. -1 = brak", text("Wartość")) as num|null
	if(heavy == null) 
		heavy = -1
	light = input(c, "Zasięg lekkich zniszczeń. -1 = brak", text("Wartość")) as num|null
	if(light == null) 
		light = -1
	flash = input(c, "Zasięg błysku. -1 = brak", text("Wartość")) as num|null
	if(flash == null) 
		flash = -1
	flames = input(c, "Zasięg płomieni. -1 = brak", text("Wartość")) as num|null
	if(flames == null) 
		flames = -1

/datum/buildmode_mode/boom/handle_click(client/c, params, obj/object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")

	if(left_click)
		explosion(object, devastation, heavy, light, flash, FALSE, TRUE, flames)
		log_admin("Build Mode: [key_name(c)] caused an explosion(dev=[devastation], hvy=[heavy], lgt=[light], flash=[flash], flames=[flames]) at [AREACOORD(object)]")
