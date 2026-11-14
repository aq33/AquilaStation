import { Button, ProgressBar, Section, Slider } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  active: any;
  alignment: number;
  frequency: number;
  heat: number;
  maintainable: boolean;
  maxheat: number;
  overloaded: boolean;
  venting: boolean;
  chargeRate: any;
  goal: any;
  maxChargeRate: any;
  maxHealthPriority: any;
  maxPower: any;
  powerAlloc: any;
  progress: any;
  regenPriority: any;
};

export const EnergyWeapons = (props) => {
  const { act, data } = useBackend<Data>();
  const maxHealthPriority = data.maxHealthPriority;
  const regenPriority = data.regenPriority;
  const progress = data.progress;
  const chargeRate = data.chargeRate;
  const maxChargeRate = data.maxChargeRate;
  const goal = data.goal;
  const powerAlloc = data.powerAlloc;
  const maxPower = data.maxPower;
  return (
    <Window theme="ntos" width={600} height={data.maintainable ? 560 : 350}>
      <Window.Content scrollable>
        <Section
          title="Stan ładowania:"
          buttons={
            <Button
              content={data.active ? 'Wyłącz ładowanie' : 'Włącz ładowanie'}
              icon="charging-station"
              color={data.active && 'good'}
              onClick={() => act('activeToggle')}
            />
          }
        >
          Pobór mocy:
          <br />
          <ProgressBar
            value={(chargeRate / maxChargeRate) * 100 * 0.01}
            ranges={{
              good: [-Infinity, 0.3],
              average: [0.3, 0.5],
              bad: [0.5, Infinity],
            }}
          >
            {chargeRate / 1e6 + ' mW'}
          </ProgressBar>
          <br />
          Ładunek:
          <br />
          <ProgressBar
            value={(progress / goal) * 100 * 0.01}
            ranges={{
              good: [0.5, Infinity],
              average: [0.15, 0.5],
              bad: [-Infinity, 0.15],
            }}
          />
        </Section>
        {!!data.maintainable && (
          <Section
            title="Ciepło:"
            buttons={
              <Button
                content="Odprowadź ciepło"
                icon="exclamation-triangle"
                color="bad"
                disabled={data.overloaded || data.venting}
                onClick={() => act('vent')}
              />
            }
          >
            <ProgressBar
              value={data.maxheat ? data.heat / data.maxheat : 0}
              ranges={{
                good: [-Infinity, 0.2],
                average: [0.2, 0.5],
                bad: [0.5, Infinity],
              }}
            >
              {data.heat + ' / ' + data.maxheat}
            </ProgressBar>
            {!!data.overloaded && 'Przegrzanie: broń stygnie w trybie awaryjnym.'}
            {!!data.venting && 'Odprowadzanie ciepła: broń nie strzela.'}
          </Section>
        )}
        {!!data.maintainable && (
          <Section title="Ustawienie soczewek:">
            <ProgressBar
              value={data.alignment * 0.01}
              ranges={{
                good: [0.5, Infinity],
                average: [0.15, 0.5],
                bad: [-Infinity, 0.15],
              }}
            />
          </Section>
        )}
        {!!data.maintainable && (
          <Section title="Strojenie częstotliwości:">
            <ProgressBar
              value={data.frequency * 0.01}
              ranges={{
                good: [0.5, Infinity],
                average: [0.15, 0.5],
                bad: [-Infinity, 0.15],
              }}
            />
          </Section>
        )}
        <Section title="Ustawienia:">
          Poziom poboru mocy:
          <Slider
            tickWhileDragging
            value={powerAlloc}
            minValue={0}
            maxValue={maxPower}
            step={0.5}
            stepPixelSize={5}
            onChange={(e, value) =>
              act('power', {
                input: value,
              })
            }
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
