defmodule Devi.Core.GeneralLedger.EnterTransaction do
  @moduledoc """
  Provides functions for creating transactions to ensure correct handling of
  account entry
  """

  alias Devi.Core
  alias Devi.Core.GeneralLedger
  alias Devi.Core.GeneralLedger.Transaction
  alias Devi.Core.LedgerEntry

  @type account_id :: GeneralLedger.account_id()
  @type make_contribution_params :: %{
          capital_account_id: account_id,
          asset_account_id: account_id,
          amount: pos_integer,
          inserted_at: DateTime.t()
        }
  @type purchase_with_asset_params :: %{
          from_account_id: account_id,
          to_account_id: account_id,
          amount: pos_integer,
          inserted_at: DateTime.t()
        }
  @type purchase_on_account_params :: %{
          asset_account_id: account_id,
          liability_account_id: account_id,
          amount: pos_integer,
          inserted_at: DateTime.t()
        }
  @type earn_asset_revenue_params :: %{
          asset_account_id: account_id,
          revenue_account_id: account_id,
          amount: pos_integer,
          inserted_at: DateTime.t()
        }
  @type pay_on_account_params :: %{
          asset_account_id: account_id,
          liability_account_id: account_id,
          amount: pos_integer,
          inserted_at: DateTime.t()
        }
  @type pay_expenses_params :: %{
          asset_account_id: account_id,
          expense_account_id: account_id,
          amount: pos_integer,
          inserted_at: DateTime.t()
        }
  @type pay_dividend_params :: %{
          asset_account_id: account_id,
          dividend_account_id: account_id,
          amount: pos_integer,
          inserted_at: DateTime.t()
        }

  ######
  #
  # Make Capital Contributions
  #
  ###

  @doc """
  For use when an owner wants to make a contribution of some asset.
  """
  @spec make_contribution(GeneralLedger.t(), make_contribution_params) :: GeneralLedger.t()
  def make_contribution(
        %GeneralLedger{} = ledger,
        %{
          capital_account_id: capital_id,
          asset_account_id: asset_id,
          amount: amount,
          inserted_at: %DateTime{} = now
        }
      ) do
    [
      ledger |> Core.fetch_account!(asset_id) |> LedgerEntry.increase_by(amount, now),
      ledger |> Core.fetch_account!(capital_id) |> LedgerEntry.increase_by(amount, now)
    ]
    |> new(now)
    |> put_transaction(ledger)
  end

  ######
  #
  # Make Purchases
  #
  ###

  @doc """
  For use when there will be a trade of one asset for another
  """
  @spec purchase_with_asset(GeneralLedger.t(), purchase_with_asset_params) :: GeneralLedger.t()
  def purchase_with_asset(
        %GeneralLedger{} = ledger,
        %{
          from_account_id: from_id,
          to_account_id: to_id,
          amount: amount,
          inserted_at: %DateTime{} = now
        }
      ) do
    [
      ledger |> Core.fetch_account!(from_id) |> LedgerEntry.decrease_by(amount, now),
      ledger |> Core.fetch_account!(to_id) |> LedgerEntry.increase_by(amount, now)
    ]
    |> new(now)
    |> put_transaction(ledger)
  end

  @doc """
  For use when an asset will be aquired in exchage for a liability
  """
  @spec purchase_on_account(GeneralLedger.t(), purchase_on_account_params) :: GeneralLedger.t()
  def purchase_on_account(
        %GeneralLedger{} = ledger,
        %{
          asset_account_id: asset_id,
          liability_account_id: liability_id,
          amount: amount,
          inserted_at: %DateTime{} = now
        }
      ) do
    [
      ledger
      |> Core.fetch_account!(liability_id)
      |> LedgerEntry.increase_by(amount, now),
      ledger |> Core.fetch_account!(asset_id) |> LedgerEntry.increase_by(amount, now)
    ]
    |> new(now)
    |> put_transaction(ledger)
  end

  ######
  #
  # Earn Revenue
  #
  ###

  @doc """
  For use when revenue if earned
  """
  @spec earn_asset_revenue(GeneralLedger.t(), earn_asset_revenue_params) :: GeneralLedger.t()
  def earn_asset_revenue(
        %GeneralLedger{} = ledger,
        %{
          asset_account_id: asset_id,
          revenue_account_id: revenue_id,
          amount: amount,
          inserted_at: %DateTime{} = now
        }
      ) do
    [
      ledger |> Core.fetch_account!(asset_id) |> LedgerEntry.increase_by(amount, now),
      ledger |> Core.fetch_account!(revenue_id) |> LedgerEntry.increase_by(amount, now)
    ]
    |> new(now)
    |> put_transaction(ledger)
  end

  ######
  #
  # Make Payments
  #
  ###

  @doc """
  For use when paying off liabilities
  """
  @spec pay_on_account(GeneralLedger.t(), pay_on_account_params) :: GeneralLedger.t()
  def pay_on_account(
        %GeneralLedger{} = ledger,
        %{
          asset_account_id: asset_id,
          liability_account_id: liability_id,
          amount: amount,
          inserted_at: %DateTime{} = now
        }
      ) do
    [
      ledger
      |> Core.fetch_account!(liability_id)
      |> LedgerEntry.decrease_by(amount, now),
      ledger |> Core.fetch_account!(asset_id) |> LedgerEntry.decrease_by(amount, now)
    ]
    |> new(now)
    |> put_transaction(ledger)
  end

  @doc """
  For use when paying for an expense
  """
  @spec pay_expenses(GeneralLedger.t(), pay_expenses_params) :: GeneralLedger.t()
  def pay_expenses(
        %GeneralLedger{} = ledger,
        %{
          asset_account_id: asset_id,
          expense_account_id: expense_id,
          amount: amount,
          inserted_at: %DateTime{} = now
        }
      ) do
    [
      ledger |> Core.fetch_account!(expense_id) |> LedgerEntry.increase_by(amount, now),
      ledger |> Core.fetch_account!(asset_id) |> LedgerEntry.decrease_by(amount, now)
    ]
    |> new(now)
    |> put_transaction(ledger)
  end

  @doc """
  For use when paying shareholder dividends

  Note - there is no enforced connection between capital accounts and dividend
  accounts but in practice there is probably a correlation between the two
  """
  @spec pay_dividend(GeneralLedger.t(), pay_dividend_params) :: GeneralLedger.t()
  def pay_dividend(
        %GeneralLedger{} = ledger,
        %{
          asset_account_id: asset_id,
          dividend_account_id: dividend_id,
          amount: amount,
          inserted_at: %DateTime{} = now
        }
      ) do
    [
      ledger
      |> Core.fetch_account!(dividend_id)
      |> LedgerEntry.increase_by(amount, now),
      ledger |> Core.fetch_account!(asset_id) |> LedgerEntry.decrease_by(amount, now)
    ]
    |> new(now)
    |> put_transaction(ledger)
  end

  ######
  #
  # Shared
  #
  ###

  # This is here rather than on Transaction to emphasize the need to use the
  #   public interface to crete
  defp new([_ | [_ | _]] = account_entries, now) do
    %Transaction{
      account_entries: account_entries,
      inserted_at: now
    }
  end

  defp put_transaction(
         %Transaction{} = transaction,
         %GeneralLedger{journal_entries: transactions} = ledger
       ) do
    Map.put(ledger, :journal_entries, [transaction | transactions])
  end
end
