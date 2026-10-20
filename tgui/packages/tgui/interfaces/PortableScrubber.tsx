import { Button, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { getGasLabel } from '../constants';
import { Window } from '../layouts';
import { PortableBasicInfo } from './PortablePump/PortableAtmos';

// AQUILA: klucze w snake_case, jak wysyła nasz DM (portable/scrubber.dm).
type Data = {
  filter_types: Filter[];
};

type Filter = {
  enabled: BooleanLike;
  gas_id: string;
  gas_name: string;
};

export const PortableScrubber = (props) => {
  const { act, data } = useBackend<Data>();
  const { filter_types = [] } = data;

  return (
    <Window width={320} height={420}>
      <Window.Content>
        <PortableBasicInfo />
        <Section title="Filtry">
          {filter_types.map((filter) => (
            <Button
              key={filter.gas_id}
              icon={filter.enabled ? 'check-square-o' : 'square-o'}
              content={getGasLabel(filter.gas_id, filter.gas_name)}
              selected={filter.enabled}
              onClick={() =>
                act('toggle_filter', {
                  val: filter.gas_id,
                })
              }
            />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
