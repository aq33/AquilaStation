"""Import sprite'ów okrętów z Aurora.3 (icons/skybox/subcapital_ships.dmi, CC-BY-SA 3.0) do aquila/icons/overmap/antag/.

Aurora trzyma statki na klatkach 512x512; tu każdy stan jest przycinany do obrysu i kładziony na klatkę o boku
zaokrąglonym w górę do 32 px i obracany dziobem na północ (Aurora ma dziób w dół). Każdy statek to osobny plik .dmi z jednym stanem.
Użycie:  python tools/overmap_scale/import_aurora_ships.py <ścieżka do repo Aurora.3>
"""
import os
import re
import sys

from PIL import Image, PngImagePlugin

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(REPO, "aquila", "icons", "overmap", "antag")
# stan w Aurorze -> (plik i stan u nas)
SHIPS = {
    "corvette": "pirate_raider",
    "unathi_diona_freighter": "salvager_ship",
    "ranger": "hunter_ship",
}
STATE_RE = re.compile(r'state = "([^"]*)"\s*\n\s*dirs = (\d+)(?:\s*\n\s*frames = (\d+))?')


def main(aurora):
    src = os.path.join(aurora, "icons", "skybox", "subcapital_ships.dmi")
    im = Image.open(src)
    desc = im.info["Description"]
    w = int(re.search(r"width = (\d+)", desc).group(1))
    h = int(re.search(r"height = (\d+)", desc).group(1))
    cols = im.width // w
    rgba = im.convert("RGBA")
    os.makedirs(OUT, exist_ok=True)
    idx = 0
    for m in STATE_RE.finditer(desc):
        name, dirs, frames = m.group(1), int(m.group(2)), int(m.group(3) or 1)
        x, y = (idx % cols) * w, (idx // cols) * h
        idx += dirs * frames
        if name not in SHIPS:
            continue
        frame = rgba.crop((x, y, x + w, y + h))
        # Aurora rysuje statki dziobem w dół (silniki u góry), overmapa NSV ma dziób u góry
        frame = frame.crop(frame.getbbox()).rotate(180)
        side_w = -(-frame.width // 32) * 32
        side_h = -(-frame.height // 32) * 32
        canvas = Image.new("RGBA", (side_w, side_h), (0, 0, 0, 0))
        canvas.alpha_composite(frame, ((side_w - frame.width) // 2, (side_h - frame.height) // 2))
        state = SHIPS[name]
        info = PngImagePlugin.PngInfo()
        info.add_text("Description", f'# BEGIN DMI\nversion = 4.0\n\twidth = {side_w}\n\theight = {side_h}\nstate = "{state}"\n\tdirs = 1\n\tframes = 1\n# END DMI\n', zip=True)
        canvas.save(os.path.join(OUT, f"{state}.dmi"), format="PNG", pnginfo=info)
        print(state, canvas.size, "z", name, frame.size)


if __name__ == "__main__":
    main(sys.argv[1])
