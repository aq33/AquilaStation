/**
 * AQUILA: teksty okien tgui przez tłumacza już przy budowie (loader webpacka przed swc-loader).
 *
 * Okna mają teksty po polsku w JSX. Zamiast podmieniać gotowy tekst na stronie
 * (tgui/i18nDom.ts zostaje jako zapas dla danych z DM), loader owija teksty z kodu
 * w wywołania tłumacza z tgui/i18n.ts:
 *   tekst JSX                         -> {__i18nT("tekst")}
 *   zdanie z wstawkami {wyrażenie}     -> {__i18nTT(["tekst ", " dalej"], [wyrażenie])}
 *   {`literał ${x}`} jako całe dziecko -> {__i18nTS(["literał ", ""], [x])}
 *   title/label/tooltip/content/placeholder z napisem -> ={__i18nT("...")} albo __i18nTS
 * Granice zdań i wstawek bierzemy z drzewa składni TypeScriptu. Biały znak tekstu JSX
 * liczymy jak Babel i SWC, więc dla gracza z PL wynik jest ten sam co bez loadera.
 * Zdanie z encją HTML (&nbsp;) zostaje bez zmian (JSX dekoduje encje, my nie).
 *
 * Ten sam plik jako skrypt wypisuje zdania wszystkich okien (tools/i18n/ui_coverage.py):
 *   node i18n-jsx.cjs dump <plik wyjściowy>
 */
const fs = require('fs');
const path = require('path');
const ts = require('typescript');

const ATTRIBUTES = new Set([
  'title',
  'label',
  'tooltip',
  'content',
  'placeholder',
]);
const LETTERS = /\p{L}{2}/u;
const IMPORT =
  "import { t as __i18nT, tt as __i18nTT, ts as __i18nTS } from 'tgui/i18n';\n";
/** Pliki okien: nie sam tłumacz, nie testy, nie okno mówienia (etykiety ma w kodzie) */
const INCLUDED =
  /[\\/]packages[\\/](tgui|tgui-panel|tgui-escape-menu)[\\/].*\.[jt]sx$/;
const EXCLUDED = /[\\/]i18n|\.test\.[jt]sx?$|[\\/]__tests__[\\/]/;

/** Tekst JSX tak, jak go wyrenderuje React (algorytm Babel cleanJSXElementLiteralChild) */
function cleanJsxText(raw) {
  const lines = raw.split(/\r\n|\n|\r/);
  let lastNonEmpty = 0;
  lines.forEach((line, i) => {
    if (/[^ \t]/.test(line)) {
      lastNonEmpty = i;
    }
  });
  let out = '';
  lines.forEach((line, i) => {
    let trimmed = line.replace(/\t/g, ' ');
    if (i !== 0) {
      trimmed = trimmed.replace(/^[ ]+/, '');
    }
    if (i !== lines.length - 1) {
      trimmed = trimmed.replace(/[ ]+$/, '');
    }
    if (trimmed) {
      if (i !== lastNonEmpty) {
        trimmed += ' ';
      }
      out += trimmed;
    }
  });
  return out;
}

function containsJsx(node) {
  let found = false;
  const walk = (n) => {
    if (found) {
      return;
    }
    if (
      ts.isJsxElement(n) ||
      ts.isJsxSelfClosingElement(n) ||
      ts.isJsxFragment(n)
    ) {
      found = true;
      return;
    }
    ts.forEachChild(n, walk);
  };
  walk(node);
  return found;
}

function stringValue(expr) {
  if (ts.isStringLiteral(expr) || ts.isNoSubstitutionTemplateLiteral(expr)) {
    return expr.text;
  }
  return null;
}

/** Literał `a${x}b` -> teksty i źródła wyrażeń */
function templateParts(expr, source, sf) {
  const texts = [expr.head.text];
  const slots = [];
  for (const span of expr.templateSpans) {
    slots.push(source.slice(span.expression.getStart(sf), span.expression.end));
    texts.push(span.literal.text);
  }
  return { texts, slots };
}

/**
 * Zdania i napisy do owinięcia: lista {start, end, kind, texts, slots}.
 * kind: "t" (sam tekst), "tt" (zdanie z wstawkami w JSX), "ts" (literał z wstawkami).
 */
function collect(source, fileName) {
  const sf = ts.createSourceFile(
    fileName,
    source,
    ts.ScriptTarget.Latest,
    true,
    ts.ScriptKind.TSX,
  );
  const found = [];

  function finish(run) {
    if (!run || !run.parts.length || run.unsafe) {
      return;
    }
    const texts = [''];
    const slots = [];
    for (const part of run.parts) {
      if (part.kind === 't') {
        texts[texts.length - 1] += part.text;
      } else {
        slots.push(part);
        texts.push('');
      }
    }
    // samo dziecko {`literał ${x}`}: tekst jest w literale
    if (
      slots.length === 1 &&
      texts.every((t) => !t.trim()) &&
      ts.isTemplateExpression(slots[0].node)
    ) {
      const inner = templateParts(slots[0].node, source, sf);
      if (LETTERS.test(inner.texts.join(''))) {
        found.push({
          start: run.start,
          end: run.end,
          kind: 'ts',
          texts: inner.texts,
          slots: inner.slots,
          lead: texts[0],
          trail: texts[1],
        });
      }
      return;
    }
    if (!LETTERS.test(texts.join(''))) {
      return;
    }
    found.push({
      start: run.start,
      end: run.end,
      kind: slots.length ? 'tt' : 't',
      texts,
      slots: slots.map((s) => s.src),
    });
  }

  function children(list) {
    let run = null;
    const begin = (node) => {
      if (!run) {
        run = {
          parts: [],
          start: node.getStart(sf),
          end: node.end,
          unsafe: false,
        };
      }
      run.end = node.end;
    };
    for (const child of list) {
      if (ts.isJsxText(child)) {
        const raw = source.slice(child.pos, child.end);
        begin(child);
        run.start = Math.min(run.start, child.pos);
        if (raw.includes('&')) {
          run.unsafe = true;
        }
        run.parts.push({ kind: 't', text: cleanJsxText(raw) });
        continue;
      }
      if (ts.isJsxExpression(child)) {
        const expr = child.expression;
        if (!expr) {
          if (run) {
            run.end = child.end; // komentarz JSX w środku zdania
          }
          continue;
        }
        if (child.dotDotDotToken || containsJsx(expr)) {
          finish(run);
          run = null;
          continue;
        }
        begin(child);
        const value = stringValue(expr);
        if (value !== null) {
          run.parts.push({ kind: 't', text: value });
        } else {
          run.parts.push({
            kind: 'e',
            src: source.slice(expr.getStart(sf), expr.end),
            node: expr,
          });
        }
        continue;
      }
      finish(run);
      run = null;
    }
    finish(run);
  }

  function attribute(node) {
    if (
      !ts.isIdentifier(node.name) ||
      !ATTRIBUTES.has(node.name.text) ||
      !node.initializer
    ) {
      return;
    }
    const init = node.initializer;
    if (ts.isStringLiteral(init)) {
      const raw = source.slice(init.getStart(sf), init.end);
      if (!raw.includes('&') && LETTERS.test(init.text)) {
        found.push({
          start: init.getStart(sf),
          end: init.end,
          kind: 't',
          texts: [init.text],
          slots: [],
          attribute: true,
        });
      }
      return;
    }
    if (!ts.isJsxExpression(init) || !init.expression) {
      return;
    }
    const expr = init.expression;
    const value = stringValue(expr);
    if (value !== null) {
      if (LETTERS.test(value)) {
        found.push({
          start: expr.getStart(sf),
          end: expr.end,
          kind: 't',
          texts: [value],
          slots: [],
          attribute: true,
          inExpression: true,
        });
      }
    } else if (ts.isTemplateExpression(expr)) {
      const inner = templateParts(expr, source, sf);
      if (LETTERS.test(inner.texts.join(''))) {
        found.push({
          start: expr.getStart(sf),
          end: expr.end,
          kind: 'ts',
          texts: inner.texts,
          slots: inner.slots,
          attribute: true,
          inExpression: true,
        });
      }
    }
  }

  function visit(node) {
    if (ts.isJsxElement(node) || ts.isJsxFragment(node)) {
      children(node.children);
    } else if (ts.isJsxAttribute(node)) {
      attribute(node);
    }
    ts.forEachChild(node, visit);
  }
  visit(sf);
  return found;
}

function replacement(item) {
  const texts = JSON.stringify(item.texts);
  const slots = `[${item.slots.join(', ')}]`;
  let call;
  if (item.kind === 't') {
    call = `__i18nT(${JSON.stringify(item.texts[0])})`;
  } else if (item.kind === 'tt') {
    call = `__i18nTT(${texts}, ${slots})`;
  } else {
    call = `__i18nTS(${texts}, ${slots})`;
  }
  if (item.inExpression) {
    return call;
  }
  if (item.attribute) {
    return `{${call}}`;
  }
  // biały znak wokół samego literału w dziecku zostaje jako tekst JSX
  const lead = item.lead ? `{${JSON.stringify(item.lead)}}` : '';
  const trail = item.trail ? `{${JSON.stringify(item.trail)}}` : '';
  return `${lead}{${call}}${trail}`;
}

/** Kod pliku z owiniętymi tekstami (bez zmian, gdy nic nie ma do owinięcia) */
function transform(source, fileName) {
  const items = collect(source, fileName).sort((a, b) => b.start - a.start);
  if (!items.length) {
    return source;
  }
  let out = source;
  let limit = Infinity;
  for (const item of items) {
    if (item.end > limit) {
      continue; // nakładanie się nie powinno się zdarzyć; na wszelki wypadek zostawiamy tekst
    }
    out = out.slice(0, item.start) + replacement(item) + out.slice(item.end);
    limit = item.start;
  }
  return IMPORT + out;
}

module.exports = function i18nJsxLoader(source) {
  const file = this.resourcePath || '';
  if (!INCLUDED.test(file) || EXCLUDED.test(file)) {
    return source;
  }
  return transform(source, file);
};
module.exports.transform = transform;
module.exports.collect = collect;
module.exports.cleanJsxText = cleanJsxText;

/** node i18n-jsx.cjs dump <plik>: zdania wszystkich okien do testu pokrycia */
if (require.main === module && process.argv[2] === 'dump') {
  const out = [];
  const walk = (dir) => {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      const full = path.join(dir, entry.name);
      if (entry.isDirectory()) {
        if (entry.name !== 'node_modules') {
          walk(full);
        }
      } else if (INCLUDED.test(full) && !EXCLUDED.test(full)) {
        const rel = path
          .relative(path.resolve(__dirname, '..'), full)
          .replace(/\\/g, '/');
        const source = fs.readFileSync(full, 'utf8');
        for (const item of collect(source, full)) {
          out.push({
            file: rel,
            line: source.slice(0, item.start).split('\n').length,
            endLine: source.slice(0, item.end).split('\n').length,
            kind: item.kind,
            texts: item.texts,
            slots: item.slots,
          });
        }
      }
    }
  };
  walk(path.resolve(__dirname, 'packages'));
  fs.writeFileSync(process.argv[3], JSON.stringify(out));
  console.log(`zdań i napisów okien: ${out.length} -> ${process.argv[3]}`);
}
