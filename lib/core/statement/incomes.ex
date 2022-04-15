defmodule Devi.Core.Statement.Incomes do
  # @moduledoc """
  # Provides information about the profitability of the company for a particular
  # period

  # In practice a printed income statement would look something like this:

  # |------------------------------------|
  # |          Income Statement          |
  # |       Month ending 2022/11/30      |
  # |------------------------------------|
  # | Revenues                           |
  # |   Ticket Revenue            $8,500 |
  # | Expenses                           |
  # |   Rent Expense      $2,000         |
  # |   Salary Expense     1,200         |
  # |     Total Expenses           3,200 |
  # |                              ----- |
  # |                             $5,300 |
  # |                              ===== |
  # |------------------------------------|

  # So we provide the values in a struct:

  # %Devi.Core.Statement.Income{
  #   end_date: "2022-11-01",
  #   expenses: %{rent: 2000, salary: 1200},
  #   expenses_subtotal: 3200,
  #   revenues: %{ticket: 8500},
  #   revenues_subtotal: 8500,
  #   start_date: "2022-11-30",
  #   total: 5300
  # }
  # """
  # alias Devi.Core.AccountEntry
  # alias Devi.Core.Transaction

  # @typedoc """
  # A date in `year-mo-da` format
  # """
  # @type date_string :: String.t()

  # @type t :: %__MODULE__{
  #         expenses: non_neg_integer,
  #         expenses_subtotal: non_neg_integer,
  #         revenues: non_neg_integer,
  #         revenues_subtotal: non_neg_integer,
  #         total: non_neg_integer,
  #         start_date: date_string | nil,
  #         end_date: date_string | nil
  #       }

  # @enforce_keys ~w[expenses expenses_subtotal revenues revenues_subtotal total]a
  # defstruct ~w[expenses expenses_subtotal revenues revenues_subtotal total start_date end_date]a

  # @doc """
  # Generates the data needed to display an income statement. These are summed
  # values based on a given list of transations

  # `new/3` will return the summary for a date bound subset of information

  # # Examples
    
  #   iex> transactions = [
  #   ...>   %Devi.Core.Transaction{inserted_at: ~U[2022-01-03 23:50:07Z], ...},
  #   ...>   %Devi.Core.Transaction{inserted_at: ~U[2022-02-03 23:50:07Z], ...},
  #   ...>   %Devi.Core.Transaction{inserted_at: ~U[2022-03-03 23:50:07Z], ...}
  #   ...> ]
  #   ...> Devi.Core.Statement.Income.new(transactions, "2022-02-01", "2022-02-28")

  #   %Devi.Core.Statement.Income{
  #     end_date: "2022-02-01",
  #     expenses: %{rent: 2000, salary: 1200},
  #     expenses_subtotal: 3200,
  #     revenues: %{ticket: 8500},
  #     revenues_subtotal: 8500,
  #     start_date: "2022-02-28",
  #     total: 5300
  #   }

  # """
  # @spec new(list(Transaction.t()), date_string, date_string) :: t
  # def new(%{expense_entriess: expenses, revenue_entriess: revenues, start_date: start_date, end_date: end_date}) do
  #   %__MODULE__{}
  #   |> put_account_summaries(expenses, :expenses, start_date, end_date)
  #   |> put_expenses_subtotal()
  #   |> put_account_summaries(expenses, :revenues, start_date, end_date)
  #   |> put_revenues_subtotal()
  #   |> put_total()
  #   |> put_dates(date_string, date_string)
  # end

  # defp put_account_summaries(token, entries, key, start_date, end_date)
end
















