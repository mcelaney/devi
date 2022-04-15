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

  defstruct ~w[account_entries inserted_at]a

  @doc """
  Given a list of transactions creates a nested grouping of transations based on
  the related accounts.

  ## Examples

    iex> transactions = [
    ...>   %Transaction{
    ...>     account_entries: [
    ...>       %AccountEntry{ account: %Account{type: :asset, id: :cash}, ... },
    ...>       %AccountEntry{ account: %Account{type: :capital, id: :mac}, ... }
    ...>     ],
    ...>     inserted_at: ~U[2022-03-03 23:50:07Z]
    ...>   },
    ...>   %Devi.Core.Transaction{
    ...>     account_entries: [
    ...>       %AccountEntry{ account: %Account{type: :asset, id: :cash}, ... },
    ...>       %AccountEntry{ account: %Account{type: :asset, id: :land}, ... }
    ...>     ],
    ...>     inserted_at: ~U[2022-03-03 23:50:07Z]
    ...>   }
    ...> ]
    ...> Transaction.group_account_entries_by_accounts(transactions)

    %{
      asset: %{
        cash: [
          %AccountEntry{ account: %Account{type: :asset, id: :cash}, ... },
          %AccountEntry{ account: %Account{type: :asset, id: :cash}, ... }
        ],
        land: [
          %AccountEntry{ account: %Account{type: :asset, id: :land}, ... }
        ]
      },
      capital: %{
        mac: [
          %AccountEntry{ account: %Account{type: :capital, id: :mac}, ... }
        ]
      }
    }

  """
  @spec group_account_entries_by_accounts(list(t)) :: map
  def group_account_entries_by_accounts(transactions) do
    transactions
    |> group_by_account_types()
    |> Map.new(fn {k, v} ->
      {k, Enum.group_by(v, fn %{account: %{id: account}} -> account end)}
    end)
  end

  @doc """
  Given a list of transactions creates a nested grouping of transations based on
  the related accounts.

  ## Examples

    iex> transactions = [
    ...>   %Transaction{
    ...>     account_entries: [
    ...>       %AccountEntry{ account: %Account{type: :asset}, ... },
    ...>       %AccountEntry{ account: %Account{type: :capital}, ... }
    ...>     ],
    ...>     inserted_at: ~U[2022-03-03 23:50:07Z]
    ...>   },
    ...>   %Devi.Core.Transaction{
    ...>     account_entries: [
    ...>       %AccountEntry{ account: %Account{type: :asset}, ... },
    ...>       %AccountEntry{ account: %Account{type: :asset}, ... }
    ...>     ],
    ...>     inserted_at: ~U[2022-03-03 23:50:07Z]
    ...>   }
    ...> ]
    ...> Transaction.group_by_account_types(transactions)

    %{
      asset: [
        %AccountEntry{ account: %Axccount{type: :asset}, ... },
        %AccountEntry{ account: %Axccount{type: :asset}, ... }
        %AccountEntry{ account: %Axccount{type: :asset}, ... }
      ],
      capital: [
        %AccountEntry{ account: %Account{type: :capital}, ... }
      ]
    }

  """
  @spec group_by_account_types(list(t)) :: map
  def group_by_account_types(transactions) do
    transactions
    |> Enum.flat_map(fn %{account_entries: account_entries} -> account_entries end)
    |> Enum.group_by(fn %{account: %{type: type}} -> type end)
  end
end
