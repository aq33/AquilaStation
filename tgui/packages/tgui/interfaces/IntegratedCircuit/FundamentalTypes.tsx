import { Button, Input, NumberInput, Stack } from 'tgui-core/components';

import { BasicInput } from './BasicInput';

// Typy z tg, których nasz wiremod nie ma (option, datum, boolean), pominięte.
export const FUNDAMENTAL_DATA_TYPES = {
  string: (props) => {
    const { name, value, setValue } = props;
    return (
      <BasicInput name={name} setValue={setValue} value={value} defaultValue="">
        <Input
          placeholder={name}
          value={value}
          onBlur={(value) => setValue(value)}
          onEnter={(value) => setValue(value)}
          width="96px"
        />
      </BasicInput>
    );
  },
  number: (props) => {
    const { name, value, setValue, color } = props;
    return (
      <BasicInput
        name={name}
        setValue={setValue}
        value={value}
        defaultValue={0}
      >
        <NumberInput
          step={1}
          minValue={-Infinity}
          maxValue={Infinity}
          value={value}
          color={color}
          onChange={(val) => setValue(val)}
          unit={name}
        />
      </BasicInput>
    );
  },
  entity: (props) => {
    const { name, setValue } = props;
    return (
      <Button
        color="transparent"
        icon="upload"
        compact
        tooltip="Ustaw obiekt oznaczony znacznikiem obwodów"
        onClick={() => setValue(null, { marked_atom: true })}
      >
        {name}
      </Button>
    );
  },
  signal: (props) => {
    const { name, setValue } = props;
    return (
      <Button color="transparent" compact onClick={() => setValue()}>
        {name}
      </Button>
    );
  },
  any: (props) => {
    const { name, value, setValue, color } = props;
    return (
      <BasicInput name={name} setValue={setValue} value={value} defaultValue="">
        <Stack>
          <Stack.Item>
            <Button
              color={color}
              icon="upload"
              tooltip="Ustaw obiekt oznaczony znacznikiem obwodów"
              onClick={() => setValue(null, { marked_atom: true })}
            />
          </Stack.Item>
          <Stack.Item>
            <Input
              placeholder={name}
              value={value}
              onBlur={(value) => setValue(value)}
              onEnter={(value) => setValue(value)}
              width="64px"
            />
          </Stack.Item>
        </Stack>
      </BasicInput>
    );
  },
};
