defmodule Devi.Core do
  @moduledoc """
  A functional core for functionality provided by Devi
  """
  alias Devi.Core.GeneralLedger
  alias Devi.Core.Statements

  defdelegate account_types, to: GeneralLedger
  defdelegate add_account(ledger, account), to: GeneralLedger
  defdelegate update_account(ledger, account), to: GeneralLedger
  defdelegate fetch_account!(ledger, account), to: GeneralLedger

  defdelegate earn_asset_revenue(ledger, params), to: GeneralLedger
  defdelegate make_contribution(ledger, params), to: GeneralLedger
  defdelegate pay_dividend(ledger, params), to: GeneralLedger
  defdelegate pay_expenses(ledger, params), to: GeneralLedger
  defdelegate pay_on_account(ledger, params), to: GeneralLedger
  defdelegate purchase_on_account(ledger, params), to: GeneralLedger
  defdelegate purchase_with_asset(ledger, params), to: GeneralLedger

  defdelegate generate_income_statement(subledger), to: Statements
  defdelegate generate_retained_earnings_statement(subledgers), to: Statements
  defdelegate generate_balance_sheet_statement(subledger), to: Statements
end
