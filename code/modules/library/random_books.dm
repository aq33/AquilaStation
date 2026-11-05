/obj/item/book/manual/random
	icon_state = "random_book"

/obj/item/book/manual/random/Initialize(mapload)
	..()
	var/static/banned_books = list(/obj/item/book/manual/random, /obj/item/book/manual/nuclear, /obj/item/book/manual/wiki)
	var/newtype = pick(subtypesof(/obj/item/book/manual) - banned_books)
	new newtype(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/book/random
	icon_state = "random_book"
	/// The category of books to pick from when creating this book.
	var/random_category = null
	/// If this book has already been 'generated' yet.
	var/random_loaded = FALSE

/obj/item/book/random/Initialize(mapload)
	. = ..()
	icon_state = "book[rand(1,8)]"

/obj/item/book/random/attack_self()
	if(!random_loaded)
		create_random_books(1, loc, TRUE, random_category, src)
		random_loaded = TRUE
	return ..()

/obj/structure/bookcase/random
	load_random_books = TRUE
	books_to_load = 2
	icon_state = "random_bookcase"

/obj/structure/bookcase/random/Initialize(mapload)
	. = ..()
	if(books_to_load && isnum_safe(books_to_load))
		books_to_load += pick(-1,-1,0,1,1)
	update_icon()

/proc/create_random_books(amount, location, fail_loud = FALSE, category = null, obj/item/book/existing_book)
	. = list()
	if(!isnum_safe(amount) || amount<1)
		return
	if (!SSdbcore.Connect())
		if(existing_book && (fail_loud || prob(5)))
			existing_book.author = "???"
			existing_book.title = "Dziwna książka"
			existing_book.name = "Dziwna książka"
			existing_book.dat = "Była raz książka z Nantucket,<br>lecz baza danych padła, więc kuźwa, nie ma jej.<br>Chciałem być dla ciebie miły,<br>a dostajesz tylko kwit dłużny.<br>Jak ci się nie podoba, to trudno!<br><br><font color='gray'>~</font>"
		return
	if(prob(25))
		category = null
	var/datum/DBQuery/query_get_random_books = SSdbcore.NewQuery({"
		SELECT author, title, content
		FROM [format_table_name("library")]
		WHERE isnull(deleted) AND (:category IS NULL OR category = :category)
		ORDER BY rand() LIMIT :limit
	"}, list("category" = category, "limit" = amount))
	if(query_get_random_books.Execute())
		while(query_get_random_books.NextRow())
			var/obj/item/book/B
			B = existing_book ? existing_book : new(location)
			B.author	=	query_get_random_books.item[1]
			B.title		=	query_get_random_books.item[2]
			B.dat		=	query_get_random_books.item[3]
			B.name		=	"Książka: [B.title]"
			if(!existing_book)
				B.icon_state=	"book[rand(1,8)]"
	qdel(query_get_random_books)

/obj/structure/bookcase/random/fiction
	name = "regał na książki (beletrystyka)"
	random_category = "Fiction"
/obj/structure/bookcase/random/nonfiction
	name = "regał na książki (literatura faktu)"
	random_category = "Non-fiction"
/obj/structure/bookcase/random/religion
	name = "regał na książki (religia)"
	random_category = "Religion"
/obj/structure/bookcase/random/adult
	name = "regał na książki (dla dorosłych)"
	random_category = "Adult"

/obj/structure/bookcase/random/reference
	name = "regał na książki (źródła)"
	random_category = "Reference"
	var/ref_book_prob = 20

/obj/structure/bookcase/random/reference/Initialize(mapload)
	. = ..()
	while(books_to_load > 0 && prob(ref_book_prob))
		books_to_load--
		new /obj/item/book/manual/random(src)
