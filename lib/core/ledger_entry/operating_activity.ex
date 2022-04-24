defmodule Devi.Core.LedgerEntry.OperatingActivity do
  @moduledoc """
  Operating activities involve payments made on goods and services required to
  produce revenues
  """

  alias Devi.Core.Account
  alias Devi.Core.LedgerEntry

  @activity_tag :operating

  @type pay_operating_expense_params :: %{
          asset_account: Account.t(),
          expense_account: Account.t(),
          amount: pos_integer,
          inserted_at: DateTime.t()
        }

  @type accept_liability_params :: %{
          asset_account: Account.t(),
          liability_account: Account.t(),
          amount: pos_integer,
          inserted_at: DateTime.t()
        }

  @type repay_obligation_params :: %{
          asset_account: Account.t(),
          liability_account: Account.t(),
          amount: pos_integer,
          inserted_at: DateTime.t()
        }

  @doc """
  For use when expenses are purchased.

  Decreases an asset and increases an expense.

  # Examples

  iex> expense_account = %{type: :expense, ...}
  ...> asset_account = %{type: :asset, ...}
  ...> params = %{
  ...>   expense_account: expense_account,
  ...>   asset_account: asset_account,
  ...>   amount: 50_000,
  ...>   inserted_at: ~U[2019-10-31 19:59:03Z]
  ...> }
  ...> Devi.Core.pay_operating_expense(params)
  {
    :operating,
    [
      %Devi.Core.LedgerEntry{type: :increase, account: expense_account, ...},
      %Devi.Core.LedgerEntry{type: :decrease, account: asset_account, ...}
    ]
  }
  """
  @spec pay_operating_expense(pay_operating_expense_params) :: {:operating, list(LedgerEntry)}
  def pay_operating_expense(%{
        asset_account: %{type: :asset} = asset,
        expense_account: %{type: :expense} = expense,
        amount: amount,
        inserted_at: %DateTime{} = now
      }) do
    entries = [
      LedgerEntry.decrease_by(asset, amount, now),
      LedgerEntry.increase_by(expense, amount, now)
    ]

    {@activity_tag, entries}
  end

  @doc """
  For use when expenses are made on account.

  Increases an asset and increases a liability.

  # Examples

  iex> liability_account = %{type: :liability, ...}
  ...> asset_account = %{type: :asset, ...}
  ...> params = %{
  ...>   liability_account: liability_account,
  ...>   asset_account: asset_account,
  ...>   amount: 50_000,
  ...>   inserted_at: ~U[2019-10-31 19:59:03Z]
  ...> }
  ...> Devi.Core.accept_operating_liability(params)
  {
    :operating,
    [
      %Devi.Core.LedgerEntry{type: :increase, account: liability_account, ...},
      %Devi.Core.LedgerEntry{type: :increase, account: asset_account, ...}
    ]
  }
  """
  @spec accept_liability(accept_liability_params) :: {:operating, list(LedgerEntry)}
  def accept_liability(%{
        asset_account: %{type: :asset} = asset,
        liability_account: %{type: :liability} = liability,
        amount: amount,
        inserted_at: %DateTime{} = now
      }) do
    entries = [
      LedgerEntry.increase_by(liability, amount, now),
      LedgerEntry.increase_by(asset, amount, now)
    ]

    {@activity_tag, entries}
  end

  @doc """
  For use when payments are made on expense liabilities.

  Decreases an asset and a liability.

  # Examples

  iex> liability_account = %{type: :liability, ...}
  ...> asset_account = %{type: :asset, ...}
  ...> params = %{
  ...>   liability_account: liability_account,
  ...>   asset_account: asset_account,
  ...>   amount: 50_000,
  ...>   inserted_at: ~U[2019-10-31 19:59:03Z]
  ...> }
  ...> Devi.Core.repay_operating_liability(params)
  {
    :operating,
    [
      %Devi.Core.LedgerEntry{type: :decrease, account: liability_account, ...},
      %Devi.Core.LedgerEntry{type: :decrease, account: asset_account, ...}
    ]
  }
  """
  @spec repay_obligation(repay_obligation_params) :: {:operating, list(LedgerEntry)}
  def repay_obligation(%{
        asset_account: %{type: :asset} = asset,
        liability_account: %{type: :liability} = liability,
        amount: amount,
        inserted_at: %DateTime{} = now
      }) do
    entries = [
      LedgerEntry.decrease_by(liability, amount, now),
      LedgerEntry.decrease_by(asset, amount, now)
    ]

    {@activity_tag, entries}
  end
end
