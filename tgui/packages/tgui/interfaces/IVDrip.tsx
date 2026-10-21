import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Slider,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type IVDripData = {
  hasContainer: BooleanLike;
  canRemoveContainer: BooleanLike;
  // AQUILA: kroplówka z solą fizjologiczną nie zmienia trybu
  canChangeMode: BooleanLike;
  mode: BooleanLike;
  transferRate: number;
  transferStep: number;
  minTransferRate: number;
  maxTransferRate: number;
  // AQUILA: worki z krwią przelewają się dwa razy szybciej
  isBloodPack: BooleanLike;
  hasObjectAttached: BooleanLike;
  objectName: string | null;
  containerName?: string;
  containerReagentColor?: string;
  containerCurrentVolume?: number;
  containerMaxVolume?: number;
};

export const IVDrip = (props) => {
  const { act, data } = useBackend<IVDripData>();
  const {
    hasContainer,
    canRemoveContainer,
    canChangeMode,
    mode,
    transferRate,
    transferStep,
    maxTransferRate,
    minTransferRate,
    isBloodPack,
    hasObjectAttached,
    objectName,
    containerName,
    containerCurrentVolume = 0,
    containerMaxVolume = 0,
    containerReagentColor,
  } = data;
  return (
    <Window width={420} height={240}>
      <Window.Content>
        <Section fill>
          <LabeledList>
            <LabeledList.Item
              label="Przepływ"
              buttons={
                <Box>
                  <Button
                    width={4}
                    lineHeight={2}
                    align="center"
                    icon="angles-left"
                    tooltip="Minimum"
                    onClick={() =>
                      act('changeRate', {
                        rate: minTransferRate,
                      })
                    }
                  />
                  <Button
                    width={4}
                    lineHeight={2}
                    align="center"
                    icon="angles-right"
                    tooltip="Maksimum"
                    onClick={() =>
                      act('changeRate', {
                        rate: maxTransferRate,
                      })
                    }
                  />
                </Box>
              }
            >
              <Tooltip
                content={
                  'Jednostki na cykl pompy.' +
                  (isBloodPack && mode
                    ? ' Worek z krwią przelewa się dwa razy szybciej.'
                    : '')
                }
              >
                <Slider
                  step={transferStep}
                  my={1}
                  value={transferRate}
                  minValue={minTransferRate}
                  maxValue={maxTransferRate}
                  unit="j."
                  onChange={(e, value) =>
                    act('changeRate', {
                      rate: value,
                    })
                  }
                />
              </Tooltip>
            </LabeledList.Item>
            <LabeledList.Item
              label="Kierunek"
              color={!mode ? 'bad' : ''}
              buttons={
                <Button
                  my={1}
                  width={8}
                  lineHeight={2}
                  align="center"
                  disabled={!canChangeMode}
                  color={!mode ? 'bad' : undefined}
                  icon={mode ? 'syringe' : 'droplet'}
                  onClick={() => act('changeMode')}
                >
                  {mode ? 'Wlew' : 'Pobór'}
                </Button>
              }
            >
              {mode
                ? 'Płyn z pojemnika do pacjenta'
                : 'Krew pacjenta do pojemnika'}
            </LabeledList.Item>
            {hasContainer ? (
              <LabeledList.Item
                label="Pojemnik"
                buttons={
                  !!canRemoveContainer && (
                    <Button
                      my={1}
                      width={8}
                      lineHeight={2}
                      align="center"
                      icon="eject"
                      onClick={() => act('eject')}
                    >
                      Wyjmij
                    </Button>
                  )
                }
              >
                <ProgressBar
                  value={containerCurrentVolume}
                  minValue={0}
                  maxValue={containerMaxVolume}
                  color={containerReagentColor}
                >
                  <span
                    style={{
                      textShadow: '1px 1px 0 black',
                    }}
                  >
                    {`${containerName}: ${containerCurrentVolume} / ${containerMaxVolume} j.`}
                  </span>
                </ProgressBar>
              </LabeledList.Item>
            ) : (
              <LabeledList.Item label="Pojemnik">
                <Tooltip content="Kliknij kroplówkę pojemnikiem trzymanym w ręce, aby go podłączyć.">
                  <NoticeBox my={0.7}>Brak podłączonego pojemnika.</NoticeBox>
                </Tooltip>
              </LabeledList.Item>
            )}
            {hasObjectAttached ? (
              <LabeledList.Item
                label="Pacjent"
                buttons={
                  <Button
                    my={1}
                    width={8}
                    lineHeight={2}
                    align="center"
                    icon="ban"
                    onClick={() => act('detach')}
                  >
                    Odłącz
                  </Button>
                }
              >
                <Box maxHeight="45px" overflow="hidden">
                  {objectName}
                </Box>
              </LabeledList.Item>
            ) : (
              <LabeledList.Item label="Pacjent">
                <Tooltip content="Przeciągnij kroplówkę na pacjenta, aby go podłączyć.">
                  <NoticeBox my={0.7}>Nikt nie jest podłączony.</NoticeBox>
                </Tooltip>
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
