defmodule Devi.Core.Statement.RetainedEarnings do

  # alias Devi.Core.Transaction

  # @typedoc """
  # A date in `year-mo-da` format
  # """
  # @type date_string :: String.t()

  # @type t :: %__MODULE__{
  #   start_date: date_string,
  #   end_date: date_string,
  #   beginning_balance: non_neg_integer,
  #   net_income: non_neg_integer,
  #   dividends: non_neg_integer,
  #   ending_balance: non_neg_integer
  # }

  # @enforce_keys ~w[beginning_balance dividends end_date ending_balance net_income start_date]a
  # defstruct ~w[beginning_balance dividends end_date ending_balance net_income start_date]a

  # @spec new(list(Transaction.t()), date_string, date_string) :: t
  # def new(transactions, start_date, end_date) do
  #   %__MODULE__{}
  #   |> put_initial_balance(start_date, transactions)


  #   transactions
  #   |> Transaction.limit_by_date_range(start_date, end_date)
  #   |> Transaction.group_account_entries_by_accounts()
  #   |> pluck_dividends_and_revenues()
  #   |> transform_account_entries_to_subtotals()
  #   |> build_report()
  #   |> add_date_range(start_date, end_date)
  # end

  # def put_initial_balance(token, start_date, transactions) do
  #  %{} =
  #     transactions
  #     |> Transaction.from_before(start_date)
  #     |> Transaction.group_account_entries_by_accounts()


  #   %{token | beginning_balance: balance}
  # end


  # defp pluck_dividends_and_revenues(log) do
  #   %{
  #     expense: log[:expense] || %{},
  #     revenue: log[:revenue] || %{}
  #   }
  # end

  # defp transform_account_entries_to_subtotals(log) do
  #   Map.new(log, fn {parent_key, accounts} ->
  #     {
  #       parent_key,
  #       Map.new(accounts, fn {key, account_entries} ->
  #         {key, AccountEntry.subtotal(account_entries)}
  #       end)
  #     }
  #   end)
  # end

  # defp build_report(data) do
  #   expenses_sum = Enum.reduce(data[:expense], 0, fn {_key, value}, acc -> value + acc end)
  #   revenues_sum = Enum.reduce(data[:revenue], 0, fn {_key, value}, acc -> value + acc end)

  #   %__MODULE__{
  #     expenses: data[:expense],
  #     expenses_subtotal: expenses_sum,
  #     revenues: data[:revenue],
  #     revenues_subtotal: revenues_sum,
  #     total: revenues_sum - expenses_sum
  #   }
  # end

  # defp add_date_range(income_statement, start_date, end_date) do
  #   income_statement
  #   |> Map.put(:start_date, start_date)
  #   |> Map.put(:end_date, end_date)
  # end
end
