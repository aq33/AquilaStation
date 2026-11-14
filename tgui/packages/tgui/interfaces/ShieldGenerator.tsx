// NSV13

import { toFixed } from 'common/math';
import { Button, ProgressBar, Section, Slider } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  active: any;
  available_power: any;
  goal: any;
  maxHealthPriority: any;
  maxPower: any;
  powerAlloc: any;
  progress: any;
  regenPriority: any;
  // AQ EDIT START - maskowanie (aquila/code/modules/overmap/shield_cloak.dm)
  cloaked?: boolean;
  cloak_left?: number;
  cloak_cooldown?: number;
  cloak_power?: number;
  can_cloak?: boolean;
  // AQ EDIT END
};

export const ShieldGenerator = (props) => {
  const { act, data } = useBackend<Data>();
  const maxHealthPriority = data.maxHealthPriority;
  const regenPriority = data.regenPriority;
  const progress = data.progress;
  const goal = data.goal;
  const powerAlloc = data.powerAlloc;
  const maxPower = data.maxPower;
  const availablePower = data.available_power;
  return (
    <Window theme="ntos" width={600} height={660}>
      <Window.Content scrollable>
        <Section title="Stan tarcz:">
          Integralność tarcz: {progress}
          <br />
          Siła tarcz: {goal}
          <br />
          <ProgressBar
            value={(progress / goal) * 100 * 0.01}
            ranges={{
              good: [0.5, Infinity],
              average: [0.15, 0.5],
              bad: [-Infinity, 0.15],
            }}
          />
          <br />
          Dostępna moc:
          <br />
          <ProgressBar
            value={availablePower}
            minValue={0}
            maxValue={powerAlloc * 1e6}
            color="yellow"
          >
            {toFixed(availablePower / 1000) + ' kW'}
          </ProgressBar>
        </Section>
        <Section
          title="Ustawienia:"
          buttons={
            <Button
              content={data.active ? 'Opuść tarcze' : 'Podnieś tarcze'}
              icon="shield-alt"
              color={data.active && 'good'}
              onClick={() => act('activeToggle')}
            />
          }
        >
          Siła tarcz:
          <Slider
            tickWhileDragging
            value={maxHealthPriority}
            fillValue={maxHealthPriority}
            minValue={0}
            maxValue={100}
            step={1}
            stepPixelSize={1}
            onChange={(e, value) =>
              act('maxHealth', {
                input: value,
              })
            }
          />
          Regeneracja tarcz:
          <Slider
            tickWhileDragging
            value={regenPriority}
            minValue={0}
            maxValue={100}
            step={1}
            stepPixelSize={1}
            onChange={(e, value) =>
              act('regen', {
                input: value,
              })
            }
          />
          Przydział mocy (MW):
          <Slider
            tickWhileDragging
            value={powerAlloc}
            minValue={0}
            maxValue={maxPower}
            step={0.25}
            stepPixelSize={5}
            onChange={(e, value) =>
              act('power', {
                input: value,
              })
            }
          />
        </Section>
        {/* AQ EDIT START - maskowanie (aquila/code/modules/overmap/shield_cloak.dm) */}
        <Section
          title="Maskowanie:"
          buttons={
            <Button
              icon="eye-slash"
              selected={!!data.cloaked}
              disabled={!data.cloaked && !data.can_cloak}
              onClick={() => act('cloakToggle')}
            >
              {data.cloaked ? 'Zdejmij maskę' : 'Włącz maskę'}
            </Button>
          }
        >
          {data.cloaked
            ? `Maska aktywna, zostało ${data.cloak_left} s.`
            : data.cloak_cooldown
              ? `Generator stygnie, maska gotowa za ${data.cloak_cooldown} s.`
              : 'Maska gotowa.'}
          <br />
          {`Pobór w masce: ${data.cloak_power} MW. Tarcza nie chroni, gdy maska jest włączona.`}
        </Section>
        {/* AQ EDIT END */}
      </Window.Content>
    </Window>
  );
};
