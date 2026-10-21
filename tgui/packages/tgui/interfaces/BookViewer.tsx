// AQUILA - czytnik książek na wzór MarkdownViewer z tg.
// Treść naszych książek to HTML (podręczniki, książki z biblioteki), a nie markdown,
// więc zamiast marked() tylko ją oczyszczamy i wyświetlamy.
import { Box } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { sanitizeText } from '../sanitize';

type Data = {
  title: string;
  author: string | null;
  content: string | null;
  width?: number;
  height?: number;
};

export const BookViewer = (props) => {
  const { data } = useBackend<Data>();
  const { title, author, content, width, height } = data;

  return (
    <Window title={title} width={width || 420} height={height || 500}>
      <Window.Content scrollable backgroundColor="#FFFFFF">
        <Box color="black" p={1}>
          {!!author && (
            <Box italic mb={1} fontFamily="monospace">
              Autor: {author}
            </Box>
          )}
          <div
            // eslint-disable-next-line react/no-danger
            dangerouslySetInnerHTML={{
              __html: sanitizeText(content || ''),
            }}
          />
        </Box>
      </Window.Content>
    </Window>
  );
};
