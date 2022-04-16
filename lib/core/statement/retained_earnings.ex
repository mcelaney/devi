defmodule Devi.Core.Statement.RetainedEarnings do
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
    end_date: ~D[2022-11-01],
    start_date: ~D[2022-11-30]
  }
  """
  alias Devi.Core.AccountEntry
  alias Devi.Core.Dateable
  alias Devi.Core.Transaction

  @typedoc """
  A date in `year-mo-da` format
  """
  @type date_value :: Dateable.date_value()

  @type t :: %__MODULE__{
          starting: non_neg_integer,
          net_income: non_neg_integer,
          dividends: non_neg_integer,
          ending: non_neg_integer,
          start_date: Date.t(),
          end_date: Date.t()
        }

  @enforce_keys ~w[starting net_income dividends ending start_date end_date]a
  defstruct ~w[starting net_income dividends ending start_date end_date]a

  @doc """
  Generates the data needed to display an income statement. These are summed
  values based on a given list of transations

  `new/3` will return the summary for a date bound subset of information

  # Examples
    
    iex> revenues = [
    ...>   %Devi.Core.AccountEntry{inserted_at: ~U[2022-01-03 23:50:07Z], ...},
    ...>   %Devi.Core.AccountEntry{inserted_at: ~U[2022-02-03 23:50:07Z], ...},
    ...>   %Devi.Core.AccountEntry{inserted_at: ~U[2022-03-03 23:50:07Z], ...}
    ...> ]
    ...> expenses = [
    ...>   %Devi.Core.AccountEntry{inserted_at: ~U[2022-01-03 23:50:07Z], ...},
    ...>   %Devi.Core.AccountEntry{inserted_at: ~U[2022-02-03 23:50:07Z], ...},
    ...>   %Devi.Core.AccountEntry{inserted_at: ~U[2022-03-03 23:50:07Z], ...}
    ...> ]
    ...> dividends = [
    ...>   %Devi.Core.AccountEntry{inserted_at: ~U[2022-01-03 23:50:07Z], ...},
    ...>   %Devi.Core.AccountEntry{inserted_at: ~U[2022-02-03 23:50:07Z], ...},
    ...>   %Devi.Core.AccountEntry{inserted_at: ~U[2022-03-03 23:50:07Z], ...}
    ...> ]
    ...> Devi.Core.Statement.Income.new(%{
    ...>   expenses: expenses,
    ...>   revenues: revenues,
    ...>   dividends: dividends,
    ...>   start_date: "2022-02-01",
    ...>   end_date: "2022-02-28"
    ...> })

    %Devi.Core.Statement.RetainedEarnings{
          starting: non_neg_integer,
          net_income: non_neg_integer,
          dividends: non_neg_integer,
          ending: non_neg_integer,
          start_date: Date.t(),
          end_date: Date.t()
        }

  """
  @spec new(%{
          expenses: list(Transaction.t()),
          revenues: list(Transaction.t()),
          start_date: date_value,
          end_date: date_value
        }) :: t
  def new(%{expense: expense, revenue: revenue, dividend: dividend, start_date: start_date, end_date: end_date}) do
    %{starting_subtotal: starting_expenses, subtotal: expense_subtotal} = calculate_split_sub_totals(expense, start_date, end_date)
    %{starting_subtotal: starting_revenues, subtotal: revenue_subtotal} = calculate_split_sub_totals(revenue, start_date, end_date)
    %{starting_subtotal: starting_dividends, subtotal: dividend_subtotal} = calculate_split_sub_totals(dividend, start_date, end_date)
    starting = starting_revenues - starting_expenses - starting_dividends

    %__MODULE__{
      dividends: dividend_subtotal,
      end_date: end_date,
      ending: starting + revenue_subtotal - expense_subtotal - dividend_subtotal,
      net_income: revenue_subtotal - expense_subtotal,
      start_date: start_date,
      starting: starting
    }
  end

  defp calculate_split_sub_totals(entries, start_date, end_date) do
    %{before_range: before_range, in_range: in_range} = Dateable.split_by_date(entries, start_date, end_date)

    %{starting_subtotal: AccountEntry.subtotal(before_range), subtotal: AccountEntry.subtotal(in_range)}
  end
end
