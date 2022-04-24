defmodule Devi.Core.LedgerEntry.InvestingActivity do
  @moduledoc """
  Operating activities involve payments made to acquire assets which might
  appreciate in value as needed by the business
  """

  alias Devi.Core.Account
  alias Devi.Core.LedgerEntry

  @activity_tag :investing

  @type pay_investment_params :: %{
          asset_account: Account.t(),
          investment_account: Account.t(),
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
  For use when there will be a trade of one asset for another

  Decreases an asset and increases an asset.

  # Examples

  iex> investment_account = %{type: :expense, ...}
  ...> asset_account = %{type: :asset, ...}
  ...> params = %{
  ...>   investment_account: investment_account,
  ...>   asset_account: asset_account,
  ...>   amount: 50_000,
  ...>   inserted_at: ~U[2019-10-31 19:59:03Z]
  ...> }
  ...> Devi.Core.pay_investment(params)
  {
    :investing,
    [
      %Devi.Core.LedgerEntry{type: :increase, account: investment_account, ...},
      %Devi.Core.LedgerEntry{type: :decrease, account: asset_account, ...}
    ]
  }
  """
  @spec pay_investment(pay_investment_params) :: {:investing, list(LedgerEntry)}
  def pay_investment(%{
        asset_account: %{type: :asset} = asset,
        investment_account: %{type: :asset} = investment,
        amount: amount,
        inserted_at: %DateTime{} = now
      }) do
    entries = [
      LedgerEntry.decrease_by(asset, amount, now),
      LedgerEntry.increase_by(investment, amount, now)
    ]

    {@activity_tag, entries}
  end

  @doc """
  For use when investments are made on account.

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
  ...> Devi.Core.accept_investing_liability(params)
  {
    :investing,
    [
      %Devi.Core.LedgerEntry{type: :increase, account: liability_account, ...},
      %Devi.Core.LedgerEntry{type: :increase, account: asset_account, ...}
    ]
  }
  """
  @spec accept_liability(accept_liability_params) :: {:investing, list(LedgerEntry)}
  def accept_liability(%{
        asset_account: %{type: :asset} = asset,
        liability_asset: %{type: :liability} = liability,
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
  For use when payments are made on investment liabilities.

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
  ...> Devi.Core.repay_investing_liability(params)
  {
    :investing,
    [
      %Devi.Core.LedgerEntry{type: :decrease, account: liability_account, ...},
      %Devi.Core.LedgerEntry{type: :decrease, account: asset_account, ...}
    ]
  }
  """
  @spec repay_obligation(repay_obligation_params) :: {:investing, list(LedgerEntry)}
  def repay_obligation(%{
        asset_account: %{type: :asset} = asset,
        liability_asset: %{type: :liability} = liability,
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
