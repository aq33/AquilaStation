import { Box, Button, Modal, NumberInput, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { AirAlarmData, EditingModalProps } from './types';

type Props = EditingModalProps & {
  oldValue: number;
};

export function AlarmEditingModal(props: Props) {
  const { act } = useBackend<AirAlarmData>();
  const { env, name, typeName, unit, oldValue, finish, typeVar } = props;

  return (
    <Modal>
      <Section
        title="Edycja progu"
        buttons={<Button onClick={() => finish()} icon="times" color="red" />}
      >
        <Box mb={1.5}>
          {typeName}: {name}
        </Box>
        {oldValue === -1 ? (
          <Button
            onClick={() =>
              act('set_threshold', {
                env,
                var: typeVar,
                value: 0,
              })
            }
          >
            Włącz
          </Button>
        ) : (
          <>
            <NumberInput
              onChange={(value) =>
                act('set_threshold', {
                  env,
                  var: typeVar,
                  value,
                })
              }
              unit={unit}
              value={oldValue}
              minValue={0}
              maxValue={100000}
              step={10}
            />
            <Button
              ml={1}
              onClick={() =>
                act('set_threshold', {
                  env,
                  var: typeVar,
                  value: -1,
                })
              }
            >
              Wyłącz
            </Button>
          </>
        )}
      </Section>
    </Modal>
  );
}
