// MAWAQIT icon font builder: SVG drawings -> TrueType font + Dart class, entirely in the browser.
// Used by tool/icons/icon_editor.html. No dependencies.
//
// Each icon in icons.json has a fixed code point (never reused), a `box` (its size: the longer side of the
// drawing, in font units out of 1000) and a `cy` (its vertical centre in font units). Drawings are centred
// horizontally on 500. Every glyph's left side bearing equals its xMin, which Android needs to centre icons.
(function () {
  'use strict';

  // ---------- SVG -> outlines (in the SVG's own user units, y down) ----------

  const SKIP = new Set(['defs', 'clipPath', 'mask', 'symbol', 'marker', 'pattern', 'linearGradient',
    'radialGradient', 'filter', 'metadata', 'title', 'desc', 'style']);
  const K = 0.5522847498; // circle-to-cubic constant

  function parsePathData(d) {
    // Returns absolute contours: [{start:[x,y], segs:[{t:'L'|'Q'|'C', ...}], closed}]
    const re = /([MmLlHhVvCcSsQqTtAaZz])|([-+]?(?:\d*\.\d+|\d+\.?)(?:[eE][-+]?\d+)?)/g;
    const toks = [];
    let m;
    while ((m = re.exec(d))) toks.push(m[1] || parseFloat(m[2]));
    const out = [];
    let i = 0, cmd = null, x = 0, y = 0, sx = 0, sy = 0, cur = null, lastC = null, lastQ = null;
    const num = () => {
      if (typeof toks[i] !== 'number') throw new Error('bad path data near "' + d.slice(0, 40) + '"');
      return toks[i++];
    };
    const flag = () => {
      // arc flags may be packed ("011"): take one digit from a number token
      let t = toks[i];
      if (typeof t !== 'number') throw new Error('bad arc flag');
      const s = String(toks[i]);
      if (s.length > 1 && (s[0] === '0' || s[0] === '1')) {
        toks[i] = parseFloat(s.slice(1)); return +s[0];
      }
      i++; return t ? 1 : 0;
    };
    const begin = (px, py) => { cur = { start: [px, py], segs: [], closed: false }; out.push(cur); };
    const ensure = () => { if (!cur || cur.closed) begin(x, y); };
    while (i < toks.length) {
      if (typeof toks[i] === 'string') cmd = toks[i++];
      else if (cmd === null) throw new Error('path data must start with a command');
      const rel = cmd === cmd.toLowerCase();
      const C = cmd.toUpperCase();
      const ox = rel ? x : 0, oy = rel ? y : 0;
      if (C === 'Z') {
        if (cur) { cur.closed = true; x = cur.start[0]; y = cur.start[1]; }
        lastC = lastQ = null;
        continue;
      }
      if (C === 'M') {
        x = ox + num(); y = oy + num(); sx = x; sy = y; begin(x, y);
        cmd = rel ? 'l' : 'L'; lastC = lastQ = null; continue;
      }
      ensure();
      if (C === 'L') { x = ox + num(); y = oy + num(); cur.segs.push({ t: 'L', p: [x, y] }); lastC = lastQ = null; }
      else if (C === 'H') { x = ox + num(); cur.segs.push({ t: 'L', p: [x, y] }); lastC = lastQ = null; }
      else if (C === 'V') { y = oy + num(); cur.segs.push({ t: 'L', p: [x, y] }); lastC = lastQ = null; }
      else if (C === 'C' || C === 'S') {
        let c1;
        if (C === 'C') c1 = [ox + num(), oy + num()];
        else c1 = lastC ? [2 * x - lastC[0], 2 * y - lastC[1]] : [x, y];
        const c2 = [ox + num(), oy + num()];
        x = ox + num(); y = oy + num();
        cur.segs.push({ t: 'C', c1, c2, p: [x, y] }); lastC = c2; lastQ = null;
      } else if (C === 'Q' || C === 'T') {
        let c;
        if (C === 'Q') c = [ox + num(), oy + num()];
        else c = lastQ ? [2 * x - lastQ[0], 2 * y - lastQ[1]] : [x, y];
        x = ox + num(); y = oy + num();
        cur.segs.push({ t: 'Q', c, p: [x, y] }); lastQ = c; lastC = null;
      } else if (C === 'A') {
        const rx = num(), ry = num(), rot = num(), large = flag(), sweep = flag();
        const nx = ox + num(), ny = oy + num();
        for (const s of arcToCubics(x, y, rx, ry, rot, large, sweep, nx, ny)) cur.segs.push(s);
        x = nx; y = ny; lastC = lastQ = null;
      } else throw new Error('unsupported path command ' + cmd);
    }
    void sx; void sy;
    return out;
  }

  function arcToCubics(x1, y1, rx, ry, phiDeg, fa, fs, x2, y2) {
    if (x1 === x2 && y1 === y2) return [];
    rx = Math.abs(rx); ry = Math.abs(ry);
    if (!rx || !ry) return [{ t: 'L', p: [x2, y2] }];
    const phi = phiDeg * Math.PI / 180, cos = Math.cos(phi), sin = Math.sin(phi);
    const dx = (x1 - x2) / 2, dy = (y1 - y2) / 2;
    const x1p = cos * dx + sin * dy, y1p = -sin * dx + cos * dy;
    const lam = (x1p * x1p) / (rx * rx) + (y1p * y1p) / (ry * ry);
    if (lam > 1) { rx *= Math.sqrt(lam); ry *= Math.sqrt(lam); }
    const num = rx * rx * ry * ry - rx * rx * y1p * y1p - ry * ry * x1p * x1p;
    const den = rx * rx * y1p * y1p + ry * ry * x1p * x1p;
    let co = Math.sqrt(Math.max(0, num / den));
    if (fa === fs) co = -co;
    const cxp = co * rx * y1p / ry, cyp = -co * ry * x1p / rx;
    const cx = cos * cxp - sin * cyp + (x1 + x2) / 2, cy = sin * cxp + cos * cyp + (y1 + y2) / 2;
    const ang = (ux, uy, vx, vy) => {
      const a = Math.atan2(ux * vy - uy * vx, ux * vx + uy * vy);
      return a;
    };
    const t1 = ang(1, 0, (x1p - cxp) / rx, (y1p - cyp) / ry);
    let dt = ang((x1p - cxp) / rx, (y1p - cyp) / ry, (-x1p - cxp) / rx, (-y1p - cyp) / ry);
    if (!fs && dt > 0) dt -= 2 * Math.PI;
    if (fs && dt < 0) dt += 2 * Math.PI;
    const n = Math.ceil(Math.abs(dt) / (Math.PI / 2));
    const segs = [];
    const step = dt / n, k = 4 / 3 * Math.tan(step / 4);
    const pt = (t) => [cx + rx * Math.cos(t) * cos - ry * Math.sin(t) * sin, cy + rx * Math.cos(t) * sin + ry * Math.sin(t) * cos];
    const dpt = (t) => [-rx * Math.sin(t) * cos - ry * Math.cos(t) * sin, -rx * Math.sin(t) * sin + ry * Math.cos(t) * cos];
    for (let j = 0; j < n; j++) {
      const a = t1 + j * step, b = a + step;
      const p0 = pt(a), p3 = pt(b), d0 = dpt(a), d3 = dpt(b);
      segs.push({ t: 'C', c1: [p0[0] + k * d0[0], p0[1] + k * d0[1]], c2: [p3[0] - k * d3[0], p3[1] - k * d3[1]], p: j === n - 1 ? [x2, y2] : p3 });
    }
    return segs;
  }

  function ellipsePath(cx, cy, rx, ry) {
    const kx = rx * K, ky = ry * K;
    return [{
      start: [cx + rx, cy], closed: true, segs: [
        { t: 'C', c1: [cx + rx, cy + ky], c2: [cx + kx, cy + ry], p: [cx, cy + ry] },
        { t: 'C', c1: [cx - kx, cy + ry], c2: [cx - rx, cy + ky], p: [cx - rx, cy] },
        { t: 'C', c1: [cx - rx, cy - ky], c2: [cx - kx, cy - ry], p: [cx, cy - ry] },
        { t: 'C', c1: [cx + kx, cy - ry], c2: [cx + rx, cy - ky], p: [cx + rx, cy] },
      ],
    }];
  }

  function rectPath(x, y, w, h, rx, ry) {
    if (!rx && !ry) {
      return [{ start: [x, y], closed: true, segs: [{ t: 'L', p: [x + w, y] }, { t: 'L', p: [x + w, y + h] }, { t: 'L', p: [x, y + h] }, { t: 'L', p: [x, y] }] }];
    }
    rx = Math.min(rx || ry, w / 2); ry = Math.min(ry || rx, h / 2);
    const kx = rx * K, ky = ry * K;
    return [{
      start: [x + rx, y], closed: true, segs: [
        { t: 'L', p: [x + w - rx, y] },
        { t: 'C', c1: [x + w - rx + kx, y], c2: [x + w, y + ry - ky], p: [x + w, y + ry] },
        { t: 'L', p: [x + w, y + h - ry] },
        { t: 'C', c1: [x + w, y + h - ry + ky], c2: [x + w - rx + kx, y + h], p: [x + w - rx, y + h] },
        { t: 'L', p: [x + rx, y + h] },
        { t: 'C', c1: [x + rx - kx, y + h], c2: [x, y + h - ry + ky], p: [x, y + h - ry] },
        { t: 'L', p: [x, y + ry] },
        { t: 'C', c1: [x, y + ry - ky], c2: [x + rx - kx, y], p: [x + rx, y] },
      ],
    }];
  }

  function shapeContours(el) {
    const n = (a) => parseFloat(el.getAttribute(a) || '0');
    switch (el.localName) {
      case 'path': return parsePathData(el.getAttribute('d') || '');
      case 'rect': return rectPath(n('x'), n('y'), n('width'), n('height'), n('rx'), n('ry'));
      case 'circle': return ellipsePath(n('cx'), n('cy'), n('r'), n('r'));
      case 'ellipse': return ellipsePath(n('cx'), n('cy'), n('rx'), n('ry'));
      case 'polygon': case 'polyline': {
        const v = (el.getAttribute('points') || '').trim().split(/[\s,]+/).map(parseFloat);
        if (v.length < 6) return [];
        const segs = [];
        for (let i = 2; i + 1 < v.length; i += 2) segs.push({ t: 'L', p: [v[i], v[i + 1]] });
        return [{ start: [v[0], v[1]], segs, closed: true }];
      }
      default: return [];
    }
  }

  // Parse an SVG file into outlines in its root user space. `host` is an element in the live document: the
  // SVG is attached there (invisible) so the browser can resolve transforms and styles.
  function parseSvg(svgText, host) {
    const doc = new DOMParser().parseFromString(svgText, 'image/svg+xml');
    const root = doc.documentElement;
    if (!root || root.localName !== 'svg' || doc.getElementsByTagName('parsererror').length) {
      throw new Error('this file is not a valid SVG');
    }
    const svg = document.importNode(root, true);
    svg.setAttribute('width', '256'); svg.setAttribute('height', '256');
    svg.style.cssText = 'position:absolute;left:-10000px;top:0;visibility:hidden';
    host.appendChild(svg);
    try {
      const rootInv = svg.getScreenCTM().inverse();
      const groups = [];
      const warnings = new Set();
      const walk = (el) => {
        for (const child of el.children) {
          if (SKIP.has(child.localName)) continue;
          if (child.localName === 'image') { warnings.add('it contains an embedded image, which was ignored'); continue; }
          if (child.localName === 'text') { warnings.add('it contains text: convert text to outlines first'); continue; }
          const cs = getComputedStyle(child);
          if (cs.display === 'none') continue;
          if (['path', 'rect', 'circle', 'ellipse', 'polygon', 'polyline'].includes(child.localName)) {
            if (cs.fill === 'none') {
              if (cs.stroke !== 'none') warnings.add('a line-only (stroke) shape was ignored: outline strokes first');
              continue;
            }
            const m = rootInv.multiply(child.getScreenCTM());
            const tf = (p) => [m.a * p[0] + m.c * p[1] + m.e, m.b * p[0] + m.d * p[1] + m.f];
            const contours = shapeContours(child).map((c) => ({
              start: tf(c.start),
              segs: c.segs.map((s) => s.t === 'L' ? { t: 'L', p: tf(s.p) } : s.t === 'Q' ? { t: 'Q', c: tf(s.c), p: tf(s.p) } : { t: 'C', c1: tf(s.c1), c2: tf(s.c2), p: tf(s.p) }),
            })).filter((c) => c.segs.length);
            if (contours.length) groups.push({ contours, evenodd: cs.fillRule === 'evenodd' });
          } else if (child.localName === 'use') {
            warnings.add('a <use> element was ignored: ungroup / expand it first');
          } else {
            walk(child);
          }
        }
      };
      walk(svg);
      if (!groups.length) throw new Error('no filled shapes found in this SVG');
      return { groups, warnings: [...warnings] };
    } finally {
      host.removeChild(svg);
    }
  }

  // ---------- geometry helpers ----------

  function flatten(c, steps = 8) {
    const pts = [c.start];
    let p0 = c.start;
    for (const s of c.segs) {
      if (s.t === 'L') pts.push(s.p);
      else if (s.t === 'Q') for (let i = 1; i <= steps; i++) {
        const t = i / steps, u = 1 - t;
        pts.push([u * u * p0[0] + 2 * u * t * s.c[0] + t * t * s.p[0], u * u * p0[1] + 2 * u * t * s.c[1] + t * t * s.p[1]]);
      } else for (let i = 1; i <= steps; i++) {
        const t = i / steps, u = 1 - t;
        pts.push([u * u * u * p0[0] + 3 * u * u * t * s.c1[0] + 3 * u * t * t * s.c2[0] + t * t * t * s.p[0],
          u * u * u * p0[1] + 3 * u * u * t * s.c1[1] + 3 * u * t * t * s.c2[1] + t * t * t * s.p[1]]);
      }
      p0 = s.p;
    }
    return pts;
  }

  const area = (poly) => { let a = 0; for (let i = 0; i < poly.length; i++) { const p = poly[i], q = poly[(i + 1) % poly.length]; a += p[0] * q[1] - q[0] * p[1]; } return a / 2; };
  function inside(pt, poly) {
    let r = false;
    for (let i = 0, j = poly.length - 1; i < poly.length; j = i++) {
      const [xi, yi] = poly[i], [xj, yj] = poly[j];
      if ((yi > pt[1]) !== (yj > pt[1]) && pt[0] < (xj - xi) * (pt[1] - yi) / (yj - yi) + xi) r = !r;
    }
    return r;
  }
  function reverse(c) {
    const pts = [c.start, ...c.segs.map((s) => s.p)];
    const segs = [];
    for (let i = c.segs.length - 1; i >= 0; i--) {
      const s = c.segs[i], to = pts[i];
      if (s.t === 'L') segs.push({ t: 'L', p: to });
      else if (s.t === 'Q') segs.push({ t: 'Q', c: s.c, p: to });
      else segs.push({ t: 'C', c1: s.c2, c2: s.c1, p: to });
    }
    return { start: pts[pts.length - 1], segs };
  }

  // Make the glyph render the same under the non-zero rule TrueType uses, whatever fill rule the SVG had.
  // Works in the final y-up font space: outer contours clockwise (negative area), holes counter-clockwise.
  function orient(groups) {
    const out = [];
    for (const g of groups) {
      const polys = g.contours.map((c) => flatten(c));
      if (g.evenodd) {
        g.contours.forEach((c, i) => {
          let depth = 0;
          polys.forEach((p, j) => { if (j !== i && inside(polys[i][0], p)) depth++; });
          const cw = area(polys[i]) < 0;
          out.push((depth % 2 === 0) === cw ? c : reverse(c));
        });
      } else {
        let big = 0;
        polys.forEach((p, i) => { if (Math.abs(area(p)) > Math.abs(area(polys[big]))) big = i; });
        const flip = area(polys[big]) > 0;
        for (const c of g.contours) out.push(flip ? reverse(c) : c);
      }
    }
    return out;
  }

  function cubicToQuads(p0, c1, c2, p3, tol, out) {
    const dx = p3[0] - 3 * c2[0] + 3 * c1[0] - p0[0], dy = p3[1] - 3 * c2[1] + 3 * c1[1] - p0[1];
    if (Math.sqrt(3) / 36 * Math.hypot(dx, dy) <= tol || out.length > 64) {
      out.push({ t: 'Q', c: [(3 * (c1[0] + c2[0]) - p0[0] - p3[0]) / 4, (3 * (c1[1] + c2[1]) - p0[1] - p3[1]) / 4], p: p3 });
      return;
    }
    const mid = (a, b) => [(a[0] + b[0]) / 2, (a[1] + b[1]) / 2];
    const a = mid(p0, c1), b = mid(c1, c2), c = mid(c2, p3), ab = mid(a, b), bc = mid(b, c), m = mid(ab, bc);
    cubicToQuads(p0, a, ab, m, tol, out);
    cubicToQuads(m, bc, c, p3, tol, out);
  }

  // ---------- one icon -> TrueType glyph ----------

  // Ink bounds of the drawing in SVG units.
  function inkBounds(groups) {
    let x0 = Infinity, y0 = Infinity, x1 = -Infinity, y1 = -Infinity;
    for (const g of groups) for (const c of g.contours) for (const [x, y] of flatten(c, 16)) {
      if (x < x0) x0 = x; if (x > x1) x1 = x; if (y < y0) y0 = y; if (y > y1) y1 = y;
    }
    return [x0, y0, x1, y1];
  }

  // `parsed` from parseSvg; box/cy from icons.json. Returns {contours:[[{x,y,on}]], xMin,yMin,xMax,yMax}.
  function makeGlyph(parsed, box, cy, unitsPerEm) {
    const [x0, y0, x1, y1] = inkBounds(parsed.groups);
    const s = box / Math.max(x1 - x0, y1 - y0), icx = (x0 + x1) / 2, icy = (y0 + y1) / 2, cx = unitsPerEm / 2;
    const tf = (p) => [cx + (p[0] - icx) * s, cy - (p[1] - icy) * s];
    const groups = parsed.groups.map((g) => ({
      evenodd: g.evenodd,
      contours: g.contours.map((c) => ({
        start: tf(c.start),
        segs: c.segs.map((q) => q.t === 'L' ? { t: 'L', p: tf(q.p) } : q.t === 'Q' ? { t: 'Q', c: tf(q.c), p: tf(q.p) } : { t: 'C', c1: tf(q.c1), c2: tf(q.c2), p: tf(q.p) }),
      })),
    }));
    const contours = [];
    for (const c of orient(groups)) {
      const pts = [];
      const add = (p, on) => {
        const x = Math.round(p[0]), y = Math.round(p[1]), last = pts[pts.length - 1];
        if (last && last.x === x && last.y === y && last.on && on) return;
        pts.push({ x, y, on });
      };
      add(c.start, true);
      let p0 = c.start;
      for (const s of c.segs) {
        if (s.t === 'L') add(s.p, true);
        else if (s.t === 'Q') { add(s.c, false); add(s.p, true); }
        else { const qs = []; cubicToQuads(p0, s.c1, s.c2, s.p, 0.5, qs); for (const q of qs) { add(q.c, false); add(q.p, true); } }
        p0 = s.p;
      }
      // closing point duplicates the start
      const f = pts[0], l = pts[pts.length - 1];
      if (pts.length > 1 && l.on && l.x === f.x && l.y === f.y) pts.pop();
      if (pts.length >= 3) contours.push(pts);
    }
    let xMin = Infinity, yMin = Infinity, xMax = -Infinity, yMax = -Infinity;
    for (const c of contours) for (const p of c) {
      if (p.x < xMin) xMin = p.x; if (p.x > xMax) xMax = p.x; if (p.y < yMin) yMin = p.y; if (p.y > yMax) yMax = p.y;
    }
    return { contours, xMin, yMin, xMax, yMax };
  }

  // ---------- TrueType writer ----------

  class Buf {
    constructor() { this.b = []; }
    u8(v) { this.b.push(v & 255); return this; }
    u16(v) { this.b.push((v >> 8) & 255, v & 255); return this; }
    i16(v) { return this.u16(v < 0 ? v + 65536 : v); }
    u32(v) { this.u16(Math.floor(v / 65536) & 65535); return this.u16(v & 65535); }
    i64(v) { this.u32(Math.floor(v / 4294967296)); return this.u32(v % 4294967296); }
    tag(s) { for (const ch of s) this.u8(ch.charCodeAt(0)); return this; }
    bytes(a) { for (const v of a) this.b.push(v); return this; }
    pad4() { while (this.b.length % 4) this.b.push(0); return this; }
  }

  function glyfData(g) {
    const b = new Buf();
    if (!g.contours.length) return b.b;
    b.i16(g.contours.length).i16(g.xMin).i16(g.yMin).i16(g.xMax).i16(g.yMax);
    let n = 0;
    for (const c of g.contours) { n += c.length; b.u16(n - 1); }
    b.u16(0); // no instructions
    // Coordinates are deltas: 0 -> no byte, |d| < 256 -> one byte (sign in the flag), else two bytes.
    const all = g.contours.flat();
    const xs = new Buf(), ys = new Buf();
    let px = 0, py = 0;
    for (const p of all) {
      let f = p.on ? 1 : 0;
      const dx = p.x - px, dy = p.y - py;
      if (dx === 0) f |= 0x10; else if (Math.abs(dx) < 256) { f |= 0x02 | (dx > 0 ? 0x10 : 0); xs.u8(Math.abs(dx)); } else xs.i16(dx);
      if (dy === 0) f |= 0x20; else if (Math.abs(dy) < 256) { f |= 0x04 | (dy > 0 ? 0x20 : 0); ys.u8(Math.abs(dy)); } else ys.i16(dy);
      b.u8(f);
      px = p.x; py = p.y;
    }
    return b.bytes(xs.b).bytes(ys.b).b;
  }

  function utf16be(s) { const a = []; for (const ch of s) { const c = ch.charCodeAt(0); a.push(c >> 8, c & 255); } return a; }

  // glyphs: [{code:number, glyph}] (any order). Returns an ArrayBuffer.
  function buildFont(glyphs, font) {
    const upm = font.unitsPerEm, asc = font.ascent, desc = font.descent, fam = font.family;
    const list = [...glyphs].sort((a, b) => a.code - b.code);
    const notdef = { contours: [], xMin: 0, yMin: 0, xMax: 0, yMax: 0 };
    const order = [notdef, ...list.map((g) => g.glyph)];
    const ink = order.filter((g) => g.contours.length);
    const bxMin = Math.min(...ink.map((g) => g.xMin)), byMin = Math.min(...ink.map((g) => g.yMin));
    const bxMax = Math.max(...ink.map((g) => g.xMax)), byMax = Math.max(...ink.map((g) => g.yMax));

    const tables = {};
    // glyf + loca (long offsets)
    const glyf = new Buf(), loca = new Buf();
    for (const g of order) { loca.u32(glyf.b.length); glyf.bytes(glyfData(g)).pad4(); }
    loca.u32(glyf.b.length);
    tables.glyf = glyf.b; tables.loca = loca.b;

    tables.head = new Buf().u32(0x00010000).u32(0x00010000).u32(0).u32(0x5F0F3CF5).u16(0x000B).u16(upm)
      .i64(3900000000).i64(3900000000).i16(bxMin).i16(byMin).i16(bxMax).i16(byMax)
      .u16(0).u16(8).i16(2).i16(1).i16(0).b;

    const minRsb = Math.min(...ink.map((g) => upm - g.xMax));
    tables.hhea = new Buf().u32(0x00010000).i16(asc).i16(-desc).i16(0).u16(upm)
      .i16(Math.min(...ink.map((g) => g.xMin))).i16(minRsb).i16(bxMax).i16(1).i16(0).i16(0)
      .i16(0).i16(0).i16(0).i16(0).i16(0).u16(order.length).b;

    const hmtx = new Buf();
    for (const g of order) hmtx.u16(upm).i16(g.contours.length ? g.xMin : 0); // lsb = xMin (Android needs it)
    tables.hmtx = hmtx.b;

    const maxPts = Math.max(...ink.map((g) => g.contours.reduce((n, c) => n + c.length, 0)));
    const maxCont = Math.max(...ink.map((g) => g.contours.length));
    // version, numGlyphs, maxPoints, maxContours, composite points/contours, maxZones, then 8 unused limits
    tables.maxp = new Buf().u32(0x00010000).u16(order.length).u16(maxPts).u16(maxCont).u16(0).u16(0)
      .u16(2).u16(0).u16(0).u16(0).u16(0).u16(0).u16(0).u16(0).u16(0).b;

    const codes = list.map((g) => g.code);
    tables['OS/2'] = new Buf().u16(4).i16(upm).u16(400).u16(5).u16(0)
      .i16(650).i16(600).i16(0).i16(75).i16(650).i16(600).i16(0).i16(350).i16(50).i16(300).i16(0)
      .bytes([0, 0, 0, 0, 0, 0, 0, 0, 0, 0]).u32(0).u32(0).u32(0).u32(0).tag('MWQT').u16(0x0040)
      .u16(Math.min(...codes)).u16(Math.max(...codes)).i16(asc).i16(-desc).i16(0).u16(asc).u16(desc)
      .u32(1).u32(0).i16(0).i16(0).u16(0).u16(32).u16(1).b;

    // cmap format 4, one segment per icon + the 0xFFFF terminator
    const segs = list.map((g, i) => ({ start: g.code, end: g.code, delta: (i + 1 - g.code + 65536) % 65536 }));
    segs.push({ start: 0xFFFF, end: 0xFFFF, delta: 1 });
    const segX2 = segs.length * 2, sr = 2 * Math.pow(2, Math.floor(Math.log2(segs.length)));
    const f4 = new Buf().u16(4).u16(16 + segs.length * 8).u16(0).u16(segX2).u16(sr).u16(Math.log2(sr / 2)).u16(segX2 - sr);
    for (const s of segs) f4.u16(s.end);
    f4.u16(0);
    for (const s of segs) f4.u16(s.start);
    for (const s of segs) f4.u16(s.delta);
    for (let i = 0; i < segs.length; i++) f4.u16(0);
    tables.cmap = new Buf().u16(0).u16(1).u16(3).u16(1).u32(12).bytes(f4.b).b;

    const names = [[1, fam], [2, 'Regular'], [3, fam + '-Regular'], [4, fam + ' Regular'], [5, 'Version 1.0'], [6, fam + '-Regular']];
    const nb = new Buf().u16(0).u16(names.length).u16(6 + names.length * 12);
    const strs = [];
    let off = 0;
    for (const [id, s] of names) { const d = utf16be(s); nb.u16(3).u16(1).u16(0x409).u16(id).u16(d.length).u16(off); off += d.length; strs.push(...d); }
    tables.name = nb.bytes(strs).b;

    tables.post = new Buf().u32(0x00030000).u32(0).i16(-75).i16(50).u32(0).u32(0).u32(0).u32(0).u32(0).b;

    // assemble
    const tags = Object.keys(tables).sort();
    const n = tags.length, es = Math.pow(2, Math.floor(Math.log2(n)));
    const out = new Buf().u32(0x00010000).u16(n).u16(es * 16).u16(Math.log2(es)).u16(n * 16 - es * 16);
    let offset = 12 + n * 16;
    const sum = (a) => { let s = 0; for (let i = 0; i < a.length; i += 4) s = (s + ((a[i] << 24) >>> 0) + ((a[i + 1] || 0) << 16) + ((a[i + 2] || 0) << 8) + (a[i + 3] || 0)) >>> 0; return s; };
    const body = [];
    let headOffset = 0;
    for (const t of tags) {
      const d = tables[t];
      out.tag(t.padEnd(4, ' ')).u32(sum(d)).u32(offset).u32(d.length);
      if (t === 'head') headOffset = offset;
      for (const v of d) body.push(v);
      while (body.length % 4) body.push(0);
      offset = 12 + n * 16 + body.length;
    }
    const bytes = new Uint8Array(out.b.length + body.length);
    bytes.set(out.b, 0);
    bytes.set(body, out.b.length);
    const adj = (0xB1B0AFBA - sum(bytes)) >>> 0;
    new DataView(bytes.buffer).setUint32(headOffset + 8, adj);
    return bytes.buffer;
  }

  // ---------- Dart class and icons.json ----------

  function dartClass(data) {
    const f = data.font;
    const cls = f.className || f.family;
    const line = (name, code, mirror) =>
      `  static const IconData ${name} = IconData(0x${code}, fontFamily: _kFontFam, fontPackage: _kFontPkg${mirror ? ', matchTextDirection: true' : ''});`;
    const byName = Object.fromEntries(data.icons.map((i) => [i.name, i]));
    const out = [
      `// MAWAQIT icon font (${f.fontFile}).`,
      '//',
      '// Generated by tool/icons/icon_editor.html from the drawings in tool/icons/svg; do not',
      '// edit by hand. Solid single-colour glyphs.',
      "import 'package:flutter/widgets.dart';",
      '',
      `class ${cls} {`,
      `  ${cls}._();`,
      '',
      `  static const _kFontFam = '${f.family}';`,
      `  static const String? _kFontPkg = ${f.package ? `'${f.package}'` : 'null'};`,
      '',
      ...[...data.icons].sort((a, b) => (a.name < b.name ? -1 : 1)).map((i) => line(i.name, i.code, i.mirror)),
    ];
    if (data.aliases.length) {
      out.push('', '  // Same glyphs as arrow_left / arrow_right, mirrored in right-to-left languages (back / forward).');
      for (const a of data.aliases) out.push(line(a.name, byName[a.glyph].code, a.mirror));
    }
    out.push('}', '');
    return out.join('\n');
  }

  function jsonText(data) {
    const icons = [...data.icons].sort((a, b) => (a.name < b.name ? -1 : 1));
    const row = (o) => '  ' + JSON.stringify(o);
    return '{\n' +
      `"about": ${JSON.stringify(data.about)},\n` +
      `"font": ${JSON.stringify(data.font)},\n` +
      '"icons": [\n' + icons.map((i) => row({ name: i.name, code: i.code, box: i.box, cy: i.cy, mirror: i.mirror })).join(',\n') + '\n],\n' +
      '"aliases": [\n' + data.aliases.map(row).join(',\n') + '\n],\n' +
      `"retiredCodes": ${JSON.stringify(data.retiredCodes)}\n}\n`;
  }

  // Next free code point: never one in use, never a retired one.
  function nextCode(data) {
    const used = new Set([...data.icons.map((i) => parseInt(i.code, 16)), ...data.retiredCodes.map((c) => parseInt(c, 16))]);
    let c = 0xE800;
    for (const u of used) if (u >= c) c = u + 1;
    return c.toString(16);
  }

  // Centring check, the way Android draws: lsb must equal xMin (true by construction) and the ink must sit centred.
  function checkGlyph(g, unitsPerEm) {
    const problems = [];
    if (!g.contours.length) problems.push('empty drawing');
    const off = Math.abs((g.xMin + g.xMax) / 2 - unitsPerEm / 2) / unitsPerEm;
    if (off > 0.02) problems.push(`not centred (${(off * 100).toFixed(1)}%)`);
    if (g.xMin < -0.03 * unitsPerEm || g.xMax > 1.03 * unitsPerEm) problems.push('wider than the icon box');
    return problems;
  }

  window.IconFont = { parseSvg, makeGlyph, buildFont, dartClass, jsonText, nextCode, checkGlyph, inkBounds };
})();
