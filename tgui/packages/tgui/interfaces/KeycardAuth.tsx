import { Box, Button, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  waiting: number;
  auth_required: number | string;
  // NSV13: -1 poza overmapą, 0 zabezpieczenia aktywne, 1 obejście włączone
  ftl_safety_override: number;
};

export const KeycardAuth = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window width={375} height={150}>
      <Window.Content>
        <Section>
          <Box>
            {data.waiting === 1 && (
              <span>Oczekiwanie na potwierdzenie z drugiego urządzenia...</span>
            )}
          </Box>
          <Box>
            {data.waiting === 0 && (
              <>
                {!!data.auth_required && (
                  <Button
                    icon="check-square"
                    color="red"
                    textAlign="center"
                    lineHeight="60px"
                    fluid
                    onClick={() => act('auth_swipe')}
                  >
                    Autoryzuj
                  </Button>
                )}
                {data.auth_required === 0 && (
                  <>
                    <Button
                      icon="exclamation-triangle"
                      fluid
                      onClick={() => act('red_alert')}
                    >
                      Alarm czerwony
                    </Button>
                    <Button
                      icon="wrench"
                      fluid
                      onClick={() => act('emergency_maint')}
                    >
                      Awaryjny dostęp do tuneli technicznych
                    </Button>
                    <Button
                      icon="meteor"
                      fluid
                      onClick={() => act('bsa_unlock')}
                    >
                      Odblokowanie artylerii bluespace
                    </Button>
                    {data.ftl_safety_override >= 0 && (
                      <Button
                        icon="exclamation-triangle"
                        fluid
                        onClick={() => act('ftl_safety_override')}
                      >
                        Obejście zabezpieczeń napędu FTL
                      </Button>
                    )}
                  </>
                )}
              </>
            )}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
