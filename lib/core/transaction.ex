defmodule Devi.Core.Transaction do
  @moduledoc """
  A transaction is a measurable event that affects the financial position of the
  business. In double entry accounting transactions will always involve two
  account_entries to the ledger and need to leave the accounting equation in
  balance.

  See `Devi.Core.Transaction.CreateCommands` for more information on creating
  these structs
  """
  alias Devi.Core.Transaction.CreateCommands

  @type t :: %__MODULE__{}

  defdelegate make_contribution(params, inserted_at), to: CreateCommands
  defdelegate purchase_with_asset(params, inserted_at), to: CreateCommands
  defdelegate purchase_on_account(params, inserted_at), to: CreateCommands
  defdelegate pay_on_account(params, inserted_at), to: CreateCommands
  defdelegate earn_asset_revenue(params, inserted_at), to: CreateCommands
  defdelegate pay_expenses(params, inserted_at), to: CreateCommands
  defdelegate pay_dividend(params, inserted_at), to: CreateCommands

  @enforce_keys ~w[account_entries inserted_at]a
  defstruct ~w[account_entries inserted_at]a

  @doc """
  Given a list of transactions creates a nested grouping of transations based on
  the related accounts.

  ## Examples

    iex> transactions = [
    ...>   %Transaction{
    ...>     account_entries: [
    ...>       %AccountEntry{ account: {:asset, :cash}, ... },
    ...>       %AccountEntry{ account: {:capital, :mac}, ... }
    ...>     ],
    ...>     inserted_at: ~U[2022-03-03 23:50:07Z]
    ...>   },
    ...>   %Devi.Core.Transaction{
    ...>     account_entries: [
    ...>       %AccountEntry{ account: {:asset, :cash}, ... },
    ...>       %AccountEntry{ account: {:asset, :land}, ... }
    ...>     ],
    ...>     inserted_at: ~U[2022-03-03 23:50:07Z]
    ...>   }
    ...> ]
    ...> Transaction.group_account_entries_by_accounts(transactions)

    %{
      asset: %{
        cash: [
          %AccountEntry{ account: {:asset, :cash}, ... },
          %AccountEntry{ account: {:asset, :cash}, ... }
        ],
        land: [
          %AccountEntry{ account: {:asset, :land}, ... }
        ]
      },
      capital: %{
        mac: [
          %AccountEntry{ account: {:capital, :mac}, ... }
        ]
      }
    }

  """
  @spec group_account_entries_by_accounts(list(t)) :: map
  def group_account_entries_by_accounts(transactions) do
    transactions
    |> Enum.flat_map(fn %{account_entries: account_entries} -> account_entries end)
    |> Enum.group_by(fn %{account: {parent, _account}} -> parent end)
    |> Map.new(fn {k, v} ->
      {k, Enum.group_by(v, fn %{account: {_parent, account}} -> account end)}
    end)
  end

  @doc """
  Given a list of transactions limits them to a given range between start_date 
  and end_date inclusively.

  The start_date and end_date values are expected as Strings "year-mo-da"

  # Examples

    iex> transactions = [
    ...>   %Devi.Core.Transaction{inserted_at: ~U[2022-01-03 23:50:07Z], ...},
    ...>   %Devi.Core.Transaction{inserted_at: ~U[2022-02-03 23:50:07Z], ...},
    ...>   %Devi.Core.Transaction{inserted_at: ~U[2022-03-03 23:50:07Z], ...}
    ...> ]
    ...> Transaction.limit_by_date_range(transactions, "2022-02-01", "2022-02-28")

    [
      %Devi.Core.Transaction{inserted_at: ~U[2022-02-03 23:50:07Z], ...},
    ]
  """
  @spec limit_by_date_range(list(t), String.t(), String.t()) :: list(t)
  def limit_by_date_range(transactions, start_date, end_date) do
    Enum.filter(transactions, fn transaction ->
      cond do
        DateTime.compare(transaction.inserted_at, datetime_value(:start, start_date)) == :lt ->
          false

        DateTime.compare(transaction.inserted_at, datetime_value(:end, end_date)) == :gt ->
          false

        true ->
          true
      end
    end)
  end

  def from_before(transactions, end_date) do
    Enum.filter(transactions, fn transaction ->
      cond do
        DateTime.compare(transaction.inserted_at, datetime_value(:end, end_date)) == :gt ->
          false

        true ->
          true
      end
    end)
  end

  defp datetime_value(:start, value),
    do: value |> Kernel.<>("T00:00:00Z") |> DateTime.from_iso8601() |> elem(1)

  defp datetime_value(:end, value),
    do: value |> Kernel.<>("T23:59:59Z") |> DateTime.from_iso8601() |> elem(1)
end
