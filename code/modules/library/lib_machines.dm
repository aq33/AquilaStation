/* Library Machines
 *
 * Contains:
 *		Borrowbook datum
 *		Library Public Computer
 *		Library Computer
 *		Library Scanner
 *		Book Binder
 */



#define BOOKS_PER_PAGE 18
#define INVENTORY_PER_PAGE 15
#define CHECKOUTS_PER_PAGE 15
#define DEFAULT_SEARCH_CATEGORY "Any"
#define DEFAULT_UPLOAD_CATEGORY "Fiction"
#define LIBRARY_SEARCH_CATEGORIES list("Any", "Fiction", "Non-Fiction", "Adult", "Reference", "Religion", "Technical")
#define LIBRARY_UPLOAD_CATEGORIES list("Fiction", "Non-Fiction", "Adult", "Reference", "Religion", "Technical")

/*
 * Library Public Computer
 */
/obj/machinery/computer/libraryconsole
	name = "library visitor console"
	icon_state = "oldcomp"
	icon_screen = "library"
	icon_keyboard = null
	circuit = /obj/item/circuitboard/computer/libraryconsole
	desc = "Checked out books MUST be returned on time."
	clockwork = TRUE //it'd look weird
	broken_overlay_emissive = TRUE
	///The current book id we're searching for
	var/book_id = null
	///The current title we're searching for
	var/title = ""
	///The category we're searching for
	var/category = DEFAULT_SEARCH_CATEGORY
	///The author we're searching for
	var/author = ""
	///The results of our last query
	var/list/page_content = list()
	///The the total pages last we checked
	var/page_count = 0
	///The page of our current query
	var/search_page = 0
	///Can we connect to the db?
	var/can_connect = FALSE
	///A hash of the last search we did, prevents spam in a different way then the cooldown
	var/last_search_hash = ""
	///Have the search params changed at all since the last search?
	var/params_changed = FALSE
	///Are we currently sending a db request for books?
	var/sending_request = FALSE
	///Prevents spamming requests, acts as a second layer of protection against spam
	COOLDOWN_DECLARE(db_request_cooldown)
	///Interface name for the ui_interact call for different subtypes.
	var/interface_type = "LibraryVisitor"

/obj/machinery/computer/libraryconsole/Initialize(mapload)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(update_db_info))

/obj/machinery/computer/libraryconsole/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, interface_type)
		ui.open()

/obj/machinery/computer/libraryconsole/ui_data(mob/user)
	var/list/data = list()
	data["can_db_request"] = can_db_request()
	data["search_categories"] = LIBRARY_SEARCH_CATEGORIES
	data["category"] = category
	data["author"] = author
	data["title"] = title
	data["book_id"] = book_id
	data["page_count"] = page_count + 1 //Increase these by one so it looks like we're not indexing at 0
	data["our_page"] = search_page + 1
	data["pages"] = page_content
	data["can_connect"] = can_connect
	data["params_changed"] = params_changed
	return data

/obj/machinery/computer/libraryconsole/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("set_search_id")
			var/newid = text2num(params["id"])
			if(!isnum_safe(newid) || !ISINTEGER(newid) || newid <= 0)
				newid = null
			if(newid != book_id)
				params_changed = TRUE
			book_id = newid
			return TRUE
		if("set_search_title")
			var/newtitle = sanitize(copytext("[params["title"]]", 1, MAX_NAME_LEN))
			if(newtitle != title)
				params_changed = TRUE
			title = newtitle
			return TRUE
		if("set_search_category")
			var/newcategory = params["category"]
			if(!(newcategory in LIBRARY_SEARCH_CATEGORIES)) //Nice try
				newcategory = DEFAULT_SEARCH_CATEGORY
			if(newcategory != category)
				params_changed = TRUE
			category = newcategory
			return TRUE
		if("set_search_author")
			var/newauthor = sanitize(copytext("[params["author"]]", 1, MAX_NAME_LEN))
			if(newauthor != author)
				params_changed = TRUE
			author = newauthor
			return TRUE
		if("search")
			if(!prevent_db_spam())
				say("Kable bazy danych się odświeżają. Chwileczkę.")
				return
			INVOKE_ASYNC(src, PROC_REF(update_db_info))
			return TRUE
		if("switch_page")
			if(!prevent_db_spam())
				say("Kable bazy danych się odświeżają. Chwileczkę.")
				return
			search_page = sanitize_page_input(params["page"], search_page, page_count)
			INVOKE_ASYNC(src, PROC_REF(update_db_info))
			return TRUE
		if("clear_data")
			if(!prevent_db_spam())
				say("Kable bazy danych się odświeżają. Chwileczkę.")
				return
			book_id = null
			title = initial(title)
			author = initial(author)
			category = DEFAULT_SEARCH_CATEGORY
			search_page = 0
			INVOKE_ASYNC(src, PROC_REF(update_db_info))
			return TRUE

///Checks if the machine is alloweed to make another db request yet. TRUE if so, FALSE otherwise
/obj/machinery/computer/libraryconsole/proc/prevent_db_spam()
	if(!can_db_request())
		return FALSE
	COOLDOWN_START(src, db_request_cooldown, 1 SECONDS)
	return TRUE

/obj/machinery/computer/libraryconsole/proc/can_db_request()
	if(sending_request)
		return FALSE
	if(!COOLDOWN_FINISHED(src, db_request_cooldown))
		return FALSE
	return TRUE

///Returns a santized page input, so converted from num/text to num, and properly maxed
/obj/machinery/computer/libraryconsole/proc/sanitize_page_input(input, default, max)
	if(istext(input))
		input = text2num(input)
	if(!isnum_safe(input))
		input = default + 1
	//We expect the search page to be one greater then it should be, because we're lying about indexing at 1
	return clamp(round(input) - 1, 0, max)

/obj/machinery/computer/libraryconsole/proc/update_db_info()
	if(!has_anything_changed()) //You're not allowed to make the same search twice, waste of resources
		return
	if(!SSdbcore.Connect())
		can_connect = FALSE
		page_count = 0
		page_content = list()
		return
	can_connect = TRUE
	params_changed = FALSE
	last_search_hash = hash_search_info()

	update_page_count()
	update_page_contents()
	SStgui.update_uis(src) //We need to do this because we sleep here, so we've gotta update manually

///Returns true if there's been an update worth refreshing our pages for, false otherwise
/obj/machinery/computer/libraryconsole/proc/has_anything_changed()
	if(last_search_hash == hash_search_info())
		return FALSE
	return TRUE

/obj/machinery/computer/libraryconsole/proc/hash_search_info()
	return "[book_id]-[title]-[author]-[category]-[search_page]-[page_count]"

/obj/machinery/computer/libraryconsole/proc/update_page_contents()
	if(sending_request)
		return
	sending_request = TRUE
	search_page = clamp(search_page, 0, page_count)
	var/datum/DBQuery/query_library_list_books = SSdbcore.NewQuery({"
		SELECT author, title, category, id
		FROM [format_table_name("library")]
		WHERE isnull(deleted)
			AND author LIKE CONCAT('%',:author,'%')
			AND title LIKE CONCAT('%',:title,'%')
			AND (:category = 'Any' OR category = :category)
			[book_id ? "AND id = :book_id" : ""]
		ORDER BY id DESC
		LIMIT :skip, :take
	"}, list("author" = author, "title" = title, "book_id" = book_id, "category" = category, "skip" = BOOKS_PER_PAGE * search_page, "take" = BOOKS_PER_PAGE))

	var/query_succeeded = query_library_list_books.Execute()
	sending_request = FALSE
	page_content.Cut()
	if(!query_succeeded)
		qdel(query_library_list_books)
		return
	while(query_library_list_books.NextRow())
		page_content += list(list(
			"author" = html_decode(query_library_list_books.item[1]),
			"title" = html_decode(query_library_list_books.item[2]),
			"category" = query_library_list_books.item[3],
			"id" = query_library_list_books.item[4],
		))
	qdel(query_library_list_books)

/obj/machinery/computer/libraryconsole/proc/update_page_count()
	var/bookcount = 0
	var/datum/DBQuery/query_library_count_books = SSdbcore.NewQuery({"
		SELECT COUNT(id) FROM [format_table_name("library")]
		WHERE isnull(deleted)
			AND author LIKE CONCAT('%',:author,'%')
			AND title LIKE CONCAT('%',:title,'%')
			AND (:category = 'Any' OR category = :category)
			[book_id ? "AND id = :book_id" : ""]
	"}, list("author" = author, "title" = title, "book_id" = book_id, "category" = category))

	if(!query_library_count_books.warn_execute())
		qdel(query_library_count_books)
		return
	if(query_library_count_books.NextRow())
		bookcount = text2num(query_library_count_books.item[1])
	qdel(query_library_count_books)

	page_count = round(max(bookcount - 1, 0) / BOOKS_PER_PAGE) //This is just floor()
	search_page = clamp(search_page, 0, page_count)

/*
 * Borrowbook datum
 */
/datum/borrowbook // Datum used to keep track of who has borrowed what when and for how long.
	var/bookname
	var/mobname
	var/getdate
	var/duedate

#define PRINTER_COOLDOWN 60
#define NEWSCASTER_COOLDOWN (10 SECONDS)
#define LIBRARY_NEWSFEED "Nanotrasen Book Club"
//The different states the computer can be in, only send the info we need yeah?
#define LIBRARY_INVENTORY 1
#define LIBRARY_CHECKOUT 2
#define LIBRARY_ARCHIVE 3
#define LIBRARY_UPLOAD 4
#define LIBRARY_PRINT 5
#define LIBRARY_TOP_SNEAKY 6
#define MIN_LIBRARY LIBRARY_INVENTORY
#define MAX_LIBRARY LIBRARY_TOP_SNEAKY

/*
 * Library Computer
 * After 860 days, it's finally a buildable computer.
 */
// TODO: Make this an actual /obj/machinery/computer that can be crafted from circuit boards and such
// It is August 22nd, 2012... This TODO has already been here for months.. I wonder how long it'll last before someone does something about it.
// It's December 25th, 2014, and this is STILL here, and it's STILL relevant. Kill me
/obj/machinery/computer/libraryconsole/bookmanagement
	name = "book inventory management console"
	desc = "Librarian's command station."
	verb_say = "pika"
	verb_ask = "pika"
	verb_exclaim = "pika"
	pass_flags = PASSTABLE
	interface_type = "LibraryConsole"
	///The screen we're currently on, sent to the ui
	var/screen_state = LIBRARY_INVENTORY
	///Should we show the buttons required for changing screens?
	var/show_dropdown = TRUE
	///Name of the book we're checking out, set by the barcode scanner or the UI
	var/buffer_book
	///Category used for the next archive upload
	var/upload_category = DEFAULT_UPLOAD_CATEGORY
	///List of checked out books, /datum/borrowbook
	var/list/checkouts = list()
	///The current page we're on in the checkout listing
	var/checkout_page = 0
	///List of /obj/item/book in our inventory (filled by the barcode scanner)
	var/list/inventory = list()
	///The current page we're on in the inventory
	var/inventory_page = 0
	var/obj/machinery/libraryscanner/scanner // Book scanner that will be used when uploading books to the Archive
	var/cooldown = 0
	///Our cooldown on publishing books to the newscaster's "book club" channel
	COOLDOWN_DECLARE(newscaster_cooldown)

/obj/machinery/computer/libraryconsole/bookmanagement/Initialize(mapload)
	. = ..()
	if(circuit)
		circuit.name = "Book Inventory Management Console (Machine Board)"
		circuit.build_path = /obj/machinery/computer/libraryconsole/bookmanagement

/obj/machinery/computer/libraryconsole/bookmanagement/ui_data(mob/user)
	var/list/data = list()
	data["can_db_request"] = can_db_request()
	data["screen_state"] = screen_state
	data["show_dropdown"] = show_dropdown
	data["display_lore"] = !!(obj_flags & EMAGGED)

	switch(screen_state)
		if(LIBRARY_INVENTORY)
			for(var/obj/item/book/old_book as anything in inventory.Copy())
				if(QDELETED(old_book))
					inventory -= old_book
			inventory -= null
			var/inventory_len = length(inventory)
			var/inventory_page_count = round(max(inventory_len - 1, 0) / INVENTORY_PER_PAGE)
			inventory_page = clamp(inventory_page, 0, inventory_page_count)
			data["inventory"] = list()
			if(inventory_len)
				for(var/id in ((INVENTORY_PER_PAGE * inventory_page) + 1) to min(INVENTORY_PER_PAGE * (inventory_page + 1), inventory_len))
					var/obj/item/book/book = inventory[id]
					data["inventory"] += list(list(
						"ref" = REF(book),
						"title" = book.title || book.name,
						"author" = book.author || "Anonim",
					))
			data["has_inventory"] = !!inventory_len
			data["inventory_page"] = inventory_page + 1
			data["inventory_page_count"] = inventory_page_count + 1

		if(LIBRARY_CHECKOUT)
			var/checkout_len = length(checkouts)
			var/checkout_page_count = round(max(checkout_len - 1, 0) / CHECKOUTS_PER_PAGE)
			checkout_page = clamp(checkout_page, 0, checkout_page_count)
			data["checkouts"] = list()
			if(checkout_len)
				for(var/id in ((CHECKOUTS_PER_PAGE * checkout_page) + 1) to min(CHECKOUTS_PER_PAGE * (checkout_page + 1), checkout_len))
					var/datum/borrowbook/loan = checkouts[id]
					var/timedue = (loan.duedate - world.time) / (1 MINUTES)
					timedue = max(round(timedue, 0.1), 0)
					data["checkouts"] += list(list(
						"id" = id,
						"ref" = REF(loan),
						"borrower" = loan.mobname || "Brak",
						"overdue" = (timedue <= 0),
						"due_in_minutes" = timedue,
						"title" = loan.bookname,
						"taken_minutes" = round((world.time - loan.getdate) / (1 MINUTES)),
					))
			data["has_checkout"] = !!checkout_len
			data["checkout_page"] = checkout_page + 1
			data["checkout_page_count"] = checkout_page_count + 1
			data["checkout_title"] = buffer_book
			var/list/inventory_titles = list()
			for(var/obj/item/book/book in inventory)
				inventory_titles |= book.name
			data["inventory_titles"] = inventory_titles

		//Copypasta from the visitor console
		if(LIBRARY_ARCHIVE)
			data |= ..()

		if(LIBRARY_UPLOAD)
			data["upload_categories"] = LIBRARY_UPLOAD_CATEGORIES
			data["default_category"] = upload_category
			var/obj/machinery/libraryscanner/scan = get_scanner()
			data["has_scanner"] = !!(scan)
			data["has_cache"] = !!(scan?.cache)
			data["cooldown_string"] = "[DisplayTimeText(COOLDOWN_TIMELEFT(src, newscaster_cooldown))]"
			data["active_newscaster_cooldown"] = COOLDOWN_FINISHED(src, newscaster_cooldown)
			if(scan?.cache)
				data["cache_title"] = scan.cache.name
				data["cache_author"] = scan.cache.author || "Anonymous"
				data["cache_content"] = scan.cache.dat

		if(LIBRARY_PRINT)
			data["deity"] = GLOB.deity || "Space Jesus"
			data["religion"] = GLOB.religion || "Christianity"
			data["bible_name"] = GLOB.bible_name || "Holy Bible"
			data["printer_ready"] = cooldown < world.time

	return data

/obj/machinery/computer/libraryconsole/bookmanagement/proc/get_scanner(viewrange = 9)
	if(scanner && !QDELETED(scanner) && get_dist(get_turf(scanner), get_turf(src)) <= viewrange)
		return scanner
	scanner = locate(/obj/machinery/libraryscanner) in range(viewrange, get_turf(src))
	return scanner

/obj/machinery/computer/libraryconsole/bookmanagement/ui_act(action, params)
	//The parent call takes care of stuff like searching, don't forget about that yeah?
	. = ..()
	if(.)
		return
	switch(action)
		if("set_screen")
			set_screen_state(text2num("[params["screen_index"]]"))
			return TRUE
		if("toggle_dropdown")
			show_dropdown = !show_dropdown
			return TRUE
		if("inventory_remove")
			var/obj/item/book/book = locate(params["book_id"]) in inventory
			if(book)
				inventory -= book
			return TRUE
		if("switch_inventory_page")
			inventory_page = sanitize_page_input(params["page"], inventory_page, round(max(length(inventory) - 1, 0) / INVENTORY_PER_PAGE))
			return TRUE
		if("checkout")
			if(!buffer_book)
				return TRUE
			var/checkoutperiod = text2num("[params["checkout_time"]]")
			if(!isnum_safe(checkoutperiod))
				checkoutperiod = 5
			checkoutperiod = clamp(round(checkoutperiod), 1, 120)
			var/datum/borrowbook/loan = new /datum/borrowbook
			loan.bookname = sanitize(buffer_book)
			loan.mobname = sanitize(copytext("[params["loaned_to"]]", 1, MAX_NAME_LEN))
			loan.getdate = world.time
			loan.duedate = world.time + (checkoutperiod * 600)
			checkouts.Add(loan)
			return TRUE
		if("set_checkout")
			var/book_name = params["book_name"]
			if(!book_name)
				return
			for(var/obj/item/book/book in inventory)
				if(book.name == book_name)
					buffer_book = book.name
					return TRUE
			return
		if("checkin")
			var/datum/borrowbook/loan = locate(params["checked_out_id"]) in checkouts
			if(loan)
				checkouts -= loan
			return TRUE
		if("switch_checkout_page")
			checkout_page = sanitize_page_input(params["page"], checkout_page, round(max(length(checkouts) - 1, 0) / CHECKOUTS_PER_PAGE))
			return TRUE
		if("set_cache_author")
			var/obj/machinery/libraryscanner/scan = get_scanner()
			var/newauthor = trim(sanitize("[params["author"]]"))
			if(!scan?.cache || !newauthor)
				return
			if(length(newauthor) > 45)
				say("Nie można ustawić autora. Pole musi mieć mniej niż 45 znaków.")
				return
			scan.cache.author = newauthor
			return TRUE
		if("upload")
			if(!prevent_db_spam())
				say("Kable bazy danych się odświeżają. Chwileczkę.")
				return
			var/new_category = params["category"]
			if(!(new_category in LIBRARY_UPLOAD_CATEGORIES)) //Nice try
				new_category = DEFAULT_UPLOAD_CATEGORY
			upload_category = new_category
			INVOKE_ASYNC(src, PROC_REF(upload_from_scanner), usr)
			return TRUE
		if("news_post")
			if(!COOLDOWN_FINISHED(src, newscaster_cooldown))
				say("Od ostatniej publikacji minęło za mało czasu. Poczekaj chwilę.")
				return
			var/obj/machinery/libraryscanner/scan = get_scanner()
			if(!scan?.cache)
				say("W pamięci skanera nie znaleziono danych. Przerywanie.")
				return
			if(!GLOB.news_network)
				say("Nie znaleziono na stacji sieci informacyjnej. Przerywanie.")
				return
			var/channelexists = FALSE
			for(var/datum/feed_channel/FC in GLOB.news_network.network_channels)
				if(FC.channel_name == LIBRARY_NEWSFEED)
					channelexists = TRUE
					break
			if(!channelexists)
				GLOB.news_network.create_feed_channel(LIBRARY_NEWSFEED, "Library", null)
			GLOB.news_network.submit_article(scan.cache.dat, "[scan.cache.name]", LIBRARY_NEWSFEED, null)
			say("Wgrywanie zakończone. Twój tytuł jest teraz dostępny w stacyjnych serwisach informacyjnych.")
			COOLDOWN_START(src, newscaster_cooldown, NEWSCASTER_COOLDOWN)
			return TRUE
		if("print_book")
			var/id = text2num("[params["book_id"]]")
			if(!isnum_safe(id) || !ISINTEGER(id))
				return
			print_book(id)
			return TRUE
		if("print_bible")
			if(!printer_ready())
				return
			var/obj/item/storage/book/bible/B = new /obj/item/storage/book/bible(loc)
			if(GLOB.bible_icon_state && GLOB.bible_item_state)
				B.icon_state = GLOB.bible_icon_state
				B.item_state = GLOB.bible_item_state
				B.name = GLOB.bible_name
				B.deity_name = GLOB.deity
			return TRUE
		if("print_spacelaw")
			if(!printer_ready())
				return
			new /obj/item/book/manual/wiki/security_space_law(loc)
			return TRUE
		if("print_poster")
			if(!printer_ready())
				return
			new /obj/item/poster/random_official(loc)
			return TRUE
		if("lore_spawn")
			if(obj_flags & EMAGGED)
				print_forbidden_lore(usr)
			set_screen_state(MIN_LIBRARY)
			return TRUE
		if("lore_deny")
			set_screen_state(MIN_LIBRARY)
			return TRUE

/obj/machinery/computer/libraryconsole/bookmanagement/proc/set_screen_state(new_state)
	if(!isnum_safe(new_state))
		return
	if(new_state == LIBRARY_TOP_SNEAKY && !(obj_flags & EMAGGED))
		return
	screen_state = clamp(new_state, MIN_LIBRARY, MAX_LIBRARY)

/// Sprawdza cooldown drukarki i go uruchamia
/obj/machinery/computer/libraryconsole/bookmanagement/proc/printer_ready()
	if(cooldown > world.time)
		say("Drukarka jest obecnie niedostępna, poczekaj chwilę.")
		return FALSE
	cooldown = world.time + PRINTER_COOLDOWN
	return TRUE

/obj/machinery/computer/libraryconsole/bookmanagement/proc/upload_from_scanner(mob/user)
	var/obj/machinery/libraryscanner/scan = get_scanner()
	if(!scan)
		say("W zasięgu sieci bezprzewodowej nie znaleziono skanera.")
		return
	if(!scan.cache)
		say("W pamięci skanera nie znaleziono danych. Przerywanie.")
		return
	if(!SSdbcore.Connect())
		say("Połączenie z archiwum zostało zerwane. Przerywanie.")
		return
	if(!scan.cache.author)
		scan.cache.author = "Anonymous"
	if((length(scan.cache.name) > 45) || (length(scan.cache.author) > 45))
		say("Pola tytułu i autora mogą mieć najwyżej po 45 znaków. Sprawdź wpis i spróbuj ponownie.")
		return
	var/msg = "[key_name(user)] has uploaded the book titled [scan.cache.name], [length(scan.cache.dat)] signs"
	var/datum/DBQuery/query_library_upload = SSdbcore.NewQuery({"
		INSERT INTO [format_table_name("library")] (author, title, content, category, ckey, datetime, round_id_created)
		VALUES (:author, :title, :content, :category, :ckey, Now(), :round_id)
	"}, list("title" = scan.cache.name, "author" = scan.cache.author, "content" = scan.cache.dat, "category" = upload_category, "ckey" = user?.ckey, "round_id" = GLOB.round_id))
	if(!query_library_upload.Execute())
		qdel(query_library_upload)
		say("Napotkano błąd bazy danych podczas wgrywania do archiwum.")
		return
	log_game(msg)
	qdel(query_library_upload)
	say("Wgrywanie zakończone. Wgrany tytuł będzie przez krótki czas niedostępny do druku.")
	last_search_hash = ""
	update_db_info()

/obj/machinery/computer/libraryconsole/bookmanagement/proc/print_book(id)
	if(cooldown > world.time)
		say("Drukarka niedostępna. Odczekaj chwilę przed ponowną próbą druku.")
		return
	if(!SSdbcore.Connect())
		say("Połączenie z archiwum zostało zerwane. Przerywanie.")
		can_connect = FALSE
		return
	cooldown = world.time + PRINTER_COOLDOWN
	var/datum/DBQuery/query_library_print = SSdbcore.NewQuery(
		"SELECT * FROM [format_table_name("library")] WHERE id=:id AND isnull(deleted)",
		list("id" = id)
	)
	if(!query_library_print.Execute())
		qdel(query_library_print)
		say("BŁĄD DRUKARKI! Nie udało się wydrukować dokumentu (0x0000000F)")
		return
	while(query_library_print.NextRow())
		var/author = query_library_print.item[2]
		var/title = query_library_print.item[3]
		var/content = query_library_print.item[4]
		if(!QDELETED(src))
			var/obj/item/book/B = new(get_turf(src))
			B.name = "Book: [title]"
			B.title = title
			B.author = author
			B.dat = content
			B.icon_state = "book[rand(1,8)]"
			visible_message("Drukarka [src] buczy, wytwarzając całkowicie oprawioną książkę. Jak ona to zrobiła?")
		break
	qdel(query_library_print)

/obj/machinery/computer/libraryconsole/bookmanagement/proc/print_forbidden_lore(mob/user)
	switch(rand(1,3))
		if(1)
			new /obj/item/melee/cultblade/dagger(get_turf(src))
			to_chat(user, "<span class='warning'>Twój umysł ledwo wytrzymuje sekundy spędzone w oknie przeglądania skarbca. Gdy przestajesz przeglądać, jedynym, co ci o tym przypomina, jest złowieszczy sztylet leżący na biurku. Nawet nie pamiętasz, skąd się wziął...</span>")
		if(2)
			new /obj/item/clockwork/clockwork_slab(get_turf(src))
			to_chat(user, "<span class='warning'>Twój umysł ledwo wytrzymuje sekundy spędzone w oknie przeglądania skarbca. Gdy przestajesz przeglądać, jedynym, co ci o tym przypomina, jest dziwna metalowa tabliczka leżąca na biurku. Nawet nie pamiętasz, skąd się wzięła...</span>")
		if(3)
			new /obj/item/codex_cicatrix(get_turf(src))
			to_chat(user, "<span class='warning'>Twój umysł ledwo wytrzymuje sekundy spędzone w oknie przeglądania skarbca. Gdy przestajesz przeglądać, jedynym, co ci o tym przypomina, jest złowróżbna księga skuta łańcuchem, leżąca na biurku. Nawet nie pamiętasz, skąd się wzięła...</span>")
	user.visible_message("[user] przez kilka chwil wpatruje się w pusty ekran z twarzą zastygłą w strachu. Gdy w końcu się z tego budzi, wygląda na znacznie starszego.", 2)

/obj/machinery/computer/libraryconsole/bookmanagement/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/barcodescanner))
		var/obj/item/barcodescanner/scanner = W
		scanner.computer = src
		to_chat(user, "Powiązaną maszyną [scanner] jest teraz [src].")
		audible_message("[src] wydaje niski, krótki pisk.")
	else
		return ..()

/obj/machinery/computer/libraryconsole/bookmanagement/emag_act(mob/user)
	if(density && !(obj_flags & EMAGGED))
		obj_flags |= EMAGGED

/*
 * Admin library console (tg LibraryAdmin)
 * Konsola w nullspace otwierana werbem admina "Library Management", zastępuje stary "Delete Book".
 * AQUILA: bez historii akcji (nie mamy tabeli library_action), powód ukrycia/przywrócenia idzie do logów admina.
 */
/obj/machinery/computer/libraryconsole/admin_only_do_not_map_in_you_fucker
	name = "admin library console"
	interface_type = "LibraryAdmin"
	/// If we should show deleted entries or not
	var/show_deleted = TRUE
	/// The current ckey we're looking for
	var/ckey = ""

/obj/machinery/computer/libraryconsole/admin_only_do_not_map_in_you_fucker/can_db_request()
	if(sending_request)
		return FALSE
	return TRUE

/obj/machinery/computer/libraryconsole/admin_only_do_not_map_in_you_fucker/hash_search_info()
	. = ..()
	return "[.]-[ckey]-[show_deleted]"

/obj/machinery/computer/libraryconsole/admin_only_do_not_map_in_you_fucker/update_page_contents()
	if(sending_request) //Final defense against nerds spamming db requests
		return
	sending_request = TRUE
	search_page = clamp(search_page, 0, page_count)
	var/datum/DBQuery/query_library_list_books = SSdbcore.NewQuery({"
		SELECT id, author, title, category, ckey, deleted
		FROM [format_table_name("library")]
		WHERE author LIKE CONCAT('%',:author,'%')
			[show_deleted ? "" : "AND isnull(deleted)"]
			AND title LIKE CONCAT('%',:title,'%')
			AND (:category = 'Any' OR category = :category)
			[book_id ? "AND id = :book_id" : ""]
			AND ckey LIKE CONCAT('%',:ckey,'%')
		ORDER BY id DESC
		LIMIT :skip, :take
	"}, list("author" = author, "title" = title, "book_id" = book_id, "category" = category, "ckey" = ckey, "skip" = BOOKS_PER_PAGE * search_page, "take" = BOOKS_PER_PAGE))

	var/query_succeeded = query_library_list_books.Execute()
	sending_request = FALSE
	page_content.Cut()
	if(!query_succeeded)
		qdel(query_library_list_books)
		return
	while(query_library_list_books.NextRow())
		page_content += list(list(
			"id" = query_library_list_books.item[1],
			"author" = html_decode(query_library_list_books.item[2]),
			"title" = html_decode(query_library_list_books.item[3]),
			"category" = query_library_list_books.item[4],
			"author_ckey" = query_library_list_books.item[5],
			"deleted" = query_library_list_books.item[6],
		))
	qdel(query_library_list_books)

/obj/machinery/computer/libraryconsole/admin_only_do_not_map_in_you_fucker/update_page_count()
	var/bookcount = 0
	var/datum/DBQuery/query_library_count_books = SSdbcore.NewQuery({"
		SELECT COUNT(id) FROM [format_table_name("library")]
		WHERE author LIKE CONCAT('%',:author,'%')
			[show_deleted ? "" : "AND isnull(deleted)"]
			AND title LIKE CONCAT('%',:title,'%')
			AND (:category = 'Any' OR category = :category)
			[book_id ? "AND id = :book_id" : ""]
			AND ckey LIKE CONCAT('%',:ckey,'%')
	"}, list("author" = author, "title" = title, "book_id" = book_id, "category" = category, "ckey" = ckey))

	if(!query_library_count_books.warn_execute())
		qdel(query_library_count_books)
		return
	if(query_library_count_books.NextRow())
		bookcount = text2num(query_library_count_books.item[1])
	qdel(query_library_count_books)

	page_count = round(max(bookcount - 1, 0) / BOOKS_PER_PAGE) //This is just floor()
	search_page = clamp(search_page, 0, page_count)

/obj/machinery/computer/libraryconsole/admin_only_do_not_map_in_you_fucker/ui_status(mob/user, datum/ui_state/state)
	if(!check_rights_for(user.client, R_ADMIN))
		return UI_CLOSE
	if(!SSdbcore.Connect())
		can_connect = FALSE
		return UI_CLOSE
	return UI_INTERACTIVE

/obj/machinery/computer/libraryconsole/admin_only_do_not_map_in_you_fucker/ui_data(mob/user)
	. = ..()
	.["show_deleted"] = show_deleted
	.["author_ckey"] = ckey

/obj/machinery/computer/libraryconsole/admin_only_do_not_map_in_you_fucker/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		// We'll always trigger a search attempt if the parent does something, this ensures the ui is v fast to update
		INVOKE_ASYNC(src, PROC_REF(update_db_info))
		return
	switch(action)
		if("set_search_ckey")
			ckey = ckey(params["ckey"])
			INVOKE_ASYNC(src, PROC_REF(update_db_info))
			return TRUE
		if("refresh")
			last_search_hash = ""
			INVOKE_ASYNC(src, PROC_REF(update_db_info))
			return TRUE
		if("hide_book")
			var/client/actor = usr?.client
			if(!actor)
				return
			INVOKE_ASYNC(src, PROC_REF(set_book_hidden), text2num("[params["book_id"]]"), "[params["reason"]]", actor, TRUE)
			return TRUE
		if("unhide_book")
			var/client/actor = usr?.client
			if(!actor)
				return
			INVOKE_ASYNC(src, PROC_REF(set_book_hidden), text2num("[params["book_id"]]"), "[params["reason"]]", actor, FALSE)
			return TRUE
		if("view_book")
			INVOKE_ASYNC(src, PROC_REF(view_book), text2num("[params["book_id"]]"), usr)
			return TRUE
		if("toggle_deleted")
			show_deleted = !show_deleted
			INVOKE_ASYNC(src, PROC_REF(update_db_info))
			return TRUE

/obj/machinery/computer/libraryconsole/admin_only_do_not_map_in_you_fucker/proc/view_book(id, mob/show_to)
	if(!id || !SSdbcore.Connect())
		return
	var/datum/DBQuery/query_library_view = SSdbcore.NewQuery(
		"SELECT author, title, content FROM [format_table_name("library")] WHERE id=:id",
		list("id" = id)
	)
	if(!query_library_view.Execute())
		qdel(query_library_view)
		return
	if(query_library_view.NextRow())
		var/datum/admin_book_viewer/viewer = new()
		viewer.author = html_decode(query_library_view.item[1])
		viewer.title = "#[id]: [html_decode(query_library_view.item[2])]"
		viewer.content = query_library_view.item[3]
		viewer.ui_interact(show_to)
	qdel(query_library_view)

/// Ukrywa (hide = TRUE) albo przywraca książkę w bazie; całkowite usuwanie zostaje dla administratora bazy.
/obj/machinery/computer/libraryconsole/admin_only_do_not_map_in_you_fucker/proc/set_book_hidden(id, reason, client/admin, hide)
	if(!id)
		return
	if(!SSdbcore.Connect())
		can_connect = FALSE
		to_chat(admin, "<span class='danger'>Nie udało się połączyć z bazą danych.</span>")
		return
	if(!check_rights_for(admin, R_ADMIN))
		log_admin_private("[admin.ckey] tried to [hide ? "hide" : "unhide"] a book without the required perms")
		message_admins("[admin.ckey] tried to [hide ? "hide" : "unhide"] a book without the required perms")
		return

	var/datum/DBQuery/query_hide_book = SSdbcore.NewQuery({"
		UPDATE [format_table_name("library")]
		SET deleted = [hide ? "1" : "NULL"]
		WHERE id = :id
	"}, list("id" = id))
	if(!query_hide_book.warn_execute())
		qdel(query_hide_book)
		return
	qdel(query_hide_book)

	reason = trim(reason)
	var/log_text = "[key_name(admin)] [hide ? "deleted" : "restored"] book number [id][reason ? ": \"[reason]\"" : ""]"
	message_admins(log_text)
	log_admin(log_text)
	last_search_hash = ""
	update_db_info()

/// Podgląd treści książki z bazy dla admina (okno BookViewer)
/datum/admin_book_viewer
	var/author
	var/title
	var/content

/datum/admin_book_viewer/ui_status(mob/user, datum/ui_state/state)
	if(!check_rights_for(user.client, R_ADMIN))
		return UI_CLOSE
	return UI_INTERACTIVE

/datum/admin_book_viewer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BookViewer", title)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/admin_book_viewer/ui_close(mob/user)
	. = ..()
	qdel(src)

/datum/admin_book_viewer/ui_data(mob/user)
	var/list/data = list()
	data["title"] = title
	data["author"] = author
	data["content"] = content
	return data

#undef PRINTER_COOLDOWN
#undef NEWSCASTER_COOLDOWN
#undef LIBRARY_NEWSFEED
#undef LIBRARY_INVENTORY
#undef LIBRARY_CHECKOUT
#undef LIBRARY_ARCHIVE
#undef LIBRARY_UPLOAD
#undef LIBRARY_PRINT
#undef LIBRARY_TOP_SNEAKY
#undef MIN_LIBRARY
#undef MAX_LIBRARY
#undef BOOKS_PER_PAGE
#undef INVENTORY_PER_PAGE
#undef CHECKOUTS_PER_PAGE
#undef DEFAULT_SEARCH_CATEGORY
#undef DEFAULT_UPLOAD_CATEGORY
#undef LIBRARY_SEARCH_CATEGORIES
#undef LIBRARY_UPLOAD_CATEGORIES

/*
 * Library Scanner
 */
/obj/machinery/libraryscanner
	name = "scanner control interface"
	icon = 'icons/obj/library.dmi'
	icon_state = "bigscanner"
	desc = "It servers the purpose of scanning stuff."
	density = TRUE
	var/obj/item/book/cache		// Last scanned book

/obj/machinery/libraryscanner/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/book))
		if(!user.transferItemToLoc(O, src))
			return
		ui_update()
	else
		return ..()

/obj/machinery/libraryscanner/Destroy()
	cache = null
	return ..()

/obj/machinery/libraryscanner/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LibraryScanner")
		ui.open()

/obj/machinery/libraryscanner/ui_data(mob/user)
	var/list/data = list()
	var/list/cached_info = list()
	data["has_book"] = !!(locate(/obj/item/book) in contents)
	data["has_cache"] = !!cache
	if(cache)
		cached_info["title"] = cache.title || cache.name
		cached_info["author"] = cache.author || "Anonim"
	data["book"] = cached_info
	return data

/obj/machinery/libraryscanner/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("scan")
			for(var/obj/item/book/B in contents)
				cache = B
				break
			return TRUE
		if("clear")
			cache = null
			return TRUE
		if("eject")
			for(var/obj/item/book/B in contents)
				B.forceMove(drop_location())
			return TRUE


/*
 * Book binder
 */
/obj/machinery/bookbinder
	name = "book binder"
	icon = 'icons/obj/library.dmi'
	icon_state = "binder"
	desc = "Only intended for binding paper products."
	density = TRUE
	var/busy = FALSE

/obj/machinery/bookbinder/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/paper))
		bind_book(user, O)
	else if(default_unfasten_wrench(user, O))
		return 1
	else
		return ..()

/obj/machinery/bookbinder/proc/bind_book(mob/user, obj/item/paper/P)
	if(machine_stat)
		return
	if(busy)
		to_chat(user, "<span class='warning'>Introligatornia jest zajęta. Poczekaj na zakończenie poprzedniej operacji.</span>")
		return
	if(!user.transferItemToLoc(P, src))
		return
	user.visible_message("[user] ładuje trochę papieru do [src].", "Ładujesz trochę papieru do [src].")
	audible_message("[src] zaczyna buczeć, rozgrzewając bębny drukujące.")
	busy = TRUE
	sleep(rand(200,400))
	busy = FALSE
	if(P)
		if(!machine_stat)
			visible_message("[src] furczy, drukując i oprawiając nową książkę.")
			var/obj/item/book/B = new(src.loc)
			var/raw_content = ""
			for(var/datum/paper_input/text_input as anything in P.raw_text_inputs)
				raw_content += sanitize(text_input.raw_text)

			B.dat = trim(raw_content, MAX_PAPER_LENGTH)
			B.name = "Print Job #" + "[rand(100, 999)]"
			B.icon_state = "book[rand(1,7)]"
			qdel(P)
		else
			P.forceMove(drop_location())
