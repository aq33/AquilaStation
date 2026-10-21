import {
  AnimatedNumber,
  Box,
  Button,
  ColorBox,
  Divider,
  Input,
  LabeledList,
  NumberInput,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { type BooleanLike, classes } from 'tgui-core/react';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';

type Chemical = {
  name: string;
  id: string;
  volume: number;
};

type PillStyle = {
  id: string;
  pill_icon_name: string;
};

type PatchStyle = {
  id: string;
  patch_icon_name: string;
};

type CondiStyle = {
  id: string;
  className: string;
  title: string;
};

type AnalyzeVars = {
  name: string;
  state: string;
  color: string;
  description: string;
  metaRate: number;
  overD: number;
  addicD: number;
};

type Data = {
  analyzeVars: AnalyzeVars;
  autoCondiStyle: string;
  beakerContents: Chemical[];
  beakerCurrentVolume: number | null;
  beakerMaxVolume: number | null;
  bufferContents: Chemical[];
  bufferCurrentVolume: number;
  bufferMaxVolume: number;
  chosen_condi_style: string;
  chosen_patch_style: string;
  chosen_pill_style: string;
  condi: BooleanLike;
  condiStyles: CondiStyle[];
  hasBeakerInHand: BooleanLike;
  isBeakerLoaded: BooleanLike;
  isPillBottleLoaded: BooleanLike;
  mode: BooleanLike;
  patch_styles: PatchStyle[];
  pillBottleCurrentAmount: number;
  pillBottleMaxAmount: number;
  pill_styles: PillStyle[];
  saved_name: string;
  saved_name_state: 'Auto' | 'Manual';
  saved_volume: number;
  saved_volume_state: 'Auto' | 'Exact';
  screen: string;
};

// Wartości z DM zostają po angielsku, tu tylko etykiety
const VOLUME_STATE_LABELS = {
  Auto: 'Auto',
  Exact: 'Dokładnie',
};

const NAME_STATE_LABELS = {
  Auto: 'Auto',
  Manual: 'Ręcznie',
};

const REAGENT_STATE_LABELS = {
  Solid: 'Stały',
  Liquid: 'Ciekły',
  Gas: 'Gaz',
  Unknown: 'Nieznany',
};

export const ChemMaster = (props) => {
  const { data } = useBackend<Data>();
  const { screen } = data;
  return (
    <Window width={465} height={620}>
      <Window.Content scrollable>
        {(screen === 'analyze' && <AnalysisResults />) || <ChemMasterContent />}
      </Window.Content>
    </Window>
  );
};

const ChemMasterContent = (props) => {
  const { act, data } = useBackend<Data>();
  const { saved_volume, saved_name, saved_volume_state, saved_name_state } =
    data;
  const {
    beakerContents = [],
    bufferContents = [],
    beakerCurrentVolume,
    beakerMaxVolume,
    bufferCurrentVolume,
    bufferMaxVolume,
    isBeakerLoaded,
    isPillBottleLoaded,
    pillBottleCurrentAmount,
    pillBottleMaxAmount,
    hasBeakerInHand,
  } = data;
  return (
    <Box>
      <Section
        title="Zlewka"
        buttons={
          isBeakerLoaded ? (
            <Box>
              <Box inline color="label" mr={2}>
                <AnimatedNumber value={beakerCurrentVolume || 0} initial={0} />
                {` / ${beakerMaxVolume} u`}
              </Box>
              <Button icon="eject" onClick={() => act('eject')}>
                Wysuń
              </Button>
            </Box>
          ) : (
            <Button
              icon="eject"
              onClick={() => act('insert')}
              style={{
                opacity: hasBeakerInHand ? 1 : 0.5,
              }}
              tooltip={!hasBeakerInHand && 'Musisz trzymać pojemnik w ręce.'}
              tooltipPosition="bottom-start"
            >
              Włóż
            </Button>
          )
        }
      >
        {!isBeakerLoaded ? (
          <Box color="label" my="4px">
            Nie włożono zlewki.
          </Box>
        ) : beakerContents.length === 0 ? (
          <Box color="label" my="4px">
            Zlewka jest pusta.
          </Box>
        ) : (
          <Table>
            {beakerContents.map((chemical) => (
              <ReagentEntry
                key={chemical.id}
                chemical={chemical}
                transferTo="buffer"
              />
            ))}
          </Table>
        )}
      </Section>
      <Section
        title="Bufor"
        buttons={
          <>
            {bufferMaxVolume !== undefined && (
              <Box inline color="label" mr={1}>
                <AnimatedNumber value={bufferCurrentVolume || 0} initial={0} />
                {` / ${bufferMaxVolume} u`}
              </Box>
            )}
            <Button
              color={data.mode ? 'good' : 'bad'}
              icon={data.mode ? 'exchange-alt' : 'trash'}
              onClick={() => act('toggleMode')}
            >
              {data.mode ? 'Przenoszenie' : 'Niszczenie'}
            </Button>
          </>
        }
      >
        {bufferContents.length === 0 ? (
          <Box color="label" my="4px">
            Bufor jest pusty.
          </Box>
        ) : (
          <Table>
            {bufferContents.map((chemical) => (
              <ReagentEntry
                key={chemical.id}
                chemical={chemical}
                transferTo="beaker"
              />
            ))}
          </Table>
        )}
      </Section>
      <Section
        title="Pakowanie"
        buttons={
          <>
            <Box inline color="label" mr={1}>
              Objętość:
            </Box>
            <Button
              icon={saved_volume_state === 'Exact' ? 'eye-dropper' : 'flask'}
              tooltip="Podział objętości"
              onClick={() =>
                act('setSavedVolumeState', {
                  volume_state:
                    saved_volume_state === 'Exact' ? 'Auto' : 'Exact',
                })
              }
            >
              {VOLUME_STATE_LABELS[saved_volume_state] || saved_volume_state}
            </Button>
            {saved_volume_state === 'Exact' && (
              <NumberInput
                step={1}
                width="84px"
                unit="u"
                stepPixelSize={15}
                value={saved_volume}
                minValue={0.01}
                maxValue={50}
                onChange={(value) => act('setSavedVolume', { volume: value })}
              />
            )}
          </>
        }
      >
        <Box mb={2}>
          <Box inline color="label" mr={1}>
            Nazwa:
          </Box>
          <Button
            icon={saved_name_state === 'Manual' ? 'pen' : 'print'}
            onClick={() =>
              act('setSavedNameState', {
                name_state: saved_name_state === 'Manual' ? 'Auto' : 'Manual',
              })
            }
          >
            {NAME_STATE_LABELS[saved_name_state] || saved_name_state}
          </Button>
          {saved_name_state === 'Manual' && (
            <Input
              fluid
              value={saved_name}
              placeholder="Nazwa"
              onChange={(value) => {
                act('setSavedName', { name: value });
              }}
            />
          )}
        </Box>
        <PackagingControls
          volume={saved_volume_state === 'Exact' ? saved_volume : 'auto'}
          packagingName={saved_name_state === 'Manual' ? saved_name : null}
        />
      </Section>
      {!!isPillBottleLoaded && (
        <Section
          title="Pojemnik na pigułki"
          buttons={
            <>
              <Box inline color="label" mr={2}>
                {pillBottleCurrentAmount} / {pillBottleMaxAmount} szt.
              </Box>
              <Button icon="eject" onClick={() => act('ejectPillBottle')}>
                Wysuń
              </Button>
            </>
          }
        />
      )}
    </Box>
  );
};

type ReagentProps = {
  chemical: Chemical;
  transferTo: 'buffer' | 'beaker';
};

const ReagentEntry = (props: ReagentProps) => {
  const { act } = useBackend<Data>();
  const { chemical, transferTo } = props;
  const transfer = (amount: number) =>
    act('transfer', {
      id: chemical.id,
      amount,
      to: transferTo,
    });
  return (
    <Table.Row key={chemical.id}>
      <Table.Cell color="label">
        {`${chemical.name} `}
        <AnimatedNumber value={chemical.volume} initial={0} />
        {'u'}
      </Table.Cell>
      <Table.Cell collapsing>
        <Button onClick={() => transfer(1)}>1</Button>
        <Button onClick={() => transfer(5)}>5</Button>
        <Button onClick={() => transfer(10)}>10</Button>
        <Button onClick={() => transfer(1000)}>Całość</Button>
        <Button
          icon="ellipsis-h"
          tooltip="Własna ilość"
          onClick={() => transfer(-1)}
        />
        <Button
          icon="question"
          tooltip="Analizuj"
          onClick={() =>
            act('analyze', {
              id: chemical.id,
            })
          }
        />
      </Table.Cell>
    </Table.Row>
  );
};

const PackagingControlsItem = (props) => {
  const { label, amountUnit, amount, onChangeAmount, onCreate, sideNote } =
    props;
  return (
    <LabeledList.Item label={label}>
      <NumberInput
        width="84px"
        unit={amountUnit}
        step={1}
        stepPixelSize={15}
        value={amount}
        minValue={1}
        maxValue={10}
        onChange={onChangeAmount}
      />
      <Button ml={1} icon="flask" onClick={onCreate}>
        Wytwórz
      </Button>
      <Box inline ml={1} color="label">
        {sideNote}
      </Box>
    </LabeledList.Item>
  );
};

const PackagingControls = ({ volume, packagingName }) => {
  const { act, data } = useBackend<Data>();
  // AQ EDIT - NumberInput z tgui-core woła onChange(value), a nie (e, value); undefined w shared state wywalał okno
  const [pillAmount, setPillAmount] = useSharedState('pillAmount', 1);
  const [patchAmount, setPatchAmount] = useSharedState('patchAmount', 1);
  const [bottleAmount, setBottleAmount] = useSharedState('bottleAmount', 1);
  const [bagAmount, setBagAmount] = useSharedState('bagAmount', 1);
  const [packAmount, setPackAmount] = useSharedState('packAmount', 1);
  const {
    condi,
    chosen_pill_style,
    pill_styles = [],
    chosen_patch_style,
    patch_styles = [],
    chosen_condi_style,
    autoCondiStyle,
    condiStyles = [],
  } = data;
  const autoCondiStyleChosen = autoCondiStyle === chosen_condi_style;
  return (
    <>
      {!condi && (
        <>
          <GroupTitle title="Pigułki" />
          <LabeledList>
            <LabeledList.Item label="Wygląd">
              {pill_styles.map((each_style) => (
                <Button
                  key={each_style.id}
                  width="30px"
                  height="16px"
                  selected={each_style.id === chosen_pill_style}
                  textAlign="center"
                  color="transparent"
                  onClick={() => act('pillStyle', { id: each_style.id })}
                >
                  <Box
                    mx={-1}
                    className={classes([
                      'medicine_containers22x22',
                      each_style.pill_icon_name,
                    ])}
                  />
                </Button>
              ))}
            </LabeledList.Item>
            <PackagingControlsItem
              label="Pigułki"
              amount={pillAmount}
              amountUnit="szt."
              sideNote="maks. 50u"
              onChangeAmount={(value) => setPillAmount(value)}
              onCreate={() =>
                act('create', {
                  type: 'pill',
                  amount: pillAmount,
                  volume: volume,
                  name: packagingName,
                })
              }
            />
          </LabeledList>
          <GroupTitle title="Plastry" />
          <LabeledList>
            <LabeledList.Item label="Wygląd">
              {patch_styles.map((each_style) => (
                <Button
                  key={each_style.id}
                  width="30px"
                  height="25px"
                  selected={each_style.id === chosen_patch_style}
                  textAlign="center"
                  color="transparent"
                  onClick={() => act('patchStyle', { id: each_style.id })}
                >
                  <Box
                    mx={-1}
                    className={classes([
                      'medicine_containers22x22',
                      each_style.patch_icon_name,
                    ])}
                  />
                </Button>
              ))}
            </LabeledList.Item>
            <PackagingControlsItem
              label="Plastry"
              amount={patchAmount}
              amountUnit="szt."
              sideNote="maks. 40u"
              onChangeAmount={(value) => setPatchAmount(value)}
              onCreate={() =>
                act('create', {
                  type: 'patch',
                  amount: patchAmount,
                  volume: volume,
                  name: packagingName,
                })
              }
            />
          </LabeledList>
          <GroupTitle title="Butelki i worki" />
          <LabeledList>
            <PackagingControlsItem
              label="Butelki"
              amount={bottleAmount}
              amountUnit="szt."
              sideNote="maks. 30u"
              onChangeAmount={(value) => setBottleAmount(value)}
              onCreate={() =>
                act('create', {
                  type: 'bottle',
                  amount: bottleAmount,
                  volume: volume,
                  name: packagingName,
                })
              }
            />
            <PackagingControlsItem
              label="Worki"
              amount={bagAmount}
              amountUnit="szt."
              sideNote="maks. 200u"
              onChangeAmount={(value) => setBagAmount(value)}
              onCreate={() =>
                act('create', {
                  type: 'bag',
                  amount: bagAmount,
                  volume: volume, // NSV13
                  name: packagingName, // NSV13
                })
              }
            />
          </LabeledList>
        </>
      )}
      {!!condi && (
        <>
          <GroupTitle title="Butelki" />
          <LabeledList>
            <LabeledList.Item label="Rodzaj butelki">
              <Button.Checkbox
                onClick={() =>
                  act('condiStyle', {
                    id: autoCondiStyleChosen
                      ? condiStyles[0].id
                      : autoCondiStyle,
                  })
                }
                checked={autoCondiStyleChosen}
                disabled={!condiStyles.length}
              >
                Dobierz do zawartości
              </Button.Checkbox>
            </LabeledList.Item>
            {!autoCondiStyleChosen && (
              <LabeledList.Item label="">
                {condiStyles.map((style) => (
                  <Button
                    key={style.id}
                    width="30px"
                    selected={style.id === chosen_condi_style}
                    textAlign="center"
                    color="transparent"
                    tooltip={style.title}
                    onClick={() => act('condiStyle', { id: style.id })}
                  >
                    <Box mx={-1} className={style.className} />
                  </Button>
                ))}
              </LabeledList.Item>
            )}
            <PackagingControlsItem
              label="Butelki"
              amount={bottleAmount}
              amountUnit="szt."
              sideNote="maks. 50u"
              onChangeAmount={(value) => setBottleAmount(value)}
              onCreate={() =>
                act('create', {
                  type: 'condimentBottle',
                  amount: bottleAmount,
                  volume: volume,
                  name: packagingName,
                })
              }
            />
          </LabeledList>
          <GroupTitle title="Saszetki" />
          <LabeledList>
            <PackagingControlsItem
              label="Saszetki"
              amount={packAmount}
              amountUnit="szt."
              sideNote="maks. 10u"
              onChangeAmount={(value) => setPackAmount(value)}
              onCreate={() =>
                act('create', {
                  type: 'condimentPack',
                  amount: packAmount,
                  volume: volume, // NSV13
                  name: packagingName, // NSV13
                })
              }
            />
          </LabeledList>
        </>
      )}
    </>
  );
};

const AnalysisResults = (props) => {
  const { act, data } = useBackend<Data>();
  const { analyzeVars } = data;
  return (
    <Section
      title="Wyniki analizy"
      buttons={
        <Button
          icon="arrow-left"
          onClick={() =>
            act('goScreen', {
              screen: 'home',
            })
          }
        >
          Wróć
        </Button>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Nazwa">{analyzeVars.name}</LabeledList.Item>
        <LabeledList.Item label="Stan skupienia">
          {REAGENT_STATE_LABELS[analyzeVars.state] || analyzeVars.state}
        </LabeledList.Item>
        <LabeledList.Item label="Kolor">
          <ColorBox color={analyzeVars.color} mr={1} />
          {analyzeVars.color}
        </LabeledList.Item>
        <LabeledList.Item label="Opis">
          {analyzeVars.description}
        </LabeledList.Item>
        <LabeledList.Item label="Tempo metabolizmu">
          {analyzeVars.metaRate} u/min
        </LabeledList.Item>
        <LabeledList.Item label="Próg przedawkowania">
          {analyzeVars.overD > 0 ? `${analyzeVars.overD} u` : 'Brak'}
        </LabeledList.Item>
        <LabeledList.Item label="Próg uzależnienia">
          {analyzeVars.addicD > 0 ? `${analyzeVars.addicD} u` : 'Brak'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const GroupTitle = ({ title }) => {
  return (
    <Stack my={1}>
      <Stack.Item grow>
        <Divider />
      </Stack.Item>
      <Stack.Item color="gray">{title}</Stack.Item>
      <Stack.Item grow>
        <Divider />
      </Stack.Item>
    </Stack>
  );
};
