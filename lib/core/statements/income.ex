defmodule Devi.Core.Statements.Income do
  @moduledoc """
  Provides information about the profitability of the company for a particular
  period

  In practice a printed income statement would look something like this:

  |------------------------------------|
  |          Income Statement          |
  |       Month ending 2022/11/30      |
  |------------------------------------|
  | Revenues                           |
  |   Ticket Revenue            $8,500 |
  | Expenses                           |
  |   Rent Expense      $2,000         |
  |   Salary Expense     1,200         |
  |     Total Expenses           3,200 |
  |                              ----- |
  |                             $5,300 |
  |                              ===== |
  |------------------------------------|

  So we provide the values in a struct:

  %Devi.Core.Statement.Income{
    period_end: ~D[2022-11-01],
    expenses: %{rent: 2000, salary: 1200},
    expenses_subtotal: 3200,
    revenues: %{ticket: 8500},
    revenues_subtotal: 8500,
    period_start: ~D[2022-11-30],
    total: 5300
  }
  """
  alias Devi.Core.Dateable
  alias Devi.Core.PeriodLedger

  @typedoc """
  A date in `year-mo-da` format
  """
  @type date_value :: Dateable.date_value()

  @type t :: %__MODULE__{
          expenses: %{optional(any) => non_neg_integer},
          expenses_subtotal: non_neg_integer,
          revenues: %{optional(any) => non_neg_integer},
          revenues_subtotal: non_neg_integer,
          total: non_neg_integer,
          period_start: Date.t(),
          period_end: Date.t()
        }

  defstruct ~w[expenses expenses_subtotal revenues revenues_subtotal total period_start period_end]a

  @doc """
  Generates the data needed to display an income statement. These are summed
  values based on a given list of transations

  `new/1` will return the summary for a date bound subset of information

  # Examples
    
    iex> Devi.Core.Statement.Income.new(%PeriodLedger{...})

    %Devi.Core.Statement.Income{
      end_date: "2022-02-01",
      expenses: %{rent: 2000, salary: 1200},
      expenses_subtotal: 3200,
      revenues: %{ticket: 8500},
      revenues_subtotal: 8500,
      start_date: "2022-02-28",
      total: 5300
    }

  """
  @spec new(PeriodLedger.t()) :: t
  def new(%PeriodLedger{} = period_ledger) do
    %__MODULE__{}
    |> put_account_summaries(period_ledger)
    |> put_subtotals(period_ledger)
    |> put_total()
    |> put_dates(period_ledger)
  end

  defp put_account_summaries(token, period_ledger) do
    %{expense: expense, revenue: revenue} =
      PeriodLedger.fetch_sub_totals(period_ledger, [:expense, :revenue])

    %{token | expenses: expense, revenues: revenue}
  end

  defp put_subtotals(token, period_ledger) do
    %{expense: expense, revenue: revenue} =
      PeriodLedger.fetch_totals(period_ledger, [:expense, :revenue])

    %{token | expenses_subtotal: expense, revenues_subtotal: revenue}
  end

  defp put_total(%{expenses_subtotal: expenses, revenues_subtotal: revenues} = token) do
    %{token | total: revenues - expenses}
  end

  defp put_dates(token, %{period_start: nil, period_end: nil}), do: token

  defp put_dates(token, %{period_start: nil, period_end: period_end}) do
    %{token | period_end: Dateable.to_date(period_end)}
  end

  defp put_dates(token, %{period_start: period_start, period_end: period_end}) do
    %{
      token
      | period_start: Dateable.to_date(period_start),
        period_end: Dateable.to_date(period_end)
    }
  end
end
