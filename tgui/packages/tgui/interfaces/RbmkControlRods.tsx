// NSV13

import { ProgressBar, Section, Slider } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { CoreEjectionData, CoreEjectionSection } from './common/CoreEjection';

type Data = {
  control_rods: any;
  core_ejection?: CoreEjectionData | null;
  desiredK: any;
  k: any;
};

export const RbmkControlRods = (props) => {
  const { act, data } = useBackend<Data>();
  const control_rods = data.control_rods;
  const k = data.k;
  const desiredK = data.desiredK;
  return (
    <Window theme="ntos" width={300} height={data.core_ejection ? 440 : 300}>
      <Window.Content>
        <Section title="Zarządzanie prętami kontrolnymi:">
          Wsunięcie prętów kontrolnych:
          <ProgressBar
            value={(control_rods / 100) * 100 * 0.01}
            ranges={{
              good: [0.7, Infinity],
              average: [0.4, 0.7],
              bad: [-Infinity, 0.4],
            }}
          />
          <br />
          Neutrony na pokolenie (K):
          <br />
          <ProgressBar
            value={(k / 3) * 100 * 0.01}
            ranges={{
              good: [-Infinity, 0.4],
              average: [0.4, 0.6],
              bad: [0.6, Infinity],
            }}
          >
            {k}
          </ProgressBar>
          <br />
          Docelowa krytyczność:
          <br />
          <Slider
            tickWhileDragging
            value={desiredK}
            fillValue={k}
            minValue={0}
            maxValue={3}
            step={0.1}
            stepPixelSize={5}
            onChange={(e, value) =>
              act('input', {
                target: value,
              })
            }
          />
        </Section>
        <CoreEjectionSection ejection={data.core_ejection} />
      </Window.Content>
    </Window>
  );
};
