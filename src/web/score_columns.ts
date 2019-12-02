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
