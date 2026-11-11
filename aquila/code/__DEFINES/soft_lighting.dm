// Miękkie światło i poświata świecących rzeczy (aquila/code/modules/lighting/soft_lighting.dm)

/// Poświata emisyjnych, nad płaszczyzną światła i latarek. Plane musi być liczbą całkowitą,
/// więc zajmuje nieużywany BYOND_LIGHTING_PLANE (19, nikt na nim nie rysuje i nie ma plane mastera).
#define AQ_EMISSIVE_GLOW_PLANE BYOND_LIGHTING_PLANE

/// Rozmycie płaszczyzny światła w pikselach świata (kafel = 32 px).
/// Od 8 px filtr blur na 516 robi ostre prostokątne krawędzie zamiast gładkich (sprawdzone na zrzutach), więc 6.
#define AQ_SOFT_LIGHTING_BLUR 6

/// Poziomy poświaty w preferencjach (/datum/preferences/var/glow_level)
#define AQ_GLOW_OFF 0
#define AQ_GLOW_LOW 1
#define AQ_GLOW_MEDIUM 2
#define AQ_GLOW_HIGH 3

/// Długość promieni (radial_blur, ułamek odległości od środka ekranu). Paradise ma 0.035.
#define AQ_GLARE_SIZE 0.035

/// Cienie latarek (aquila/code/modules/lighting/light_shadows.dm): nierysowana płaszczyzna obiektów z trójkątami cienia
/// (każdy ma własny render_target, maskę swojej latarki). 11 jest wolne (między BLACKNESS_PLANE a EMISSIVE_BLOCKER_PLANE).
#define AQ_LIGHT_SHADOW_PLANE 11
/// Domyślny zasięg trójkąta cienia od światła (dalej niż największe światło ruchome, 6 kafli + przesunięcie stożka).
/// Komponent podaje własny, krótszy zasięg: koniec swojej plamy światła.
#define AQ_SHADOW_REACH (12 * 32)
