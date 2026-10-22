// Port z Monkestation/Monkestation2.0 (MicrofusionGunControl.jsx)

import { toFixed } from 'common/math';
import {
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type PhaseEmitterData = {
  type: string;
  integrity: number;
  current_heat: number;
  throttle_percentage: number;
  heat_dissipation_per_tick: number;
  max_heat: number;
  damaged: boolean;
  hacked: boolean;
  heat_percent: number;
  process_time: number;
  cooling_system: boolean;
  cooling_system_rate: number;
};

type CellData = {
  type: string;
  charge: number;
  max_charge: number;
  status: boolean;
  attachments: string[];
};

type AttachmentModification = {
  title: string;
  icon: string;
  color: string;
  reference: string;
};

type Attachment = {
  name: string;
  desc: string;
  slot: string;
  information?: string;
  has_modifications: boolean;
  modify?: AttachmentModification[];
  ref: string;
};

type Data = {
  gun_name: string;
  gun_desc: string;
  gun_heat_dissipation: number;
  has_cell: boolean;
  cell_data?: CellData;
  has_emitter: boolean;
  phase_emitter_data?: PhaseEmitterData;
  has_attachments: boolean;
  attachments?: Attachment[];
};

export const MicrofusionGunControl = (props) => {
  const { data } = useBackend<Data>();
  const { gun_name } = data;
  return (
    <Window
      title={`Micron Control Systems Incorporated: ${gun_name}`}
      width={500}
      height={700}
    >
      <Window.Content scrollable>
        <Stack vertical>
          <Stack.Item>
            <GunInfo />
          </Stack.Item>
          <Stack.Item>
            <PowerCell />
          </Stack.Item>
          <Stack.Item>
            <PhaseEmitter />
          </Stack.Item>
          <Stack.Item>
            <Attachments />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const GunInfo = (props) => {
  const { data } = useBackend<Data>();
  const { gun_name, gun_desc, gun_heat_dissipation } = data;
  return (
    <Section title="Broń">
      <LabeledList>
        <LabeledList.Item label="Nazwa">{gun_name}</LabeledList.Item>
        <LabeledList.Item label="Opis">{gun_desc}</LabeledList.Item>
        <LabeledList.Item label="Aktywne chłodzenie">
          {`${gun_heat_dissipation} C/s`}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const PowerCell = (props) => {
  const { act, data } = useBackend<Data>();
  const { has_cell, cell_data } = data;
  return (
    <Section
      title="Ogniwo"
      buttons={
        <Button
          icon="eject"
          disabled={!has_cell}
          onClick={() => act('eject_cell')}
        >
          Wyjmij ogniwo
        </Button>
      }
    >
      {has_cell && cell_data ? (
        <LabeledList>
          <LabeledList.Item label="Typ ogniwa">
            {cell_data.type}
          </LabeledList.Item>
          <LabeledList.Item label="Stan ogniwa">
            {cell_data.status ? 'BŁĄD' : 'W normie'}
          </LabeledList.Item>
          <LabeledList.Item label="Ładunek">
            <ProgressBar
              value={cell_data.charge}
              minValue={0}
              maxValue={cell_data.max_charge}
              ranges={{
                good: [cell_data.max_charge * 0.85, cell_data.max_charge],
                average: [
                  cell_data.max_charge * 0.25,
                  cell_data.max_charge * 0.85,
                ],
                bad: [0, cell_data.max_charge * 0.25],
              }}
            >
              {`${toFixed(cell_data.charge)}/${cell_data.max_charge} MF`}
            </ProgressBar>
          </LabeledList.Item>
          {cell_data.attachments.length > 0 && (
            <LabeledList.Item label="Dodatki ogniwa">
              {cell_data.attachments.join(', ')}
            </LabeledList.Item>
          )}
          {cell_data.charge <= 0 && (
            <LabeledList.Item>
              <NoticeBox color="bad">Ogniwo rozładowane!</NoticeBox>
            </LabeledList.Item>
          )}
        </LabeledList>
      ) : (
        <NoticeBox color="bad">Brak ogniwa!</NoticeBox>
      )}
    </Section>
  );
};

const PhaseEmitter = (props) => {
  const { act, data } = useBackend<Data>();
  const { has_emitter, has_cell, phase_emitter_data, gun_heat_dissipation } =
    data;
  if (!has_emitter || !phase_emitter_data) {
    return (
      <Section title="Emiter fazowy">
        <NoticeBox color="bad">Brak emitera fazowego!</NoticeBox>
      </Section>
    );
  }
  const emitter = phase_emitter_data;
  const total_dissipation =
    emitter.heat_dissipation_per_tick +
    gun_heat_dissipation +
    (emitter.cooling_system ? emitter.cooling_system_rate : 0);
  return (
    <Section
      title="Emiter fazowy"
      buttons={
        <Button icon="eject" onClick={() => act('eject_emitter')}>
          Wyjmij emiter
        </Button>
      }
    >
      {emitter.damaged ? (
        <NoticeBox color="bad">Emiter fazowy jest uszkodzony!</NoticeBox>
      ) : (
        <LabeledList>
          <LabeledList.Item label="Typ emitera">
            {emitter.type}
          </LabeledList.Item>
          <LabeledList.Item label="Temperatura">
            <ProgressBar
              value={emitter.current_heat}
              minValue={0}
              maxValue={emitter.max_heat}
              ranges={{
                bad: [emitter.max_heat * 0.85, emitter.max_heat * 2],
                average: [emitter.max_heat * 0.25, emitter.max_heat * 0.85],
                good: [0, emitter.max_heat * 0.25],
              }}
            >
              {`${toFixed(emitter.current_heat)} C (${emitter.heat_percent}%)`}
            </ProgressBar>
          </LabeledList.Item>
          <LabeledList.Item label="Maksymalna temperatura">
            {`${emitter.max_heat} C`}
          </LabeledList.Item>
          <LabeledList.Item
            label="Próg dławienia termicznego"
            buttons={
              <Button
                icon="wrench"
                color="bad"
                disabled={!emitter.hacked}
                tooltip={
                  emitter.hacked
                    ? undefined
                    : 'Najpierw obejdź zabezpieczenie multitoolem.'
                }
                onClick={() => act('overclock_emitter')}
              >
                Podkręć
              </Button>
            }
          >
            {`${emitter.throttle_percentage}%`}
          </LabeledList.Item>
          <LabeledList.Item label="Pasywne oddawanie ciepła">
            {`${emitter.heat_dissipation_per_tick} C/s`}
          </LabeledList.Item>
          <LabeledList.Item
            label="Układ chłodzenia"
            buttons={
              <Button
                icon="snowflake"
                color={emitter.cooling_system ? 'blue' : 'bad'}
                disabled={!has_cell}
                onClick={() => act('toggle_cooling_system')}
              >
                {emitter.cooling_system ? 'WŁĄCZONY' : 'WYŁĄCZONY'}
              </Button>
            }
          >
            {`Chłodzi o ${emitter.cooling_system_rate} C/s`}
          </LabeledList.Item>
          <LabeledList.Item label="Łączne oddawanie ciepła">
            {`${total_dissipation} C/s`}
          </LabeledList.Item>
          <LabeledList.Item label="Integralność">
            <ProgressBar
              value={emitter.integrity}
              minValue={0}
              maxValue={100}
              ranges={{
                good: [85, 100],
                average: [25, 85],
                bad: [0, 25],
              }}
            >
              {`${toFixed(emitter.integrity)}%`}
            </ProgressBar>
          </LabeledList.Item>
          <LabeledList.Item label="Czas przetwarzania strzału">
            <ProgressBar
              value={emitter.process_time}
              minValue={0}
              maxValue={5}
              ranges={{
                good: [0, 1],
                average: [1, 3],
                bad: [3, 5],
              }}
            >
              {`${emitter.process_time / 10} s`}
            </ProgressBar>
          </LabeledList.Item>
          {emitter.heat_percent >= emitter.throttle_percentage && (
            <LabeledList.Item>
              <NoticeBox color="orange">Dławienie termiczne aktywne!</NoticeBox>
            </LabeledList.Item>
          )}
          {emitter.current_heat >= emitter.max_heat && (
            <LabeledList.Item>
              <NoticeBox color="bad">Przegrzanie!</NoticeBox>
            </LabeledList.Item>
          )}
        </LabeledList>
      )}
    </Section>
  );
};

const Attachments = (props) => {
  const { act, data } = useBackend<Data>();
  const { has_attachments, attachments = [] } = data;
  return (
    <Section title="Dodatki">
      {has_attachments ? (
        attachments.map((attachment) => (
          <Section
            key={attachment.ref}
            title={attachment.name}
            buttons={
              <Button
                icon="eject"
                onClick={() =>
                  act('remove_attachment', {
                    attachment_ref: attachment.ref,
                  })
                }
              >
                Zdejmij
              </Button>
            }
          >
            <LabeledList>
              <LabeledList.Item label="Opis">
                {attachment.desc}
              </LabeledList.Item>
              <LabeledList.Item label="Slot">
                {attachment.slot}
              </LabeledList.Item>
              {!!attachment.information && (
                <LabeledList.Item label="Informacje">
                  {attachment.information}
                </LabeledList.Item>
              )}
              {!!attachment.has_modifications &&
                attachment.modify?.map((mod) => (
                  <LabeledList.Item
                    key={mod.reference}
                    buttons={
                      <Button
                        icon={mod.icon}
                        color={mod.color}
                        onClick={() =>
                          act('modify_attachment', {
                            attachment_ref: attachment.ref,
                            modify_ref: mod.reference,
                          })
                        }
                      >
                        {mod.title}
                      </Button>
                    }
                  />
                ))}
            </LabeledList>
          </Section>
        ))
      ) : (
        <NoticeBox color="blue">Brak zamontowanych dodatków!</NoticeBox>
      )}
    </Section>
  );
};
