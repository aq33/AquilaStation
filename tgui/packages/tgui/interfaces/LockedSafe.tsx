import { Box, Flex } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { NukeKeypad } from './NuclearBomb';

type Data = {
  input_code: string;
  locked: BooleanLike;
  lock_code: BooleanLike;
  // AQUILA: uszkodzona pamięć zamka (l_setshort)
  memory_error: BooleanLike;
};

export const LockedSafe = (props) => {
  const { data } = useBackend<Data>();
  const { input_code, locked, lock_code, memory_error } = data;
  return (
    <Window width={300} height={400} theme="ntos">
      <Window.Content>
        <Box m="6px">
          <Box mb="6px" className="NuclearBomb__displayBox">
            {input_code || '-----'}
          </Box>
          <Box className="NuclearBomb__displayBox">
            {!!memory_error && 'BŁĄD PAMIĘCI 6040 201'}
            {!memory_error && !lock_code && 'Ustaw 5-cyfrowy kod.'}
            {!memory_error &&
              !!lock_code &&
              (!locked ? 'Odblokowany' : 'Zablokowany')}
          </Box>
          <Flex ml="3px" mt="10px">
            <Flex.Item>
              <NukeKeypad />
            </Flex.Item>
          </Flex>
        </Box>
      </Window.Content>
    </Window>
  );
};
