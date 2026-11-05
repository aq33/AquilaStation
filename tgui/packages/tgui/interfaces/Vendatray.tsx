import { Box, Button, Flex, Image, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  owner_name: any;
  product_cost: any;
  product_icon: any;
  product_name: any;
  registered: any;
  tray_open: any;
};

export const Vendatray = (props) => {
  const { act, data } = useBackend<Data>();
  const { product_name, product_cost, tray_open, registered, owner_name } =
    data;
  return (
    <Window width={300} height={270}>
      <Window.Content>
        <Flex mb={1}>
          <Flex.Item mr={1}>{!!product_name && <VendingImage />}</Flex.Item>
          <Flex.Item grow={1}>
            <Section fontSize="18px" align="center">
              <b>{product_name ? product_name : 'Pusto'}</b>
              <Box fontSize="16px">
                <i>{product_name ? product_cost : 'N/A'} cr </i>
                <Button icon="pen" onClick={() => act('Adjust')} />
              </Box>
            </Section>
            <>
              <Button
                fluid
                icon="window-restore"
                content={tray_open ? 'Otwarta' : 'Zamknięta'}
                selected={tray_open}
                onClick={() => act('Open')}
              />
              <Button.Confirm
                confirmContent="Na pewno?"
                fluid
                icon="money-bill-wave"
                content="Kup przedmiot"
                disabled={!product_name}
                onClick={() => act('Buy')}
              />
            </>
          </Flex.Item>
        </Flex>
        {registered ? (
          <Section style={{ fontStyle: 'italic' }}>
            Pays to the account of {owner_name}.
          </Section>
        ) : (
          <>
            <Section>Taca nie jest zarejestrowana.</Section>
            <Button
              fluid
              icon="cash-register"
              content="Zarejestruj tacę"
              disabled={registered}
              onClick={() => act('Register')}
            />
          </>
        )}
      </Window.Content>
    </Window>
  );
};

const VendingImage = (props) => {
  const { data } = useBackend<Data>();
  const { product_icon } = data;
  return (
    <Section height="100%">
      <Image
        m={1}
        src={`data:image/jpeg;base64,${product_icon}`}
        height="96px"
        width="96px"
        style={{
          imageRendering: 'pixelated',
          verticalAlign: 'middle',
        }}
      />
    </Section>
  );
};
