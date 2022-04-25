defmodule Devi.Core.Statements do
  @moduledoc """
  Statements are documents used to communicate information needed to make
  financial decisions
  """

  alias Devi.Core.Statements.BalanceSheet
  alias Devi.Core.Statements.CashFlows
  alias Devi.Core.Statements.Income
  alias Devi.Core.Statements.RetainedEarnings

  defdelegate generate_income_statement(params), to: Income, as: :new
  defdelegate generate_retained_earnings_statement(params), to: RetainedEarnings, as: :new
  defdelegate generate_balance_sheet_statement(params), to: BalanceSheet, as: :new
  defdelegate generate_cash_flows_statement(params), to: CashFlows, as: :new
end
