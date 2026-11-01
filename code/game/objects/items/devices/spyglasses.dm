//detective spyglasses. meant to be an example for map_popups.dm
/obj/item/clothing/glasses/sunglasses/spy
	desc = "Dzieło działu infiltracji i inwigilacji Nerd Co. Przy bliższych oględzinach widać w każdym szkle mały ekranik."
	actions_types = list(/datum/action/item_action/activate_remote_view)
	var/obj/item/clothing/accessory/spy_bug/linked_bug

/obj/item/clothing/glasses/sunglasses/spy/proc/show_to_user(mob/user)//this is the meat of it. most of the map_popup usage is in this.
	if(!user?.client)
		return
	if(!linked_bug)
		user.audible_message("<span class='warning'>[src] wydaje przenikliwy pisk!</span>")
	if(user.client.screen_maps["spypopup_map"]) //alright, the popup this object uses is already IN use, so the window is open. no point in doing any other work here, so we're good.
		return
	user.client.setup_popup("spypopup", 3, 3, 2)
	user.client.register_map_obj(linked_bug.cam_screen)
	for(var/plane in linked_bug.cam_plane_masters)
		user.client.register_map_obj(plane)
	linked_bug.update_view()

/obj/item/clothing/glasses/sunglasses/spy/equipped(mob/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_EYES))
		user.client.close_popup("spypopup")

/obj/item/clothing/glasses/sunglasses/spy/dropped(mob/user)
	..()
	user.client.close_popup("spypopup")

/obj/item/clothing/glasses/sunglasses/spy/ui_action_click(mob/user)
	show_to_user(user)

/obj/item/clothing/glasses/sunglasses/spy/item_action_slot_check(slot)
	return slot & ITEM_SLOT_EYES

/obj/item/clothing/glasses/sunglasses/spy/Destroy()
	if(linked_bug)
		linked_bug.linked_glasses = null
	return ..()


/obj/item/clothing/accessory/spy_bug
	name = "etui na długopisy"
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "pocketprotector"
	desc = "Zaawansowany sprzęt szpiegowski w kształcie kieszonkowego etui na długopisy. Ma wbudowaną kamerę 360 stopni na wszystkie twoje „godne podziwu” potrzeby. Mikrofon do nabycia osobno."
	var/obj/item/clothing/glasses/sunglasses/spy/linked_glasses
	var/atom/movable/screen/map_view/cam_screen
	var/list/cam_plane_masters
	// Ranges higher than one can be used to see through walls.
	var/cam_range = 1
	var/datum/movement_detector/tracker

/obj/item/clothing/accessory/spy_bug/Initialize(mapload)
	. = ..()
	tracker = new /datum/movement_detector(src, CALLBACK(src, PROC_REF(update_view)))

	cam_screen = new
	cam_screen.name = "screen"
	cam_screen.assigned_map = "spypopup_map"
	cam_screen.del_on_map_removal = FALSE
	cam_screen.set_position(1, 1)

	// We need to add planesmasters to the popup, otherwise
	// blending fucks up massively. Any planesmaster on the main screen does
	// NOT apply to map popups. If there's ever a way to make planesmasters
	// omnipresent, then this wouldn't be needed.
	cam_plane_masters = list()
	for(var/plane in subtypesof(/atom/movable/screen/plane_master))
		var/atom/movable/screen/instance = new plane()
		instance.assigned_map = "spypopup_map"
		instance.del_on_map_removal = FALSE
		instance.screen_loc = "spypopup_map:CENTER"
		cam_plane_masters += instance

/obj/item/clothing/accessory/spy_bug/Destroy()
	if(linked_glasses)
		linked_glasses.linked_bug = null
	QDEL_NULL(cam_screen)
	QDEL_LIST(cam_plane_masters)
	QDEL_NULL(tracker)
	return ..()

/obj/item/clothing/accessory/spy_bug/proc/update_view()//this doesn't do anything too crazy, just updates the vis_contents of its screen obj
	cam_screen.vis_contents.Cut()
	for(var/turf/visible_turf in view(1,get_turf(src)))//fuck you usr
		cam_screen.vis_contents += visible_turf

//it needs to be linked, hence a kit.
/obj/item/storage/box/rxglasses/spyglasskit
	name = "zestaw okularów szpiegowskich"
	desc = "W tym pudełku są <i>odjazdowe</i> okulary nerda z wbudowanymi wyświetlaczami do podglądu z połączonej kamery."

/obj/item/paper/fluff/nerddocs
	name = "Szpiegostwo dla opornych"
	color = "#FFFF00"
	desc = "Oślepiająco żółta broszurka z kiepsko zaprojektowanym obrazkiem detektywa. Podtytuł głosi: „Najnowszy sposób na łamanie zasad ochrony prywatności!” "
	default_raw_text = @{"
Dziękujemy za zakup Nerd Co SpySpeks <small>tm</small>! Ta kartka to twój szybki przewodnik po łamaniu prywatności współtowarzyszy w trzech prostych krokach!<br><br>Krok pierwszy: załóż Nerd Co SpySpeks <small>tm</small> na twarz. <br>
Krok drugi: umieść dołączony zespół kamery „ProfitProtektor <small>tm</small>” w wybranym miejscu – koniecznie wykorzystaj jego niepozorny wygląd!
Krok trzeci: naciśnij przycisk „Aktywuj Zdalny Widok” z boku SpySpeks <small>tm</small>, by otworzyć ruchomy podgląd z kamery w rogu pola widzenia. To takie proste!<br><br><br><center><b>ROZWIĄZYWANIE PROBLEMÓW</b><br></center>
Moje SpySpeks <small>tm</small> przenikliwie piszczą przy próbie użycia!
Przenikliwy pisk SpySpeks oznacza, że nie mogą połączyć się z dołączonym ProfitProtektorem <small>tm</small>. Upewnij się, że ProfitProtektor wciąż jest aktywny i sprawny!
	"}

/obj/item/storage/box/rxglasses/spyglasskit/PopulateContents()
	var/obj/item/clothing/accessory/spy_bug/newbug = new(src)
	var/obj/item/clothing/glasses/sunglasses/spy/newglasses = new(src)
	newbug.linked_glasses = newglasses
	newglasses.linked_bug = newbug
	new /obj/item/paper/fluff/nerddocs(src)
