import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { MainData } from './data';

// AQUILA: sloty, ciepło, overclock i pancerz kierunkowy
// (aquila/code/modules/mecha_rework/ui.dm)
export const AqSystemsPane = (props) => {
  const { act, data } = useBackend<MainData>();
  const {
    aq_slots = [],
    aq_heat = 0,
    aq_heat_warning = 50,
    aq_heat_danger = 100,
    aq_heat_max = 150,
    aq_overclock,
    aq_fuses = 0,
    aq_fuses_max = 3,
    aq_fuse_safety,
    aq_facing = [1, 1, 1],
    aq_plating,
    aq_copilot,
    aq_remote,
  } = data;
  return (
    <Section title="Systemy">
      <LabeledList>
        <LabeledList.Item
          label="Ciepło"
          buttons={
            <Button
              icon="bolt"
              selected={!!aq_overclock}
              tooltip="Szybszy krok i przeładowanie, rosnące ciepło"
              onClick={() => act('aq_overclock')}
            >
              Overclock
            </Button>
          }
        >
          <ProgressBar
            value={aq_heat}
            minValue={0}
            maxValue={aq_heat_max}
            ranges={{
              good: [-Infinity, aq_heat_warning],
              average: [aq_heat_warning, aq_heat_danger],
              bad: [aq_heat_danger, Infinity],
            }}
          >
            {aq_heat} / {aq_heat_max}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item
          label="Bezpieczniki"
          buttons={
            <Button
              icon="shield-alt"
              selected={!!aq_fuse_safety}
              tooltip="Wyłączone: przy przegrzaniu overclock nie gaśnie, a mech się smaży"
              onClick={() => act('aq_fuse_safety')}
            >
              Zabezpieczenie
            </Button>
          }
        >
          {aq_fuses} / {aq_fuses_max}
        </LabeledList.Item>
        <LabeledList.Item label="Pancerz">
          przód ×{aq_facing[0]}, boki ×{aq_facing[1]}, tył ×{aq_facing[2]}
          {aq_plating ? `, płyta: ${aq_plating}` : ''}
        </LabeledList.Item>
        {!!aq_copilot && (
          <LabeledList.Item label="Kierowca">{aq_copilot}</LabeledList.Item>
        )}
        {!!aq_remote && (
          <LabeledList.Item label="Łącze">Sterowanie zdalne</LabeledList.Item>
        )}
        {aq_slots.map((slot) => (
          <LabeledList.Item
            key={slot.key}
            label={slot.name}
            color={slot.max && slot.used >= slot.max ? 'average' : undefined}
          >
            {slot.max ? `${slot.used}/${slot.max}` : slot.used}
            {slot.modules.length > 0 && (
              <Box color="label">{slot.modules.join(', ')}</Box>
            )}
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};
