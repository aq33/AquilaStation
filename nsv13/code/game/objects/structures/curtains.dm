/obj/structure/curtain/obscuring //In other words, curtains that obscure vision when you close them
	name = "czarne zasłony"
	desc = "Eleganckie czarne zasłony, które ochronią przed wścibskimi oczami cokolwiek robisz w środku..."
	color = "#000000"
	alpha = 255

/obj/structure/curtain/obscuring/grey
	name = "czarne zasłony"
	desc = "Eleganckie ciemnoszare zasłony, które ochronią przed wścibskimi oczami cokolwiek robisz w środku..."
	color = "#696969"

/obj/structure/curtain/obscuring/toggle() //obscure vision when you close them.
	open = !open
	switch(open)
		if(TRUE)
			opacity = FALSE
		if(FALSE)
			opacity = TRUE
	update_icon()
