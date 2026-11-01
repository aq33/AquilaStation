import { Box } from 'tgui-core/components';

export const BeakerContents = (props) => {
  const { beakerLoaded, beakerContents } = props;
  return (
    <Box>
      {(!beakerLoaded && <Box color="label">Nie włożono zlewki.</Box>) ||
        (beakerContents.length === 0 && (
          <Box color="label">Zlewka jest pusta.</Box>
        ))}
      {beakerContents.map((chemical) => (
        <Box key={chemical.name} color="label">
          {chemical.volume} j. {chemical.name}
        </Box>
      ))}
    </Box>
  );
};
