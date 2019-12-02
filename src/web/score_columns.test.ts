import { ScoreColumns } from "./score_columns";

test("empty is safe", () => {
  const s = new ScoreColumns([[]]);
  expect(s.get(1, 1)).toBe(0);
  expect(s.get(2, 1)).toBe(0);
  expect(s.get(1, 2)).toBe(0);
});

test("indices are one-based", () => {
  const s = new ScoreColumns([
    [1, 2],
    [3, 4]
  ]);
  expect(s.get(0, 0)).toBe(0);
  expect(s.get(0, 1)).toBe(0);
  expect(s.get(1, 0)).toBe(0);
  expect(s.get(1, 1)).toBe(1);
  expect(s.get(1, 2)).toBe(2);
  expect(s.get(1, 3)).toBe(0);
  expect(s.get(2, 0)).toBe(0);
  expect(s.get(2, 1)).toBe(3);
  expect(s.get(2, 2)).toBe(4);
  expect(s.get(2, 3)).toBe(0);
  expect(s.get(3, 0)).toBe(0);
  expect(s.get(3, 1)).toBe(0);
  expect(s.get(3, 2)).toBe(0);
  expect(s.get(3, 3)).toBe(0);
});

test("updating does not change original", () => {
  const s1 = new ScoreColumns([[5, 6]]);
  const c1 = s1.column(1);
  const c2 = s1.column(2);

  const s2 = s1.updated(1, 2, v => v + 1);
  const s3 = s2.updated(1, 2, v => v + 1);

  expect(s1.get(1, 1)).toBe(5);
  expect(s1.get(1, 2)).toBe(6);
  expect(s1.column(1)).toBe(c1);
  expect(s1.column(2)).toBe(c2);
  expect(s2.get(1, 1)).toBe(5);
  expect(s2.get(1, 2)).toBe(7);
  expect(s3.get(1, 1)).toBe(5);
  expect(s3.get(1, 2)).toBe(8);
});

test("columns have stable identities", () => {
  const s = new ScoreColumns([
    [1, 2],
    [3, 4]
  ]);
  const c1 = s.column(1);
  const c2 = s.column(2);
  const c3 = s.column(3);

  expect(s.column(1)).toBe(c1);
  expect(s.column(2)).toBe(c2);
  expect(s.column(3)).toBe(c3);
});

test("updating preserves identify of unmodified columns", () => {
  const s0 = new ScoreColumns([
    [1, 2],
    [3, 4],
    [5, 6]
  ]);
  const s1 = s0.updated(2, 1, () => 9);

  expect(s0.get(2, 1)).toBe(3);
  expect(s1.get(2, 1)).toBe(9);

  expect(s0.column(1)).toBe(s1.column(1));
  expect(s0.column(2)).not.toBe(s1.column(2));
  expect(s0.column(3)).toBe(s1.column(3));
});
