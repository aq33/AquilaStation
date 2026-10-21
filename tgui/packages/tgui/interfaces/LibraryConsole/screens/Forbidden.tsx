import { useBackend } from 'tgui/backend';
import { Box, Button, Modal, Stack } from 'tgui-core/components';

const description =
  'Abf vqrnz cebprffhf pbzchgngvbanyvf fghqrer vapvcvrzhf\nCebprffhf pbzchgngvbanyrf fhag erf nofgenpgnr dhnr pbzchgngberf vapbyhag\nHg ribyihag, cebprffhf nyvn nofgenpgn dhnr qngn znavchyner qvphaghe\nRibyhgvbavf cebprffhf qvevtvghe cre rkrzcyhz erthynr cebtenzzngvf ibpngv\nUbzvarf cebtenzzngn nq cebprffhf erpgbf rssvpvhag\nEriren fcvevghf pbzchgngbevv phz vapnagnzragvf pbavhatvzhf\nCebprffhf pbzchgngvbanyvf rfg zhyghz fvzvyvf vqrnr irarsvpnr fcvevghf\nivqrev nhg gnatv aba cbgrfg\nAba rfg rk zngrevn pbzcbfvgn\nFrq vq cynpreng vcfhz\nAba cbgrfg bcrenev bchf vagryyrpghnyr\nErfcbaqrev cbgrfg\nZhaqhz nssvprer cbgrfg rebtnaqb crphavnz nq evcnz iry cre oenppuvhz \nebobgv snoevpnaqb zbqrenaqb\nPbafvyvvf hgvzhe cebprffvohf nhthenaqv fhag fvphg vapnagnzragn irarsvpvv';

export function Forbidden(props) {
  return (
    <Box className="LibraryComputer__CultNonsense" preserveWhitespace>
      {description}
      <ForbiddenModal />
    </Box>
  );
}

function ForbiddenModal(props) {
  const { act } = useBackend();

  return (
    <Modal>
      <Box className="LibraryComputer__CultText" fontSize="28px">
        Dostęp do Skarbca Zakazanej Wiedzy v 1.3:
      </Box>
      <Box className="LibraryComputer__CultText" pt={0.4}>
        Czy na pewno chcesz kontynuować?
      </Box>
      <Box className="LibraryComputer__CultText" pt={0.2} bold>
        EldritchRelics Inc. nie ponosi odpowiedzialności za ten wybór
      </Box>
      <Stack justify="center" align="center">
        <Stack.Item>
          <Button
            className="LibraryComputer__CultText"
            fluid
            icon="check"
            color="good"
            fontSize="20px"
            onClick={() => act('lore_spawn')}
            lineHeight={2}
          >
            Zgadzam się
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            className="LibraryComputer__CultText"
            fluid
            icon="times"
            color="bad"
            fontSize="20px"
            onClick={() => act('lore_deny')}
            lineHeight={2}
          >
            Odmawiam
          </Button>
        </Stack.Item>
      </Stack>
    </Modal>
  );
}
