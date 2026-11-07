// Geometria cieni latarek: trójkąty cienia za nieprzezroczystym kaflem, widziane ze środka kafla światła.
// Czysta matematyka (bez typów gry), żeby dało się ją sprawdzić w małym projekcie BYOND.
//
// Cień kafla = suma cieni jego tylnych ścian (odwróconych od światła). Cień ściany AB to czworokąt
// A, B, Pb, Pa, gdzie P to punkt na promieniu od światła przez wierzchołek, w odległości reach (koniec plamy światła).
// Czworokąt to dwa trójkąty z jedną ikoną trójkąta prostokątnego rozciągniętą macierzą (transform jest afiniczny,
// więc trójkąt w trójkąt przechodzi dokładnie). Obie połówki mają przekątną A–Pb jako przeciwprostokątną,
// a ikona wychodzi kilka pikseli poza krawędzie, więc między trójkątami nie ma szczelin.

/// Bok trójkąta w ikonie (aquila/icons/effects/light_shadow.dmi, stan "tri"), w pikselach
#define AQ_SHADOW_TRI_SIZE 256
/// Margines wypełnienia poza przyprostokątnymi; cała ikona ma AQ_SHADOW_TRI_SIZE + 2 * margines
#define AQ_SHADOW_TRI_MARGIN 4

/// Macierze trójkątów cienia kafla przesuniętego o (dx, dy) kafli od kafla światła.
/// Współrzędne względem środka kafla światła; nakładka leży na obiekcie w kaflu światła.
/// hidden_faces: bity ścian (1 dół, 2 prawo, 4 góra, 8 lewo) stykających się z innym nieprzezroczystym kaflem.
/// Takie ściany nie rzucają cienia: ich cień leży w sąsiedzie, a ciemniłby jego oświetlony bok.
/// reach: odległość końca cienia od światła w pikselach. Maska cieni jest wspólna dla wszystkich świateł ruchomych,
/// więc cień dłuższy niż plama tego światła wycinałby światło innych latarek dalej.
/proc/aq_light_shadow_matrices(dx, dy, hidden_faces = 0, reach = AQ_SHADOW_REACH)
	. = list()
	if(!dx && !dy)
		return
	var/cx = dx * world.icon_size
	var/cy = dy * world.icon_size
	var/half = world.icon_size / 2
	// wierzchołki przeciwnie do ruchu wskazówek: lewy dolny, prawy dolny, prawy górny, lewy górny
	var/list/corner_x = list(cx - half, cx + half, cx + half, cx - half)
	var/list/corner_y = list(cy - half, cy - half, cy + half, cy + half)
	// normalne ścian i -> i+1: dół, prawo, góra, lewo
	var/static/list/normal_x = list(0, 1, 0, -1)
	var/static/list/normal_y = list(-1, 0, 1, 0)
	for(var/i in 1 to 4)
		if(hidden_faces & (1 << (i - 1)))
			continue
		var/next = (i % 4) + 1
		var/ax = corner_x[i]
		var/ay = corner_y[i]
		var/bx = corner_x[next]
		var/by = corner_y[next]
		// ściana odwrócona od światła (światło w 0,0)
		if(normal_x[i] * (ax + bx) + normal_y[i] * (ay + by) <= 0)
			continue
		var/a_len = sqrt(ax * ax + ay * ay)
		var/b_len = sqrt(bx * bx + by * by)
		// koniec cienia zawsze za ścianą, nawet gdy ściana leży na brzegu plamy
		var/a_reach = max(reach, a_len + world.icon_size)
		var/b_reach = max(reach, b_len + world.icon_size)
		var/pax = ax / a_len * a_reach
		var/pay = ay / a_len * a_reach
		var/pbx = bx / b_len * b_reach
		var/pby = by / b_len * b_reach
		// kąt prosty w B i w Pa, przeciwprostokątna A–Pb w obu
		. += aq_shadow_triangle_matrix(bx, by, ax, ay, pbx, pby)
		. += aq_shadow_triangle_matrix(pax, pay, pbx, pby, ax, ay)

/// Macierz, która kładzie trójkąt z ikony (kąt prosty w lewym dolnym rogu) na trójkąt P0, P1, P2:
/// lewy dolny róg -> P0, prawy dolny -> P1, lewy górny -> P2
/proc/aq_shadow_triangle_matrix(x0, y0, x1, y1, x2, y2)
	var/size = AQ_SHADOW_TRI_SIZE
	var/a = (x1 - x0) / size
	var/d = (y1 - y0) / size
	var/b = (x2 - x0) / size
	var/e = (y2 - y0) / size
	// transform działa wokół środka ikony, a duża ikona leży lewym dolnym rogiem na kaflu,
	// więc jej środek jest o (pół ikony - pół kafla) od środka kafla
	var/icon_half = size / 2 + AQ_SHADOW_TRI_MARGIN
	var/center_offset = icon_half - world.icon_size / 2
	// wierzchołek kąta prostego w ikonie: (-size/2, -size/2) względem środka ikony
	var/c = x0 + (a + b) * size / 2 - center_offset
	var/f = y0 + (d + e) * size / 2 - center_offset
	return matrix(a, b, c, d, e, f)
