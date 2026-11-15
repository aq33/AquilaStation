/**
 * Cache spritesheetów między rundami (port tgstation/tgstation#63503, #80522, #80601 w wersji bez przepisywania podtypów).
 *
 * Składanie arkuszy przy każdym starcie zajmowało ~10 z 13-14 s SSassets. Z włączonym CACHE_ASSETS gotowy PNG,
 * CSS (z adresami jako %nazwa%) i lista sprite'ów lądują w tmp/assets/<klucz wersji kodu>, a kolejny start tej samej
 * wersji tylko je wczytuje: New() pomija register() podtypu. Klucz to commit z GLOB.revdata i test merge'e, więc
 * aktualizacja kodu zawsze składa arkusze od nowa; bez znanego commitu cache jest wyłączony. Lokalnie zostaw
 * CACHE_ASSETS wyłączone: zmiany ikon bez commitu nie zmieniają klucza.
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

/// Gatunki do wyboru pochodzą z configu (ROUNDSTART_RACES), który zmienia się bez zmiany kodu
/datum/asset/spritesheet/species
	aq_cross_round_cachable = FALSE

/// Cache folder of this code version, or null when the version is unknown (no commit) or the config is off
/proc/aq_asset_cache_folder()
	var/static/folder
	var/static/checked = FALSE
	if(checked)
		return folder
	checked = TRUE
	if(!CONFIG_GET(flag/cache_assets) || !GLOB.revdata?.commit)
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

/datum/asset/spritesheet/send(client/C)
	. = ..()
	if(. && length(aq_cached_files))
		SSassets.transport.send_assets(C, aq_cached_files)

/datum/asset/spritesheet/get_url_mappings()
	. = ..()
	if(islist(.))
		for(var/asset_name in aq_cached_files)
			.[asset_name] = SSassets.transport.get_asset_url(asset_name)

/// Writes the built sheet: PNG per size, CSS with %asset% in place of the URLs, sprite positions as JSON
/datum/asset/spritesheet/proc/aq_write_cache()
	var/css = generate_css()
	for(var/size_id in sizes)
		var/asset_name = "[name]_[size_id].png"
		var/datum/asset_cache_item/item = SSassets.cache[asset_name]
		if(!item)
			return
		fcopy(item.resource, aq_cache_file("_[size_id].png"))
		css = replacetext(css, "url('[SSassets.transport.get_asset_url(asset_name)]')", "url('%[asset_name]%')")
	// Dane najpierw, CSS na końcu: aq_read_cache() uznaje cache za kompletny dopiero, gdy jest CSS
	rustg_file_write(json_encode(list("sprites" = sprites)), aq_cache_file(".json"))
	rustg_file_write(css, aq_cache_file(".css"))

/// Registers the sheet from the cache. FALSE when there is no complete cache, then the sheet is built normally.
/datum/asset/spritesheet/proc/aq_read_cache()
	var/css_file = aq_cache_file(".css")
	var/data_file = aq_cache_file(".json")
	if(!css_file || !fexists(css_file) || !fexists(data_file))
		return FALSE
	var/list/data = json_decode(file2text(data_file))
	var/css = file2text(css_file)
	if(!islist(data) || !islist(data["sprites"]) || !length(css))
		return FALSE
	var/list/files = list()
	var/regex/placeholder = regex(@"url\('%(.+?)%'\)", "g")
	while(placeholder.Find(css))
		var/asset_name = placeholder.group[1]
		var/size_suffix = copytext(asset_name, length(name) + 2) // "<name>_32x32.png" -> "32x32.png"
		var/png = aq_cache_file("_[size_suffix]")
		if(!fexists(png))
			return FALSE
		var/datum/asset_cache_item/item = SSassets.transport.register_asset(asset_name, png)
		css = replacetext(css, placeholder.match, "url('[SSassets.transport.get_asset_url(asset_name, item)]')")
		files |= asset_name
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
