import { setDictionary, translateHtml } from './i18n';

// Mały słownik w formacie z tools/i18n/build_chat_dict.py
const DICTIONARY = {
  version: 1,
  exact: {
    'skrzynka narzędziowa': 'toolbox',
    robustuje: 'robusts',
    'w klatkę piersiową': 'in the chest',
    'Za mało paliwa.': 'There is not enough fuel.',
    'trzęsie się!': 'jiggles!',
  },
  templates: [
    [
      'używając',
      ['', ' ', ' ', '', ', używając ', '!'],
      ['', [0], ' ', [1], ' ', [2], [3], ' with ', [4, 'the'], '!'],
    ],
    [
      'zamyka',
      ["<span class='notice'>", ' zamyka się sama.</span>'],
      ["<span class='notice'>", [0, 'The'], ' closes on its own.</span>'],
    ],
    [
      'widzisz',
      ["<span class='emote'>Widzisz, jak <b>", '</b>', '', '</span>'],
      ["<span class='emote'><b>", [0], '</b>', [1], [2], '</span>'],
    ],
    // [weapon] [harmful ? "wbija się w kończynę" : "przykleja się do kończyny"] [victim] ([strefa])!
    [
      ['kończynę', 'przykleja'],
      ["<span class='danger'>", ' ', ' ', ' (', ')!</span>'],
      [
        "<span class='danger'>",
        [0],
        ' ',
        ['?', 1, ['embeds', 'sticks']],
        ' itself ',
        ['?', 1, ['in', 'to']],
        ' ',
        [2],
        "'s ",
        [3],
        '!</span>',
      ],
      { '1': ['wbija się w kończynę', 'przykleja się do kończyny'] },
    ],
  ],
};

describe('translateHtml', () => {
  beforeEach(() => setDictionary(DICTIONARY as any));
  afterAll(() => setDictionary(null));

  it('tłumaczy szablon i dzieli wielowyrazowe imiona', () => {
    expect(
      translateHtml(
        "<span class='danger'>Ewelina Marek robustuje Tekla Kubacka w klatkę piersiową, używając skrzynka narzędziowa!</span>",
      ),
    ).toBe(
      "<span class='danger'>Ewelina Marek robusts Tekla Kubacka in the chest with the toolbox!</span>",
    );
  });

  it('dodaje przedimek tylko przed nazwą pospolitą', () => {
    expect(
      translateHtml(
        "<span class='notice'>skrzynka narzędziowa zamyka się sama.</span>",
      ),
    ).toBe("<span class='notice'>The toolbox closes on its own.</span>");
    expect(
      translateHtml("<span class='notice'>Bob zamyka się sama.</span>"),
    ).toBe("<span class='notice'>Bob closes on its own.</span>");
  });

  it('tłumaczy stały tekst w węźle i wartość złożoną', () => {
    expect(translateHtml("<span class='warning'>Za mało paliwa.</span>")).toBe(
      "<span class='warning'>There is not enough fuel.</span>",
    );
    expect(
      translateHtml(
        "<span class='emote'>Widzisz, jak <b>młody szlam</b> trzęsie się!</span>",
      ),
    ).toBe("<span class='emote'><b>młody szlam</b> jiggles!</span>");
  });

  it('nie rusza nieznanego tekstu', () => {
    const html = "<span class='notice'>Coś zupełnie nowego.</span>";
    expect(translateHtml(html)).toBe(html);
  });

  it('wybiera gałąź warunku według polskiej alternatywy', () => {
    expect(
      translateHtml(
        "<span class='danger'>skrzynka narzędziowa przykleja się do kończyny Jan Kowalski (klatka piersiowa)!</span>",
      ),
    ).toBe(
      "<span class='danger'>toolbox sticks itself to Jan Kowalski's klatka piersiowa!</span>",
    );
  });

  it('tłumaczy linie examine sklejone znakiem nowej linii', () => {
    // run_examinate: EXAMINE_BLOCK(jointext(examine(), "\n"))
    expect(
      translateHtml(
        "<div class='examine_block'>Za mało paliwa.\n<span class='notice'>skrzynka narzędziowa zamyka się sama.</span>\nNieznana linia.</div>",
      ),
    ).toBe(
      "<div class='examine_block'>There is not enough fuel.\n<span class='notice'>The toolbox closes on its own.</span>\nNieznana linia.</div>",
    );
  });

  it('nazwy: wielkość litery, przedimek, lista i dopisek w nawiasie', () => {
    // okna piszą nazwy małą literą, BYOND dokleja "the"
    expect(translateHtml('Skrzynka narzędziowa')).toBe('Toolbox');
    expect(translateHtml('the skrzynka narzędziowa')).toBe('the toolbox');
    // english_list po polsku i nazwa z dopiskiem jako wartość szablonu
    expect(
      translateHtml(
        "<span class='notice'>skrzynka narzędziowa (skrzynka narzędziowa) zamyka się sama.</span>",
      ),
    ).toBe(
      "<span class='notice'>The toolbox (toolbox) closes on its own.</span>",
    );
  });

  it('nie tłumaczy tego, co powiedział gracz', () => {
    const html =
      "<span class='game say'><span class='name'>Jan</span> <span class='message'>mówi, \"skrzynka narzędziowa\"</span></span>";
    expect(translateHtml(html)).toBe(html);
  });

  it('nie bierze kluczy z prototypu Object', () => {
    expect(translateHtml('constructor')).toBe('constructor');
    expect(translateHtml('<b>toString</b>')).toBe('<b>toString</b>');
  });

  it('bez słownika zwraca oryginał', () => {
    setDictionary(null);
    expect(translateHtml('Za mało paliwa.')).toBe('Za mało paliwa.');
  });
});
