/**
 * An immutable one-dimensional array of numbers with one-based indices.
 */
export class ScoreColumn {
  constructor(private values: readonly number[] = []) {}

  get(table: number): number {
    return this.values[table - 1] || 0;
  }

  updated(table: number, updater: (v: number) => number): ScoreColumn {
    const newValues = Array.from(this.values);
    newValues[table - 1] = updater(newValues[table - 1] || 0) || 0;
    return new ScoreColumn(newValues);
  }
}

/**
 * An immutable two-dimensional array of numbers with one-based indices.
 * Each column can be accessed independently. The identify of any unchanged
 * columns will be preserved across updates.
 */
export class ScoreColumns {
  private static EMPTY_COLUMN = new ScoreColumn();
  private columns: ScoreColumn[];

  constructor(columns: readonly (readonly number[] | ScoreColumn)[]) {
    this.columns = columns.map(column =>
      column instanceof ScoreColumn ? column : new ScoreColumn(column)
    );
  }

  column(game: number): ScoreColumn {
    return this.columns[game - 1] || ScoreColumns.EMPTY_COLUMN;
  }

  get(game: number, table: number): number {
    return this.column(game).get(table);
  }

  updated(
    game: number,
    table: number,
    updater: (v: number) => number
  ): ScoreColumns {
    const newColumns = Array.from(this.columns);
    newColumns[game - 1] = this.column(game).updated(table, updater);
    return new ScoreColumns(newColumns);
  }
}

/**
 * Calls a function with values from 1 to n, inclusive.
 * @param n The maximum value.
 * @param each The function to call.
 */
export function forOneTo(n: number, each: (v: number) => void): void {
  for (let i = 1; i <= n; i++) {
    each(i);
  }
}

/**
 * Creates an array of length n with the results of calling a function with
 * values from 1 to n, inclusive.
 * @param n The maximum value.
 * @param each The function to call.
 * @return An array containing the result of each function call.
 */
export function mapOneTo<T>(n: number, each: (v: number) => T): T[] {
  return Array.from({ length: n }, (_, i) => each(i + 1));
}
