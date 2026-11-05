import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  NumberInput,
  Section,
  Table,
} from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';

type Data = {
  MaxDispense: any;
  beakerContents: any;
  beakerCurrentVolume: any;
  beakerMaxVolume: any;
  bufferContents: any;
  condi: any;
  isBeakerLoaded: any;
  mode: any;
};

export const AutoInjectorPrinter = (props) => {
  return (
    <Window width={465} height={550}>
      <Window.Content scrollable>
        <MediPenPrinterContent />
      </Window.Content>
    </Window>
  );
};

const MediPenPrinterContent = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    beakerContents = [],
    bufferContents = [],
    beakerCurrentVolume,
    beakerMaxVolume,
    isBeakerLoaded,
  } = data;
  return (
    <>
      <Section
        title="Zlewka"
        buttons={
          !!data.isBeakerLoaded && (
            <>
              <Box inline color="label" mr={2}>
                <AnimatedNumber value={beakerCurrentVolume} initial={0} />
                {` / ${beakerMaxVolume} j.`}
              </Box>
              <Button
                icon="eject"
                content="Wysuń"
                onClick={() => act('eject')}
              />
            </>
          )
        }
      >
        {!isBeakerLoaded && (
          <Box color="label" mt="3px" mb="5px">
            Nie włożono zlewki.
          </Box>
        )}
        {!!isBeakerLoaded && beakerContents.length === 0 && (
          <Box color="label" mt="3px" mb="5px">
            Zlewka jest pusta.
          </Box>
        )}
        <ChemicalBuffer>
          {beakerContents.map((chemical) => (
            <ChemicalBufferEntry
              key={chemical.id}
              chemical={chemical}
              transferTo="buffer"
            />
          ))}
        </ChemicalBuffer>
      </Section>
      <Section
        title="Bufor"
        buttons={
          <>
            <Box inline color="label" mr={1}>
              Tryb:
            </Box>
            <Button
              color={data.mode ? 'good' : 'bad'}
              icon={data.mode ? 'exchange-alt' : 'times'}
              content={data.mode ? 'Przelewanie' : 'Usuwanie'}
              onClick={() => act('toggleMode')}
            />
          </>
        }
      >
        {bufferContents.length === 0 && (
          <Box color="label" mt="3px" mb="5px">
            Bufor jest pusty.
          </Box>
        )}
        <ChemicalBuffer>
          {bufferContents.map((chemical) => (
            <ChemicalBufferEntry
              key={chemical.id}
              chemical={chemical}
              transferTo="beaker"
            />
          ))}
        </ChemicalBuffer>
      </Section>
      <Section title="Pakowanie">
        <PackagingControls />
      </Section>
    </>
  );
};

const ChemicalBuffer = Table;

const ChemicalBufferEntry = (props) => {
  const { act } = useBackend<Data>();
  const { chemical, transferTo } = props;
  return (
    <Table.Row key={chemical.id}>
      <Table.Cell color="label">
        <AnimatedNumber value={chemical.volume} initial={0} />
        {` j. ${chemical.name}`}
      </Table.Cell>
      <Table.Cell collapsing>
        <Button
          content="1"
          onClick={() =>
            act('transfer', {
              id: chemical.id,
              amount: 1,
              to: transferTo,
            })
          }
        />
        <Button
          content="5"
          onClick={() =>
            act('transfer', {
              id: chemical.id,
              amount: 5,
              to: transferTo,
            })
          }
        />
        <Button
          content="10"
          onClick={() =>
            act('transfer', {
              id: chemical.id,
              amount: 10,
              to: transferTo,
            })
          }
        />
        <Button
          content="Wszystko"
          onClick={() =>
            act('transfer', {
              id: chemical.id,
              amount: 1000,
              to: transferTo,
            })
          }
        />
        <Button
          icon="ellipsis-h"
          tooltip="Własna ilość"
          onClick={() =>
            act('transfer', {
              id: chemical.id,
              amount: -1,
              to: transferTo,
            })
          }
        />
      </Table.Cell>
    </Table.Row>
  );
};

const PackagingControlsItem = (props) => {
  const { data } = useBackend<Data>();
  const { label, amountUnit, amount, onChangeAmount, onCreate, sideNote } =
    props;
  const { MaxDispense } = data;
  return (
    <LabeledList.Item label={label}>
      <NumberInput
        width="84px"
        unit={amountUnit}
        step={1}
        stepPixelSize={15}
        value={amount}
        minValue={1}
        maxValue={MaxDispense}
        onChange={onChangeAmount}
      />
      <Button ml={1} content="Utwórz" onClick={onCreate} />
      <Box inline ml={1} color="label">
        {sideNote}
      </Box>
    </LabeledList.Item>
  );
};

const PackagingControls = (props) => {
  const { act, data } = useBackend<Data>();
  // AQ EDIT - NumberInput z tgui-core woła onChange(value), a nie (e, value); undefined w shared state wywalał okno
  const [medipenAmount, setmedipenAmount] = useSharedState('medipenAmount', 1);
  const { condi } = data;
  return (
    <LabeledList>
      {!condi && (
        <PackagingControlsItem
          label="autoinjektory"
          amount={medipenAmount}
          amountUnit="szt."
          sideNote="maks. 10 j."
          onChangeAmount={(value) => setmedipenAmount(value)}
          onCreate={() =>
            act('create', {
              type: 'medipen',
              amount: medipenAmount,
              volume: 'auto',
            })
          }
        />
      )}
    </LabeledList>
  );
};
