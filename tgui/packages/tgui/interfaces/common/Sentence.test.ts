import {
  calculateSentence,
  MAX_TIMER,
  PRESET_LONG,
  PRESET_SHORT,
  suggestPunishment,
} from './Sentence';

const everything = { genpop: true, gulag: true, exile: true };
const nothing = { genpop: false, gulag: false, exile: false };

describe('suggestPunishment', () => {
  it('suggests a fine for minor offences only', () => {
    const charges = [PRESET_SHORT, PRESET_SHORT];
    const total = calculateSentence(PRESET_SHORT * 2);
    expect(
      suggestPunishment({
        charges,
        total,
        facilities: everything,
        maxFine: 2000,
      }),
    ).toEqual([{ kind: 'fine', amount: 300, time: total }]);
  });

  it('caps the fine and sends a pile of offences to prison', () => {
    const charges = Array(20).fill(PRESET_SHORT);
    const [fine] = suggestPunishment({
      charges,
      total: MAX_TIMER - 1,
      facilities: everything,
      maxFine: 2000,
    });
    expect(fine).toMatchObject({ kind: 'genpop' });
    const [small] = suggestPunishment({
      charges: [PRESET_SHORT],
      total: PRESET_SHORT,
      facilities: everything,
      maxFine: 100,
    });
    expect(small).toEqual({ kind: 'fine', amount: 100, time: PRESET_SHORT });
  });

  it('drops the fine for repeat offenders and resisting arrest', () => {
    const charges = [PRESET_SHORT];
    const total = calculateSentence(PRESET_SHORT, { elevated: true });
    expect(
      suggestPunishment({
        charges,
        total,
        elevated: true,
        facilities: everything,
        maxFine: 2000,
      }),
    ).toEqual([{ kind: 'brig', time: total }]);
  });

  it('sends up to 15 minutes to the brig', () => {
    expect(
      suggestPunishment({
        charges: [PRESET_LONG],
        total: PRESET_LONG,
        facilities: everything,
        maxFine: 2000,
      }),
    ).toEqual([{ kind: 'brig', time: PRESET_LONG }]);
  });

  it('offers GenPop and the gulag for longer sentences', () => {
    const total = PRESET_LONG + 6000; // 25 min
    expect(
      suggestPunishment({
        charges: [PRESET_LONG, 6000],
        total,
        facilities: everything,
        maxFine: 2000,
      }),
    ).toEqual([
      { kind: 'genpop', time: total },
      { kind: 'gulag', points: 500 },
    ]);
  });

  it('falls back to the brig when the map has no GenPop or gulag', () => {
    const total = PRESET_LONG * 2;
    expect(
      suggestPunishment({
        charges: [PRESET_LONG, PRESET_LONG],
        total,
        facilities: nothing,
        maxFine: 2000,
      }),
    ).toEqual([{ kind: 'brig', time: total }]);
  });

  it('lists permanent options, including digital exile, for a life sentence', () => {
    expect(
      suggestPunishment({
        charges: [MAX_TIMER],
        total: MAX_TIMER,
        facilities: everything,
        maxFine: 2000,
      }),
    ).toEqual([
      { kind: 'permanent_cell' },
      { kind: 'gulag_permanent' },
      { kind: 'exile' },
    ]);
    expect(
      suggestPunishment({
        charges: [MAX_TIMER],
        total: MAX_TIMER,
        facilities: nothing,
        maxFine: 2000,
      }),
    ).toEqual([{ kind: 'permanent_cell' }]);
  });
});
