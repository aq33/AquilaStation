import { Button, LabeledList, NoticeBox, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  silicon_user: BooleanLike;
  locked: BooleanLike;
  on: BooleanLike;
  check_weapons: BooleanLike;
  check_records: BooleanLike;
  neutralize_criminals: BooleanLike;
  neutralize_all: BooleanLike;
  neutralize_unidentified: BooleanLike;
  neutralize_nonmindshielded: BooleanLike;
  neutralize_cyborgs: BooleanLike;
  manual_control: BooleanLike;
  allow_manual_control: BooleanLike;
  lasertag_turret: BooleanLike;
};

export const PortableTurret = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    silicon_user,
    locked,
    on,
    check_weapons,
    check_records,
    neutralize_criminals,
    neutralize_all,
    neutralize_unidentified,
    neutralize_nonmindshielded,
    neutralize_cyborgs,
    manual_control,
    allow_manual_control,
    lasertag_turret,
  } = data;
  return (
    <Window
      title="Przenośna wieżyczka"
      width={330}
      height={lasertag_turret ? 130 : 320}
    >
      <Window.Content>
        <NoticeBox>
          Przeciągnij kartę ID, aby {locked ? 'odblokować' : 'zablokować'}{' '}
          sterowanie.
        </NoticeBox>
        <Section>
          <LabeledList>
            <LabeledList.Item
              label="Stan"
              buttons={
                !lasertag_turret &&
                (!!allow_manual_control ||
                  (!!manual_control && !!silicon_user)) && (
                  <Button
                    icon={manual_control ? 'wifi' : 'terminal'}
                    disabled={!!manual_control}
                    color="bad"
                    onClick={() => act('manual')}
                  >
                    {manual_control ? 'Sterowana zdalnie' : 'Sterowanie ręczne'}
                  </Button>
                )
              }
            >
              <Button
                icon={on ? 'power-off' : 'times'}
                selected={on}
                disabled={locked}
                onClick={() => act('power')}
              >
                {on ? 'Włączona' : 'Wyłączona'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {!lasertag_turret && (
          <Section title="Cele">
            <Button.Checkbox
              fluid
              checked={neutralize_all}
              disabled={locked}
              onClick={() => act('shootall')}
            >
              Personel spoza ochrony i dowództwa
            </Button.Checkbox>
            <Button.Checkbox
              fluid
              checked={check_weapons}
              disabled={locked}
              onClick={() => act('authweapon')}
            >
              Broń bez zezwolenia
            </Button.Checkbox>
            {/* AQUILA: sprawdzanie akt ochrony (tg tego nie ma) */}
            <Button.Checkbox
              fluid
              checked={check_records}
              disabled={locked}
              onClick={() => act('checkrecords')}
            >
              Sprawdzaj akta ochrony
            </Button.Checkbox>
            <Button.Checkbox
              fluid
              checked={neutralize_unidentified}
              disabled={locked}
              onClick={() => act('checkxenos')}
            >
              Niezidentyfikowane formy życia
            </Button.Checkbox>
            <Button.Checkbox
              fluid
              checked={neutralize_nonmindshielded}
              disabled={locked}
              onClick={() => act('checkloyal')}
            >
              Bez implantu lojalności
            </Button.Checkbox>
            <Button.Checkbox
              fluid
              checked={neutralize_criminals}
              disabled={locked}
              onClick={() => act('shootcrooks')}
            >
              Poszukiwani przestępcy
            </Button.Checkbox>
            <Button.Checkbox
              fluid
              checked={neutralize_cyborgs}
              disabled={locked}
              onClick={() => act('checkborg')}
            >
              Cyborgi
            </Button.Checkbox>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
