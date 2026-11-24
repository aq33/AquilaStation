import { Box, Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { MainData } from './data';

// AQUILA: sloty, overclock i pancerz kierunkowy
// (aquila/code/modules/mecha_rework/ui.dm)
export const AqSystemsPane = (props) => {
  const { act, data } = useBackend<MainData>();
  const {
    aq_slots = [],
    aq_overclock,
    aq_overclock_left = 0,
    aq_overclock_cooldown = 0,
    aq_facing = [1, 1, 1],
    aq_plating,
    aq_copilot,
    aq_remote,
  } = data;
  return (
    <Section title="Systemy">
      <LabeledList>
        <LabeledList.Item
          label="Overclock"
          buttons={
            <Button
              icon="bolt"
              selected={!!aq_overclock}
              disabled={!aq_overclock && aq_overclock_cooldown > 0}
              tooltip="Na chwilę szybszy krok i przeładowanie kosztem energii, potem odnowienie"
              onClick={() => act('aq_overclock')}
            >
              Overclock
            </Button>
          }
        >
          {aq_overclock ? (
            <Box color="good">Włączony, zostało {aq_overclock_left} s</Box>
          ) : aq_overclock_cooldown > 0 ? (
            <Box color="average">Odnowienie: {aq_overclock_cooldown} s</Box>
          ) : (
            'Gotowy'
          )}
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
