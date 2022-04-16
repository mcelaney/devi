defmodule Devi.Core.Statement.Income do
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
    end_date: ~D[2022-11-01],
    expenses: %{rent: 2000, salary: 1200},
    expenses_subtotal: 3200,
    revenues: %{ticket: 8500},
    revenues_subtotal: 8500,
    start_date: ~D[2022-11-30],
    total: 5300
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
          expenses: %{optional(any) => non_neg_integer},
          expenses_subtotal: non_neg_integer,
          revenues: %{optional(any) => non_neg_integer},
          revenues_subtotal: non_neg_integer,
          total: non_neg_integer,
          start_date: Date.t(),
          end_date: Date.t()
        }

  @enforce_keys ~w[expenses expenses_subtotal revenues revenues_subtotal total start_date end_date]a
  defstruct ~w[expenses expenses_subtotal revenues revenues_subtotal total start_date end_date]a

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
    ...> Devi.Core.Statement.Income.new(%{expenses: expenses, revenues: revenues, start_date: "2022-02-01", end_date: "2022-02-28"})

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
  @spec new(%{
          expenses: list(Transaction.t()),
          revenues: list(Transaction.t()),
          start_date: date_value,
          end_date: date_value
        }) :: t
  def new(%{expenses: expenses, revenues: revenues, start_date: start_date, end_date: end_date}) do
    %__MODULE__{
      end_date: nil,
      expenses: nil,
      expenses_subtotal: nil,
      revenues: nil,
      revenues_subtotal: nil,
      start_date: nil,
      total: nil
    }
    |> put_account_summaries(expenses, revenues, start_date, end_date)
    |> put_subtotals()
    |> put_total()
    |> put_dates(start_date, end_date)
  end

  defp put_account_summaries(token, expenses, revenues, start_date, end_date) do
    %{
      token
      | expenses: group_by_account_and_sum(expenses, start_date, end_date),
        revenues: group_by_account_and_sum(revenues, start_date, end_date)
    }
  end

  defp put_subtotals(%{expenses: expenses, revenues: revenues} = token) do
    %{
      token
      | expenses_subtotal: sum_subtotals(expenses),
        revenues_subtotal: sum_subtotals(revenues)
    }
  end

  defp put_total(%{expenses_subtotal: expenses, revenues_subtotal: revenues} = token) do
    %{token | total: revenues - expenses}
  end

  defp put_dates(token, start_date, end_date) do
    %{token | start_date: Dateable.to_date(start_date), end_date: Dateable.to_date(end_date)}
  end

  def sum_subtotals(subtotals) do
    Enum.reduce(subtotals, 0, fn {_key, value}, acc -> value + acc end)
  end

  defp group_by_account_and_sum(entries, start_date, end_date) do
    entries
    |> Dateable.limit_by_date_range(start_date, end_date)
    |> AccountEntry.to_subtotals()
  end
end
