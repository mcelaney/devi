defmodule Devi.Core do
  @moduledoc """
  A functional core for functionality provided by Devi
  """
  alias Devi.Core.GeneralLedger
  alias Devi.Core.LedgerEntry
  alias Devi.Core.Statements

  defdelegate account_types, to: GeneralLedger
  defdelegate add_account(ledger, account), to: GeneralLedger
  defdelegate update_account(ledger, account), to: GeneralLedger
  defdelegate fetch_account!(ledger, account), to: GeneralLedger

  defdelegate generate_income_statement(period_ledger), to: Statements
  defdelegate generate_retained_earnings_statement(period_ledgers), to: Statements
  defdelegate generate_balance_sheet_statement(period_ledger), to: Statements

  def accept_investing_liability(ledger, params) do
    params
    |> LedgerEntry.accept_investing_liability()
    |> add_to_ledger(ledger, params)
  end

  def accept_operating_liability(ledger, params) do
    params
    |> LedgerEntry.accept_operating_liability()
    |> add_to_ledger(ledger, params)
  end

  def pay_dividend(ledger, params) do
    params
    |> LedgerEntry.pay_dividend()
    |> add_to_ledger(ledger, params)
  end

  def pay_investment(ledger, params) do
    params
    |> LedgerEntry.pay_investment()
    |> add_to_ledger(ledger, params)
  end

  def pay_operating_expense(ledger, params) do
    params
    |> LedgerEntry.pay_operating_expense()
    |> add_to_ledger(ledger, params)
  end

  def receive_capital(ledger, params) do
    params
    |> LedgerEntry.receive_capital()
    |> add_to_ledger(ledger, params)
  end

  def receive_payment_on_account(ledger, params) do
    params
    |> LedgerEntry.receive_payment_on_account()
    |> add_to_ledger(ledger, params)
  end

  def receive_revenue(ledger, params) do
    params
    |> LedgerEntry.receive_revenue()
    |> add_to_ledger(ledger, params)
  end

  def repay_investing_obligation(ledger, params) do
    params
    |> LedgerEntry.repay_investing_obligation()
    |> add_to_ledger(ledger, params)
  end

  def repay_operating_obligation(ledger, params) do
    params
    |> LedgerEntry.repay_operating_obligation()
    |> add_to_ledger(ledger, params)
  end

  defp add_to_ledger({tag, entries}, ledger, %{inserted_at: now}) do
    GeneralLedger.add_to_ledger(ledger, entries, now, %{activity_tag: tag})
  end
end
