/**
 * Cache spritesheetów między rundami (port tgstation/tgstation#63503, #80522, #80601 w wersji bez przepisywania podtypów).
 *
 * Składanie arkuszy przy każdym starcie zajmowało ~10 z 13-14 s SSassets. Z włączonym CACHE_ASSETS gotowy PNG,
 * CSS (z adresami jako %nazwa%) i opis arkusza lądują w tmp/assets/<klucz wersji kodu>, a kolejny start tej samej
 * wersji tylko je wczytuje: New() pomija register() podtypu. Klucz to commit z GLOB.revdata i test merge'e, więc
 * aktualizacja kodu zawsze składa arkusze od nowa; bez znanego commitu cache jest wyłączony. Lokalnie zostaw
 * CACHE_ASSETS wyłączone: zmiany ikon bez commitu nie zmieniają klucza.
 *
 * Opis arkusza (JSON) zapisuje się ostatni i trzyma hashe CSS i każdego PNG, więc przerwany zapis albo uszkodzony
 * plik daje zwykłe złożenie arkusza od nowa, a nie brakujące ikony. Odczyt najpierw sprawdza wszystko, dopiero potem
 * rejestruje assety, żeby nieudany odczyt nie zostawiał w SSassets plików pod nazwami, które zaraz zbuduje register().
 *
 * Arkusz, który zależy od stanu świata albo configu, ustawia aq_cross_round_cachable = FALSE.
 */

#define AQ_ASSET_CACHE_ROOT "tmp/assets/"

/datum/config_entry/flag/cache_assets
	default = FALSE

/datum/asset/spritesheet
	/// Can this sheet be read from the cache of an earlier round on the same code version (see CACHE_ASSETS)
	var/aq_cross_round_cachable = TRUE
	/// PNG asset names registered from the cache; null when the sheet was built normally
	var/list/aq_cached_files
	/// CSS made by the last generate_css(), so writing the cache does not build it a second time
	var/aq_last_css

/// Gatunki do wyboru pochodzą z configu (ROUNDSTART_RACES), który zmienia się bez zmiany kodu
/datum/asset/spritesheet/species
	aq_cross_round_cachable = FALSE

/// Cache folder of this code version, or null when the version is unknown (no commit) or the config is off
/proc/aq_asset_cache_folder()
	var/static/folder
	var/static/checked = FALSE
	if(checked)
		return folder
	// GLOB.revdata powstaje w world/New() po wczytaniu configu: wcześniej nic nie zapamiętujemy
	if(!GLOB.revdata)
		return null
	checked = TRUE
	if(!CONFIG_GET(flag/cache_assets) || !GLOB.revdata.commit)
		return null
	var/key = GLOB.revdata.commit
	for(var/datum/tgs_revision_information/test_merge/merge in GLOB.revdata.testmerge)
		key += "+[merge.number]:[merge.head_commit]"
	folder = "[AQ_ASSET_CACHE_ROOT][copytext(md5(key), 1, 13)]/"
	// Arkusze starszych wersji kodu tylko zajmują miejsce
	for(var/old in flist(AQ_ASSET_CACHE_ROOT))
		if("[AQ_ASSET_CACHE_ROOT][old]" != folder)
			fdel("[AQ_ASSET_CACHE_ROOT][old]")
	return folder

/datum/asset/spritesheet/proc/aq_cache_file(suffix)
	var/folder = aq_asset_cache_folder()
	return folder && "[folder]spritesheet.[name][suffix]"

/datum/asset/spritesheet/New()
	if(name && aq_cross_round_cachable && aq_read_cache())
		GLOB.asset_datums[type] = src
		return
	return ..()

/datum/asset/spritesheet/register()
	. = ..()
	if(name && aq_cross_round_cachable && aq_asset_cache_folder())
		aq_write_cache()
	aq_last_css = null

/datum/asset/spritesheet/generate_css()
	. = ..()
	aq_last_css = .

/datum/asset/spritesheet/send(client/C)
	. = ..()
	if(. && length(aq_cached_files))
		SSassets.transport.send_assets(C, aq_cached_files)

/datum/asset/spritesheet/get_url_mappings()
	. = ..()
	if(islist(.))
		for(var/asset_name in aq_cached_files)
			.[asset_name] = SSassets.transport.get_asset_url(asset_name)

/// Writes the built sheet: PNG per size, CSS with %asset% in place of the URLs, then the description with all hashes
/datum/asset/spritesheet/proc/aq_write_cache()
	var/css = aq_last_css || generate_css()
	var/list/png_hashes = list()
	for(var/size_id in sizes)
		var/asset_name = "[name]_[size_id].png"
		var/datum/asset_cache_item/item = SSassets.cache[asset_name]
		if(!item)
			return
		var/png = aq_cache_file("_[size_id].png")
		fdel(png)
		fcopy(item.resource, png)
		png_hashes[asset_name] = rustg_hash_file(RUSTG_HASH_MD5, png)
		css = replacetext(css, "url('[SSassets.transport.get_asset_url(asset_name)]')", "url('%[asset_name]%')")
	rustg_file_write(css, aq_cache_file(".css"))
	// Opis na końcu: bez niego (albo z innym hashem CSS i PNG) aq_read_cache() składa arkusz od nowa
	rustg_file_write(json_encode(list(
		"sprites" = sprites,
		"css_md5" = md5(css),
		"files" = png_hashes,
	)), aq_cache_file(".json"))

/// Registers the sheet from the cache. FALSE when there is no complete, intact cache, then the sheet is built normally.
/datum/asset/spritesheet/proc/aq_read_cache()
	var/css_file = aq_cache_file(".css")
	var/data_file = aq_cache_file(".json")
	if(!css_file || !fexists(css_file) || !fexists(data_file))
		return FALSE
	var/list/data
	try
		data = json_decode(file2text(data_file))
	catch
		return FALSE
	var/css = file2text(css_file)
	if(!islist(data) || !islist(data["sprites"]) || !islist(data["files"]) || !length(css) || md5(css) != data["css_md5"])
		return FALSE
	// Najpierw sprawdzenie wszystkiego, rejestracja dopiero na końcu
	var/list/png_hashes = data["files"]
	var/list/placeholders = list() // "url('%asset%')" -> asset name
	var/regex/placeholder = regex(@"url\('%(.+?)%'\)", "g")
	while(placeholder.Find(css))
		placeholders[placeholder.match] = placeholder.group[1]
	if(length(placeholders) != length(png_hashes))
		return FALSE
	for(var/match in placeholders)
		var/asset_name = placeholders[match]
		var/png = aq_cache_file("_[copytext(asset_name, length(name) + 2)]") // "<name>_32x32.png" -> "_32x32.png"
		if(!png_hashes[asset_name] || !fexists(png) || rustg_hash_file(RUSTG_HASH_MD5, png) != png_hashes[asset_name])
			return FALSE
	var/list/files = list()
	for(var/match in placeholders)
		var/asset_name = placeholders[match]
		var/png = aq_cache_file("_[copytext(asset_name, length(name) + 2)]")
		var/datum/asset_cache_item/item = SSassets.transport.register_asset(asset_name, png, png_hashes[asset_name])
		css = replacetext(css, match, "url('[SSassets.transport.get_asset_url(asset_name, item)]')")
		files += asset_name
	var/css_name = "spritesheet_[name].css"
	var/temp_css = "data/spritesheets/[css_name]"
	fdel(temp_css)
	text2file(css, temp_css)
	SSassets.transport.register_asset(css_name, fcopy_rsc(temp_css))
	fdel(temp_css)
	sprites = data["sprites"]
	aq_cached_files = files
	return TRUE

#undef AQ_ASSET_CACHE_ROOT
