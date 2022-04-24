defmodule Devi.Core.LedgerEntry.FinancingActivity do
  @moduledoc """
  Financing activities involve the transition of assets to and from business
  owners. This involves capital contributions as well as dividend payments.
  """

  alias Devi.Core.Account
  alias Devi.Core.LedgerEntry

  @activity_tag :financing

  @type receive_capital_params :: %{
          capital_account: Account.t(),
          asset_account: Account.t(),
          amount: pos_integer,
          inserted_at: DateTime.t()
        }

  @type pay_dividend_params :: %{
          asset_account: Account.t(),
          dividend_account: Account.t(),
          amount: pos_integer,
          inserted_at: DateTime.t()
        }

  @doc """
  For use when an owner wants to make a contribution of some asset.

  Increases a capital account as well as an asset account.

  # Examples

  iex> capital_account = %{type: :capital, ...}
  ...> asset_account = %{type: :asset, ...}
  ...> params = %{
  ...>   capital_account: capital_account,
  ...>   asset_account: asset_account,
  ...>   amount: 500_000,
  ...>   inserted_at: ~U[2019-10-31 19:59:03Z]
  ...> }
  ...> Devi.Core.receive_capital(params)
  {
    :financing,
    [
      %Devi.Core.LedgerEntry{type: :increase, account: capital_account, ...},
      %Devi.Core.LedgerEntry{type: :increase, account: asset_account, ...}
    ]
  }
  """
  @spec receive_capital(receive_capital_params) :: {:financing, list(LedgerEntry.t())}
  def receive_capital(%{
        capital_account: %{type: :capital} = capital,
        asset_account: %{type: :asset} = asset,
        amount: amount,
        inserted_at: now
      }) do
    entries = [
      LedgerEntry.increase_by(capital, amount, now),
      LedgerEntry.increase_by(asset, amount, now)
    ]

    {@activity_tag, entries}
  end

  @doc """
  For use when paying shareholder dividends

  Increases a dividend account and decreases an asset account.

  # Examples

  iex> dividend_account = %{type: :dividend, ...}
  ...> asset_account = %{type: :asset, ...}
  ...> params = %{
  ...>   dividend_account: dividend_account,
  ...>   asset_account: asset_account,
  ...>   amount: 50_000,
  ...>   inserted_at: ~U[2019-10-31 19:59:03Z]
  ...> }
  ...> Devi.Core.pay_dividend(params)
  {
    :financing,
    [
      %Devi.Core.LedgerEntry{type: :increase, account: dividend_account, ...},
      %Devi.Core.LedgerEntry{type: :decrease, account: asset_account, ...}
    ]
  }
  """
  @spec pay_dividend(pay_dividend_params) :: {:financing, list(LedgerEntry.t())}
  def pay_dividend(%{
        asset_account: %{type: :asset} = asset,
        dividend_account: %{type: :dividend} = dividend,
        amount: amount,
        inserted_at: now
      }) do
    entries = [
      LedgerEntry.increase_by(dividend, amount, now),
      LedgerEntry.decrease_by(asset, amount, now)
    ]

    {@activity_tag, entries}
  end
end
