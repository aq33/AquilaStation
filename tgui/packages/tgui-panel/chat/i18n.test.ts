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

  it('bez słownika zwraca oryginał', () => {
    setDictionary(null);
    expect(translateHtml('Za mało paliwa.')).toBe('Za mało paliwa.');
  });
});
