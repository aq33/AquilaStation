import { Image } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

type MessageContentProps = {
  contents: string;
  emojis?: BooleanLike;
  /** Lista nazw emotek (icon_states z emoji.dmi); starsze wywołania mogą podać obiekt */
  emoji_names?: string[] | Record<string, unknown>;
  photo?: string;
  photo_width?: number;
  photo_height?: number;
};

/**
 * AQUILA: treść wiadomości PDA z emotkami w formie :nazwa:.
 * Używane też przez MessageMonitor.
 */
export const MessageContent = (props: MessageContentProps) => {
  const {
    contents = '',
    photo,
    photo_width,
    photo_height,
    emojis,
    emoji_names = [],
  } = props;
  const names = Array.isArray(emoji_names)
    ? emoji_names
    : Object.keys(emoji_names);
  const isEmoji = (part: string) => !!emojis && names.includes(part);

  return (
    <>
      {contents.split(':').map((part, index, arr) => {
        if (isEmoji(part)) {
          return <span key={index} className={`chat16x16 emoji-${part}`} />;
        }
        // przywracamy dwukropki zjedzone przez split(),
        // jeśli następny kawałek nie jest emotką
        return (
          <span key={index}>
            {part}
            {arr.length - 1 !== index && !isEmoji(arr[index + 1]) ? ':' : ''}
          </span>
        );
      })}
      {!!photo && (
        <>
          <br />
          <Image
            mt={1}
            width={photo_width ? `${photo_width}px` : undefined}
            height={photo_height ? `${photo_height}px` : undefined}
            src={photo}
          />
        </>
      )}
    </>
  );
};
