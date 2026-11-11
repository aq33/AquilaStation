// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - aq33/AquilaStation#557: okno automatu dostaje kolor ramy ze sprite'a (window_color())
/datum/unit_test/vending_window_color

/datum/unit_test/vending_window_color/Run()
	// Space Cola jest niebieska, SnackVend czerwony: kolor musi być poprawnym "#rrggbb" z odcieniem sprite'a
	var/obj/machinery/vending/cola/cola = allocate(/obj/machinery/vending/cola)
	var/blue = cola.window_color()
	TEST_ASSERT(findtext(blue, regex(@"^#[0-9a-fA-F]{6}$")), "Space Cola dostała kolor w złym formacie: [blue]")
	var/list/blue_rgb = rgb2num(blue)
	TEST_ASSERT(blue_rgb[3] > blue_rgb[1], "Rama Space Coli nie jest niebieska: [blue]")

	var/obj/machinery/vending/snack/snack = allocate(/obj/machinery/vending/snack)
	var/red = snack.window_color()
	var/list/red_rgb = rgb2num(red)
	TEST_ASSERT(red_rgb[1] > red_rgb[3], "Rama SnackVenda nie jest czerwona: [red]")

	// Drugi automat z tym samym sprite'em bierze kolor z pamięci, a nie liczy go od nowa
	var/key = "[cola.icon]-[initial(cola.icon_state)]"
	GLOB.vending_window_colors[key] = "#123456"
	var/obj/machinery/vending/cola/second = allocate(/obj/machinery/vending/cola)
	TEST_ASSERT_EQUAL(second.window_color(), "#123456", "window_color() nie skorzystało z zapamiętanego koloru")
	GLOB.vending_window_colors -= key

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
