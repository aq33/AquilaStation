import { Box, Button, Flex } from 'tgui-core/components';

import { DATATYPE_NAMES, getConnectedRefs } from './constants';
import { FUNDAMENTAL_DATA_TYPES } from './FundamentalTypes';

export const DisplayName = (props) => {
  const { port, isOutput, componentId, portIndex, act, ...rest } = props;

  // W naszym DM typ null oznacza port przyjmujący dowolne dane.
  const portType = port.type || 'any';
  const InputComponent = FUNDAMENTAL_DATA_TYPES[portType];

  const hasInput =
    !isOutput &&
    !getConnectedRefs(port).length &&
    !!componentId &&
    InputComponent;

  const displayType = DATATYPE_NAMES[portType] || portType;

  return (
    <Box {...rest}>
      <Flex direction="column">
        <Flex.Item textAlign={isOutput ? 'right' : 'left'}>
          {hasInput ? (
            <InputComponent
              setValue={(val, extraParams) =>
                act('set_component_input', {
                  component_id: componentId,
                  port_id: portIndex,
                  input: val,
                  ...extraParams,
                })
              }
              color={port.color}
              name={port.name}
              value={port.current_data}
            />
          ) : isOutput ? (
            <Button
              compact
              color="transparent"
              tooltip="Pokaż bieżącą wartość"
              onClick={() =>
                act('get_component_value', {
                  component_id: componentId,
                  port_id: portIndex,
                })
              }
            >
              <Box color="white">{port.name}</Box>
            </Button>
          ) : (
            port.name
          )}
        </Flex.Item>
        <Flex.Item>
          <Box
            fontSize={0.75}
            opacity={0.5}
            textAlign={isOutput ? 'right' : 'left'}
          >
            {displayType}
          </Box>
        </Flex.Item>
      </Flex>
    </Box>
  );
};
