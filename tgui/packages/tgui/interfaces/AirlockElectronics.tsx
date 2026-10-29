import {
  Button,
  Input,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { AccessList } from './common/AccessList';

type Region = {
  accesses: { desc: string; ref: number }[];
  name: string;
  regid: number;
};

type Data = {
  accesses: number[];
  oneAccess: BooleanLike;
  passedCycleId: string;
  passedName: string;
  regions: Region[];
  shell: BooleanLike;
  unres_direction: number;
};

const DIRECTIONS = [
  { bit: 1, name: 'Północ' },
  { bit: 2, name: 'Południe' },
  { bit: 4, name: 'Wschód' },
  { bit: 8, name: 'Zachód' },
];

export function AirlockElectronics(props) {
  return (
    <Window width={420} height={530}>
      <Window.Content>
        <AirLockMainSection />
      </Window.Content>
    </Window>
  );
}

export function AirLockMainSection(props) {
  const { act, data } = useBackend<Data>();
  const {
    accesses = [],
    oneAccess,
    passedName,
    passedCycleId,
    regions = [],
    shell,
    unres_direction,
  } = data;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section fill>
          <LabeledList>
            {shell !== undefined && (
              <LabeledList.Item label="Obudowa układu">
                <Button.Checkbox
                  checked={shell}
                  onClick={() => {
                    act('set_shell', { on: !shell });
                  }}
                  tooltip="Czy w zbudowanej śluzie będzie można umieścić układ scalony."
                >
                  Obudowa
                </Button.Checkbox>
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Wymagany dostęp">
              <Button
                icon={oneAccess ? 'unlock' : 'lock'}
                onClick={() => act('one_access')}
              >
                {oneAccess ? 'Jeden' : 'Wszystkie'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Wolny przejazd">
              {DIRECTIONS.map((direction) => (
                <Button
                  key={direction.bit}
                  icon={
                    unres_direction & direction.bit
                      ? 'check-square-o'
                      : 'square-o'
                  }
                  selected={unres_direction & direction.bit}
                  onClick={() =>
                    act('direc_set', {
                      unres_direction: String(direction.bit),
                    })
                  }
                >
                  {direction.name}
                </Button>
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Nazwa śluzy">
              <Input
                fluid
                maxLength={30}
                value={passedName || ''}
                onBlur={(value) =>
                  act('passedName', {
                    passedName: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="ID cyklowania">
              <Input
                fluid
                maxLength={30}
                value={passedCycleId || ''}
                onBlur={(value) =>
                  act('passedCycleId', {
                    passedCycleId: value,
                  })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <AccessList
          accesses={regions}
          selectedList={accesses}
          accessMod={(ref) =>
            act('set', {
              access: ref,
            })
          }
          grantAll={() => act('grant_all')}
          denyAll={() => act('clear_all')}
          grantDep={(ref) =>
            act('grant_region', {
              region: ref,
            })
          }
          denyDep={(ref) =>
            act('deny_region', {
              region: ref,
            })
          }
        />
      </Stack.Item>
    </Stack>
  );
}
