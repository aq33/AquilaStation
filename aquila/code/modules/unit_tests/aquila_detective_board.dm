// Makra asercji z upstreamu są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc ten test ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - port tgstation/tgstation#85609: zdjęta tablica oddaje przypięte dowody, a usunięty dowód znika z połączeń
/datum/unit_test/aquila_detective_board

/datum/unit_test/aquila_detective_board/Run()
	var/obj/structure/detectiveboard/board = allocate(/obj/structure/detectiveboard, run_loc_floor_bottom_left)
	var/obj/item/paper/note = allocate(/obj/item/paper)
	var/obj/item/photo/photo = allocate(/obj/item/photo)
	note.forceMove(board)
	photo.forceMove(board)
	var/datum/case/case = new("Sprawa testowa", "red")
	board.cases += case
	var/datum/evidence/first = new("kartka", "opis", note)
	var/datum/evidence/second = new("zdjęcie", "opis", photo)
	case.evidences += list(first, second)
	case.notices = 2
	first.connections += second
	second.connections += first
	board.update_appearance(UPDATE_ICON)
	TEST_ASSERT_EQUAL(board.icon_state, "nboard02", "The board icon does not show two notices")
	TEST_ASSERT_EQUAL(second.evidence_type, "photo", "A photo was not pinned as a photo")

	case.evidences -= first
	qdel(first)
	TEST_ASSERT(!length(second.connections), "A removed evidence stayed connected")

	var/turf/spot = board.loc
	board.deconstruct(TRUE)
	TEST_ASSERT(note.loc == spot && photo.loc == spot, "Taking the board down did not drop the pinned items")
	var/obj/item/wallframe/detectiveboard/frame = locate() in spot
	TEST_ASSERT(frame, "Taking the board down did not leave a board frame")
	qdel(frame)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
