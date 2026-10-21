import { Button, Dropdown, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';

type Data = {
  pdaTypes: string[];
  cardTrims: string[];
  hasPDA: BooleanLike;
  pdaName: string | null;
  hasID: BooleanLike;
  idName: string | null;
};

export const PaintingMachine = (props) => {
  const { act, data } = useBackend<Data>();
  const { pdaTypes, cardTrims, hasPDA, pdaName, hasID, idName } = data;

  const [selectedPDA] = useSharedState('pdaSelection', pdaTypes[0]);
  const [selectedTrim] = useSharedState('trimSelection', cardTrims[0]);

  return (
    <Window width={500} height={300}>
      <Window.Content scrollable>
        <Section
          title="Malowanie PDA"
          buttons={
            <Button.Confirm
              disabled={!hasPDA}
              confirmContent="Na pewno?"
              onClick={() =>
                act('trim_pda', {
                  selection: selectedPDA,
                })
              }
            >
              Pomaluj PDA
            </Button.Confirm>
          }
        >
          <Stack vertical>
            <Stack.Item>
              <EjectButton
                name={pdaName || '-----'}
                onClickEject={() => act('eject_pda')}
              />
            </Stack.Item>
            <Stack.Item>
              <PainterDropdown stateKey="pdaSelection" options={pdaTypes} />
            </Stack.Item>
          </Stack>
        </Section>
        <Section
          title="Malowanie karty ID"
          buttons={
            <>
              <Button.Confirm
                disabled={!hasID}
                confirmContent="Na pewno?"
                onClick={() =>
                  act('trim_card', {
                    selection: selectedTrim,
                  })
                }
              >
                Pomaluj kartę ID
              </Button.Confirm>
              <Button
                icon="question-circle"
                tooltip={
                  'Zmienia wygląd karty, ikonę w HUD-zie i dział konta ' +
                  'bankowego. Dostępy na karcie zostają bez zmian.'
                }
                tooltipPosition="left"
              />
            </>
          }
        >
          <Stack vertical>
            <Stack.Item>
              <EjectButton
                name={idName || '-----'}
                onClickEject={() => act('eject_card')}
              />
            </Stack.Item>
            <Stack.Item>
              <PainterDropdown stateKey="trimSelection" options={cardTrims} />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

type EjectButtonProps = {
  name: string;
  onClickEject: () => void;
};

export const EjectButton = (props: EjectButtonProps) => {
  const { name, onClickEject } = props;

  return (
    <Button fluid ellipsis icon="eject" onClick={() => onClickEject()}>
      {name}
    </Button>
  );
};

type PainterDropdownProps = {
  stateKey: string;
  options: string[];
};

export const PainterDropdown = (props: PainterDropdownProps) => {
  const { stateKey, options } = props;

  const [selectedOption, setSelectedOption] = useSharedState(
    stateKey,
    options[0],
  );

  return (
    <Dropdown
      width="100%"
      selected={selectedOption}
      options={options}
      onSelected={(sel) => setSelectedOption(sel)}
    />
  );
};
