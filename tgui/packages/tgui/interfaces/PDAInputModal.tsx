import { useBackend } from '../backend';
import { Box, Button, Flex, Input, TextArea } from '../components';
import { Window } from '../layouts';

type Data = {
  everyone: any;
  image: any;
  job: any;
  name: any;
  target: any;
  text: any;
  theme: any;
};

export const PDAInputModal = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    name,
    job,
    text,
    image,
    target = 'Wybierz PDA',
    everyone,
    theme,
  } = data;
  return (
    <Window title="Wyślij wiadomość PDA" theme={theme} width={600} height={290}>
      <Window.Content>
        <Box>
          <Box inline color="label">
            Do:{' '}
          </Box>
          <Button
            ml={1}
            icon={target !== 'Select PDA' || everyone ? 'envelope' : undefined}
            content={everyone ? 'Wszyscy' : target}
            onClick={() => act('select')}
          />
        </Box>
        <Box mt={1}>
          <Box inline color="label">
            Imię:
          </Box>
          <Input
            value={name}
            maxLength={32}
            fluid
            onChange={(value) => act('set_name', { value })}
          />
        </Box>
        <Box mt={1}>
          <Box inline color="label">
            Zawód:
          </Box>
          <Input
            value={job}
            maxLength={16}
            fluid
            onChange={(value) => act('set_job', { value })}
          />
        </Box>
        <Box mt={1}>
          <Box inline color="label">
            Załącznik:{' '}
          </Box>
          <Button
            ml={1}
            icon="camera"
            content={'Skanuj zdjęcie'}
            color={image ? 'good' : undefined}
            onClick={() => act('photo')}
          />
        </Box>
        <Box mt={0.5}>
          <Box inline color="label">
            Wiadomość:
          </Box>
          <TextArea
            mt={0.25}
            value={text}
            maxLength={1024}
            fluid
            height="60px"
            onChange={(value) => act('set_message', { value })}
          />
        </Box>
        <Flex
          width="100%"
          height="45px"
          fontSize={1.75}
          style={{
            justifyContent: 'center',
            alignContent: 'center',
            alignItems: 'center',
          }}
        >
          <Flex.Item mr={1} grow={1} basis={0} height="80%">
            <Button
              align="center"
              height="100%"
              fluid
              content="Wyślij"
              color="good"
              onClick={() => act('submit')}
            />
          </Flex.Item>
          <Flex.Item ml={1} grow={1} basis={0} height="80%">
            <Button
              align="center"
              height="100%"
              fluid
              content="Anuluj"
              color="bad"
              onClick={() => act('cancel')}
            />
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
