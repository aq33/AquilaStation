import { PropsWithChildren } from 'react';
import { Button, Icon } from 'tgui-core/components';
import { UI_DISABLED, UI_INTERACTIVE, UI_UPDATE } from 'tgui-core/constants';
import { BooleanLike, classes } from 'tgui-core/react';
import { toTitleCase } from 'tgui-core/string';

import { globalStore } from '../backend';
import { toggleKitchenSink } from '../debug/actions';
import { isTranslating, translateUiText } from '../i18n'; // AQ EDIT - i18n tytułu okna

type TitleBarProps = Partial<{
  className: string;
  title: string;
  status: number;
  canClose: BooleanLike;
  onClose: (e) => void;
  onDragStart: (e) => void;
}> &
  PropsWithChildren;

function statusToColor(status: number): string {
  switch (status) {
    case UI_INTERACTIVE:
      return 'good';
    case UI_UPDATE:
      return 'average';
    case UI_DISABLED:
    default:
      return 'bad';
  }
}

export function TitleBar(props: TitleBarProps) {
  const { className, title, status, canClose, onDragStart, onClose, children } =
    props;
  const dispatch = globalStore.dispatch;

  // AQ EDIT START - i18n: tytuł (nazwa obiektu) tłumaczony przed toTitleCase, słownik ma małe litery
  const source =
    typeof title === 'string' && isTranslating()
      ? translateUiText(title)
      : title;
  const finalTitle =
    (typeof source === 'string' &&
      source === source.toLowerCase() &&
      toTitleCase(source)) ||
    source;
  // AQ EDIT END

  return (
    <div className={classes(['TitleBar', className])}>
      <div
        className="TitleBar__dragZone"
        onMouseDown={(e) => onDragStart?.(e)}
      />
      {status === undefined ? (
        <Icon className="TitleBar__statusIcon" name="tools" opacity={0.5} />
      ) : (
        <Icon
          className="TitleBar__statusIcon"
          color={statusToColor(status)}
          name={status === UI_DISABLED ? 'eye-slash' : 'eye'}
        />
      )}
      <div className="TitleBar__title">{finalTitle}</div>
      {!!children && <div className="TitleBar__buttons">{children}</div>}
      {process.env.NODE_ENV !== 'production' && (
        <Button
          className="TitleBar__buttons TitleBar__KitchenSink"
          icon="bug"
          onClick={() => dispatch(toggleKitchenSink())}
        />
      )}
      {!!canClose && (
        <div className="TitleBar__close" onClick={onClose}>
          <Icon className="TitleBar__close--icon" name="times" />
        </div>
      )}
    </div>
  );
}
