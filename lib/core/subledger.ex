defmodule Devi.Core.Subledger do
  @moduledoc """
  A subledger represents the changes to general ledger over a specific time period

  While a GeneralLedger holds transactions and is the source of truth for the
  system - Subledgers serve as materialized views which contain LedgerEntries but
  no record of why those entries exist. Subledgers can be rebuilt from the
  GeneralLedger whenever necessary - but in theory once the books are closed on a
  period this should be unneccessary.
  """

  alias Devi.Core.Dateable
  alias Devi.Core.GeneralLedger
  alias Devi.Core.GeneralLedger.Transaction
  alias Devi.Core.LedgerEntry

  @type t :: %__MODULE__{}
  @type filter_information ::
          %{period_before: Dateable.date_value()}
          | %{period_start: Dateable.date_value(), period_end: Dateable.date_value()}

  defstruct asset: [],
            capital: [],
            dividend: [],
            expense: [],
            liability: [],
            revenue: [],
            period_end: nil,
            period_start: nil

  @spec build(GeneralLedger.t(), filter_information) :: t
  def build(%GeneralLedger{journal_entries: transactions}, options \\ %{}) do
    transactions
    |> limit_to_period(options)
    |> Enum.reduce(%__MODULE__{}, fn %Transaction{account_entries: account_entries}, sub_ledger ->
      add_entries_to_sub_ledger(sub_ledger, account_entries)
    end)
    |> add_period_info(options)
  end

  defp limit_to_period(entries, %{period_before: end_date}) do
    Dateable.entries_before(entries, end_date)
  end

  defp limit_to_period(entries, %{period_start: start_date, period_end: end_date}) do
    Dateable.entries_in_range(entries, start_date, end_date)
  end

  defp limit_to_period(entries, _), do: entries

  defp add_entries_to_sub_ledger(sub_ledger, account_entries) do
    Enum.reduce(
      account_entries,
      sub_ledger,
      fn %LedgerEntry{account: %{type: type}} = entry, ledger ->
        current_entries = Map.fetch!(ledger, type)
        Map.put(ledger, type, [entry | current_entries])
      end
    )
  end

  defp add_period_info(ledger, %{period_before: limit}) do
    Map.put(ledger, :period_end, limit |> Dateable.to_date() |> Date.add(-1))
  end

  defp add_period_info(ledger, %{period_start: start_date, period_end: end_date}) do
    ledger
    |> Map.put(:period_start, Dateable.to_date(start_date))
    |> Map.put(:period_end, Dateable.to_date(end_date))
  end

  defp add_period_info(ledger, _), do: ledger

  @spec fetch_sub_totals(t, list(Account.account_type())) :: map
  def fetch_sub_totals(ledger, account_types) do
    Enum.reduce(account_types, %{}, fn key, acc ->
      values = ledger |> Map.fetch!(key) |> LedgerEntry.to_subtotals()
      Map.put(acc, key, values)
    end)
  end

  @spec fetch_totals(t, list(Account.account_type())) :: map
  def fetch_totals(ledger, account_types) do
    Enum.reduce(account_types, %{}, fn key, acc ->
      values = ledger |> Map.fetch!(key) |> LedgerEntry.subtotal()
      Map.put(acc, key, values)
    end)
  end
end
