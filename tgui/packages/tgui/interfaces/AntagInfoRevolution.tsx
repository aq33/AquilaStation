import { Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Head = {
  name: string;
  role: string;
};

// AQUILA: bez słów kodowych i wytycznej dla nawróconych z tg (nie mamy
// tych mechanik); werbunek odbywa się przemową, a nie fleszem.
type Info = {
  antag_name: string;
  leader: BooleanLike;
  heads: Head[];
  lone_wolf: BooleanLike;
};

export const AntagInfoRevolution = () => {
  const { data } = useBackend<Info>();
  const { leader, heads = [], lone_wolf } = data;

  return (
    <Window width={400} height={leader ? 450 : 400}>
      <Window.Content>
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item textColor="red" fontSize="24px" textAlign="center">
              Viva la revolución!
            </Stack.Item>
            <Stack.Item>
              {leader ? (
                <Stack vertical>
                  {lone_wolf ? (
                    <Stack.Item>
                      - Jesteś jedynym przywódcą rewolucji. Działaj szybko i
                      zdecydowanie - gdy rewolucja urośnie, kolejni
                      rewolucjoniści zostaną awansowani na przywódców.
                    </Stack.Item>
                  ) : (
                    <Stack.Item>
                      - Rewolucja ma kilku przywódców. Współpracujcie i ustalcie
                      plan, ZANIM zaczniecie werbować załogę - wczesne
                      zdemaskowanie może się skończyć bardzo źle.
                    </Stack.Item>
                  )}
                  <Stack.Item>
                    - Werbuj załogę zdolnością &quot;Nawrócenie
                    rewolucyjne&quot;: przekonuj stojącą blisko, przytomną
                    osobę. Atak na cel albo przerwanie przemowy psuje werbunek.
                  </Stack.Item>
                  <Stack.Item>
                    - Implant ochrony umysłu chroni przed werbunkiem.
                    Wszczepiony HUD ochrony pokaże ci, kto go ma.
                  </Stack.Item>
                  <Stack.Item>
                    - Rewolucja przegrywa, jeśli ty i pozostali przywódcy
                    zginiecie albo traficie na wygnanie. Nie dopuść do tego!
                  </Stack.Item>
                </Stack>
              ) : (
                <Stack vertical>
                  <Stack.Item>
                    - Wspieraj sprawę. Nie krzywdź towarzyszy walki o wolność.
                  </Stack.Item>
                  <Stack.Item>
                    - Towarzyszy rozpoznasz po czerwonych ikonach &quot;R&quot;,
                    a przywódców po niebieskich.
                  </Stack.Item>
                  <Stack.Item>
                    - Rewolucja przegrywa, jeśli wszyscy przywódcy zginą albo
                    trafią na wygnanie. Nie dopuść do tego!
                  </Stack.Item>
                </Stack>
              )}
            </Stack.Item>
            {heads.length > 0 && (
              <>
                <Stack.Divider />
                <Stack.Item>
                  <Stack vertical>
                    <Stack.Item fontSize="16px" textAlign="center">
                      Musisz zabić albo wygnać szefów działów:
                    </Stack.Item>
                    {heads.map((head, i) => (
                      <Stack.Item key={`head-${i}`}>
                        - {head.name} ({head.role})
                      </Stack.Item>
                    ))}
                  </Stack>
                </Stack.Item>
              </>
            )}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
