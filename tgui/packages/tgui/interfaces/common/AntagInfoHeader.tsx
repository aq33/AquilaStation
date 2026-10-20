import { resolveAsset } from '../../assets';
import { Box, Image, Section, Stack } from '../../components';

type Props = {
  name: string;
  asset?: string;
  color?: string;
};

export const AntagInfoHeader = (props: Props) => {
  const { name, asset, color } = props;
  return (
    <Section>
      <Stack className="AntagInfo__header_outer">
        {!!asset && (
          <Stack.Item className="AntagInfo__header_img">
            <Image
              src={resolveAsset(asset)}
              width="64px"
              style={{
                imageRendering: 'pixelated',
              }}
            />
          </Stack.Item>
        )}
        <Stack.Item grow className="AntagInfo__header_text">
          <h1>
            You are the{' '}
            <Box inline textColor={color || 'red'}>
              {name}
            </Box>
            !
          </h1>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
