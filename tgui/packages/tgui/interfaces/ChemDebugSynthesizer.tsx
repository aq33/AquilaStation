import { Button, NumberInput, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { BeakerDisplay, legacyBeaker } from './Chemistry/BeakerDisplay';
import type { BeakerReagent } from './common/BeakerDisplay';

type Data = {
  amount: number;
  temp: number;
  isBeakerLoaded: BooleanLike;
  beakerCurrentVolume: number | null;
  beakerMaxVolume: number | null;
  beakerContents: BeakerReagent[];
};

export const ChemDebugSynthesizer = (props) => {
  const { act, data } = useBackend<Data>();
  const { amount, temp } = data;
  const beaker = legacyBeaker(
    data.isBeakerLoaded,
    data.beakerCurrentVolume,
    data.beakerMaxVolume,
    data.beakerContents,
  );

  return (
    <Window width={390} height={330}>
      <Window.Content scrollable>
        <Section
          title="Pojemnik"
          buttons={
            beaker ? (
              <>
                <NumberInput
                  value={amount}
                  unit="u"
                  minValue={1}
                  maxValue={beaker.maxVolume}
                  step={1}
                  stepPixelSize={2}
                  onChange={(value) =>
                    act('amount', {
                      amount: value,
                    })
                  }
                />
                <NumberInput
                  value={temp}
                  unit="K"
                  minValue={0}
                  maxValue={1000}
                  step={1}
                  stepPixelSize={2}
                  onChange={(value) =>
                    act('temp', {
                      amount: value,
                    })
                  }
                />
                <Button icon="plus" onClick={() => act('input')}>
                  Dodaj
                </Button>
              </>
            ) : (
              <Button icon="plus" onClick={() => act('makecup')}>
                Stwórz zlewkę
              </Button>
            )
          }
        >
          <BeakerDisplay beaker={beaker} />
        </Section>
      </Window.Content>
    </Window>
  );
};
