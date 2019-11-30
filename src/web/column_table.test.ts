import { ColumnTable } from "./column_table";

test("empty table", () => {
  const t = new ColumnTable(0, 0);
  expect(t.rows).toBe(0);
  expect(t.cols).toBe(0);
  expect(t.at(0, 0)).toBe(0);
  expect(t.at(1, 1)).toBe(0);
});

test("updating table does not change original", () => {
  const t0 = new ColumnTable(4, 3);
  const t1 = t0.updated(2, 1, v => v + 1);
  const t2 = t1.updated(2, 1, v => v + 1);

  expect(t2.rows).toBe(4);
  expect(t2.cols).toBe(3);
  expect(t0.at(2, 1)).toBe(0);
  expect(t1.at(2, 1)).toBe(1);
  expect(t2.at(2, 1)).toBe(2);
});

test("updating table keeps identify of unmodified columns", () => {
  const t0 = new ColumnTable(4, 3);
  const t1 = t0.updated(2, 1, v => v + 1);

  expect(t1.column(1)).toHaveProperty([2], 1);
  expect(t0.column(1)).not.toBe(t1.column(1));

  expect(t0.column(0)).toBe(t1.column(0));
  expect(t0.column(2)).toBe(t1.column(2));
});

test("resizing table hides out-of-range data", () => {
  const t0 = new ColumnTable(3, 2, [
    [1, 2, 3],
    [4, 5, 6]
  ]);
  const t1 = t0.resized(1, 2);
  expect(t1.at(0, 1)).toBe(4);
  expect(t0.at(1, 1)).toBe(5);
  expect(t1.at(1, 1)).toBe(0);
});

test("resizing table does not lose data", () => {
  const t0 = new ColumnTable(3, 2, [
    [1, 2, 3],
    [4, 5, 6]
  ]);
  const t1 = t0
    .resized(1, 2)
    .updated(0, 1, () => 9)
    .resized(3, 2);
  expect(t1.at(0, 1)).toBe(9);
  expect(t1.at(2, 1)).toBe(6);
});
