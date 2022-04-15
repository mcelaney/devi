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
end
