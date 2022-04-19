defmodule Devi.Core.Statements.RetainedEarnings do
  @moduledoc """
  Provides information about the profitability of the company for a particular
  period

  In practice a printed income statement would look something like this:

  |----------------------------------------------|
  |       Statement of Retained Earnings         |
  |           Month ending 2022/11/30            |
  |----------------------------------------------|
  | Retained Earnings, Nov 1, 2016           $0  |
  | Net income for the month              $5300  |
  |                                       -----  |
  |                                       $5300  |
  | Dividends                            ($5000) |
  | Retained Earnings, Nov 30, 2016        $300  |
  |                                        ====  |
  |----------------------------------------------|

  So we provide the values in a struct:

  %Devi.Core.Statement.Income{
    starting: 0,
    net_income: 5300,
    dividends: 5000,
    ending: 300,
    period_end: ~D[2022-11-01],
    period_start: ~D[2022-11-30]
  }
  """
  alias Devi.Core.Dateable
  alias Devi.Core.Subledger

  @typedoc """
  A date in `year-mo-da` format
  """
  @type date_value :: Dateable.date_value()

  @type t :: %__MODULE__{
          starting: non_neg_integer,
          net_income: non_neg_integer,
          dividends: non_neg_integer,
          ending: non_neg_integer,
          period_start: Date.t(),
          period_end: Date.t()
        }

  defstruct ~w[starting net_income dividends ending period_start period_end]a

  @doc """
  Generates the data needed to display an income statement. These are summed
  values based on a given list of transations

  `new/3` will return the summary for a date bound subset of information

  # Examples
    
    iex> Devi.Core.Statement.Income.new(%Subledger{...})

    %Devi.Core.Statement.RetainedEarnings{
          starting: non_neg_integer,
          net_income: non_neg_integer,
          dividends: non_neg_integer,
          ending: non_neg_integer,
          period_start: Date.t(),
          period_end: Date.t()
        }

  """
  @spec new(%{history: Subledger.t(), period: Subledger.t()}) :: t
  def new(%{history: history_ledger, period: period_ledger}) do
    %{revenue: starting_revenues, expense: starting_expenses, dividend: starting_dividends} =
      Subledger.fetch_totals(history_ledger, [:revenue, :expense, :dividend])

    %{revenue: revenue_subtotal, expense: expense_subtotal, dividend: dividend_subtotal} =
      Subledger.fetch_totals(period_ledger, [:revenue, :expense, :dividend])

    starting = starting_revenues - starting_expenses - starting_dividends

    %__MODULE__{
      dividends: dividend_subtotal,
      period_end: period_ledger.period_end,
      ending: starting + revenue_subtotal - expense_subtotal - dividend_subtotal,
      net_income: revenue_subtotal - expense_subtotal,
      period_start: period_ledger.period_start,
      starting: starting
    }
  end
end