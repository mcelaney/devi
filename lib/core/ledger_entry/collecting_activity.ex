defmodule Devi.Core.LedgerEntry.CollectingActivity do
  @moduledoc """
  Collecting activities involve the receipt of revenues from business activities
  """

  alias Devi.Core.Account
  alias Devi.Core.LedgerEntry

  @activity_tag :collecting

  @type receive_revenue_params :: %{
          asset_account: Account.t(),
          revenue_account: Account.t(),
          amount: pos_integer,
          inserted_at: DateTime.t()
        }

  @type receive_payment_on_account_params :: %{
          receivable_account: Account.t(),
          asset_account: Account.t(),
          amount: pos_integer,
          inserted_at: DateTime.t()
        }

  @doc """
  For use when revenue is earned.

  Increases a revenue account as well as an asset account.

  # Examples

  iex> revenue_account = %{type: :revenue, ...}
  ...> asset_account = %{type: :asset, ...}
  ...> params = %{
  ...>   revenue_account: revenue_account,
  ...>   asset_account: asset_account,
  ...>   amount: 50_000,
  ...>   inserted_at: ~U[2019-10-31 19:59:03Z]
  ...> }
  ...> Devi.Core.receive_revenue(params)
  {
    :collecting,
    [
      %Devi.Core.LedgerEntry{type: :increase, account: revenue_account, ...},
      %Devi.Core.LedgerEntry{type: :increase, account: asset_account, ...}
    ]
  }
  """
  @spec receive_revenue(receive_revenue_params) :: {:collecting, list(LedgerEntry.t())}
  def receive_revenue(%{
        asset_account: %{type: :asset} = asset,
        revenue_account: %{type: :revenue} = revenue,
        amount: amount,
        inserted_at: now
      }) do
    entries = [
      LedgerEntry.increase_by(asset, amount, now),
      LedgerEntry.increase_by(revenue, amount, now)
    ]

    {@activity_tag, entries}
  end

  @doc """
  For use when a payment is received on an accounts receivable acount.

  Increases one asset account and decreases another.

  # Examples

  iex> receivable_account = %{type: :asset, ...}
  ...> asset_account = %{type: :asset, ...}
  ...> params = %{
  ...>   receivable_account: receivable_account,
  ...>   asset_account: asset_account,
  ...>   amount: 50_000,
  ...>   inserted_at: ~U[2019-10-31 19:59:03Z]
  ...> }
  ...> Devi.Core.pay_dividend(params)
  {
    :financing,
    [
      %Devi.Core.LedgerEntry{type: :increase, account: receivable_account, ...},
      %Devi.Core.LedgerEntry{type: :decrease, account: asset_account, ...}
    ]
  }
  """
  @spec receive_payment_on_account(receive_payment_on_account_params) ::
          {:collecting, list(LedgerEntry.t())}
  def receive_payment_on_account(%{
        receivable_account: %{type: :asset} = receivable,
        asset_account: %{type: :asset} = asset,
        amount: amount,
        inserted_at: now
      }) do
    entries = [
      LedgerEntry.increase_by(asset, amount, now),
      LedgerEntry.decrease_by(receivable, amount, now)
    ]

    {@activity_tag, entries}
  end
end
