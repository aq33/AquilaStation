import {
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { getGasLabel } from '../../constants';
import type { ScrubberData, VentData } from './types';

// AQUILA: Vent i Scrubber jak w common/AtmosControls z tg, ale po polsku
// i pod nasz DM: urządzenia adresowane przez id_tag (sygnał radiowy),
// bez podkręcania (overclock) i wytrzymałości, których nie mamy.

export const Vent = (props: VentData) => {
  const { act } = useBackend();
  const {
    id_tag,
    long_name,
    power,
    checks,
    excheck,
    incheck,
    direction,
    external,
    internal,
    extdefault,
    intdefault,
  } = props;
  const releasing = direction === 'release';
  return (
    <Section
      title={decodeHtmlEntities(long_name)}
      buttons={
        <Button
          icon={power ? 'power-off' : 'times'}
          selected={power}
          content={power ? 'Wł.' : 'Wył.'}
          onClick={() =>
            act('power', {
              id_tag,
              val: Number(!power),
            })
          }
        />
      }
    >
      <LabeledList>
        <LabeledList.Item label="Tryb">
          <Button
            icon="sign-in-alt"
            content={releasing ? 'Nadmuch' : 'Wysysanie'}
            color={!releasing && 'danger'}
            onClick={() =>
              act('direction', {
                id_tag,
                val: Number(!releasing),
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Regulator ciśnienia">
          <Button
            icon="sign-in-alt"
            content="Wewnętrzny"
            selected={incheck}
            onClick={() =>
              act('incheck', {
                id_tag,
                val: checks,
              })
            }
          />
          <Button
            icon="sign-out-alt"
            content="Zewnętrzny"
            selected={excheck}
            onClick={() =>
              act('excheck', {
                id_tag,
                val: checks,
              })
            }
          />
        </LabeledList.Item>
        {!!incheck && (
          <LabeledList.Item label="Cel wewnętrzny">
            <NumberInput
              value={Math.round(internal)}
              unit="kPa"
              width="75px"
              minValue={0}
              step={10}
              maxValue={5066}
              onChange={(value) =>
                act('set_internal_pressure', {
                  id_tag,
                  value,
                })
              }
            />
            <Button
              icon="undo"
              disabled={intdefault}
              content="Domyślne"
              onClick={() =>
                act('reset_internal_pressure', {
                  id_tag,
                })
              }
            />
          </LabeledList.Item>
        )}
        {!!excheck && (
          <LabeledList.Item label="Cel zewnętrzny">
            <NumberInput
              value={Math.round(external)}
              unit="kPa"
              width="75px"
              minValue={0}
              step={10}
              maxValue={5066}
              onChange={(value) =>
                act('set_external_pressure', {
                  id_tag,
                  value,
                })
              }
            />
            <Button
              icon="undo"
              disabled={extdefault}
              content="Domyślne"
              onClick={() =>
                act('reset_external_pressure', {
                  id_tag,
                })
              }
            />
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};

export const Scrubber = (props: ScrubberData) => {
  const { act } = useBackend();
  const { long_name, power, scrubbing, id_tag, widenet, filter_types } = props;
  return (
    <Section
      title={decodeHtmlEntities(long_name)}
      buttons={
        <Button
          icon={power ? 'power-off' : 'times'}
          content={power ? 'Wł.' : 'Wył.'}
          selected={power}
          onClick={() =>
            act('power', {
              id_tag,
              val: Number(!power),
            })
          }
        />
      }
    >
      <LabeledList>
        <LabeledList.Item label="Tryb">
          <Button
            icon={scrubbing ? 'filter' : 'sign-in-alt'}
            color={!scrubbing && 'danger'}
            content={scrubbing ? 'Filtrowanie' : 'Wysysanie'}
            onClick={() =>
              act('scrubbing', {
                id_tag,
                val: Number(!scrubbing),
              })
            }
          />
          <Button
            icon={widenet ? 'expand' : 'compress'}
            selected={widenet}
            content={widenet ? 'Szeroki zasięg' : 'Zwykły zasięg'}
            onClick={() =>
              act('widenet', {
                id_tag,
                val: Number(!widenet),
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Filtry">
          {(scrubbing &&
            (filter_types || []).map((filter) => (
              <Button
                key={filter.gas_id}
                icon={filter.enabled ? 'check-square-o' : 'square-o'}
                tooltip={filter.gas_name}
                selected={filter.enabled}
                onClick={() =>
                  act('toggle_filter', {
                    id_tag,
                    val: filter.gas_id,
                  })
                }
              >
                {getGasLabel(filter.gas_id, filter.gas_name)}
              </Button>
            ))) ||
            'b.d.'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
